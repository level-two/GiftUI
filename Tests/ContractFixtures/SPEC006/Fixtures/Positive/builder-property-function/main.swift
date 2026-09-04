import GiftUI

struct Leaf: View {
    var body: Never { fatalError() }
}

@ViewBuilder
func makeContent() -> some View {
    Leaf()
    Leaf()
}

struct FunctionRoot: View {
    @ViewBuilder
    var body: some View {
        makeContent()
    }
}
