@ObservableStateHost
private struct PrivateHost: View {
    @State private var model = Model()
    var body: Never { fatalError() }
}
