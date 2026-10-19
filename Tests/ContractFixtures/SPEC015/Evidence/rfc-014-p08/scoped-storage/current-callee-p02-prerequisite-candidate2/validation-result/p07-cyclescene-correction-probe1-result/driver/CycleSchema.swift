import GiftUI
@usableFromInline package protocol CycleReadDomain: _GiftUIReadDomain {
static func bind(_ key: _GiftUIModelKey<CycleModelSchema>, slots: Span<Slot>) throws(_GiftUIAccessFailure) -> Int
static func CycleRead_value(at index: Int, slots: Span<Slot>) -> UInt8
}
@usableFromInline package struct CycleModelSchemaSeed {
@usableFromInline package let value: UInt8
@inlinable package init(value: UInt8) {
self.value = value
}
}
@usableFromInline package enum CycleModelSchema: _GiftUIModelSchema { @usableFromInline package typealias Seed = CycleModelSchemaSeed }
@usableFromInline
package struct CycleRead<D: CycleReadDomain>: ~Escapable {
    @usableFromInline internal let slots: Span<D.Slot>
    @usableFromInline internal let index: Int
@inlinable
@_lifetime(copy read)
package init(_ key: _GiftUIModelKey<CycleModelSchema>, read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) {
    index = try D.bind(key, slots: read.slots)
    slots = read.slots
}

@inlinable
@_lifetime(copy drawingRead)
package init(_ key: _GiftUIModelKey<CycleModelSchema>, drawingRead: borrowing _GiftUIFrameRead<D>)
    throws(DrawingError) {
    do throws(_GiftUIAccessFailure) {
        index = try D.bind(key, slots: drawingRead.slots)
    } catch { throw DrawingError(accessFailure: error) }
    slots = drawingRead.slots
}
@inlinable package var value: UInt8 { D.CycleRead_value(at: index, slots: slots) }
}
