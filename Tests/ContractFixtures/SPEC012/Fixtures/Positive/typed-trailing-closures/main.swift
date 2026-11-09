import GiftUI

struct TypedTrailingClosureCanvas: Canvas {
    typealias Domain = _GiftUIEmptyReadDomain

    func _giftUIDraw(
        in _: Rect,
        context: inout GraphicsContext,
        read _: borrowing _GiftUIFrameRead<Domain>
    ) throws(DrawingError) {
        guard let size = Size(width: 2, height: 2) else {
            throw DrawingError.invalidValue
        }
        try context.withPath { (context, path) throws(DrawingError) in
            try path.move(to: Point(x: 0, y: 0))
            try path.addLine(to: Point(x: size.width, y: size.height))
            try context.stroke(path, with: .color(.white), lineWidth: 1)
        }
    }
}

func typedTrailingClosures() -> TypedTrailingClosureCanvas {
    TypedTrailingClosureCanvas()
}
