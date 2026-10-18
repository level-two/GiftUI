import GiftUI

/// Finite schema/type dispatch, generated independently of runtime occurrences.
@usableFromInline
package protocol CanvasValueTable: StaticCanvasCallableTable {
    static func caseID(for value: borrowing CaptureStorage) -> UInt16
    static func payload<Value: _GiftUISemanticPrimitivePayload>(
        _ value: borrowing Value
    ) -> CaptureStorage?
}

@usableFromInline
package struct CanvasStagedEntry<Identity: Equatable & Sendable, Payload> {
    @usableFromInline
    package let identity: Identity
    @usableFromInline
    package let witness: UInt16
    @usableFromInline
    internal var value: Payload?
    @usableFromInline
    internal var invoked = false

    @inlinable
    internal init(
        identity: Identity,
        witness: UInt16,
        value: Payload?,
        invoked: Bool = false
    ) {
        self.identity = identity
        self.witness = witness
        self.value = value
        self.invoked = invoked
    }
}

@usableFromInline
package struct CanvasStagedMetadata {
    @usableFromInline
    package internal(set) var count: UInt16 = 0
    @usableFromInline
    package internal(set) var releases: UInt16 = 0
    @inlinable
    package init() {}
}

/// Both profile lenders provide actual initialized backing for this lifetime.
@inline(__always)
@inlinable
package func withCanvasStagedValues<
    Identity: Equatable & Sendable, Table: CanvasValueTable, Result
>(
    metadata: inout CanvasStagedMetadata,
    entries: inout MutableSpan<CanvasStagedEntry<Identity, Table.CaptureStorage>?>,
    table: borrowing Table, capacity: UInt16, limits: StaticCanvasLimits,
    _ body: (borrowing CanvasStagedValues<Identity, Table>) throws(DrawingError) -> Result
) throws(DrawingError) -> Result {
    guard metadata.count == 0, capacity <= entries.count,
        table.callableCaseCount <= limits.maximumStaticCallableCases
    else { throw .capacityExhausted }
    if table.callableCaseCount > 0 {
        for id in 1 ... table.callableCaseCount {
            guard let bytes = table.captureByteCount(for: id),
                bytes <= limits.maximumStaticCaptureBytes
            else { throw .invariantViolation }
        }
    }
    metadata = CanvasStagedMetadata()
    return try withUnsafeMutablePointer(to: &metadata) { (state) throws(DrawingError) in
        try entries.withUnsafeMutableBufferPointer { (buffer) throws(DrawingError) in
            let values = CanvasStagedValues<Identity, Table>(
                state: state, entries: buffer, capacity: capacity)
            defer { values.discard() }
            return try body(values)
        }
    }
}

@usableFromInline
package struct CanvasStagedValues<Identity: Equatable & Sendable, Table: CanvasValueTable>:
    ~Copyable, ~Escapable
{
    @usableFromInline
    internal let state: UnsafeMutablePointer<CanvasStagedMetadata>
    @usableFromInline
    internal let entries:
        UnsafeMutableBufferPointer<CanvasStagedEntry<Identity, Table.CaptureStorage>?>
    @usableFromInline
    internal let capacity: UInt16

    @_lifetime(borrow state, borrow entries)
    @inlinable
    internal init(
        state: borrowing UnsafeMutablePointer<CanvasStagedMetadata>,
        entries:
            borrowing UnsafeMutableBufferPointer<CanvasStagedEntry<Identity, Table.CaptureStorage>?>,
        capacity: UInt16
    ) {
        self.state = copy state
        self.entries = copy entries
        self.capacity = capacity
    }

    @_lifetime(copy self)
    @inlinable
    package borrowing func borrowedValues() -> CanvasStagedValues<Identity, Table> {
        CanvasStagedValues(borrowing: self)
    }
    @_lifetime(copy other)
    @inlinable
    internal init(borrowing other: borrowing CanvasStagedValues<Identity, Table>) {
        state = other.state
        entries = other.entries
        capacity = other.capacity
    }
    @inlinable
    package var count: UInt16 { state.pointee.count }
    @inlinable
    package var releaseCount: UInt16 { state.pointee.releases }
    @inlinable
    package borrowing func identity(at index: UInt16) -> Identity? {
        guard index < count else { return nil }
        return entries[Int(index)]?.identity
    }
    @inline(__always)
    @inlinable
    package borrowing func stage(
        identity: Identity, value: consuming Table.CaptureStorage,
        table: borrowing Table
    ) throws(DrawingError) {
        guard count < capacity else { throw .capacityExhausted }
        for index in 0 ..< count {
            guard entries[Int(index)]?.identity != identity else { throw .invariantViolation }
        }
        let id = Table.caseID(for: value)
        guard id > 0, id <= table.callableCaseCount, table.captureByteCount(for: id) != nil
        else { throw .invariantViolation }
        entries[Int(count)] = CanvasStagedEntry(
            identity: identity, witness: id, value: consume value)
        state.pointee.count += 1
    }
    @inlinable
    package borrowing func invoke(
        at identity: Identity, table: inout Table, context: inout GraphicsContext, size: Size,
        read: borrowing _GiftUIFrameRead<Table.Domain>
    ) throws(DrawingError) {
        for index in 0 ..< count where entries[Int(index)]?.identity == identity {
            guard let entry = entries[Int(index)], !entry.invoked, let value = entry.value,
                Table.caseID(for: value) == entry.witness
            else { throw .invariantViolation }
            entries[Int(index)]!.invoked = true
            try table.invoke(
                id: entry.witness, captures: value, context: &context, size: size, read: read)
            return
        }
        throw .invariantViolation
    }
    @inlinable
    package borrowing func release(at identity: Identity) {
        for index in 0 ..< count where entries[Int(index)]?.identity == identity {
            guard entries[Int(index)]?.value != nil else { return }
            entries[Int(index)]!.value = nil
            state.pointee.releases += 1
            return
        }
    }
    @inlinable
    package borrowing func discard() {
        for index in 0 ..< count {
            if let identity = entries[Int(index)]?.identity { release(at: identity) }
            entries[Int(index)] = nil
        }
        state.pointee.count = 0
    }
}
