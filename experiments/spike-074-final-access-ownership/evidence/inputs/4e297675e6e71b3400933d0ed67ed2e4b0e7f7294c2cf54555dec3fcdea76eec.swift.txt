import GiftUI
import SignalAnalyzerDomain
import ApplicationSchema
import PortablePresentation
import HostBridge

package struct Checks {
    package var total = 0
    package var failures = 0
    package var failureMask: UInt64 = 0
    package mutating func expect(_ condition: Bool) {
        if !condition { failures += 1; failureMask |= UInt64(1) << UInt64(total % 64) }
        total += 1
    }
}
private func render<V: View>(_ view: V, owner: borrowing Owner) throws(AccessFailure) -> UInt32
    where V.Domain == AnalyzerDomain {
    let read = try owner.read()
    return try view.render(read: read)
}
private func expectReplacementFailure(_ owner: inout Owner, key: ModelKey<AnalyzerSchema>,
    fault: AttachFault, expected: AccessFailure, checks: inout Checks) {
    let old = owner.active, attachment = owner.attachment, dirty = owner.dirty
    let count = owner.count(old), owners = owner.owners(old), record = owner.modelRecord(1)
    do throws(AccessFailure) {
        try owner.replace(key, transferringOld: true, fault: fault); checks.expect(false)
    } catch { checks.expect(error == expected) }
    checks.expect(owner.active == old && owner.bankOwner == old && owner.attachment == attachment && owner.dirty == dirty)
    checks.expect(owner.count(old) == count && owner.owners(old) == owners && owner.modelRecord(1) == record)
    checks.expect(owner.canariesValid())
}
package func runChecks() -> Checks {
    var checks = Checks()
    withUnsafeTemporaryAllocation(of: CounterSlot.self, capacity: 1) { slots in
        slots.initialize(repeating: CounterSlot(7)); defer { slots.deinitialize() }
        let key = ModelKey<CounterSchema>(owner: 75, generation: 1, slot: 0)
        do throws(AccessFailure) {
            let first: UInt32
            do {
                let read = FrameRead<CounterDomain>(Span(_unsafeElements: slots))
                first = try CounterRoot<CounterDomain>(key).render(read: read)
            }
            checks.expect(first == 12)
            slots[0].value = 0
            let read = FrameRead<CounterDomain>(Span(_unsafeElements: slots))
            let later = try CounterRoot<CounterDomain>(key).render(read: read)
            checks.expect(later == 0 && first == 12)
        } catch { checks.expect(false) }
    }
    withUnsafeTemporaryAllocation(byteCount: 19392, alignment: 8) { bytes in
        bytes.initializeMemory(as: UInt8.self, repeating: 0)
        withUnsafeTemporaryAllocation(of: AnalyzerSlot.self, capacity: 2) { slots in
            let modelBytes = UnsafeRawBufferPointer(rebasing: bytes[6464..<12928])
            slots.initialize(repeating: AnalyzerSlot(modelBytes)); defer { slots.deinitialize() }
            var owner = Owner(slots, bytes: bytes)
            owner.seedCanaries()
            do throws(AccessFailure) {
                let old = owner.key(0)
                let candidate = try owner.createEmpty()
                do throws(AccessFailure) { _ = try owner.createEmpty(); checks.expect(false) }
                catch { checks.expect(error == .capacity) }
                // An empty candidate does not own the installed model's reserved bank.
                do throws(AccessFailure) { try owner.populate(candidate, count: 1); checks.expect(false) }
                catch { checks.expect(error == .capacity) }
                checks.expect(owner.count(0) == 0 && owner.count(1) == 0)
                try owner.populate(old, count: 2)
                try owner.begin()
                let tree = try render(AnalyzerRoot<AnalyzerDomain>(old), owner: owner)
                checks.expect(tree == 16) // nested count 2 + running 10 + helper 1+3
                let trace = Trace<AnalyzerDomain>(old, position: 1)
                let geometry = try render(trace, owner: owner)
                checks.expect(geometry == 21)
                do throws(AccessFailure) { try owner.replace(candidate, transferringOld: true); checks.expect(false) }
                catch { checks.expect(error == .phase) }
                do throws(AccessFailure) { try owner.populate(old, count: 0); checks.expect(false) }
                catch { checks.expect(error == .phase) }
                do throws(AccessFailure) { _ = try render(Trace<AnalyzerDomain>(old, position: 2), owner: owner); checks.expect(false) }
                catch { checks.expect(error == .bounds) }
                let wrongOwner = ModelKey<AnalyzerSchema>(owner: 99, generation: 1, slot: 0)
                do throws(AccessFailure) { _ = try render(AnalyzerRoot<AnalyzerDomain>(wrongOwner), owner: owner); checks.expect(false) }
                catch { checks.expect(error == .key) }
                try owner.finish()
                try owner.retain(old)
                expectReplacementFailure(&owner, key: candidate, fault: .none, expected: .retained, checks: &checks)
                try owner.releaseExtra(old)
                expectReplacementFailure(&owner, key: candidate, fault: .report, expected: .attachment, checks: &checks)
                expectReplacementFailure(&owner, key: candidate, fault: .retain, expected: .busy, checks: &checks)
                expectReplacementFailure(&owner, key: candidate, fault: .reenter, expected: .busy, checks: &checks)
                try owner.replace(candidate, transferringOld: true)
                checks.expect(owner.active == 1 && owner.bankOwner == 1 && owner.attachment == 2)
                checks.expect(owner.count(1) == 0 && owner.owners(0) == 0 && owner.owners(1) == 1)
                checks.expect(owner.modelRecord(1) == 1) // Transfer need not clear old bytes.
                try owner.begin()
                do throws(AccessFailure) { _ = try render(trace, owner: owner); checks.expect(false) }
                catch { checks.expect(error == .key) }
                // Drawing failure after commit must not undo B.
                do throws(AccessFailure) { _ = try render(Trace<AnalyzerDomain>(candidate, position: 0), owner: owner); checks.expect(false) }
                catch { checks.expect(error == .bounds) }
                checks.expect(owner.active == 1 && owner.attachment == 2)
                try owner.finish()
                try owner.populate(candidate, count: 404)
                try owner.begin()
                let nextGeometry = try render(Trace<AnalyzerDomain>(candidate, position: 403), owner: owner)
                checks.expect(nextGeometry == 41 && geometry == 21 && tree == 16)
                try owner.finish()
                checks.expect(owner.canariesValid())
                let newCandidate = try owner.createEmpty() // Reuses old metadata slot with a new generation.
                checks.expect(newCandidate.slot == old.slot && newCandidate.generation != old.generation)
                try owner.replace(newCandidate, transferringOld: true)
                try owner.populate(newCandidate, count: 1)
                checks.expect(owner.active == 0 && owner.attachment == 3 && owner.count(0) == 1)
                try owner.begin()
                do throws(AccessFailure) { _ = try render(AnalyzerRoot<AnalyzerDomain>(old), owner: owner); checks.expect(false) }
                catch { checks.expect(error == .key) }
                try owner.finish()
                checks.expect(owner.canariesValid())
                let dirty = owner.dirty
                do throws(AccessFailure) { try owner.populate(newCandidate, count: 405); checks.expect(false) }
                catch { checks.expect(error == .capacity) }
                checks.expect(owner.count(0) == 1 && owner.dirty == dirty)
            } catch { checks.expect(false) }
        }
        withUnsafeTemporaryAllocation(of: AnalyzerSlot.self, capacity: 2) { slots in
            slots.initialize(repeating: AnalyzerSlot(UnsafeRawBufferPointer(rebasing: bytes[6464..<12928])))
            defer { slots.deinitialize() }
            var owner = Owner(slots, bytes: bytes, generationLimit: 1)
            owner.seedCanaries()
            do throws(AccessFailure) {
                try owner.populate(owner.key(0), count: 2)
                let candidate = try owner.createEmpty()
                expectReplacementFailure(&owner, key: candidate, fault: .none, expected: .generation, checks: &checks)
            } catch { checks.expect(false) }
        }
    }
    checks.expect(recordStride() == 16)
    checks.expect(counterStride() == 1)
    return checks
}
@_cdecl("spike074_run") public func run() -> Int32 {
    let checks = runChecks()
    return checks.failures == 0 && checks.total >= 40 ? 0 : 1
}
@_cdecl("spike074_canvas_stride") public func canvasStride() -> Int {
    MemoryLayout<Trace<AnalyzerDomain>>.stride
}
