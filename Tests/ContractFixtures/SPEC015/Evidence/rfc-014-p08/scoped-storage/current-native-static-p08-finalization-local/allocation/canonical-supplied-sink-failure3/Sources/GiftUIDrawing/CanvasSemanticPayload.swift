import GiftUI
import GiftUISemanticCore

/// Scalar control for one pending expansion. Captures and canonical payload
/// ordinals are parallel initialized buffers supplied by the attempt owner.
@usableFromInline
package struct CanvasPendingMetadata {
    @usableFromInline internal var count: UInt16 = 0
    @usableFromInline internal var owner: SemanticRecordOwnerIdentity?
    @usableFromInline internal var bank: UInt8 = 0
    @usableFromInline internal var revision: UInt32 = 0
    @inlinable package init() {}
}

/// This lender does not construct the later staged-value store, whose existing
/// Table validation and capacity refusal stay after successful expansion.
@inlinable
package func withCanvasSemanticPayloadCodec<
    Codec: CanvasSemanticPayloadCodec & ~Escapable, Result
>(
    metadata: inout CanvasPendingMetadata,
    captures: inout MutableSpan<Codec.Table.CaptureStorage?>,
    payloadOrdinals: inout MutableSpan<UInt16>, capacity: UInt16,
    codec: Codec.Type,
    _ body: (borrowing Codec)
        throws(SemanticExpansionError) -> Result
) throws(SemanticExpansionError) -> Result {
    guard metadata.count == 0 else { throw .reentrancyViolation }
    guard capacity <= captures.count, capacity <= payloadOrdinals.count else {
        throw .capacityExhausted
    }
    guard case .none = metadata.owner else { throw .invariantViolation }
    for index in 0 ..< Int(capacity) {
        if case .some = captures[index] { throw .invariantViolation }
        guard payloadOrdinals[index] == .max else { throw .invariantViolation }
    }
    return try withUnsafeMutablePointer(to: &metadata) { (state) throws(SemanticExpansionError) in
        try captures.withUnsafeMutableBufferPointer {
            (captureBuffer) throws(SemanticExpansionError) in
            try payloadOrdinals.withUnsafeMutableBufferPointer {
                (ordinalBuffer) throws(SemanticExpansionError) in
                let codec = Codec.makeCodec(
                    state: state, captures: captureBuffer, payloadOrdinals: ordinalBuffer,
                    capacity: capacity)
                defer { codec.discardPending() }
                return try body(codec)
            }
        }
    }
}

/// Typed captures are reachable only during traversal and transfer. Canonical
/// consumers are nongeneric and see an ordinary value or the Canvas marker.
@usableFromInline
package protocol CanvasSemanticPayloadCodec: SemanticRecordPayloadCodec, ~Escapable {
    associatedtype Roles: SemanticDeclarationRoles
    associatedtype Table: CanvasValueTable

    var state: UnsafeMutablePointer<CanvasPendingMetadata> { get }
    var captures: UnsafeMutableBufferPointer<Table.CaptureStorage?> { get }
    var payloadOrdinals: UnsafeMutableBufferPointer<UInt16> { get }
    var capacity: UInt16 { get }

    @_lifetime(borrow state, borrow captures, borrow payloadOrdinals)
    static func makeCodec(
        state: borrowing UnsafeMutablePointer<CanvasPendingMetadata>,
        captures: borrowing UnsafeMutableBufferPointer<Table.CaptureStorage?>,
        payloadOrdinals: borrowing UnsafeMutableBufferPointer<UInt16>, capacity: UInt16
    ) -> Self
}

extension CanvasSemanticPayloadCodec {
    @inlinable
    package borrowing func prepare(maximumSemanticNodes: UInt16) -> SemanticExpansionError? {
        guard state.pointee.count == 0 else { return .reentrancyViolation }
        guard capacity >= maximumSemanticNodes else { return .capacityExhausted }
        return nil
    }

    @inlinable
    package borrowing func ownsPendingCandidate(
        owner: SemanticRecordOwnerIdentity, bank: UInt8, revision: UInt32, required: Bool
    ) -> Bool {
        if state.pointee.count == 0 { return !required }
        guard let expected = state.pointee.owner else { return false }
        guard expected == owner else { return false }
        guard state.pointee.bank == bank else { return false }
        return state.pointee.revision == revision
    }

    @inlinable
    package var pendingCount: UInt16 { state.pointee.count }

    /// Read-only lifecycle observations used by the immediate failure oracles.
    @inlinable
    package var initializedCaptureCount: UInt16 {
        var count: UInt16 = 0
        for index in 0 ..< Int(capacity) {
            if case .some = captures[index] { count += 1 }
        }
        return count
    }

    @inlinable
    package var pendingStorageIsClear: Bool {
        guard state.pointee.count == 0, initializedCaptureCount == 0 else { return false }
        for index in 0 ..< Int(capacity) {
            if payloadOrdinals[index] != .max { return false }
        }
        return true
    }

    @inlinable
    package borrowing func primitive<Value: _GiftUISemanticPrimitivePayload>(
        _ value: borrowing Value, writer: borrowing SemanticPayloadWriter
    ) -> SemanticExpansionError? {
        if let canvas = Table.payload(value) {
            let bytes =
                UInt64(MemoryLayout<Table.CaptureStorage?>.stride)
                + UInt64(MemoryLayout<UInt16>.stride)
            let pendingState = state
            let captureBuffer = captures
            let ordinalBuffer = payloadOrdinals
            let pendingCapacity = capacity
            return writer.storeCanvas(additionalBytes: bytes) { ordinal, reference in
                let index = pendingState.pointee.count
                guard index < pendingCapacity else { return .capacityExhausted }
                if index == 0 {
                    pendingState.pointee.owner = reference.owner
                    pendingState.pointee.bank = reference.bank
                    pendingState.pointee.revision = reference.revision
                } else {
                    guard let owner = pendingState.pointee.owner, owner == reference.owner,
                        pendingState.pointee.bank == reference.bank,
                        pendingState.pointee.revision == reference.revision
                    else { return .invariantViolation }
                }
                captureBuffer[Int(index)] = canvas
                ordinalBuffer[Int(index)] = ordinal
                pendingState.pointee.count += 1
                return nil
            }
        }
        return SemanticStandardPayloadCodec.primitive(value, writer: writer)
    }

    @inlinable
    package borrowing func modifier<Value: _GiftUISemanticModifierPayload>(
        _ value: borrowing Value, chainIndex: UInt16,
        writer: borrowing SemanticPayloadWriter
    ) -> SemanticExpansionError? {
        SemanticStandardPayloadCodec.modifier(
            value, chainIndex: chainIndex, writer: writer)
    }

    @inlinable
    package borrowing func action<Value: GiftUIAction>(
        _ value: borrowing Value, writer: borrowing SemanticPayloadWriter
    ) -> SemanticExpansionError? {
        SemanticStandardPayloadCodec.action(value, writer: writer, roles: Roles.self)
    }

    @inlinable
    package borrowing func discardPending() {
        for index in 0 ..< Int(state.pointee.count) {
            captures[index] = nil
            payloadOrdinals[index] = .max
        }
        state.pointee.count = 0
        state.pointee.owner = nil
        state.pointee.bank = 0
        state.pointee.revision = 0
    }
}

@usableFromInline
package enum CanvasSemanticTransfer {
    @inlinable
    package static func stage<Codec: CanvasSemanticPayloadCodec & ~Escapable>(
        from semantic: borrowing SemanticRecordStore,
        pending: borrowing Codec,
        into values: borrowing CanvasStagedValues<SemanticRecordReference, Codec.Table>,
        table: borrowing Codec.Table
    ) throws(DrawingError) {
        guard values.count == 0 else { throw .invariantViolation }
        let table = copy table
        // A foreign checked codec must be rejected without destroying either
        // its captures or this store's candidate. Cleanup below is only ours.
        do throws(SemanticExpansionError) {
            try semantic.validatePendingCandidate(using: pending)
        } catch { throw .invariantViolation }
        let pendingState = pending.state
        let captureBuffer = pending.captures
        let ordinalBuffer = pending.payloadOrdinals
        var cursor: UInt16 = 0
        do throws(SemanticExpansionError) {
            try semantic.takePendingCanvas { (identity, ordinal) throws(SemanticExpansionError) in
                guard cursor < pendingState.pointee.count,
                    let owner = pendingState.pointee.owner, owner == identity.owner,
                    pendingState.pointee.bank == identity.bank,
                    pendingState.pointee.revision == identity.revision,
                    ordinalBuffer[Int(cursor)] == ordinal,
                    let value = captureBuffer[Int(cursor)]
                else { throw .invariantViolation }
                do throws(DrawingError) {
                    try values.stage(identity: identity, value: value, table: table)
                } catch {
                    throw error == .capacityExhausted ? .capacityExhausted : .invariantViolation
                }
                captureBuffer[Int(cursor)] = nil
                cursor += 1
            }
            guard cursor == pending.state.pointee.count else { throw .invariantViolation }
            pending.discardPending()
        } catch {
            values.discard()
            try? semantic.discardCandidate(using: pending)
            throw error == .capacityExhausted ? .capacityExhausted : .invariantViolation
        }
    }
}
