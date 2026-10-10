import GiftUI

@ObservableStateHost
package struct SeededRoot: View {
    @State private var model = CounterModel(value: 3)

    package init() {}

    package var body: some View {
        Text(BoundedText(Int32(model.value)))
    }
}

@ObservableStateHost
package struct CandidateRoot: View {
    @State private var model: CounterModel

    package init(model: CounterModel) {
        _model = State(wrappedValue: model)
    }

    package var body: some View {
        Text(BoundedText(Int32(self.model.value)))
    }
}

@ObservableStateHost
package struct NestedRoot: View {
    @State private var model = CounterModel(value: 7)

    package init() {}

    package var body: some View {
        CandidateRoot(model: self.model)
    }
}
