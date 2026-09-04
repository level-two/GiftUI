import GiftUI

struct FirstLeaf: View {
    var body: Never { fatalError() }
}

struct SecondLeaf: View {
    var body: Never { fatalError() }
}

struct ConditionalRoot: View {
    let useFirst: Bool

    var body: some View {
        if useFirst {
            FirstLeaf()
        } else {
            SecondLeaf()
        }
    }
}
