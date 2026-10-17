import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ObservableStateHostMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(StructDeclSyntax.self) || declaration.is(ClassDeclSyntax.self) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: ObservableStateHostDiagnostic.requiresNominalView
                )
            )
            return []
        }

        let declarations = observableStateDeclarations(in: declaration, context: context)
        guard !exceedsDeclarationLimit(declarations.count) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: ObservableStateHostDiagnostic.tooManyDeclarations
                )
            )
            return []
        }

        guard
            let projectionNames = checkedStateProjectionNames(
                declarations: declarations, in: declaration, context: context)
        else { return [] }
        let access = witnessAccessPrefix(for: declaration)
        let mutation = declaration.is(ClassDeclSyntax.self) ? "" : "mutating "
        let visits = declarations.enumerated().map { offset, name in
            if projectionNames.contains(name) {
                return
                    "visitor.visit(&self._giftUIStateStorage_\(canonicalName(name)), declarationOrdinal: \(offset))"
            }
            return "visitor.visit(&_\(name), declarationOrdinal: \(offset))"
        }.joined(separator: "\n")

        let declarationVisitor: DeclSyntax = """
            @inlinable
            @inline(__always)
            \(raw: access)\(raw: mutation)func _giftUIVisitObservableStateDeclarations<
                Visitor: _GiftUIObservableStateDeclarationVisitor & ~Copyable & ~Escapable
            >(_ visitor: inout Visitor) {
                \(raw: visits)
            }
            """
        let traversal: DeclSyntax = """
            @inlinable
            @inline(__always)
            \(raw: access)func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
                _ visitor: inout Visitor
            ) where Visitor.Domain == Domain {
                visitor.visitStatefulCustomView(self) {
                    (declaration: borrowing Self, read: borrowing _GiftUIFrameRead<Domain>)
                        throws(_GiftUIAccessFailure) in
                    try declaration._giftUIEvaluate(read: read)
                }
            }
            """

        return [declarationVisitor, traversal]
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        [
            try ExtensionDeclSyntax("extension \(type): _GiftUIObservableStateHost {}")
        ]
    }

    private static func observableStateDeclarations(
        in declaration: some DeclGroupSyntax,
        context: some MacroExpansionContext
    ) -> [String] {
        var names: [String] = []

        for member in declaration.memberBlock.members {
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                variable.modifiers.allSatisfy({ modifier in
                    modifier.name.tokenKind != .keyword(.static)
                        && modifier.name.tokenKind != .keyword(.class)
                }),
                variable.attributes.contains(where: isObservableStateAttribute)
            else {
                continue
            }

            guard variable.bindings.count == 1,
                let binding = variable.bindings.first,
                binding.accessorBlock == nil,
                let identifier = binding.pattern.as(IdentifierPatternSyntax.self)
            else {
                context.diagnose(
                    Diagnostic(
                        node: Syntax(variable),
                        message: ObservableStateHostDiagnostic.malformedStateDeclaration
                    )
                )
                continue
            }

            names.append(identifier.identifier.text)
        }

        return names
    }

    // Only the finite lowerer emits these helpers. Structural validation keeps
    // arbitrary macro input from selecting a different State field or operation.
    static func canonicalName(_ spelling: String) -> String {
        spelling.hasPrefix("`") && spelling.hasSuffix("`")
            ? String(spelling.dropFirst().dropLast()) : spelling
    }

    private static func memberNames(_ declaration: DeclSyntax) -> [String] {
        if let variable = declaration.as(VariableDeclSyntax.self) {
            return variable.bindings.compactMap {
                $0.pattern.as(IdentifierPatternSyntax.self).map {
                    canonicalName($0.identifier.text)
                }
            }
        }
        let name: TokenSyntax?
        if let function = declaration.as(FunctionDeclSyntax.self) {
            name = function.name
        } else if let type = declaration.as(StructDeclSyntax.self) {
            name = type.name
        } else if let type = declaration.as(ClassDeclSyntax.self) {
            name = type.name
        } else if let type = declaration.as(EnumDeclSyntax.self) {
            name = type.name
        } else if let type = declaration.as(ActorDeclSyntax.self) {
            name = type.name
        } else if let type = declaration.as(ProtocolDeclSyntax.self) {
            name = type.name
        } else if let type = declaration.as(TypeAliasDeclSyntax.self) {
            name = type.name
        } else {
            name = nil
        }
        return name.map { [canonicalName($0.text)] } ?? []
    }

    static func hasReservedStateName(_ declaration: DeclSyntax) -> Bool {
        memberNames(declaration).contains {
            $0.hasPrefix("_giftUIStateStorage_") || $0.hasPrefix("_giftUIStateKey_")
        }
    }

    static func checkedStateHelpers(name: String, schema: String) -> [DeclSyntax] {
        let name = canonicalName(name)
        return [
            """
            @usableFromInline
            internal var _giftUIStateStorage_\(raw: name): State<\(raw: schema)> {
                _read { yield _\(raw: name) }
                _modify { yield &_\(raw: name) }
            }
            """,
            """
            @usableFromInline
            internal borrowing func _giftUIStateKey_\(raw: name)()
                throws(_GiftUIAccessFailure) -> _GiftUIModelKey<\(raw: schema)> {
                try _\(raw: name)._giftUIKey()
            }
            """,
        ]
    }

    private static func sameStructure(_ lhs: Syntax, _ rhs: Syntax) -> Bool {
        guard lhs.kind == rhs.kind else { return false }
        if let left = lhs.as(TokenSyntax.self), let right = rhs.as(TokenSyntax.self) {
            return left.presence == right.presence
                && canonicalName(left.text) == canonicalName(right.text)
        }
        let left = Array(lhs.children(viewMode: .sourceAccurate))
        let right = Array(rhs.children(viewMode: .sourceAccurate))
        return left.count == right.count
            && zip(left, right).allSatisfy { sameStructure($0, $1) }
    }

    private static func checkedStateProjectionNames(
        declarations: [String], in declaration: some DeclGroupSyntax,
        context: some MacroExpansionContext
    ) -> Set<String>? {
        let reserved = declaration.memberBlock.members.map(\.decl).filter(hasReservedStateName)
        guard !reserved.isEmpty else { return [] }
        var remaining = reserved
        var names: Set<String> = []
        for name in declarations {
            let canonical = canonicalName(name)
            let variables = declaration.memberBlock.members.compactMap {
                $0.decl.as(VariableDeclSyntax.self)
            }.filter {
                $0.bindings.count == 1
                    && $0.bindings.first?.pattern.as(IdentifierPatternSyntax.self).map {
                        canonicalName($0.identifier.text) == canonical
                    } == true
            }
            guard variables.count == 1, let variable = variables.first,
                let attribute = variable.attributes.compactMap({ $0.as(AttributeSyntax.self) })
                    .first(where: { isObservableStateAttribute(.attribute($0)) }),
                let stateType = attribute.attributeName.as(IdentifierTypeSyntax.self),
                let arguments = stateType.genericArgumentClause?.arguments,
                arguments.count == 1,
                let schema = arguments.first?.argument
                    .as(IdentifierTypeSyntax.self), schema.genericArgumentClause == nil,
                let actualType = variable.bindings.first?.typeAnnotation?.type,
                sameStructure(
                    Syntax(actualType),
                    Syntax(
                        TypeSyntax(
                            stringLiteral:
                                "_GiftUIModelKey<\(schema.name.text)>?")))
            else {
                context.diagnose(
                    Diagnostic(
                        node: Syntax(declaration),
                        message: ObservableStateHostDiagnostic.malformedStateHelper))
                return nil
            }
            for expected in checkedStateHelpers(name: canonical, schema: schema.name.text) {
                let expectedNames = memberNames(expected)
                let matches = remaining.indices.filter {
                    memberNames(remaining[$0]) == expectedNames
                }
                guard matches.count == 1, let index = matches.first,
                    sameStructure(Syntax(remaining[index]), Syntax(expected))
                else {
                    context.diagnose(
                        Diagnostic(
                            node: Syntax(declaration),
                            message: ObservableStateHostDiagnostic.malformedStateHelper))
                    return nil
                }
                remaining.remove(at: index)
            }
            names.insert(name)
        }
        guard remaining.isEmpty else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(declaration),
                    message: ObservableStateHostDiagnostic.malformedStateHelper))
            return nil
        }
        return names
    }

    private static func isObservableStateAttribute(_ element: AttributeListSyntax.Element) -> Bool {
        guard let attribute = element.as(AttributeSyntax.self) else {
            return false
        }

        if let name = attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.text {
            return name == "State"
        }
        return attribute.attributeName.as(MemberTypeSyntax.self)?.name.text == "State"
    }

    static func exceedsDeclarationLimit(_ count: Int) -> Bool {
        count > Int(UInt16.max)
    }

    private static func witnessAccessPrefix(for declaration: some DeclGroupSyntax) -> String {
        for modifier in declaration.modifiers {
            switch modifier.name.tokenKind {
            case .keyword(.open), .keyword(.public):
                return "public "
            case .keyword(.package):
                return "package "
            case .keyword(.fileprivate):
                return "fileprivate "
            case .keyword(.private):
                return "fileprivate "
            default:
                continue
            }
        }
        return ""
    }
}

private enum ObservableStateHostDiagnostic: String, DiagnosticMessage {
    case malformedStateDeclaration
    case malformedStateHelper
    case requiresNominalView
    case tooManyDeclarations

    var message: String {
        switch self {
        case .malformedStateHelper:
            return
                "reserved State helpers must exactly yield and check their original concrete-schema wrapper"
        case .malformedStateDeclaration:
            return "@State must decorate one direct stored property"
        case .requiresNominalView:
            return "@ObservableStateHost requires a struct or class declaration"
        case .tooManyDeclarations:
            return "@ObservableStateHost supports at most 65,535 direct @State declarations"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "GiftUIMacros.ObservableStateHost", id: rawValue)
    }

    var severity: DiagnosticSeverity { .error }
}
