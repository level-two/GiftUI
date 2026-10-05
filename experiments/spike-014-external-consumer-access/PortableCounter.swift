import GiftUI

enum CounterAction: UInt16, GiftUIAction {
    case increment = 1
    case reset = 2
}

struct CounterScreen: View {
    let value: BoundedText
    let resetDisabled: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text("Counter")
            Text(value)
            Button("Increment", action: CounterAction.increment)
            Button("Reset", action: CounterAction.reset).disabled(resetDisabled)
        }
    }
}

@_cdecl("spike014_declaration_probe")
public func declarationProbe() {
    let screen = CounterScreen(value: BoundedText("0")!, resetDisabled: true)
    _ = screen.body
}
