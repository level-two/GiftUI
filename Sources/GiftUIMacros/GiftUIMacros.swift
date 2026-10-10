import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

struct GiftUIMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObservableStateHostMacro.self
    ]
}

@main
struct GiftUIMacroEntryPoint {
    static func main() throws {
        if CommandLine.arguments.dropFirst().first == "--lower-source" {
            do {
                try lowerGiftUISource(arguments: Array(CommandLine.arguments.dropFirst()))
            } catch {
                FileHandle.standardError.write(Data("\(error)\n".utf8))
                exit(1)
            }
        } else {
            try GiftUIMacroPlugin.main()
        }
    }
}
