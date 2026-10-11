import GiftUI
package protocol CycleReadDomain: _GiftUIReadDomain {
static func bind(_ key: _GiftUIModelKey<CycleModelSchema>, slots: Span<Slot>) throws(_GiftUIAccessFailure) -> Int
static func CycleRead_value(at index: Int, slots: Span<Slot>) -> UInt8
}
package struct CycleModelSchemaSeed {
package let value: UInt8
package init(value: UInt8) {
self.value = value
}
}
package enum CycleModelSchema: _GiftUIModelSchema { package typealias Seed = CycleModelSchemaSeed }
package struct CycleRead<D: CycleReadDomain>: ~Escapable {
    private let slots: Span<D.Slot>
    private let index: Int
@_lifetime(copy read)
package init(_ key: _GiftUIModelKey<CycleModelSchema>, read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) {
    index = try D.bind(key, slots: read.slots)
    slots = read.slots
}

@_lifetime(copy drawingRead)
package init(_ key: _GiftUIModelKey<CycleModelSchema>, drawingRead: borrowing _GiftUIFrameRead<D>)
    throws(DrawingError) {
    do throws(_GiftUIAccessFailure) {
        index = try D.bind(key, slots: drawingRead.slots)
    } catch { throw DrawingError(accessFailure: error) }
    slots = drawingRead.slots
}
package var value: UInt8 { D.CycleRead_value(at: index, slots: slots) }
}
