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

    package init(model: CounterModel) { self.model = model }

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

package struct ArityZero: View { package var body: some View {} }
package struct ArityOne: View { package var body: some View { Text("1") } }
package struct ArityTwo: View { package var body: some View { Text("1"); Text("2") } }
package struct ArityThree: View { package var body: some View { Text("1"); Text("2"); Text("3") } }
package struct ArityFour: View { package var body: some View { Text("1"); Text("2"); Text("3"); Text("4") } }
package struct ArityFive: View { package var body: some View { Text("1"); Text("2"); Text("3"); Text("4"); Text("5") } }
package struct ArityProbe: View {
    package init() {}
    package var body: some View {
        VStack {
            ArityZero(); ArityOne(); ArityTwo(); ArityThree()
            VStack { ArityFour(); ArityFive() }
        }
    }
}

@ViewBuilder
package func freeLabels() -> some View { Text("a"); Text("b") }
package struct HelperProbe: View {
    package init() {}
    package var caption: some View { Text("caption") }
    @ViewBuilder package func makeLabel() -> some View { Text("method") }
    package var body: some View { caption; makeLabel(); freeLabels() }
}

@ObservableStateHost
package struct StateHostWitnessProbe: View {
    package init() {}
    package var body: some View { Text("state host witness") }
}

package struct LazyProbe: View {
    package let model: CounterModel
    package init(model: CounterModel) { self.model = model }
    package var body: some View {
        let absent: UInt8? = nil
        let present: UInt8? = 7
        Text(counterText(absent ?? model.value))
        Text(counterText(present ?? model.value))
        if model.value == 9 || model.value > 0 { Text("or") }
        if !(model.value == 0 && model.value > 0) { Text("and") }
    }
}
package struct SwitchProbe: View {
    package let model: CounterModel
    package init(model: CounterModel) { self.model = model }
    package var body: some View {
        switch model.value {
        case 0: Text("zero")
        case 1...8: Text("middle")
        default: Text("nine")
        }
    }
}
package struct ArgumentOrderProbe: View {
    package let first: CounterModel
    package let second: CounterModel
    package init(first: CounterModel, second: CounterModel) { self.first = first; self.second = second }
    package var body: some View { Text(counterText(first.value + second.value)) }
}
package struct SiblingFailureProbe: View {
    package let first: CounterModel
    package let second: CounterModel
    package init(first: CounterModel, second: CounterModel) { self.first = first; self.second = second }
    package var body: some View { CounterRoot(model: first); CounterRoot(model: second) }
}
