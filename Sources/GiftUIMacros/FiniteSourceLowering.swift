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
}

struct Model: Decodable {
    let authoredType: String
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
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.inheritanceClause?.inheritedTypes.contains(where: {
            $0.type.trimmedDescription == "View"
        }) == true {
            views.insert(node.name.text)
        }
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
    let configuration: Configuration
    let inventory: Inventory
    let location: SourceLocationConverter
    var errors: [String] = []
    var bindings: [String: Model] = [:]
    var evaluating = false
    var insideView = false

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

    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        reject(node, "mutable reference declarations belong in the checked model owner")
        return DeclSyntax(node)
    }

    override func visit(_ node: InOutExprSyntax) -> ExprSyntax {
        reject(node, "unchecked inout is outside the finite source inventory")
        return ExprSyntax(node)
    }

    override func visit(_ node: StructDeclSyntax) -> DeclSyntax {
        guard inventory.views.contains(node.name.text) else { return super.visit(node) }
        guard node.genericParameterClause == nil else {
            reject(node, "authored generic custom views are outside the finite source inventory")
            return DeclSyntax(node)
        }
        let previousBindings = bindings
        let previousView = insideView
        insideView = true
        bindings = [:]
        for member in node.memberBlock.members {
            guard let variable = member.decl.as(VariableDeclSyntax.self) else { continue }
            for binding in variable.bindings {
                if let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                    let model = configuration.models.first(where: {
                        $0.authoredType == binding.typeAnnotation?.type.trimmedDescription
                    })
                {
                    bindings[name] = model
                }
            }
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
        return DeclSyntax(result)
    }

    override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
        guard insideView, node.bindings.count == 1, let binding = node.bindings.first,
            let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        else { return super.visit(node) }
        if let model = bindings[name] {
            var result = node
            var newBinding = binding
            newBinding.typeAnnotation = TypeAnnotationSyntax(
                type: TypeSyntax(stringLiteral: "_GiftUIModelKey<\(model.schema)>")
            )
            result.bindings = PatternBindingListSyntax([newBinding])
            return DeclSyntax(result)
        }
        guard name == "body" else { return super.visit(node) }
        guard binding.typeAnnotation?.type.trimmedDescription == "some View",
            let accessors = binding.accessorBlock,
            case .getter = accessors.accessors
        else {
            reject(node, "custom body requires an inferred some View getter")
            return DeclSyntax(node)
        }
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
                \(access) func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
                    throws(_GiftUIAccessFailure) -> some View<D> {
                    \(statements.isEmpty ? "EmptyView<D>()" : statements.description)
                }
                """)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        let called = node.calledExpression.trimmedDescription
        let name = called.split(separator: ".").last.map(String.init) ?? called
        let framework: Set<String> = [
            "Text", "Spacer", "EmptyView", "VStack", "HStack", "ZStack", "Button",
            "padding", "frame", "foregroundStyle", "background", "disabled",
        ]
        if !framework.contains(name) && !inventory.views.contains(name)
            && !configuration.calls.contains(called)
        {
            reject(node, "unsupported call/effect '\(called)'")
        }
        var result = super.visit(node).cast(FunctionCallExprSyntax.self)
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
        return ExprSyntax(result)
    }

    override func visit(_ node: MemberAccessExprSyntax) -> ExprSyntax {
        guard evaluating, let base = node.base?.as(DeclReferenceExprSyntax.self),
            let model = bindings[base.baseName.text]
        else { return super.visit(node) }
        guard let field = model.fields.first(where: { $0.name == node.declName.baseName.text })
        else {
            reject(
                node,
                "model member '\(node.declName.baseName.text)' has no checked schema operation")
            return ExprSyntax(node)
        }
        let expression = "(try \(model.facade)<D>(\(base), read: read)).\(field.name)"
        return ExprSyntax(stringLiteral: expression)
            .with(\.leadingTrivia, node.leadingTrivia)
            .with(\.trailingTrivia, node.trailingTrivia)
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
                "try { () throws(_GiftUIAccessFailure) in if let value = \(lhs) { return value }; return \(rhs) }()"
        }
        return ExprSyntax(stringLiteral: lowered)
            .with(\.leadingTrivia, node.leadingTrivia)
            .with(\.trailingTrivia, node.trailingTrivia)
    }

}

func schema(_ configuration: Configuration) throws -> String {
    let ownedTypes: Set<String> = [
        "Bool", "UInt8", "UInt16", "UInt32", "Int", "Int64", "Duration", "BoundedText",
        "AcquisitionState", "DigitalLevel", "SignalChannelID", "SignalTransition",
        "Range<Duration>",
    ]
    let names =
        [configuration.module, configuration.domain] + configuration.imports
        + configuration.models.flatMap {
            [$0.authoredType, $0.schema, $0.facade] + $0.fields.map(\.name)
        }
    guard
        names.allSatisfy({
            $0.range(of: "^[A-Za-z_][A-Za-z_0-9]*$", options: .regularExpression) != nil
        })
    else {
        throw LoweringFailure(description: "invalid finite schema identifier")
    }
    guard configuration.models.allSatisfy({ $0.fields.allSatisfy { ownedTypes.contains($0.type) } })
    else {
        throw LoweringFailure(description: "schema getter must return an inventoried owned value")
    }
    var result = "import GiftUI\n" + configuration.imports.map { "import \($0)\n" }.joined()
    result += "package protocol \(configuration.domain): _GiftUIReadDomain {\n"
    for model in configuration.models {
        result += """
            static func bind(_ key: _GiftUIModelKey<\(model.schema)>, slots: Span<Slot>)
                throws(_GiftUIAccessFailure) -> Int

            """
        for field in model.fields {
            let position = field.indexed ? "_ position: Int, " : ""
            let failure = field.indexed ? " throws(_GiftUIAccessFailure)" : ""
            result +=
                "static func \(model.facade)_\(field.name)(\(position)at index: Int, slots: Span<Slot>)\(failure) -> \(field.type)\n"
        }
    }
    result += "}\n"
    for model in configuration.models {
        result += """
            package enum \(model.schema) {}
            package struct \(model.facade)<D: \(configuration.domain)>: ~Escapable {
                private let slots: Span<D.Slot>
                private let index: Int
                @_lifetime(copy read)
                package init(_ key: _GiftUIModelKey<\(model.schema)>, read: borrowing _GiftUIFrameRead<D>)
                    throws(_GiftUIAccessFailure) {
                    index = try D.bind(key, slots: read.slots)
                    slots = read.slots
                }

            """
        for field in model.fields {
            if field.indexed {
                result += """
                    package func \(field.name)(_ position: Int) throws(_GiftUIAccessFailure) -> \(field.type) {
                        try D.\(model.facade)_\(field.name)(position, at: index, slots: slots)
                    }

                    """
            } else {
                result +=
                    "package var \(field.name): \(field.type) { D.\(model.facade)_\(field.name)(at: index, slots: slots) }\n"
            }
        }
        result += "}\n"
    }
    return result
}

func lowerGiftUISource(arguments: [String]) throws {
    guard arguments.count == 5 else {
        throw LoweringFailure(
            description:
                "usage: GiftUIMacros-tool --lower-source <schema.json> <authored.swift> <schema-output.swift> <presentation-output.swift>"
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
    let lowerer = Lowerer(
        configuration: configuration, inventory: inventory, source: source, file: arguments[2])
    let lowered = lowerer.rewrite(source)
    guard lowerer.errors.isEmpty else {
        throw LoweringFailure(description: lowerer.errors.joined(separator: "\n"))
    }
    let schemaText = try schema(configuration)
    // Emit neither output on any diagnostic. The build consumes only a complete pair.
    try schemaText.write(toFile: arguments[3], atomically: true, encoding: .utf8)
    let presentation = "import \(configuration.module)\n" + lowered.description
    try presentation.write(toFile: arguments[4], atomically: true, encoding: .utf8)
}
