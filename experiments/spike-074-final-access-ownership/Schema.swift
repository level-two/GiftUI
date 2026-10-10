import GiftUI
import SignalAnalyzerDomain

package enum AnalyzerSchema {}
package enum CounterSchema {}
package protocol AnalyzerReadDomain: ReadDomain {
    static func bind(_ key: ModelKey<AnalyzerSchema>, in slots: Span<Slot>) throws(AccessFailure) -> Int
    static func acquisition(at index: Int, in slots: Span<Slot>) -> AcquisitionState
    static func count(at index: Int, in slots: Span<Slot>) -> UInt16
    static func transition(at position: Int, model: Int, in slots: Span<Slot>) throws(AccessFailure) -> SignalTransition
}
package protocol CounterReadDomain: ReadDomain {
    static func bind(_ key: ModelKey<CounterSchema>, in slots: Span<Slot>) throws(AccessFailure) -> Int
    static func value(at index: Int, in slots: Span<Slot>) -> UInt8
}
package struct AnalyzerRead<D: AnalyzerReadDomain>: ~Escapable {
    private let slots: Span<D.Slot>
    private let index: Int
    @_lifetime(copy read)
    package init(_ key: ModelKey<AnalyzerSchema>, read: borrowing FrameRead<D>) throws(AccessFailure) {
        index = try D.bind(key, in: read.slots); slots = read.slots
    }
    package var acquisitionState: AcquisitionState { D.acquisition(at: index, in: slots) }
    package var count: UInt16 { D.count(at: index, in: slots) }
    @_lifetime(borrow self)
    package func capture() -> CaptureRead<D> { CaptureRead(slots, index: index) }
}
package struct CaptureRead<D: AnalyzerReadDomain>: ~Escapable {
    private let slots: Span<D.Slot>
    private let index: Int
    @_lifetime(copy slots)
    fileprivate init(_ slots: Span<D.Slot>, index: Int) { self.slots = slots; self.index = index }
    package func transition(at position: Int) throws(AccessFailure) -> SignalTransition {
        try D.transition(at: position, model: index, in: slots)
    }
}
package struct CounterRead<D: CounterReadDomain>: ~Escapable {
    private let slots: Span<D.Slot>
    private let index: Int
    @_lifetime(copy read)
    package init(_ key: ModelKey<CounterSchema>, read: borrowing FrameRead<D>) throws(AccessFailure) {
        index = try D.bind(key, in: read.slots); slots = read.slots
    }
    package var value: UInt8 { D.value(at: index, in: slots) }
}
