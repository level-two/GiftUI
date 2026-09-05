@ObservableStateHost
struct InvalidHost: View {
    @State var value: Model { Model() }
    var body: Never { fatalError() }
}
