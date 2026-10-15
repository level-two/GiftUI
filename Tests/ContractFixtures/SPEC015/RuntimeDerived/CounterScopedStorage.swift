import P08CounterTable
import GiftUI
import GiftUIDrawing
@testable import GiftUIExecution
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIReferenceTextResources
import GiftUISemanticCore
@testable import GiftUIRuntimeCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif
import P08CounterSchema

import GiftUIInteraction
@testable import GiftUIHostConfiguration

// All creation and projection of selected capabilities is confined to this file.
// Layout/source inspection does not establish numeric ABI or target fit.
fileprivate enum P08PhysicalID: UInt8 { case b0, b1, b2, b3, g0, g1, g2, g3, g4, c0, h0, r0, r1, h1 }
fileprivate enum P08PhysicalLifecycle { case reserved, idle, active, released }
fileprivate enum P08BackingInitializationFailure: Equatable { case invalidReservation, invalidCapacity, constructor, injected(P08PhysicalID, Int) }
fileprivate struct P08InitializedEntry: Equatable {
    let id: P08PhysicalID
    let address: UInt
    let count: Int
    let size: Int
    let stride: Int
    let alignment: Int
    let retainedBytes: Int
}
fileprivate struct P08AcquisitionFault {
    let id: P08PhysicalID
    let completed: Int
    let afterInstall: Bool
}

// Native slots remain pinned by their enclosing typed Optional borrows. Embedded
// descriptors name separately bound T objects, never an old Optional aggregate.
fileprivate struct P08PaddedReservation<T> {
    var slot: T? = nil
    var padding: InlineArray<64, UInt8> = .init(repeating: 0)
}
fileprivate enum P08TypedSlot<T> {
    case native(UnsafeMutablePointer<T?>)
    case padded(UnsafeMutablePointer<P08PaddedReservation<T>>)
    case embedded(UnsafeMutablePointer<T>, Int)
    var reservedBytes: Int {
        switch self {
        case .native: MemoryLayout<T?>.stride
        case .padded: MemoryLayout<P08PaddedReservation<T>>.stride
        case .embedded(_, let extent): extent
        }
    }
    var reservationRange: (UInt, Int, Int, Int) {
        switch self {
        case .padded(let p): precondition(p.pointee.slot == nil); return (UInt(bitPattern: p), MemoryLayout<P08PaddedReservation<T>>.stride, MemoryLayout<P08PaddedReservation<T>>.alignment, MemoryLayout<P08PaddedReservation<T>>.stride)
        case .native(let p): precondition(p.pointee == nil); return (UInt(bitPattern: p), MemoryLayout<T?>.stride, MemoryLayout<T?>.alignment, MemoryLayout<T?>.stride)
        case .embedded(let p, let extent): return (UInt(bitPattern: p), extent, MemoryLayout<T>.alignment, MemoryLayout<T>.stride)
        }
    }
    func install(_ value: consuming T) {
        switch self {
        case .native(let slot): precondition(slot.pointee == nil); slot.pointee = consume value
        case .padded(let slot): precondition(slot.pointee.slot == nil); slot.pointee.slot = consume value
        case .embedded(let slot, _): slot.initialize(to: consume value)
        }
    }
    func destroy() {
        switch self {
        case .native(let slot): precondition(slot.pointee != nil); slot.pointee = nil
        case .padded(let slot): precondition(slot.pointee.slot != nil); slot.pointee.slot = nil
        case .embedded(let slot, _): slot.deinitialize(count: 1)
        }
    }
    func withBorrow<Result>(_ body: (UnsafeMutablePointer<T>) -> Result) -> Result {
        switch self {
        case .padded(let slot):
            precondition(slot.pointee.slot != nil)
            return withUnsafeMutablePointer(to: &slot.pointee.slot!) { body($0) }
        case .native(let slot):
            precondition(slot.pointee != nil)
            return withUnsafeMutablePointer(to: &slot.pointee!) { body($0) }
        case .embedded(let slot, _):
            return withUnsafeMutablePointer(to: &slot.pointee) { body($0) }
        }
    }
    func facts(id: P08PhysicalID, payloadBytes: Int = 0) -> P08InitializedEntry {
        withBorrow { pointer in
            let retained = reservedBytes.addingReportingOverflow(payloadBytes)
            precondition(!retained.overflow)
            return .init(id: id, address: UInt(bitPattern: pointer), count: 1,
                size: MemoryLayout<T>.size, stride: MemoryLayout<T>.stride,
                alignment: MemoryLayout<T>.alignment, retainedBytes: retained.partialValue)
        }
    }
}

fileprivate enum P08ByteSlot {
    case scopes(UnsafeMutablePointer<InlineArray<1024, UInt8>?>)
    case text(UnsafeMutablePointer<InlineArray<1056, UInt8>?>)
    case path(UnsafeMutablePointer<InlineArray<20, UInt8>?>)
    case plan(UnsafeMutablePointer<InlineArray<112, UInt8>?>)
    case embedded(UnsafeMutableBufferPointer<UInt8>, Int)
    var count: Int {
        switch self { case .scopes: 1024; case .text: 1056; case .path: 20; case .plan: 112; case .embedded(let p, _): p.count }
    }
    var reservedBytes: Int {
        switch self {
        case .scopes: MemoryLayout<InlineArray<1024, UInt8>?>.stride
        case .text: MemoryLayout<InlineArray<1056, UInt8>?>.stride
        case .path: MemoryLayout<InlineArray<20, UInt8>?>.stride
        case .plan: MemoryLayout<InlineArray<112, UInt8>?>.stride
        case .embedded(_, let extent): extent
        }
    }
    var reservationRange: (UInt, Int, Int, Int) {
        switch self {
        case .scopes(let p): precondition(p.pointee == nil); return (UInt(bitPattern: p), reservedBytes, MemoryLayout<InlineArray<1024, UInt8>?>.alignment, MemoryLayout<InlineArray<1024, UInt8>?>.stride)
        case .text(let p): precondition(p.pointee == nil); return (UInt(bitPattern: p), reservedBytes, MemoryLayout<InlineArray<1056, UInt8>?>.alignment, MemoryLayout<InlineArray<1056, UInt8>?>.stride)
        case .path(let p): precondition(p.pointee == nil); return (UInt(bitPattern: p), reservedBytes, MemoryLayout<InlineArray<20, UInt8>?>.alignment, MemoryLayout<InlineArray<20, UInt8>?>.stride)
        case .plan(let p): precondition(p.pointee == nil); return (UInt(bitPattern: p), reservedBytes, MemoryLayout<InlineArray<112, UInt8>?>.alignment, MemoryLayout<InlineArray<112, UInt8>?>.stride)
        case .embedded(let p, _): return (UInt(bitPattern: p.baseAddress!), reservedBytes, 1, p.count)
        }
    }
    // Counts are acquired cell by cell only for Embedded raw UInt8 regions.
    func initialize(upTo count: Int) {
        switch self {
        case .scopes(let p): precondition(count == 1024 && p.pointee == nil); p.pointee = .init(repeating: 0)
        case .text(let p): precondition(count == 1056 && p.pointee == nil); p.pointee = .init(repeating: 0)
        case .path(let p): precondition(count == 20 && p.pointee == nil); p.pointee = .init(repeating: 0)
        case .plan(let p): precondition(count == 112 && p.pointee == nil); p.pointee = .init(repeating: 0)
        case .embedded(let p, _): for index in 0..<count { p.baseAddress!.advanced(by: index).initialize(to: 0) }
        }
    }
    func destroy(count: Int) {
        switch self {
        case .scopes(let p): p.pointee = nil
        case .text(let p): p.pointee = nil
        case .path(let p): p.pointee = nil
        case .plan(let p): p.pointee = nil
        case .embedded(let p, _): p.baseAddress!.deinitialize(count: count)
        }
    }
    func withBorrow<Result>(initializedCount: Int? = nil, _ body: (UnsafeMutableRawBufferPointer) -> Result) -> Result {
        switch self {
        case .scopes(let p): return withUnsafeMutableBytes(of: &p.pointee!) { body($0) }
        case .text(let p): return withUnsafeMutableBytes(of: &p.pointee!) { body($0) }
        case .path(let p): return withUnsafeMutableBytes(of: &p.pointee!) { body($0) }
        case .plan(let p): return withUnsafeMutableBytes(of: &p.pointee!) { body($0) }
        case .embedded(let p, _):
            let liveCount = initializedCount ?? p.count
            precondition(liveCount >= 0 && liveCount <= p.count)
            var cells = MutableSpan(_unsafeStart: p.baseAddress!, count: liveCount)
            return cells.withUnsafeMutableBufferPointer { body(UnsafeMutableRawBufferPointer($0)) }
        }
    }
    func facts(id: P08PhysicalID, initialized: Int) -> P08InitializedEntry {
        withBorrow(initializedCount: initialized) { bytes in .init(id: id, address: UInt(bitPattern: bytes.baseAddress!),
            count: initialized, size: 1, stride: 1, alignment: 1, retainedBytes: reservedBytes) }
    }
}
fileprivate struct P08StaticSlots {
    let b0: P08ByteSlot
    let b1: P08ByteSlot
    let b2: P08ByteSlot
    let b3: P08ByteSlot
    let g0: P08TypedSlot<StaticCounterLayoutWorkspace>
    let g1: P08TypedSlot<StaticCounterResolvedLayoutStorage>
    let g2: P08TypedSlot<InlineArray<64, SemanticRecordReference?>>
    let g3: P08TypedSlot<StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>>
    let g4: P08TypedSlot<QualifiedRender>
    let c0: P08TypedSlot<CounterStaticCandidate>
    let h0: P08TypedSlot<CounterStaticHits>
    let r0: P08TypedSlot<CounterStaticCommitted>
    let r1: P08TypedSlot<CounterStaticCommitted>
    let h1: P08TypedSlot<CounterStaticHits>
}

#if !hasFeature(Embedded)
fileprivate struct P08DynamicSlots {
    let g0: P08TypedSlot<DynamicLayoutWorkspace>
    let g1: P08TypedSlot<DynamicResolvedLayoutStorage>
    let g3: P08TypedSlot<DynamicDrawingPlanWorkspace>
    let g4: P08TypedSlot<DynamicRenderWorkspace>
    let c0: P08TypedSlot<CounterDynamicCandidate>
    let h0: P08TypedSlot<CounterDynamicHits>
    let r0: P08TypedSlot<CounterDynamicCommitted>
    let r1: P08TypedSlot<CounterDynamicCommitted>
    let h1: P08TypedSlot<CounterDynamicHits>
}
#endif

fileprivate enum P08PhysicalSlots {
    case `static`(P08StaticSlots)
    #if !hasFeature(Embedded)
    case dynamic(P08DynamicSlots)
    #endif
}
fileprivate struct P08TypedBackingOwner: ~Copyable {
    private let slots: P08PhysicalSlots
    private let identity: UInt
    private var serial: UInt64 = 0
    private var lifecycle: P08PhysicalLifecycle = .reserved
    private var inventory: InlineArray<14, P08InitializedEntry?> = .init(repeating: nil)
    private var acquired = 0
    private var destruction: InlineArray<14, P08InitializedEntry?> = .init(repeating: nil)
    private var destroyed = 0
    private let capacities: InlineArray<5, UInt16>
    init(slots: P08PhysicalSlots, identity: UInt, capacities: InlineArray<5, UInt16> = [2, 2, 2, 2, 2]) {
        self.slots = slots; self.identity = identity; self.capacities = capacities
    }
    private mutating func record(_ entry: P08InitializedEntry) {
        precondition(acquired < 14)
        for index in 0..<acquired {
            let other = inventory[index]!
            let entryExtent = UInt(entry.stride).multipliedReportingOverflow(by: UInt(entry.count))
            let otherExtent = UInt(other.stride).multipliedReportingOverflow(by: UInt(other.count))
            precondition(!entryExtent.overflow && !otherExtent.overflow)
            let a = entry.address.addingReportingOverflow(entryExtent.partialValue)
            let b = other.address.addingReportingOverflow(otherExtent.partialValue)
            precondition(!a.overflow && !b.overflow && (a.partialValue <= other.address || b.partialValue <= entry.address))
            precondition(entry.id != other.id)
        }
        inventory[acquired] = entry; acquired += 1
    }
    private func validateReservations() -> Bool {
        var ranges: InlineArray<14, (UInt, Int, Int, Int)?> = .init(repeating: nil)
        var count = 0
        switch slots {
        case .static(let s):
            ranges[count] = s.b0.reservationRange; count += 1
            ranges[count] = s.b1.reservationRange; count += 1
            ranges[count] = s.b2.reservationRange; count += 1
            ranges[count] = s.b3.reservationRange; count += 1
            ranges[count] = s.g0.reservationRange; count += 1
            ranges[count] = s.g1.reservationRange; count += 1
            ranges[count] = s.g2.reservationRange; count += 1
            ranges[count] = s.g3.reservationRange; count += 1
            ranges[count] = s.g4.reservationRange; count += 1
            ranges[count] = s.c0.reservationRange; count += 1
            ranges[count] = s.h0.reservationRange; count += 1
            ranges[count] = s.r0.reservationRange; count += 1
            ranges[count] = s.r1.reservationRange; count += 1
            ranges[count] = s.h1.reservationRange; count += 1
        #if !hasFeature(Embedded)
        case .dynamic(let s):
            ranges[count] = s.g0.reservationRange; count += 1
            ranges[count] = s.g1.reservationRange; count += 1
            ranges[count] = s.g3.reservationRange; count += 1
            ranges[count] = s.g4.reservationRange; count += 1
            ranges[count] = s.c0.reservationRange; count += 1
            ranges[count] = s.h0.reservationRange; count += 1
            ranges[count] = s.r0.reservationRange; count += 1
            ranges[count] = s.r1.reservationRange; count += 1
            ranges[count] = s.h1.reservationRange; count += 1
        #endif
        }
        for index in 0..<count {
            let (start, extent, alignment, required) = ranges[index]!
            guard extent >= required, required > 0, alignment > 0, start % UInt(alignment) == 0 else { return false }
            let end = start.addingReportingOverflow(UInt(extent))
            guard !end.overflow else { return false }
            for earlier in 0..<index {
                let (other, bytes, _, _) = ranges[earlier]!
                let otherEnd = other.addingReportingOverflow(UInt(bytes))
                guard !otherEnd.overflow, end.partialValue <= other || otherEnd.partialValue <= start else { return false }
            }
        }
        return true
    }
    private func validateCapacities() -> Bool {
        capacities[0] >= 2 && capacities[1] >= 2 && capacities[2] >= 2 &&
            capacities[2] == capacities[3] && capacities[1] == capacities[4]
    }
    fileprivate mutating func initialize(fault: P08AcquisitionFault? = nil) -> P08BackingInitializationFailure? {
        precondition(lifecycle == .reserved && acquired == 0)
        destroyed = 0; destruction = .init(repeating: nil)
        guard identity != 0, validateCapacities() else { return .invalidCapacity }
        guard validateReservations() else { return .invalidReservation }
        func before(_ id: P08PhysicalID) -> Bool { fault?.id == id && fault?.completed == 0 && fault?.afterInstall == false }
        func after(_ id: P08PhysicalID) -> Bool { fault?.id == id && fault?.afterInstall == true }
        var failure: P08BackingInitializationFailure?
        switch slots {
        case .static(let s):
            if failure == nil {
                if before(.b0) { failure = .injected(.b0, 0) } else {
                    let count = fault?.id == .b0 && fault?.afterInstall == false ? fault!.completed : s.b0.count
                    if case .embedded = s.b0 {
                        guard count >= 0 && count <= s.b0.count else { preconditionFailure("invalid acquisition fault") }
                        s.b0.initialize(upTo: count)
                        record(s.b0.facts(id: .b0, initialized: count))
                        if count != s.b0.count { failure = .injected(.b0, count) }
                    } else {
                        precondition(count == s.b0.count)
                        s.b0.initialize(upTo: count); record(s.b0.facts(id: .b0, initialized: count))
                    }
                    if after(.b0) { failure = .injected(.b0, count) }
                }
            }
            if failure == nil {
                if before(.b1) { failure = .injected(.b1, 0) } else {
                    let count = fault?.id == .b1 && fault?.afterInstall == false ? fault!.completed : s.b1.count
                    if case .embedded = s.b1 {
                        guard count >= 0 && count <= s.b1.count else { preconditionFailure("invalid acquisition fault") }
                        s.b1.initialize(upTo: count)
                        record(s.b1.facts(id: .b1, initialized: count))
                        if count != s.b1.count { failure = .injected(.b1, count) }
                    } else {
                        precondition(count == s.b1.count)
                        s.b1.initialize(upTo: count); record(s.b1.facts(id: .b1, initialized: count))
                    }
                    if after(.b1) { failure = .injected(.b1, count) }
                }
            }
            if failure == nil {
                if before(.b2) { failure = .injected(.b2, 0) } else {
                    let count = fault?.id == .b2 && fault?.afterInstall == false ? fault!.completed : s.b2.count
                    if case .embedded = s.b2 {
                        guard count >= 0 && count <= s.b2.count else { preconditionFailure("invalid acquisition fault") }
                        s.b2.initialize(upTo: count)
                        record(s.b2.facts(id: .b2, initialized: count))
                        if count != s.b2.count { failure = .injected(.b2, count) }
                    } else {
                        precondition(count == s.b2.count)
                        s.b2.initialize(upTo: count); record(s.b2.facts(id: .b2, initialized: count))
                    }
                    if after(.b2) { failure = .injected(.b2, count) }
                }
            }
            if failure == nil {
                if before(.b3) { failure = .injected(.b3, 0) } else {
                    let count = fault?.id == .b3 && fault?.afterInstall == false ? fault!.completed : s.b3.count
                    if case .embedded = s.b3 {
                        guard count >= 0 && count <= s.b3.count else { preconditionFailure("invalid acquisition fault") }
                        s.b3.initialize(upTo: count)
                        record(s.b3.facts(id: .b3, initialized: count))
                        if count != s.b3.count { failure = .injected(.b3, count) }
                    } else {
                        precondition(count == s.b3.count)
                        s.b3.initialize(upTo: count); record(s.b3.facts(id: .b3, initialized: count))
                    }
                    if after(.b3) { failure = .injected(.b3, count) }
                }
            }
            if failure == nil {
                if before(.g0) { failure = .injected(.g0, 0) }
                else if let object = s.b0.withBorrow({ scopes in s.b1.withBorrow { text in StaticCounterLayoutWorkspace(scopes: scopes, text: text) } }) {
                    s.g0.install(consume object); record(s.g0.facts(id: .g0))
                    if after(.g0) { failure = .injected(.g0, 1) }
                } else { failure = .constructor }
            }
            if failure == nil {
                if before(.g1) { failure = .injected(.g1, 0) }
                else if let object = s.b0.withBorrow({ scopes in s.b1.withBorrow { text in StaticCounterResolvedLayoutStorage(scopes: scopes, text: text) } }) {
                    s.g1.install(consume object); record(s.g1.facts(id: .g1))
                    if after(.g1) { failure = .injected(.g1, 1) }
                } else { failure = .constructor }
            }
            if failure == nil {
                if before(.g2) { failure = .injected(.g2, 0) }
                else if let object = .some(InlineArray<64, SemanticRecordReference?>(repeating: nil)) {
                    s.g2.install(consume object); record(s.g2.facts(id: .g2))
                    if after(.g2) { failure = .injected(.g2, 1) }
                } else { failure = .constructor }
            }
            if failure == nil {
                if before(.g3) { failure = .injected(.g3, 0) }
                else if let object = s.b2.withBorrow({ path in s.b3.withBorrow { plan in StaticCounterDrawingWorkspace(pathRegion: path, planRegion: plan, capacity: counterDrawingLimits).map { StaticRecordDrawingWorkspace(base: $0) } } }) {
                    s.g3.install(consume object); record(s.g3.facts(id: .g3))
                    if after(.g3) { failure = .injected(.g3, 1) }
                } else { failure = .constructor }
            }
            if failure == nil {
                if before(.g4) { failure = .injected(.g4, 0) }
                else if let object = s.b1.withBorrow({ text in StaticCounterRenderWorkspace(region: text, capacity: counterRenderLimits, structuralCapacity: counterRenderCapacity).map { QualifiedRender(base: $0) } }) {
                    s.g4.install(consume object); record(s.g4.facts(id: .g4))
                    if after(.g4) { failure = .injected(.g4, 1) }
                } else { failure = .constructor }
            }
            if failure == nil {
                if before(.c0) { failure = .injected(.c0, 0) }
                else if let object = CounterStaticCandidate(capacity: capacities[0]) {
                    s.c0.install(consume object); record(s.c0.facts(id: .c0))
                    if after(.c0) { failure = .injected(.c0, 1) }
                } else { failure = .constructor }
            }
            if failure == nil {
                if before(.h0) { failure = .injected(.h0, 0) }
                else if let object = CounterStaticHits(capacity: capacities[1]) {
                    s.h0.install(consume object); record(s.h0.facts(id: .h0))
                    if after(.h0) { failure = .injected(.h0, 1) }
                } else { failure = .constructor }
            }
            if failure == nil {
                if before(.r0) { failure = .injected(.r0, 0) }
                else if let object = CounterStaticCommitted(capacity: capacities[2]) {
                    s.r0.install(consume object); record(s.r0.facts(id: .r0))
                    if after(.r0) { failure = .injected(.r0, 1) }
                } else { failure = .constructor }
            }
            if failure == nil {
                if before(.r1) { failure = .injected(.r1, 0) }
                else if let object = CounterStaticCommitted(capacity: capacities[3]) {
                    s.r1.install(consume object); record(s.r1.facts(id: .r1))
                    if after(.r1) { failure = .injected(.r1, 1) }
                } else { failure = .constructor }
            }
            if failure == nil {
                if before(.h1) { failure = .injected(.h1, 0) }
                else if let object = CounterStaticHits(capacity: capacities[4]) {
                    s.h1.install(consume object); record(s.h1.facts(id: .h1))
                    if after(.h1) { failure = .injected(.h1, 1) }
                } else { failure = .constructor }
            }
        #if !hasFeature(Embedded)
        case .dynamic(let s):
            if failure == nil {
                if before(.g0) { failure = .injected(.g0, 0) } else {
                    let object = DynamicLayoutWorkspace(limits: counterLayoutLimits, maximumSemanticRecords: 126)
                    let retainedPayloadBytes = Int(object.reservedPayloadBytes)
                    s.g0.install(consume object); record(s.g0.facts(id: .g0, payloadBytes: retainedPayloadBytes))
                    if after(.g0) { failure = .injected(.g0, 1) }
                }
            }
            if failure == nil {
                if before(.g1) { failure = .injected(.g1, 0) } else {
                    let object = DynamicResolvedLayoutStorage(limits: counterLayoutLimits)
                    let retainedPayloadBytes = Int(object.reservedPayloadBytes)
                    s.g1.install(consume object); record(s.g1.facts(id: .g1, payloadBytes: retainedPayloadBytes))
                    if after(.g1) { failure = .injected(.g1, 1) }
                }
            }
            if failure == nil {
                if before(.g3) { failure = .injected(.g3, 0) } else {
                    let object = DynamicDrawingPlanWorkspace(capacity: counterDrawingLimits)
                    let retainedPayloadBytes = Int(object.livePathReservedPayloadBytes + object.planReservedPayloadBytes)
                    s.g3.install(consume object); record(s.g3.facts(id: .g3, payloadBytes: retainedPayloadBytes))
                    if after(.g3) { failure = .injected(.g3, 1) }
                }
            }
            if failure == nil {
                if before(.g4) { failure = .injected(.g4, 0) } else {
                    let object = DynamicRenderWorkspace(capacity: counterRenderLimits, structuralCapacity: counterRenderCapacity)
                    let retainedPayloadBytes = Int(object.reservedPayloadBytes)
                    s.g4.install(consume object); record(s.g4.facts(id: .g4, payloadBytes: retainedPayloadBytes))
                    if after(.g4) { failure = .injected(.g4, 1) }
                }
            }
            if failure == nil {
                if before(.c0) { failure = .injected(.c0, 0) } else {
                    let object = CounterDynamicCandidate(capacity: capacities[0])
                    let retainedPayloadBytes = Int(object.reservedPayloadBytes)
                    s.c0.install(consume object); record(s.c0.facts(id: .c0, payloadBytes: retainedPayloadBytes))
                    if after(.c0) { failure = .injected(.c0, 1) }
                }
            }
            if failure == nil {
                if before(.h0) { failure = .injected(.h0, 0) } else {
                    let object = CounterDynamicHits(capacity: capacities[1])
                    let retainedPayloadBytes = Int(object.reservedPayloadBytes)
                    s.h0.install(consume object); record(s.h0.facts(id: .h0, payloadBytes: retainedPayloadBytes))
                    if after(.h0) { failure = .injected(.h0, 1) }
                }
            }
            if failure == nil {
                if before(.r0) { failure = .injected(.r0, 0) } else {
                    let object = CounterDynamicCommitted(capacity: capacities[2])
                    let retainedPayloadBytes = Int(object.reservedPayloadBytes)
                    s.r0.install(consume object); record(s.r0.facts(id: .r0, payloadBytes: retainedPayloadBytes))
                    if after(.r0) { failure = .injected(.r0, 1) }
                }
            }
            if failure == nil {
                if before(.r1) { failure = .injected(.r1, 0) } else {
                    let object = CounterDynamicCommitted(capacity: capacities[3])
                    let retainedPayloadBytes = Int(object.reservedPayloadBytes)
                    s.r1.install(consume object); record(s.r1.facts(id: .r1, payloadBytes: retainedPayloadBytes))
                    if after(.r1) { failure = .injected(.r1, 1) }
                }
            }
            if failure == nil {
                if before(.h1) { failure = .injected(.h1, 0) } else {
                    let object = CounterDynamicHits(capacity: capacities[4])
                    let retainedPayloadBytes = Int(object.reservedPayloadBytes)
                    s.h1.install(consume object); record(s.h1.facts(id: .h1, payloadBytes: retainedPayloadBytes))
                    if after(.h1) { failure = .injected(.h1, 1) }
                }
            }
        #endif
        }
        if let failure { destroyPrefix(); return failure }
        lifecycle = .idle
        return nil
    }
    private mutating func destroyPrefix() {
        while acquired > 0 {
            acquired -= 1
            let entry = inventory[acquired]!
            destroyOriginal(entry)
            destruction[destroyed] = entry; destroyed += 1
            inventory[acquired] = nil
        }
        lifecycle = .reserved
    }
    private borrowing func destroyOriginal(_ entry: P08InitializedEntry) {
        switch slots {
        case .static(let s):
            switch entry.id {
            case .b0: s.b0.destroy(count: entry.count)
            case .b1: s.b1.destroy(count: entry.count)
            case .b2: s.b2.destroy(count: entry.count)
            case .b3: s.b3.destroy(count: entry.count)
            case .g0: s.g0.destroy()
            case .g1: s.g1.destroy()
            case .g2: s.g2.destroy()
            case .g3: s.g3.destroy()
            case .g4: s.g4.destroy()
            case .c0: s.c0.destroy()
            case .h0: s.h0.destroy()
            case .r0: s.r0.destroy()
            case .r1: s.r1.destroy()
            case .h1: s.h1.destroy()
            }
        #if !hasFeature(Embedded)
        case .dynamic(let s):
            switch entry.id {
            case .g0: s.g0.destroy()
            case .g1: s.g1.destroy()
            case .g3: s.g3.destroy()
            case .g4: s.g4.destroy()
            case .c0: s.c0.destroy()
            case .h0: s.h0.destroy()
            case .r0: s.r0.destroy()
            case .r1: s.r1.destroy()
            case .h1: s.h1.destroy()
            default: preconditionFailure("Dynamic inventory contains Static region")
            }
        #endif
        }
    }
    fileprivate mutating func finishReservation() {
        if lifecycle == .idle { release() } else { precondition(lifecycle == .released && acquired == 0) }
    }
    fileprivate mutating func release() {
        precondition(lifecycle == .idle)
        requireEmpty()
        destroyPrefix(); lifecycle = .released
    }
    deinit {
        precondition(lifecycle != .active)
        if lifecycle == .idle {
            requireEmpty()
            var remaining = acquired
            while remaining > 0 { remaining -= 1; destroyOriginal(inventory[remaining]!) }
        } else { precondition(acquired == 0) }
    }
    fileprivate func requireEmpty() {
        switch slots {
        case .static(let s):
            s.g0.withBorrow { precondition($0.pointee.scopeCount == 0 && $0.pointee.textLineCount == 0 && $0.pointee.positionedGlyphCount == 0) }
            s.g2.withBorrow { p in for index in 0..<64 { precondition(p.pointee[index] == nil) } }
            s.g3.withBorrow { precondition(!$0.pointee.isActive && $0.pointee.summary.normalizedStrokeOperationCount == 0) }
            s.g4.withBorrow { precondition(!$0.pointee.isActive) }
            s.c0.withBorrow { precondition($0.pointee.count == 0) }
            s.h0.withBorrow { precondition($0.pointee.count == 0) }
            s.r0.withBorrow { precondition($0.pointee.count == 0) }
            s.r1.withBorrow { precondition($0.pointee.count == 0) }
            s.h1.withBorrow { precondition($0.pointee.count == 0) }
        #if !hasFeature(Embedded)
        case .dynamic(let s):
            s.g3.withBorrow { precondition(!$0.pointee.isActive && $0.pointee.strokeCount == 0 && $0.pointee.pointCount == 0 && $0.pointee.subpathCount == 0) }
            s.g4.withBorrow { precondition(!$0.pointee.isActive) }
            s.c0.withBorrow { precondition($0.pointee.count == 0) }
            s.h0.withBorrow { precondition($0.pointee.count == 0) }
            s.r0.withBorrow { precondition($0.pointee.count == 0) }
            s.r1.withBorrow { precondition($0.pointee.count == 0) }
            s.h1.withBorrow { precondition($0.pointee.count == 0) }
        #endif
        }
    }
    fileprivate func originalInventory() -> InlineArray<14, P08InitializedEntry?> { inventory }
    fileprivate func destructionTranscript() -> InlineArray<14, P08InitializedEntry?> { destruction }
}
fileprivate func initializeP08Backing(_ backing: inout P08TypedBackingOwner) -> P08BackingInitializationFailure? {
    backing.initialize()
}

fileprivate struct P08SessionLifetime: ~Escapable {
    private let ownerIdentity: UInt
    private let serial: UInt64
    @_lifetime(borrow owner)
    private init(owner: borrowing P08TypedBackingOwner, identity: UInt, serial: UInt64) {
        self.ownerIdentity = identity; self.serial = serial
    }
    @_lifetime(borrow owner)
    fileprivate static func lend(owner: borrowing P08TypedBackingOwner, identity: UInt, serial: UInt64) -> Self {
        Self(owner: owner, identity: identity, serial: serial)
    }
    fileprivate func matches(_ other: borrowing Self) -> Bool {
        ownerIdentity == other.ownerIdentity && serial == other.serial
    }
}

fileprivate enum P08CandidateDescriptor {
    case `static`(UnsafeMutablePointer<CounterStaticCandidate>, P08InitializedEntry, UInt16)
    #if !hasFeature(Embedded)
    case dynamic(UnsafeMutablePointer<CounterDynamicCandidate>, P08InitializedEntry, UInt16)
    #endif
    var original: P08InitializedEntry { switch self { case .static(_, let facts, _): facts
        #if !hasFeature(Embedded)
        case .dynamic(_, let facts, _): facts
        #endif
    } }
    var capacity: UInt16 { switch self { case .static(_, _, let capacity): capacity
        #if !hasFeature(Embedded)
        case .dynamic(_, _, let capacity): capacity
        #endif
    } }
    var count: UInt16 { switch self { case .static(let p, _, _): p.pointee.count
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.count
        #endif
    } }
}
fileprivate struct P08CandidateAccess: ~Copyable, ~Escapable, CounterCandidateBacking {
    typealias Identity = SemanticCompleteIdentity
    private let lifetime: P08SessionLifetime
    private var descriptor: P08CandidateDescriptor
    @_lifetime(copy sessionLifetime)
    private init(sessionLifetime: borrowing P08SessionLifetime, descriptor: P08CandidateDescriptor) {
        lifetime = copy sessionLifetime; self.descriptor = descriptor
    }
    private enum Factory {
        @_lifetime(copy sessionLifetime)
        static func make(sessionLifetime: borrowing P08SessionLifetime, descriptor: P08CandidateDescriptor) -> P08CandidateAccess {
            P08CandidateAccess(sessionLifetime: sessionLifetime, descriptor: descriptor)
        }
    }
    @_lifetime(copy sessionLifetime)
    fileprivate static func lend(sessionLifetime: borrowing P08SessionLifetime, descriptor: P08CandidateDescriptor) -> Self {
        Factory.make(sessionLifetime: sessionLifetime, descriptor: descriptor)
    }
    var count: UInt16 { descriptor.count }
    var capacity: UInt16 { descriptor.capacity }
    var retainedIdentitySlots: Int { switch descriptor {
        case .static(let p, _, _): p.pointee.retainedIdentitySlots
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.retainedIdentitySlots
        #endif
    } }
    var retainedPayloadBytes: Int { switch descriptor {
        case .static(let p, _, _): p.pointee.retainedPayloadBytes
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.retainedPayloadBytes
        #endif
    } }
    mutating func reset() { switch descriptor { case .static(let p, _, _): p.pointee.reset()
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.reset()
        #endif
    } }
    borrowing func record(at index: UInt16) -> InteractionCandidateRecord<SemanticCompleteIdentity>? { switch descriptor {
        case .static(let p, _, _): p.pointee.record(at: index)
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.record(at: index)
        #endif
    } }
    mutating func append(_ record: consuming InteractionCandidateRecord<SemanticCompleteIdentity>) -> Bool { switch descriptor {
        case .static(let p, _, _): p.pointee.append(record)
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.append(record)
        #endif
    } }
    mutating func replace(at index: UInt16, with record: consuming InteractionCandidateRecord<SemanticCompleteIdentity>) -> Bool { switch descriptor {
        case .static(let p, _, _): p.pointee.replace(at: index, with: record)
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.replace(at: index, with: record)
        #endif
    } }
}

fileprivate enum P08CommittedDescriptor {
    case `static`(UnsafeMutablePointer<CounterStaticCommitted>, P08InitializedEntry, UInt16)
    #if !hasFeature(Embedded)
    case dynamic(UnsafeMutablePointer<CounterDynamicCommitted>, P08InitializedEntry, UInt16)
    #endif
    var original: P08InitializedEntry { switch self { case .static(_, let facts, _): facts
        #if !hasFeature(Embedded)
        case .dynamic(_, let facts, _): facts
        #endif
    } }
    var capacity: UInt16 { switch self { case .static(_, _, let capacity): capacity
        #if !hasFeature(Embedded)
        case .dynamic(_, _, let capacity): capacity
        #endif
    } }
    var count: UInt16 { switch self { case .static(let p, _, _): p.pointee.count
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.count
        #endif
    } }
}
fileprivate struct P08CommittedAccess: ~Copyable, ~Escapable, CounterCommittedBacking {
    typealias Identity = SemanticCompleteIdentity
    private let lifetime: P08SessionLifetime
    private let transcript: UnsafeMutablePointer<P08RoleTranscript>?
    private var descriptor: P08CommittedDescriptor
    @_lifetime(copy sessionLifetime)
    private init(sessionLifetime: borrowing P08SessionLifetime, descriptor: P08CommittedDescriptor, transcript: UnsafeMutablePointer<P08RoleTranscript>? = nil) {
        lifetime = copy sessionLifetime; self.descriptor = descriptor; self.transcript = transcript
    }
    private enum Factory {
        @_lifetime(copy sessionLifetime)
        static func make(sessionLifetime: borrowing P08SessionLifetime, descriptor: P08CommittedDescriptor, transcript: UnsafeMutablePointer<P08RoleTranscript>? = nil) -> P08CommittedAccess {
            P08CommittedAccess(sessionLifetime: sessionLifetime, descriptor: descriptor, transcript: transcript)
        }
    }
    @_lifetime(copy sessionLifetime)
    fileprivate static func lend(sessionLifetime: borrowing P08SessionLifetime, descriptor: P08CommittedDescriptor, transcript: UnsafeMutablePointer<P08RoleTranscript>? = nil) -> Self {
        Factory.make(sessionLifetime: sessionLifetime, descriptor: descriptor, transcript: transcript)
    }
    var count: UInt16 { descriptor.count }
    var capacity: UInt16 { descriptor.capacity }
    var retainedIdentitySlots: Int { switch descriptor {
        case .static(let p, _, _): p.pointee.retainedIdentitySlots
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.retainedIdentitySlots
        #endif
    } }
    var retainedPayloadBytes: Int { switch descriptor {
        case .static(let p, _, _): p.pointee.retainedPayloadBytes
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.retainedPayloadBytes
        #endif
    } }
    mutating func reset() { switch descriptor { case .static(let p, _, _): p.pointee.reset()
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.reset()
        #endif
    } }
    borrowing func record(at index: UInt16) -> BoundActionRecord<SemanticCompleteIdentity>? { switch descriptor {
        case .static(let p, _, _): p.pointee.record(at: index)
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.record(at: index)
        #endif
    } }
    mutating func append(_ record: consuming BoundActionRecord<SemanticCompleteIdentity>) -> Bool { switch descriptor {
        case .static(let p, _, _): p.pointee.append(record)
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.append(record)
        #endif
    } }
    mutating func exchangeContents(with other: inout Self) {
        precondition(lifetime.matches(other.lifetime) && capacity == other.capacity)
        precondition(descriptor.original.id != other.descriptor.original.id)
        precondition(descriptor.original.address != other.descriptor.original.address)
        let old = descriptor, right = other.descriptor
        let leftCount = count, rightCount = other.count
        descriptor = right; other.descriptor = old
        precondition(descriptor.original.address == right.original.address && other.descriptor.original.address == old.original.address)
        precondition(count == rightCount && other.count == leftCount)
        precondition(descriptor.original.retainedBytes == right.original.retainedBytes && other.descriptor.original.retainedBytes == old.original.retainedBytes)
        transcript?.pointee.record(.init(bankKind: 0, leftBefore: old.original, rightBefore: right.original, leftCount: leftCount, rightCount: rightCount, leftAfter: descriptor.original, rightAfter: other.descriptor.original))
    }
}

fileprivate enum P08HitDescriptor {
    case `static`(UnsafeMutablePointer<CounterStaticHits>, P08InitializedEntry, UInt16)
    #if !hasFeature(Embedded)
    case dynamic(UnsafeMutablePointer<CounterDynamicHits>, P08InitializedEntry, UInt16)
    #endif
    var original: P08InitializedEntry { switch self { case .static(_, let facts, _): facts
        #if !hasFeature(Embedded)
        case .dynamic(_, let facts, _): facts
        #endif
    } }
    var capacity: UInt16 { switch self { case .static(_, _, let capacity): capacity
        #if !hasFeature(Embedded)
        case .dynamic(_, _, let capacity): capacity
        #endif
    } }
    var count: UInt16 { switch self { case .static(let p, _, _): p.pointee.count
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.count
        #endif
    } }
}
fileprivate struct P08HitAccess: ~Copyable, ~Escapable, CounterHitBacking {
    typealias Identity = SemanticCompleteIdentity
    private let lifetime: P08SessionLifetime
    private let transcript: UnsafeMutablePointer<P08RoleTranscript>?
    private var descriptor: P08HitDescriptor
    @_lifetime(copy sessionLifetime)
    private init(sessionLifetime: borrowing P08SessionLifetime, descriptor: P08HitDescriptor, transcript: UnsafeMutablePointer<P08RoleTranscript>? = nil) {
        lifetime = copy sessionLifetime; self.descriptor = descriptor; self.transcript = transcript
    }
    private enum Factory {
        @_lifetime(copy sessionLifetime)
        static func make(sessionLifetime: borrowing P08SessionLifetime, descriptor: P08HitDescriptor, transcript: UnsafeMutablePointer<P08RoleTranscript>? = nil) -> P08HitAccess {
            P08HitAccess(sessionLifetime: sessionLifetime, descriptor: descriptor, transcript: transcript)
        }
    }
    @_lifetime(copy sessionLifetime)
    fileprivate static func lend(sessionLifetime: borrowing P08SessionLifetime, descriptor: P08HitDescriptor, transcript: UnsafeMutablePointer<P08RoleTranscript>? = nil) -> Self {
        Factory.make(sessionLifetime: sessionLifetime, descriptor: descriptor, transcript: transcript)
    }
    var count: UInt16 { descriptor.count }
    var capacity: UInt16 { descriptor.capacity }
    var retainedIdentitySlots: Int { switch descriptor {
        case .static(let p, _, _): p.pointee.retainedIdentitySlots
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.retainedIdentitySlots
        #endif
    } }
    var retainedPayloadBytes: Int { switch descriptor {
        case .static(let p, _, _): p.pointee.retainedPayloadBytes
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.retainedPayloadBytes
        #endif
    } }
    mutating func reset() { switch descriptor { case .static(let p, _, _): p.pointee.reset()
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.reset()
        #endif
    } }
    borrowing func region(at index: UInt16) -> InteractionHitRegion<SemanticCompleteIdentity>? { switch descriptor {
        case .static(let p, _, _): p.pointee.region(at: index)
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.region(at: index)
        #endif
    } }
    mutating func append(_ region: consuming InteractionHitRegion<SemanticCompleteIdentity>) -> Bool { switch descriptor {
        case .static(let p, _, _): p.pointee.append(region)
        #if !hasFeature(Embedded)
        case .dynamic(let p, _, _): p.pointee.append(region)
        #endif
    } }
    mutating func exchangeContents(with other: inout Self) {
        precondition(lifetime.matches(other.lifetime) && capacity == other.capacity)
        precondition(descriptor.original.id != other.descriptor.original.id)
        precondition(descriptor.original.address != other.descriptor.original.address)
        let old = descriptor, right = other.descriptor
        let leftCount = count, rightCount = other.count
        descriptor = right; other.descriptor = old
        precondition(descriptor.original.address == right.original.address && other.descriptor.original.address == old.original.address)
        precondition(count == rightCount && other.count == leftCount)
        precondition(descriptor.original.retainedBytes == right.original.retainedBytes && other.descriptor.original.retainedBytes == old.original.retainedBytes)
        transcript?.pointee.record(.init(bankKind: 1, leftBefore: old.original, rightBefore: right.original, leftCount: leftCount, rightCount: rightCount, leftAfter: descriptor.original, rightAfter: other.descriptor.original))
    }
}
fileprivate struct P08StaticGeometryDescriptor {
    let g0: UnsafeMutablePointer<StaticCounterLayoutWorkspace>
    let g1: UnsafeMutablePointer<StaticCounterResolvedLayoutStorage>
    let g2: UnsafeMutablePointer<InlineArray<64, SemanticRecordReference?>>
    let g3: UnsafeMutablePointer<StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>>
    let g4: UnsafeMutablePointer<QualifiedRender>
    let byteCounts: InlineArray<4, Int>
}

#if !hasFeature(Embedded)
fileprivate struct P08DynamicGeometryDescriptor {
    let g0: UnsafeMutablePointer<DynamicLayoutWorkspace>
    let g1: UnsafeMutablePointer<DynamicResolvedLayoutStorage>
    let g3: UnsafeMutablePointer<DynamicDrawingPlanWorkspace>
    let g4: UnsafeMutablePointer<DynamicRenderWorkspace>
}
#endif
fileprivate enum P08GeometryDescriptor {
    case `static`(P08StaticGeometryDescriptor)
    #if !hasFeature(Embedded)
    case dynamic(P08DynamicGeometryDescriptor)
    #endif
}
fileprivate struct P08GeometryAccess: ~Copyable, ~Escapable, CounterGeometry {
    private let lifetime: P08SessionLifetime
    private let descriptor: P08GeometryDescriptor
    @_lifetime(copy sessionLifetime)
    private init(sessionLifetime: borrowing P08SessionLifetime, descriptor: P08GeometryDescriptor) {
        lifetime = copy sessionLifetime; self.descriptor = descriptor
    }
    private enum Factory {
        @_lifetime(copy sessionLifetime)
        static func make(sessionLifetime: borrowing P08SessionLifetime, descriptor: P08GeometryDescriptor) -> P08GeometryAccess {
            P08GeometryAccess(sessionLifetime: sessionLifetime, descriptor: descriptor)
        }
    }
    @_lifetime(copy sessionLifetime)
    fileprivate static func lend(sessionLifetime: borrowing P08SessionLifetime, descriptor: P08GeometryDescriptor) -> Self {
        Factory.make(sessionLifetime: sessionLifetime, descriptor: descriptor)
    }
    borrowing func storageMeasurement() -> CounterGeometryMeasurement {
        switch descriptor {
        case .static(let d):
            return .init(layout: counterLayoutLimits, render: d.g4.pointee.capacity,
                renderWorkspace: d.g4.pointee.structuralCapacity, drawing: d.g3.pointee.capacity,
                layoutBytes: UInt64(d.byteCounts[0] + d.byteCounts[1] + MemoryLayout<StaticCounterLayoutWorkspace>.stride + MemoryLayout<StaticCounterResolvedLayoutStorage>.stride + MemoryLayout<InlineArray<64, SemanticRecordReference?>>.stride),
                renderBytes: UInt64(MemoryLayout<QualifiedRender>.stride), pathBytes: UInt64(d.byteCounts[2]),
                planBytes: UInt64(d.byteCounts[3] + MemoryLayout<StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>>.stride))
        #if !hasFeature(Embedded)
        case .dynamic(let d):
            let layoutInline: UInt64 = UInt64(MemoryLayout<DynamicLayoutWorkspace>.stride + MemoryLayout<DynamicResolvedLayoutStorage>.stride)
            let layoutPayload: UInt64 = d.g0.pointee.reservedPayloadBytes + d.g1.pointee.reservedPayloadBytes
            let layoutBytes: UInt64 = layoutInline + layoutPayload
            let renderInline: UInt64 = UInt64(MemoryLayout<DynamicRenderWorkspace>.stride)
            guard let renderPayload = UInt64(exactly: d.g4.pointee.reservedPayloadBytes) else {
                preconditionFailure("negative Dynamic render payload extent")
            }
            let renderBytes: UInt64 = renderInline + renderPayload
            let pathBytes: UInt64 = d.g3.pointee.livePathReservedPayloadBytes
            let planInline: UInt64 = UInt64(MemoryLayout<DynamicDrawingPlanWorkspace>.stride)
            let planBytes: UInt64 = planInline + d.g3.pointee.planReservedPayloadBytes
            return .init(layout: counterLayoutLimits, render: d.g4.pointee.capacity,
                renderWorkspace: d.g4.pointee.structuralCapacity, drawing: d.g3.pointee.capacity,
                layoutBytes: layoutBytes, renderBytes: renderBytes, pathBytes: pathBytes, planBytes: planBytes)
        #endif
        }
    }
    mutating func layout(_ bank: borrowing SemanticRecordView<CounterPayload>, limits: RuntimeProfileLimits) -> LayoutResult {
        switch descriptor {
        case .static(let d):
            d.g2.pointee = .init(repeating: nil)
                    for index: UInt16 in 0..<bank.recordCount { d.g2.pointee[Int(index)] = bank.reference(at: index) }
                    return GiftUILayout.layout(semantic: LocalSemantic(bank), metrics: GiftUIReferenceTextMetricsView(), proposal: ProposedSize(width: 100, height: 120)!, limits: limits.layout, workspace: &d.g0.pointee, sink: &d.g1.pointee)
        #if !hasFeature(Embedded)
        case .dynamic(let d):
            return GiftUILayout.layout(semantic: SemanticRecordLayoutView(bank), metrics: GiftUIReferenceTextMetricsView(), proposal: ProposedSize(width: 100, height: 120)!, limits: limits.layout, workspace: &d.g0.pointee, sink: &d.g1.pointee)
        #endif
        }
    }
    mutating func draw(source: inout CounterSource, context: ExecutionContext, limits: RuntimeProfileLimits) -> DrawingPlanResult {
        switch descriptor {
        case .static(let d):
            precondition(d.g3.pointee.withBase { $0.configure(limits: limits.drawing) })
                    return CanvasPlanProducer.derive(source: &source, layout: QualifiedLayout(base: d.g1.pointee.renderView, references: d.g2.pointee), executionContext: context, limits: limits.drawing, workspace: &d.g3.pointee)
        #if !hasFeature(Embedded)
        case .dynamic(let d):
            precondition(d.g3.pointee.configure(limits: limits.drawing))
                    return CanvasPlanProducer.derive(source: &source, layout: d.g1.pointee.renderView, executionContext: context, limits: limits.drawing, workspace: &d.g3.pointee)
        #endif
        }
    }
    mutating func preflight(_ bank: borrowing SemanticRecordView<CounterPayload>, limits: RuntimeProfileLimits) -> RenderProductionResult {
        switch descriptor {
        case .static(let d):
            let layout = QualifiedLayout(base: d.g1.pointee.renderView, references: d.g2.pointee)
                    let result = withCounterRenderLimits(&d.g4.pointee, limits: limits) { bounded in CanvasRenderProducer.preflight(semantic: SemanticRecordRenderView(bank), layout: layout, textMetrics: GiftUIReferenceTextMetricsView(), drawingPlan: d.g3.pointee, surfaceBounds: counterSurface, damageMode: .initializeCompleteSurface, rootForeground: .white, limits: limits.render, configuredSinkCapacity: limits.renderSink, workspace: &bounded) }
                    if case .success(let header) = result {
                        guard header.operationCount >= d.g3.pointee.summary.normalizedStrokeOperationCount,
                            header.operationCount - d.g3.pointee.summary.normalizedStrokeOperationCount <= limits.maximumOrdinaryRenderOperations else { return .failure(.capacityExhausted) }
                    }
                    return result
        #if !hasFeature(Embedded)
        case .dynamic(let d):
            let result = withCounterRenderLimits(&d.g4.pointee, limits: limits) { bounded in CanvasRenderProducer.preflight(semantic: SemanticRecordRenderView(bank), layout: d.g1.pointee.renderView, textMetrics: GiftUIReferenceTextMetricsView(), drawingPlan: d.g3.pointee, surfaceBounds: counterSurface, damageMode: .initializeCompleteSurface, rootForeground: .white, limits: limits.render, configuredSinkCapacity: limits.renderSink, workspace: &bounded) }
                    if case .success(let header) = result {
                        guard header.operationCount >= d.g3.pointee.summary.normalizedStrokeOperationCount,
                            header.operationCount - d.g3.pointee.summary.normalizedStrokeOperationCount <= limits.maximumOrdinaryRenderOperations else { return .failure(.capacityExhausted) }
                    }
                    return result
        #endif
        }
    }
    mutating func produce<S: DrawingOperationSink>(_ bank: borrowing SemanticRecordView<CounterPayload>, header: RenderPlanHeader, sink: inout S, limits: RuntimeProfileLimits) -> RenderProductionResult {
        switch descriptor {
        case .static(let d):
            let layout = QualifiedLayout(base: d.g1.pointee.renderView, references: d.g2.pointee)
                    return withCounterRenderLimits(&d.g4.pointee, limits: limits) { bounded in CanvasRenderProducer.produce(semantic: SemanticRecordRenderView(bank), layout: layout, textMetrics: GiftUIReferenceTextMetricsView(), drawingPlan: d.g3.pointee, surfaceBounds: counterSurface, damageMode: .initializeCompleteSurface, rootForeground: .white, limits: limits.render, expectedHeader: header, workspace: &bounded, sink: &sink) }
        #if !hasFeature(Embedded)
        case .dynamic(let d):
            return withCounterRenderLimits(&d.g4.pointee, limits: limits) { bounded in CanvasRenderProducer.produce(semantic: SemanticRecordRenderView(bank), layout: d.g1.pointee.renderView, textMetrics: GiftUIReferenceTextMetricsView(), drawingPlan: d.g3.pointee, surfaceBounds: counterSurface, damageMode: .initializeCompleteSurface, rootForeground: .white, limits: limits.render, expectedHeader: header, workspace: &bounded, sink: &sink) }
        #endif
        }
    }
    func verifyPlan(canvas: SemanticRecordReference, value: UInt8) -> Int {
        switch descriptor {
        case .static(let d):
            counterVerifyPlan(d.g3.pointee, canvas: canvas, bounds: QualifiedLayout(base: d.g1.pointee.renderView, references: d.g2.pointee).bounds(of: canvas)!, value: value)
        #if !hasFeature(Embedded)
        case .dynamic(let d):
            counterVerifyPlan(d.g3.pointee, canvas: canvas, bounds: d.g1.pointee.renderView.bounds(of: canvas)!, value: value)
        #endif
        }
    }
    func bounds(_ record: SemanticRecordReference) -> Rect? {
        switch descriptor {
        case .static(let d):
            QualifiedLayout(base: d.g1.pointee.renderView, references: d.g2.pointee).bounds(of: record)
        #if !hasFeature(Embedded)
        case .dynamic(let d):
            d.g1.pointee.renderView.bounds(of: record)
        #endif
        }
    }
    func clip(_ record: SemanticRecordReference) -> Rect? {
        switch descriptor {
        case .static(let d):
            QualifiedLayout(base: d.g1.pointee.renderView, references: d.g2.pointee).clip(of: record)
        #if !hasFeature(Embedded)
        case .dynamic(let d):
            d.g1.pointee.renderView.clip(of: record)
        #endif
        }
    }
    mutating func resetLayout() {
        switch descriptor {
        case .static(let d):
            d.g1.pointee.discard(); d.g0.pointee.resetLayout(); d.g2.pointee = .init(repeating: nil)
        #if !hasFeature(Embedded)
        case .dynamic(let d):
            d.g0.pointee.resetLayout(); d.g1.pointee.discard()
        #endif
        }
    }
    mutating func resetPlan() {
        switch descriptor {
        case .static(let d):
            d.g3.pointee.discard(); d.g3.pointee.reset()
        #if !hasFeature(Embedded)
        case .dynamic(let d):
            d.g3.pointee.discard(); d.g3.pointee.reset()
        #endif
        }
    }
    mutating func resetRender() {
        switch descriptor {
        case .static(let d):
            d.g4.pointee.reset()
        #if !hasFeature(Embedded)
        case .dynamic(let d):
            d.g4.pointee.reset()
        #endif
        }
    }
    mutating func reset() {
        switch descriptor {
        case .static(let d):
            resetRender(); resetPlan(); resetLayout()
        #if !hasFeature(Embedded)
        case .dynamic(let d):
            resetRender(); resetPlan(); resetLayout()
        #endif
        }
    }
}
private func withCounterRenderLimits<Base: RenderProductionWorkspace>(_ base: inout Base, limits: RuntimeProfileLimits, _ body: (inout CounterConfiguredRender<Base>) -> RenderProductionResult) -> RenderProductionResult {
    precondition(counterRenderWorkspaceCovers(base.structuralCapacity, limits.renderWorkspace))
    return withUnsafeMutablePointer(to: &base) { pointer in
        var bounded = CounterConfiguredRender(base: pointer, capacity: limits.render, structuralCapacity: limits.renderWorkspace)
        return body(&bounded)
    }
}
private struct CounterConfiguredRender<Base: RenderProductionWorkspace>: RenderProductionWorkspace {
    typealias Identity = Base.Identity
    let base: UnsafeMutablePointer<Base>
    let capacity: RenderLimits
    let structuralCapacity: RenderWorkspaceCapacity
    var isActive: Bool { base.pointee.isActive }
    var currentForeground: Color? { base.pointee.currentForeground }
    mutating func acquire() -> Bool { base.pointee.acquire() }
    mutating func visitSemanticScope(at ordinal: UInt16) -> RenderWorkspaceVisit { base.pointee.visitSemanticScope(at: ordinal) }
    mutating func visitLayoutScope(at ordinal: UInt16) -> RenderWorkspaceVisit { base.pointee.visitLayoutScope(at: ordinal) }
    mutating func pushForeground(_ color: Color) -> Bool { base.pointee.pushForeground(color) }
    mutating func popForeground() -> Bool { base.pointee.popForeground() }
    mutating func reset() { base.pointee.reset() }
}


fileprivate typealias P08ScopedKeys = InteractionOwnedKeyState<P08CandidateAccess, P08CommittedAccess, P08HitAccess>
fileprivate struct P08StorageSession: ~Copyable, ~Escapable {
    private var geometry: P08GeometryAccess
    private var interaction: P08ScopedKeys
    private let ownerIdentity: UInt
    private let sessionSerial: UInt64
    borrowing func installProducerOrigin(_ control: UnsafeMutablePointer<CounterControl>) { control.pointee.installProducerOrigin(owner: ownerIdentity, serial: sessionSerial) }
    @_lifetime(copy geometry, copy interaction)
    fileprivate init(geometry: consuming P08GeometryAccess, interaction: consuming P08ScopedKeys, ownerIdentity: UInt, sessionSerial: UInt64) {
        self.geometry = consume geometry; self.interaction = consume interaction
        self.ownerIdentity = ownerIdentity; self.sessionSerial = sessionSerial
    }
    mutating func reset() { geometry.reset(); interaction.resetAllStorage() }
}

extension P08TypedBackingOwner {
    fileprivate mutating func withStorage<Result>(transcript: UnsafeMutablePointer<P08RoleTranscript>? = nil, _ body: (consuming P08StorageSession) -> Result) -> Result {
        precondition(lifecycle == .idle && validateCapacities())
        requireEmpty()
        let next = serial.addingReportingOverflow(1); precondition(!next.overflow)
        serial = next.partialValue; lifecycle = .active
        let ownerIdentity = identity; let sessionSerial = serial
        let regions = inventory; let configuration = capacities; let physical = slots
        func entry(_ id: P08PhysicalID) -> P08InitializedEntry {
            for index in 0..<14 { if let entry = regions[index], entry.id == id { return entry } }
            preconditionFailure("unacquired physical region")
        }
        let result: Result
        switch physical {
        case .static(let s):
            result = s.b0.withBorrow { b0 in
                s.b1.withBorrow { b1 in
                s.b2.withBorrow { b2 in
                s.b3.withBorrow { b3 in
                s.g0.withBorrow { g0 in
                s.g1.withBorrow { g1 in
                s.g2.withBorrow { g2 in
                s.g3.withBorrow { g3 in
                s.g4.withBorrow { g4 in
                s.c0.withBorrow { c0 in
                s.h0.withBorrow { h0 in
                s.r0.withBorrow { r0 in
                s.r1.withBorrow { r1 in
                s.h1.withBorrow { h1 in
                    precondition(UInt(bitPattern: b0.baseAddress!) == entry(.b0).address && UInt(bitPattern: b1.baseAddress!) == entry(.b1).address && UInt(bitPattern: b2.baseAddress!) == entry(.b2).address && UInt(bitPattern: b3.baseAddress!) == entry(.b3).address)
                    precondition(UInt(bitPattern: g0) == entry(.g0).address && UInt(bitPattern: g1) == entry(.g1).address && UInt(bitPattern: g2) == entry(.g2).address && UInt(bitPattern: g3) == entry(.g3).address && UInt(bitPattern: g4) == entry(.g4).address)
                    let token = P08SessionLifetime.lend(owner: self, identity: ownerIdentity, serial: sessionSerial)
                    for pair in [(c0, P08PhysicalID.c0)] { precondition(UInt(bitPattern: pair.0) == entry(pair.1).address) }
                    precondition(UInt(bitPattern: h0) == entry(.h0).address && UInt(bitPattern: r0) == entry(.r0).address && UInt(bitPattern: r1) == entry(.r1).address && UInt(bitPattern: h1) == entry(.h1).address)
                    let geometry = P08GeometryAccess.lend(sessionLifetime: token, descriptor: .static(.init(g0: g0, g1: g1, g2: g2, g3: g3, g4: g4, byteCounts: [b0.count, b1.count, b2.count, b3.count])))
                    let c0Access = P08CandidateAccess.lend(sessionLifetime: token, descriptor: .static(c0, entry(.c0), configuration[0]))
                    let h0Access = P08HitAccess.lend(sessionLifetime: token, descriptor: .static(h0, entry(.h0), configuration[1]), transcript: transcript)
                    let r0Access = P08CommittedAccess.lend(sessionLifetime: token, descriptor: .static(r0, entry(.r0), configuration[2]), transcript: transcript)
                    let r1Access = P08CommittedAccess.lend(sessionLifetime: token, descriptor: .static(r1, entry(.r1), configuration[3]), transcript: transcript)
                    let h1Access = P08HitAccess.lend(sessionLifetime: token, descriptor: .static(h1, entry(.h1), configuration[4]), transcript: transcript)
                    let state = InteractionState(candidateRecords: c0Access, candidateHitRegions: h0Access, candidateCommittedRecords: r0Access, committedRecords: r1Access, committedHitRegions: h1Access)
                    let interaction = P08ScopedKeys(state: state, maximumComponentsPerKey: 24, maximumComponents: 48)!
                    return body(P08StorageSession(geometry: geometry, interaction: interaction, ownerIdentity: ownerIdentity, sessionSerial: sessionSerial))
                }
                }
                }
                }
                }
                }
                }
                }
                }
                }
                }
                }
                }
                }
        #if !hasFeature(Embedded)
        case .dynamic(let s):
            result = s.g0.withBorrow { g0 in
                s.g1.withBorrow { g1 in
                s.g3.withBorrow { g3 in
                s.g4.withBorrow { g4 in
                s.c0.withBorrow { c0 in
                s.h0.withBorrow { h0 in
                s.r0.withBorrow { r0 in
                s.r1.withBorrow { r1 in
                s.h1.withBorrow { h1 in
                    precondition(UInt(bitPattern: g0) == entry(.g0).address && UInt(bitPattern: g1) == entry(.g1).address && UInt(bitPattern: g3) == entry(.g3).address && UInt(bitPattern: g4) == entry(.g4).address)
                    let token = P08SessionLifetime.lend(owner: self, identity: ownerIdentity, serial: sessionSerial)
                    precondition(UInt(bitPattern: c0) == entry(.c0).address && UInt(bitPattern: h0) == entry(.h0).address && UInt(bitPattern: r0) == entry(.r0).address && UInt(bitPattern: r1) == entry(.r1).address && UInt(bitPattern: h1) == entry(.h1).address)
                    let geometry = P08GeometryAccess.lend(sessionLifetime: token, descriptor: .dynamic(.init(g0: g0, g1: g1, g3: g3, g4: g4)))
                    let c0Access = P08CandidateAccess.lend(sessionLifetime: token, descriptor: .dynamic(c0, entry(.c0), configuration[0]))
                    let h0Access = P08HitAccess.lend(sessionLifetime: token, descriptor: .dynamic(h0, entry(.h0), configuration[1]), transcript: transcript)
                    let r0Access = P08CommittedAccess.lend(sessionLifetime: token, descriptor: .dynamic(r0, entry(.r0), configuration[2]), transcript: transcript)
                    let r1Access = P08CommittedAccess.lend(sessionLifetime: token, descriptor: .dynamic(r1, entry(.r1), configuration[3]), transcript: transcript)
                    let h1Access = P08HitAccess.lend(sessionLifetime: token, descriptor: .dynamic(h1, entry(.h1), configuration[4]), transcript: transcript)
                    let state = InteractionState(candidateRecords: c0Access, candidateHitRegions: h0Access, candidateCommittedRecords: r0Access, committedRecords: r1Access, committedHitRegions: h1Access)
                    let interaction = P08ScopedKeys(state: state, maximumComponentsPerKey: 24, maximumComponents: 48)!
                    return body(P08StorageSession(geometry: geometry, interaction: interaction, ownerIdentity: ownerIdentity, sessionSerial: sessionSerial))
                }
                }
                }
                }
                }
                }
                }
                }
                }
        #endif
        }
        // Capability/token/pointee borrows end before reaccessing the actual owner.
        requireEmpty(); lifecycle = .idle
        return result
    }
}
fileprivate func withP08Storage<Result>(backing: inout P08TypedBackingOwner,
    _ body: (consuming P08StorageSession) -> Result) -> Result {
    backing.withStorage(body)
}
fileprivate func withP08R1Reservation<T, Result>(
    _ reservation: UnsafeMutablePointer<P08PaddedReservation<T>>, surplus: Bool,
    _ body: (P08TypedSlot<T>) -> Result
) -> Result {
    if surplus { return body(.padded(reservation)) }
    return withUnsafeMutablePointer(to: &reservation.pointee.slot) { slot in
        body(.native(slot))
    }
}
// Occupy G4's native stride tail with a real typed field so the next stored
// Optional cannot reuse it. The complete wrapper is charged by the enclosing
// reservation metadata; the G4 descriptor retains its unchanged Optional stride.
fileprivate struct P08StaticRenderReservation {
    var slot: QualifiedRender? = nil
    private let strideTail: UInt32 = 0
    init() {}
}
fileprivate struct P08StaticReservation: ~Copyable {
    var b0: InlineArray<1024, UInt8>? = nil
    var b1: InlineArray<1056, UInt8>? = nil
    var b2: InlineArray<20, UInt8>? = nil
    var b3: InlineArray<112, UInt8>? = nil
    var g0: StaticCounterLayoutWorkspace? = nil
    var g1: StaticCounterResolvedLayoutStorage? = nil
    var g2: InlineArray<64, SemanticRecordReference?>? = nil
    var g3: StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>? = nil
    var g4: P08StaticRenderReservation = .init()
    var c0: CounterStaticCandidate? = nil
    var h0: CounterStaticHits? = nil
    var r0: CounterStaticCommitted? = nil
    var r1: P08PaddedReservation<CounterStaticCommitted> = .init()
    var h1: CounterStaticHits? = nil
}
fileprivate func withP08StaticReservation<Result>(surplus: Bool = false, capacities: InlineArray<5, UInt16> = [2, 2, 2, 2, 2], _ body: (inout P08TypedBackingOwner) -> Result) -> Result {
    precondition(MemoryLayout<P08StaticRenderReservation>.size == MemoryLayout<P08StaticRenderReservation>.stride)
    precondition(MemoryLayout<P08StaticRenderReservation>.alignment == MemoryLayout<QualifiedRender?>.alignment)
    precondition(MemoryLayout<P08StaticRenderReservation>.size >= MemoryLayout<QualifiedRender?>.stride)
    var reservation = P08StaticReservation()
    return withUnsafeMutablePointer(to: &reservation.b0) { b0 in
        withUnsafeMutablePointer(to: &reservation.b1) { b1 in
        withUnsafeMutablePointer(to: &reservation.b2) { b2 in
        withUnsafeMutablePointer(to: &reservation.b3) { b3 in
        withUnsafeMutablePointer(to: &reservation.g0) { g0 in
        withUnsafeMutablePointer(to: &reservation.g1) { g1 in
        withUnsafeMutablePointer(to: &reservation.g2) { g2 in
        withUnsafeMutablePointer(to: &reservation.g3) { g3 in
        withUnsafeMutablePointer(to: &reservation.g4) { g4Reservation in
        withUnsafeMutablePointer(to: &g4Reservation.pointee.slot) { g4 in
            let reservationStart = UInt(bitPattern: g4Reservation)
            let reservationEnd = reservationStart.addingReportingOverflow(UInt(MemoryLayout<P08StaticRenderReservation>.size))
            let slotStart = UInt(bitPattern: g4)
            let slotEnd = slotStart.addingReportingOverflow(UInt(MemoryLayout<QualifiedRender?>.stride))
            precondition(!reservationEnd.overflow && !slotEnd.overflow && slotStart >= reservationStart && slotEnd.partialValue <= reservationEnd.partialValue)
        return withUnsafeMutablePointer(to: &reservation.c0) { c0 in
        withUnsafeMutablePointer(to: &reservation.h0) { h0 in
        withUnsafeMutablePointer(to: &reservation.r0) { r0 in
        withUnsafeMutablePointer(to: &reservation.r1) { r1Reservation in
        withP08R1Reservation(r1Reservation, surplus: surplus) { r1 in
        withUnsafeMutablePointer(to: &reservation.h1) { h1 in
            var owner = P08TypedBackingOwner(slots: .static(.init(b0: .scopes(b0), b1: .text(b1), b2: .path(b2), b3: .plan(b3), g0: .native(g0), g1: .native(g1), g2: .native(g2), g3: .native(g3), g4: .native(g4), c0: .native(c0), h0: .native(h0), r0: .native(r0), r1: r1, h1: .native(h1))), identity: UInt(bitPattern: b0), capacities: capacities)
            return body(&owner)
        }
        }
        }
        }
        }
        }
        }
        }
        }
        }
        }
        }
        }
        }        } }
}


#if !hasFeature(Embedded)
fileprivate struct P08DynamicReservation: ~Copyable {
    var g0: DynamicLayoutWorkspace? = nil
    var g1: DynamicResolvedLayoutStorage? = nil
    var g3: DynamicDrawingPlanWorkspace? = nil
    var g4: DynamicRenderWorkspace? = nil
    var c0: CounterDynamicCandidate? = nil
    var h0: CounterDynamicHits? = nil
    var r0: CounterDynamicCommitted? = nil
    var r1: P08PaddedReservation<CounterDynamicCommitted> = .init()
    var h1: CounterDynamicHits? = nil
}
fileprivate func withP08DynamicReservation<Result>(surplus: Bool = false, capacities: InlineArray<5, UInt16> = [2, 2, 2, 2, 2], _ body: (inout P08TypedBackingOwner) -> Result) -> Result {
    var reservation = P08DynamicReservation()
    return withUnsafeMutablePointer(to: &reservation.g0) { g0 in
        withUnsafeMutablePointer(to: &reservation.g1) { g1 in
        withUnsafeMutablePointer(to: &reservation.g3) { g3 in
        withUnsafeMutablePointer(to: &reservation.g4) { g4 in
        withUnsafeMutablePointer(to: &reservation.c0) { c0 in
        withUnsafeMutablePointer(to: &reservation.h0) { h0 in
        withUnsafeMutablePointer(to: &reservation.r0) { r0 in
        withUnsafeMutablePointer(to: &reservation.r1) { r1Reservation in
        withP08R1Reservation(r1Reservation, surplus: surplus) { r1 in
        withUnsafeMutablePointer(to: &reservation.h1) { h1 in
            var owner = P08TypedBackingOwner(slots: .dynamic(.init(g0: .native(g0), g1: .native(g1), g3: .native(g3), g4: .native(g4), c0: .native(c0), h0: .native(h0), r0: .native(r0), r1: r1, h1: .native(h1))), identity: UInt(bitPattern: g0), capacities: capacities)
            return body(&owner)
        }
        }
        }
        }
        }
        }
        }
        }
        }        }
}

#endif

#if hasFeature(Embedded)
fileprivate struct P08EmbeddedOuter: ~Copyable {
    let limits: UnsafeMutablePointer<RuntimeProfileLimits>
    let root: UnsafeMutablePointer<StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>>
    let semantic: UnsafeMutablePointer<StaticSemanticRecordStorage>
    let records: UnsafeMutablePointer<SemanticRuntimeRecord>
    let paths: UnsafeMutablePointer<SemanticPathEntry>
    let payloads: UnsafeMutablePointer<CounterPayload?>
    let scalars: UnsafeMutablePointer<UInt32>
    let canvas: UnsafeMutablePointer<StaticCanvasValueStorage>
    let entries: UnsafeMutablePointer<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>
    let control: UnsafeMutablePointer<CounterControl>
    let used: UnsafeMutablePointer<Bool>
    private var acquired: UInt8 = 0
    let layout: CounterEmbeddedLayout
    let bytes: UnsafeMutableRawBufferPointer
    init(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity,
        backing: UnsafeMutableRawBufferPointer, limits: RuntimeProfileLimits, surplus: Int = 0) {
        guard let layout = CounterEmbeddedLayout(suppliedByteCount: backing.count, r1Surplus: surplus), backing.count >= counterEmbeddedSlotBytes else { preconditionFailure("provisional Embedded reservation mismatch") }
        self.layout = layout; bytes = backing
        // The complete checked layout is disjoint and aligned before any bind/init.
        for index in 0..<25 {
            let region = layout.regions[index]!
            let address = UInt(bitPattern: backing.baseAddress!).addingReportingOverflow(UInt(region.offset))
            precondition(!address.overflow && address.partialValue % UInt(region.alignment) == 0)
        }
        self.limits = counterEmbeddedField(backing, RuntimeProfileLimits.self, region: layout.regions[0]!)
        root = counterEmbeddedField(backing, StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>.self, region: layout.regions[1]!)
        semantic = counterEmbeddedField(backing, StaticSemanticRecordStorage.self, region: layout.regions[2]!)
        records = counterEmbeddedField(backing, SemanticRuntimeRecord.self, region: layout.regions[3]!)
        paths = counterEmbeddedField(backing, SemanticPathEntry.self, region: layout.regions[4]!)
        payloads = counterEmbeddedField(backing, CounterPayload?.self, region: layout.regions[5]!)
        scalars = counterEmbeddedField(backing, UInt32.self, region: layout.regions[6]!)
        canvas = counterEmbeddedField(backing, StaticCanvasValueStorage.self, region: layout.regions[7]!)
        entries = counterEmbeddedField(backing, CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?.self, region: layout.regions[8]!)
        control = counterEmbeddedField(backing, CounterControl.self, region: layout.regions[23]!)
        used = counterEmbeddedField(backing, Bool.self, region: layout.regions[24]!)
        self.limits.initialize(to: limits); acquired = 1
        root.initialize(to: StaticObservableRootAdapter(identity: modelOwner, schema: 1, needsCapture: false, modelLimit: min(2, max(1, limits.models.maximumModelSlots)), claimLimit: min(4, max(1, limits.models.maximumOwningTickets)), pinLimit: min(2, max(1, limits.models.maximumFramePins)), captureLimit: 0)!); acquired = 2
        semantic.initialize(to: StaticSemanticRecordStorage(limits: counterSemanticLimits, owner: semanticOwner)); acquired = 3
        for index in 0..<128 { records.advanced(by: index).initialize(to: .init()) }; acquired = 4
        for index in 0..<384 { paths.advanced(by: index).initialize(to: .init()) }; acquired = 5
        for index in 0..<256 { payloads.advanced(by: index).initialize(to: nil) }; acquired = 6
        for index in 0..<128 { scalars.advanced(by: index).initialize(to: 0) }; acquired = 7
        canvas.initialize(to: StaticCanvasValueStorage()); acquired = 8
        entries.initialize(to: nil); acquired = 9
        control.initialize(to: CounterControl()); acquired = 10
        used.initialize(to: false); acquired = 11
    }
    deinit {
        if acquired >= 11 { used.deinitialize(count: 1) }
        if acquired >= 10 { control.deinitialize(count: 1) }
        if acquired >= 9 { entries.deinitialize(count: 1) }
        if acquired >= 8 { canvas.deinitialize(count: 1) }
        if acquired >= 7 { scalars.deinitialize(count: 128) }
        if acquired >= 6 { payloads.deinitialize(count: 256) }
        if acquired >= 5 { paths.deinitialize(count: 384) }
        if acquired >= 4 { records.deinitialize(count: 128) }
        if acquired >= 3 { semantic.deinitialize(count: 1) }
        if acquired >= 2 { root.deinitialize(count: 1) }
        if acquired >= 1 { limits.deinitialize(count: 1) }
    }
    func storageSlots(r0Extent: Int? = nil) -> P08StaticSlots {
        .init(b0: .embedded(.init(start: counterEmbeddedField(bytes, UInt8.self, region: layout.regions[9]!), count: layout.regions[9]!.count), layout.regions[9]!.extent),
            b1: .embedded(.init(start: counterEmbeddedField(bytes, UInt8.self, region: layout.regions[10]!), count: layout.regions[10]!.count), layout.regions[10]!.extent),
            b2: .embedded(.init(start: counterEmbeddedField(bytes, UInt8.self, region: layout.regions[11]!), count: layout.regions[11]!.count), layout.regions[11]!.extent),
            b3: .embedded(.init(start: counterEmbeddedField(bytes, UInt8.self, region: layout.regions[12]!), count: layout.regions[12]!.count), layout.regions[12]!.extent),
            g0: .embedded(counterEmbeddedField(bytes, StaticCounterLayoutWorkspace.self, region: layout.regions[13]!), layout.regions[13]!.extent),
            g1: .embedded(counterEmbeddedField(bytes, StaticCounterResolvedLayoutStorage.self, region: layout.regions[14]!), layout.regions[14]!.extent),
            g2: .embedded(counterEmbeddedField(bytes, InlineArray<64, SemanticRecordReference?>.self, region: layout.regions[15]!), layout.regions[15]!.extent),
            g3: .embedded(counterEmbeddedField(bytes, StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>.self, region: layout.regions[16]!), layout.regions[16]!.extent),
            g4: .embedded(counterEmbeddedField(bytes, QualifiedRender.self, region: layout.regions[17]!), layout.regions[17]!.extent),
            c0: .embedded(counterEmbeddedField(bytes, CounterStaticCandidate.self, region: layout.regions[18]!), layout.regions[18]!.extent),
            h0: .embedded(counterEmbeddedField(bytes, CounterStaticHits.self, region: layout.regions[19]!), layout.regions[19]!.extent),
            r0: .embedded(counterEmbeddedField(bytes, CounterStaticCommitted.self, region: layout.regions[20]!), (r0Extent ?? layout.regions[20]!.extent)),
            r1: .embedded(counterEmbeddedField(bytes, CounterStaticCommitted.self, region: layout.regions[21]!), layout.regions[21]!.extent),
            h1: .embedded(counterEmbeddedField(bytes, CounterStaticHits.self, region: layout.regions[22]!), layout.regions[22]!.extent))
    }
}
#endif

fileprivate struct P08OwnedPhysicalFacts {
    let geometry: CounterGeometryMeasurement
    let geometryRegions: CounterPhysicalGeometryFacts
    let interaction: CounterPhysicalInteractionFacts
}
extension P08TypedBackingOwner {
    fileprivate borrowing func physicalFacts() -> P08OwnedPhysicalFacts {
        precondition(lifecycle == .idle)
        func entry(_ id: P08PhysicalID) -> P08InitializedEntry {
            for index in 0..<acquired { if inventory[index]!.id == id { return inventory[index]! } }
            preconditionFailure("missing original physical facts")
        }
        var rows = CounterPhysicalGeometryFacts()
        func object(_ id: P08PhysicalID, family: Int, payload: Int = 0) {
            let e = entry(id)
            let objectBytes = e.count.multipliedReportingOverflow(by: e.stride)
            precondition(!objectBytes.overflow && e.retainedBytes >= objectBytes.partialValue + payload)
            rows.append(.init(family: family, kind: .inlineValue, count: e.count, size: e.size, stride: e.stride, alignment: e.alignment, chargedBytes: UInt64(objectBytes.partialValue)))
            rows.append(.elements(UInt8.self, count: e.retainedBytes - objectBytes.partialValue - payload, family: family))
        }
        let banks: CounterPhysicalInteractionFacts
        switch slots {
        case .static(let s):
            for id in [P08PhysicalID.b0, .b1, .g0, .g1, .g2] { object(id, family: 12) }
            object(.g4, family: 13); object(.b2, family: 15); object(.b3, family: 16); object(.g3, family: 16)
            banks = .init(
                candidate: s.c0.withBorrow { CounterPhysicalBankFacts.owned($0.pointee, record: InteractionCandidateRecord<SemanticCompleteIdentity>?.self, optionalRecords: true, retainedBytes: entry(.c0).retainedBytes) },
                candidateHits: s.h0.withBorrow { CounterPhysicalBankFacts.owned($0.pointee, record: InteractionHitRegion<SemanticCompleteIdentity>?.self, optionalRecords: true, retainedBytes: entry(.h0).retainedBytes) },
                prepared: s.r0.withBorrow { CounterPhysicalBankFacts.owned($0.pointee, record: BoundActionRecord<SemanticCompleteIdentity>?.self, optionalRecords: true, retainedBytes: entry(.r0).retainedBytes) },
                committed: s.r1.withBorrow { CounterPhysicalBankFacts.owned($0.pointee, record: BoundActionRecord<SemanticCompleteIdentity>?.self, optionalRecords: true, retainedBytes: entry(.r1).retainedBytes) },
                committedHits: s.h1.withBorrow { CounterPhysicalBankFacts.owned($0.pointee, record: InteractionHitRegion<SemanticCompleteIdentity>?.self, optionalRecords: true, retainedBytes: entry(.h1).retainedBytes) },
                stateMetadataBytes: MemoryLayout<P08ScopedKeys>.size - MemoryLayout<P08CandidateAccess>.size - 2 * MemoryLayout<P08CommittedAccess>.size - 2 * MemoryLayout<P08HitAccess>.size)
        #if !hasFeature(Embedded)
        case .dynamic(let s):
            s.g0.withBorrow { p in
                object(.g0, family: 12, payload: Int(p.pointee.reservedPayloadBytes))
                p.pointee.visitRetainedPayloadExtents { count, size, stride, alignment in rows.append(.init(family: 12, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CounterExtent(count: count, stride: stride, alignment: alignment).bytes!)) }
            }
            s.g1.withBorrow { p in
                object(.g1, family: 12, payload: Int(p.pointee.reservedPayloadBytes))
                p.pointee.visitRetainedPayloadExtents { count, size, stride, alignment in rows.append(.init(family: 12, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CounterExtent(count: count, stride: stride, alignment: alignment).bytes!)) }
            }
            s.g4.withBorrow { p in
                object(.g4, family: 13, payload: Int(p.pointee.reservedPayloadBytes))
                p.pointee.visitRetainedPayloadExtents { count, size, stride, alignment in rows.append(.init(family: 13, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CounterExtent(count: count, stride: stride, alignment: alignment).bytes!)) }
            }
            s.g3.withBorrow { p in
                object(.g3, family: 16, payload: Int(p.pointee.livePathReservedPayloadBytes + p.pointee.planReservedPayloadBytes))
                p.pointee.visitRetainedPathExtents { count, size, stride, alignment in rows.append(.init(family: 15, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CounterExtent(count: count, stride: stride, alignment: alignment).bytes!)) }
                p.pointee.visitRetainedPlanExtents { count, size, stride, alignment in rows.append(.init(family: 16, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CounterExtent(count: count, stride: stride, alignment: alignment).bytes!)) }
            }
            banks = .init(
                candidate: s.c0.withBorrow { CounterPhysicalBankFacts.owned($0.pointee, record: InteractionCandidateRecord<SemanticCompleteIdentity>.self, optionalRecords: false, retainedBytes: entry(.c0).retainedBytes) },
                candidateHits: s.h0.withBorrow { CounterPhysicalBankFacts.owned($0.pointee, record: InteractionHitRegion<SemanticCompleteIdentity>.self, optionalRecords: false, retainedBytes: entry(.h0).retainedBytes) },
                prepared: s.r0.withBorrow { CounterPhysicalBankFacts.owned($0.pointee, record: BoundActionRecord<SemanticCompleteIdentity>.self, optionalRecords: false, retainedBytes: entry(.r0).retainedBytes) },
                committed: s.r1.withBorrow { CounterPhysicalBankFacts.owned($0.pointee, record: BoundActionRecord<SemanticCompleteIdentity>.self, optionalRecords: false, retainedBytes: entry(.r1).retainedBytes) },
                committedHits: s.h1.withBorrow { CounterPhysicalBankFacts.owned($0.pointee, record: InteractionHitRegion<SemanticCompleteIdentity>.self, optionalRecords: false, retainedBytes: entry(.h1).retainedBytes) },
                stateMetadataBytes: MemoryLayout<P08ScopedKeys>.size - MemoryLayout<P08CandidateAccess>.size - 2 * MemoryLayout<P08CommittedAccess>.size - 2 * MemoryLayout<P08HitAccess>.size)
        #endif
        }
        var totals: InlineArray<26, UInt64> = .init(repeating: 0)
        rows.visitStorageRegions { row in
            let next = totals[row.family].addingReportingOverflow(row.chargedBytes)
            precondition(!next.overflow); totals[row.family] = next.partialValue
        }
        let geometry = CounterGeometryMeasurement(layout: counterLayoutLimits, render: counterRenderLimits, renderWorkspace: counterRenderCapacity, drawing: counterDrawingLimits,
            layoutBytes: totals[12], renderBytes: totals[13], pathBytes: totals[15], planBytes: totals[16])
        return .init(geometry: geometry, geometryRegions: rows, interaction: banks)
    }
}

// Only the two concrete counter owners conform; observations are owned facts.
fileprivate protocol P08ReuseObservation: ~Copyable, ~Escapable {
    var teardownStep: UInt8 { get }
    borrowing func observeModelValue() -> UInt8
    borrowing func observeProducedAction() -> CounterProducedAction
    borrowing func prepareProducedAction(_ action: CounterProducedAction) -> Bool
    borrowing func deliverProducedAction(_ action: CounterProducedAction) -> Bool
    borrowing func observeApplicationProducer() -> CounterApplicationOwners
}
extension CounterHostOwner: P08ReuseObservation
where Geometry: CounterGeometry & ~Copyable & ~Escapable,
      Candidate: CounterCandidateBacking & ~Copyable & ~Escapable,
      Committed: CounterCommittedBacking & ~Copyable & ~Escapable,
      Hits: CounterHitBacking & ~Copyable & ~Escapable,
      Candidate.Identity == SemanticCompleteIdentity, Committed.Identity == SemanticCompleteIdentity,
      Hits.Identity == SemanticCompleteIdentity {}
#if !hasFeature(Embedded)
extension CounterDynamicHostOwner: P08ReuseObservation
where Geometry: CounterGeometry & ~Copyable & ~Escapable,
      Candidate: CounterCandidateBacking & ~Copyable & ~Escapable,
      Committed: CounterCommittedBacking & ~Copyable & ~Escapable,
      Hits: CounterHitBacking & ~Copyable & ~Escapable,
      Candidate.Identity == SemanticCompleteIdentity, Committed.Identity == SemanticCompleteIdentity,
      Hits.Identity == SemanticCompleteIdentity {}
#endif
fileprivate struct P08HostReuseTranscript {
    var action: CounterProducedAction?
    var event: NormalizedPointerEvent?
    var admission: CounterAdmission?
    var application: CounterApplicationOwners?
    var semanticRevision: SemanticRevision?
    var hosts = 0
    mutating func endRetainedObservations() {
        precondition(hosts == 2)
        action = nil; event = nil; admission = nil; application = nil; semanticRevision = nil
    }
}
fileprivate func p08ReuseLabel(_ route: StaticString, _ suffix: StaticString) {
    #if !hasFeature(Embedded)
    print("so06-reuse-\(route)-\(suffix)")
    #endif
}
fileprivate func p08RequireFreshControl(_ control: UnsafeMutablePointer<CounterControl>) {
    precondition(control.pointee.admissionController == nil && control.pointee.wake == nil && control.pointee.scheduler == nil)
    precondition(control.pointee.lastSealedAction == nil && control.pointee.lastDispatchedAction == nil && control.pointee.lastDispatchContext == nil && control.pointee.actionDispatches == 0)
    precondition(!control.pointee.inputGate.inputIsEligible && !control.pointee.wakeEnabled && control.pointee.finalized == 0)
}
fileprivate func p08RequireRetiredControl(_ control: UnsafeMutablePointer<CounterControl>) {
    precondition(control.pointee.unavailable && !control.pointee.inputGate.inputIsEligible && !control.pointee.wakeEnabled)
    precondition(control.pointee.observationsInstalled == control.pointee.observationsDetached)
    if var scheduler = control.pointee.scheduler {
        precondition(scheduler.begin(at: control.pointee.wakeClockMicroseconds, lifecycleState: .active, assemblyReport: scheduler.assemblyReport) == .rejected(.pacingRejected, pacing: .unavailable))
    }
    precondition(control.pointee.snapshotProducerOrigin() == nil && !control.pointee.frameActive && !control.pointee.hasRoot)
    precondition(control.pointee.admission.pointerCount == 0 && control.pointee.admission.pendingStateCount == 0 && !control.pointee.admission.sealActive)
}
fileprivate func p08RequireSameInventory(_ current: InlineArray<14, P08InitializedEntry?>, _ original: InlineArray<14, P08InitializedEntry?>) {
    for index in 0..<14 { precondition(current[index] == original[index]) }
}
fileprivate struct P08ReuseFingerprint: Equatable {
    let joins: CounterJoinSnapshot
    let context: ExecutionContext
    let capture: CapturedAction<SemanticCompleteIdentity>?
    let source: InputSourceID?
    let sequence: InputSourceSequenceState
    let presentation: PresentationRevision?
    let semantic: CounterSemanticSnapshot
    let dirty: Bool
    let admission: CounterAdmissionBacking
    let controllerContext: ExecutionContext?
    let controllerPresentation: PresentationRevision?
    let controllerQuiescent: Bool?
    let controllerSeal: Bool?
    let controllerDeferred: Bool?
    let schedulerNow: HostScheduledOpportunityBeginResult?
    let schedulerDeadline: HostScheduledOpportunityBeginResult?
    let wakeTakes: Int
    let disabledWakeRejections: Int
    let applicationCallbacks: Int
    let observationsInstalled: Int
    let observationsDetached: Int
    let reentrantApplicationRejections: Int
    let stoppedApplicationChecks: Int
    let lastSealedAction: CapturedAction<SemanticCompleteIdentity>?
    let lastDispatchedAction: CapturedAction<SemanticCompleteIdentity>?
    let lastDispatchContext: ExecutionContext?
    let actionDispatches: Int
    init(_ control: UnsafeMutablePointer<CounterControl>) {
        joins = counterJoinSnapshot(control); context = control.pointee.context
        capture = control.pointee.runtime.pointer.capture.current; source = control.pointee.runtime.pointer.source
        sequence = control.pointee.runtime.pointer.sequence
        presentation = control.pointee.runtime.committedPresentation; semantic = control.pointee.semanticSnapshot
        dirty = control.pointee.runtime.changed
        admission = control.pointee.admission
        controllerContext = control.pointee.admissionController?.context
        controllerPresentation = control.pointee.admissionController?.committedPresentationRevision
        controllerQuiescent = control.pointee.admissionController?.isQuiescent
        controllerSeal = control.pointee.admissionController?.isSealClosed
        controllerDeferred = control.pointee.admissionController?.didDeferAfterSeal
        var now = control.pointee.scheduler, deadline = control.pointee.scheduler
        let schedulerReport = control.pointee.scheduler?.assemblyReport
        let boundary = control.pointee.wakeClockMicroseconds.addingReportingOverflow(250000)
        precondition(!boundary.overflow)
        schedulerNow = now?.begin(at: control.pointee.wakeClockMicroseconds, lifecycleState: .active, assemblyReport: schedulerReport!)
        schedulerDeadline = deadline?.begin(at: boundary.partialValue, lifecycleState: .active, assemblyReport: schedulerReport!)
        wakeTakes = control.pointee.wakeTakes; disabledWakeRejections = control.pointee.disabledWakeRejections
        applicationCallbacks = control.pointee.applicationCallbacks
        observationsInstalled = control.pointee.observationsInstalled; observationsDetached = control.pointee.observationsDetached
        reentrantApplicationRejections = control.pointee.reentrantApplicationRejections
        stoppedApplicationChecks = control.pointee.stoppedApplicationChecks
        lastSealedAction = control.pointee.lastSealedAction; lastDispatchedAction = control.pointee.lastDispatchedAction
        lastDispatchContext = control.pointee.lastDispatchContext; actionDispatches = control.pointee.actionDispatches
    }
}
fileprivate func p08RunReuseHost<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, control: UnsafeMutablePointer<CounterControl>, transcript: UnsafeMutablePointer<P08HostReuseTranscript>) -> Int
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    let route: StaticString = host.assemblyReport.profile == .static ? "static" : "dynamic"
    guard case .active = host.activate() else { preconditionFailure("reuse actual activation") }
    precondition(control.pointee.inputGate.inputIsEligible && control.pointee.wake != nil && control.pointee.scheduler != nil)
    guard case .cycle(.success) = host.runOpportunity() else { preconditionFailure("reuse source initial fact") }
    var count = counterCheckHostFrame(control.pointee, value: 0)
    let action = host.owner.observeProducedAction()
    var admission = CounterAdmission(borrowing: control)
    let revision = control.pointee.runtime.committedPresentation!
    if transcript.pointee.hosts == 1 {
        let oldAction = transcript.pointee.action!, oldEvent = transcript.pointee.event!
        precondition(action.captured == oldAction.captured && action.targetGeneration == oldAction.targetGeneration && action.targetIdentity == oldAction.targetIdentity)
        precondition(control.pointee.context.semanticRevision == transcript.pointee.semanticRevision)
        precondition(oldEvent.source == .init(rawValue: 0) && oldEvent.sequence.rawValue == 0 && oldEvent.ordinal.rawValue == 0 && oldEvent.presentationRevision == revision)
        p08ReuseLabel(route, "raw-namespace-collision")
        let modelBefore = host.owner.observeModelValue()
        let before = P08ReuseFingerprint(control)
        precondition(!host.owner.prepareProducedAction(oldAction))
        precondition(P08ReuseFingerprint(control) == before && host.owner.observeModelValue() == modelBefore)
        precondition(!host.owner.deliverProducedAction(oldAction))
        precondition(P08ReuseFingerprint(control) == before && host.owner.observeModelValue() == modelBefore); count += counterCheckHostFrame(control.pointee, value: 0)
        p08ReuseLabel(route, "action-stale")
        precondition(transcript.pointee.admission!.submit(pointer: oldEvent).result == .unavailable)
        precondition(P08ReuseFingerprint(control) == before && host.owner.observeModelValue() == modelBefore)
        p08ReuseLabel(route, "input-stale")
        precondition(transcript.pointee.admission!.submit(pointer: oldEvent).result == .unavailable)
        precondition(transcript.pointee.admission!.submit(stateChange: 8).result == .unavailable)
        precondition(transcript.pointee.admission!.submit(completion: 0).result == .unavailable)
        precondition(P08ReuseFingerprint(control) == before && host.owner.observeModelValue() == modelBefore)
        p08ReuseLabel(route, "admission-stale")
        precondition(!transcript.pointee.application!.constructedProjectionIsValid)
        precondition(!transcript.pointee.application!.serviceSource(value: 8))
        precondition(!transcript.pointee.application!.startSource())
        _ = transcript.pointee.application!.installObservation()
        transcript.pointee.application!.stopDelivery()
        precondition(P08ReuseFingerprint(control) == before && host.owner.observeModelValue() == modelBefore)
        p08ReuseLabel(route, "source-stale")
    }
    let down = control.pointee.inputGate.submit(phase: .down, position: control.pointee.actionPoints[0], source: .init(rawValue: 0), observedPresentationRevision: revision, isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &admission)
    let up = control.pointee.inputGate.submit(phase: .up, position: control.pointee.actionPoints[0], source: .init(rawValue: 0), observedPresentationRevision: revision, isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &admission)
    guard case .queued(let downEvent) = down, case .queued(let upEvent) = up else { preconditionFailure("reuse actual normalized input") }
    precondition(downEvent.sequence.rawValue == 0 && upEvent.sequence == downEvent.sequence && upEvent.ordinal.rawValue == 1)
    if transcript.pointee.hosts == 0 {
        transcript.pointee.action = action; transcript.pointee.event = downEvent
        transcript.pointee.semanticRevision = control.pointee.context.semanticRevision
        transcript.pointee.admission = admission; transcript.pointee.application = host.owner.observeApplicationProducer()
    }
    guard case .cycle(.success(let summary)) = host.runOpportunity() else { preconditionFailure("reuse current pointer cycle") }
    precondition(summary.admission.inputEventCount == 2 && summary.admission.semanticActionCount == 1)
    count += counterCheckHostFrame(control.pointee, value: 1)
    if transcript.pointee.hosts == 1 {
        p08ReuseLabel(route, "input-current")
        let currentAction = host.owner.observeProducedAction()
        let applied = control.pointee.applied, dispatched = control.pointee.actionDispatches
        precondition(host.owner.prepareProducedAction(currentAction))
        guard case .cycle(.success(let downSummary)) = host.runOpportunity() else { preconditionFailure("reuse current action down cycle") }
        precondition(downSummary.admission.inputEventCount == 1 && downSummary.admission.semanticActionCount == 0)
        precondition(control.pointee.applied == applied && control.pointee.actionDispatches == dispatched)
        precondition(control.pointee.runtime.pointer.capture.current == currentAction.captured && host.owner.observeModelValue() == 1)
        precondition(host.owner.deliverProducedAction(currentAction))
        precondition(control.pointee.applied == applied && control.pointee.actionDispatches == dispatched)
        guard case .cycle(.success(let upSummary)) = host.runOpportunity() else { preconditionFailure("reuse current action up cycle") }
        precondition(upSummary.admission.inputEventCount == 1 && upSummary.admission.semanticActionCount == 1)
        precondition(control.pointee.lastSealedAction == currentAction.captured && control.pointee.lastDispatchedAction == currentAction.captured)
        precondition(control.pointee.lastDispatchContext?.phase == .mutating && control.pointee.lastDispatchContext?.cycle == upSummary.cycle)
        precondition(control.pointee.applied == applied + 1 && control.pointee.actionDispatches == dispatched + 1)
        precondition(control.pointee.runtime.pointer.capture.current == nil && host.owner.observeModelValue() == 2)
        count += counterCheckHostFrame(control.pointee, value: 2); p08ReuseLabel(route, "action-current")
        let wake = control.pointee.acceptedFactWakeRecords
        precondition(admission.submit(stateChange: 3).result == .queued)
        precondition(admission.submit(completion: 0).result == .queued)
        let currentRevision = control.pointee.runtime.committedPresentation!
        let pointer = control.pointee.inputGate.submit(phase: .down, position: .init(x: 0, y: 0), source: .init(rawValue: 0), observedPresentationRevision: currentRevision, isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &admission)
        guard case .queued = pointer else { preconditionFailure("reuse current admission pointer") }
        precondition(control.pointee.acceptedFactWakeRecords == wake + 3)
        guard case .cycle(.success) = host.runOpportunity() else { preconditionFailure("reuse current admission cycle") }
        count += counterCheckHostFrame(control.pointee, value: 3); p08ReuseLabel(route, "admission-current")
        var application = host.owner.observeApplicationProducer()
        let callbacks = control.pointee.applicationCallbacks
        precondition(application.serviceSource(value: 4) && control.pointee.applicationCallbacks == callbacks + 1)
        guard case .cycle(.success) = host.runOpportunity() else { preconditionFailure("reuse current source cycle") }
        count += counterCheckHostFrame(control.pointee, value: 4); p08ReuseLabel(route, "source-current")
    }
    host.teardown()
    precondition(host.lifecycleState == .quiescent && host.owner.teardownStep == 8)
    guard case .failure = host.activate() else { preconditionFailure("terminal host reactivation") }
    precondition(host.runOpportunity() == .invalidLifecycle)
    if transcript.pointee.hosts == 0 { p08ReuseLabel(route, "terminal-old-host") }
    transcript.pointee.hosts += 1
    return count + 10
}

fileprivate struct P08StaticOuter: ~Copyable {
    let limits = counterActualLimits(.static)
    var root: StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>
    var semantic: StaticSemanticRecordStorage
    var semanticBacking = CounterSemanticBacking()
    var canvas = StaticCanvasValueStorage()
    var canvasBacking: InlineArray<1, CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?> = .init(repeating: nil)
    var control = CounterControl()
    init(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity) {
        root = StaticObservableRootAdapter(identity: modelOwner, schema: 1, needsCapture: false, modelLimit: 2, claimLimit: 4, pinLimit: 2, captureLimit: 0)!
        semantic = StaticSemanticRecordStorage(limits: counterSemanticLimits, owner: semanticOwner)
    }
}
fileprivate struct P08StaticOuterView: ~Copyable {
    let limits: RuntimeProfileLimits
    let root: UnsafeMutablePointer<StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>>
    let semantic: UnsafeMutablePointer<StaticSemanticRecordStorage>
    let records: UnsafeMutableBufferPointer<SemanticRuntimeRecord>
    let paths: UnsafeMutableBufferPointer<SemanticPathEntry>
    let payloads: UnsafeMutableBufferPointer<CounterPayload?>
    let scalars: UnsafeMutableBufferPointer<UInt32>
    let canvas: UnsafeMutablePointer<StaticCanvasValueStorage>
    let entries: UnsafeMutableBufferPointer<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>
    let control: UnsafeMutablePointer<CounterControl>
    let outerMetadataBytes: Int
    borrowing func reconstruct(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity) {
        p08RequireRetiredControl(control)
        control.deinitialize(count: 1); canvas.deinitialize(count: 1); semantic.deinitialize(count: 1); root.deinitialize(count: 1)
        root.initialize(to: StaticObservableRootAdapter(identity: modelOwner, schema: 1, needsCapture: false, modelLimit: 2, claimLimit: 4, pinLimit: 2, captureLimit: 0)!)
        semantic.initialize(to: StaticSemanticRecordStorage(limits: counterSemanticLimits, owner: semanticOwner))
        canvas.initialize(to: StaticCanvasValueStorage()); control.initialize(to: CounterControl())
        p08RequireFreshControl(control)
    }
    borrowing func audit(owner: borrowing P08TypedBackingOwner, report: (CounterStorageRegion) -> Void = { _ in }) -> RuntimeProfileValidationResult {
        let facts = owner.physicalFacts()
        return counterValidatePhysicalBacking(profile: .static, limits: limits, root: root.pointee.storageLayout,
            rootMetadataRegion: .inline(StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>.self, family: 7, chargedBytes: root.pointee.storageLayout.metadataBytes, kind: .metadataPadding),
            semantic: .init(limits: semantic.pointee.storageLimits, records: .elements(SemanticRuntimeRecord.self, count: records.count), paths: .elements(SemanticPathEntry.self, count: paths.count), payloads: .elements(CounterPayload?.self, count: payloads.count), scalars: .elements(UInt32.self, count: scalars.count), controlBytes: MemoryLayout<StaticSemanticRecordStorage>.size + CounterSemanticBacking.paddingBytes),
            geometry: facts.geometry, interactionFacts: facts.interaction, identityCapacities: (24, 48),
            descriptorBytes: MemoryLayout<P08GeometryAccess>.size + MemoryLayout<P08CandidateAccess>.size + 2 * MemoryLayout<P08CommittedAccess>.size + 2 * MemoryLayout<P08HitAccess>.size,
            geometryType: P08GeometryAccess.self, candidateType: P08CandidateAccess.self, committedType: P08CommittedAccess.self, hitType: P08HitAccess.self,
            canvasCount: entries.count, canvasCapacity: 1, canvasControlBytes: MemoryLayout<StaticCanvasValueStorage>.size,
            factoryRegion: .elements(UInt8.self, count: outerMetadataBytes + MemoryLayout<P08TypedBackingOwner>.stride, family: 24),
            factoryDescriptorRegion: .inline(Self.self, family: 24), geometryRegions: facts.geometryRegions, report: report)
    }
}
#if !hasFeature(Embedded)
// Each concrete inout field loan encloses its span and complete buffer callback.
// These private helpers return only the existing owned caller result.
fileprivate func withP08RecordsFieldBuffer<Result>(
    _ field: inout InlineArray<128, SemanticRuntimeRecord>,
    _ body: (UnsafeMutableBufferPointer<SemanticRuntimeRecord>) -> Result
) -> Result {
    var span = field.mutableSpan
    return span.withUnsafeMutableBufferPointer(body)
}
fileprivate func withP08PathsFieldBuffer<Result>(
    _ field: inout InlineArray<384, SemanticPathEntry>,
    _ body: (UnsafeMutableBufferPointer<SemanticPathEntry>) -> Result
) -> Result {
    var span = field.mutableSpan
    return span.withUnsafeMutableBufferPointer(body)
}
fileprivate func withP08PayloadsFieldBuffer<Result>(
    _ field: inout InlineArray<256, CounterPayload?>,
    _ body: (UnsafeMutableBufferPointer<CounterPayload?>) -> Result
) -> Result {
    var span = field.mutableSpan
    return span.withUnsafeMutableBufferPointer(body)
}
fileprivate func withP08ScalarsFieldBuffer<Result>(
    _ field: inout InlineArray<128, UInt32>,
    _ body: (UnsafeMutableBufferPointer<UInt32>) -> Result
) -> Result {
    var span = field.mutableSpan
    return span.withUnsafeMutableBufferPointer(body)
}
fileprivate func withP08EntriesFieldBuffer<Result>(
    _ field: inout InlineArray<1, CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>,
    _ body: (UnsafeMutableBufferPointer<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>) -> Result
) -> Result {
    var span = field.mutableSpan
    return span.withUnsafeMutableBufferPointer(body)
}
#endif

fileprivate func withP08SelectedStatic<Result>(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity,
    backing: UnsafeMutableRawBufferPointer?, _ body: (inout P08TypedBackingOwner, borrowing P08StaticOuterView) -> Result) -> Result {
    #if hasFeature(Embedded)
    let outer = P08EmbeddedOuter(modelOwner: modelOwner, semanticOwner: semanticOwner, backing: backing!, limits: counterActualLimits(.static))
    var owner = P08TypedBackingOwner(slots: .static(outer.storageSlots()), identity: UInt(bitPattern: backing!.baseAddress!))
    precondition(initializeP08Backing(&owner) == nil)
    defer { owner.finishReservation() }
    var occupied = 0
    for index in 0..<25 { let sum = occupied.addingReportingOverflow(outer.layout.regions[index]!.extent); precondition(!sum.overflow); occupied = sum.partialValue }
    let metadata = backing!.count - occupied + MemoryLayout<RuntimeProfileLimits>.stride + MemoryLayout<Bool>.stride - CounterSemanticBacking.paddingBytes
    let view = P08StaticOuterView(limits: outer.limits.pointee, root: outer.root, semantic: outer.semantic,
        records: .init(start: outer.records, count: 128), paths: .init(start: outer.paths, count: 384), payloads: .init(start: outer.payloads, count: 256), scalars: .init(start: outer.scalars, count: 128), canvas: outer.canvas, entries: .init(start: outer.entries, count: 1), control: outer.control, outerMetadataBytes: metadata)
    return body(&owner, view)
    #else
    var outer = P08StaticOuter(modelOwner: modelOwner, semanticOwner: semanticOwner)
    let limits = outer.limits
    return withUnsafeMutablePointer(to: &outer.root) { root in
        withUnsafeMutablePointer(to: &outer.semantic) { semantic in
        withUnsafeMutablePointer(to: &outer.canvas) { canvas in
        withUnsafeMutablePointer(to: &outer.control) { control in
        withP08RecordsFieldBuffer(&outer.semanticBacking.records) { records in
        withP08PathsFieldBuffer(&outer.semanticBacking.paths) { paths in
        withP08PayloadsFieldBuffer(&outer.semanticBacking.payloads) { payloads in
        withP08ScalarsFieldBuffer(&outer.semanticBacking.scalars) { scalars in
        withP08EntriesFieldBuffer(&outer.canvasBacking) { entries in
            withP08StaticReservation { owner in
                precondition(initializeP08Backing(&owner) == nil)
                defer { owner.finishReservation() }
                let metadata = MemoryLayout<P08StaticOuter>.stride - MemoryLayout<StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>>.size - MemoryLayout<StaticSemanticRecordStorage>.size - MemoryLayout<CounterSemanticBacking>.size - MemoryLayout<StaticCanvasValueStorage>.size - MemoryLayout<InlineArray<1, CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>>.size - MemoryLayout<CounterControl>.size + MemoryLayout<P08StaticReservation>.stride - (MemoryLayout<InlineArray<1024, UInt8>?>.stride + MemoryLayout<InlineArray<1056, UInt8>?>.stride + MemoryLayout<InlineArray<20, UInt8>?>.stride + MemoryLayout<InlineArray<112, UInt8>?>.stride + MemoryLayout<StaticCounterLayoutWorkspace?>.stride + MemoryLayout<StaticCounterResolvedLayoutStorage?>.stride + MemoryLayout<InlineArray<64, SemanticRecordReference?>?>.stride + MemoryLayout<StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>?>.stride + MemoryLayout<QualifiedRender?>.stride + MemoryLayout<CounterStaticCandidate?>.stride + 2 * MemoryLayout<CounterStaticHits?>.stride + 2 * MemoryLayout<CounterStaticCommitted?>.stride)
                let view = P08StaticOuterView(limits: limits, root: root, semantic: semantic, records: records, paths: paths, payloads: payloads, scalars: scalars, canvas: canvas, entries: entries, control: control, outerMetadataBytes: metadata)
                return body(&owner, view)
            }
        } } } } } } } } }
    #endif
}

fileprivate typealias P08StaticSupplied = CounterHostSuppliedStorage<P08GeometryAccess, P08CandidateAccess, P08CommittedAccess, P08HitAccess>
fileprivate typealias P08StaticHostOwner = CounterHostOwner<P08GeometryAccess, P08CandidateAccess, P08CommittedAccess, P08HitAccess>
fileprivate typealias P08StaticHost = SignalAnalyzerPresetHostInstance<P08StaticHostOwner>
fileprivate typealias P08Retired = CounterRetiredStorage<P08GeometryAccess, P08CandidateAccess, P08CommittedAccess, P08HitAccess>
#if !hasFeature(Embedded)
fileprivate typealias P08DynamicSupplied = CounterDynamicHostSuppliedStorage<P08GeometryAccess, P08CandidateAccess, P08CommittedAccess, P08HitAccess>
fileprivate typealias P08DynamicHostOwner = CounterDynamicHostOwner<P08GeometryAccess, P08CandidateAccess, P08CommittedAccess, P08HitAccess>
fileprivate typealias P08DynamicHost = SignalAnalyzerPresetHostInstance<P08DynamicHostOwner>
#endif
extension P08StorageSession {
    @_lifetime(copy self, copy models, copy root, copy semantic, copy values, copy control)
    fileprivate consuming func intoSupplied(models: consuming ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: consuming ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, semantic: consuming SemanticRecordStore<CounterPayload>, values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>, control: consuming CounterHostControl, audit: RuntimeStorageAudit) -> P08StaticSupplied {
        P08StaticSupplied(models: models, root: root, semantic: semantic, values: values, scopedControl: control, audit: audit, geometry: geometry, interaction: interaction)
    }
    #if !hasFeature(Embedded)
    @_lifetime(copy self, copy models, copy root, copy semantic, copy values, copy control)
    fileprivate consuming func intoDynamicSupplied(models: consuming ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: consuming ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, semantic: consuming SemanticRecordStore<CounterPayload>, values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>, control: consuming CounterHostControl, audit: RuntimeStorageAudit) -> P08DynamicSupplied {
        P08DynamicSupplied(models: models, root: root, semantic: semantic, values: values, scopedControl: control, audit: audit, geometry: geometry, interaction: interaction)
    }
    #endif
}

fileprivate enum P08BodyStage: ~Copyable, ~Escapable {
    case session(P08StorageSession)
    case supplied(P08StaticSupplied)
    case owner(P08StaticHostOwner)
    case host(P08StaticHost)
    case retired(P08Retired)
    #if !hasFeature(Embedded)
    case dynamicSupplied(P08DynamicSupplied)
    case dynamicOwner(P08DynamicHostOwner)
    case dynamicHost(P08DynamicHost)
    #endif
}
fileprivate struct P08BodyCleanup: ~Copyable, ~Escapable {
    private var stage: P08BodyStage?
    private let control: UnsafeMutablePointer<CounterControl>
    private var activationAttempted = false
    @_lifetime(copy session, borrow control)
    init(session: consuming P08StorageSession, control: borrowing UnsafeMutablePointer<CounterControl>) { stage = .session(session); self.control = copy control }
    @_lifetime(self: copy self, copy models, copy root, copy semantic, copy values, copy control)
    mutating func supply(models: consuming ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: consuming ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, semantic: consuming SemanticRecordStore<CounterPayload>, values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>, control: consuming CounterHostControl, audit: RuntimeStorageAudit, dynamic: Bool) {
        let current = stage.take()!
        switch consume current {
        case .session(let session):
            #if !hasFeature(Embedded)
            if dynamic { stage = .dynamicSupplied(session.intoDynamicSupplied(models: models, root: root, semantic: semantic, values: values, control: control, audit: audit)); return }
            #endif
            stage = .supplied(session.intoSupplied(models: models, root: root, semantic: semantic, values: values, control: control, audit: audit))
        default: preconditionFailure("body supply stage")
        }
    }
    @_lifetime(self: copy self, copy activationSpan)
    mutating func constructOwner(activationSpan: Span<UInt8>, assembly: CounterHostAssembly, failAfterRuntime: Bool) {
        let current = stage.take()!
        switch consume current {
        case .supplied(let supplied): stage = .owner(P08StaticHostOwner(supplied: supplied, activationSpan: activationSpan, assembly: assembly, failAfterRuntime: failAfterRuntime))
        #if !hasFeature(Embedded)
        case .dynamicSupplied(let supplied): stage = .dynamicOwner(P08DynamicHostOwner(supplied: supplied, activationSpan: activationSpan, assembly: assembly, failAfterRuntime: failAfterRuntime))
        #endif
        default: preconditionFailure("body owner stage")
        }
    }
    @_lifetime(self: copy self)
    mutating func checkJoins(models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, foreignModels: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, foreignRoot: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, control: UnsafeMutablePointer<CounterControl>, foreignControl: UnsafeMutablePointer<CounterControl>, audit: RuntimeStorageAudit, report: HostAssemblyReport) -> Int {
        let expected = counterJoinSnapshot(control), foreignExpected = counterJoinSnapshot(foreignControl)
        let current = stage.take()!
        switch consume current {
        case .owner(var owner):
            let checks = counterCheckRejectedBindings(owner: &owner, models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, audit: audit, report: report, expected: expected, foreignExpected: foreignExpected)
            stage = .owner(consume owner); return checks
        #if !hasFeature(Embedded)
        case .dynamicOwner(var owner):
            let checks = counterCheckDynamicRejectedBindings(owner: &owner, models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, audit: audit, report: report, expected: expected, foreignExpected: foreignExpected)
            stage = .dynamicOwner(consume owner); return checks
        #endif
        default: preconditionFailure("body join stage")
        }
    }
    @_lifetime(self: copy self)
    mutating func constructHost(report: HostAssemblyReport) {
        let current = stage.take()!
        switch consume current {
        case .owner(let owner):
            #if hasFeature(Embedded)
            stage = .host(SignalAnalyzerPresetHostInstances.nrf52840Static(report: report, owner: owner)!)
            #else
            stage = .host(SignalAnalyzerPresetHostInstances.macOSStatic(report: report, owner: owner)!)
            #endif
        #if !hasFeature(Embedded)
        case .dynamicOwner(let owner):
            #if os(Linux)
            stage = .dynamicHost(SignalAnalyzerPresetHostInstances.raspberryPiDynamic(report: report, owner: owner)!)
            #else
            stage = .dynamicHost(SignalAnalyzerPresetHostInstances.macOSDynamic(report: report, owner: owner)!)
            #endif
        #endif
        default: preconditionFailure("body host stage")
        }
    }
    @_lifetime(self: copy self)
    mutating func run(control: UnsafeMutablePointer<CounterControl>, report: HostAssemblyReport, failAfterRuntime: Bool, joinChecks: Int, early: UInt8, candidateFailure: RuntimeCompletePipelineStage?, reuse: UnsafeMutablePointer<P08HostReuseTranscript>? = nil) -> Int {
        activationAttempted = true
        let current = stage.take()!
        switch consume current {
        case .host(var host):
            let checks: Int
            if let reuse {
                checks = p08RunReuseHost(host: &host, control: control, transcript: reuse)
            } else if early == 5 || candidateFailure != nil {
                precondition(host.activate() == .active)
                if let candidateFailure {
                    control.pointee.fault = candidateFailure
                    var admission = CounterAdmission(borrowing: control)
                    precondition(admission.submit(stateChange: 7).result == .queued)
                    guard case .cycle(.failure) = host.runOpportunity() else { preconditionFailure("candidate failure control") }
                }
                checks = 1
            } else { checks = counterRunHostLifecycle(host: &host, control: control, report: report, failAfterRuntime: failAfterRuntime, joinChecks: joinChecks) }
            stage = .host(consume host); return checks
        #if !hasFeature(Embedded)
        case .dynamicHost(var host):
            let checks: Int
            if let reuse {
                checks = p08RunReuseHost(host: &host, control: control, transcript: reuse)
            } else if early == 5 || candidateFailure != nil {
                precondition(host.activate() == .active)
                if let candidateFailure {
                    control.pointee.fault = candidateFailure
                    var admission = CounterAdmission(borrowing: control)
                    precondition(admission.submit(stateChange: 7).result == .queued)
                    guard case .cycle(.failure) = host.runOpportunity() else { preconditionFailure("candidate failure control") }
                }
                checks = 1
            } else { checks = counterRunDynamicHostLifecycle(host: &host, control: control, report: report, failAfterRuntime: failAfterRuntime, joinChecks: joinChecks) }
            stage = .dynamicHost(consume host); return checks
        #endif
        default: preconditionFailure("body run stage")
        }
    }
    @_lifetime(self: copy self)
    mutating func finish() {
        guard let current = stage.take() else { return }
        var constructed = false
        switch consume current {
        case .session(var session): session.reset()
        case .supplied(let supplied): var retired = supplied.retireInertStorage(); retired.resetAfterQuiescence()
        case .retired(var retired): retired.resetAfterQuiescence()
        case .owner(var owner):
            constructed = true
            owner.refuseApplicationDeliveryAndInput(); owner.stopSourceDeliveryAndDetachObservations(); owner.cancelPointerSequencesAndHostCallbacks(); owner.quiesceRuntimeAndFinalizeActiveCycle(); owner.retireObservableRegistrationAndRouting(); owner.releasePlatformOwners(); owner.resetProfileStorage(); owner.invalidateAssemblyReportRuntimeUse()
        case .host(var host): constructed = true; host.teardown(); precondition(host.owner.teardownStep == 8)
        #if !hasFeature(Embedded)
        case .dynamicSupplied(let supplied): var retired = supplied.retireInertStorage(); retired.resetAfterQuiescence()
        case .dynamicOwner(var owner):
            constructed = true
            owner.refuseApplicationDeliveryAndInput(); owner.stopSourceDeliveryAndDetachObservations(); owner.cancelPointerSequencesAndHostCallbacks(); owner.quiesceRuntimeAndFinalizeActiveCycle(); owner.retireObservableRegistrationAndRouting(); owner.releasePlatformOwners(); owner.resetProfileStorage(); owner.invalidateAssemblyReportRuntimeUse()
        case .dynamicHost(var host): constructed = true; host.teardown(); precondition(host.owner.teardownStep == 8)
        #endif
        }
        if constructed {
            precondition(!control.pointee.inputGate.inputIsEligible)
            if activationAttempted { precondition(control.pointee.unavailable) }
            else {
                precondition(!control.pointee.unavailable && control.pointee.wake == nil && control.pointee.scheduler == nil)
                precondition(control.pointee.teardowns == 0 && control.pointee.applicationConstructions == 0)
            }
            precondition(control.pointee.observationsInstalled == control.pointee.observationsDetached)
            precondition(!control.pointee.frameActive && !control.pointee.admission.sealActive)
            precondition(control.pointee.admission.pendingStateCount == 0 && control.pointee.admission.pointerCount == 0)
            precondition(control.pointee.runtime.pointer.capture.current == nil && control.pointee.runtime.pointer.source == nil)
            precondition(!control.pointee.hasRoot && control.pointee.committedRecords == 0)
        }
        control.pointee.retireProducerOrigin()
    }
}

fileprivate func runP08ScopedBody(session: consuming P08StorageSession,
    models: consuming ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: consuming ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, semantic: consuming SemanticRecordStore<CounterPayload>, values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>, control: borrowing UnsafeMutablePointer<CounterControl>, audit: RuntimeStorageAudit, assembly: CounterHostAssembly, foreignModels: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, foreignRoot: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, foreignControl: UnsafeMutablePointer<CounterControl>, dynamic: Bool, failAfterRuntime: Bool, early: UInt8 = 0, candidateFailure: RuntimeCompletePipelineStage? = nil, reuse: UnsafeMutablePointer<P08HostReuseTranscript>? = nil) -> Int {
    let activationBacking: InlineArray<1, UInt8> = [1]
    session.installProducerOrigin(control)
    var holder = P08BodyCleanup(session: session, control: control)
    defer { holder.finish() }
    // This cleanup precedes every owned return and every activation.
    if early == 1 { return 1 }
    holder.supply(models: models.borrowedScope(), root: root.borrowedRoot(), semantic: semantic, values: values, control: CounterHostControl(pointer: control), audit: audit, dynamic: dynamic)
    if early == 2 { return 1 }
    holder.constructOwner(activationSpan: activationBacking.span, assembly: assembly, failAfterRuntime: failAfterRuntime)
    if early == 3 { return 1 }
    let joins = holder.checkJoins(models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, audit: audit, report: assembly.report)
    holder.constructHost(report: assembly.report)
    if early == 4 { return 1 }
    return holder.run(control: control, report: assembly.report, failAfterRuntime: failAfterRuntime, joinChecks: joins, early: early, candidateFailure: candidateFailure, reuse: reuse)
}

fileprivate func runP08StaticHost(owner: inout P08TypedBackingOwner, outer: borrowing P08StaticOuterView, failAfterRuntime: Bool, early: UInt8 = 0, candidateFailure: RuntimeCompletePipelineStage? = nil, write: CounterTiledPixelWrite? = nil, reuse: UnsafeMutablePointer<P08HostReuseTranscript>? = nil) -> Int {
    // Field facts remain local to the enclosing synchronous selected reservation.
    let control = outer.control
    let rootStorage = outer.root, semanticStorage = outer.semantic, canvasStorage = outer.canvas
    let recordsBacking = outer.records, pathsBacking = outer.paths
    let payloadsBacking = outer.payloads, scalarsBacking = outer.scalars, entriesBacking = outer.entries
    let limits = outer.limits
    #if hasFeature(Embedded) || GIFTUI_COUNTER_TILED
    if let write { control.pointee.backend.write = write }
    #endif
    guard case .valid(let audit) = outer.audit(owner: owner), let assembly = CounterHostAssembly.validate(audit, kind: counterStaticHostKind) else { preconditionFailure("counter valid-only host") }
    return counterForeignJoinScope { foreignModels, foreignRoot, foreignControl in
        let ownedChecks = counterOwnedSchedulerCompatibility(assembly.report)
        precondition(CounterHostAssembly.validate(audit, kind: counterStaticHostKind, sourceCallbacks: 21) == nil)
        precondition(CounterHostAssembly.validate(audit, kind: counterStaticHostKind, repositoryCallbacks: 2) == nil)
        precondition(CounterHostAssembly.validate(audit, kind: counterStaticHostKind, useCaseCallbacks: 2) == nil)
        precondition(CounterHostAssembly.validate(audit, kind: counterStaticHostKind, nonTransitionPublications: 2) == nil)
        var checks = 0
        do throws(ObservableStateError) {
            try rootStorage.pointee.withLifetime(limits: limits.observableState) { (models, root) throws(ObservableStateError) in
                do throws(SemanticExpansionError) {
                    var records = MutableSpan(_unsafeStart: recordsBacking.baseAddress!, count: recordsBacking.count)
                    var paths = MutableSpan(_unsafeStart: pathsBacking.baseAddress!, count: pathsBacking.count)
                    var payloads = MutableSpan(_unsafeStart: payloadsBacking.baseAddress!, count: payloadsBacking.count)
                    var scalars = MutableSpan(_unsafeStart: scalarsBacking.baseAddress!, count: scalarsBacking.count)
                    try semanticStorage.pointee.withLifetime(configuredLimits: counterSemanticConfiguration(limits), records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) { (semantic) throws(SemanticExpansionError) in
                        do throws(DrawingError) {
                            var entries = MutableSpan(_unsafeStart: entriesBacking.baseAddress!, count: entriesBacking.count)
                            try canvasStorage.pointee.withLifetime(entries: &entries, table: CounterValueTable(), capacity: 1, limits: limits.staticCanvas!) { values in
                                checks = withP08Storage(backing: &owner) { session in
                                    runP08ScopedBody(session: session, models: models.borrowedScope(), root: root.borrowedRoot(), semantic: semantic.borrowedStore(), values: values.borrowedValues(), control: control, audit: audit, assembly: assembly, foreignModels: foreignModels, foreignRoot: foreignRoot, foreignControl: foreignControl, dynamic: false, failAfterRuntime: failAfterRuntime, early: early, candidateFailure: candidateFailure, reuse: reuse)
                                }
                            }
                        } catch { preconditionFailure("counter host Canvas") }
                    }
                } catch { preconditionFailure("counter host semantics") }
            }
        } catch { preconditionFailure("counter host model") }
        return checks + ownedChecks + 4
    }
}
package func p08CounterHost(write: CounterTiledPixelWrite? = nil, backing: UnsafeMutableRawBufferPointer? = nil) -> Int {
    var models = ObservableModelOwnerNamespace(); var semantics = SemanticRecordOwnerNamespace()
    do {
        var checks = 0
        for scenario: UInt8 in 0...8 {
            let slot = scenario < 3 ? Int(scenario) : 3
            checks += withP08SelectedStatic(modelOwner: try models.issue(), semanticOwner: try semantics.issue(), backing: counterSelectedProfileBacking(backing, slot: slot)) { owner, outer in
                outer.control.pointee.terminalRetry = scenario == 2
                outer.control.pointee.idleQuiesceMode = scenario >= 3 ? scenario - 1 : 0
                #if hasFeature(Embedded) || GIFTUI_COUNTER_TILED
                outer.control.pointee.backend.write = write
                #endif
                return runP08StaticHost(owner: &owner, outer: outer, failAfterRuntime: scenario == 1)
            }
        }
        let firstModel = try models.issue(), secondModel = try models.issue()
        let firstSemantic = try semantics.issue(), secondSemantic = try semantics.issue()
        precondition(firstModel != secondModel && firstSemantic != secondSemantic)
        counterTrace("reuse.namespaces", (firstModel, secondModel, firstSemantic, secondSemantic))
        var transcript = P08HostReuseTranscript()
        checks += withUnsafeMutablePointer(to: &transcript) { transcript in
            withP08SelectedStatic(modelOwner: firstModel, semanticOwner: firstSemantic, backing: counterSelectedProfileBacking(backing, slot: 0)) { owner, outer in
                let control = outer.control
                let original = owner.originalInventory()
                let address = UInt(bitPattern: control)
                p08RequireFreshControl(control)
                var count = runP08StaticHost(owner: &owner, outer: outer, failAfterRuntime: false, write: write, reuse: transcript)
                owner.requireEmpty()
                p08RequireRetiredControl(control)
                outer.reconstruct(modelOwner: secondModel, semanticOwner: secondSemantic)
                precondition(UInt(bitPattern: control) == address)
                count += runP08StaticHost(owner: &owner, outer: outer, failAfterRuntime: false, write: write, reuse: transcript)
                owner.requireEmpty()
                p08RequireSameInventory(owner.originalInventory(), original)
                p08RequireRetiredControl(control)
                transcript.pointee.endRetainedObservations()
                owner.release()
                precondition(transcript.pointee.hosts == 2)
                count += p08VerifyDestruction(owner.destructionTranscript(), original: original, expectedCount: 14)
                p08ReuseLabel("static", "inventory-two-hosts"); p08ReuseLabel("static", "control-same-address"); p08ReuseLabel("static", "cleanup-backing-last")
                return count + 3
            }
        }
        return checks
    } catch { preconditionFailure("counter host identities") }
}

#if !hasFeature(Embedded)
fileprivate struct P08DynamicOuter: ~Copyable {
    let limits = counterActualLimits(.dynamic)
    var root: DynamicObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>
    var semantic: DynamicSemanticRecordStorage<CounterPayload>
    var canvas = DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>(capacity: 1)
    var control = CounterControl()
    init(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity) {
        root = DynamicObservableRootAdapter(identity: modelOwner, schema: 1, needsCapture: false, modelLimit: 2, claimLimit: 4, pinLimit: 2, captureLimit: 0)!
        semantic = DynamicSemanticRecordStorage(limits: counterSemanticLimits, owner: semanticOwner)
    }
}
fileprivate struct P08DynamicOuterView: ~Copyable {
    let limits: RuntimeProfileLimits
    let root: UnsafeMutablePointer<DynamicObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>>
    let semantic: UnsafeMutablePointer<DynamicSemanticRecordStorage<CounterPayload>>
    let canvas: UnsafeMutablePointer<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>
    let control: UnsafeMutablePointer<CounterControl>
    borrowing func reconstruct(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity) {
        p08RequireRetiredControl(control)
        control.deinitialize(count: 1); canvas.deinitialize(count: 1); semantic.deinitialize(count: 1); root.deinitialize(count: 1)
        root.initialize(to: DynamicObservableRootAdapter(identity: modelOwner, schema: 1, needsCapture: false, modelLimit: 2, claimLimit: 4, pinLimit: 2, captureLimit: 0)!)
        semantic.initialize(to: DynamicSemanticRecordStorage(limits: counterSemanticLimits, owner: semanticOwner))
        canvas.initialize(to: DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>(capacity: 1)); control.initialize(to: CounterControl())
        p08RequireFreshControl(control)
    }
    borrowing func audit(owner: borrowing P08TypedBackingOwner) -> RuntimeProfileValidationResult {
        let facts = owner.physicalFacts(), extent = semantic.pointee.retainedExtents
        let model = root.pointee.storageLayout
        let optionalBytes = MemoryLayout<DynamicLayoutWorkspace?>.stride + MemoryLayout<DynamicResolvedLayoutStorage?>.stride + MemoryLayout<DynamicDrawingPlanWorkspace?>.stride + MemoryLayout<DynamicRenderWorkspace?>.stride + MemoryLayout<CounterDynamicCandidate?>.stride + 2 * MemoryLayout<CounterDynamicCommitted?>.stride + 2 * MemoryLayout<CounterDynamicHits?>.stride
        return counterValidatePhysicalBacking(profile: .dynamic, limits: limits, root: model,
            rootMetadataRegion: .inline(ObservableModelOwnership.self, family: 7, chargedBytes: model.metadataBytes - MemoryLayout<UInt16>.size - 2 * MemoryLayout<Bool>.size - MemoryLayout<DynamicObservableModelStorage<CounterOwnedModel, CounterModelSchema>>.size, kind: .partition),
            semantic: .init(limits: semantic.pointee.storageLimits, records: .elements(SemanticRuntimeRecord.self, count: extent.records), paths: .elements(SemanticPathEntry.self, count: extent.paths), payloads: .elements(CounterPayload?.self, count: extent.payloads), scalars: .elements(UInt32.self, count: extent.scalars), controlBytes: extent.controlBytes),
            geometry: facts.geometry, interactionFacts: facts.interaction, identityCapacities: (24, 48),
            descriptorBytes: MemoryLayout<P08GeometryAccess>.size + MemoryLayout<P08CandidateAccess>.size + 2 * MemoryLayout<P08CommittedAccess>.size + 2 * MemoryLayout<P08HitAccess>.size,
            geometryType: P08GeometryAccess.self, candidateType: P08CandidateAccess.self, committedType: P08CommittedAccess.self, hitType: P08HitAccess.self,
            canvasCount: canvas.pointee.retainedElementCapacity, canvasCapacity: canvas.pointee.capacity,
            canvasControlBytes: MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>.size,
            factoryRegion: .elements(UInt8.self, count: MemoryLayout<P08DynamicOuter>.stride - MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>.size - MemoryLayout<CounterControl>.size + MemoryLayout<P08DynamicReservation>.stride - optionalBytes + MemoryLayout<P08TypedBackingOwner>.stride, family: 24),
            factoryDescriptorRegion: .inline(Self.self, family: 24), geometryRegions: facts.geometryRegions, report: { _ in })
    }
}
fileprivate func withP08SelectedDynamic<Result>(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity,
    _ body: (inout P08TypedBackingOwner, borrowing P08DynamicOuterView) -> Result) -> Result {
    var outer = P08DynamicOuter(modelOwner: modelOwner, semanticOwner: semanticOwner)
    let limits = outer.limits
    return withUnsafeMutablePointer(to: &outer.root) { root in
        withUnsafeMutablePointer(to: &outer.semantic) { semantic in
        withUnsafeMutablePointer(to: &outer.canvas) { canvas in
        withUnsafeMutablePointer(to: &outer.control) { control in
            withP08DynamicReservation { owner in
                precondition(initializeP08Backing(&owner) == nil); defer { owner.finishReservation() }
                let view = P08DynamicOuterView(limits: limits, root: root, semantic: semantic, canvas: canvas, control: control)
                return body(&owner, view)
            }
        } } } }
}
fileprivate func runP08DynamicHost(owner: inout P08TypedBackingOwner, outer: borrowing P08DynamicOuterView, failAfterRuntime: Bool, early: UInt8 = 0, candidateFailure: RuntimeCompletePipelineStage? = nil, reuse: UnsafeMutablePointer<P08HostReuseTranscript>? = nil) -> Int {
    // Capture owned field facts, never the borrowed outer aggregate.
    let control = outer.control
    let rootStorage = outer.root, semanticStorage = outer.semantic, canvasStorage = outer.canvas
    let limits = outer.limits
    guard case .valid(let audit) = outer.audit(owner: owner), let assembly = CounterHostAssembly.validate(audit, kind: counterDynamicHostKind) else { preconditionFailure("counter Dynamic valid-only host") }
    precondition(CounterHostAssembly.validate(audit, kind: counterDynamicHostKind, sourceCallbacks: 21) == nil)
    precondition(CounterHostAssembly.validate(audit, kind: counterDynamicHostKind, repositoryCallbacks: 2) == nil)
    precondition(CounterHostAssembly.validate(audit, kind: counterDynamicHostKind, useCaseCallbacks: 2) == nil)
    precondition(CounterHostAssembly.validate(audit, kind: counterDynamicHostKind, nonTransitionPublications: 2) == nil)
    return counterForeignJoinScope { foreignModels, foreignRoot, foreignControl in
        var checks = 0
        do throws(ObservableStateError) {
            try rootStorage.pointee.withLifetime(limits: limits.observableState) { (models, root) throws(ObservableStateError) in
                do throws(SemanticExpansionError) {
                    try semanticStorage.pointee.withLifetime(configuredLimits: counterSemanticConfiguration(limits)) { (semantic) throws(SemanticExpansionError) in
                        do throws(DrawingError) {
                            try canvasStorage.pointee.withLifetime(table: CounterValueTable(), limits: counterCanvasLimits, configuredCapacity: 1) { values in
                                checks = withP08Storage(backing: &owner) { session in
                                    runP08ScopedBody(session: session, models: models.borrowedScope(), root: root.borrowedRoot(), semantic: semantic.borrowedStore(), values: values.borrowedValues(), control: control, audit: audit, assembly: assembly, foreignModels: foreignModels, foreignRoot: foreignRoot, foreignControl: foreignControl, dynamic: true, failAfterRuntime: failAfterRuntime, early: early, candidateFailure: candidateFailure, reuse: reuse)
                                }
                            }
                        } catch { preconditionFailure("counter Dynamic Canvas") }
                    }
                } catch { preconditionFailure("counter Dynamic semantic") }
            }
        } catch { preconditionFailure("counter Dynamic model") }
        return checks + 4
    }
}
package func p08CounterDynamicHost() -> Int {
    var models = ObservableModelOwnerNamespace(); var semantics = SemanticRecordOwnerNamespace()
    do {
        var checks = 0
        for scenario: UInt8 in 0...8 {
            checks += withP08SelectedDynamic(modelOwner: try models.issue(), semanticOwner: try semantics.issue()) { owner, outer in
                outer.control.pointee.terminalRetry = scenario == 2
                outer.control.pointee.idleQuiesceMode = scenario >= 3 ? scenario - 1 : 0
                return runP08DynamicHost(owner: &owner, outer: outer, failAfterRuntime: scenario == 1)
            }
        }
        let firstModel = try models.issue(), secondModel = try models.issue()
        let firstSemantic = try semantics.issue(), secondSemantic = try semantics.issue()
        precondition(firstModel != secondModel && firstSemantic != secondSemantic)
        counterTrace("reuse.namespaces", (firstModel, secondModel, firstSemantic, secondSemantic))
        var transcript = P08HostReuseTranscript()
        checks += withUnsafeMutablePointer(to: &transcript) { transcript in
            withP08SelectedDynamic(modelOwner: firstModel, semanticOwner: firstSemantic) { owner, outer in
                let control = outer.control
                let original = owner.originalInventory()
                let address = UInt(bitPattern: control)
                p08RequireFreshControl(control)
                var count = runP08DynamicHost(owner: &owner, outer: outer, failAfterRuntime: false, reuse: transcript)
                owner.requireEmpty()
                p08RequireRetiredControl(control)
                outer.reconstruct(modelOwner: secondModel, semanticOwner: secondSemantic)
                precondition(UInt(bitPattern: control) == address)
                count += runP08DynamicHost(owner: &owner, outer: outer, failAfterRuntime: false, reuse: transcript)
                owner.requireEmpty()
                p08RequireSameInventory(owner.originalInventory(), original)
                p08RequireRetiredControl(control)
                transcript.pointee.endRetainedObservations()
                owner.release()
                precondition(transcript.pointee.hosts == 2)
                count += p08VerifyDestruction(owner.destructionTranscript(), original: original, expectedCount: 9)
                p08ReuseLabel("dynamic", "inventory-two-hosts"); p08ReuseLabel("dynamic", "control-same-address"); p08ReuseLabel("dynamic", "cleanup-backing-last")
                return count + 3
            }
        }
        return checks
    } catch { preconditionFailure("counter Dynamic identities") }
}
#endif

package func p08CounterGraph(backing: UnsafeMutableRawBufferPointer? = nil) -> Int {
    // Independent expected vector from the reviewed actual-owner inventory:
    // endpoint6 needs backing0, text1 and configuration2–5; wake16 retains
    // audit0 and capability2–5 in its full report. Operation-only peers add no edge.
    let expectedMasks: InlineArray<18, UInt32> = [0, 0, 0, 0, 0, 0, 63, 0, 0, 0, 0, 1, 0, 0, 1, 0, 61, 0]
    for index: UInt8 in 0..<18 {
        let record = CounterHostGraph().record(at: index)!
        precondition(record.role.rawValue == index)
        precondition(record.dependencies.rawValue == expectedMasks[Int(index)])
    }
    precondition(HostComponentGraphValidation.validate(CounterHostGraph()) == nil)
    precondition(CounterHostGraph().record(at: 18) == nil)
    for mode: UInt8 in 0...7 { precondition(HostComponentGraphValidation.validate(CounterInvalidGraph(mode: mode)) != nil) }
    var modelOwners = ObservableModelOwnerNamespace()
    var semanticOwners = SemanticRecordOwnerNamespace()
    var count = 46
    do {
        return withP08SelectedStatic(modelOwner: try modelOwners.issue(), semanticOwner: try semanticOwners.issue(), backing: counterSelectedProfileBacking(backing, slot: 0)) { owner, outer in
        guard case .valid(let audit) = outer.audit(owner: owner) else { preconditionFailure("counter graph audit") }
        let control = outer.control
        func reject(_ negative: CounterConstructionNegative) {
            let graph = CounterHostGraph(negative: negative)
            precondition(HostComponentGraphValidation.validate(graph) == nil)
            var observation = CounterConstructionObservation()
            precondition(CounterHostAssembly.validate(audit, kind: counterStaticHostKind, negative: negative, observation: &observation) == nil)
            precondition(observation.result == .invalid(stage: .graph, error: .invalidGraph))
            precondition(observation.hasNoLaterReads)
            precondition(control.pointee.applicationConstructions == 0 && control.pointee.finalized == 0 && control.pointee.wake == nil)
            count += 5
        }
        for origin: UInt8 in 0...5 { reject(.omitted(.rasterEndpoint, origin)) }
        reject(.omitted(.factAdmission, 0))
        reject(.omitted(.rootModelTarget, 0))
        for origin: UInt8 in [0, 2, 3, 4, 5] { reject(.omitted(.wakeRequester, origin)) }
        reject(.hiddenSelectedText)
        reject(.hiddenRetainedReport)
        reject(.undeclaredBoundText)
        var positive = CounterConstructionObservation()
        precondition(CounterHostAssembly.validate(audit, kind: counterStaticHostKind, negative: nil, observation: &positive) != nil)
        guard case .valid? = positive.result else { preconditionFailure("counter graph positive") }
        precondition(positive.runtimeReads == 1 && positive.textReads == 1 && positive.workloadReads == 1 && positive.capabilityReads == 1 && positive.endpointReads == 1 && positive.applicationReads == 1 && positive.inputReads == 1 && positive.policyReads == 1)
        precondition(control.pointee.applicationConstructions == 0 && control.pointee.finalized == 0 && control.pointee.wake == nil)
        count += 4
        return count
        }
    } catch { preconditionFailure("counter graph profile identities") }
}

fileprivate struct P08RoleObservation {
    let bankKind: UInt8
    let leftBefore: P08InitializedEntry
    let rightBefore: P08InitializedEntry
    let leftCount: UInt16
    let rightCount: UInt16
    let leftAfter: P08InitializedEntry
    let rightAfter: P08InitializedEntry
}
fileprivate struct P08RoleTranscript {
    var entries: InlineArray<64, P08RoleObservation?> = .init(repeating: nil)
    var count = 0
    mutating func record(_ event: P08RoleObservation) {
        precondition(count < entries.count)
        entries[count] = event; count += 1
    }
}

extension P08StorageSession {
    fileprivate mutating func exerciseTransactions() -> Int {
        func key(_ ordinal: UInt8) -> SemanticCompleteIdentity {
            var key = SemanticCompleteIdentity()
            precondition(key.append(.init(kind: .root)))
            precondition(key.append(.init(kind: .fixedChild, ordinal: ordinal)))
            precondition(key.append(.init(kind: .declarationRole, role: 2)))
            return key
        }
        let bounds = Rect(origin: .init(x: 0, y: 0), size: .init(width: 10, height: 10)!)!
        let limits = InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!
        var checks = 0
        for iteration: UInt32 in 0..<6 {
            let count: UInt16 = iteration % 2 == 0 ? 1 : 2
            precondition(interaction.beginCandidate(limits: limits) == nil)
            for index: UInt16 in 0..<count {
                let identity = key(UInt8(index))
                let result = interaction.append(identity: identity, isEnabled: true, bounds: bounds, clip: bounds, paintOrder: index, action: .init(code: index + 1), targetGeneration: .init(rawValue: 1))
                if result == .requiresGeneration { precondition(interaction.assignGeneration(.init(rawValue: iteration + 1), to: identity) == nil) }
                else { guard case .preserved = result else { preconditionFailure("scoped candidate append") } }
            }
            precondition(interaction.finishCandidate() == nil)
            let revision = PresentationRevision(rawValue: iteration + 1)
            interaction.resolveCandidate(.commit(revision))
            precondition(interaction.committedRecordCount == count && interaction.committedRevision == revision)
            let before = interaction.committedRecord(for: key(0))!
            let captured = CapturedAction(identity: before.identity, generation: before.generation)
            precondition(interaction.beginCandidate(limits: limits) == nil)
            precondition(interaction.finishCandidate() == nil)
            interaction.resolveCandidate(.discard)
            precondition(interaction.committedRecord(for: key(0)) == before && interaction.committedRevision == revision)
            precondition(interaction.resolveUp(captured, at: .init(x: 1, y: 1)) == .activationAdmitted(captured))
            checks += 5
        }
        // First-excess poisons the candidate; asking to commit cannot replace it.
        precondition(interaction.beginCandidate(limits: limits) == nil)
        for index: UInt16 in 0..<2 {
            let result = interaction.append(identity: key(UInt8(index)), isEnabled: true, bounds: bounds, clip: bounds, paintOrder: index, action: .init(code: index + 1), targetGeneration: .init(rawValue: 1))
            if result == .requiresGeneration { precondition(interaction.assignGeneration(.init(rawValue: 20 + UInt32(index)), to: key(UInt8(index))) == nil) }
        }
        precondition(interaction.append(identity: key(2), isEnabled: true, bounds: bounds, clip: bounds, paintOrder: 2, action: .init(code: 3), targetGeneration: .init(rawValue: 1)) == .failure(.capacityExhausted))
        precondition(interaction.finishCandidate() == .capacityExhausted)
        interaction.resolveCandidate(.discard)
        precondition(interaction.committedRecordCount == 2)
        return checks + 3
    }
}
fileprivate func p08VerifyRoleTranscript(_ transcript: borrowing P08RoleTranscript) -> Int {
    let count = transcript.count
    precondition(count == 12) // Six commits, R then H; discard exchanges none.
    for index in 0..<count {
        let event = transcript.entries[index]!
        precondition(event.bankKind == UInt8(index % 2))
        precondition(event.leftBefore.id != event.rightBefore.id && event.leftBefore.address != event.rightBefore.address)
        precondition(event.leftAfter.id == event.rightBefore.id && event.rightAfter.id == event.leftBefore.id)
        precondition(event.leftAfter.address == event.rightBefore.address && event.rightAfter.address == event.leftBefore.address)
        precondition(event.leftAfter.retainedBytes == event.rightBefore.retainedBytes && event.rightAfter.retainedBytes == event.leftBefore.retainedBytes)
        precondition(event.leftCount != event.rightCount) // 1→0, 2→1, 1→2, ...
        #if !hasFeature(Embedded)
        print("SO06 role", event.bankKind, event.leftBefore.id.rawValue, event.leftBefore.address, event.leftCount, event.leftBefore.retainedBytes, event.rightBefore.id.rawValue, event.rightBefore.address, event.rightCount, event.rightBefore.retainedBytes, "=>", event.leftAfter.id.rawValue, event.rightAfter.id.rawValue)
        #endif
    }
    return count * 5 + 1
}
fileprivate func p08VerifyDestruction(_ trace: InlineArray<14, P08InitializedEntry?>, original: InlineArray<14, P08InitializedEntry?>, expectedCount: Int) -> Int {
    for index in 0..<expectedCount {
        let destroyed = trace[index]!, acquired = original[expectedCount - 1 - index]!
        precondition(destroyed.id == acquired.id && destroyed.address == acquired.address && destroyed.count == acquired.count)
        precondition(destroyed.stride == acquired.stride && destroyed.alignment == acquired.alignment && destroyed.retainedBytes == acquired.retainedBytes)
    }
    for index in expectedCount..<14 { precondition(trace[index] == nil) }
    return expectedCount * 2 + 1
}
fileprivate func p08VerifyFault(_ owner: borrowing P08TypedBackingOwner, fault: P08AcquisitionFault, ids: InlineArray<14, P08PhysicalID?>, objects: Int) -> Int {
    let trace = owner.destructionTranscript()
    let installed = fault.afterInstall || fault.completed > 0
    var before = 0
    while ids[before] != fault.id { before += 1; precondition(before < objects) }
    let count = before + (installed ? 1 : 0)
    for index in 0..<count {
        let entry = trace[index]!
        precondition(entry.id == ids[count - 1 - index] && entry.address != 0 && entry.count >= 0 && entry.retainedBytes >= entry.count * entry.stride)
        if entry.id == fault.id && fault.completed > 0 { precondition(entry.count == fault.completed) }
    }
    for index in count..<14 { precondition(trace[index] == nil) }
    let empty = owner.originalInventory()
    for index in 0..<14 { precondition(empty[index] == nil) }
    return count + 1
}
#if hasFeature(Embedded)
fileprivate func p08SurplusBacking(_ backing: UnsafeMutableRawBufferPointer?) -> UnsafeMutableRawBufferPointer {
    let extent = counterEmbeddedSlotBytes.multipliedReportingOverflow(by: 2)
    guard !extent.overflow, let backing, extent.partialValue > 0,
        extent.partialValue <= backing.count, backing.baseAddress != nil
    else { preconditionFailure("surplus reservation bounds") }
    return UnsafeMutableRawBufferPointer(rebasing: backing[0..<extent.partialValue])
}
#endif
package func counterExerciseScopedStorage(backing: UnsafeMutableRawBufferPointer? = nil, write: CounterTiledPixelWrite? = nil) -> Int {
    let staticIDs: InlineArray<14, P08PhysicalID?> = [.b0, .b1, .b2, .b3, .g0, .g1, .g2, .g3, .g4, .c0, .h0, .r0, .r1, .h1]
    var checks = 0
    // Native typed arrays acquire whole T values. Embedded additionally acquires
    // every possible UInt8 prefix; all faults remain original-prefix unwind.
    #if !hasFeature(Embedded)
    for index in 0..<14 { for after in [false, true] {
        let fault = P08AcquisitionFault(id: staticIDs[index]!, completed: 0, afterInstall: after)
        checks += withP08StaticReservation { owner in
            precondition(owner.initialize(fault: fault) != nil)
            return p08VerifyFault(owner, fault: fault, ids: staticIDs, objects: 14)
        }
    } }
    for capacities: InlineArray<5, UInt16> in [[1,2,2,2,2], [2,1,2,2,1], [2,2,1,1,2], [2,2,2,1,2], [2,2,2,2,1]] {
        checks += withP08StaticReservation(capacities: capacities) { owner in
            precondition(owner.initialize() == .invalidCapacity)
            let inventory = owner.originalInventory(); for index in 0..<14 { precondition(inventory[index] == nil) }
            return 1
        }
    }
    checks += withP08StaticReservation { owner in
        precondition(owner.initialize() == nil)
        let original = owner.originalInventory()
        var count = 0
        for _ in 0..<3 {
            var transcript = P08RoleTranscript()
            count += withUnsafeMutablePointer(to: &transcript) { pointer in owner.withStorage(transcript: pointer) { session in
                var holder = P08SessionOnlyCleanup(session: session); defer { holder.finish() }
                return holder.exercise()
            } }
            count += p08VerifyRoleTranscript(transcript)
            let current = owner.originalInventory()
            for index in 0..<14 { precondition(current[index]!.address == original[index]!.address && current[index]!.retainedBytes == original[index]!.retainedBytes) }
        }
        owner.release()
        return count + p08VerifyDestruction(owner.destructionTranscript(), original: original, expectedCount: 14)
    }
    for surplus in [false, true] {
        checks += withP08StaticReservation(surplus: surplus) { owner in
            precondition(owner.initialize() == nil)
            let original = owner.originalInventory()
            let left = original[11]!, right = original[12]!
            precondition(left.retainedBytes <= right.retainedBytes)
            if surplus { precondition(left.retainedBytes < right.retainedBytes) }
            var transcript = P08RoleTranscript()
            let count = withUnsafeMutablePointer(to: &transcript) { pointer in owner.withStorage(transcript: pointer) { session in var holder = P08SessionOnlyCleanup(session: session); defer { holder.finish() }; return holder.exercise() } }
            owner.release()
            return count + p08VerifyRoleTranscript(transcript) + p08VerifyDestruction(owner.destructionTranscript(), original: original, expectedCount: 14)
        }
        checks += withP08DynamicReservation(surplus: surplus) { owner in
            precondition(owner.initialize() == nil)
            let original = owner.originalInventory()
            if surplus { precondition(original[6]!.retainedBytes < original[7]!.retainedBytes) }
            var transcript = P08RoleTranscript()
            let count = withUnsafeMutablePointer(to: &transcript) { pointer in owner.withStorage(transcript: pointer) { session in var holder = P08SessionOnlyCleanup(session: session); defer { holder.finish() }; return holder.exercise() } }
            owner.release()
            return count + p08VerifyRoleTranscript(transcript) + p08VerifyDestruction(owner.destructionTranscript(), original: original, expectedCount: 9)
        }
    }
    #endif
    var models = ObservableModelOwnerNamespace(); var semantics = SemanticRecordOwnerNamespace()
    do {
        #if hasFeature(Embedded)
        for surplus in [0, 64] {
            let outer = P08EmbeddedOuter(modelOwner: try models.issue(), semanticOwner: try semantics.issue(), backing: surplus == 0 ? counterSelectedProfileBacking(backing, slot: 0)! : p08SurplusBacking(backing), limits: counterActualLimits(.static), surplus: surplus)
            var owner = P08TypedBackingOwner(slots: .static(outer.storageSlots()), identity: UInt(bitPattern: outer.bytes.baseAddress!))
            precondition(owner.initialize() == nil)
            let original = owner.originalInventory()
            if surplus > 0 { precondition(original[11]!.retainedBytes < original[12]!.retainedBytes) }
            var transcript = P08RoleTranscript()
            checks += withUnsafeMutablePointer(to: &transcript) { pointer in owner.withStorage(transcript: pointer) { session in var holder = P08SessionOnlyCleanup(session: session); defer { holder.finish() }; return holder.exercise() } }
            checks += p08VerifyRoleTranscript(transcript)
            owner.release(); checks += p08VerifyDestruction(owner.destructionTranscript(), original: original, expectedCount: 14)
        }
        do {
            let outer = P08EmbeddedOuter(modelOwner: try models.issue(), semanticOwner: try semantics.issue(), backing: counterSelectedProfileBacking(backing, slot: 0)!, limits: counterActualLimits(.static))
            var owner = P08TypedBackingOwner(slots: .static(outer.storageSlots(r0Extent: MemoryLayout<CounterStaticCommitted>.stride - 1)), identity: UInt(bitPattern: outer.bytes.baseAddress!))
            precondition(owner.initialize() == .invalidReservation)
            let original = owner.originalInventory(); for index in 0..<14 { precondition(original[index] == nil) }
            checks += 1
        }
        for index in 0..<14 { for after in [false, true] {
            let outer = P08EmbeddedOuter(modelOwner: try models.issue(), semanticOwner: try semantics.issue(), backing: counterSelectedProfileBacking(backing, slot: 0)!, limits: counterActualLimits(.static))
            var owner = P08TypedBackingOwner(slots: .static(outer.storageSlots()), identity: UInt(bitPattern: outer.bytes.baseAddress!))
            let fault = P08AcquisitionFault(id: staticIDs[index]!, completed: 0, afterInstall: after)
            precondition(owner.initialize(fault: fault) != nil)
            checks += p08VerifyFault(owner, fault: fault, ids: staticIDs, objects: 14)
        } }
        for (id, count) in [(P08PhysicalID.b0,1024), (.b1,1056), (.b2,20), (.b3,112)] {
            for prefix in 1..<count {
                let outer = P08EmbeddedOuter(modelOwner: try models.issue(), semanticOwner: try semantics.issue(), backing: counterSelectedProfileBacking(backing, slot: 0)!, limits: counterActualLimits(.static))
                var owner = P08TypedBackingOwner(slots: .static(outer.storageSlots()), identity: UInt(bitPattern: outer.bytes.baseAddress!))
                let fault = P08AcquisitionFault(id: id, completed: prefix, afterInstall: false)
                precondition(owner.initialize(fault: fault) != nil)
                checks += p08VerifyFault(owner, fault: fault, ids: staticIDs, objects: 14)
            }
        }
        #endif
        for early: UInt8 in 1...5 {
            checks += withP08SelectedStatic(modelOwner: try models.issue(), semanticOwner: try semantics.issue(), backing: counterSelectedProfileBacking(backing, slot: 0)) { owner, outer in runP08StaticHost(owner: &owner, outer: outer, failAfterRuntime: false, early: early, write: write) }
        }
        for raw: UInt8 in 0...10 {
            checks += withP08SelectedStatic(modelOwner: try models.issue(), semanticOwner: try semantics.issue(), backing: counterSelectedProfileBacking(backing, slot: 0)) { owner, outer in runP08StaticHost(owner: &owner, outer: outer, failAfterRuntime: false, candidateFailure: RuntimeCompletePipelineStage(rawValue: raw)!, write: write) }
        }
        #if !hasFeature(Embedded)
        let dynamicIDs: InlineArray<14, P08PhysicalID?> = [.g0, .g1, .g3, .g4, .c0, .h0, .r0, .r1, .h1, nil, nil, nil, nil, nil]
        for index in 0..<9 { for after in [false, true] {
            let fault = P08AcquisitionFault(id: dynamicIDs[index]!, completed: 0, afterInstall: after)
            checks += withP08DynamicReservation { owner in precondition(owner.initialize(fault: fault) != nil); return p08VerifyFault(owner, fault: fault, ids: dynamicIDs, objects: 9) }
        } }
        for capacities: InlineArray<5, UInt16> in [[1,2,2,2,2], [2,1,2,2,1], [2,2,1,1,2], [2,2,2,1,2], [2,2,2,2,1]] {
            checks += withP08DynamicReservation(capacities: capacities) { owner in precondition(owner.initialize() == .invalidCapacity); return 1 }
        }
        checks += withP08DynamicReservation { owner in
            precondition(owner.initialize() == nil); let original = owner.originalInventory()
            var count = 0
            for _ in 0..<3 {
                var transcript = P08RoleTranscript()
                count += withUnsafeMutablePointer(to: &transcript) { pointer in owner.withStorage(transcript: pointer) { session in var holder = P08SessionOnlyCleanup(session: session); defer { holder.finish() }; return holder.exercise() } }
                count += p08VerifyRoleTranscript(transcript)
            }
            owner.release(); return count + p08VerifyDestruction(owner.destructionTranscript(), original: original, expectedCount: 9)
        }
        for early: UInt8 in 1...5 { checks += withP08SelectedDynamic(modelOwner: try models.issue(), semanticOwner: try semantics.issue()) { owner, outer in runP08DynamicHost(owner: &owner, outer: outer, failAfterRuntime: false, early: early) } }
        for raw: UInt8 in 0...10 { checks += withP08SelectedDynamic(modelOwner: try models.issue(), semanticOwner: try semantics.issue()) { owner, outer in runP08DynamicHost(owner: &owner, outer: outer, failAfterRuntime: false, candidateFailure: RuntimeCompletePipelineStage(rawValue: raw)!) } }
        #endif
    } catch { preconditionFailure("scoped corpus identities") }
    return checks
}
fileprivate struct P08SessionOnlyCleanup: ~Copyable, ~Escapable {
    private var session: P08StorageSession?
    @_lifetime(copy session)
    init(session: consuming P08StorageSession) { self.session = consume session }
    @_lifetime(self: copy self)
    mutating func exercise() -> Int {
        var current = session.take()!; let result = current.exerciseTransactions(); session = consume current; return result
    }
    @_lifetime(self: copy self)
    mutating func finish() { if var current = session.take() { current.reset() } }
}

#if !hasFeature(Embedded) && GIFTUI_COUNTER_NATIVE_EXCLUSIVITY
// This Native-only negative is deliberately an unresolved dynamic overlap of
// the actual owner Optional. The opaque helper performs only a read, so a trap
// cannot be attributed to the owner's active/reinitialize/release precondition.
// The global remains nil outside this closed, synchronous reservation scope.
@MainActor fileprivate var p08NativeExclusivityOwner: P08TypedBackingOwner? = nil
@inline(never)
@MainActor fileprivate func p08ReadNativeExclusiveOwner() -> Bool { p08NativeExclusivityOwner != nil }
@MainActor package func counterScopedNativeExclusivity(negative: Bool) -> Int {
    precondition(p08NativeExclusivityOwner == nil)
    func exercise(_ owner: inout P08TypedBackingOwner) -> Int {
        precondition(owner.initialize() == nil)
        p08NativeExclusivityOwner = consume owner
        if !negative { precondition(p08ReadNativeExclusiveOwner()) }
        let checks = withP08Storage(backing: &p08NativeExclusivityOwner!) { session in
            var holder = P08SessionOnlyCleanup(session: session); defer { holder.finish() }
            if negative { precondition(p08ReadNativeExclusiveOwner()) }
            return 1
        }
        owner = p08NativeExclusivityOwner.take()!
        precondition(p08NativeExclusivityOwner == nil)
        owner.release()
        return checks
    }
    #if GIFTUI_COUNTER_ROUTE_DYNAMIC
    return withP08DynamicReservation { owner in exercise(&owner) }
    #else
    return withP08StaticReservation { owner in exercise(&owner) }
    #endif
}
#endif
