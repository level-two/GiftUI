import Foundation
import SwiftParser
import SwiftSyntax
import SwiftSyntaxMacroExpansion

@main struct MacroChecks {
    static func main() throws {
        let root = URL(fileURLWithPath: CommandLine.arguments[1])
        for name in ["zero", "several", "portable-profile", "private", "inherited", "malformed"] {
            let path = root.appendingPathComponent("Sources/\(name).swift")
            let source = Parser.parse(source: try String(contentsOf: path, encoding: .utf8))
            let context = BasicMacroExpansionContext(sourceFiles: [source: .init(moduleName: "GiftUI", fullFilePath: path.path)])
            let expanded = source.expand(
                macroSpecs: ["ObservableStateHost": MacroSpec(type: ObservableStateHostMacro.self, conformances: ["_GiftUIObservableStateHost"])],
                contextGenerator: { BasicMacroExpansionContext(sharingWith: context, lexicalContext: $0.allMacroLexicalContexts()) },
                indentationWidth: .spaces(4)
            )
            let expected = try String(contentsOf: root.appendingPathComponent("Expected/\(name).swift"), encoding: .utf8)
            guard expanded.description.trimmingCharacters(in: .newlines) == expected.trimmingCharacters(in: .newlines) else {
                print("Macro mismatch: \(name)\nActual:\n\(expanded)")
                exit(1)
            }
            let messages = context.diagnostics.map { $0.message }
            precondition(messages == (name == "malformed" ? ["@State must decorate one direct stored property"] : []))
        }
        precondition(!ObservableStateHostMacro.exceedsDeclarationLimit(Int(UInt16.max)))
        precondition(ObservableStateHostMacro.exceedsDeclarationLimit(Int(UInt16.max) + 1))
        print("macro-fixtures=6 declaration-limit-controls=2 failures=0")
    }
}
