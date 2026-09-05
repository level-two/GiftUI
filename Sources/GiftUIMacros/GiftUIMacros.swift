import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct GiftUIMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObservableStateHostMacro.self
    ]
}
