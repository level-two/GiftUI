import GiftUISemanticCore

/// Dynamic owns exactly the configured typed extents. Initialization may
/// allocate; activation and growth never exceed those extents.
package final class DynamicSemanticRecordStorage<Payload> {
    private var metadata: InlineArray<2, SemanticRecordBankMetadata> = .init(repeating: .init())
    private var records: [SemanticRuntimeRecord]
    private var paths: [SemanticPathEntry]
    private var payloads: [Payload?]
    private var scalars: [UInt32]
    private let limits: SemanticRecordLimits
    private let owner: SemanticRecordOwnerIdentity
    private var active = false
    package init(limits: SemanticRecordLimits, owner: SemanticRecordOwnerIdentity) {
        self.limits = limits
        self.owner = owner
        records = .init(repeating: .init(), count: Int(limits.records) * 2)
        paths = .init(repeating: .init(), count: Int(limits.paths) * 2)
        payloads = .init(repeating: nil, count: Int(limits.payloads) * 2)
        scalars = .init(repeating: 0, count: Int(limits.textScalars) * 2)
    }
    package func withLifetime<Result>(
        _ body: (borrowing SemanticRecordStore<Payload>) throws(SemanticExpansionError) -> Result
    ) throws(SemanticExpansionError) -> Result {
        guard !active else { throw .reentrancyViolation }
        active = true
        defer { active = false }
        var m = metadata.mutableSpan
        return try records.withUnsafeMutableBufferPointer {
            (records) throws(SemanticExpansionError) in
            try paths.withUnsafeMutableBufferPointer { (paths) throws(SemanticExpansionError) in
                try payloads.withUnsafeMutableBufferPointer {
                    (payloads) throws(SemanticExpansionError) in
                    try scalars.withUnsafeMutableBufferPointer {
                        (scalars) throws(SemanticExpansionError) in
                        var r = MutableSpan(_unsafeElements: records)
                        var p = MutableSpan(_unsafeElements: paths)
                        var v = MutableSpan(_unsafeElements: payloads)
                        var s = MutableSpan(_unsafeElements: scalars)
                        return try withSemanticRecordStore(
                            metadata: &m, records: &r, paths: &p, payloads: &v, scalars: &s,
                            limits: limits, owner: owner, body)
                    }
                }
            }
        }
    }
}
