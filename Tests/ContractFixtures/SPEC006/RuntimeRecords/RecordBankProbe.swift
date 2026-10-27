import GiftUI
@testable import GiftUISemanticCore

private struct Banks: ~Copyable {
    var metadata: InlineArray<2, SemanticRecordBankMetadata> = .init(repeating: .init())
    var records: InlineArray<24, SemanticRuntimeRecord> = .init(repeating: .init())
    var paths: InlineArray<96, SemanticPathEntry> = .init(repeating: .init())
    var payloads: InlineArray<24, SemanticRecordPayload?> = .init(repeating: nil)
    var scalars: InlineArray<64, UInt32> = .init(repeating: 0)
    mutating func withStore<Result>(_ limits: SemanticRecordLimits, owner: SemanticRecordOwnerIdentity,
        _ body: (borrowing SemanticRecordStore) throws(SemanticExpansionError) -> Result
    ) throws(SemanticExpansionError) -> Result {
        var m = metadata.mutableSpan; var r = records.mutableSpan; var p = paths.mutableSpan
        var v = payloads.mutableSpan; var s = scalars.mutableSpan
        return try withSemanticRecordStore(metadata: &m, records: &r, paths: &p, payloads: &v, scalars: &s, limits: limits, owner: owner, body)
    }
}
private func limits(records: UInt16 = 12, paths: UInt16 = 48, depth: UInt16 = 34,
                    fanout: UInt16 = 5, payloads: UInt16 = 12, scalars: UInt16 = 32,
                    bytes: UInt32 = 256) -> SemanticRecordLimits {
    SemanticRecordLimits(records: records, paths: paths, depth: depth, fanout: fanout,
                         payloads: payloads, textScalars: scalars, payloadBytes: bytes)!
}
private func expect(_ value: Bool, _ count: inout UInt32) { count += 1; precondition(value) }
private func enter(_ bank: SemanticRecordBankBuffers, _ component: SemanticPathComponent,
                   _ limits: SemanticRecordLimits) throws(SemanticExpansionError) {
    if let failure = bank.enter(component, limits: limits) { throw failure }
}
private func tree(_ store: borrowing SemanticRecordStore, branch: UInt8, marker: UInt32) throws(SemanticExpansionError) {
    let number = try store.beginCandidate(); let bank = store.expansionBank(number)!
    try enter(bank, .init(kind: .root), store.limits)
    try enter(bank, .init(kind: .declarationRole, role: 1), store.limits)
    if let failure = bank.appendRecord(limits: store.limits) { throw failure }
    try enter(bank, .init(kind: .conditionalBranch, ordinal: branch), store.limits)
    try enter(bank, .init(kind: .fixedChild), store.limits)
    try enter(bank, .init(kind: .declarationRole, role: 2), store.limits)
    if let failure = bank.appendRecord(limits: store.limits) { throw failure }
    let text: InlineArray<2, UInt32> = [65, 0x1F600]
    if let failure = bank.store(.standard(.action(role: 1, code: UInt16(marker))), kind: .primitive, text: text.span, limits: store.limits) { throw failure }
    for _ in 0..<5 { bank.leave() }
    bank.metadata.pointee.phase = .candidate
}
private func lifetimeChecks(_ store: borrowing SemanticRecordStore) throws(SemanticExpansionError) -> UInt32 {
    var checks: UInt32 = 0
    try tree(store, branch: 0, marker: 11)
    // A complete candidate is borrowed successfully but not globally published.
    try store.withCandidateView { (candidate) throws(SemanticExpansionError) in
        expect(candidate.recordCount == 2 && candidate.pathCount == 5, &checks)
        expect(candidate.payload(at: 0) == .standard(.action(role: 1, code: 11)) && candidate.scalar(at: 1) == 0x1F600, &checks)
    }
    do throws(SemanticExpansionError) { try store.withPublishedView { _ in () }; preconditionFailure() }
    catch { expect(error == .invariantViolation, &checks) }
    try store.publishCandidate()
    var firstReference: SemanticRecordReference?
    var independentKey: SemanticCompleteIdentity?
    try store.withPublishedView { (old) throws(SemanticExpansionError) in
        firstReference = old.reference(at: 1); independentKey = old.completeIdentity(for: firstReference!)
        try tree(store, branch: 1, marker: 22)
        try store.withCandidateView { (next) throws(SemanticExpansionError) in
            expect(next.reference(at: 1)!.ordinal == firstReference!.ordinal, &checks)
            expect(!old.sameIdentity(firstReference!, as: next.reference(at: 1)!, in: next), &checks)
            expect(old.record(next.reference(at: 1)!) == nil, &checks)
        }
        try store.publishCandidate()
        expect(old.payload(at: 0) == .standard(.action(role: 1, code: 11)), &checks)
        do throws(SemanticExpansionError) { _ = try store.beginCandidate(); preconditionFailure() }
        catch { expect(error == .capacityExhausted, &checks) }
        try store.withPublishedView { (next) throws(SemanticExpansionError) in
            expect(next.payload(at: 0) == .standard(.action(role: 1, code: 22)) && next.path(at: 2)!.matchedPath == .max, &checks)
            expect(next.componentComparisons <= UInt32(next.pathCount) * UInt32(store.limits.fanout), &checks)
        }
    }
    // Last reader retires the old bank. Reuse rejects stale references while the
    // independent complete key remains valid and matches restored branch 0.
    try tree(store, branch: 0, marker: 33)
    try store.withCandidateView { (next) throws(SemanticExpansionError) in
        expect(next.bankNumber == firstReference!.bank && next.revision != firstReference!.revision, &checks)
        expect(next.record(firstReference!) == nil, &checks)
        expect(next.completeIdentity(for: next.reference(at: 1)!) == independentKey, &checks)
    }
    try store.discardCandidate()
    try store.withPublishedView { (current) throws(SemanticExpansionError) in expect(current.payload(at: 0) == .standard(.action(role: 1, code: 22)), &checks) }
    // Equal full paths match every prefix despite different payload values.
    try tree(store, branch: 1, marker: 44)
    try store.publishCandidate()
    try store.withPublishedView { (current) throws(SemanticExpansionError) in
        for index in 0..<current.pathCount { expect(current.path(at: index)!.matchedPath == index, &checks) }
        expect(current.componentComparisons == 5, &checks)
    }
    return checks
}
@_cdecl("giftui_p04_record_banks") public func giftuiP04RecordBanks() -> UInt32 {
    do throws(SemanticExpansionError) {
        var namespace = SemanticRecordOwnerNamespace(); var banks = Banks(); var checks: UInt32 = 0
        checks += try banks.withStore(limits(), owner: namespace.issue()) { (store) throws(SemanticExpansionError) in
            try lifetimeChecks(store)
        }
        // Every independent pool boundary rejects first excess. The complete
        // published bank is unaffected by the failed attempt.
        for small in [limits(records: 1), limits(paths: 4), limits(depth: 4),
                      limits(payloads: 0), limits(scalars: 1), limits(bytes: UInt32(MemoryLayout<SemanticRecordPayload?>.stride) + 7)] {
            checks += try banks.withStore(small, owner: namespace.issue()) { (store) throws(SemanticExpansionError) in
                var local: UInt32 = 0
                let initial = store.expansionBank(try store.beginCandidate())!
                try enter(initial, .init(kind: .root), store.limits)
                try enter(initial, .init(kind: .declarationRole, role: 1), store.limits)
                expect(initial.appendRecord(limits: store.limits) == nil, &local)
                initial.leave(); initial.leave(); initial.metadata.pointee.phase = .candidate
                try store.publishCandidate()
                do throws(SemanticExpansionError) { try tree(store, branch: 0, marker: 0); preconditionFailure() }
                catch { expect(error == .capacityExhausted, &local) }
                try store.discardCandidate()
                try store.withPublishedView { (prior) throws(SemanticExpansionError) in
                    expect(prior.recordCount == 1 && prior.pathCount == 2 && prior.payloadCount == 0, &local)
                }
                let number = try store.beginCandidate()
                expect(store.expansionBank(number)!.metadata.pointee.records == 0, &local)
                try store.discardCandidate()
                return local
            }
        }
        checks += try banks.withStore(limits(records: 2, paths: 5, depth: 5, fanout: 1, payloads: 1, scalars: 2, bytes: UInt32(MemoryLayout<SemanticRecordPayload?>.stride) + 8), owner: namespace.issue()) {
            (store) throws(SemanticExpansionError) in
            try tree(store, branch: 0, marker: 1)
            try store.publishCandidate()
            return try store.withPublishedView { (view) throws(SemanticExpansionError) in
                var local: UInt32 = 0
                expect(view.recordCount == 2 && view.pathCount == 5 && view.payloadCount == 1 && view.scalarCount == 2, &local)
                expect(view.payloadBytes == UInt32(MemoryLayout<SemanticRecordPayload?>.stride) + 8, &local)
                return local
            }
        }
        var prefix = SemanticCompleteIdentity()
        expect(prefix.append(.init(kind: .root)), &checks)
        var roleA = prefix; var roleB = prefix; var modifierA = prefix; var modifierB = prefix
        expect(roleA.append(.init(kind: .declarationRole, role: 1)), &checks)
        expect(roleB.append(.init(kind: .declarationRole, role: 2)), &checks)
        expect(modifierA.append(.init(kind: .declarationRole, role: 1, modifier: 1)), &checks)
        expect(modifierB.append(.init(kind: .declarationRole, role: 1, modifier: 2)), &checks)
        expect(prefix != roleA && roleA != roleB && modifierA != modifierB && roleA != modifierA, &checks)
        // All of these would collide under a constant hash. No hash enters the
        // component equality or paired matching algorithm.
        // Fanout is independent of path count and includes all fixed children.
        checks += try banks.withStore(limits(fanout: 1), owner: namespace.issue()) { (store) throws(SemanticExpansionError) in
            var local: UInt32 = 0; let bank = store.expansionBank(try store.beginCandidate())!
            try enter(bank, .init(kind: .root), store.limits)
            try enter(bank, .init(kind: .fixedChild), store.limits); bank.leave()
            expect(bank.enter(.init(kind: .fixedChild, ordinal: 1), limits: store.limits) == .capacityExhausted, &local)
            try store.discardCandidate(); return local
        }
        // Malformed components and duplicate children are identity failures.
        checks += try banks.withStore(limits(), owner: namespace.issue()) { (store) throws(SemanticExpansionError) in
            var local: UInt32 = 0; let bank = store.expansionBank(try store.beginCandidate())!
            expect(bank.enter(.init(kind: .fixedChild, ordinal: 5), limits: store.limits) == .invalidIdentity, &local)
            try store.discardCandidate()
            let next = store.expansionBank(try store.beginCandidate())!
            try enter(next, .init(kind: .root), store.limits)
            try enter(next, .init(kind: .fixedChild), store.limits); next.leave()
            expect(next.enter(.init(kind: .fixedChild), limits: store.limits) == .invalidIdentity, &local)
            try store.discardCandidate(); return local
        }
        // Maximum authored fixed fanout: five siblings, with exact matching
        // comparisons 1 root + 1 role + (1+2+3+4+5) children + 5 leaf roles.
        checks += try banks.withStore(limits(), owner: namespace.issue()) { (store) throws(SemanticExpansionError) in
            var local: UInt32 = 0
            for _ in 0..<2 {
                let bank = store.expansionBank(try store.beginCandidate())!
                try enter(bank, .init(kind: .root), store.limits)
                try enter(bank, .init(kind: .declarationRole, role: 1), store.limits)
                if let error = bank.appendRecord(limits: store.limits) { throw error }
                for ordinal: UInt8 in 0..<5 {
                    try enter(bank, .init(kind: .fixedChild, ordinal: ordinal), store.limits)
                    try enter(bank, .init(kind: .declarationRole, role: 2), store.limits)
                    if let error = bank.appendRecord(limits: store.limits) { throw error }
                    bank.leave(); bank.leave()
                }
                bank.leave(); bank.leave(); bank.metadata.pointee.phase = .candidate
                try store.publishCandidate()
            }
            try store.withPublishedView { (view) throws(SemanticExpansionError) in
                expect(view.recordCount == 6 && view.pathCount == 12, &local)
                expect(view.componentComparisons == 22, &local)
                expect(view.componentComparisons <= UInt32(view.pathCount) * 5, &local)
            }
            return local
        }
        return checks
    } catch { return 0 }
}
