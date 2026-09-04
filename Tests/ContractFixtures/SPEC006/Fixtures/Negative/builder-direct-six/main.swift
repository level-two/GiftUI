import GiftUI

struct Leaf: View {
    var body: Never { fatalError() }
}

@ViewBuilder
func invalidDirectSix() -> some View {
    Leaf()
    Leaf()
    Leaf()
    Leaf()
    Leaf()
    Leaf()
}
