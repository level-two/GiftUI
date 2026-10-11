import GiftUI

package struct CounterTrace: Canvas {
    package let model: CounterModel
    package let offset: GeometryScalar
    package func draw(in bounds: Rect, context: inout GraphicsContext) throws(DrawingError) {
        let value = model.value
        try context.withPath { (context, path) throws(DrawingError) in
            try path.move(to: Point(x: offset, y: GeometryScalar(value)))
            try path.addLine(to: Point(x: bounds.size.width, y: bounds.size.height))
            try context.stroke(path, with: .color(.white), lineWidth: 1)
        }
    }
}
package struct CounterCanvasRoot: View {
    package let model: CounterModel
    package var body: some View {
        CounterTrace(model: model, offset: 0)
        CounterTrace(model: model, offset: 2)
    }
}
