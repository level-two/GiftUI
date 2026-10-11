import CycleSchema
import GiftUI

package enum CycleAction: UInt16, GiftUIAction { case increment = 1 }
package struct CycleTrace<D:CycleReadDomain>: Canvas {package typealias Domain = D

    package let model:_GiftUIModelKey<CycleModelSchema>
    package init(model: _GiftUIModelKey<CycleModelSchema>) { self.model = model }
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
package struct CycleRoot<D:CycleReadDomain>: View {package typealias Domain = D

    @State<CycleModelSchema>(seed: CycleModelSchemaSeed(value: 3)) private var model: _GiftUIModelKey<CycleModelSchema>?

    package init() {}
@ViewBuilder
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    
        try VStack {() throws(_GiftUIAccessFailure) in 
            Text<D>(BoundedText(Int32((try CycleRead<D>(try _model._giftUIKey(), read: read)).value)))
            try Button(action: CycleAction.increment) { () throws(_GiftUIAccessFailure) in Text<D>("+") }
            CycleTrace<D>(model: (try _model._giftUIKey()))
        }
}
}
package struct CycleScene<D:CycleReadDomain>: View {package typealias Domain = D

    package let show: Bool
    package init(show: Bool) { self.show = show }
@ViewBuilder
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    
        if show { CycleRoot<D>() } else { Text<D>("gone") }
}
}
