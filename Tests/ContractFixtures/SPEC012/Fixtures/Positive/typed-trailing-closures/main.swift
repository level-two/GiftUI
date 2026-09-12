import GiftUI

func typedTrailingClosures() -> Canvas {
    Canvas { (context, size) throws(DrawingError) in
        try context.withPath { (context, path) throws(DrawingError) in
            try path.move(to: Point(x: 0, y: 0))
            try path.addLine(to: Point(x: size.width, y: size.height))
            try context.stroke(path, with: .color(.white), lineWidth: 1)
        }
    }
}
