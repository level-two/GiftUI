import CycleSchema
import GiftUI
@usableFromInline


package enum CycleAction: UInt16, GiftUIAction { case increment = 1 }
@usableFromInline

package struct CycleTrace<D:CycleReadDomain>: Canvas {@usableFromInline package typealias Domain = D

@usableFromInline

    package let model:_GiftUIModelKey<CycleModelSchema>
@inlinable

    package init(model: _GiftUIModelKey<CycleModelSchema>) { self.model = model }
    @inlinable
@inline(__always)
package func _giftUIDraw(in bounds: Rect, context drawing: inout GraphicsContext,
    read: borrowing _GiftUIFrameRead<D>) throws(DrawingError) {_ = try CycleRead<D>(self.model, drawingRead: read)

        try drawing.withPath { (context, path) throws(DrawingError) in
            try path.move(to: Point(x: 0, y: GeometryScalar((try CycleRead<D>(model, drawingRead: read)).value)))
            try path.addLine(to: Point(x: bounds.size.width, y: bounds.size.height))
            try context.stroke(path, with: .color(.white), lineWidth: 1)
        }
    }
}
@ObservableStateHost
@usableFromInline

package struct CycleRoot<D:CycleReadDomain>: View {@usableFromInline package typealias Domain = D

    @State<CycleModelSchema>(seed: CycleModelSchemaSeed(value: 3)) private var model: _GiftUIModelKey<CycleModelSchema>?

@usableFromInline

    package init() {}
@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    
        try VStack {() throws(_GiftUIAccessFailure) in 
            Text<D>(BoundedText(Int32((try CycleRead<D>(try self._giftUIStateKey_model(), read: read)).value)))
            try Button(action: CycleAction.increment) { () throws(_GiftUIAccessFailure) in Text<D>("+") }
            CycleTrace<D>(model: (try self._giftUIStateKey_model()))
        }
}
@usableFromInline
internal var _giftUIStateStorage_model: State<CycleModelSchema> {
    _read { yield _model }
    _modify { yield &_model }
}
@usableFromInline
internal borrowing func _giftUIStateKey_model()
    throws(_GiftUIAccessFailure) -> _GiftUIModelKey<CycleModelSchema> {
    try _model._giftUIKey()
}
}
@usableFromInline

package struct CycleScene<D:CycleReadDomain>: View {@usableFromInline package typealias Domain = D

    @usableFromInline package let show: Bool
    package init(show: Bool) { self.show = show }
@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    
        if show { CycleRoot<D>() } else { Text<D>("gone") }
}
}
