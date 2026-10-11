import GiftUI

package enum CycleAction: UInt16, GiftUIAction { case increment = 1 }
package struct CycleTrace: Canvas {
    package let model: CycleModel
    package init(model: CycleModel) { self.model = model }
    package func draw(in bounds: Rect, context drawing: inout GraphicsContext) throws(DrawingError) {
        try drawing.withPath { (context, path) throws(DrawingError) in
            try path.move(to: Point(x: 0, y: GeometryScalar(model.value)))
            try path.addLine(to: Point(x: bounds.size.width, y: bounds.size.height))
            try context.stroke(path, with: .color(.white), lineWidth: 1)
        }
    }
}
@ObservableStateHost
package struct CycleRoot: View {
    @State private var model = CycleModel(value: 3)
    package init() {}
    package var body: some View {
        VStack {
            Text(BoundedText(Int32(model.value)))
            Button(action: CycleAction.increment) { Text("+") }
            CycleTrace(model: model)
        }
    }
}
package struct CycleScene: View {
    package let show: Bool
    package init(show: Bool) { self.show = show }
    package var body: some View {
        if show { CycleRoot() } else { Text("gone") }
    }
}
