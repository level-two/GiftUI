import GiftUI

struct Leaf: View {
    var body: Never { fatalError() }
}

@ViewBuilder
func zero() -> some View {}

@ViewBuilder
func one() -> some View {
    Leaf()
}

@ViewBuilder
func two() -> some View {
    Leaf()
    Leaf()
}

@ViewBuilder
func three() -> some View {
    Leaf()
    Leaf()
    Leaf()
}

@ViewBuilder
func four() -> some View {
    Leaf()
    Leaf()
    Leaf()
    Leaf()
}

@ViewBuilder
func five() -> some View {
    Leaf()
    Leaf()
    Leaf()
    Leaf()
    Leaf()
}
