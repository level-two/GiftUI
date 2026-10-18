import P08CounterSchema
import GiftUI
@usableFromInline


package enum CounterAction: UInt16, GiftUIAction { case increment = 0, reset = 1 }
@usableFromInline


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
@usableFromInline


package struct CounterCanvas<D:CounterReadDomain>: Canvas {@usableFromInline package typealias Domain = D

@usableFromInline

    package let model:_GiftUIModelKey<CounterModelSchema>
@inlinable

    package init(model: _GiftUIModelKey<CounterModelSchema>) { self.model = model }
    @inlinable
@inline(__always)
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
@usableFromInline

package struct CounterScreen<D:CounterReadDomain>: View {@usableFromInline package typealias Domain = D

    @State<CounterModelSchema>(seed: CounterModelSchemaSeed(value: 0)) private var model: _GiftUIModelKey<CounterModelSchema>?

@usableFromInline

    package init() {}
@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    
        try VStack(spacing: 4) {() throws(_GiftUIAccessFailure) in 
            Text<D>("Counter")
            Text<D>(counterText((try CounterRead<D>(try self._giftUIStateKey_model(), read: read)).value))
            try Button(action: CounterAction.increment) { () throws(_GiftUIAccessFailure) in Text<D>("Increment") }.disabled((try CounterRead<D>(try self._giftUIStateKey_model(), read: read)).value == 9)
            try Button(action: CounterAction.reset) { () throws(_GiftUIAccessFailure) in Text<D>("Reset") }.disabled((try CounterRead<D>(try self._giftUIStateKey_model(), read: read)).value == 0)
            CounterCanvas<D>(model: (try self._giftUIStateKey_model())).frame(width: 48, height: 16)
        }.background(.black)
}
@usableFromInline
internal var _giftUIStateStorage_model: State<CounterModelSchema> {
    _read { yield _model }
    _modify { yield &_model }
}
@usableFromInline
internal borrowing func _giftUIStateKey_model()
    throws(_GiftUIAccessFailure) -> _GiftUIModelKey<CounterModelSchema> {
    try _model._giftUIKey()
}
}
