import GiftUI

/// Owns no backing. The factory lends all five real storage regions until its
/// Escapable-result callback ends; neither this scope nor a reader may escape.
package func withSemanticRecordStore<Payload, Result>(
    metadata: inout MutableSpan<SemanticRecordBankMetadata>,
    records: inout MutableSpan<SemanticRuntimeRecord>,
    paths: inout MutableSpan<SemanticPathEntry>,
    payloads: inout MutableSpan<Payload?>,
    scalars: inout MutableSpan<UInt32>,
    limits: SemanticRecordLimits,
    capacity: SemanticRecordLimits? = nil,
    owner: SemanticRecordOwnerIdentity,
    _ body: (borrowing SemanticRecordStore<Payload>) throws(SemanticExpansionError) -> Result
) throws(SemanticExpansionError) -> Result {
    let capacity = capacity ?? limits
    guard capacity.records >= limits.records, capacity.paths >= limits.paths,
        capacity.payloads >= limits.payloads, capacity.textScalars >= limits.textScalars,
        metadata.count == 2, records.count >= Int(capacity.records) * 2,
        paths.count >= Int(capacity.paths) * 2, payloads.count >= Int(capacity.payloads) * 2,
        scalars.count >= Int(capacity.textScalars) * 2
    else { throw .capacityExhausted }
    guard metadata[0].phase == .idle, metadata[1].phase == .idle else { throw .reentrancyViolation }
    return try metadata.withUnsafeMutableBufferPointer { (meta) throws(SemanticExpansionError) in
        try records.withUnsafeMutableBufferPointer {
            (recordBuffer) throws(SemanticExpansionError) in
            try paths.withUnsafeMutableBufferPointer {
                (pathBuffer) throws(SemanticExpansionError) in
                try payloads.withUnsafeMutableBufferPointer {
                    (payloadBuffer) throws(SemanticExpansionError) in
                    try scalars.withUnsafeMutableBufferPointer {
                        (scalarBuffer) throws(SemanticExpansionError) in
                        func bank(_ number: Int) -> SemanticRecordBankBuffers<Payload> {
                            SemanticRecordBankBuffers(
                                metadata: meta.baseAddress! + number,
                                records: .init(
                                    rebasing: recordBuffer[
                                        (number * Int(capacity.records))
                                            ..< ((number + 1) * Int(capacity.records))]),
                                paths: .init(
                                    rebasing: pathBuffer[
                                        (number * Int(capacity.paths))
                                            ..< ((number + 1) * Int(capacity.paths))]),
                                payloads: .init(
                                    rebasing: payloadBuffer[
                                        (number * Int(capacity.payloads))
                                            ..< ((number + 1) * Int(capacity.payloads))]),
                                scalars: .init(
                                    rebasing: scalarBuffer[
                                        (number * Int(capacity.textScalars))
                                            ..< ((number + 1) * Int(capacity.textScalars))]))
                        }
                        let a = bank(0)
                        let b = bank(1)
                        let scope = SemanticRecordStore(a: a, b: b, limits: limits, owner: owner)
                        defer {
                            a.clear()
                            b.clear()
                        }
                        return try body(scope)
                    }
                }
            }
        }
    }
}

package struct SemanticRecordStore<Payload>: ~Copyable, ~Escapable {
    private let a: SemanticRecordBankBuffers<Payload>
    private let b: SemanticRecordBankBuffers<Payload>
    package let limits: SemanticRecordLimits
    private let owner: SemanticRecordOwnerIdentity
    @_lifetime(borrow a, borrow b)
    fileprivate init(
        a: borrowing SemanticRecordBankBuffers<Payload>,
        b: borrowing SemanticRecordBankBuffers<Payload>, limits: SemanticRecordLimits,
        owner: SemanticRecordOwnerIdentity
    ) {
        self.a = copy a
        self.b = copy b
        self.limits = limits
        self.owner = owner
    }
    @_lifetime(copy self)
    package borrowing func borrowedStore() -> SemanticRecordStore<Payload> {
        SemanticRecordStore(borrowing: self)
    }

    @_lifetime(copy other)
    private init(borrowing other: borrowing SemanticRecordStore<Payload>) {
        a = other.a
        b = other.b
        limits = other.limits
        owner = other.owner
    }

    private borrowing func bank(_ number: UInt8) -> SemanticRecordBankBuffers<Payload> {
        number == 0 ? a : b
    }
    private var candidate: UInt8? {
        if a.metadata.pointee.phase == .candidate { return 0 }
        if b.metadata.pointee.phase == .candidate { return 1 }
        return nil
    }
    private var published: UInt8? {
        if a.metadata.pointee.phase == .published { return 0 }
        if b.metadata.pointee.phase == .published { return 1 }
        return nil
    }
    package borrowing func beginCandidate() throws(SemanticExpansionError) -> UInt8 {
        guard candidate == nil, a.metadata.pointee.phase != .expanding,
            b.metadata.pointee.phase != .expanding
        else { throw .reentrancyViolation }
        let number: UInt8
        if a.metadata.pointee.phase == .idle {
            number = 0
        } else if b.metadata.pointee.phase == .idle {
            number = 1
        } else {
            throw .capacityExhausted
        }
        let selected = bank(number)
        guard selected.metadata.pointee.readers == 0 else { throw .invariantViolation }
        let next = selected.metadata.pointee.revision.addingReportingOverflow(1)
        guard !next.overflow, next.partialValue != 0 else { throw .invalidIdentity }
        selected.clear()
        selected.metadata.pointee.revision = next.partialValue
        selected.metadata.pointee.phase = .expanding
        return number
    }
    package borrowing func discardCandidate() throws(SemanticExpansionError) {
        for number: UInt8 in 0 ..< 2 {
            let selected = bank(number)
            if selected.metadata.pointee.phase == .candidate
                || selected.metadata.pointee.phase == .expanding
            {
                if selected.metadata.pointee.readers == 0 {
                    selected.clear()
                } else {
                    selected.metadata.pointee.phase = .retired
                }
                return
            }
        }
        throw .invariantViolation
    }
    /// The caller has prepared all other candidate products. This is the
    /// semantic-bank swap, not accepted-offer action routing.
    package borrowing func publishCandidate() throws(SemanticExpansionError) {
        guard let candidate else { throw .invariantViolation }
        let next = bank(candidate)
        guard !hasPendingCanvas(next) else { throw .invariantViolation }
        if let published {
            let prior = bank(published)
            if let failure = next.reconcile(with: prior, limits: limits) { throw failure }
            prior.metadata.pointee.phase = .retired
            if prior.metadata.pointee.readers == 0 { prior.clear() }
        }
        next.metadata.pointee.phase = .published
    }
    package borrowing func withCandidateView<Result>(
        _ body: (borrowing SemanticRecordView<Payload>) throws(SemanticExpansionError) -> Result
    ) throws(SemanticExpansionError) -> Result {
        guard let candidate, !hasPendingCanvas(bank(candidate)) else { throw .invariantViolation }
        return try withView(candidate, body)
    }
    private borrowing func hasPendingCanvas(_ bank: SemanticRecordBankBuffers<Payload>) -> Bool {
        for index in 0 ..< Int(bank.metadata.pointee.records) {
            if bank.records[index].kind == .pendingCanvas { return true }
        }
        return false
    }

    /// Transfer transient owned Canvas values before lending consumer views.
    /// A failed transfer remains unpublished; the drawing adapter discards both
    /// this candidate and any already-transferred entries.
    package borrowing func takePendingCanvas(
        _ body: (SemanticRecordReference, inout Payload) throws(SemanticExpansionError) -> Void
    ) throws(SemanticExpansionError) {
        guard let candidate else { throw .invariantViolation }
        let selected = bank(candidate)
        guard selected.metadata.pointee.readers == 0 else { throw .reentrancyViolation }
        for index in 0 ..< Int(selected.metadata.pointee.records) {
            let record = selected.records[index]
            guard record.kind == .pendingCanvas else { continue }
            guard record.payload < selected.metadata.pointee.payloads,
                selected.payloads[Int(record.payload)] != nil
            else { throw .invariantViolation }
            let reference = SemanticRecordReference(
                owner: owner, bank: candidate,
                revision: selected.metadata.pointee.revision, ordinal: UInt16(index))
            try body(reference, &selected.payloads[Int(record.payload)]!)
            selected.records[index].kind = .primitive
        }
    }

    package borrowing func withPublishedView<Result>(
        _ body: (borrowing SemanticRecordView<Payload>) throws(SemanticExpansionError) -> Result
    ) throws(SemanticExpansionError) -> Result {
        guard let published else { throw .invariantViolation }
        return try withView(published, body)
    }
    private borrowing func withView<Result>(
        _ number: UInt8,
        _ body: (borrowing SemanticRecordView<Payload>) throws(SemanticExpansionError) -> Result
    ) throws(SemanticExpansionError) -> Result {
        let selected = bank(number)
        let readers = selected.metadata.pointee.readers.addingReportingOverflow(1)
        guard !readers.overflow else { throw .capacityExhausted }
        selected.metadata.pointee.readers = readers.partialValue
        defer {
            selected.metadata.pointee.readers -= 1
            if selected.metadata.pointee.readers == 0 && selected.metadata.pointee.phase == .retired
            {
                selected.clear()
            }
        }
        let view = SemanticRecordView(bank: selected, number: number, owner: owner)
        return try body(view)
    }

    // Restricted to the sole Semantic Core traversal adapter in this module.
    borrowing func expansionBank(_ number: UInt8) -> SemanticRecordBankBuffers<Payload>? {
        guard number < 2 else { return nil }
        let selected = bank(number)
        guard selected.metadata.pointee.phase == .expanding else { return nil }
        return selected
    }
}

package struct SemanticRecordView<Payload>: ~Escapable {
    private let bank: SemanticRecordBankBuffers<Payload>
    package let bankNumber: UInt8
    package let revision: UInt32
    private let owner: SemanticRecordOwnerIdentity
    @_lifetime(borrow bank)
    fileprivate init(
        bank: borrowing SemanticRecordBankBuffers<Payload>, number: UInt8,
        owner: SemanticRecordOwnerIdentity
    ) {
        self.owner = owner
        self.bank = copy bank
        bankNumber = number
        revision = bank.metadata.pointee.revision
    }
    private var valid: Bool {
        bank.metadata.pointee.revision == revision && bank.metadata.pointee.readers > 0
            && (bank.metadata.pointee.phase == .candidate
                || bank.metadata.pointee.phase == .published
                || bank.metadata.pointee.phase == .retired)
    }
    package var isCandidate: Bool { valid && bank.metadata.pointee.phase == .candidate }
    package var rootReference: SemanticRecordReference {
        SemanticRecordReference(owner: owner, bank: bankNumber, revision: revision, ordinal: 0)
    }
    package var recordCount: UInt16 { valid ? bank.metadata.pointee.records : 0 }
    package var pathCount: UInt16 { valid ? bank.metadata.pointee.paths : 0 }
    package var payloadCount: UInt16 { valid ? bank.metadata.pointee.payloads : 0 }
    package var scalarCount: UInt16 { valid ? bank.metadata.pointee.scalars : 0 }
    package var payloadBytes: UInt32 { valid ? bank.metadata.pointee.payloadBytes : 0 }
    package var componentComparisons: UInt32 {
        valid ? bank.metadata.pointee.componentComparisons : 0
    }
    package func reference(at ordinal: UInt16) -> SemanticRecordReference? {
        guard valid, ordinal < recordCount else { return nil }
        return SemanticRecordReference(
            owner: owner, bank: bankNumber, revision: revision, ordinal: ordinal)
    }
    package func record(_ reference: SemanticRecordReference) -> SemanticRuntimeRecord? {
        guard valid, reference.owner == owner, reference.bank == bankNumber,
            reference.revision == revision,
            reference.ordinal < recordCount
        else { return nil }
        return bank.records[Int(reference.ordinal)]
    }
    package func payload(at index: UInt16) -> Payload? {
        guard valid, index < payloadCount else { return nil }
        return bank.payloads[Int(index)]
    }
    package func scalar(at index: UInt16) -> UInt32? {
        guard valid, index < scalarCount else { return nil }
        return bank.scalars[Int(index)]
    }
    package func path(at index: UInt16) -> SemanticPathEntry? {
        guard valid, index < pathCount else { return nil }
        return bank.paths[Int(index)]
    }
    package func completeIdentity(for reference: SemanticRecordReference)
        -> SemanticCompleteIdentity?
    {
        guard let record = record(reference), record.path < pathCount,
            bank.paths[Int(record.path)].component.kind == .declarationRole
        else { return nil }
        var reversed: InlineArray<34, SemanticPathComponent> = .init(repeating: .init(kind: .root))
        var cursor = record.path
        var count = 0
        while cursor != .max {
            guard cursor < pathCount, count < Int(SemanticCompleteIdentity.capacity) else {
                return nil
            }
            let entry = bank.paths[Int(cursor)]
            guard entry.parent == .max || entry.parent < cursor else { return nil }
            reversed[count] = entry.component
            count += 1
            cursor = entry.parent
        }
        var identity = SemanticCompleteIdentity()
        while count > 0 {
            count -= 1
            guard identity.append(reversed[count]) else { return nil }
        }
        return identity
    }
    package func sameIdentity(
        _ reference: SemanticRecordReference, as other: SemanticRecordReference,
        in view: borrowing Self
    ) -> Bool {
        guard let left = completeIdentity(for: reference),
            let right = view.completeIdentity(for: other)
        else { return false }
        return left == right
    }
}
