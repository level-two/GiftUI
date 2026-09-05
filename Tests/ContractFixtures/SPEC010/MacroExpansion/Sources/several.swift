@ObservableStateHost
public struct SeveralHost: View {
    @State private var first = Model()
    struct Nested {
        @State var ignored = Model()
    }
    @GiftUI.State var second = Model()
    static var ignoredStatic = Model()
    public var body: Never { fatalError() }
}
