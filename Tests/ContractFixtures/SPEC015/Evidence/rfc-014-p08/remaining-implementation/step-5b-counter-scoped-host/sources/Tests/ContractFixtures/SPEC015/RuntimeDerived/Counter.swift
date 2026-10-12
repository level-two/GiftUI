import GiftUI

package enum CounterAction: UInt16, GiftUIAction { case increment = 0, reset = 1 }

package func counterText(_ value: UInt8) -> BoundedText {
    switch value {
    case 0: BoundedText("0")!
    case 1: BoundedText("1")!
    case 2: BoundedText("2")!
    case 3: BoundedText("3")!
    case 4: BoundedText("4")!
    case 5: BoundedText("5")!
    case 6: BoundedText("6")!
    case 7: BoundedText("7")!
    case 8: BoundedText("8")!
    default: BoundedText("9")!
    }
}

package struct CounterCanvas: Canvas {
    package let model: CounterModel
    package init(model: CounterModel) { self.model = model }
    package func draw(in bounds: Rect, context drawing: inout GraphicsContext) throws(DrawingError) {
        if model.value > 0 {
            try drawing.withPath { (context, path) throws(DrawingError) in
                try path.move(to: Point(x: 4, y: 8))
                try path.addLine(to: Point(x: 4 + 4 * GeometryScalar(model.value), y: 8))
                try context.stroke(path, with: .color(.white),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

@ObservableStateHost
package struct CounterScreen: View {
    @State private var model = CounterModel(value: 0)
    package init() {}
    package var body: some View {
        VStack(spacing: 4) {
            Text("Counter")
            Text(counterText(model.value))
            Button(action: CounterAction.increment) { Text("Increment") }.disabled(model.value == 9)
            Button(action: CounterAction.reset) { Text("Reset") }.disabled(model.value == 0)
            CounterCanvas(model: model).frame(width: 48, height: 16)
        }
    }
}
