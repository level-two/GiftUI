import GiftUI
import GiftUIDrawing
import CycleSchema
import CyclePresentation
@usableFromInline package enum CycleSchemaCanvasValues<D: CycleReadDomain> {
case v1(CycleTrace<D>)
}
@usableFromInline package struct CycleSchemaCanvasTable<D: CycleReadDomain>: CanvasValueTable {
@usableFromInline package typealias Domain = D
@usableFromInline package typealias CaptureStorage = CycleSchemaCanvasValues<D>
@inlinable package init() {}
@inlinable package var callableCaseCount: UInt16 { 1 }
@inlinable package func captureByteCount(for id: UInt16) -> UInt16? { switch id {
case 1: UInt16(exactly: MemoryLayout<CycleTrace<D>>.stride)
default: nil } }
@inlinable package static func caseID(for value: borrowing CaptureStorage) -> UInt16 { switch value {
case .v1: 1
} }
@inlinable package static func payload<Value: _GiftUISemanticPrimitivePayload>(_ value: borrowing Value) -> CaptureStorage? {
if Value.self == CycleTrace<D>.self {
    return withUnsafePointer(to: value) { pointer in
        pointer.withMemoryRebound(to: CycleTrace<D>.self, capacity: 1) { .v1($0.pointee) }
    }
}
return nil
}
@inlinable package mutating func invoke(id: UInt16, captures: borrowing CaptureStorage,
    context: inout GraphicsContext, size: Size, read: borrowing _GiftUIFrameRead<D>) throws(DrawingError) {
    guard id == Self.caseID(for: captures) else { throw .invariantViolation }
    switch captures {
case .v1(let value): try value._giftUIInvokeCanvas(context: &context, size: size, read: read)
}
}
}
