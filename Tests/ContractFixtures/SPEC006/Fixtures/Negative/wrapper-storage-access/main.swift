import GiftUI

struct Leaf: View {
    var body: Never { fatalError() }
}

func inspect(_ pair: TupleView<Leaf, Leaf>) {
    _ = pair.a
}
