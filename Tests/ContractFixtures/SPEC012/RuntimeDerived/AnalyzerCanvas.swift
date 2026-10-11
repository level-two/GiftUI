import GiftUI
import SignalAnalyzerDomain

package struct AnalyzerTrace: Canvas {
    package let model: SignalAnalyzerViewModel
    package let index: Int
    package init(model: SignalAnalyzerViewModel, index: Int) {
        self.model = model
        self.index = index
    }
    package func draw(in bounds: Rect, context: inout GraphicsContext) throws(DrawingError) {
        let capture = model.state.capture
        if capture.count > 0 {
            let transition = model.state.capture.transition(index)
            try context.withPath { (context, path) throws(DrawingError) in
                try path.move(to: Point(x: 0, y: GeometryScalar(transition.channelID.rawValue)))
                try path.addLine(to: Point(x: bounds.size.width, y: bounds.size.height))
                try context.stroke(path, with: .color(.white), lineWidth: 1)
            }
        }
    }
}
