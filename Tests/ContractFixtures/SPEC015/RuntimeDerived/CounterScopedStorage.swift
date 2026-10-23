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
    fileprivate mutating func finishMetadataReservation() -> Bool {
        switch lifecycle {
        case .reserved: return acquired == 0
        case .idle: finishReservation(); return true
        case .released: return true
        case .active: return false
        }
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
            s.g3.withBorrow { pointer in
                precondition(!pointer.pointee.isActive)
                pointer.pointee.withBase { base in
                    precondition(base.strokeCount == 0 && base.pointCount == 0 && base.subpathCount == 0 && base.normalizedStrokeOperationCount == 0)
                }
            }
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
        case .static:
            resetRender(); resetPlan(); resetLayout()
        #if !hasFeature(Embedded)
        case .dynamic:
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

// Construction returns before the active body; the original field loans remain open.
@inline(never)
@_lifetime(copy token)
fileprivate func p08ConstructStaticStorageSession(token: borrowing P08SessionLifetime,
    b0: UnsafeMutableRawBufferPointer,
    b1: UnsafeMutableRawBufferPointer,
    b2: UnsafeMutableRawBufferPointer,
    b3: UnsafeMutableRawBufferPointer,
    g0: UnsafeMutablePointer<StaticCounterLayoutWorkspace>,
    g1: UnsafeMutablePointer<StaticCounterResolvedLayoutStorage>,
    g2: UnsafeMutablePointer<InlineArray<64, SemanticRecordReference?>>,
    g3: UnsafeMutablePointer<StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>>,
    g4: UnsafeMutablePointer<QualifiedRender>,
    c0: UnsafeMutablePointer<CounterStaticCandidate>,
    h0: UnsafeMutablePointer<CounterStaticHits>,
    r0: UnsafeMutablePointer<CounterStaticCommitted>,
    r1: UnsafeMutablePointer<CounterStaticCommitted>,
    h1: UnsafeMutablePointer<CounterStaticHits>,
    c0Entry: P08InitializedEntry,
    h0Entry: P08InitializedEntry,
    r0Entry: P08InitializedEntry,
    r1Entry: P08InitializedEntry,
    h1Entry: P08InitializedEntry,
    configuration: InlineArray<5, UInt16>,
    transcript: UnsafeMutablePointer<P08RoleTranscript>?,
    ownerIdentity: UInt,
    sessionSerial: UInt64) -> P08StorageSession {
    let geometry = P08GeometryAccess.lend(sessionLifetime: token, descriptor: .static(.init(g0: g0, g1: g1, g2: g2, g3: g3, g4: g4, byteCounts: [b0.count, b1.count, b2.count, b3.count])))
    let c0Access = P08CandidateAccess.lend(sessionLifetime: token, descriptor: .static(c0, c0Entry, configuration[0]))
    let h0Access = P08HitAccess.lend(sessionLifetime: token, descriptor: .static(h0, h0Entry, configuration[1]), transcript: transcript)
    let r0Access = P08CommittedAccess.lend(sessionLifetime: token, descriptor: .static(r0, r0Entry, configuration[2]), transcript: transcript)
    let r1Access = P08CommittedAccess.lend(sessionLifetime: token, descriptor: .static(r1, r1Entry, configuration[3]), transcript: transcript)
    let h1Access = P08HitAccess.lend(sessionLifetime: token, descriptor: .static(h1, h1Entry, configuration[4]), transcript: transcript)
    let state = InteractionState(candidateRecords: c0Access, candidateHitRegions: h0Access, candidateCommittedRecords: r0Access, committedRecords: r1Access, committedHitRegions: h1Access)
    let interaction = P08ScopedKeys(state: state, maximumComponentsPerKey: 24, maximumComponents: 48)!
    return P08StorageSession(geometry: geometry, interaction: interaction, ownerIdentity: ownerIdentity, sessionSerial: sessionSerial)
}
#if !hasFeature(Embedded)
// Construction returns before the active body; the original field loans remain open.
@inline(never)
@_lifetime(copy token)
fileprivate func p08ConstructDynamicStorageSession(token: borrowing P08SessionLifetime,
    g0: UnsafeMutablePointer<DynamicLayoutWorkspace>,
    g1: UnsafeMutablePointer<DynamicResolvedLayoutStorage>,
    g3: UnsafeMutablePointer<DynamicDrawingPlanWorkspace>,
    g4: UnsafeMutablePointer<DynamicRenderWorkspace>,
    c0: UnsafeMutablePointer<CounterDynamicCandidate>,
    h0: UnsafeMutablePointer<CounterDynamicHits>,
    r0: UnsafeMutablePointer<CounterDynamicCommitted>,
    r1: UnsafeMutablePointer<CounterDynamicCommitted>,
    h1: UnsafeMutablePointer<CounterDynamicHits>,
    c0Entry: P08InitializedEntry,
    h0Entry: P08InitializedEntry,
    r0Entry: P08InitializedEntry,
    r1Entry: P08InitializedEntry,
    h1Entry: P08InitializedEntry,
    configuration: InlineArray<5, UInt16>,
    transcript: UnsafeMutablePointer<P08RoleTranscript>?,
    ownerIdentity: UInt,
    sessionSerial: UInt64) -> P08StorageSession {
    let geometry = P08GeometryAccess.lend(sessionLifetime: token, descriptor: .dynamic(.init(g0: g0, g1: g1, g3: g3, g4: g4)))
    let c0Access = P08CandidateAccess.lend(sessionLifetime: token, descriptor: .dynamic(c0, c0Entry, configuration[0]))
    let h0Access = P08HitAccess.lend(sessionLifetime: token, descriptor: .dynamic(h0, h0Entry, configuration[1]), transcript: transcript)
    let r0Access = P08CommittedAccess.lend(sessionLifetime: token, descriptor: .dynamic(r0, r0Entry, configuration[2]), transcript: transcript)
    let r1Access = P08CommittedAccess.lend(sessionLifetime: token, descriptor: .dynamic(r1, r1Entry, configuration[3]), transcript: transcript)
    let h1Access = P08HitAccess.lend(sessionLifetime: token, descriptor: .dynamic(h1, h1Entry, configuration[4]), transcript: transcript)
    let state = InteractionState(candidateRecords: c0Access, candidateHitRegions: h0Access, candidateCommittedRecords: r0Access, committedRecords: r1Access, committedHitRegions: h1Access)
    let interaction = P08ScopedKeys(state: state, maximumComponentsPerKey: 24, maximumComponents: 48)!
    return P08StorageSession(geometry: geometry, interaction: interaction, ownerIdentity: ownerIdentity, sessionSerial: sessionSerial)
}
#endif

fileprivate struct P08SessionPreparation {
    let b0Address: UInt
    let b1Address: UInt
    let b2Address: UInt
    let b3Address: UInt
    let g0Address: UInt
    let g1Address: UInt
    let g2Address: UInt
    let g3Address: UInt
    let g4Address: UInt
    let c0Address: UInt
    let h0Address: UInt
    let r0Address: UInt
    let r1Address: UInt
    let h1Address: UInt
    let c0Entry: P08InitializedEntry
    let h0Entry: P08InitializedEntry
    let r0Entry: P08InitializedEntry
    let r1Entry: P08InitializedEntry
    let h1Entry: P08InitializedEntry
    let configuration: InlineArray<5, UInt16>
}

extension P08TypedBackingOwner {
    @inline(never)
    private borrowing func sessionEntry(_ id: P08PhysicalID) -> P08InitializedEntry {
        for index in 0..<14 { if let entry = inventory[index], entry.id == id { return entry } }
        preconditionFailure("unacquired physical region")
    }
    @inline(never)
    private borrowing func prepareSession() -> P08SessionPreparation {
        var addresses: InlineArray<14, UInt> = .init(repeating: 0)
        switch slots {
        case .static:
            addresses[0] = sessionEntry(.b0).address
            addresses[1] = sessionEntry(.b1).address
            addresses[2] = sessionEntry(.b2).address
            addresses[3] = sessionEntry(.b3).address
            addresses[4] = sessionEntry(.g0).address
            addresses[5] = sessionEntry(.g1).address
            addresses[6] = sessionEntry(.g2).address
            addresses[7] = sessionEntry(.g3).address
            addresses[8] = sessionEntry(.g4).address
            addresses[9] = sessionEntry(.c0).address
            addresses[10] = sessionEntry(.h0).address
            addresses[11] = sessionEntry(.r0).address
            addresses[12] = sessionEntry(.r1).address
            addresses[13] = sessionEntry(.h1).address
        #if !hasFeature(Embedded)
        case .dynamic:
            addresses[4] = sessionEntry(.g0).address
            addresses[5] = sessionEntry(.g1).address
            addresses[7] = sessionEntry(.g3).address
            addresses[8] = sessionEntry(.g4).address
            addresses[9] = sessionEntry(.c0).address
            addresses[10] = sessionEntry(.h0).address
            addresses[11] = sessionEntry(.r0).address
            addresses[12] = sessionEntry(.r1).address
            addresses[13] = sessionEntry(.h1).address
        #endif
        }
        return .init(b0Address: addresses[0], b1Address: addresses[1], b2Address: addresses[2], b3Address: addresses[3], g0Address: addresses[4], g1Address: addresses[5], g2Address: addresses[6], g3Address: addresses[7], g4Address: addresses[8], c0Address: addresses[9], h0Address: addresses[10], r0Address: addresses[11], r1Address: addresses[12], h1Address: addresses[13], c0Entry: sessionEntry(.c0), h0Entry: sessionEntry(.h0), r0Entry: sessionEntry(.r0), r1Entry: sessionEntry(.r1), h1Entry: sessionEntry(.h1), configuration: capacities)
    }
}

extension P08TypedBackingOwner {
    fileprivate mutating func withStorage<Result>(transcript: UnsafeMutablePointer<P08RoleTranscript>? = nil, _ body: (consuming P08StorageSession) -> Result) -> Result {
        precondition(lifecycle == .idle && validateCapacities())
        requireEmpty()
        let next = serial.addingReportingOverflow(1); precondition(!next.overflow)
        serial = next.partialValue; lifecycle = .active
        let ownerIdentity = identity; let sessionSerial = serial
        let prepared = prepareSession()
        let b0Address = prepared.b0Address
        let b1Address = prepared.b1Address
        let b2Address = prepared.b2Address
        let b3Address = prepared.b3Address
        let g0Address = prepared.g0Address
        let g1Address = prepared.g1Address
        let g2Address = prepared.g2Address
        let g3Address = prepared.g3Address
        let g4Address = prepared.g4Address
        let c0Address = prepared.c0Address
        let h0Address = prepared.h0Address
        let r0Address = prepared.r0Address
        let r1Address = prepared.r1Address
        let h1Address = prepared.h1Address
        let c0Entry = prepared.c0Entry
        let h0Entry = prepared.h0Entry
        let r0Entry = prepared.r0Entry
        let r1Entry = prepared.r1Entry
        let h1Entry = prepared.h1Entry
        let configuration = prepared.configuration
        let result: Result
        switch slots {
        case .static(let s):
            let b0Slot = s.b0
            let b1Slot = s.b1
            let b2Slot = s.b2
            let b3Slot = s.b3
            let g0Slot = s.g0
            let g1Slot = s.g1
            let g2Slot = s.g2
            let g3Slot = s.g3
            let g4Slot = s.g4
            let c0Slot = s.c0
            let h0Slot = s.h0
            let r0Slot = s.r0
            let r1Slot = s.r1
            let h1Slot = s.h1

            result = b0Slot.withBorrow { b0 in
                b1Slot.withBorrow { b1 in
                b2Slot.withBorrow { b2 in
                b3Slot.withBorrow { b3 in
                g0Slot.withBorrow { g0 in
                g1Slot.withBorrow { g1 in
                g2Slot.withBorrow { g2 in
                g3Slot.withBorrow { g3 in
                g4Slot.withBorrow { g4 in
                c0Slot.withBorrow { c0 in
                h0Slot.withBorrow { h0 in
                r0Slot.withBorrow { r0 in
                r1Slot.withBorrow { r1 in
                h1Slot.withBorrow { h1 in
                    precondition(UInt(bitPattern: b0.baseAddress!) == b0Address && UInt(bitPattern: b1.baseAddress!) == b1Address && UInt(bitPattern: b2.baseAddress!) == b2Address && UInt(bitPattern: b3.baseAddress!) == b3Address)
                    precondition(UInt(bitPattern: g0) == g0Address && UInt(bitPattern: g1) == g1Address && UInt(bitPattern: g2) == g2Address && UInt(bitPattern: g3) == g3Address && UInt(bitPattern: g4) == g4Address)
                    let token = P08SessionLifetime.lend(owner: self, identity: ownerIdentity, serial: sessionSerial)
                    precondition(UInt(bitPattern: c0) == c0Address)
                    precondition(UInt(bitPattern: h0) == h0Address && UInt(bitPattern: r0) == r0Address && UInt(bitPattern: r1) == r1Address && UInt(bitPattern: h1) == h1Address)
                    return body(p08ConstructStaticStorageSession(token: token, b0: b0, b1: b1, b2: b2, b3: b3, g0: g0, g1: g1, g2: g2, g3: g3, g4: g4, c0: c0, h0: h0, r0: r0, r1: r1, h1: h1, c0Entry: c0Entry, h0Entry: h0Entry, r0Entry: r0Entry, r1Entry: r1Entry, h1Entry: h1Entry, configuration: configuration, transcript: transcript, ownerIdentity: ownerIdentity, sessionSerial: sessionSerial))
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
            let g0Slot = s.g0
            let g1Slot = s.g1
            let g3Slot = s.g3
            let g4Slot = s.g4
            let c0Slot = s.c0
            let h0Slot = s.h0
            let r0Slot = s.r0
            let r1Slot = s.r1
            let h1Slot = s.h1

            result = g0Slot.withBorrow { g0 in
                g1Slot.withBorrow { g1 in
                g3Slot.withBorrow { g3 in
                g4Slot.withBorrow { g4 in
                c0Slot.withBorrow { c0 in
                h0Slot.withBorrow { h0 in
                r0Slot.withBorrow { r0 in
                r1Slot.withBorrow { r1 in
                h1Slot.withBorrow { h1 in
                    precondition(UInt(bitPattern: g0) == g0Address && UInt(bitPattern: g1) == g1Address && UInt(bitPattern: g3) == g3Address && UInt(bitPattern: g4) == g4Address)
                    let token = P08SessionLifetime.lend(owner: self, identity: ownerIdentity, serial: sessionSerial)
                    precondition(UInt(bitPattern: c0) == c0Address && UInt(bitPattern: h0) == h0Address && UInt(bitPattern: r0) == r0Address && UInt(bitPattern: r1) == r1Address && UInt(bitPattern: h1) == h1Address)
                    return body(p08ConstructDynamicStorageSession(token: token, g0: g0, g1: g1, g3: g3, g4: g4, c0: c0, h0: h0, r0: r0, r1: r1, h1: h1, c0Entry: c0Entry, h0Entry: h0Entry, r0Entry: r0Entry, r1Entry: r1Entry, h1Entry: h1Entry, configuration: configuration, transcript: transcript, ownerIdentity: ownerIdentity, sessionSerial: sessionSerial))
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

@inline(never)
fileprivate func p08ClearHostPlan(_ facts: inout P08HostRunFacts?) {
    let installed = facts != nil; precondition(installed)
    facts = nil
}

// One private owned plan; no scope, pointer, callback or mutable backend.
fileprivate struct P08HostRunFacts: ~Copyable {
    let limits: RuntimeProfileLimits
    let audit: RuntimeStorageAudit
    let assembly: CounterHostAssembly
}

#if hasFeature(Embedded)
fileprivate struct P08EmbeddedOuter: ~Copyable {
    var hostPlan: P08HostRunFacts? = nil
    let limits: UnsafeMutablePointer<RuntimeProfileLimits>
    let root: UnsafeMutablePointer<CounterStaticRootStorage>
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
        root = counterEmbeddedField(backing, CounterStaticRootStorage.self, region: layout.regions[1]!)
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
        root.initialize(to: CounterStaticRootStorage(identity: modelOwner, schema: 1, needsCapture: false, modelLimit: min(2, max(1, limits.models.maximumModelSlots)), claimLimit: min(4, max(1, limits.models.maximumOwningTickets)), pinLimit: min(2, max(1, limits.models.maximumFramePins)), captureLimit: 0)!); acquired = 2
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
        let planningEnded = hostPlan == nil; precondition(planningEnded)
        if acquired >= 11 { used.deinitialize(count: 1) }
        if acquired >= 10 { CounterControl.requireVacantRuntimeSlot(at: control); control.deinitialize(count: 1) }
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
        func object(_ e: P08InitializedEntry, family: Int, payload: Int = 0, into rows: inout CounterPhysicalGeometryFacts) {
            let objectBytes = e.count.multipliedReportingOverflow(by: e.stride)
            precondition(!objectBytes.overflow && e.retainedBytes >= objectBytes.partialValue + payload)
            rows.append(.init(family: family, kind: .inlineValue, count: e.count, size: e.size, stride: e.stride, alignment: e.alignment, chargedBytes: UInt64(objectBytes.partialValue)))
            rows.append(.elements(UInt8.self, count: e.retainedBytes - objectBytes.partialValue - payload, family: family))
        }
        let banks: CounterPhysicalInteractionFacts
        switch slots {
        case .static(let s):

            object(entry(.b0), family: 12, into: &rows); object(entry(.b1), family: 12, into: &rows)
            object(entry(.g0), family: 12, into: &rows); object(entry(.g1), family: 12, into: &rows); object(entry(.g2), family: 12, into: &rows)
            object(entry(.g4), family: 13, into: &rows); object(entry(.b2), family: 15, into: &rows); object(entry(.b3), family: 16, into: &rows); object(entry(.g3), family: 16, into: &rows)
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
                object(entry(.g0), family: 12, payload: Int(p.pointee.reservedPayloadBytes), into: &rows)
                p.pointee.visitRetainedPayloadExtents { count, size, stride, alignment in rows.append(.init(family: 12, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CounterExtent(count: count, stride: stride, alignment: alignment).bytes!)) }
            }
            s.g1.withBorrow { p in
                object(entry(.g1), family: 12, payload: Int(p.pointee.reservedPayloadBytes), into: &rows)
                p.pointee.visitRetainedPayloadExtents { count, size, stride, alignment in rows.append(.init(family: 12, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CounterExtent(count: count, stride: stride, alignment: alignment).bytes!)) }
            }
            s.g4.withBorrow { p in
                object(entry(.g4), family: 13, payload: Int(p.pointee.reservedPayloadBytes), into: &rows)
                p.pointee.visitRetainedPayloadExtents { count, size, stride, alignment in rows.append(.init(family: 13, kind: .elements, count: count, size: size, stride: stride, alignment: alignment, chargedBytes: CounterExtent(count: count, stride: stride, alignment: alignment).bytes!)) }
            }
            s.g3.withBorrow { p in
                object(entry(.g3), family: 16, payload: Int(p.pointee.livePathReservedPayloadBytes + p.pointee.planReservedPayloadBytes), into: &rows)
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
        for index in 0..<rows.count {
            let row = rows.regions[index]!
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
    #if os(macOS) && !GIFTUI_COUNTER_ROUTE_DYNAMIC && !hasFeature(Embedded)
        counterDiagnosticReuse(route, suffix)
    #elseif !hasFeature(Embedded)
        print("so06-reuse-\(route)-\(suffix)")
    #endif
}
fileprivate func p08RequireFreshControl(_ control: UnsafeMutablePointer<CounterControl>) {
    CounterControl.requireVacantRuntimeSlot(at: control)
    precondition(control.pointee.admissionController == nil && control.pointee.wake == nil && control.pointee.scheduler == nil)
    precondition(control.pointee.lastSealedAction == nil && control.pointee.lastDispatchedAction == nil && control.pointee.lastDispatchContext == nil && control.pointee.actionDispatches == 0)
    precondition(!control.pointee.inputGate.inputIsEligible && !control.pointee.wakeEnabled && control.pointee.finalized == 0)
}
fileprivate func p08RequireRetiredControl(_ control: UnsafeMutablePointer<CounterControl>) {
    CounterControl.requireVacantRuntimeSlot(at: control)
    precondition(control.pointee.runtime.unavailable && !control.pointee.inputGate.inputIsEligible && !control.pointee.wakeEnabled)
    precondition(control.pointee.observationsInstalled == control.pointee.observationsDetached)
    if var scheduler = control.pointee.scheduler {
        precondition(scheduler.begin(at: control.pointee.wakeClockMicroseconds, lifecycleState: .active, assemblyReport: scheduler.assemblyReport) == .rejected(.pacingRejected, pacing: .unavailable))
    }
    precondition(CounterControl.snapshotProducerOrigin(at: control) == nil && !control.pointee.frameActive && !control.pointee.hasRoot)
    precondition(control.pointee.runtime.admission.pointerCount == 0 && control.pointee.runtime.admission.pendingStateCount == 0 && !control.pointee.runtime.admission.sealActive)
}
fileprivate func p08RequireSameInventory(_ current: borrowing InlineArray<14, P08InitializedEntry?>, _ original: borrowing InlineArray<14, P08InitializedEntry?>) {
    for index in 0..<14 {
        let same = current[index] == original[index]
        precondition(same)
    }
}
fileprivate struct P08ReuseFingerprint: ~Copyable {
    private var frozen = false
    private var runtimeSlot = CounterRuntimeSlotBaseline()
    private var acceptedRecording = CounterRecordingObservation()
    private var joins: CounterJoinSnapshot? = nil
    private var context: ExecutionContext? = nil
    private var capture: CapturedAction<SemanticCompleteIdentity>? = nil
    private var source: InputSourceID? = nil
    private var sequence: InputSourceSequenceState? = nil
    private var presentation: PresentationRevision? = nil
    private var semantic: CounterSemanticSnapshot? = nil
    private var dirty: Bool? = nil
    private var admission: CounterAdmissionBacking? = nil
    private var controllerContext: ExecutionContext? = nil
    private var controllerPresentation: PresentationRevision? = nil
    private var controllerQuiescent: Bool? = nil
    private var controllerSeal: Bool? = nil
    private var controllerDeferred: Bool? = nil
    private var schedulerNow: HostScheduledOpportunityBeginResult? = nil
    private var schedulerDeadline: HostScheduledOpportunityBeginResult? = nil
    private var wakeTakes: Int? = nil
    private var disabledWakeRejections: Int? = nil
    private var applicationCallbacks: Int? = nil
    private var observationsInstalled: Int? = nil
    private var observationsDetached: Int? = nil
    private var reentrantApplicationRejections: Int? = nil
    private var stoppedApplicationChecks: Int? = nil
    private var lastSealedAction: CapturedAction<SemanticCompleteIdentity>? = nil
    private var lastDispatchedAction: CapturedAction<SemanticCompleteIdentity>? = nil
    private var lastDispatchContext: ExecutionContext? = nil
    private var actionDispatches: Int? = nil
    mutating func capture(_ control: UnsafeMutablePointer<CounterControl>) {
        let canCapture = !frozen; precondition(canCapture)
        runtimeSlot.capture(control)
        acceptedRecording.captureAccepted(control)
        joins = counterJoinSnapshot(control); context = control.pointee.runtime.context
        capture = control.pointee.runtime.pointer.capture.current; source = control.pointee.runtime.pointer.source
        sequence = control.pointee.runtime.pointer.sequence
        presentation = control.pointee.runtime.committedPresentation; semantic = control.pointee.semanticSnapshot
        dirty = control.pointee.runtime.changed
        admission = control.pointee.runtime.admission
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
        frozen = true
    }
    @inline(never)
    mutating func installRecordingProbe(_ index: Int, control: UnsafeMutablePointer<CounterControl>) {
        acceptedRecording.installAcceptedProbe(index, control: control)
    }
    @inline(never)
    mutating func restoreRecordingProbe(_ index: Int, control: UnsafeMutablePointer<CounterControl>) {
        acceptedRecording.restoreAcceptedProbe(index, control: control)
    }
    @inline(never)
    mutating func installKeyProbe0(_ control: UnsafeMutablePointer<CounterControl>) { runtimeSlot.installKeyProbe0(control) }
    @inline(never)
    mutating func restoreKeyProbe0(_ control: UnsafeMutablePointer<CounterControl>) { runtimeSlot.restoreKeyProbe0(control) }
    @inline(never)
    mutating func installKeyProbe1(_ control: UnsafeMutablePointer<CounterControl>) { runtimeSlot.installKeyProbe1(control) }
    @inline(never)
    mutating func restoreKeyProbe1(_ control: UnsafeMutablePointer<CounterControl>) { runtimeSlot.restoreKeyProbe1(control) }
    @inline(never)
    mutating func installKeyProbe2(_ control: UnsafeMutablePointer<CounterControl>) { runtimeSlot.installKeyProbe2(control) }
    @inline(never)
    mutating func restoreKeyProbe2(_ control: UnsafeMutablePointer<CounterControl>) { runtimeSlot.restoreKeyProbe2(control) }
    @inline(never)
    mutating func installKeyProbe3(_ control: UnsafeMutablePointer<CounterControl>) { runtimeSlot.installKeyProbe3(control) }
    @inline(never)
    mutating func restoreKeyProbe3(_ control: UnsafeMutablePointer<CounterControl>) { runtimeSlot.restoreKeyProbe3(control) }
    // Concrete formal operations split independent comparison homes. They do
    // not write the once-frozen facts or construct a full current observation.
    // `mutating` selects an inout self convention; these match operations only read.
    @inline(never)
    private mutating func matchesRuntimeSlot(_ control: UnsafeMutablePointer<CounterControl>) -> Bool {
        runtimeSlot.matches(control)
    }
    @inline(never)
    private mutating func matchesRecording(_ control: UnsafeMutablePointer<CounterControl>) -> Bool {
        acceptedRecording.matchesAccepted(control)
    }
    @inline(never)
    private mutating func matchesJoins(_ control: UnsafeMutablePointer<CounterControl>) -> Bool {
        let present = joins != nil
        guard present else { return false }
        let samerequests = joins!.requests == control.pointee.wake?.requester.requestCount
        guard samerequests else { return false }
        let samereasons = joins!.reasons == control.pointee.wake?.accumulatedReasons
        guard samereasons else { return false }
        let sameoutstanding = joins!.outstanding == control.pointee.wake?.wakeOutstanding
        guard sameoutstanding else { return false }
        let samehostRequests = joins!.hostRequests == control.pointee.hostWakeRequests
        guard samehostRequests else { return false }
        let samefactRecords = joins!.factRecords == control.pointee.acceptedFactWakeRecords
        guard samefactRecords else { return false }
        let samefirstFact = joins!.firstFact == control.pointee.wakeFirstFactMicroseconds
        guard samefirstFact else { return false }
        let sameclock = joins!.clock == control.pointee.wakeClockMicroseconds
        guard sameclock else { return false }
        let samepointerCount = joins!.pointerCount == control.pointee.runtime.admission.pointerCount
        guard samepointerCount else { return false }
        let samestateCount = joins!.stateCount == control.pointee.runtime.admission.pendingStateCount
        guard samestateCount else { return false }
        let samecompletion = joins!.completion == control.pointee.runtime.admission.pendingCompletion
        guard samecompletion else { return false }
        #if !hasFeature(Embedded)
        let currentEndpoints = control.pointee.backend.constructedEndpoints
        #else
        let currentEndpoints = 0
        #endif
        let sameendpoints = joins!.endpoints == currentEndpoints
        guard sameendpoints else { return false }
        let sameapplications = joins!.applications == control.pointee.applicationConstructions
        guard sameapplications else { return false }
        let samefinalized = joins!.finalized == control.pointee.finalized
        guard samefinalized else { return false }
        let sameapplied = joins!.applied == control.pointee.applied
        guard sameapplied else { return false }
        return true
    }
    @inline(never)
    private mutating func matchesSemantic(_ control: UnsafeMutablePointer<CounterControl>) -> Bool {
        let present = semantic != nil
        guard present else { return false }
        let samescalarCount = semantic!.scalarCount == control.pointee.semanticSnapshot.scalarCount
        guard samescalarCount else { return false }
        let sametexts = semantic!.texts == control.pointee.semanticSnapshot.texts
        guard sametexts else { return false }
        let samedisabledMask = semantic!.disabledMask == control.pointee.semanticSnapshot.disabledMask
        guard samedisabledMask else { return false }
        let samedisabledCount = semantic!.disabledCount == control.pointee.semanticSnapshot.disabledCount
        guard samedisabledCount else { return false }
        let samecanvasOrigin = semantic!.canvasOrigin == control.pointee.semanticSnapshot.canvasOrigin
        guard samecanvasOrigin else { return false }
        for index in 0..<22 {
            let same = semantic!.scalars[index] == control.pointee.semanticSnapshot.scalars[index]
            guard same else { return false }
        }
        for index in 0..<4 {
            let same = semantic!.textLengths[index] == control.pointee.semanticSnapshot.textLengths[index]
            guard same else { return false }
        }
        return true
    }
    @inline(never)
    private mutating func matchesAdmission(_ control: UnsafeMutablePointer<CounterControl>) -> Bool {
        let present = admission != nil
        guard present else { return false }
        let samependingStateCount = admission!.pendingStateCount == control.pointee.runtime.admission.pendingStateCount
        guard samependingStateCount else { return false }
        let samependingCompletion = admission!.pendingCompletion == control.pointee.runtime.admission.pendingCompletion
        guard samependingCompletion else { return false }
        let samesealedStateCount = admission!.sealedStateCount == control.pointee.runtime.admission.sealedStateCount
        guard samesealedStateCount else { return false }
        let samesealedStateCursor = admission!.sealedStateCursor == control.pointee.runtime.admission.sealedStateCursor
        guard samesealedStateCursor else { return false }
        let samesealedCompletion = admission!.sealedCompletion == control.pointee.runtime.admission.sealedCompletion
        guard samesealedCompletion else { return false }
        let samesealedAction = admission!.sealedAction == control.pointee.runtime.admission.sealedAction
        guard samesealedAction else { return false }
        let samesealedPointerCount = admission!.sealedPointerCount == control.pointee.runtime.admission.sealedPointerCount
        guard samesealedPointerCount else { return false }
        let samesealActive = admission!.sealActive == control.pointee.runtime.admission.sealActive
        guard samesealActive else { return false }
        for index in 0..<2 {
            let samependingPointers = admission!.pendingPointers[index] == control.pointee.runtime.admission.pendingPointers[index]
            guard samependingPointers else { return false }
            let samesealedPointers = admission!.sealedPointers[index] == control.pointee.runtime.admission.sealedPointers[index]
            guard samesealedPointers else { return false }
        }
        for index in 0..<34 {
            let samependingStates = admission!.pendingStates[index] == control.pointee.runtime.admission.pendingStates[index]
            guard samependingStates else { return false }
            let samesealedStates = admission!.sealedStates[index] == control.pointee.runtime.admission.sealedStates[index]
            guard samesealedStates else { return false }
        }
        return true
    }
    @inline(never)
    private mutating func matchesSchedulerNow(_ control: UnsafeMutablePointer<CounterControl>) -> Bool {
        var scheduler = control.pointee.scheduler
        let report = control.pointee.scheduler?.assemblyReport
        return schedulerNow == scheduler?.begin(at: control.pointee.wakeClockMicroseconds, lifecycleState: .active, assemblyReport: report!)
    }
    @inline(never)
    private mutating func matchesSchedulerDeadline(_ control: UnsafeMutablePointer<CounterControl>, boundary: UInt64) -> Bool {
        var scheduler = control.pointee.scheduler
        let report = control.pointee.scheduler?.assemblyReport
        return schedulerDeadline == scheduler?.begin(at: boundary, lifecycleState: .active, assemblyReport: report!)
    }
    @inline(never)
    mutating func matches(_ control: UnsafeMutablePointer<CounterControl>) -> Bool {
        let isFrozen = frozen; precondition(isFrozen)
        let boundary = control.pointee.wakeClockMicroseconds.addingReportingOverflow(250000)
        precondition(!boundary.overflow)
        let sameruntimeSlot = matchesRuntimeSlot(control)
        guard sameruntimeSlot else { return false }
        let sameacceptedRecording = matchesRecording(control)
        guard sameacceptedRecording else { return false }
        let samejoins = matchesJoins(control)
        guard samejoins else { return false }
        let samecontext = context == control.pointee.runtime.context
        guard samecontext else { return false }
        let samecapture = capture == control.pointee.runtime.pointer.capture.current
        guard samecapture else { return false }
        let samesource = source == control.pointee.runtime.pointer.source
        guard samesource else { return false }
        let samesequence = sequence == control.pointee.runtime.pointer.sequence
        guard samesequence else { return false }
        let samepresentation = presentation == control.pointee.runtime.committedPresentation
        guard samepresentation else { return false }
        let samesemantic = matchesSemantic(control)
        guard samesemantic else { return false }
        let samedirty = dirty == control.pointee.runtime.changed
        guard samedirty else { return false }
        let sameadmission = matchesAdmission(control)
        guard sameadmission else { return false }
        let samecontrollerContext = controllerContext == control.pointee.admissionController?.context
        guard samecontrollerContext else { return false }
        let samecontrollerPresentation = controllerPresentation == control.pointee.admissionController?.committedPresentationRevision
        guard samecontrollerPresentation else { return false }
        let samecontrollerQuiescent = controllerQuiescent == control.pointee.admissionController?.isQuiescent
        guard samecontrollerQuiescent else { return false }
        let samecontrollerSeal = controllerSeal == control.pointee.admissionController?.isSealClosed
        guard samecontrollerSeal else { return false }
        let samecontrollerDeferred = controllerDeferred == control.pointee.admissionController?.didDeferAfterSeal
        guard samecontrollerDeferred else { return false }
        let sameschedulerNow = matchesSchedulerNow(control)
        guard sameschedulerNow else { return false }
        let sameschedulerDeadline = matchesSchedulerDeadline(control, boundary: boundary.partialValue)
        guard sameschedulerDeadline else { return false }
        let samewakeTakes = wakeTakes == control.pointee.wakeTakes
        guard samewakeTakes else { return false }
        let samedisabledWakeRejections = disabledWakeRejections == control.pointee.disabledWakeRejections
        guard samedisabledWakeRejections else { return false }
        let sameapplicationCallbacks = applicationCallbacks == control.pointee.applicationCallbacks
        guard sameapplicationCallbacks else { return false }
        let sameobservationsInstalled = observationsInstalled == control.pointee.observationsInstalled
        guard sameobservationsInstalled else { return false }
        let sameobservationsDetached = observationsDetached == control.pointee.observationsDetached
        guard sameobservationsDetached else { return false }
        let samereentrantApplicationRejections = reentrantApplicationRejections == control.pointee.reentrantApplicationRejections
        guard samereentrantApplicationRejections else { return false }
        let samestoppedApplicationChecks = stoppedApplicationChecks == control.pointee.stoppedApplicationChecks
        guard samestoppedApplicationChecks else { return false }
        let samelastSealedAction = lastSealedAction == control.pointee.lastSealedAction
        guard samelastSealedAction else { return false }
        let samelastDispatchedAction = lastDispatchedAction == control.pointee.lastDispatchedAction
        guard samelastDispatchedAction else { return false }
        let samelastDispatchContext = lastDispatchContext == control.pointee.lastDispatchContext
        guard samelastDispatchContext else { return false }
        let sameactionDispatches = actionDispatches == control.pointee.actionDispatches
        guard sameactionDispatches else { return false }
        return true
    }
}
@inline(never)
fileprivate func p08MatchesReuseFingerprint(_ expected: inout P08ReuseFingerprint,
    control: UnsafeMutablePointer<CounterControl>) -> Bool {
    expected.matches(control)
}
// Mutate one actual observed field at a time, restore it before the next read.
// The sole frozen baseline is never refreshed or copied by these controls.
@inline(never)
fileprivate func p08CheckBaselineSensitivity(_ before: inout P08ReuseFingerprint,
    control: UnsafeMutablePointer<CounterControl>) -> Int {
    let initialMatch = before.matches(control); precondition(initialMatch)
    for index in 0..<64 {
        before.installRecordingProbe(index, control: control)
        let rejects = !before.matches(control); precondition(rejects)
        before.restoreRecordingProbe(index, control: control)
        let restored = before.matches(control); precondition(restored)
    }
    before.installKeyProbe0(control)
    let rejects0 = !before.matches(control); precondition(rejects0)
    before.restoreKeyProbe0(control)
    let restored0 = before.matches(control); precondition(restored0)
    before.installKeyProbe1(control)
    let rejects1 = !before.matches(control); precondition(rejects1)
    before.restoreKeyProbe1(control)
    let restored1 = before.matches(control); precondition(restored1)
    before.installKeyProbe2(control)
    let rejects2 = !before.matches(control); precondition(rejects2)
    before.restoreKeyProbe2(control)
    let restored2 = before.matches(control); precondition(restored2)
    before.installKeyProbe3(control)
    let rejects3 = !before.matches(control); precondition(rejects3)
    before.restoreKeyProbe3(control)
    let restored3 = before.matches(control); precondition(restored3)
    do {
        let original = control.pointee.backend.reservations
        control.pointee.backend.reservations = original == 0 ? 1 : 0
        let rejects = !before.matches(control); precondition(rejects)
        control.pointee.backend.reservations = original
        let restored = before.matches(control); precondition(restored)
    }
    do {
        let original = control.pointee.backend.submissions
        control.pointee.backend.submissions = original == 0 ? 1 : 0
        let rejects = !before.matches(control); precondition(rejects)
        control.pointee.backend.submissions = original
        let restored = before.matches(control); precondition(restored)
    }
    do {
        let original = control.pointee.backend.finishes
        control.pointee.backend.finishes = original == 0 ? 1 : 0
        let rejects = !before.matches(control); precondition(rejects)
        control.pointee.backend.finishes = original
        let restored = before.matches(control); precondition(restored)
    }
    do {
        let original = control.pointee.backend.cancellations
        control.pointee.backend.cancellations = original == 0 ? 1 : 0
        let rejects = !before.matches(control); precondition(rejects)
        control.pointee.backend.cancellations = original
        let restored = before.matches(control); precondition(restored)
    }
    do {
        let original = control.pointee.backend.submittedBytes
        control.pointee.backend.submittedBytes = original == 0 ? 1 : 0
        let rejects = !before.matches(control); precondition(rejects)
        control.pointee.backend.submittedBytes = original
        let restored = before.matches(control); precondition(restored)
    }
    do {
        let original = control.pointee.backend.submittedRows
        control.pointee.backend.submittedRows = original == 0 ? 1 : 0
        let rejects = !before.matches(control); precondition(rejects)
        control.pointee.backend.submittedRows = original
        let restored = before.matches(control); precondition(restored)
    }
    do {
        let original = control.pointee.backend.constructedEndpoints
        control.pointee.backend.constructedEndpoints = original == 0 ? 1 : 0
        let rejects = !before.matches(control); precondition(rejects)
        control.pointee.backend.constructedEndpoints = original
        let restored = before.matches(control); precondition(restored)
    }
    do {
        let original = control.pointee.backend.projectionControls
        control.pointee.backend.projectionControls = original == 0 ? 1 : 0
        let rejects = !before.matches(control); precondition(rejects)
        control.pointee.backend.projectionControls = original
        let restored = before.matches(control); precondition(restored)
    }
    do {
        let original = control.pointee.backend.envelopeRejections
        control.pointee.backend.envelopeRejections = original == 0 ? 1 : 0
        let rejects = !before.matches(control); precondition(rejects)
        control.pointee.backend.envelopeRejections = original
        let restored = before.matches(control); precondition(restored)
    }
    let finalMatch = before.matches(control); precondition(finalMatch)
    return 156
}
// Borrow the host only for one operation; return existing owned observations.
@inline(never)
fileprivate func p08ReuseModelValue<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>) -> UInt8
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    host.owner.observeModelValue()
}

@inline(never)
fileprivate func p08ReuseProducedAction<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>) -> CounterProducedAction
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    host.owner.observeProducedAction()
}

@inline(never)
fileprivate func p08ReusePrepareAction<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, action: CounterProducedAction) -> Bool
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    host.owner.prepareProducedAction(action)
}

@inline(never)
fileprivate func p08ReuseDeliverAction<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, action: CounterProducedAction) -> Bool
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    host.owner.deliverProducedAction(action)
}

@inline(never)
fileprivate func p08ReuseTeardownStep<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>) -> UInt8
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    host.owner.teardownStep
}

@inline(never)
fileprivate func p08ReuseActivate<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, control: UnsafeMutablePointer<CounterControl>) -> Int
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    guard case .active = host.activate() else { preconditionFailure("reuse actual activation") }
    precondition(control.pointee.inputGate.inputIsEligible && control.pointee.wake != nil && control.pointee.scheduler != nil)
    guard case .cycle(.success) = host.runOpportunity() else { preconditionFailure("reuse source initial fact") }
    return counterCheckHostFrame(control.pointee, value: 0)
}

@inline(never)
fileprivate func p08ReuseRejectAction<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, control: UnsafeMutablePointer<CounterControl>, route: StaticString, before: inout P08ReuseFingerprint, modelBefore: UInt8, oldAction: CounterProducedAction) -> Int
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    let prepared = p08ReusePrepareAction(host: &host, action: oldAction)
    precondition(!prepared)
    let fingerprintUnchangedAfterPrepare = p08MatchesReuseFingerprint(&before, control: control)
    let modelUnchangedAfterPrepare: Bool
    if fingerprintUnchangedAfterPrepare {
        modelUnchangedAfterPrepare = p08ReuseModelValue(host: &host) == modelBefore
    } else {
        modelUnchangedAfterPrepare = false
    }
    let unchangedAfterPrepare = fingerprintUnchangedAfterPrepare && modelUnchangedAfterPrepare
    precondition(unchangedAfterPrepare)
    let delivered = p08ReuseDeliverAction(host: &host, action: oldAction)
    precondition(!delivered)
    let fingerprintUnchangedAfterDelivery = p08MatchesReuseFingerprint(&before, control: control)
    let modelUnchangedAfterDelivery: Bool
    if fingerprintUnchangedAfterDelivery {
        modelUnchangedAfterDelivery = p08ReuseModelValue(host: &host) == modelBefore
    } else {
        modelUnchangedAfterDelivery = false
    }
    let unchangedAfterDelivery = fingerprintUnchangedAfterDelivery && modelUnchangedAfterDelivery
    precondition(unchangedAfterDelivery); let checks = counterCheckHostFrame(control.pointee, value: 0)
    p08ReuseLabel(route, "action-stale")
    return checks
}

@inline(never)
fileprivate func p08ReuseRejectInput<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, control: UnsafeMutablePointer<CounterControl>, transcript: UnsafeMutablePointer<P08HostReuseTranscript>, route: StaticString, before: inout P08ReuseFingerprint, modelBefore: UInt8, oldEvent: NormalizedPointerEvent) -> Void
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    precondition(transcript.pointee.admission!.submit(pointer: oldEvent).result == .unavailable)
    let fingerprintUnchangedAfterInput = p08MatchesReuseFingerprint(&before, control: control)
    let modelUnchangedAfterInput: Bool
    if fingerprintUnchangedAfterInput {
        modelUnchangedAfterInput = p08ReuseModelValue(host: &host) == modelBefore
    } else {
        modelUnchangedAfterInput = false
    }
    let unchangedAfterInput = fingerprintUnchangedAfterInput && modelUnchangedAfterInput
    precondition(unchangedAfterInput)
    p08ReuseLabel(route, "input-stale")
}

@inline(never)
fileprivate func p08ReuseRejectAdmission<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, control: UnsafeMutablePointer<CounterControl>, transcript: UnsafeMutablePointer<P08HostReuseTranscript>, route: StaticString, before: inout P08ReuseFingerprint, modelBefore: UInt8, oldEvent: NormalizedPointerEvent) -> Void
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    precondition(transcript.pointee.admission!.submit(pointer: oldEvent).result == .unavailable)
    precondition(transcript.pointee.admission!.submit(stateChange: 8).result == .unavailable)
    precondition(transcript.pointee.admission!.submit(completion: 0).result == .unavailable)
    let fingerprintUnchangedAfterAdmission = p08MatchesReuseFingerprint(&before, control: control)
    let modelUnchangedAfterAdmission: Bool
    if fingerprintUnchangedAfterAdmission {
        modelUnchangedAfterAdmission = p08ReuseModelValue(host: &host) == modelBefore
    } else {
        modelUnchangedAfterAdmission = false
    }
    let unchangedAfterAdmission = fingerprintUnchangedAfterAdmission && modelUnchangedAfterAdmission
    precondition(unchangedAfterAdmission)
    p08ReuseLabel(route, "admission-stale")
}

@inline(never)
fileprivate func p08ReuseRejectSource<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, control: UnsafeMutablePointer<CounterControl>, transcript: UnsafeMutablePointer<P08HostReuseTranscript>, route: StaticString, before: inout P08ReuseFingerprint, modelBefore: UInt8) -> Void
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    precondition(!transcript.pointee.application!.constructedProjectionIsValid)
    precondition(!transcript.pointee.application!.serviceSource(value: 8))
    precondition(!transcript.pointee.application!.startSource())
    _ = transcript.pointee.application!.installObservation()
    transcript.pointee.application!.stopDelivery()
    let fingerprintUnchangedAfterSource = p08MatchesReuseFingerprint(&before, control: control)
    let modelUnchangedAfterSource: Bool
    if fingerprintUnchangedAfterSource {
        modelUnchangedAfterSource = p08ReuseModelValue(host: &host) == modelBefore
    } else {
        modelUnchangedAfterSource = false
    }
    let unchangedAfterSource = fingerprintUnchangedAfterSource && modelUnchangedAfterSource
    precondition(unchangedAfterSource)
    p08ReuseLabel(route, "source-stale")
}

@inline(never)
fileprivate func p08ReuseRejectOldOrigins<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, control: UnsafeMutablePointer<CounterControl>, transcript: UnsafeMutablePointer<P08HostReuseTranscript>, route: StaticString, action: CounterProducedAction, revision: PresentationRevision, baseline: inout P08ReuseFingerprint) -> Int
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    let oldAction = transcript.pointee.action!, oldEvent = transcript.pointee.event!
    precondition(action.captured == oldAction.captured && action.targetGeneration == oldAction.targetGeneration && action.targetIdentity == oldAction.targetIdentity)
    precondition(control.pointee.runtime.context.semanticRevision == transcript.pointee.semanticRevision)
    precondition(oldEvent.source == .init(rawValue: 0) && oldEvent.sequence.rawValue == 0 && oldEvent.ordinal.rawValue == 0 && oldEvent.presentationRevision == revision)
    p08ReuseLabel(route, "raw-namespace-collision")
    let modelBefore = p08ReuseModelValue(host: &host)
    baseline.capture(control)
    let sensitivityChecks = p08CheckBaselineSensitivity(&baseline, control: control)
    let checks = p08ReuseRejectAction(host: &host, control: control, route: route, before: &baseline, modelBefore: modelBefore, oldAction: oldAction)
    p08ReuseRejectInput(host: &host, control: control, transcript: transcript, route: route, before: &baseline, modelBefore: modelBefore, oldEvent: oldEvent)
    p08ReuseRejectAdmission(host: &host, control: control, transcript: transcript, route: route, before: &baseline, modelBefore: modelBefore, oldEvent: oldEvent)
    p08ReuseRejectSource(host: &host, control: control, transcript: transcript, route: route, before: &baseline, modelBefore: modelBefore)
    return checks + sensitivityChecks
}

@inline(never)
fileprivate func p08ReuseCurrentPointer<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, control: UnsafeMutablePointer<CounterControl>, transcript: UnsafeMutablePointer<P08HostReuseTranscript>, action: CounterProducedAction, revision: PresentationRevision, admission: inout CounterAdmission) -> Int
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    let down = control.pointee.inputGate.submit(phase: .down, position: control.pointee.actionPoints[0], source: .init(rawValue: 0), observedPresentationRevision: revision, isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &admission)
    let up = control.pointee.inputGate.submit(phase: .up, position: control.pointee.actionPoints[0], source: .init(rawValue: 0), observedPresentationRevision: revision, isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &admission)
    guard case .queued(let downEvent) = down, case .queued(let upEvent) = up else { preconditionFailure("reuse actual normalized input") }
    precondition(downEvent.sequence.rawValue == 0 && upEvent.sequence == downEvent.sequence && upEvent.ordinal.rawValue == 1)
    if transcript.pointee.hosts == 0 {
        transcript.pointee.action = action; transcript.pointee.event = downEvent
        transcript.pointee.semanticRevision = control.pointee.runtime.context.semanticRevision
        transcript.pointee.admission = admission; transcript.pointee.application = host.owner.observeApplicationProducer()
    }
    guard case .cycle(.success(let summary)) = host.runOpportunity() else { preconditionFailure("reuse current pointer cycle") }
    precondition(summary.admission.inputEventCount == 2 && summary.admission.semanticActionCount == 1)
    return counterCheckHostFrame(control.pointee, value: 1)
}

@inline(never)
fileprivate func p08ReuseCurrentActionDown<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, control: UnsafeMutablePointer<CounterControl>, currentAction: CounterProducedAction, applied: Int, dispatched: Int)
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    let prepared = p08ReusePrepareAction(host: &host, action: currentAction)
    precondition(prepared)
    guard case .cycle(.success(let downSummary)) = host.runOpportunity() else { preconditionFailure("reuse current action down cycle") }
    precondition(downSummary.admission.inputEventCount == 1 && downSummary.admission.semanticActionCount == 0)
    precondition(control.pointee.applied == applied && control.pointee.actionDispatches == dispatched)
    let captureMatches = control.pointee.runtime.pointer.capture.current == currentAction.captured
    let captureAndModelMatch: Bool
    if captureMatches { captureAndModelMatch = p08ReuseModelValue(host: &host) == 1 }
    else { captureAndModelMatch = false }
    precondition(captureAndModelMatch)
}

@inline(never)
fileprivate func p08ReuseCurrentActionUp<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, control: UnsafeMutablePointer<CounterControl>, route: StaticString, currentAction: CounterProducedAction, applied: Int, dispatched: Int) -> Int
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    let delivered = p08ReuseDeliverAction(host: &host, action: currentAction)
    precondition(delivered)
    precondition(control.pointee.applied == applied && control.pointee.actionDispatches == dispatched)
    guard case .cycle(.success(let upSummary)) = host.runOpportunity() else { preconditionFailure("reuse current action up cycle") }
    precondition(upSummary.admission.inputEventCount == 1 && upSummary.admission.semanticActionCount == 1)
    precondition(control.pointee.lastSealedAction == currentAction.captured && control.pointee.lastDispatchedAction == currentAction.captured)
    precondition(control.pointee.lastDispatchContext?.phase == .mutating && control.pointee.lastDispatchContext?.cycle == upSummary.cycle)
    precondition(control.pointee.applied == applied + 1 && control.pointee.actionDispatches == dispatched + 1)
    let captureMatches = control.pointee.runtime.pointer.capture.current == nil
    let captureAndModelMatch: Bool
    if captureMatches { captureAndModelMatch = p08ReuseModelValue(host: &host) == 2 }
    else { captureAndModelMatch = false }
    precondition(captureAndModelMatch)
    let checks = counterCheckHostFrame(control.pointee, value: 2); p08ReuseLabel(route, "action-current")
    return checks
}

@inline(never)
fileprivate func p08ReuseCurrentAction<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, control: UnsafeMutablePointer<CounterControl>, route: StaticString) -> Int
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    let currentAction = p08ReuseProducedAction(host: &host)
    let applied = control.pointee.applied, dispatched = control.pointee.actionDispatches
    p08ReuseCurrentActionDown(host: &host, control: control, currentAction: currentAction, applied: applied, dispatched: dispatched)
    return p08ReuseCurrentActionUp(host: &host, control: control, route: route, currentAction: currentAction, applied: applied, dispatched: dispatched)
}

@inline(never)
fileprivate func p08ReuseCurrentAdmission<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, control: UnsafeMutablePointer<CounterControl>, route: StaticString, admission: inout CounterAdmission) -> Int
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    let wake = control.pointee.acceptedFactWakeRecords
    precondition(admission.submit(stateChange: 3).result == .queued)
    precondition(admission.submit(completion: 0).result == .queued)
    let currentRevision = control.pointee.runtime.committedPresentation!
    let pointer = control.pointee.inputGate.submit(phase: .down, position: .init(x: 0, y: 0), source: .init(rawValue: 0), observedPresentationRevision: currentRevision, isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &admission)
    guard case .queued = pointer else { preconditionFailure("reuse current admission pointer") }
    precondition(control.pointee.acceptedFactWakeRecords == wake + 3)
    guard case .cycle(.success) = host.runOpportunity() else { preconditionFailure("reuse current admission cycle") }
    let checks = counterCheckHostFrame(control.pointee, value: 3); p08ReuseLabel(route, "admission-current")
    return checks
}

@inline(never)
fileprivate func p08ReuseCurrentSource<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, control: UnsafeMutablePointer<CounterControl>, route: StaticString) -> Int
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    var application = host.owner.observeApplicationProducer()
    let callbacks = control.pointee.applicationCallbacks
    precondition(application.serviceSource(value: 4) && control.pointee.applicationCallbacks == callbacks + 1)
    guard case .cycle(.success) = host.runOpportunity() else { preconditionFailure("reuse current source cycle") }
    let checks = counterCheckHostFrame(control.pointee, value: 4); p08ReuseLabel(route, "source-current")
    return checks
}

@inline(never)
fileprivate func p08ReuseTerminal<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, transcript: UnsafeMutablePointer<P08HostReuseTranscript>, route: StaticString) -> Int
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    host.teardown()
    let quiescent = host.lifecycleState == .quiescent
    let terminalState: Bool
    if quiescent { terminalState = p08ReuseTeardownStep(host: &host) == 8 }
    else { terminalState = false }
    precondition(terminalState)
    guard case .failure = host.activate() else { preconditionFailure("terminal host reactivation") }
    precondition(host.runOpportunity() == .invalidLifecycle)
    if transcript.pointee.hosts == 0 { p08ReuseLabel(route, "terminal-old-host") }
    transcript.pointee.hosts += 1
    return 10
}

fileprivate func p08RunReuseHost<Owner>(host: inout SignalAnalyzerPresetHostInstance<Owner>, control: UnsafeMutablePointer<CounterControl>, transcript: UnsafeMutablePointer<P08HostReuseTranscript>, baseline: UnsafeMutablePointer<P08ReuseFingerprint>?) -> Int
where Owner: SignalAnalyzerPresetLiveOwner & P08ReuseObservation & ~Copyable & ~Escapable {
    let route: StaticString = host.assemblyReport.profile == .static ? "static" : "dynamic"
    var count = p08ReuseActivate(host: &host, control: control)
    count += p08RuntimeSlotGuardControls(control)
    let action = p08ReuseProducedAction(host: &host)
    var admission = CounterAdmission(borrowing: control)
    let revision = control.pointee.runtime.committedPresentation!
    if transcript.pointee.hosts == 1 {
        #if hasFeature(Embedded)
        guard let baseline else { preconditionFailure("missing donor baseline") }
        count += p08ReuseRejectOldOrigins(host: &host, control: control, transcript: transcript, route: route, action: action, revision: revision, baseline: &baseline.pointee)
        #else
        var localBaseline = P08ReuseFingerprint()
        count += p08ReuseRejectOldOrigins(host: &host, control: control, transcript: transcript, route: route, action: action, revision: revision, baseline: &localBaseline)
        #endif
    }
    count += p08ReuseCurrentPointer(host: &host, control: control, transcript: transcript, action: action, revision: revision, admission: &admission)
    if transcript.pointee.hosts == 1 {
        p08ReuseLabel(route, "input-current")
        count += p08ReuseCurrentAction(host: &host, control: control, route: route)
        count += p08ReuseCurrentAdmission(host: &host, control: control, route: route, admission: &admission)
        count += p08ReuseCurrentSource(host: &host, control: control, route: route)
    }
    return count + p08ReuseTerminal(host: &host, transcript: transcript, route: route)
}

fileprivate struct P08StaticOuter: ~Copyable {
    let limits = counterActualLimits(.static)
    var root: CounterStaticRootStorage
    var semantic: StaticSemanticRecordStorage
    var semanticBacking = CounterSemanticBacking()
    var canvas = StaticCanvasValueStorage()
    var canvasBacking: InlineArray<1, CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?> = .init(repeating: nil)
    var control = CounterControl()
    init(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity) {
        root = CounterStaticRootStorage(identity: modelOwner, schema: 1, needsCapture: false, modelLimit: 2, claimLimit: 4, pinLimit: 2, captureLimit: 0)!
        semantic = StaticSemanticRecordStorage(limits: counterSemanticLimits, owner: semanticOwner)
    }
}
@inline(never)
fileprivate func p08DeinitializeOuterControl(_ field: UnsafeMutablePointer<CounterControl>) { field.deinitialize(count: 1) }
@inline(never)
fileprivate func p08InitializeOuterControl(_ field: UnsafeMutablePointer<CounterControl>) { field.initialize(to: CounterControl()) }
@inline(never)
fileprivate func p08DeinitializeStaticCanvas(_ field: UnsafeMutablePointer<StaticCanvasValueStorage>) { field.deinitialize(count: 1) }
@inline(never)
fileprivate func p08DeinitializeStaticSemantic(_ field: UnsafeMutablePointer<StaticSemanticRecordStorage>) { field.deinitialize(count: 1) }
@inline(never)
fileprivate func p08DeinitializeStaticRoot(_ field: UnsafeMutablePointer<CounterStaticRootStorage>) { field.deinitialize(count: 1) }
@inline(never)
fileprivate func p08InitializeStaticRoot(_ field: UnsafeMutablePointer<CounterStaticRootStorage>, owner: ObservableModelOwnerIdentity) {
    field.initialize(to: CounterStaticRootStorage(identity: owner, schema: 1, needsCapture: false, modelLimit: 2, claimLimit: 4, pinLimit: 2, captureLimit: 0)!)
}
@inline(never)
fileprivate func p08InitializeStaticSemantic(_ field: UnsafeMutablePointer<StaticSemanticRecordStorage>, owner: SemanticRecordOwnerIdentity) {
    field.initialize(to: StaticSemanticRecordStorage(limits: counterSemanticLimits, owner: owner))
}
@inline(never)
fileprivate func p08InitializeStaticCanvas(_ field: UnsafeMutablePointer<StaticCanvasValueStorage>) { field.initialize(to: StaticCanvasValueStorage()) }
fileprivate struct P08StaticOuterView: ~Copyable {
    let limits: RuntimeProfileLimits
    let root: UnsafeMutablePointer<CounterStaticRootStorage>
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
        CounterControl.requireVacantRuntimeSlot(at: control)
        p08DeinitializeOuterControl(control); p08DeinitializeStaticCanvas(canvas)
        p08DeinitializeStaticSemantic(semantic); p08DeinitializeStaticRoot(root)
        p08InitializeStaticRoot(root, owner: modelOwner)
        p08InitializeStaticSemantic(semantic, owner: semanticOwner)
        p08InitializeStaticCanvas(canvas); p08InitializeOuterControl(control)
        p08RequireFreshControl(control)
    }
    borrowing func audit(owner: borrowing P08TypedBackingOwner, report: (CounterStorageRegion) -> Void = { _ in }) -> RuntimeProfileValidationResult {
        let facts = owner.physicalFacts()
        return counterValidatePhysicalBacking(profile: .static, limits: limits, root: root.pointee.storageLayout,
            rootMetadataRegion: .inline(CounterStaticRootStorage.self, family: 7, chargedBytes: root.pointee.storageLayout.metadataBytes, kind: .metadataPadding),
            semantic: .init(limits: semantic.pointee.storageLimits, records: .elements(SemanticRuntimeRecord.self, count: records.count), paths: .elements(SemanticPathEntry.self, count: paths.count), payloads: .elements(CounterPayload?.self, count: payloads.count), scalars: .elements(UInt32.self, count: scalars.count), controlBytes: MemoryLayout<StaticSemanticRecordStorage>.size + CounterSemanticBacking.paddingBytes),
            geometry: facts.geometry, interactionFacts: facts.interaction, identityCapacities: (24, 48),
            descriptorBytes: MemoryLayout<P08GeometryAccess>.size + MemoryLayout<P08CandidateAccess>.size + 2 * MemoryLayout<P08CommittedAccess>.size + 2 * MemoryLayout<P08HitAccess>.size,
            geometryType: P08GeometryAccess.self, candidateType: P08CandidateAccess.self, committedType: P08CommittedAccess.self, hitType: P08HitAccess.self,
            canvasCount: entries.count, canvasCapacity: 1, canvasControlBytes: MemoryLayout<StaticCanvasValueStorage>.size,
            factoryRegion: .elements(UInt8.self, count: outerMetadataBytes + MemoryLayout<P08TypedBackingOwner>.stride + MemoryLayout<P08HostRunFacts?>.stride, family: 24),
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

#if !hasFeature(Embedded)
fileprivate func withP08SelectedStatic<Result>(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity,
    backing: UnsafeMutableRawBufferPointer?, _ body: (inout P08TypedBackingOwner, borrowing P08StaticOuterView) -> Result) -> Result {
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
                let metadata = MemoryLayout<P08StaticOuter>.stride - MemoryLayout<CounterStaticRootStorage>.size - MemoryLayout<StaticSemanticRecordStorage>.size - MemoryLayout<CounterSemanticBacking>.size - MemoryLayout<StaticCanvasValueStorage>.size - MemoryLayout<InlineArray<1, CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>>.size - MemoryLayout<CounterControl>.size + MemoryLayout<P08StaticReservation>.stride - (MemoryLayout<InlineArray<1024, UInt8>?>.stride + MemoryLayout<InlineArray<1056, UInt8>?>.stride + MemoryLayout<InlineArray<20, UInt8>?>.stride + MemoryLayout<InlineArray<112, UInt8>?>.stride + MemoryLayout<StaticCounterLayoutWorkspace?>.stride + MemoryLayout<StaticCounterResolvedLayoutStorage?>.stride + MemoryLayout<InlineArray<64, SemanticRecordReference?>?>.stride + MemoryLayout<StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>?>.stride + MemoryLayout<QualifiedRender?>.stride + MemoryLayout<CounterStaticCandidate?>.stride + 2 * MemoryLayout<CounterStaticHits?>.stride + 2 * MemoryLayout<CounterStaticCommitted?>.stride)
                let view = P08StaticOuterView(limits: limits, root: root, semantic: semantic, records: records, paths: paths, payloads: payloads, scalars: scalars, canvas: canvas, entries: entries, control: control, outerMetadataBytes: metadata)
                defer { CounterControl.requireVacantRuntimeSlot(at: control) }
                return body(&owner, view)
            }
        } } } } } } } } }
}
#endif

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

fileprivate struct P08BodyResult {
    let checks: Int
    let constructed: Bool
    let activationAttempted: Bool
}



// Only owned completion facts return; every original lender stays in the body.
@inline(never)
fileprivate func p08CompleteBody(_ result: P08BodyResult, control: UnsafeMutablePointer<CounterControl>) {
    if result.constructed {
        precondition(!control.pointee.inputGate.inputIsEligible)
        if result.activationAttempted { precondition(control.pointee.runtime.unavailable) }
        else {
            precondition(!control.pointee.runtime.unavailable && control.pointee.wake == nil && control.pointee.scheduler == nil)
            precondition(control.pointee.teardowns == 0 && control.pointee.applicationConstructions == 0)
        }
        precondition(control.pointee.observationsInstalled == control.pointee.observationsDetached)
        precondition(!control.pointee.frameActive && !control.pointee.runtime.admission.sealActive)
        precondition(control.pointee.runtime.admission.pendingStateCount == 0 && control.pointee.runtime.admission.pointerCount == 0)
        precondition(control.pointee.runtime.pointer.capture.current == nil && control.pointee.runtime.pointer.source == nil)
        precondition(!control.pointee.hasRoot && control.pointee.committedRecords == 0)
    }
    CounterControl.requireVacantRuntimeSlot(at: control)
    control.pointee.retireProducerOrigin()
}

@inline(never)
fileprivate func p08FinishStaticOwner(_ owner: inout P08StaticHostOwner) {
    owner.refuseApplicationDeliveryAndInput(); owner.stopSourceDeliveryAndDetachObservations(); owner.cancelPointerSequencesAndHostCallbacks(); owner.quiesceRuntimeAndFinalizeActiveCycle(); owner.retireObservableRegistrationAndRouting(); owner.releasePlatformOwners(); owner.resetProfileStorage(); owner.invalidateAssemblyReportRuntimeUse()
}

@inline(never)
fileprivate func p08RunStaticHostPhase(host: inout P08StaticHost, control: UnsafeMutablePointer<CounterControl>, report: HostAssemblyReport, failAfterRuntime: Bool, joinChecks: Int, early: UInt8, candidateFailure: RuntimeCompletePipelineStage?, reuse: UnsafeMutablePointer<P08HostReuseTranscript>?, baseline: UnsafeMutablePointer<P08ReuseFingerprint>?) -> P08BodyResult {
    let checks: Int
    if let reuse {
        checks = p08RunReuseHost(host: &host, control: control, transcript: reuse, baseline: baseline)
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
    return P08BodyResult(checks: checks, constructed: true, activationAttempted: true)
}

extension SignalAnalyzerPresetHostInstance where Owner: SignalAnalyzerPresetLiveOwner & ~Copyable & ~Escapable, Owner == P08StaticHostOwner {
    @_lifetime(self: copy self)
    fileprivate mutating func p08UseOriginalStaticHost(control: UnsafeMutablePointer<CounterControl>, report: HostAssemblyReport, failAfterRuntime: Bool, joinChecks: Int, early: UInt8, candidateFailure: RuntimeCompletePipelineStage?, reuse: UnsafeMutablePointer<P08HostReuseTranscript>?, baseline: UnsafeMutablePointer<P08ReuseFingerprint>?) -> P08BodyResult {
        if early == 4 { return P08BodyResult(checks: 1, constructed: true, activationAttempted: false) }
        return p08RunStaticHostPhase(host: &self, control: control, report: report, failAfterRuntime: failAfterRuntime, joinChecks: joinChecks, early: early, candidateFailure: candidateFailure, reuse: reuse, baseline: baseline)
    }
    @_lifetime(self: copy self)
    fileprivate mutating func p08FinishOriginalStaticHost() {
        self.teardown()
        let teardownStep = p08ReuseTeardownStep(host: &self)
        let finished = teardownStep == 8; precondition(finished)
    }
}

@inline(never)
fileprivate func p08CheckStaticHostJoins(owner: inout P08StaticHostOwner, models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, foreignModels: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, foreignRoot: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, control: UnsafeMutablePointer<CounterControl>, foreignControl: UnsafeMutablePointer<CounterControl>, facts: inout P08HostRunFacts) -> Int {
    let expected = counterJoinSnapshot(control), foreignExpected = counterJoinSnapshot(foreignControl)
    return counterCheckRejectedBindings(owner: &owner, models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, audit: facts.audit, report: facts.assembly.report, expected: expected, foreignExpected: foreignExpected)
}

// No capability or scoped owner is retained in construction completion facts.
fileprivate struct P08HostConstructionFacts {
    var completed: P08BodyResult? = nil
    var joinChecks: Int = 0
}

@_lifetime(destination: copy session, copy semantic, copy values, copy models, copy root, borrow control, copy activationSpan)
@inline(never)
fileprivate func p08ConstructStaticHost(session: consuming P08StorageSession, semantic: consuming SemanticRecordStore<CounterPayload>, values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>, activationSpan: Span<UInt8>, models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, foreignModels: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, foreignRoot: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, control: borrowing UnsafeMutablePointer<CounterControl>, foreignControl: UnsafeMutablePointer<CounterControl>, facts: inout P08HostRunFacts, failAfterRuntime: Bool, early: UInt8, destination: inout P08StaticHost?, completion: inout P08HostConstructionFacts) {
    if early == 1 {
        var session = consume session; session.reset()
        completion.completed = P08BodyResult(checks: 1, constructed: false, activationAttempted: false)
        return
    }
    let supplied = session.intoSupplied(models: models.borrowedScope(), root: root.borrowedRoot(), semantic: semantic, values: values, control: CounterHostControl(pointer: control), audit: facts.audit)
    if early == 2 {
        var retired = supplied.retireInertStorage(); retired.resetAfterQuiescence()
        completion.completed = P08BodyResult(checks: 1, constructed: false, activationAttempted: false)
        return
    }
    var owner = P08StaticHostOwner(supplied: supplied, activationSpan: activationSpan, assembly: facts.assembly, failAfterRuntime: failAfterRuntime)
    if early == 3 {
        p08FinishStaticOwner(&owner)
        completion.completed = P08BodyResult(checks: 1, constructed: true, activationAttempted: false)
        return
    }
    completion.joinChecks = p08CheckStaticHostJoins(owner: &owner, models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, facts: &facts)
    #if hasFeature(Embedded)
    destination = SignalAnalyzerPresetHostInstances.nrf52840Static(report: facts.assembly.report, owner: owner)
    #else
    destination = SignalAnalyzerPresetHostInstances.macOSStatic(report: facts.assembly.report, owner: owner)
    #endif
}

@inline(never)
fileprivate func p08RunStaticSessionPhase(session: consuming P08StorageSession, semantic: consuming SemanticRecordStore<CounterPayload>, values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>, activationSpan: Span<UInt8>, models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, foreignModels: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, foreignRoot: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, control: UnsafeMutablePointer<CounterControl>, foreignControl: UnsafeMutablePointer<CounterControl>, facts: inout P08HostRunFacts, failAfterRuntime: Bool, early: UInt8, candidateFailure: RuntimeCompletePipelineStage?, reuse: UnsafeMutablePointer<P08HostReuseTranscript>?, baseline: UnsafeMutablePointer<P08ReuseFingerprint>?) -> P08BodyResult {
    var completion = P08HostConstructionFacts()
    var host: P08StaticHost? = nil
    p08ConstructStaticHost(session: session, semantic: semantic, values: values, activationSpan: activationSpan, models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, facts: &facts, failAfterRuntime: failAfterRuntime, early: early, destination: &host, completion: &completion)
    defer { host?.p08FinishOriginalStaticHost() }
    if let result = host?.p08UseOriginalStaticHost(control: control, report: facts.assembly.report, failAfterRuntime: failAfterRuntime, joinChecks: completion.joinChecks, early: early, candidateFailure: candidateFailure, reuse: reuse, baseline: baseline) {
        let noEarlyCompletion = completion.completed == nil; precondition(noEarlyCompletion)
        return result
    }
    guard let result = completion.completed else { preconditionFailure("original host factory invariant") }
    return result
}

#if !hasFeature(Embedded)

@inline(never)
fileprivate func p08FinishDynamicOwner(_ owner: inout P08DynamicHostOwner) {
    owner.refuseApplicationDeliveryAndInput(); owner.stopSourceDeliveryAndDetachObservations(); owner.cancelPointerSequencesAndHostCallbacks(); owner.quiesceRuntimeAndFinalizeActiveCycle(); owner.retireObservableRegistrationAndRouting(); owner.releasePlatformOwners(); owner.resetProfileStorage(); owner.invalidateAssemblyReportRuntimeUse()
}

@inline(never)
fileprivate func p08RunDynamicHostPhase(host: inout P08DynamicHost, control: UnsafeMutablePointer<CounterControl>, report: HostAssemblyReport, failAfterRuntime: Bool, joinChecks: Int, early: UInt8, candidateFailure: RuntimeCompletePipelineStage?, reuse: UnsafeMutablePointer<P08HostReuseTranscript>?, baseline: UnsafeMutablePointer<P08ReuseFingerprint>?) -> P08BodyResult {
    let checks: Int
    if let reuse {
        checks = p08RunReuseHost(host: &host, control: control, transcript: reuse, baseline: baseline)
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
    return P08BodyResult(checks: checks, constructed: true, activationAttempted: true)
}

extension SignalAnalyzerPresetHostInstance where Owner: SignalAnalyzerPresetLiveOwner & ~Copyable & ~Escapable, Owner == P08DynamicHostOwner {
    @_lifetime(self: copy self)
    fileprivate mutating func p08UseOriginalDynamicHost(control: UnsafeMutablePointer<CounterControl>, report: HostAssemblyReport, failAfterRuntime: Bool, joinChecks: Int, early: UInt8, candidateFailure: RuntimeCompletePipelineStage?, reuse: UnsafeMutablePointer<P08HostReuseTranscript>?, baseline: UnsafeMutablePointer<P08ReuseFingerprint>?) -> P08BodyResult {
        if early == 4 { return P08BodyResult(checks: 1, constructed: true, activationAttempted: false) }
        return p08RunDynamicHostPhase(host: &self, control: control, report: report, failAfterRuntime: failAfterRuntime, joinChecks: joinChecks, early: early, candidateFailure: candidateFailure, reuse: reuse, baseline: baseline)
    }
    @_lifetime(self: copy self)
    fileprivate mutating func p08FinishOriginalDynamicHost() {
        self.teardown()
        let teardownStep = p08ReuseTeardownStep(host: &self)
        let finished = teardownStep == 8; precondition(finished)
    }
}

@inline(never)
fileprivate func p08CheckDynamicHostJoins(owner: inout P08DynamicHostOwner, models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, foreignModels: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, foreignRoot: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, control: UnsafeMutablePointer<CounterControl>, foreignControl: UnsafeMutablePointer<CounterControl>, facts: inout P08HostRunFacts) -> Int {
    let expected = counterJoinSnapshot(control), foreignExpected = counterJoinSnapshot(foreignControl)
    return counterCheckDynamicRejectedBindings(owner: &owner, models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, audit: facts.audit, report: facts.assembly.report, expected: expected, foreignExpected: foreignExpected)
}

@_lifetime(destination: copy session, copy semantic, copy values, copy models, copy root, borrow control, copy activationSpan)
@inline(never)
fileprivate func p08ConstructDynamicHost(session: consuming P08StorageSession, semantic: consuming SemanticRecordStore<CounterPayload>, values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>, activationSpan: Span<UInt8>, models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, foreignModels: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, foreignRoot: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, control: borrowing UnsafeMutablePointer<CounterControl>, foreignControl: UnsafeMutablePointer<CounterControl>, facts: inout P08HostRunFacts, failAfterRuntime: Bool, early: UInt8, destination: inout P08DynamicHost?, completion: inout P08HostConstructionFacts) {
    if early == 1 {
        var session = consume session; session.reset()
        completion.completed = P08BodyResult(checks: 1, constructed: false, activationAttempted: false)
        return
    }
    let supplied = session.intoDynamicSupplied(models: models.borrowedScope(), root: root.borrowedRoot(), semantic: semantic, values: values, control: CounterHostControl(pointer: control), audit: facts.audit)
    if early == 2 {
        var retired = supplied.retireInertStorage(); retired.resetAfterQuiescence()
        completion.completed = P08BodyResult(checks: 1, constructed: false, activationAttempted: false)
        return
    }
    var owner = P08DynamicHostOwner(supplied: supplied, activationSpan: activationSpan, assembly: facts.assembly, failAfterRuntime: failAfterRuntime)
    if early == 3 {
        p08FinishDynamicOwner(&owner)
        completion.completed = P08BodyResult(checks: 1, constructed: true, activationAttempted: false)
        return
    }
    completion.joinChecks = p08CheckDynamicHostJoins(owner: &owner, models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, facts: &facts)
    #if os(Linux)
    destination = SignalAnalyzerPresetHostInstances.raspberryPiDynamic(report: facts.assembly.report, owner: owner)
    #else
    destination = SignalAnalyzerPresetHostInstances.macOSDynamic(report: facts.assembly.report, owner: owner)
    #endif
}

@inline(never)
fileprivate func p08RunDynamicSessionPhase(session: consuming P08StorageSession, semantic: consuming SemanticRecordStore<CounterPayload>, values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>, activationSpan: Span<UInt8>, models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, foreignModels: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, foreignRoot: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, control: UnsafeMutablePointer<CounterControl>, foreignControl: UnsafeMutablePointer<CounterControl>, facts: inout P08HostRunFacts, failAfterRuntime: Bool, early: UInt8, candidateFailure: RuntimeCompletePipelineStage?, reuse: UnsafeMutablePointer<P08HostReuseTranscript>?, baseline: UnsafeMutablePointer<P08ReuseFingerprint>?) -> P08BodyResult {
    var completion = P08HostConstructionFacts()
    var host: P08DynamicHost? = nil
    p08ConstructDynamicHost(session: session, semantic: semantic, values: values, activationSpan: activationSpan, models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, facts: &facts, failAfterRuntime: failAfterRuntime, early: early, destination: &host, completion: &completion)
    defer { host?.p08FinishOriginalDynamicHost() }
    if let result = host?.p08UseOriginalDynamicHost(control: control, report: facts.assembly.report, failAfterRuntime: failAfterRuntime, joinChecks: completion.joinChecks, early: early, candidateFailure: candidateFailure, reuse: reuse, baseline: baseline) {
        let noEarlyCompletion = completion.completed == nil; precondition(noEarlyCompletion)
        return result
    }
    guard let result = completion.completed else { preconditionFailure("original host factory invariant") }
    return result
}
#endif

fileprivate func runP08ScopedBody(session: consuming P08StorageSession,
    models: consuming ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: consuming ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, semantic: consuming SemanticRecordStore<CounterPayload>, values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>, control: borrowing UnsafeMutablePointer<CounterControl>, facts: inout P08HostRunFacts, foreignModels: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, foreignRoot: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, foreignControl: UnsafeMutablePointer<CounterControl>, dynamic: Bool, failAfterRuntime: Bool, early: UInt8 = 0, candidateFailure: RuntimeCompletePipelineStage? = nil, reuse: UnsafeMutablePointer<P08HostReuseTranscript>? = nil, baseline: UnsafeMutablePointer<P08ReuseFingerprint>? = nil) -> Int {
    let activationBacking: InlineArray<1, UInt8> = [1]
    session.installProducerOrigin(control)
    let result: P08BodyResult
    #if !hasFeature(Embedded)
    if dynamic {
        result = p08RunDynamicSessionPhase(session: session, semantic: semantic, values: values, activationSpan: activationBacking.span, models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, facts: &facts, failAfterRuntime: failAfterRuntime, early: early, candidateFailure: candidateFailure, reuse: reuse, baseline: baseline)
    } else {
        result = p08RunStaticSessionPhase(session: session, semantic: semantic, values: values, activationSpan: activationBacking.span, models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, facts: &facts, failAfterRuntime: failAfterRuntime, early: early, candidateFailure: candidateFailure, reuse: reuse, baseline: baseline)
    }
    #else
    result = p08RunStaticSessionPhase(session: session, semantic: semantic, values: values, activationSpan: activationBacking.span, models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, facts: &facts, failAfterRuntime: failAfterRuntime, early: early, candidateFailure: candidateFailure, reuse: reuse, baseline: baseline)
    #endif
    p08CompleteBody(result, control: control)
    return result.checks
}

// Cold operations return owned audit/assembly/check facts only. They never retain
// a view/owner or start a live host, root, semantic, or values callback.
@inline(never)
fileprivate func p08PrepareStaticHost(outer: borrowing P08StaticOuterView, owner: inout P08TypedBackingOwner)
    -> (audit: RuntimeStorageAudit, assembly: CounterHostAssembly) {
    guard case .valid(let audit) = outer.audit(owner: owner), let assembly = CounterHostAssembly.validate(audit, kind: counterStaticHostKind) else { preconditionFailure("counter valid-only host") }
    return (audit, assembly)
}
@inline(never)
fileprivate func p08CheckStaticHostConfiguration(_ facts: inout P08HostRunFacts) -> Int {
    let ownedChecks = counterOwnedSchedulerCompatibility(facts.assembly.report)
    let rejected0 = CounterHostAssembly.validate(facts.audit, kind: counterStaticHostKind, sourceCallbacks: 21) == nil
    precondition(rejected0)
    let rejected1 = CounterHostAssembly.validate(facts.audit, kind: counterStaticHostKind, repositoryCallbacks: 2) == nil
    precondition(rejected1)
    let rejected2 = CounterHostAssembly.validate(facts.audit, kind: counterStaticHostKind, useCaseCallbacks: 2) == nil
    precondition(rejected2)
    let rejected3 = CounterHostAssembly.validate(facts.audit, kind: counterStaticHostKind, nonTransitionPublications: 2) == nil
    precondition(rejected3)
    return ownedChecks
}
@inline(never)
fileprivate func p08InstallStaticHostPlan(owner: inout P08TypedBackingOwner, outer: borrowing P08StaticOuterView, write: CounterTiledPixelWrite?, into facts: inout P08HostRunFacts?) {
    let vacant = facts == nil; precondition(vacant)
    #if hasFeature(Embedded) || GIFTUI_COUNTER_TILED
    if let write { outer.control.pointee.backend.write = write }
    #endif
    let (audit, assembly) = p08PrepareStaticHost(outer: outer, owner: &owner)
    facts = .init(limits: outer.limits, audit: audit, assembly: assembly)
}

@inline(never)
fileprivate func p08RunPreparedStaticHost(owner: inout P08TypedBackingOwner, facts: inout P08HostRunFacts, rootStorage: UnsafeMutablePointer<CounterStaticRootStorage>, semanticStorage: UnsafeMutablePointer<StaticSemanticRecordStorage>, canvasStorage: UnsafeMutablePointer<StaticCanvasValueStorage>, recordsBacking: UnsafeMutableBufferPointer<SemanticRuntimeRecord>, pathsBacking: UnsafeMutableBufferPointer<SemanticPathEntry>, payloadsBacking: UnsafeMutableBufferPointer<CounterPayload?>, scalarsBacking: UnsafeMutableBufferPointer<UInt32>, entriesBacking: UnsafeMutableBufferPointer<CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?>, control: UnsafeMutablePointer<CounterControl>, failAfterRuntime: Bool, early: UInt8 = 0, candidateFailure: RuntimeCompletePipelineStage? = nil, reuse: UnsafeMutablePointer<P08HostReuseTranscript>? = nil, baseline: UnsafeMutablePointer<P08ReuseFingerprint>? = nil, foreignRootStorage: UnsafeMutablePointer<CounterStaticRootStorage>? = nil, foreignControlStorage: UnsafeMutablePointer<CounterControl>? = nil) -> Int {
    return counterForeignJoinScope(backing: foreignRootStorage, foreign: foreignControlStorage) { foreignModels, foreignRoot, foreignControl in
        let ownedChecks = p08CheckStaticHostConfiguration(&facts)
        var checks = 0
        do throws(ObservableStateError) {
            try rootStorage.pointee.withLifetime(limits: facts.limits.observableState) { (models, root) throws(ObservableStateError) in
                do throws(SemanticExpansionError) {
                    var records = MutableSpan(_unsafeStart: recordsBacking.baseAddress!, count: recordsBacking.count)
                    var paths = MutableSpan(_unsafeStart: pathsBacking.baseAddress!, count: pathsBacking.count)
                    var payloads = MutableSpan(_unsafeStart: payloadsBacking.baseAddress!, count: payloadsBacking.count)
                    var scalars = MutableSpan(_unsafeStart: scalarsBacking.baseAddress!, count: scalarsBacking.count)
                    try semanticStorage.pointee.withLifetime(configuredLimits: counterSemanticConfiguration(facts.limits), records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) { (semantic) throws(SemanticExpansionError) in
                        do throws(DrawingError) {
                            var entries = MutableSpan(_unsafeStart: entriesBacking.baseAddress!, count: entriesBacking.count)
                            try canvasStorage.pointee.withLifetime(entries: &entries, table: CounterValueTable(), capacity: 1, limits: facts.limits.staticCanvas!) { values in
                                checks = withP08Storage(backing: &owner) { session in
                                    runP08ScopedBody(session: session, models: models.borrowedScope(), root: root.borrowedRoot(), semantic: semantic.borrowedStore(), values: values.borrowedValues(), control: control, facts: &facts, foreignModels: foreignModels, foreignRoot: foreignRoot, foreignControl: foreignControl, dynamic: false, failAfterRuntime: failAfterRuntime, early: early, candidateFailure: candidateFailure, reuse: reuse, baseline: baseline)
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

fileprivate func runP08StaticHost(owner: inout P08TypedBackingOwner, outer: borrowing P08StaticOuterView, failAfterRuntime: Bool, early: UInt8 = 0, candidateFailure: RuntimeCompletePipelineStage? = nil, write: CounterTiledPixelWrite? = nil, reuse: UnsafeMutablePointer<P08HostReuseTranscript>? = nil, baseline: UnsafeMutablePointer<P08ReuseFingerprint>? = nil, foreignRootStorage: UnsafeMutablePointer<CounterStaticRootStorage>? = nil, foreignControlStorage: UnsafeMutablePointer<CounterControl>? = nil) -> Int {
    // Field facts remain local to the enclosing synchronous selected reservation.
    let control = outer.control
    let rootStorage = outer.root, semanticStorage = outer.semantic, canvasStorage = outer.canvas
    let recordsBacking = outer.records, pathsBacking = outer.paths
    let payloadsBacking = outer.payloads, scalarsBacking = outer.scalars, entriesBacking = outer.entries
    var facts: P08HostRunFacts? = nil
    p08InstallStaticHostPlan(owner: &owner, outer: outer, write: write, into: &facts)
    let checks = p08RunPreparedStaticHost(owner: &owner, facts: &facts!, rootStorage: rootStorage, semanticStorage: semanticStorage, canvasStorage: canvasStorage, recordsBacking: recordsBacking, pathsBacking: pathsBacking, payloadsBacking: payloadsBacking, scalarsBacking: scalarsBacking, entriesBacking: entriesBacking, control: control, failAfterRuntime: failAfterRuntime, early: early, candidateFailure: candidateFailure, reuse: reuse, baseline: baseline, foreignRootStorage: foreignRootStorage, foreignControlStorage: foreignControlStorage)
    p08ClearHostPlan(&facts)
    return checks
}
#if !hasFeature(Embedded)
package func p08CounterHost(write: CounterTiledPixelWrite? = nil, backing: UnsafeMutableRawBufferPointer? = nil) -> Int {
    var models = ObservableModelOwnerNamespace(); var semantics = SemanticRecordOwnerNamespace()
    do {
        var checks = 0
        for scenario: UInt8 in 0...8 {
            checks += withP08SelectedStatic(modelOwner: try models.issue(), semanticOwner: try semantics.issue(), backing: nil) { owner, outer in
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
            withP08SelectedStatic(modelOwner: firstModel, semanticOwner: firstSemantic, backing: nil) { owner, outer in
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
#endif

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
@inline(never)
fileprivate func p08DeinitializeDynamicCanvas(_ field: UnsafeMutablePointer<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>) { field.deinitialize(count: 1) }
@inline(never)
fileprivate func p08DeinitializeDynamicSemantic(_ field: UnsafeMutablePointer<DynamicSemanticRecordStorage<CounterPayload>>) { field.deinitialize(count: 1) }
@inline(never)
fileprivate func p08DeinitializeDynamicRoot(_ field: UnsafeMutablePointer<DynamicObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>>) { field.deinitialize(count: 1) }
@inline(never)
fileprivate func p08InitializeDynamicRoot(_ field: UnsafeMutablePointer<DynamicObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>>, owner: ObservableModelOwnerIdentity) {
    field.initialize(to: DynamicObservableRootAdapter(identity: owner, schema: 1, needsCapture: false, modelLimit: 2, claimLimit: 4, pinLimit: 2, captureLimit: 0)!)
}
@inline(never)
fileprivate func p08InitializeDynamicSemantic(_ field: UnsafeMutablePointer<DynamicSemanticRecordStorage<CounterPayload>>, owner: SemanticRecordOwnerIdentity) {
    field.initialize(to: DynamicSemanticRecordStorage(limits: counterSemanticLimits, owner: owner))
}
@inline(never)
fileprivate func p08InitializeDynamicCanvas(_ field: UnsafeMutablePointer<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>) { field.initialize(to: DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>(capacity: 1)) }
fileprivate struct P08DynamicOuterView: ~Copyable {
    let limits: RuntimeProfileLimits
    let root: UnsafeMutablePointer<DynamicObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>>
    let semantic: UnsafeMutablePointer<DynamicSemanticRecordStorage<CounterPayload>>
    let canvas: UnsafeMutablePointer<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>
    let control: UnsafeMutablePointer<CounterControl>
    borrowing func reconstruct(modelOwner: ObservableModelOwnerIdentity, semanticOwner: SemanticRecordOwnerIdentity) {
        p08RequireRetiredControl(control)
        CounterControl.requireVacantRuntimeSlot(at: control)
        p08DeinitializeOuterControl(control); p08DeinitializeDynamicCanvas(canvas)
        p08DeinitializeDynamicSemantic(semantic); p08DeinitializeDynamicRoot(root)
        p08InitializeDynamicRoot(root, owner: modelOwner)
        p08InitializeDynamicSemantic(semantic, owner: semanticOwner)
        p08InitializeDynamicCanvas(canvas); p08InitializeOuterControl(control)
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
            factoryRegion: .elements(UInt8.self, count: MemoryLayout<P08DynamicOuter>.stride - MemoryLayout<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>.size - MemoryLayout<CounterControl>.size + MemoryLayout<P08DynamicReservation>.stride - optionalBytes + MemoryLayout<P08TypedBackingOwner>.stride + MemoryLayout<P08HostRunFacts?>.stride, family: 24),
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
                defer { CounterControl.requireVacantRuntimeSlot(at: control) }
                return body(&owner, view)
            }
        } } } }
}
@inline(never)
fileprivate func p08PrepareDynamicHost(outer: borrowing P08DynamicOuterView, owner: inout P08TypedBackingOwner)
    -> (audit: RuntimeStorageAudit, assembly: CounterHostAssembly) {
    guard case .valid(let audit) = outer.audit(owner: owner), let assembly = CounterHostAssembly.validate(audit, kind: counterDynamicHostKind) else { preconditionFailure("counter Dynamic valid-only host") }
    return (audit, assembly)
}
@inline(never)
fileprivate func p08CheckDynamicHostConfiguration(_ facts: inout P08HostRunFacts) {
    let rejected0 = CounterHostAssembly.validate(facts.audit, kind: counterDynamicHostKind, sourceCallbacks: 21) == nil
    precondition(rejected0)
    let rejected1 = CounterHostAssembly.validate(facts.audit, kind: counterDynamicHostKind, repositoryCallbacks: 2) == nil
    precondition(rejected1)
    let rejected2 = CounterHostAssembly.validate(facts.audit, kind: counterDynamicHostKind, useCaseCallbacks: 2) == nil
    precondition(rejected2)
    let rejected3 = CounterHostAssembly.validate(facts.audit, kind: counterDynamicHostKind, nonTransitionPublications: 2) == nil
    precondition(rejected3)
}
@inline(never)
fileprivate func p08InstallDynamicHostPlan(owner: inout P08TypedBackingOwner, outer: borrowing P08DynamicOuterView, into facts: inout P08HostRunFacts?) {
    let vacant = facts == nil; precondition(vacant)
    let (audit, assembly) = p08PrepareDynamicHost(outer: outer, owner: &owner)
    facts = .init(limits: outer.limits, audit: audit, assembly: assembly)
}

@inline(never)
fileprivate func p08RunPreparedDynamicHost(owner: inout P08TypedBackingOwner, facts: inout P08HostRunFacts, rootStorage: UnsafeMutablePointer<DynamicObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>>, semanticStorage: UnsafeMutablePointer<DynamicSemanticRecordStorage<CounterPayload>>, canvasStorage: UnsafeMutablePointer<DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>>, control: UnsafeMutablePointer<CounterControl>, failAfterRuntime: Bool, early: UInt8 = 0, candidateFailure: RuntimeCompletePipelineStage? = nil, reuse: UnsafeMutablePointer<P08HostReuseTranscript>? = nil, baseline: UnsafeMutablePointer<P08ReuseFingerprint>? = nil) -> Int {
    p08CheckDynamicHostConfiguration(&facts)
    return counterForeignJoinScope { foreignModels, foreignRoot, foreignControl in
        var checks = 0
        do throws(ObservableStateError) {
            try rootStorage.pointee.withLifetime(limits: facts.limits.observableState) { (models, root) throws(ObservableStateError) in
                do throws(SemanticExpansionError) {
                    try semanticStorage.pointee.withLifetime(configuredLimits: counterSemanticConfiguration(facts.limits)) { (semantic) throws(SemanticExpansionError) in
                        do throws(DrawingError) {
                            try canvasStorage.pointee.withLifetime(table: CounterValueTable(), limits: counterCanvasLimits, configuredCapacity: 1) { values in
                                checks = withP08Storage(backing: &owner) { session in
                                    runP08ScopedBody(session: session, models: models.borrowedScope(), root: root.borrowedRoot(), semantic: semantic.borrowedStore(), values: values.borrowedValues(), control: control, facts: &facts, foreignModels: foreignModels, foreignRoot: foreignRoot, foreignControl: foreignControl, dynamic: true, failAfterRuntime: failAfterRuntime, early: early, candidateFailure: candidateFailure, reuse: reuse, baseline: baseline)
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

fileprivate func runP08DynamicHost(owner: inout P08TypedBackingOwner, outer: borrowing P08DynamicOuterView, failAfterRuntime: Bool, early: UInt8 = 0, candidateFailure: RuntimeCompletePipelineStage? = nil, reuse: UnsafeMutablePointer<P08HostReuseTranscript>? = nil, baseline: UnsafeMutablePointer<P08ReuseFingerprint>? = nil) -> Int {
    // Capture owned field facts, never the borrowed outer aggregate.
    let control = outer.control
    let rootStorage = outer.root, semanticStorage = outer.semantic, canvasStorage = outer.canvas
    var facts: P08HostRunFacts? = nil
    p08InstallDynamicHostPlan(owner: &owner, outer: outer, into: &facts)
    let checks = p08RunPreparedDynamicHost(owner: &owner, facts: &facts!, rootStorage: rootStorage, semanticStorage: semanticStorage, canvasStorage: canvasStorage, control: control, failAfterRuntime: failAfterRuntime, early: early, candidateFailure: candidateFailure, reuse: reuse, baseline: baseline)
    p08ClearHostPlan(&facts)
    return checks
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

#if !hasFeature(Embedded)
package func p08CounterGraph(backing: UnsafeMutableRawBufferPointer? = nil) -> Int {
    p08CheckGraphDefinition()
    var modelOwners = ObservableModelOwnerNamespace()
    var semanticOwners = SemanticRecordOwnerNamespace()
    do {
        return withP08SelectedStatic(modelOwner: try modelOwners.issue(), semanticOwner: try semanticOwners.issue(), backing: nil) { owner, outer in
        return p08CheckGraphSelection(owner: owner, outer: outer)

        }
    } catch { preconditionFailure("counter graph profile identities") }
}
#endif
fileprivate func p08CheckGraphDefinition() {

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
}
fileprivate func p08CheckGraphSelection(owner: borrowing P08TypedBackingOwner, outer: borrowing P08StaticOuterView) -> Int {
    var count = 46
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
            // Keep the complete record oracle concrete: generic Optional/record
            // equality otherwise requests a runtime Equatable witness here.
            let afterDiscard = interaction.committedRecord(for: key(0))
            let recordMatches: Bool
            if let afterDiscard {
                recordMatches = afterDiscard.identity == before.identity
                    && afterDiscard.generation == before.generation
                    && afterDiscard.isEnabled == before.isEnabled
                    && afterDiscard.hitBounds == before.hitBounds
                    && afterDiscard.paintOrder == before.paintOrder
                    && afterDiscard.action == before.action
                    && afterDiscard.targetGeneration == before.targetGeneration
            } else { recordMatches = false }
            precondition(recordMatches && interaction.committedRevision == revision)
            let outcome = interaction.resolveUp(captured, at: .init(x: 1, y: 1))
            let activationMatches: Bool
            if case .activationAdmitted(let admitted) = outcome {
                activationMatches = admitted.identity == captured.identity
                    && admitted.generation == captured.generation
            } else { activationMatches = false }
            precondition(activationMatches)
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
        #if os(macOS) && !GIFTUI_COUNTER_ROUTE_DYNAMIC && !hasFeature(Embedded)
            counterDiagnosticRole(
                event.bankKind, event.leftBefore.id.rawValue, event.leftBefore.address,
                event.leftCount, event.leftBefore.retainedBytes, event.rightBefore.id.rawValue,
                event.rightBefore.address, event.rightCount, event.rightBefore.retainedBytes,
                event.leftAfter.id.rawValue, event.rightAfter.id.rawValue)
        #elseif !hasFeature(Embedded)
            print(
                "SO06 role", event.bankKind, event.leftBefore.id.rawValue, event.leftBefore.address,
                event.leftCount, event.leftBefore.retainedBytes, event.rightBefore.id.rawValue,
                event.rightBefore.address, event.rightCount, event.rightBefore.retainedBytes, "=>",
                event.leftAfter.id.rawValue, event.rightAfter.id.rawValue)
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
#if !hasFeature(Embedded)
package func counterExerciseScopedStorage(backing: UnsafeMutableRawBufferPointer? = nil, write: CounterTiledPixelWrite? = nil) -> Int {
    counterExerciseScopedStorage(includeDynamicValidation: true, backing: backing, write: write)
}

#if !GIFTUI_COUNTER_ROUTE_DYNAMIC
// The mixed functional corpus remains the default. This prospective resource
// entry keeps all Static scenarios and their diagnostics, without executing the
// intentional Dynamic validation controls before or within its process.
package func counterExerciseStaticScopedStorage(backing: UnsafeMutableRawBufferPointer? = nil, write: CounterTiledPixelWrite? = nil) -> Int {
    counterExerciseScopedStorage(includeDynamicValidation: false, backing: backing, write: write)
}
#endif

@inline(__always)
private func counterExerciseScopedStorage(includeDynamicValidation: Bool, backing: UnsafeMutableRawBufferPointer?, write: CounterTiledPixelWrite?) -> Int {
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
    let invalidCapacityCases: InlineArray<5, InlineArray<5, UInt16>> = [
        [1, 2, 2, 2, 2],
        [2, 1, 2, 2, 1],
        [2, 2, 1, 1, 2],
        [2, 2, 2, 1, 2],
        [2, 2, 2, 2, 1],
    ]
    for capacityIndex in 0..<5 {
        let capacities = invalidCapacityCases[capacityIndex]
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
        if includeDynamicValidation {
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
    }
    #endif
    var models = ObservableModelOwnerNamespace(); var semantics = SemanticRecordOwnerNamespace()
    do {

        for early: UInt8 in 1...5 {
            checks += withP08SelectedStatic(modelOwner: try models.issue(), semanticOwner: try semantics.issue(), backing: nil) { owner, outer in runP08StaticHost(owner: &owner, outer: outer, failAfterRuntime: false, early: early, write: write) }
        }
        for raw: UInt8 in 0...10 {
            checks += withP08SelectedStatic(modelOwner: try models.issue(), semanticOwner: try semantics.issue(), backing: nil) { owner, outer in runP08StaticHost(owner: &owner, outer: outer, failAfterRuntime: false, candidateFailure: RuntimeCompletePipelineStage(rawValue: raw)!, write: write) }
        }
        #if !hasFeature(Embedded)
        if includeDynamicValidation {
            let dynamicIDs: InlineArray<14, P08PhysicalID?> = [.g0, .g1, .g3, .g4, .c0, .h0, .r0, .r1, .h1, nil, nil, nil, nil, nil]
            for index in 0..<9 { for after in [false, true] {
                let fault = P08AcquisitionFault(id: dynamicIDs[index]!, completed: 0, afterInstall: after)
                checks += withP08DynamicReservation { owner in precondition(owner.initialize(fault: fault) != nil); return p08VerifyFault(owner, fault: fault, ids: dynamicIDs, objects: 9) }
            } }
            for capacityIndex in 0..<5 {
                let capacities = invalidCapacityCases[capacityIndex]
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
        }
        #endif
    } catch { preconditionFailure("scoped corpus identities") }
    return checks
}
#endif
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

@inline(never)
fileprivate func p08RuntimeSlotGuardControls(_ control: UnsafeMutablePointer<CounterControl>) -> Int {
    let before = CounterRuntimeSlotObservation(control)
    guard let owner = control.pointee.runtimeSlotOwner else { preconditionFailure("missing actual runtime owner") }
    let wrong = owner.addingReportingOverflow(1)
    precondition(!wrong.overflow)
    let duplicate = control.pointee.tryClaimRuntimeSlot()
    let wrongClear = control.pointee.tryClearRuntimeSlot(wrong.partialValue)
    let same = CounterRuntimeSlotObservation(control) == before
    precondition(duplicate == nil && !wrongClear && same)
    return 3
}
#if hasFeature(Embedded)
// The layout visitor emits owned numbers only, never a typed capability. The
// same checked seven-region derivation serves binding and strict scalar roots.
fileprivate struct P08MetadataLayoutSummary {
    let cursor: Int
    let maximumAlignment: Int
    let extent: Int
}
@inline(__always)
fileprivate func p08VisitMetadataField<T: ~Copyable>(_ type: T.Type, index: Int,
    cursor: inout Int, maximum: inout Int,
    visit: (Int, Int, Int, Int, Int) -> Void) -> Bool {
    let alignment = MemoryLayout<T>.alignment
    guard alignment > 0 else { return false }
    let remainder = cursor % alignment
    let padding = remainder == 0 ? 0 : alignment - remainder
    let (offset, offsetOverflow) = cursor.addingReportingOverflow(padding)
    let (end, endOverflow) = offset.addingReportingOverflow(MemoryLayout<T>.stride)
    guard !offsetOverflow, !endOverflow else { return false }
    visit(index, offset, MemoryLayout<T>.size, MemoryLayout<T>.stride, alignment)
    cursor = end; maximum = max(maximum, alignment)
    return true
}
@inline(__always)
fileprivate func p08DeriveMetadataLayout(_ visit: (Int, Int, Int, Int, Int) -> Void) -> P08MetadataLayoutSummary? {
    var cursor = 0, maximum = 1
    guard p08VisitMetadataField(P08EmbeddedOuter.self, index: 0, cursor: &cursor, maximum: &maximum, visit: visit),
        p08VisitMetadataField(P08TypedBackingOwner.self, index: 1, cursor: &cursor, maximum: &maximum, visit: visit),
        p08VisitMetadataField(P08ReuseFingerprint.self, index: 2, cursor: &cursor, maximum: &maximum, visit: visit),
        p08VisitMetadataField(InlineArray<14, P08InitializedEntry?>.self, index: 3, cursor: &cursor, maximum: &maximum, visit: visit),
        p08VisitMetadataField(P08HostReuseTranscript.self, index: 4, cursor: &cursor, maximum: &maximum, visit: visit),
        p08VisitMetadataField(CounterStaticRootStorage.self, index: 5, cursor: &cursor, maximum: &maximum, visit: visit),
        p08VisitMetadataField(CounterControl.self, index: 6, cursor: &cursor, maximum: &maximum, visit: visit)
    else { return nil }
    let remainder = cursor % maximum
    let padding = remainder == 0 ? 0 : maximum - remainder
    let (extent, overflow) = cursor.addingReportingOverflow(padding)
    guard !overflow else { return nil }
    return .init(cursor: cursor, maximumAlignment: maximum, extent: extent)
}
fileprivate struct P08MetadataPointers: ~Copyable {
    let outer: UnsafeMutablePointer<P08EmbeddedOuter>
    let owner: UnsafeMutablePointer<P08TypedBackingOwner>
    let before: UnsafeMutablePointer<P08ReuseFingerprint>
    let original: UnsafeMutablePointer<InlineArray<14, P08InitializedEntry?>>
    let transcript: UnsafeMutablePointer<P08HostReuseTranscript>
    let foreignRoot: UnsafeMutablePointer<CounterStaticRootStorage>
    let foreignControl: UnsafeMutablePointer<CounterControl>
    init(donor: UnsafeMutableRawBufferPointer) {
        var offsets: InlineArray<7, Int> = .init(repeating: 0)
        guard let summary = p08DeriveMetadataLayout({ index, offset, _, stride, alignment in
            precondition(index >= 0 && index < 7 && stride > 0)
            let address = UInt(bitPattern: donor.baseAddress!).addingReportingOverflow(UInt(offset))
            let end = offset.addingReportingOverflow(stride)
            precondition(!address.overflow && address.partialValue % UInt(alignment) == 0)
            precondition(!end.overflow && end.partialValue <= donor.count)
            offsets[index] = offset
        }), summary.extent <= donor.count, counterEmbeddedSlotBytes % summary.maximumAlignment == 0
        else { preconditionFailure("donor metadata bounds/alignment") }
        outer = donor.baseAddress!.advanced(by: offsets[0]).bindMemory(to: P08EmbeddedOuter.self, capacity: 1)
        owner = donor.baseAddress!.advanced(by: offsets[1]).bindMemory(to: P08TypedBackingOwner.self, capacity: 1)
        before = donor.baseAddress!.advanced(by: offsets[2]).bindMemory(to: P08ReuseFingerprint.self, capacity: 1)
        original = donor.baseAddress!.advanced(by: offsets[3]).bindMemory(to: InlineArray<14, P08InitializedEntry?>.self, capacity: 1)
        transcript = donor.baseAddress!.advanced(by: offsets[4]).bindMemory(to: P08HostReuseTranscript.self, capacity: 1)
        foreignRoot = donor.baseAddress!.advanced(by: offsets[5]).bindMemory(to: CounterStaticRootStorage.self, capacity: 1)
        foreignControl = donor.baseAddress!.advanced(by: offsets[6]).bindMemory(to: CounterControl.self, capacity: 1)
    }
}
// Each normal typed constructor/destructor has a distinct cold boundary. Its
// frame returns before another object phase or any scoped/host callback starts.
@inline(never)
fileprivate func p08InitializeMetadataOuter(_ pointer: UnsafeMutablePointer<P08EmbeddedOuter>,
    active: UnsafeMutableRawBufferPointer, modelOwner: ObservableModelOwnerIdentity,
    semanticOwner: SemanticRecordOwnerIdentity, surplus: Int) {
    pointer.initialize(to: P08EmbeddedOuter(modelOwner: modelOwner, semanticOwner: semanticOwner,
        backing: active, limits: counterActualLimits(.static), surplus: surplus))
}
@inline(never)
fileprivate func p08InitializeMetadataOwner(_ pointer: UnsafeMutablePointer<P08TypedBackingOwner>,
    outer: inout P08EmbeddedOuter, active: UnsafeMutableRawBufferPointer, invalidExtent: Bool) {
    pointer.initialize(to: P08TypedBackingOwner(slots: .static(outer.storageSlots(r0Extent: invalidExtent ? MemoryLayout<CounterStaticCommitted>.stride - 1 : nil)), identity: UInt(bitPattern: active.baseAddress!)))
}
@inline(never)
fileprivate func p08InitializeMetadataBaseline(_ pointer: UnsafeMutablePointer<P08ReuseFingerprint>) {
    pointer.initialize(to: P08ReuseFingerprint())
}
@inline(never)
fileprivate func p08InitializeMetadataInventory(_ pointer: UnsafeMutablePointer<InlineArray<14, P08InitializedEntry?>>) {
    pointer.initialize(to: .init(repeating: nil))
}
@inline(never)
fileprivate func p08InitializeMetadataTranscript(_ pointer: UnsafeMutablePointer<P08HostReuseTranscript>) {
    pointer.initialize(to: P08HostReuseTranscript())
}
@inline(never)
fileprivate func p08InitializeMetadataForeignRoot(_ pointer: UnsafeMutablePointer<CounterStaticRootStorage>) {
    var namespace = ObservableModelOwnerNamespace()
    do {
        let identity = try namespace.issue()
        precondition(identity.rawValue == 0)
        pointer.initialize(to: CounterStaticRootStorage(identity: identity, schema: 1, needsCapture: false, modelLimit: 2, claimLimit: 4, pinLimit: 2, captureLimit: 0)!)
    } catch { preconditionFailure("foreign metadata identity") }
}
@inline(never)
fileprivate func p08InitializeMetadataForeignControl(_ pointer: UnsafeMutablePointer<CounterControl>) {
    pointer.initialize(to: CounterControl())
}
@inline(never)
fileprivate func p08PrepareMetadata(_ p: borrowing P08MetadataPointers,
    active: UnsafeMutableRawBufferPointer, modelOwner: ObservableModelOwnerIdentity,
    semanticOwner: SemanticRecordOwnerIdentity, surplus: Int, invalidExtent: Bool,
    stopAfter: UInt8, prefix: inout UInt8) {
    let outer = p.outer, owner = p.owner, before = p.before, original = p.original
    let transcript = p.transcript, foreignRoot = p.foreignRoot, foreignControl = p.foreignControl
    precondition(prefix == 0 && stopAfter <= 7)
    if stopAfter == 0 { return }
    p08InitializeMetadataOuter(outer, active: active, modelOwner: modelOwner, semanticOwner: semanticOwner, surplus: surplus)
    prefix = 1
    if stopAfter == 1 { return }
    p08InitializeMetadataOwner(owner, outer: &outer.pointee, active: active, invalidExtent: invalidExtent)
    prefix = 2
    if stopAfter == 2 { return }
    p08InitializeMetadataBaseline(before)
    prefix = 3
    if stopAfter == 3 { return }
    p08InitializeMetadataInventory(original)
    prefix = 4
    if stopAfter == 4 { return }
    p08InitializeMetadataTranscript(transcript)
    prefix = 5
    if stopAfter == 5 { return }
    p08InitializeMetadataForeignRoot(foreignRoot)
    prefix = 6
    if stopAfter == 6 { return }
    p08InitializeMetadataForeignControl(foreignControl)
    prefix = 7
}
@inline(never)
fileprivate func p08FinishMetadataOwner(_ owner: inout P08TypedBackingOwner) -> Bool {
    owner.finishMetadataReservation()
}
@inline(never)
fileprivate func p08DestroyMetadataForeignControl(_ pointer: UnsafeMutablePointer<CounterControl>) {
    CounterControl.requireVacantRuntimeSlot(at: pointer)
    pointer.deinitialize(count: 1)
}
@inline(never)
fileprivate func p08DestroyMetadataForeignRoot(_ pointer: UnsafeMutablePointer<CounterStaticRootStorage>) {
    pointer.deinitialize(count: 1)
}
@inline(never)
fileprivate func p08DestroyMetadataTranscript(_ pointer: UnsafeMutablePointer<P08HostReuseTranscript>) {
    pointer.deinitialize(count: 1)
}
@inline(never)
fileprivate func p08DestroyMetadataInventory(_ pointer: UnsafeMutablePointer<InlineArray<14, P08InitializedEntry?>>) {
    pointer.deinitialize(count: 1)
}
@inline(never)
fileprivate func p08DestroyMetadataBaseline(_ pointer: UnsafeMutablePointer<P08ReuseFingerprint>) {
    pointer.deinitialize(count: 1)
}
@inline(never)
fileprivate func p08DestroyMetadataOwner(_ pointer: UnsafeMutablePointer<P08TypedBackingOwner>) {
    pointer.deinitialize(count: 1)
}
@inline(never)
fileprivate func p08DestroyMetadataOuter(_ pointer: UnsafeMutablePointer<P08EmbeddedOuter>) {
    pointer.deinitialize(count: 1)
}
@inline(never)
fileprivate func p08DestroyMetadata(_ p: borrowing P08MetadataPointers, prefix: inout UInt8) -> Bool {
    let outer = p.outer, owner = p.owner, before = p.before, original = p.original
    let transcript = p.transcript, foreignRoot = p.foreignRoot, foreignControl = p.foreignControl
    // Reserved/acquired0 is a metadata prefix, not an idle bank reservation.
    if prefix >= 2 {
        guard p08FinishMetadataOwner(&owner.pointee) else { return false }
    }
    if prefix >= 7 { p08DestroyMetadataForeignControl(foreignControl) }
    if prefix >= 6 { p08DestroyMetadataForeignRoot(foreignRoot) }
    if prefix >= 5 { p08DestroyMetadataTranscript(transcript) }
    if prefix >= 4 { p08DestroyMetadataInventory(original) }
    if prefix >= 3 { p08DestroyMetadataBaseline(before) }
    if prefix >= 2 { p08DestroyMetadataOwner(owner) }
    if prefix >= 1 { p08DestroyMetadataOuter(outer) }
    prefix = 0
    return true
}
fileprivate func p08MetadataOuterView(_ outer: borrowing P08EmbeddedOuter) -> P08StaticOuterView {
    var occupied = 0
    for index in 0..<25 {
        let sum = occupied.addingReportingOverflow(outer.layout.regions[index]!.extent)
        precondition(!sum.overflow); occupied = sum.partialValue
    }
    let metadata = outer.bytes.count - occupied + MemoryLayout<RuntimeProfileLimits>.stride + MemoryLayout<Bool>.stride - CounterSemanticBacking.paddingBytes
    return .init(limits: outer.limits.pointee, root: outer.root, semantic: outer.semantic,
        records: .init(start: outer.records, count: 128), paths: .init(start: outer.paths, count: 384),
        payloads: .init(start: outer.payloads, count: 256), scalars: .init(start: outer.scalars, count: 128),
        canvas: outer.canvas, entries: .init(start: outer.entries, count: 1), control: outer.control, outerMetadataBytes: metadata)
}
fileprivate enum P08EmbeddedCasePlan {
    case graph, host(UInt8), twoHosts, early(UInt8), candidate(UInt8), exchange(Int), invalidExtent
    case fault(P08PhysicalID, Int, Bool)
    case metadataPrefix(UInt8)
    var ranges: (active: Int, slots: Int, donor: Int) {
        switch self {
        case .host(let scenario):
            precondition(scenario <= 8)
            let active = scenario < 3 ? Int(scenario) : 3
            return (active, 1, active == 3 ? 2 : 3)
        case .exchange(let surplus):
            precondition(surplus == 0 || surplus == 64)
            return (0, surplus == 0 ? 1 : 2, 3)
        default: return (0, 1, 3)
        }
    }
}
fileprivate enum P08CallerPhase { case idle, active, donor, poisoned }
fileprivate struct P08CallerCustody: ~Copyable {
    private let bytes: UnsafeMutableRawBufferPointer
    private var phases: InlineArray<4, P08CallerPhase> = .init(repeating: .idle)
    private var busy = false
    private var metadataPrefix: UInt8 = 0
    init(_ bytes: UnsafeMutableRawBufferPointer) {
        precondition(bytes.count == counterEmbeddedSlotCount * counterEmbeddedSlotBytes)
        precondition(bytes.baseAddress != nil && UInt(bitPattern: bytes.baseAddress!) % 8 == 0)
        self.bytes = bytes
    }
    mutating func run(_ plan: P08EmbeddedCasePlan, model: ObservableModelOwnerIdentity,
        semantic: SemanticRecordOwnerIdentity, secondModel: ObservableModelOwnerIdentity? = nil,
        secondSemantic: SemanticRecordOwnerIdentity? = nil, write: CounterTiledPixelWrite? = nil) -> Int {
        let notBusy = !busy, emptyPrefix = metadataPrefix == 0
        let canEnter = notBusy && emptyPrefix
        precondition(canEnter)
        let range = plan.ranges
        let (activeStart, startOverflow) = range.active.multipliedReportingOverflow(by: counterEmbeddedSlotBytes)
        let (activeCount, countOverflow) = range.slots.multipliedReportingOverflow(by: counterEmbeddedSlotBytes)
        let (activeEnd, endOverflow) = activeStart.addingReportingOverflow(activeCount)
        let (donorStart, donorOverflow) = range.donor.multipliedReportingOverflow(by: counterEmbeddedSlotBytes)
        let (donorEnd, donorEndOverflow) = donorStart.addingReportingOverflow(counterEmbeddedSlotBytes)
        precondition(!startOverflow && !countOverflow && !endOverflow && !donorOverflow && !donorEndOverflow)
        precondition(activeStart >= 0 && activeEnd <= bytes.count && donorStart >= 0 && donorEnd <= bytes.count)
        precondition(activeEnd <= donorStart || donorEnd <= activeStart)
        for slot in range.active..<(range.active + range.slots) {
            let idle = phases[slot] == .idle; precondition(idle)
        }
        let donorIdle = phases[range.donor] == .idle; precondition(donorIdle)
        busy = true
        for slot in range.active..<(range.active + range.slots) { phases[slot] = .active }
        phases[range.donor] = .donor
        let active = UnsafeMutableRawBufferPointer(rebasing: bytes[activeStart..<activeEnd])
        let donor = UnsafeMutableRawBufferPointer(rebasing: bytes[donorStart..<donorEnd])
        let p = P08MetadataPointers(donor: donor)
        let surplus: Int
        if case .exchange(let value) = plan { surplus = value } else { surplus = 0 }
        let invalid: Bool
        if case .invalidExtent = plan { invalid = true } else { invalid = false }
        let prefixLimit: UInt8
        if case .metadataPrefix(let value) = plan { prefixLimit = value } else { prefixLimit = 7 }
        p08PrepareMetadata(p, active: active, modelOwner: model, semanticOwner: semantic,
            surplus: surplus, invalidExtent: invalid, stopAfter: prefixLimit, prefix: &metadataPrefix)
        // No initialization frame remains live across this concrete operation.
        let checks = p08RunMetadataCase(plan, pointers: p, secondModel: secondModel, secondSemantic: secondSemantic, write: write)
        // All scoped/model/descriptor loans ended when the operation returned.
        guard p08DestroyMetadata(p, prefix: &metadataPrefix) else {
            for slot in 0..<4 { phases[slot] = .poisoned }
            preconditionFailure("incomplete metadata/bank cleanup")
        }
        _ = consume p // End every typed descriptor before the pair can be idle/rebound.
        for slot in range.active..<(range.active + range.slots) { phases[slot] = .idle }
        phases[range.donor] = .idle; busy = false
        return checks
    }
    borrowing func requireIdle() {
        let notBusy = !busy; precondition(notBusy)
        let empty = metadataPrefix == 0; precondition(empty)
        for slot in 0..<4 { let idle = phases[slot] == .idle; precondition(idle) }
    }
}
// Dispatch before constructing a view or any case-specific owned temporary.
// Every leaf receives the actual donor owner/outer lvalues; no consuming carrier
// or second owner is created. Custody still encloses all original callbacks.
@inline(never)
fileprivate func p08RunMetadataCase(_ plan: P08EmbeddedCasePlan, pointers p: borrowing P08MetadataPointers,
    secondModel: ObservableModelOwnerIdentity?, secondSemantic: SemanticRecordOwnerIdentity?, write: CounterTiledPixelWrite?) -> Int {
    switch plan {
    case .metadataPrefix: return 1
    case .invalidExtent:
        return p08RunMetadataInvalid(owner: &p.owner.pointee, original: &p.original.pointee)
    case .fault(let id, let completed, let after):
        return p08RunMetadataFault(owner: &p.owner.pointee, id: id, completed: completed, after: after)
    case .graph:
        return p08RunMetadataGraph(owner: &p.owner.pointee, outer: &p.outer.pointee)
    case .host, .early, .candidate:
        return p08RunMetadataHost(plan, owner: &p.owner.pointee, outer: &p.outer.pointee,
            foreignRoot: p.foreignRoot, foreignControl: p.foreignControl, write: write)
    case .twoHosts:
        return p08RunMetadataTwoHosts(owner: &p.owner.pointee, outer: &p.outer.pointee,
            before: p.before, original: &p.original.pointee, transcript: p.transcript,
            foreignRoot: p.foreignRoot, foreignControl: p.foreignControl,
            secondModel: secondModel, secondSemantic: secondSemantic, write: write)
    case .exchange(let surplus):
        return p08RunMetadataExchange(owner: &p.owner.pointee, outer: &p.outer.pointee, original: &p.original.pointee, surplus: surplus)
    }
}
@inline(never)
fileprivate func p08RunMetadataInvalid(owner: inout P08TypedBackingOwner,
    original: inout InlineArray<14, P08InitializedEntry?>) -> Int {
    let invalid = owner.initialize() == .invalidReservation
    precondition(invalid)
    original = owner.originalInventory()
    for index in 0..<14 { let empty = original[index] == nil; precondition(empty) }
    return 1
}
@inline(never)
fileprivate func p08RunMetadataFault(owner: inout P08TypedBackingOwner,
    id: P08PhysicalID, completed: Int, after: Bool) -> Int {
    let ids: InlineArray<14, P08PhysicalID?> = [.b0, .b1, .b2, .b3, .g0, .g1, .g2, .g3, .g4, .c0, .h0, .r0, .r1, .h1]
    let fault = P08AcquisitionFault(id: id, completed: completed, afterInstall: after)
    let failed = owner.initialize(fault: fault) != nil
    precondition(failed)
    return p08VerifyFault(owner, fault: fault, ids: ids, objects: 14)
}
@inline(never)
fileprivate func p08RunMetadataGraph(owner: inout P08TypedBackingOwner, outer: inout P08EmbeddedOuter) -> Int {
    let initialized = initializeP08Backing(&owner) == nil
    precondition(initialized)
    let view = p08MetadataOuterView(outer)
    return p08CheckGraphSelection(owner: owner, outer: view)
}
@inline(never)
fileprivate func p08RunMetadataHost(_ plan: P08EmbeddedCasePlan,
    owner: inout P08TypedBackingOwner, outer: inout P08EmbeddedOuter,
    foreignRoot: UnsafeMutablePointer<CounterStaticRootStorage>,
    foreignControl: UnsafeMutablePointer<CounterControl>, write: CounterTiledPixelWrite?) -> Int {
    let initialized = initializeP08Backing(&owner) == nil
    precondition(initialized)
    return p08RunOneMetadataHost(owner: &owner, outer: &outer, before: nil, transcript: nil,
        foreignRoot: foreignRoot, foreignControl: foreignControl, write: write, plan: plan)
}
// Cold inventory and empty/retirement checks finish before live host invocation.
@inline(never)
fileprivate func p08InitializeMetadataHostBacking(_ owner: inout P08TypedBackingOwner) {
    let initialized = initializeP08Backing(&owner) == nil
    precondition(initialized)
}
@inline(never)
fileprivate func p08CaptureMetadataHostInventory(_ owner: inout P08TypedBackingOwner,
    into original: inout InlineArray<14, P08InitializedEntry?>) {
    original = owner.originalInventory()
}
@inline(never)
fileprivate func p08RequireMetadataHostEmpty(_ owner: inout P08TypedBackingOwner) {
    owner.requireEmpty()
}
@inline(never)
fileprivate func p08RequireMetadataHostRetired(_ control: UnsafeMutablePointer<CounterControl>) {
    p08RequireRetiredControl(control)
}
@inline(never)
fileprivate func p08InstallEmbeddedHostPlan(owner: inout P08TypedBackingOwner,
    outer: inout P08EmbeddedOuter, write: CounterTiledPixelWrite?, plan: P08EmbeddedCasePlan?) {
    let vacant = outer.hostPlan == nil; precondition(vacant)
    let view = p08MetadataOuterView(outer)
    if let plan {
        switch plan {
        case .host(let scenario):
            view.control.pointee.terminalRetry = scenario == 2
            view.control.pointee.idleQuiesceMode = scenario >= 3 ? scenario - 1 : 0
        case .early(let early): precondition(early >= 1 && early <= 5)
        case .candidate(let raw): precondition(raw <= 10)
        default: preconditionFailure("non-host metadata case")
        }
    }
    if let write { view.control.pointee.backend.write = write }
    let (audit, assembly) = p08PrepareStaticHost(outer: view, owner: &owner)
    outer.hostPlan = .init(limits: view.limits, audit: audit, assembly: assembly)
}

@inline(never)
fileprivate func p08RunOneMetadataHost(owner: inout P08TypedBackingOwner, outer: inout P08EmbeddedOuter,
    before: UnsafeMutablePointer<P08ReuseFingerprint>?, transcript: UnsafeMutablePointer<P08HostReuseTranscript>?,
    foreignRoot: UnsafeMutablePointer<CounterStaticRootStorage>,
    foreignControl: UnsafeMutablePointer<CounterControl>, write: CounterTiledPixelWrite?, plan: P08EmbeddedCasePlan? = nil) -> Int {
    // Whole-outer setup ends before addresses are projected and the plan field is lent.
    p08InstallEmbeddedHostPlan(owner: &owner, outer: &outer, write: write, plan: plan)
    let root = outer.root, semantic = outer.semantic, canvas = outer.canvas, control = outer.control
    let records = outer.records, paths = outer.paths, payloads = outer.payloads
    let scalars = outer.scalars, entries = outer.entries
    let failAfterRuntime: Bool, early: UInt8, candidateFailure: RuntimeCompletePipelineStage?
    switch plan {
    case .host(let scenario)?: failAfterRuntime = scenario == 1; early = 0; candidateFailure = nil
    case .early(let value)?: failAfterRuntime = false; early = value; candidateFailure = nil
    case .candidate(let raw)?: failAfterRuntime = false; early = 0; candidateFailure = RuntimeCompletePipelineStage(rawValue: raw)!
    case nil: failAfterRuntime = false; early = 0; candidateFailure = nil
    default: preconditionFailure("non-host metadata case")
    }
    let checks = p08RunPreparedStaticHost(owner: &owner, facts: &outer.hostPlan!,
        rootStorage: root, semanticStorage: semantic, canvasStorage: canvas,
        recordsBacking: .init(start: records, count: 128), pathsBacking: .init(start: paths, count: 384),
        payloadsBacking: .init(start: payloads, count: 256), scalarsBacking: .init(start: scalars, count: 128),
        entriesBacking: .init(start: entries, count: 1), control: control,
        failAfterRuntime: failAfterRuntime, early: early, candidateFailure: candidateFailure,
        reuse: transcript, baseline: before, foreignRootStorage: foreignRoot, foreignControlStorage: foreignControl)
    // Prepared execution has returned through root shutdown and host teardown.
    p08ClearHostPlan(&outer.hostPlan)
    return checks
}
@inline(never)
fileprivate func p08ReconstructMetadataHost(outer: inout P08EmbeddedOuter,
    model: ObservableModelOwnerIdentity, semantic: SemanticRecordOwnerIdentity,
    foreignRoot: UnsafeMutablePointer<CounterStaticRootStorage>,
    foreignControl: UnsafeMutablePointer<CounterControl>) {
    p08MetadataOuterView(outer).reconstruct(modelOwner: model, semanticOwner: semantic)
    p08ResetForeignMetadata(root: foreignRoot, control: foreignControl)
}
// The exact invariant check ends before inventory/host work. Actual owner/outer
// remain inout inputs, not transferred owners; failure cleanup requires target inspection.
@inline(never)
fileprivate func p08RequireSecondNamespaces(owner: inout P08TypedBackingOwner, outer: inout P08EmbeddedOuter,
    secondModel: ObservableModelOwnerIdentity?, secondSemantic: SemanticRecordOwnerIdentity?)
    -> (ObservableModelOwnerIdentity, SemanticRecordOwnerIdentity) {
    guard let secondModel, let secondSemantic else { preconditionFailure("second namespaces") }
    return (secondModel, secondSemantic)
}
@inline(never)
fileprivate func p08RunMetadataTwoHosts(owner: inout P08TypedBackingOwner, outer: inout P08EmbeddedOuter,
    before: UnsafeMutablePointer<P08ReuseFingerprint>, original: inout InlineArray<14, P08InitializedEntry?>,
    transcript: UnsafeMutablePointer<P08HostReuseTranscript>,
    foreignRoot: UnsafeMutablePointer<CounterStaticRootStorage>,
    foreignControl: UnsafeMutablePointer<CounterControl>, secondModel: ObservableModelOwnerIdentity?,
    secondSemantic: SemanticRecordOwnerIdentity?, write: CounterTiledPixelWrite?) -> Int {
    p08InitializeMetadataHostBacking(&owner)
    let (secondModel, secondSemantic) = p08RequireSecondNamespaces(owner: &owner, outer: &outer, secondModel: secondModel, secondSemantic: secondSemantic)
    p08CaptureMetadataHostInventory(&owner, into: &original)
    let control = outer.control, address = UInt(bitPattern: outer.control)
    p08RequireFreshControl(control)
    var checks = p08RunOneMetadataHost(owner: &owner, outer: &outer, before: before, transcript: transcript, foreignRoot: foreignRoot, foreignControl: foreignControl, write: write)
    p08RequireMetadataHostEmpty(&owner); p08RequireMetadataHostRetired(control)
    p08ReconstructMetadataHost(outer: &outer, model: secondModel, semantic: secondSemantic, foreignRoot: foreignRoot, foreignControl: foreignControl)
    precondition(UInt(bitPattern: control) == address)
    checks += p08RunOneMetadataHost(owner: &owner, outer: &outer, before: before, transcript: transcript, foreignRoot: foreignRoot, foreignControl: foreignControl, write: write)
    return checks + p08FinishMetadataTwoHosts(owner: &owner, original: &original, control: control, transcript: transcript)
}
@inline(never)
fileprivate func p08FinishMetadataTwoHosts(owner: inout P08TypedBackingOwner,
    original: inout InlineArray<14, P08InitializedEntry?>, control: UnsafeMutablePointer<CounterControl>,
    transcript: UnsafeMutablePointer<P08HostReuseTranscript>) -> Int {
    p08RequireMetadataHostEmpty(&owner)
    p08RequireSameInventory(owner.originalInventory(), original)
    p08RequireMetadataHostRetired(control); transcript.pointee.endRetainedObservations()
    owner.release()
    precondition(transcript.pointee.hosts == 2)
    let checks = p08VerifyDestruction(owner.destructionTranscript(), original: original, expectedCount: 14)
    p08ReuseLabel("static", "inventory-two-hosts"); p08ReuseLabel("static", "control-same-address"); p08ReuseLabel("static", "cleanup-backing-last")
    return checks + 3
}
@inline(never)
fileprivate func p08RunMetadataExchange(owner: inout P08TypedBackingOwner, outer: inout P08EmbeddedOuter,
    original: inout InlineArray<14, P08InitializedEntry?>, surplus: Int) -> Int {
    let initialized = initializeP08Backing(&owner) == nil
    precondition(initialized)
    _ = p08MetadataOuterView(outer) // Preserve original checked outer-view queries even on exchange.
    original = owner.originalInventory()
    let enough = original[11]!.retainedBytes <= original[12]!.retainedBytes
    precondition(enough)
    if surplus > 0 {
        let larger = original[11]!.retainedBytes < original[12]!.retainedBytes
        precondition(larger)
    }
    var transcript = P08RoleTranscript()
    var checks = withUnsafeMutablePointer(to: &transcript) { pointer in
        owner.withStorage(transcript: pointer) { session in
            var holder = P08SessionOnlyCleanup(session: session); defer { holder.finish() }; return holder.exercise()
        }
    }
    checks += p08VerifyRoleTranscript(transcript)
    owner.release()
    return checks + p08VerifyDestruction(owner.destructionTranscript(), original: original, expectedCount: 14)
}
fileprivate func p08EmbeddedGraph(custody: inout P08CallerCustody) -> Int {
    p08CheckGraphDefinition()
    var models = ObservableModelOwnerNamespace(), semantics = SemanticRecordOwnerNamespace()
    do { return custody.run(.graph, model: try models.issue(), semantic: try semantics.issue()) }
    catch { preconditionFailure("counter graph profile identities") }
}
fileprivate func p08EmbeddedHost(custody: inout P08CallerCustody, write: CounterTiledPixelWrite?) -> Int {
    var models = ObservableModelOwnerNamespace(), semantics = SemanticRecordOwnerNamespace()
    do {
        var checks = 0
        for scenario: UInt8 in 0...8 { checks += custody.run(.host(scenario), model: try models.issue(), semantic: try semantics.issue(), write: write) }
        let firstModel = try models.issue(), secondModel = try models.issue()
        let firstSemantic = try semantics.issue(), secondSemantic = try semantics.issue()
        precondition(firstModel != secondModel && firstSemantic != secondSemantic)
        counterTrace("reuse.namespaces", (firstModel, secondModel, firstSemantic, secondSemantic))
        checks += custody.run(.twoHosts, model: firstModel, semantic: firstSemantic, secondModel: secondModel, secondSemantic: secondSemantic, write: write)
        return checks
    } catch { preconditionFailure("counter host identities") }
}
fileprivate func p08EmbeddedScoped(custody: inout P08CallerCustody, write: CounterTiledPixelWrite?) -> Int {
    let ids: InlineArray<14, P08PhysicalID?> = [.b0, .b1, .b2, .b3, .g0, .g1, .g2, .g3, .g4, .c0, .h0, .r0, .r1, .h1]
    var models = ObservableModelOwnerNamespace(), semantics = SemanticRecordOwnerNamespace()
    do {
        var checks = 0
        for surplus in [0, 64] { checks += custody.run(.exchange(surplus), model: try models.issue(), semantic: try semantics.issue()) }
        checks += custody.run(.invalidExtent, model: try models.issue(), semantic: try semantics.issue())
        for index in 0..<14 { for after in [false, true] {
            checks += custody.run(.fault(ids[index]!, 0, after), model: try models.issue(), semantic: try semantics.issue())
        } }
        for (id, count) in [(P08PhysicalID.b0,1024), (.b1,1056), (.b2,20), (.b3,112)] {
            for prefix in 1..<count { checks += custody.run(.fault(id, prefix, false), model: try models.issue(), semantic: try semantics.issue()) }
        }
        for early: UInt8 in 1...5 { checks += custody.run(.early(early), model: try models.issue(), semantic: try semantics.issue(), write: write) }
        for raw: UInt8 in 0...10 { checks += custody.run(.candidate(raw), model: try models.issue(), semantic: try semantics.issue(), write: write) }
        // Additive metadata-prefix controls; do not replace any original selection.
        for prefix: UInt8 in 0...7 { checks += custody.run(.metadataPrefix(prefix), model: try models.issue(), semantic: try semantics.issue()) }
        return checks
    } catch { preconditionFailure("scoped corpus identities") }
}
package func p08RunEmbeddedCorpus(write: CounterTiledPixelWrite?, backing: UnsafeMutableRawBufferPointer) -> Int {
    var custody = P08CallerCustody(backing)
    let graph = p08EmbeddedGraph(custody: &custody)
    let scoped = p08EmbeddedScoped(custody: &custody, write: write)
    let hosts = p08EmbeddedHost(custody: &custody, write: write)
    custody.requireIdle()
    return graph + scoped + hosts
}
package func p08CounterGraph(backing: UnsafeMutableRawBufferPointer? = nil) -> Int {
    var custody = P08CallerCustody(backing!)
    let checks = p08EmbeddedGraph(custody: &custody); custody.requireIdle(); return checks
}
package func p08CounterHost(write: CounterTiledPixelWrite? = nil, backing: UnsafeMutableRawBufferPointer? = nil) -> Int {
    var custody = P08CallerCustody(backing!)
    let checks = p08EmbeddedHost(custody: &custody, write: write); custody.requireIdle(); return checks
}
package func counterExerciseScopedStorage(backing: UnsafeMutableRawBufferPointer? = nil, write: CounterTiledPixelWrite? = nil) -> Int {
    var custody = P08CallerCustody(backing!)
    let checks = p08EmbeddedScoped(custody: &custody, write: write); custody.requireIdle(); return checks
}
#endif

#if hasFeature(Embedded)
@inline(never)
fileprivate func p08ResetForeignMetadata(root: UnsafeMutablePointer<CounterStaticRootStorage>, control: UnsafeMutablePointer<CounterControl>) {
    p08DestroyMetadataForeignControl(control)
    p08DestroyMetadataForeignRoot(root)
    p08InitializeMetadataForeignRoot(root)
    p08InitializeMetadataForeignControl(control)
}
#endif

#if hasFeature(Embedded)
@inline(__always)
fileprivate func p08MetadataScalarFact(_ field: Int, _ component: Int) -> UInt32 {
    var selected: Int? = nil
    guard let summary = p08DeriveMetadataLayout({ index, offset, size, stride, alignment in
        guard field == index else { return }
        switch component {
        case 0: selected = offset
        case 1: selected = size
        case 2: selected = stride
        case 3: selected = alignment
        default: preconditionFailure("invalid metadata fact")
        }
    }) else { preconditionFailure("invalid metadata layout") }
    let value: Int
    if field < 7 { guard let selected else { preconditionFailure("missing metadata fact") }; value = selected }
    else {
        switch field {
        case 7: value = summary.cursor
        case 8: value = summary.maximumAlignment
        case 9: value = summary.extent
        default: preconditionFailure("invalid metadata summary")
        }
    }
    guard let result = UInt32(exactly: value) else { preconditionFailure("metadata exceeds UInt32") }
    return result
}
@_cdecl("giftui_p08_metadata_outer_offset")
@inline(__always)
func p08MetadataFact0_0() -> UInt32 { p08MetadataScalarFact(0, 0) }
@_cdecl("giftui_p08_metadata_outer_size")
@inline(__always)
func p08MetadataFact0_1() -> UInt32 { p08MetadataScalarFact(0, 1) }
@_cdecl("giftui_p08_metadata_outer_stride")
@inline(__always)
func p08MetadataFact0_2() -> UInt32 { p08MetadataScalarFact(0, 2) }
@_cdecl("giftui_p08_metadata_outer_alignment")
@inline(__always)
func p08MetadataFact0_3() -> UInt32 { p08MetadataScalarFact(0, 3) }
@_cdecl("giftui_p08_metadata_owner_offset")
@inline(__always)
func p08MetadataFact1_0() -> UInt32 { p08MetadataScalarFact(1, 0) }
@_cdecl("giftui_p08_metadata_owner_size")
@inline(__always)
func p08MetadataFact1_1() -> UInt32 { p08MetadataScalarFact(1, 1) }
@_cdecl("giftui_p08_metadata_owner_stride")
@inline(__always)
func p08MetadataFact1_2() -> UInt32 { p08MetadataScalarFact(1, 2) }
@_cdecl("giftui_p08_metadata_owner_alignment")
@inline(__always)
func p08MetadataFact1_3() -> UInt32 { p08MetadataScalarFact(1, 3) }
@_cdecl("giftui_p08_metadata_baseline_offset")
@inline(__always)
func p08MetadataFact2_0() -> UInt32 { p08MetadataScalarFact(2, 0) }
@_cdecl("giftui_p08_metadata_baseline_size")
@inline(__always)
func p08MetadataFact2_1() -> UInt32 { p08MetadataScalarFact(2, 1) }
@_cdecl("giftui_p08_metadata_baseline_stride")
@inline(__always)
func p08MetadataFact2_2() -> UInt32 { p08MetadataScalarFact(2, 2) }
@_cdecl("giftui_p08_metadata_baseline_alignment")
@inline(__always)
func p08MetadataFact2_3() -> UInt32 { p08MetadataScalarFact(2, 3) }
@_cdecl("giftui_p08_metadata_inventory_offset")
@inline(__always)
func p08MetadataFact3_0() -> UInt32 { p08MetadataScalarFact(3, 0) }
@_cdecl("giftui_p08_metadata_inventory_size")
@inline(__always)
func p08MetadataFact3_1() -> UInt32 { p08MetadataScalarFact(3, 1) }
@_cdecl("giftui_p08_metadata_inventory_stride")
@inline(__always)
func p08MetadataFact3_2() -> UInt32 { p08MetadataScalarFact(3, 2) }
@_cdecl("giftui_p08_metadata_inventory_alignment")
@inline(__always)
func p08MetadataFact3_3() -> UInt32 { p08MetadataScalarFact(3, 3) }
@_cdecl("giftui_p08_metadata_transcript_offset")
@inline(__always)
func p08MetadataFact4_0() -> UInt32 { p08MetadataScalarFact(4, 0) }
@_cdecl("giftui_p08_metadata_transcript_size")
@inline(__always)
func p08MetadataFact4_1() -> UInt32 { p08MetadataScalarFact(4, 1) }
@_cdecl("giftui_p08_metadata_transcript_stride")
@inline(__always)
func p08MetadataFact4_2() -> UInt32 { p08MetadataScalarFact(4, 2) }
@_cdecl("giftui_p08_metadata_transcript_alignment")
@inline(__always)
func p08MetadataFact4_3() -> UInt32 { p08MetadataScalarFact(4, 3) }
@_cdecl("giftui_p08_metadata_foreignRoot_offset")
@inline(__always)
func p08MetadataFact5_0() -> UInt32 { p08MetadataScalarFact(5, 0) }
@_cdecl("giftui_p08_metadata_foreignRoot_size")
@inline(__always)
func p08MetadataFact5_1() -> UInt32 { p08MetadataScalarFact(5, 1) }
@_cdecl("giftui_p08_metadata_foreignRoot_stride")
@inline(__always)
func p08MetadataFact5_2() -> UInt32 { p08MetadataScalarFact(5, 2) }
@_cdecl("giftui_p08_metadata_foreignRoot_alignment")
@inline(__always)
func p08MetadataFact5_3() -> UInt32 { p08MetadataScalarFact(5, 3) }
@_cdecl("giftui_p08_metadata_foreignControl_offset")
@inline(__always)
func p08MetadataFact6_0() -> UInt32 { p08MetadataScalarFact(6, 0) }
@_cdecl("giftui_p08_metadata_foreignControl_size")
@inline(__always)
func p08MetadataFact6_1() -> UInt32 { p08MetadataScalarFact(6, 1) }
@_cdecl("giftui_p08_metadata_foreignControl_stride")
@inline(__always)
func p08MetadataFact6_2() -> UInt32 { p08MetadataScalarFact(6, 2) }
@_cdecl("giftui_p08_metadata_foreignControl_alignment")
@inline(__always)
func p08MetadataFact6_3() -> UInt32 { p08MetadataScalarFact(6, 3) }
@_cdecl("giftui_p08_metadata_cursor")
@inline(__always)
func p08MetadataSummary7() -> UInt32 { p08MetadataScalarFact(7, 0) }
@_cdecl("giftui_p08_metadata_maximumAlignment")
@inline(__always)
func p08MetadataSummary8() -> UInt32 { p08MetadataScalarFact(8, 0) }
@_cdecl("giftui_p08_metadata_extent")
@inline(__always)
func p08MetadataSummary9() -> UInt32 { p08MetadataScalarFact(9, 0) }
#endif
