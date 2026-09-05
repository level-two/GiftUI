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

        let access = witnessAccessPrefix(for: declaration)
        let mutation = declaration.is(ClassDeclSyntax.self) ? "" : "mutating "
        let visits = declarations.enumerated().map { offset, name in
            "visitor.visit(&_\(name), declarationOrdinal: \(offset))"
        }.joined(separator: "\n")

        let declarationVisitor: DeclSyntax = """
            \(raw: access)\(raw: mutation)func _giftUIVisitObservableStateDeclarations<
                Visitor: _GiftUIObservableStateDeclarationVisitor
            >(_ visitor: inout Visitor) {
                \(raw: visits)
            }
            """
        let traversal: DeclSyntax = """
            \(raw: access)func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
                _ visitor: inout Visitor
            ) {
                visitor.visitStatefulCustomView(self) { declaration in
                    declaration.body
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

    private static func isObservableStateAttribute(_ element: AttributeListSyntax.Element) -> Bool {
        guard let attribute = element.as(AttributeSyntax.self) else {
            return false
        }

        let name = attribute.attributeName.trimmedDescription
        return name == "State" || name.hasSuffix(".State")
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
    case requiresNominalView
    case tooManyDeclarations

    var message: String {
        switch self {
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
