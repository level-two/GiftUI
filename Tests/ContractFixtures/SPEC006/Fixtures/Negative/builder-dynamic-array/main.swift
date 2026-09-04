import GiftUI

struct Leaf: View {
    var body: Never { fatalError() }
}

@ViewBuilder
func invalidDynamicArray() -> some View {
    for _ in 0..<2 {
        Leaf()
    }
}
