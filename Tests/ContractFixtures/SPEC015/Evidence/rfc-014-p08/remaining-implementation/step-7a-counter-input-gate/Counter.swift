import P08CounterSchema
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

package struct CounterCanvas<D:CounterReadDomain>: Canvas {package typealias Domain = D

    package let model:_GiftUIModelKey<CounterModelSchema>
    package init(model: _GiftUIModelKey<CounterModelSchema>) { self.model = model }
    package func _giftUIDraw(in bounds: Rect, context drawing: inout GraphicsContext,
    read: borrowing _GiftUIFrameRead<D>) throws(DrawingError) {_ = try CounterRead<D>(self.model, drawingRead: read)

        if (try CounterRead<D>(model, drawingRead: read)).value > 0 {
            try drawing.withPath { (context, path) throws(DrawingError) in
                try path.move(to: Point(x: 4, y: 8))
                try path.addLine(to: Point(x: 4 + 4 * GeometryScalar((try CounterRead<D>(model, drawingRead: read)).value), y: 8))
                try context.stroke(path, with: .color(.white),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

@ObservableStateHost
package struct CounterScreen<D:CounterReadDomain>: View {package typealias Domain = D

    @State<CounterModelSchema>(seed: CounterModelSchemaSeed(value: 0)) private var model: _GiftUIModelKey<CounterModelSchema>?

    package init() {}
@ViewBuilder
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    
        try VStack(spacing: 4) {() throws(_GiftUIAccessFailure) in 
            Text<D>("Counter")
            Text<D>(counterText((try CounterRead<D>(try _model._giftUIKey(), read: read)).value))
            try Button(action: CounterAction.increment) { () throws(_GiftUIAccessFailure) in Text<D>("Increment") }.disabled((try CounterRead<D>(try _model._giftUIKey(), read: read)).value == 9)
            try Button(action: CounterAction.reset) { () throws(_GiftUIAccessFailure) in Text<D>("Reset") }.disabled((try CounterRead<D>(try _model._giftUIKey(), read: read)).value == 0)
            CounterCanvas<D>(model: (try _model._giftUIKey())).frame(width: 48, height: 16)
        }
}
}
