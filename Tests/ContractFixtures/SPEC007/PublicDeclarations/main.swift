import GiftUI

let center = Alignment.center
let leading = Alignment.leading
let custom = Alignment(horizontal: .center, vertical: .bottom)
let zeroInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)!
let nonzeroInsets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)!
let emptyEdges = EdgeSet()
let reservedEdges = EdgeSet(rawValue: 1 << 7)
let allEdges: [EdgeSet] = [
    .top, .leading, .bottom, .trailing, .horizontal, .vertical, .all,
]
let finite = FrameLimit.points(10)
let negativeFinite = FrameLimit.points(-1)
let infinite = FrameLimit.infinity

struct PublicLayoutFixture: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .bottom, spacing: 3) {
                Spacer(minLength: 4)
                ZStack(alignment: custom) {
                    Spacer()
                }
            }
        }
        .padding(5)
        .padding(.horizontal, 6)
        .padding(nonzeroInsets)
        .frame(width: 100, height: nil, alignment: leading)
        .frame(
            minWidth: 10,
            maxWidth: .infinity,
            minHeight: nil,
            maxHeight: .points(200),
            alignment: center
        )
    }
}

let preservedInvalid = VStack(spacing: -1) {
    Spacer(minLength: -2)
}
.padding(reservedEdges, -3)
.frame(width: -4, height: -5)
.frame(
    minWidth: 9,
    maxWidth: .points(8),
    minHeight: -6,
    maxHeight: negativeFinite
)
