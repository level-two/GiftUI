class BaseHost {
    @State var inherited = Model()
}

@ObservableStateHost
class DerivedHost: BaseHost, View {
    @State var direct = Model()
    var body: Never { fatalError() }
}
