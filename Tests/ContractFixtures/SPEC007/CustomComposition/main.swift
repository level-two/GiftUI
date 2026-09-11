import GiftUI

struct LayoutLeaf: View {
    var body: some View {
        Spacer()
    }
}

struct LayoutComposition: View {
    @ViewBuilder
    var property: some View {
        LayoutLeaf()
        LayoutLeaf()
    }

    @ViewBuilder
    func function() -> some View {
        LayoutLeaf()
        LayoutLeaf()
        LayoutLeaf()
    }

    var body: some View {
        VStack {
            VStack {}
            VStack { LayoutLeaf() }
            HStack {
                LayoutLeaf()
                LayoutLeaf()
            }
            ZStack {
                LayoutLeaf()
                LayoutLeaf()
                LayoutLeaf()
            }
            VStack {
                LayoutLeaf()
                LayoutLeaf()
                LayoutLeaf()
                LayoutLeaf()
            }
        }
        .padding(0)
        .frame(
            minWidth: nil,
            maxWidth: nil,
            minHeight: nil,
            maxHeight: nil,
            alignment: .leading
        )
    }
}

let five = HStack {
    LayoutLeaf()
    LayoutLeaf()
    LayoutLeaf()
    LayoutLeaf()
    LayoutLeaf()
}

let property = LayoutComposition().property
let function = LayoutComposition().function()
