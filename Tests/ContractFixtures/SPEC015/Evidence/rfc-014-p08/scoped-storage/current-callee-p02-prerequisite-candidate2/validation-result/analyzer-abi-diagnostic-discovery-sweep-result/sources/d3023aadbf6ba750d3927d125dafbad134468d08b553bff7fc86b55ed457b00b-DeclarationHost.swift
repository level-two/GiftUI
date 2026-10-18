import GiftUI
import CounterSchema
import CounterPresentation
import AnalyzerSchema
import AnalyzerPresentation
import SignalAnalyzerDomain

// Declaration-level P02 oracle; this is not a RuntimeCore/State implementation.
package struct CounterSlot {
    package let value: UInt8
    package let reads: UnsafeMutablePointer<UInt16>
}
package enum CounterDomain: CounterReadDomain {
    package typealias Slot = CounterSlot
    package static func bind(_ key: _GiftUIModelKey<CounterModelSchema>, slots: Span<Slot>)
        throws(_GiftUIAccessFailure) -> Int {
        guard key._giftUIOwnerInstance == 7 else { throw .wrongOwner }
        guard key._giftUIAllocationGeneration == 3 else { throw .staleModel }
        guard Int(key._giftUISlot) < slots.count else { throw .staleModel }
        return Int(key._giftUISlot)
    }
    package static func CounterRead_value(at index: Int, slots: Span<Slot>) -> UInt8 {
        slots[index].reads.pointee += 1
        return slots[index].value
    }
}

package struct DeclarationRecorder<R: _GiftUIReadDomain>: _GiftUISemanticTraversalVisitor {
    package typealias Domain = R
    package let slots: UnsafeBufferPointer<R.Slot>
    package var failure: _GiftUIAccessFailure?
    package var customs = 0
    package var stateful = 0
    package var primitives = 0
    package var actions: UInt16 = 0
    package var modifiers = 0
    package var empty = 0
    package var optionals = 0
    package var alternatives = 0
    package var fixed = 0

    package mutating func visitCustomView<Declaration: View>(
        _ declaration: borrowing Declaration,
        body: (borrowing _GiftUIFrameRead<R>) throws(_GiftUIAccessFailure) -> Declaration.Body
    ) where Declaration.Domain == R, Declaration.Body.Domain == R {
        guard failure == nil else { return }
        customs += 1
        let ownedBody: Declaration.Body
        do {
            let read = _GiftUIFrameRead<R>(slots: Span(_unsafeElements: slots))
            ownedBody = try body(read)
        } catch { failure = error; return }
        ownedBody._giftUITraverse(&self)
    }

    package mutating func visitStatefulCustomView<Declaration: View & _GiftUIObservableStateHost>(
        _ declaration: borrowing Declaration,
        body: (borrowing Declaration, borrowing _GiftUIFrameRead<R>) throws(_GiftUIAccessFailure) -> Declaration.Body
    ) where Declaration.Domain == R, Declaration.Body.Domain == R {
        guard failure == nil else { return }
        stateful += 1
        let ownedBody: Declaration.Body
        do {
            let read = _GiftUIFrameRead<R>(slots: Span(_unsafeElements: slots))
            ownedBody = try body(declaration, read)
        } catch { failure = error; return }
        ownedBody._giftUITraverse(&self)
    }

    package mutating func child<C: View>(_ child: borrowing C) where C.Domain == R {
        if failure == nil { child._giftUITraverse(&self) }
    }
    package mutating func visitEmpty() { if failure == nil { empty += 1 } }
    package mutating func visitFixed<A: View, B: View>(_ a: borrowing A, _ b: borrowing B) where A.Domain == R, B.Domain == R {
        fixed += 1
        child(a)
        child(b)
    }
    package mutating func visitFixed<A: View, B: View, C: View>(_ a: borrowing A, _ b: borrowing B, _ c: borrowing C) where A.Domain == R, B.Domain == R, C.Domain == R {
        fixed += 1
        child(a)
        child(b)
        child(c)
    }
    package mutating func visitFixed<A: View, B: View, C: View, D: View>(_ a: borrowing A, _ b: borrowing B, _ c: borrowing C, _ d: borrowing D) where A.Domain == R, B.Domain == R, C.Domain == R, D.Domain == R {
        fixed += 1
        child(a)
        child(b)
        child(c)
        child(d)
    }
    package mutating func visitFixed<A: View, B: View, C: View, D: View, E: View>(_ a: borrowing A, _ b: borrowing B, _ c: borrowing C, _ d: borrowing D, _ e: borrowing E) where A.Domain == R, B.Domain == R, C.Domain == R, D.Domain == R, E.Domain == R {
        fixed += 1
        child(a)
        child(b)
        child(c)
        child(d)
        child(e)
    }

    package mutating func visitConditionalFirst<First: View, Second: View>(
        _ content: borrowing First, second: Second.Type
    ) where First.Domain == R, Second.Domain == R { alternatives += 1; child(content) }
    package mutating func visitConditionalSecond<First: View, Second: View>(
        first: First.Type, _ content: borrowing Second
    ) where First.Domain == R, Second.Domain == R { alternatives += 1; child(content) }
    package mutating func visitOptionalAbsent<Content: View>(_ content: Content.Type)
        where Content.Domain == R { optionals += 1 }
    package mutating func visitOptionalPresent<Content: View>(_ content: borrowing Content)
        where Content.Domain == R { optionals += 1; child(content) }
    package mutating func visitPrimitive<Payload: _GiftUISemanticPrimitivePayload>(
        _ payload: borrowing Payload
    ) { if failure == nil { primitives += 1 } }
    package mutating func visitPrimitive<Content: View, Payload: _GiftUISemanticPrimitivePayload>(
        content: borrowing Content, payload: borrowing Payload
    ) where Content.Domain == R { visitPrimitive(payload); child(content) }
    package mutating func visitActionPrimitive<Payload: _GiftUISemanticActionPayload>(
        _ payload: borrowing Payload
    ) { if failure == nil { actions = actions * 10 + payload._giftUIAction.rawValue + 1 } }
    package mutating func visitActionPrimitive<Content: View, Payload: _GiftUISemanticActionPayload>(
        content: borrowing Content, payload: borrowing Payload
    ) where Content.Domain == R { visitActionPrimitive(payload); child(content) }
    package mutating func visitModifier<Content: View, Payload: _GiftUISemanticModifierPayload>(
        content: borrowing Content, payload: borrowing Payload
    ) where Content.Domain == R { if failure == nil { modifiers += 1 }; child(content) }
}

package struct Results {
    package var checks = 0
    package var failures = 0
    package mutating func expect(_ value: Bool) { checks += 1; if !value { failures += 1 } }
}
package func runDeclarationChecks() -> Results {
    var results = Results()
    withUnsafeTemporaryAllocation(of: UInt16.self, capacity: 1) { reads in
        reads.initialize(repeating: 0)
        defer { reads.deinitialize() }
        withUnsafeTemporaryAllocation(of: CounterSlot.self, capacity: 1) { slots in
            slots.initialize(repeating: CounterSlot(value: 0, reads: reads.baseAddress!))
            defer { slots.deinitialize() }
            let key = _GiftUIModelKey<CounterModelSchema>(ownerInstance: 7, allocationGeneration: 3, slot: 0)
            for value: UInt8 in 0...9 {
                reads[0] = 0
                slots[0] = CounterSlot(value: value, reads: reads.baseAddress!)
                var recorder = DeclarationRecorder<CounterDomain>(slots: UnsafeBufferPointer(slots))
                CounterRoot<CounterDomain>(model: key)._giftUITraverse(&recorder)
                let hasBadge = value > 0 && value < 9
                results.expect(recorder.failure == nil)
                results.expect(recorder.customs == (hasBadge ? 2 : 1))
                results.expect(recorder.primitives == (hasBadge ? 5 : 4))
                results.expect(recorder.actions == 12)
                results.expect(recorder.modifiers == (hasBadge ? 4 : 2))
                results.expect(recorder.optionals == 1)
                results.expect(reads[0] == (value == 0 ? 4 : (value == 9 ? 5 : 6)))
                results.expect(counterText(value) == BoundedText(Int32(value)))
                reads[0] = 0
                var lazy = DeclarationRecorder<CounterDomain>(slots: UnsafeBufferPointer(slots))
                LazyProbe<CounterDomain>(model: key)._giftUITraverse(&lazy)
                results.expect(lazy.failure == nil && lazy.primitives == (value == 0 ? 3 : 4))
                results.expect(reads[0] == (value == 0 ? 5 : (value == 9 ? 3 : 4)))
                reads[0] = 0
                var selection = DeclarationRecorder<CounterDomain>(slots: UnsafeBufferPointer(slots))
                SwitchProbe<CounterDomain>(model: key)._giftUITraverse(&selection)
                results.expect(selection.failure == nil && selection.primitives == 1 && reads[0] == 1)
            }
            var arities = DeclarationRecorder<CounterDomain>(slots: UnsafeBufferPointer(slots))
            ArityProbe<CounterDomain>()._giftUITraverse(&arities)
            results.expect(arities.customs == 7 && arities.primitives == 17 && arities.empty == 1 && arities.fixed == 6)
            var helpers = DeclarationRecorder<CounterDomain>(slots: UnsafeBufferPointer(slots))
            HelperProbe<CounterDomain>()._giftUITraverse(&helpers)
            results.expect(helpers.customs == 1 && helpers.primitives == 4 && helpers.fixed == 2)
            var host = DeclarationRecorder<CounterDomain>(slots: UnsafeBufferPointer(slots))
            StateHostWitnessProbe<CounterDomain>()._giftUITraverse(&host)
            results.expect(host.stateful == 1 && host.customs == 0 && host.primitives == 1)
            reads[0] = 0
            let stale = _GiftUIModelKey<CounterModelSchema>(ownerInstance: 7, allocationGeneration: 4, slot: 0)
            var failed = DeclarationRecorder<CounterDomain>(slots: UnsafeBufferPointer(slots))
            CounterRoot<CounterDomain>(model: stale)._giftUITraverse(&failed)
            results.expect(failed.failure == .staleModel)
            results.expect(failed.primitives == 0 && failed.actions == 0 && reads[0] == 0)
            let foreign = _GiftUIModelKey<CounterModelSchema>(ownerInstance: 8, allocationGeneration: 3, slot: 0)
            var order = DeclarationRecorder<CounterDomain>(slots: UnsafeBufferPointer(slots))
            ArgumentOrderProbe<CounterDomain>(first: stale, second: foreign)._giftUITraverse(&order)
            results.expect(order.failure == .staleModel && reads[0] == 0)
            var siblings = DeclarationRecorder<CounterDomain>(slots: UnsafeBufferPointer(slots))
            SiblingFailureProbe<CounterDomain>(first: stale, second: key)._giftUITraverse(&siblings)
            results.expect(siblings.failure == .staleModel && siblings.customs == 2 && reads[0] == 0)
        }
    }
    withUnsafeTemporaryAllocation(of: UInt16.self, capacity: 1) { slots in
        slots.initialize(repeating: 1)
        defer { slots.deinitialize() }
        let key = _GiftUIModelKey<AnalyzerModelSchema>(ownerInstance: 9, allocationGeneration: 0, slot: 0)
        var success = DeclarationRecorder<AnalyzerDomain>(slots: UnsafeBufferPointer(slots))
        AnalyzerReadProbe<AnalyzerDomain>(model: key, index: 0)._giftUITraverse(&success)
        results.expect(success.failure == nil && success.customs == 1 && success.primitives == 3)
        var failure = DeclarationRecorder<AnalyzerDomain>(slots: UnsafeBufferPointer(slots))
        AnalyzerReadProbe<AnalyzerDomain>(model: key, index: 1)._giftUITraverse(&failure)
        results.expect(failure.failure == .outOfBounds && failure.primitives == 0)
        slots[0] = 0
        var inactive = DeclarationRecorder<AnalyzerDomain>(slots: UnsafeBufferPointer(slots))
        AnalyzerReadProbe<AnalyzerDomain>(model: key, index: 1)._giftUITraverse(&inactive)
        results.expect(inactive.failure == nil && inactive.primitives == 2)
    }
    return results
}
@_cdecl("giftui_p02_declarations") public func declarationResult() -> Int32 {
    let result = runDeclarationChecks()
    return result.checks == 120 && result.failures == 0 ? 0 : 1
}

package enum AnalyzerDomain: AnalyzerReadDomain {
    package typealias Slot = UInt16
    package static func bind(_ key: _GiftUIModelKey<AnalyzerModelSchema>, slots: Span<UInt16>) throws(_GiftUIAccessFailure) -> Int {
        guard key._giftUIOwnerInstance == 9 else { throw .wrongOwner }
        guard key._giftUIAllocationGeneration == 0 && key._giftUISlot == 0 && slots.count == 1 else { throw .staleModel }
        return 0
    }
    package static func AnalyzerRead_state_acquisitionState(at index: Int, slots: Span<UInt16>) -> AcquisitionState { .running }
    package static func AnalyzerRead_state_capture_count(at index: Int, slots: Span<UInt16>) -> UInt16 { slots[index] }
    package static func AnalyzerRead_state_capture_transition(_ position: Int, at index: Int, slots: Span<UInt16>) throws(_GiftUIAccessFailure) -> SignalTransition {
        guard position >= 0 && position < Int(slots[index]) else { throw .outOfBounds }
        return SignalTransition(channelID: SignalChannelID(rawValue: 1), timestamp: .zero, level: .high)
    }
}
