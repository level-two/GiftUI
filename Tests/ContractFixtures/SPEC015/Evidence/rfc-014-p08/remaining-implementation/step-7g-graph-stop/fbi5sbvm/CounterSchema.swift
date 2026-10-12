import GiftUI
package protocol CounterReadDomain: _GiftUIReadDomain {
static func bind(_ key: _GiftUIModelKey<CounterModelSchema>, slots: Span<Slot>) throws(_GiftUIAccessFailure) -> Int
static func CounterRead_value(at index: Int, slots: Span<Slot>) -> UInt8
}
package struct CounterModelSchemaSeed {
package let value: UInt8
package init(value: UInt8) {
self.value = value
}
}
package enum CounterModelSchema: _GiftUIModelSchema { package typealias Seed = CounterModelSchemaSeed }
package struct CounterRead<D: CounterReadDomain>: ~Escapable {
    private let slots: Span<D.Slot>
    private let index: Int
@_lifetime(copy read)
package init(_ key: _GiftUIModelKey<CounterModelSchema>, read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) {
    index = try D.bind(key, slots: read.slots)
    slots = read.slots
}

@_lifetime(copy drawingRead)
package init(_ key: _GiftUIModelKey<CounterModelSchema>, drawingRead: borrowing _GiftUIFrameRead<D>)
    throws(DrawingError) {
    do throws(_GiftUIAccessFailure) {
        index = try D.bind(key, slots: drawingRead.slots)
    } catch { throw DrawingError(accessFailure: error) }
    slots = drawingRead.slots
}
package var value: UInt8 { D.CounterRead_value(at: index, slots: slots) }
}
