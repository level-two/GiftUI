import GiftUI

/// Owns no backing. The factory lends all five real storage regions until its
/// Escapable-result callback ends; neither this scope nor a reader may escape.
@inlinable
@inline(__always)
package func withSemanticRecordStore<Result>(
    metadata: inout MutableSpan<SemanticRecordBankMetadata>,
    records: inout MutableSpan<SemanticRuntimeRecord>,
    paths: inout MutableSpan<SemanticPathEntry>,
    payloads: inout MutableSpan<SemanticRecordPayload?>,
    scalars: inout MutableSpan<UInt32>,
    limits: SemanticRecordLimits,
    capacity: SemanticRecordLimits? = nil,
    owner: SemanticRecordOwnerIdentity,
    _ body: (borrowing SemanticRecordStore) throws(SemanticExpansionError) -> Result
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
                        func bank(_ number: Int) -> SemanticRecordBankBuffers {
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

@usableFromInline
package struct SemanticRecordStore: ~Copyable, ~Escapable {
    @usableFromInline
    let a: SemanticRecordBankBuffers
    @usableFromInline
    let b: SemanticRecordBankBuffers
    @usableFromInline
    package let limits: SemanticRecordLimits
    @usableFromInline
    let owner: SemanticRecordOwnerIdentity
    @_lifetime(borrow a, borrow b)
    @usableFromInline
    init(
        a: borrowing SemanticRecordBankBuffers,
        b: borrowing SemanticRecordBankBuffers, limits: SemanticRecordLimits,
        owner: SemanticRecordOwnerIdentity
    ) {
        self.a = copy a
        self.b = copy b
        self.limits = limits
        self.owner = owner
    }
    @_lifetime(copy self)
    @inlinable
    package borrowing func borrowedStore() -> SemanticRecordStore {
        SemanticRecordStore(borrowing: self)
    }

    @_lifetime(copy other)
    @inlinable
    internal init(borrowing other: borrowing SemanticRecordStore) {
        a = other.a
        b = other.b
        limits = other.limits
        owner = other.owner
    }

    @inlinable
    borrowing func bank(_ number: UInt8) -> SemanticRecordBankBuffers {
        number == 0 ? a : b
    }
    @inlinable
    var candidate: UInt8? {
        if a.metadata.pointee.phase == .candidate { return 0 }
        if b.metadata.pointee.phase == .candidate { return 1 }
        return nil
    }
    @inlinable
    var published: UInt8? {
        if a.metadata.pointee.phase == .published { return 0 }
        if b.metadata.pointee.phase == .published { return 1 }
        return nil
    }
    /// Clears retained semantic products only after the owning runtime has ended
    /// candidates and scoped readers. Bank revisions remain monotonic.
    package borrowing func resetAfterQuiescence() throws(SemanticExpansionError) {
        guard a.metadata.pointee.readers == 0, b.metadata.pointee.readers == 0,
            a.metadata.pointee.phase != .expanding, b.metadata.pointee.phase != .expanding,
            a.metadata.pointee.phase != .candidate, b.metadata.pointee.phase != .candidate
        else { throw .reentrancyViolation }
        a.clear()
        b.clear()
    }

    @inlinable
    @inline(__always)
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
    @inlinable
    package borrowing func discardCandidate() throws(SemanticExpansionError) {
        for number: UInt8 in 0 ..< 2 {
            let selected = bank(number)
            if selected.metadata.pointee.phase == .candidate
                || selected.metadata.pointee.phase == .expanding
            {
                guard !hasPendingCanvas(selected) else { throw .invariantViolation }
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

    /// Typed pending values belong to this attempt, not a published bank.
    /// Preserve the candidate/phase checks before releasing that side pool.
    @inlinable
    package borrowing func discardCandidate<Codec: SemanticRecordPayloadCodec & ~Escapable>(
        using codec: borrowing Codec
    ) throws(SemanticExpansionError) {
        for number: UInt8 in 0 ..< 2 {
            let selected = bank(number)
            if selected.metadata.pointee.phase == .candidate
                || selected.metadata.pointee.phase == .expanding
            {
                guard
                    codec.ownsPendingCandidate(
                        owner: owner, bank: number, revision: selected.metadata.pointee.revision,
                        required: hasPendingCanvas(selected))
                else { throw .invariantViolation }
                codec.discardPending()
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

    @inlinable
    package borrowing func validatePendingCandidate<Codec: SemanticRecordPayloadCodec & ~Escapable>(
        using codec: borrowing Codec
    ) throws(SemanticExpansionError) {
        guard let candidate else { throw .invariantViolation }
        let selected = bank(candidate)
        guard selected.metadata.pointee.readers == 0 else { throw .reentrancyViolation }
        guard
            codec.ownsPendingCandidate(
                owner: owner, bank: candidate, revision: selected.metadata.pointee.revision,
                required: hasPendingCanvas(selected))
        else { throw .invariantViolation }
    }
    /// The caller has prepared all other candidate products. This is the
    /// semantic-bank swap, not accepted-offer action routing.
    @inlinable
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
    @inlinable
    @inline(__always)
    package borrowing func withCandidateView<Result>(
        _ body: (borrowing SemanticRecordView) throws(SemanticExpansionError) -> Result
    ) throws(SemanticExpansionError) -> Result {
        guard let candidate, !hasPendingCanvas(bank(candidate)) else { throw .invariantViolation }
        return try withView(candidate, body)
    }
    @inlinable
    borrowing func hasPendingCanvas(_ bank: SemanticRecordBankBuffers) -> Bool {
        for index in 0 ..< Int(bank.metadata.pointee.records) {
            if bank.records[index].kind == .pendingCanvas { return true }
        }
        return false
    }

    /// Transfer transient owned Canvas values before lending consumer views.
    /// A failed transfer remains unpublished; the drawing adapter discards both
    /// this candidate and any already-transferred entries.
    @inlinable
    package borrowing func takePendingCanvas(
        _ body: (SemanticRecordReference, UInt16) throws(SemanticExpansionError) -> Void
    ) throws(SemanticExpansionError) {
        guard let candidate else { throw .invariantViolation }
        let selected = bank(candidate)
        guard selected.metadata.pointee.readers == 0 else { throw .reentrancyViolation }
        for index in 0 ..< Int(selected.metadata.pointee.records) {
            let record = selected.records[index]
            guard record.kind == .pendingCanvas else { continue }
            guard record.payload < selected.metadata.pointee.payloads,
                case .canvas? = selected.payloads[Int(record.payload)]
            else { throw .invariantViolation }
            let reference = SemanticRecordReference(
                owner: owner, bank: candidate,
                revision: selected.metadata.pointee.revision, ordinal: UInt16(index))
            try body(reference, record.payload)
            selected.records[index].kind = .primitive
        }
    }

    @inlinable
    @inline(__always)
    package borrowing func withPublishedView<Result>(
        _ body: (borrowing SemanticRecordView) throws(SemanticExpansionError) -> Result
    ) throws(SemanticExpansionError) -> Result {
        guard let published else { throw .invariantViolation }
        return try withView(published, body)
    }
    @inlinable
    @inline(__always)
    borrowing func withView<Result>(
        _ number: UInt8,
        _ body: (borrowing SemanticRecordView) throws(SemanticExpansionError) -> Result
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
    @inlinable
    borrowing func expansionBank(_ number: UInt8) -> SemanticRecordBankBuffers? {
        guard number < 2 else { return nil }
        let selected = bank(number)
        guard selected.metadata.pointee.phase == .expanding else { return nil }
        return selected
    }
}

/// Shared expansion bookkeeping owns no capture or codec. Concrete supplied
/// sinks forward here while retaining their separately checked codec loan.
@usableFromInline
package struct SemanticRecordSinkState: ~Escapable {
    private let bank: SemanticRecordBankBuffers
    private let owner: SemanticRecordOwnerIdentity
    private let bankNumber: UInt8
    private let limits: SemanticRecordLimits
    private let expansion: SemanticExpansionLimits
    private var bodyCount: UInt16 = 0
    private var semanticCount: UInt16 = 0
    private var modifierCount: UInt16 = 0
    private var actionCount: UInt16 = 0
    @_lifetime(borrow bank)
    @usableFromInline
    init(
        bank: borrowing SemanticRecordBankBuffers,
        owner: SemanticRecordOwnerIdentity, bankNumber: UInt8, limits: SemanticRecordLimits,
        expansion: SemanticExpansionLimits
    ) {
        self.owner = owner
        self.bankNumber = bankNumber
        self.bank = copy bank
        self.limits = limits
        self.expansion = expansion
    }
    @usableFromInline
    package var stagingFailure: SemanticExpansionError? { bank.metadata.pointee.failure }
    @usableFromInline
    package var maximumStructuralOccurrences: UInt16 { limits.records }
    @usableFromInline
    package var maximumBodyEvaluations: UInt16 { expansion.maximumBodyEvaluations }
    @usableFromInline
    package var maximumSemanticOccurrences: UInt16 { expansion.maximumSemanticNodes }
    @usableFromInline
    package var maximumModifierApplications: UInt16 { expansion.maximumModifierApplications }
    @usableFromInline
    package var maximumActionOccurrences: UInt16 { expansion.maximumActionOccurrences }
    @usableFromInline
    package mutating func beginExpansion() -> Bool { bank.metadata.pointee.phase == .expanding }
    @usableFromInline
    package mutating func stageStructuralOccurrence(identity: borrowing SemanticCompleteIdentity)
        -> Bool
    {
        bank.appendRecord(limits: limits) == nil
    }
    @usableFromInline
    package mutating func stageBodyEvaluation(identity: borrowing SemanticCompleteIdentity) -> Bool
    {
        bodyCount += 1
        return true
    }
    @_lifetime(copy self)
    @usableFromInline
    package borrowing func payloadWriter() -> SemanticPayloadWriter {
        SemanticPayloadWriter(bank: bank, limits: limits, owner: owner, bankNumber: bankNumber)
    }
    @usableFromInline
    package mutating func stageSemanticResult(_ error: SemanticExpansionError?) -> Bool {
        if let error {
            _ = bank.fail(error)
            return false
        }
        semanticCount += 1
        return true
    }
    @usableFromInline
    package mutating func stageModifierResult(_ error: SemanticExpansionError?) -> Bool {
        if let error {
            _ = bank.fail(error)
            return false
        }
        modifierCount += 1
        return true
    }
    @usableFromInline
    package mutating func stageActionResult(_ error: SemanticExpansionError?) -> Bool {
        if let error {
            _ = bank.fail(error)
            return false
        }
        semanticCount += 1
        actionCount += 1
        return true
    }
    @usableFromInline
    package mutating func publishExpansion(_ summary: SemanticExpansionSummary) -> Bool {
        guard bank.metadata.pointee.phase == .expanding, bank.metadata.pointee.failure == nil,
            bank.metadata.pointee.activePath == .max, summary.bodyEvaluationCount == bodyCount,
            summary.semanticNodeCount == semanticCount,
            summary.modifierApplicationCount == modifierCount,
            summary.actionOccurrenceCount == actionCount
        else { return false }
        bank.metadata.pointee.summary = summary
        bank.metadata.pointee.phase = .candidate
        return true
    }
    @usableFromInline
    package mutating func discardExpansion() {}
    @usableFromInline
    package mutating func resetExpansion() {}
}

@frozen
@usableFromInline
package struct SemanticRecordView: BitwiseCopyable, ~Escapable {
    @usableFromInline
    internal let metadata: UnsafePointer<SemanticRecordBankMetadata>
    @usableFromInline
    internal let records: UnsafeBufferPointer<SemanticRuntimeRecord>
    @usableFromInline
    internal let paths: UnsafeBufferPointer<SemanticPathEntry>
    @usableFromInline
    internal let payloads: UnsafeBufferPointer<SemanticRecordPayload?>
    @usableFromInline
    internal let scalars: UnsafeBufferPointer<UInt32>
    @usableFromInline
    package let bankNumber: UInt8
    @usableFromInline
    package let revision: UInt32
    @usableFromInline
    internal let owner: SemanticRecordOwnerIdentity
    @_lifetime(borrow bank)
    @inlinable
    init(
        bank: borrowing SemanticRecordBankBuffers, number: UInt8,
        owner: SemanticRecordOwnerIdentity
    ) {
        self.owner = owner
        metadata = UnsafePointer(bank.metadata)
        records = UnsafeBufferPointer(bank.records)
        paths = UnsafeBufferPointer(bank.paths)
        payloads = UnsafeBufferPointer(bank.payloads)
        scalars = UnsafeBufferPointer(bank.scalars)
        bankNumber = number
        revision = bank.metadata.pointee.revision
    }
    @inlinable
    internal var valid: Bool {
        metadata.pointee.revision == revision && metadata.pointee.readers > 0
            && (metadata.pointee.phase == .candidate
                || metadata.pointee.phase == .published
                || metadata.pointee.phase == .retired)
    }
    @inlinable
    package var isCandidate: Bool { valid && metadata.pointee.phase == .candidate }
    package var rootReference: SemanticRecordReference {
        SemanticRecordReference(owner: owner, bank: bankNumber, revision: revision, ordinal: 0)
    }
    @inlinable
    package var recordCount: UInt16 { valid ? metadata.pointee.records : 0 }
    @inlinable
    package var pathCount: UInt16 { valid ? metadata.pointee.paths : 0 }
    @inlinable
    package var payloadCount: UInt16 { valid ? metadata.pointee.payloads : 0 }
    package var scalarCount: UInt16 { valid ? metadata.pointee.scalars : 0 }
    package var payloadBytes: UInt32 { valid ? metadata.pointee.payloadBytes : 0 }
    package var componentComparisons: UInt32 {
        valid ? metadata.pointee.componentComparisons : 0
    }
    @inlinable
    package func reference(at ordinal: UInt16) -> SemanticRecordReference? {
        guard valid, ordinal < recordCount else { return nil }
        return SemanticRecordReference(
            owner: owner, bank: bankNumber, revision: revision, ordinal: ordinal)
    }
    @inlinable
    package func record(_ reference: SemanticRecordReference) -> SemanticRuntimeRecord? {
        guard valid, reference.owner == owner, reference.bank == bankNumber,
            reference.revision == revision,
            reference.ordinal < recordCount
        else { return nil }
        return records[Int(reference.ordinal)]
    }
    @inlinable
    package func payload(at index: UInt16) -> SemanticRecordPayload? {
        guard valid, index < payloadCount else { return nil }
        return payloads[Int(index)]
    }
    package func scalar(at index: UInt16) -> UInt32? {
        guard valid, index < scalarCount else { return nil }
        return scalars[Int(index)]
    }
    package func path(at index: UInt16) -> SemanticPathEntry? {
        guard valid, index < pathCount else { return nil }
        return paths[Int(index)]
    }
    @inlinable
    package func completeIdentity(for reference: SemanticRecordReference)
        -> SemanticCompleteIdentity?
    {
        guard let record = record(reference), record.path < pathCount,
            paths[Int(record.path)].component.kind == .declarationRole
        else { return nil }
        var reversed: InlineArray<34, SemanticPathComponent> = .init(repeating: .init(kind: .root))
        var cursor = record.path
        var count = 0
        while cursor != .max {
            guard cursor < pathCount, count < Int(SemanticCompleteIdentity.capacity) else {
                return nil
            }
            let entry = paths[Int(cursor)]
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
