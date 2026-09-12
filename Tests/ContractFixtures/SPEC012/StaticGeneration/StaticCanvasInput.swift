import GiftUI

// This source is the human-readable fixture paired with static-canvas-input.yaml.
// T6.1 checks expression anchors and capture metadata; T6.2 owns Swift emission.

func gridCanvas(color: Color, lineWidth: GeometryScalar) -> Canvas {
    // giftui-static-canvas-expression: grid
    Canvas { (context, size) throws(DrawingError) in
        try context.withPath { (context, path) throws(DrawingError) in
            try path.move(to: Point(x: 0, y: 0))
            try path.addLine(to: Point(x: size.width, y: 0))
            try context.stroke(path, with: .color(color), lineWidth: lineWidth)
        }
    }
}

func traceCanvas(
    color: Color,
    verticalOffset: GeometryScalar,
    highLevel: GeometryScalar
) -> Canvas {
    // giftui-static-canvas-expression: trace
    Canvas { (context, size) throws(DrawingError) in
        try context.withPath { (context, path) throws(DrawingError) in
            try path.move(to: Point(x: 0, y: verticalOffset))
            try path.addLine(to: Point(x: size.width, y: highLevel))
            try context.stroke(path, with: .color(color), lineWidth: 1)
        }
    }
}

func markerCanvas() -> Canvas {
    // giftui-static-canvas-expression: marker
    Canvas { (context, size) throws(DrawingError) in
        try context.withPath { (context, path) throws(DrawingError) in
            try path.move(to: Point(x: size.width, y: 0))
            try path.addLine(to: Point(x: size.width, y: size.height))
            try context.stroke(path, with: .color(.white), lineWidth: 1)
        }
    }
}
