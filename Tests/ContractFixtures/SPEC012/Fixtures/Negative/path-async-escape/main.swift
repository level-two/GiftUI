import GiftUI

func suspend() async {}

func illegalPathAsyncEscape(
    _ context: inout GraphicsContext
) async throws(DrawingError) {
    try await context.withPath { (_, path) async throws(DrawingError) in
        try path.move(to: Point(x: 0, y: 0))
        await suspend()
        try path.addLine(to: Point(x: 1, y: 1))
    }
}
