import GiftUI

struct Leaf: View {
    var body: Never { fatalError() }
}

@ViewBuilder
func nestedPair() -> some View {
    Leaf()
    Leaf()
}

@ViewBuilder
func nestedSix() -> some View {
    nestedPair()
    Leaf()
    Leaf()
    Leaf()
    Leaf()
}
