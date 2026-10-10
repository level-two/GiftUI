import GiftUI

package enum CounterAction: UInt16, GiftUIAction {
    case increment, reset
}

package func counterText(_ value: UInt8) -> BoundedText {
    switch value {
    case 0: BoundedText("0")!
    case 1: BoundedText("1")!
    case 2: BoundedText("2")!
    case 3: BoundedText("3")!
    case 4: BoundedText("4")!
    case 5: BoundedText("5")!
    case 6: BoundedText("6")!
    case 7: BoundedText("7")!
    case 8: BoundedText("8")!
    default: BoundedText("9")!
    }
}

package struct CounterRoot: View {
    package let model: CounterModel

    package var body: some View {
        VStack {
            Text(counterText(model.value))
            Button(action: CounterAction.increment) { Text("Increment") }
                .disabled(model.value == 9)
            Button(action: CounterAction.reset) { Text("Reset") }
                .disabled(model.value == 0)
            if model.value > 0 && model.value < 9 {
                CounterBadge(value: model.value)
            }
        }
    }
}

package struct CounterBadge: View {
    package let value: UInt8
    package var body: some View {
        Text(counterText(value)).padding(1).foregroundStyle(.white)
    }
}
