import GiftUI
@usableFromInline package protocol CounterReadDomain: _GiftUIReadDomain {
static func bind(_ key: _GiftUIModelKey<CounterModelSchema>, slots: Span<Slot>) throws(_GiftUIAccessFailure) -> Int
static func CounterRead_value(at index: Int, slots: Span<Slot>) -> UInt8
}
@usableFromInline package struct CounterModelSchemaSeed {
@inlinable package init() {
}
}
@usableFromInline package enum CounterModelSchema: _GiftUIModelSchema { @usableFromInline package typealias Seed = CounterModelSchemaSeed }
@usableFromInline
package struct CounterRead<D: CounterReadDomain>: ~Escapable {
    @usableFromInline internal let slots: Span<D.Slot>
    @usableFromInline internal let index: Int
@inlinable
@_lifetime(copy read)
package init(_ key: _GiftUIModelKey<CounterModelSchema>, read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) {
    index = try D.bind(key, slots: read.slots)
    slots = read.slots
}

@inlinable
@_lifetime(copy drawingRead)
package init(_ key: _GiftUIModelKey<CounterModelSchema>, drawingRead: borrowing _GiftUIFrameRead<D>)
    throws(DrawingError) {
    do throws(_GiftUIAccessFailure) {
        index = try D.bind(key, slots: drawingRead.slots)
    } catch { throw DrawingError(accessFailure: error) }
    slots = drawingRead.slots
}
@inlinable package var value: UInt8 { D.CounterRead_value(at: index, slots: slots) }
}
