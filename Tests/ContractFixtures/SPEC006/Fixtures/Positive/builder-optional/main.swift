import GiftUI

struct Leaf: View {
    var body: Never { fatalError() }
}

struct OptionalRoot: View {
    let includesLeaf: Bool

    var body: some View {
        if includesLeaf {
            Leaf()
        }
    }
}
