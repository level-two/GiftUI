import Foundation
import SwiftOperators
import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder

// P02 / SPEC-006 DV-RD-001. The existing macro target owns a finite, application-owned
// schema and rejects effects outside that schema. It does not infer Swift effects.
struct Field: Decodable {
    let name: String
    let type: String
    let indexed: Bool
    let members: [Field]?
}

struct SeedField: Decodable {
    let name: String
    let type: String
}

struct Model: Decodable {
    let authoredType: String
    let seedFields: [SeedField]?
    let schema: String
    let facade: String
    let fields: [Field]
}

struct Configuration: Decodable {
    let module: String
    let domain: String
    let imports: [String]
    let models: [Model]
    let calls: [String]
}

struct LoweringFailure: Error, CustomStringConvertible {
    let description: String
}

final class Inventory: SyntaxVisitor {
    var views: Set<String> = []
    var canvases: Set<String> = []
    var viewFunctions: Set<String> = []
    var memberViewFunctions: Set<String> = []
    var functions: Set<String> = []
    var values: Set<String> = []
    var valueTypes: Set<String> = []
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        valueTypes.insert(node.name.text)
        if node.inheritanceClause?.inheritedTypes.contains(where: {
            ["View", "Canvas"].contains($0.type.trimmedDescription)
        }) == true {
            views.insert(node.name.text)
            if node.inheritanceClause?.inheritedTypes.contains(where: {
                $0.type.trimmedDescription == "Canvas"
            }) == true {
                canvases.insert(node.name.text)
            }
            for member in node.memberBlock.members {
                if let function = member.decl.as(FunctionDeclSyntax.self),
                    function.signature.returnClause?.type.trimmedDescription == "some View"
                {
                    memberViewFunctions.insert(function.name.text)
                }
            }
        }
        return .visitChildren
    }
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        functions.insert(node.name.text)
        if node.signature.returnClause?.type.trimmedDescription == "some View" {
            viewFunctions.insert(node.name.text)
        }
        return .visitChildren
    }
    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        valueTypes.insert(node.name.text)
        return .visitChildren
    }
    override func visit(_ node: PatternBindingSyntax) -> SyntaxVisitorContinueKind {
        if let name = node.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
            values.insert(name)
        }
        return .visitChildren
    }
    override func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        values.insert((node.secondName ?? node.firstName).text)
        return .visitChildren
    }
}

private final class ThrowingExpressionScan: SyntaxVisitor {
    var containsTry = false
    override func visit(_ node: TryExprSyntax) -> SyntaxVisitorContinueKind {
        containsTry = true
        return .skipChildren
    }
}

final class Lowerer: SyntaxRewriter {
    static let ownedTypes: Set<String> = [
        "Bool", "UInt8", "UInt16", "UInt32", "Int", "Int32", "Int64", "Duration",
        "BoundedText", "Color", "GeometryScalar", "AcquisitionState", "DigitalLevel",
        "SignalChannelID", "SignalTransition", "Range<Duration>", "Point", "Size", "Rect",
        "StrokeStyle",
    ]
    let configuration: Configuration
    let inventory: Inventory
    let location: SourceLocationConverter
    var errors: [String] = []
    var bindings: [String: Model] = [:]
    var evaluating = false
    var insideView = false
    var insideCanvas = false
    var drawing = false
    var drawingContext = ""
    var drawingPath = ""
    var viewProperties: Set<String> = []
    var stateProperties: Set<String> = []

    init(configuration: Configuration, inventory: Inventory, source: SourceFileSyntax, file: String)
    {
        self.configuration = configuration
        self.inventory = inventory
        location = SourceLocationConverter(fileName: file, tree: source)
        super.init(viewMode: .sourceAccurate)
    }

    func reject(_ node: some SyntaxProtocol, _ reason: String) {
        let point = location.location(for: node.positionAfterSkippingLeadingTrivia)
        errors.append("\(point.file):\(point.line):\(point.column): error: RFC014: \(reason)")
    }

    override func visit(_ node: ImportDeclSyntax) -> DeclSyntax {
        let name = node.path.trimmedDescription
        if name != "GiftUI" && !configuration.imports.contains(name) {
            reject(node, "import '\(name)' is outside the finite presentation boundary")
        }
        return super.visit(node)
    }

    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        reject(node, "mutable reference declarations belong in the checked model owner")
        return DeclSyntax(node)
    }

    override func visit(_ node: InOutExprSyntax) -> ExprSyntax {
        reject(node, "unchecked inout is outside the finite source inventory")
        return ExprSyntax(node)
    }

    override func visit(_ node: FunctionParameterSyntax) -> FunctionParameterSyntax {
        if evaluating, stateProperties.contains((node.secondName ?? node.firstName).text) {
            reject(
                node, "parameter shadows a State declaration outside the finite source inventory")
        }
        let type = node.type.trimmedDescription
        if drawing && type == "inout GraphicsContext" { return super.visit(node) }
        if !Self.ownedTypes.contains(type.replacingOccurrences(of: "?", with: "")),
            !inventory.valueTypes.contains(type),
            !configuration.models.contains(where: { $0.authoredType == type })
        {
            reject(
                node,
                "parameter type '\(type)' has no inventoried owned-value or model-key representation"
            )
        }
        return super.visit(node)
    }

    override func visit(_ node: StructDeclSyntax) -> DeclSyntax {
        guard inventory.views.contains(node.name.text) else { return super.visit(node) }
        guard node.genericParameterClause == nil else {
            reject(node, "authored generic custom views are outside the finite source inventory")
            return DeclSyntax(node)
        }
        let previousBindings = bindings
        let previousView = insideView
        let previousCanvas = insideCanvas
        insideCanvas = inventory.canvases.contains(node.name.text)
        let previousProperties = viewProperties
        let previousState = stateProperties
        insideView = true
        bindings = [:]
        viewProperties = []
        stateProperties = []
        for member in node.memberBlock.members {
            guard let variable = member.decl.as(VariableDeclSyntax.self) else { continue }
            for binding in variable.bindings {
                if binding.typeAnnotation?.type.trimmedDescription == "some View",
                    let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                    name != "body"
                {
                    viewProperties.insert(name)
                }
                if let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                    let model = configuration.models.first(where: {
                        $0.authoredType
                            == (binding.typeAnnotation?.type.trimmedDescription
                                ?? binding.initializer?.value.as(FunctionCallExprSyntax.self)?
                                .calledExpression.trimmedDescription)
                    })
                {
                    bindings[name] = model
                    if variable.attributes.contains(where: {
                        $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "State"
                    }) {
                        stateProperties.insert(name)
                    }
                }
            }
        }
        if insideCanvas {
            let witnesses = node.memberBlock.members.compactMap {
                $0.decl.as(FunctionDeclSyntax.self)
            }
            .filter { $0.name.text == "draw" }
            if witnesses.count != 1 { reject(node, "Canvas requires exactly one draw witness") }
            if !stateProperties.isEmpty { reject(node, "Canvas cannot declare State") }
        }
        var result = super.visit(node).cast(StructDeclSyntax.self)
        result.genericParameterClause = GenericParameterClauseSyntax(
            parameters: GenericParameterListSyntax([
                GenericParameterSyntax(
                    name: .identifier("D"), colon: .colonToken(),
                    inheritedType: TypeSyntax(stringLiteral: configuration.domain))
            ])
        )
        result.memberBlock.members.insert(
            MemberBlockItemSyntax(
                decl: DeclSyntax(stringLiteral: "package typealias Domain = D\n")),
            at: result.memberBlock.members.startIndex
        )
        bindings = previousBindings
        insideView = previousView
        insideCanvas = previousCanvas
        viewProperties = previousProperties
        stateProperties = previousState
        return DeclSyntax(result)
    }

    override func visit(_ node: IdentifierTypeSyntax) -> TypeSyntax {
        if insideView,
            let model = configuration.models.first(where: { $0.authoredType == node.name.text })
        {
            return TypeSyntax(stringLiteral: "_GiftUIModelKey<\(model.schema)>")
                .with(\.leadingTrivia, node.leadingTrivia)
                .with(\.trailingTrivia, node.trailingTrivia)
        }
        return super.visit(node)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> ExprSyntax {
        if evaluating && stateProperties.contains(node.baseName.text) {
            return ExprSyntax(stringLiteral: "(try _\(node.baseName.text)._giftUIKey())")
                .with(\.leadingTrivia, node.leadingTrivia).with(
                    \.trailingTrivia, node.trailingTrivia)
        }
        if evaluating && viewProperties.contains(node.baseName.text) {
            return ExprSyntax(stringLiteral: "(try _giftUI_\(node.baseName.text)(read: read))")
                .with(\.leadingTrivia, node.leadingTrivia)
                .with(\.trailingTrivia, node.trailingTrivia)
        }
        return super.visit(node)
    }

    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        if insideCanvas && node.name.text == "draw" {
            let parameters = node.signature.parameterClause.parameters
            guard parameters.count == 2,
                parameters.first?.firstName.text == "in",
                parameters.first?.type.trimmedDescription == "Rect",
                parameters.last?.firstName.text == "context",
                parameters.last?.type.trimmedDescription == "inout GraphicsContext",
                node.signature.effectSpecifiers?.throwsClause?.type?.trimmedDescription
                    == "DrawingError",
                node.signature.effectSpecifiers?.asyncSpecifier == nil,
                node.signature.returnClause == nil,
                node.genericParameterClause == nil, let body = node.body,
                !node.modifiers.contains(where: { ["mutating", "static"].contains($0.name.text) })
            else {
                reject(
                    node,
                    "Canvas requires synchronous draw(in: Rect, context: inout GraphicsContext) throws(DrawingError)"
                )
                return DeclSyntax(node)
            }
            let oldEvaluating = evaluating
            let oldDrawing = drawing
            let oldContext = drawingContext
            evaluating = true
            drawing = true
            drawingContext = (parameters.last!.secondName ?? parameters.last!.firstName).text
            let lowered = rewrite(body).cast(CodeBlockSyntax.self)
            evaluating = oldEvaluating
            drawing = oldDrawing
            drawingContext = oldContext
            let bounds = (parameters.first!.secondName ?? parameters.first!.firstName).text
            return DeclSyntax(
                stringLiteral: """
                    \(node.modifiers.trimmedDescription) func _giftUIDraw(in \(bounds): Rect, context: inout GraphicsContext,
                        read: borrowing _GiftUIFrameRead<D>) throws(DrawingError) \(lowered)
                    """
            )
            .with(\.leadingTrivia, node.leadingTrivia).with(\.trailingTrivia, node.trailingTrivia)
        }
        guard node.signature.returnClause?.type.trimmedDescription == "some View" else {
            return super.visit(node)
        }
        guard node.genericParameterClause == nil else {
            reject(node, "generic view helpers are outside the finite inventory")
            return DeclSyntax(node)
        }
        let previous = evaluating
        evaluating = insideView
        var result = super.visit(node).cast(FunctionDeclSyntax.self)
        evaluating = previous
        result.signature.returnClause!.type = TypeSyntax(stringLiteral: "some View<D> ")
        result.signature.effectSpecifiers = FunctionEffectSpecifiersSyntax(
            throwsClause: ThrowsClauseSyntax(
                throwsSpecifier: .keyword(.throws),
                leftParen: .leftParenToken(),
                type: TypeSyntax(stringLiteral: "_GiftUIAccessFailure"),
                rightParen: .rightParenToken())
        )
        var parameters = result.signature.parameterClause.parameters
        if !parameters.isEmpty {
            parameters[parameters.index(before: parameters.endIndex)].trailingComma = .commaToken(
                trailingTrivia: .space)
        }
        parameters.append(
            FunctionParameterSyntax(
                firstName: .identifier(insideView ? "read" : "domain"),
                type: TypeSyntax(
                    stringLiteral: insideView ? "borrowing _GiftUIFrameRead<D>" : "D.Type")))
        result.signature.parameterClause.parameters = parameters
        if !insideView {
            result.genericParameterClause = GenericParameterClauseSyntax(
                parameters: GenericParameterListSyntax([
                    GenericParameterSyntax(
                        name: .identifier("D"), colon: .colonToken(),
                        inheritedType: TypeSyntax(stringLiteral: configuration.domain))
                ]))
        }
        if !node.attributes.contains(where: {
            $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "ViewBuilder"
        }) {
            result.attributes.append(
                .attribute(
                    AttributeSyntax(
                        attributeName: TypeSyntax(stringLiteral: "ViewBuilder"),
                        trailingTrivia: .newline)))
        }
        return DeclSyntax(result)
    }

    override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
        for binding in node.bindings {
            if evaluating,
                let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                stateProperties.contains(name)
            {
                reject(
                    binding,
                    "local declaration shadows a State declaration outside the finite source inventory"
                )
                return DeclSyntax(node)
            }
            if let type = binding.typeAnnotation?.type.trimmedDescription,
                type != "some View",
                !Self.ownedTypes.contains(type.replacingOccurrences(of: "?", with: "")),
                !inventory.valueTypes.contains(type),
                !configuration.models.contains(where: { $0.authoredType == type })
            {
                reject(
                    binding,
                    "value type '\(type)' has no inventoried owned-value or model-key representation"
                )
            }
        }
        guard insideView, node.bindings.count == 1, let binding = node.bindings.first,
            let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        else { return super.visit(node) }
        if let model = bindings[name], stateProperties.contains(name) {
            guard binding.accessorBlock == nil,
                node.bindingSpecifier.tokenKind == .keyword(.var),
                !node.modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) })
            else {
                reject(node, "State requires one direct stored instance variable")
                return DeclSyntax(node)
            }
            var seed = ""
            if let initial = binding.initializer {
                guard let call = initial.value.as(FunctionCallExprSyntax.self),
                    call.calledExpression.trimmedDescription == model.authoredType,
                    call.trailingClosure == nil,
                    call.arguments.map({ $0.label?.text ?? "" })
                        == (model.seedFields ?? []).map(\.name)
                else {
                    reject(initial, "State initializer must use the inventoried inert model seed")
                    return DeclSyntax(node)
                }
                let arguments = rewrite(call.arguments).cast(LabeledExprListSyntax.self)
                seed = "(seed: \(model.schema)Seed(\(arguments)))"
            }
            return DeclSyntax(
                stringLiteral:
                    "@State<\(model.schema)>\(seed) \(node.modifiers.trimmedDescription) var \(name): _GiftUIModelKey<\(model.schema)>?\n"
            )
            .with(\.leadingTrivia, node.leadingTrivia)
        }
        if let model = bindings[name] {
            var result = node
            var newBinding = binding
            newBinding.typeAnnotation = TypeAnnotationSyntax(
                type: TypeSyntax(stringLiteral: "_GiftUIModelKey<\(model.schema)>")
            )
            result.bindings = PatternBindingListSyntax([newBinding])
            return DeclSyntax(result)
        }
        guard name == "body" || viewProperties.contains(name) else { return super.visit(node) }
        guard binding.typeAnnotation?.type.trimmedDescription == "some View",
            let accessors = binding.accessorBlock,
            case .getter = accessors.accessors
        else {
            reject(node, "custom body requires an inferred some View getter")
            return DeclSyntax(node)
        }
        if insideCanvas { reject(node, "Canvas cannot declare a body or view property") }
        let previous = evaluating
        evaluating = true
        let lowered = super.visit(node).cast(VariableDeclSyntax.self)
        evaluating = previous
        guard case .getter(let statements) = lowered.bindings.first!.accessorBlock!.accessors else {
            preconditionFailure("getter changed during lowering")
        }
        let access = node.modifiers.trimmedDescription
        return DeclSyntax(
            stringLiteral: """

                @ViewBuilder
                \(access) func \(name == "body" ? "_giftUIEvaluate" : "_giftUI_" + name)(read: borrowing _GiftUIFrameRead<D>)
                    throws(_GiftUIAccessFailure) -> some View<D> {
                    \(statements.isEmpty ? "EmptyView<D>()" : statements.description)
                }
                """)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        let called = node.calledExpression.trimmedDescription
        let name = called.split(separator: ".").last.map(String.init) ?? called
        if called == "State", insideView, !evaluating,
            node.arguments.count == 1, node.arguments.first?.label?.text == "wrappedValue",
            let argument = node.arguments.first?.expression.as(DeclReferenceExprSyntax.self)?
                .baseName.text,
            stateProperties.contains(argument), let model = bindings[argument]
        {
            return ExprSyntax(stringLiteral: "State<\(model.schema)>(candidate: \(argument))")
                .with(\.leadingTrivia, node.leadingTrivia).with(
                    \.trailingTrivia, node.trailingTrivia)
        }
        let framework: Set<String> = [
            "Text", "Spacer", "EmptyView", "VStack", "HStack", "ZStack", "Button",
        ]
        let modifier: Bool
        if let member = node.calledExpression.as(MemberAccessExprSyntax.self),
            ["padding", "frame", "foregroundStyle", "background", "disabled"].contains(name),
            let receiver = member.base
        {
            modifier = isViewExpression(receiver)
        } else {
            modifier = false
        }
        let indexed = modelPath(node.calledExpression)?.fields.last?.indexed == true
        let scopedDrawingCall =
            drawing
            && (["Point", "Size", "Rect", "StrokeStyle", "Shading.color", ".color"].contains(called)
                || called == drawingContext + ".withPath" || called == drawingContext + ".stroke"
                || (!drawingPath.isEmpty
                    && [drawingPath + ".move", drawingPath + ".addLine"].contains(called)))
        if !scopedDrawingCall && !framework.contains(called) && !modifier
            && !inventory.views.contains(called) && !indexed
            && !inventory.viewFunctions.contains(name)
            && !configuration.calls.contains(called)
        {
            reject(node, "unsupported call/effect '\(called)'")
        }
        let oldContext = drawingContext
        let oldPath = drawingPath
        if drawing && called == drawingContext + ".withPath" {
            guard let closure = node.trailingClosure, let signature = closure.signature,
                signature.capture == nil, signature.effectSpecifiers?.asyncSpecifier == nil,
                signature.effectSpecifiers?.throwsClause?.type?.trimmedDescription
                    == "DrawingError", let clause = signature.parameterClause
            else {
                reject(node, "withPath requires a scoped two-inout typed DrawingError closure")
                return ExprSyntax(node)
            }
            let names: [String]
            switch clause {
            case .simpleInput(let parameters): names = parameters.map { $0.name.text }
            case .parameterClause(let parameters):
                names = parameters.parameters.map { ($0.secondName ?? $0.firstName).text }
            }
            guard names.count == 2 else {
                reject(node, "withPath requires exactly two scoped parameters")
                return ExprSyntax(node)
            }
            drawingContext = names[0]
            drawingPath = names[1]
        }
        var result = super.visit(node).cast(FunctionCallExprSyntax.self)
        drawingContext = oldContext
        drawingPath = oldPath
        if inventory.viewFunctions.contains(name) {
            if !result.arguments.isEmpty {
                result.arguments[result.arguments.index(before: result.arguments.endIndex)]
                    .trailingComma = .commaToken(trailingTrivia: .space)
            }
            let member = inventory.memberViewFunctions.contains(name)
            result.arguments.append(
                LabeledExprSyntax(
                    label: .identifier(member ? "read" : "domain"),
                    colon: .colonToken(trailingTrivia: .space),
                    expression: ExprSyntax(stringLiteral: member ? "read" : "D.self")))
        }
        if ["Text", "Spacer", "EmptyView"].contains(called) || inventory.views.contains(called) {
            result.calledExpression = ExprSyntax(stringLiteral: "\(called)<D>")
                .with(\.leadingTrivia, node.calledExpression.leadingTrivia)
                .with(\.trailingTrivia, node.calledExpression.trailingTrivia)
        }
        if ["VStack", "HStack", "ZStack", "Button"].contains(called) {
            if result.trailingClosure != nil {
                if result.trailingClosure!.statements.isEmpty {
                    result.trailingClosure!.statements = CodeBlockItemListSyntax([
                        CodeBlockItemSyntax(
                            item: .expr(ExprSyntax(stringLiteral: "EmptyView<D>()")))
                    ])
                }
                result.trailingClosure!.signature =
                    ExprSyntax(
                        stringLiteral: "{ () throws(_GiftUIAccessFailure) in }"
                    ).cast(ClosureExprSyntax.self).signature
            }
            return ExprSyntax(stringLiteral: "try \(result.trimmedDescription)")
                .with(\.leadingTrivia, node.leadingTrivia)
                .with(\.trailingTrivia, node.trailingTrivia)
        }
        if indexed || inventory.viewFunctions.contains(name) {
            return ExprSyntax(stringLiteral: "try \(result.trimmedDescription)")
                .with(\.leadingTrivia, node.leadingTrivia)
                .with(\.trailingTrivia, node.trailingTrivia)
        }
        return ExprSyntax(result)
    }

    private func isViewExpression(_ expression: ExprSyntax) -> Bool {
        if let name = expression.as(DeclReferenceExprSyntax.self)?.baseName.text {
            return viewProperties.contains(name)
        }
        guard let call = expression.as(FunctionCallExprSyntax.self) else { return false }
        let callee = call.calledExpression.trimmedDescription
        if ["Text", "Spacer", "EmptyView", "VStack", "HStack", "ZStack", "Button"].contains(callee)
            || inventory.views.contains(callee) || inventory.viewFunctions.contains(callee)
        {
            return true
        }
        if let member = call.calledExpression.as(MemberAccessExprSyntax.self),
            let base = member.base,
            ["padding", "frame", "foregroundStyle", "background", "disabled"].contains(
                member.declName.baseName.text)
        {
            return isViewExpression(base)
        }
        return false
    }

    private func modelPath(_ expression: ExprSyntax) -> (
        root: String, model: Model, fields: [Field]
    )? {
        if let reference = expression.as(DeclReferenceExprSyntax.self),
            let model = bindings[reference.baseName.text]
        {
            return (reference.baseName.text, model, [])
        }
        guard let member = expression.as(MemberAccessExprSyntax.self), let base = member.base else {
            return nil
        }
        if base.trimmedDescription == "self", let model = bindings[member.declName.baseName.text] {
            return ("self." + member.declName.baseName.text, model, [])
        }
        guard var path = modelPath(base) else { return nil }
        let fields = path.fields.last.map { $0.members ?? [] } ?? path.model.fields
        guard let field = fields.first(where: { $0.name == member.declName.baseName.text }) else {
            return nil
        }
        path.fields.append(field)
        return path
    }

    override func visit(_ node: MemberAccessExprSyntax) -> ExprSyntax {
        if let base = node.base?.as(DeclReferenceExprSyntax.self)?.baseName.text,
            !inventory.values.contains(base), !inventory.valueTypes.contains(base),
            !Self.ownedTypes.contains(base), !["self", "Self"].contains(base),
            !(drawing && [drawingContext, drawingPath].contains(base))
        {
            reject(node, "member access through unknown value '\(base)'")
        }
        guard evaluating else { return super.visit(node) }
        if node.base?.trimmedDescription == "self",
            stateProperties.contains(node.declName.baseName.text)
        {
            return ExprSyntax(stringLiteral: "(try _\(node.declName.baseName.text)._giftUIKey())")
                .with(\.leadingTrivia, node.leadingTrivia).with(
                    \.trailingTrivia, node.trailingTrivia)
        }
        if node.base?.trimmedDescription == "self",
            viewProperties.contains(node.declName.baseName.text)
        {
            return ExprSyntax(
                stringLiteral: "(try _giftUI_\(node.declName.baseName.text)(read: read))"
            )
            .with(\.leadingTrivia, node.leadingTrivia).with(\.trailingTrivia, node.trailingTrivia)
        }
        if let path = modelPath(ExprSyntax(node)), !path.fields.isEmpty {
            let rootName = path.root.hasPrefix("self.") ? String(path.root.dropFirst(5)) : path.root
            let root =
                stateProperties.contains(rootName) ? "try _\(rootName)._giftUIKey()" : path.root
            let fields = path.fields.map {
                "." + (drawing && $0.indexed ? "_giftUIDrawing_" : "") + $0.name
                    + ($0.members == nil ? "" : "()")
            }
            .joined()
            return ExprSyntax(
                stringLiteral:
                    "(try \(path.model.facade)<D>(\(root), \(drawing ? "drawingRead" : "read"): read))\(fields)"
            )
            .with(\.leadingTrivia, node.leadingTrivia)
            .with(\.trailingTrivia, node.trailingTrivia)
        }
        if let base = node.base, modelPath(base) != nil {
            reject(
                node,
                "model member '\(node.declName.baseName.text)' has no checked schema operation")
            return ExprSyntax(node)
        }
        return super.visit(node)
    }

    override func visit(_ node: InfixOperatorExprSyntax) -> ExprSyntax {
        let result = super.visit(node).cast(InfixOperatorExprSyntax.self)
        guard let operation = node.operator.as(BinaryOperatorExprSyntax.self),
            ["&&", "||", "??"].contains(operation.operator.text)
        else { return ExprSyntax(result) }
        let scan = ThrowingExpressionScan(viewMode: .sourceAccurate)
        scan.walk(result)
        guard scan.containsTry else { return ExprSyntax(result) }
        let lhs = result.leftOperand.trimmedDescription
        let rhs = result.rightOperand.trimmedDescription
        let lowered: String
        switch operation.operator.text {
        case "&&": lowered = "((\(lhs)) ? (\(rhs)) : false)"
        case "||": lowered = "((\(lhs)) ? true : (\(rhs)))"
        default:
            lowered =
                "try { () throws(\(drawing ? "DrawingError" : "_GiftUIAccessFailure")) in if let value = \(lhs) { return value }; return \(rhs) }()"
        }
        return ExprSyntax(stringLiteral: lowered)
            .with(\.leadingTrivia, node.leadingTrivia)
            .with(\.trailingTrivia, node.trailingTrivia)
    }

}

func schema(_ configuration: Configuration) throws -> String {
    let ownedTypes: Set<String> = [
        "Bool", "UInt8", "UInt16", "UInt32", "Int", "Int64", "Duration", "BoundedText",
        "UInt8?", "BoundedText?", "AcquisitionState", "DigitalLevel", "SignalChannelID",
        "SignalTransition", "Range<Duration>",
    ]
    func identifier(_ name: String) -> Bool {
        name.range(of: "^[A-Za-z_][A-Za-z_0-9]*$", options: .regularExpression) != nil
    }
    func valid(_ fields: [Field]) -> Bool {
        Set(fields.map(\.name)).count == fields.count
            && fields.allSatisfy { field in
                identifier(field.name)
                    && (field.members.map {
                        field.type == "aggregate" && !field.indexed && valid($0)
                    }
                        ?? ownedTypes.contains(field.type))
            }
    }
    let names =
        [configuration.module, configuration.domain] + configuration.imports
        + configuration.models.flatMap { [$0.authoredType, $0.schema, $0.facade] }
    guard names.allSatisfy(identifier),
        configuration.models.allSatisfy({ model in
            valid(model.fields)
                && Set((model.seedFields ?? []).map(\.name)).count == (model.seedFields ?? []).count
                && (model.seedFields ?? []).allSatisfy {
                    identifier($0.name) && ownedTypes.contains($0.type)
                }
        })
    else {
        throw LoweringFailure(
            description: "schema requires unique identifiers and inventoried owned getters")
    }
    func requirements(_ fields: [Field], prefix: String) -> String {
        fields.map { field in
            let name = prefix + "_" + field.name
            if let nested = field.members { return requirements(nested, prefix: name) }
            let position = field.indexed ? "_ position: Int, " : ""
            let failure = field.indexed ? " throws(_GiftUIAccessFailure)" : ""
            return
                "static func \(name)(\(position)at index: Int, slots: Span<Slot>)\(failure) -> \(field.type)\n"
        }.joined()
    }
    func facade(_ fields: [Field], name: String, schema: String?) -> String {
        var result = """
            package struct \(name)<D: \(configuration.domain)>: ~Escapable {
                private let slots: Span<D.Slot>
                private let index: Int

            """
        if let schema {
            result += """
                @_lifetime(copy read)
                package init(_ key: _GiftUIModelKey<\(schema)>, read: borrowing _GiftUIFrameRead<D>)
                    throws(_GiftUIAccessFailure) {
                    index = try D.bind(key, slots: read.slots)
                    slots = read.slots
                }

                @_lifetime(copy drawingRead)
                package init(_ key: _GiftUIModelKey<\(schema)>, drawingRead: borrowing _GiftUIFrameRead<D>)
                    throws(DrawingError) {
                    do throws(_GiftUIAccessFailure) {
                        index = try D.bind(key, slots: drawingRead.slots)
                    } catch { throw DrawingError(accessFailure: error) }
                    slots = drawingRead.slots
                }

                """
        } else {
            result += """
                @_lifetime(copy slots)
                fileprivate init(slots: Span<D.Slot>, index: Int) {
                    self.slots = slots
                    self.index = index
                }

                """
        }
        var nestedFacades = ""
        for field in fields {
            let member = name + "_" + field.name
            if let nested = field.members {
                result += """
                    @_lifetime(copy self)
                    package func \(field.name)() -> \(member)<D> {
                        \(member)<D>(slots: slots, index: index)
                    }

                    """
                nestedFacades += facade(nested, name: member, schema: nil)
            } else if field.indexed {
                result += """
                    package func \(field.name)(_ position: Int) throws(_GiftUIAccessFailure) -> \(field.type) {
                        try D.\(member)(position, at: index, slots: slots)
                    }
                    package func _giftUIDrawing_\(field.name)(_ position: Int) throws(DrawingError) -> \(field.type) {
                        do throws(_GiftUIAccessFailure) {
                            return try D.\(member)(position, at: index, slots: slots)
                        } catch { throw DrawingError(accessFailure: error) }
                    }

                    """
            } else {
                result +=
                    "package var \(field.name): \(field.type) { D.\(member)(at: index, slots: slots) }\n"
            }
        }
        return result + "}\n" + nestedFacades
    }
    var result = "import GiftUI\n" + configuration.imports.map { "import \($0)\n" }.joined()
    result += "package protocol \(configuration.domain): _GiftUIReadDomain {\n"
    for model in configuration.models {
        result +=
            "static func bind(_ key: _GiftUIModelKey<\(model.schema)>, slots: Span<Slot>) throws(_GiftUIAccessFailure) -> Int\n"
        result += requirements(model.fields, prefix: model.facade)
    }
    result += "}\n"
    for model in configuration.models {
        let seedFields = model.seedFields ?? []
        result += "package struct \(model.schema)Seed {\n"
        for field in seedFields {
            result += "package let \(field.name): \(field.type)\n"
        }
        result +=
            "package init(" + seedFields.map { "\($0.name): \($0.type)" }.joined(separator: ", ")
            + ") {\n"
        for field in seedFields {
            result += "self.\(field.name) = \(field.name)\n"
        }
        result += "}\n}\n"
        result +=
            "package enum \(model.schema): _GiftUIModelSchema { package typealias Seed = \(model.schema)Seed }\n"
            + facade(model.fields, name: model.facade, schema: model.schema)
    }
    return result
}

func lowerGiftUISource(arguments: [String]) throws {
    guard arguments.count == 5 || arguments.count == 7 else {
        throw LoweringFailure(
            description:
                "usage: GiftUIMacros-tool --lower-source <schema.json> <authored.swift> <schema-output.swift> <presentation-output.swift> [<canvas-table-output.swift> <presentation-module>]"
        )
    }
    let configuration = try JSONDecoder().decode(
        Configuration.self, from: Data(contentsOf: URL(fileURLWithPath: arguments[1])))
    let parsed = Parser.parse(source: try String(contentsOfFile: arguments[2], encoding: .utf8))
    let source = try OperatorTable.standardOperators.foldAll(parsed).cast(SourceFileSyntax.self)
    guard !source.hasError else {
        throw LoweringFailure(
            description: "\(arguments[2]):1:1: error: RFC014: malformed Swift source")
    }
    let inventory = Inventory(viewMode: .sourceAccurate)
    inventory.walk(source)
    let pureCalls = Lowerer.ownedTypes.union(inventory.functions).union(["min", "max"])
    guard configuration.imports.allSatisfy({ $0 == "SignalAnalyzerDomain" }),
        configuration.calls.allSatisfy({ pureCalls.contains($0) })
    else {
        throw LoweringFailure(
            description: "schema imports/calls exceed the finite owned-value inventory")
    }
    let lowerer = Lowerer(
        configuration: configuration, inventory: inventory, source: source, file: arguments[2])
    let lowered = lowerer.rewrite(source)
    guard lowerer.errors.isEmpty else {
        throw LoweringFailure(description: lowerer.errors.joined(separator: "\n"))
    }
    let schemaText = try schema(configuration)
    let tableText =
        arguments.count == 7
        ? try canvasWitnessTable(
            configuration: configuration, inventory: inventory, presentationModule: arguments[6])
        : nil
    // Emit neither output on any diagnostic. The build consumes only a complete pair.
    try schemaText.write(toFile: arguments[3], atomically: true, encoding: .utf8)
    let presentation = "import \(configuration.module)\n" + lowered.description
    try presentation.write(toFile: arguments[4], atomically: true, encoding: .utf8)
    if let tableText {
        try tableText.write(toFile: arguments[5], atomically: true, encoding: .utf8)
    }
}
