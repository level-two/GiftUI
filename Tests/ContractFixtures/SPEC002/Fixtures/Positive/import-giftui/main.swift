import GiftUI

let point = Point(x: -1, y: 2)
let size = Size(width: 3, height: 4)
let proposal = ProposedSize(width: nil, height: 4)

func makeRect() -> Rect? {
    guard let size else { return nil }
    return Rect(origin: point, size: size)
}

_ = makeRect()?.contains(point)
_ = proposal?.width
