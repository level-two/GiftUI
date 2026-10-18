import GiftUI
import SignalAnalyzerDomain
@usableFromInline package protocol AnalyzerReadDomain: _GiftUIReadDomain {
static func bind(_ key: _GiftUIModelKey<AnalyzerModelSchema>, slots: Span<Slot>) throws(_GiftUIAccessFailure) -> Int
static func AnalyzerRead_state_acquisitionState(at index: Int, slots: Span<Slot>) -> AcquisitionState
static func AnalyzerRead_state_capture_count(at index: Int, slots: Span<Slot>) -> UInt16
static func AnalyzerRead_state_capture_transition(_ position: Int, at index: Int, slots: Span<Slot>) throws(_GiftUIAccessFailure) -> SignalTransition
}
@usableFromInline package struct AnalyzerModelSchemaSeed {
@inlinable package init() {
}
}
@usableFromInline package enum AnalyzerModelSchema: _GiftUIModelSchema { @usableFromInline package typealias Seed = AnalyzerModelSchemaSeed }
@usableFromInline
package struct AnalyzerRead<D: AnalyzerReadDomain>: ~Escapable {
    @usableFromInline internal let slots: Span<D.Slot>
    @usableFromInline internal let index: Int
@inlinable
@_lifetime(copy read)
package init(_ key: _GiftUIModelKey<AnalyzerModelSchema>, read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) {
    index = try D.bind(key, slots: read.slots)
    slots = read.slots
}

@inlinable
@_lifetime(copy drawingRead)
package init(_ key: _GiftUIModelKey<AnalyzerModelSchema>, drawingRead: borrowing _GiftUIFrameRead<D>)
    throws(DrawingError) {
    do throws(_GiftUIAccessFailure) {
        index = try D.bind(key, slots: drawingRead.slots)
    } catch { throw DrawingError(accessFailure: error) }
    slots = drawingRead.slots
}
@inlinable
@_lifetime(copy self)
package func state() -> AnalyzerRead_state<D> {
    AnalyzerRead_state<D>(slots: slots, index: index)
}
}
@usableFromInline
package struct AnalyzerRead_state<D: AnalyzerReadDomain>: ~Escapable {
    @usableFromInline internal let slots: Span<D.Slot>
    @usableFromInline internal let index: Int
@inlinable
@_lifetime(copy slots)
internal init(slots: Span<D.Slot>, index: Int) {
    self.slots = slots
    self.index = index
}
@inlinable package var acquisitionState: AcquisitionState { D.AnalyzerRead_state_acquisitionState(at: index, slots: slots) }
@inlinable
@_lifetime(copy self)
package func capture() -> AnalyzerRead_state_capture<D> {
    AnalyzerRead_state_capture<D>(slots: slots, index: index)
}
}
@usableFromInline
package struct AnalyzerRead_state_capture<D: AnalyzerReadDomain>: ~Escapable {
    @usableFromInline internal let slots: Span<D.Slot>
    @usableFromInline internal let index: Int
@inlinable
@_lifetime(copy slots)
internal init(slots: Span<D.Slot>, index: Int) {
    self.slots = slots
    self.index = index
}
@inlinable package var count: UInt16 { D.AnalyzerRead_state_capture_count(at: index, slots: slots) }
@inlinable
package func transition(_ position: Int) throws(_GiftUIAccessFailure) -> SignalTransition {
    try D.AnalyzerRead_state_capture_transition(position, at: index, slots: slots)
}
@inlinable
package func _giftUIDrawing_transition(_ position: Int) throws(DrawingError) -> SignalTransition {
    do throws(_GiftUIAccessFailure) {
        return try D.AnalyzerRead_state_capture_transition(position, at: index, slots: slots)
    } catch { throw DrawingError(accessFailure: error) }
}
}
