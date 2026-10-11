import GiftUISemanticCore

/// Static assembly supplies initialized typed backing before entering this
/// lifetime. No array, allocation, generated topology or byte rebinding occurs.
package struct StaticSemanticRecordStorage: ~Copyable {
    private var metadata: InlineArray<2, SemanticRecordBankMetadata> = .init(repeating: .init())
    private let limits: SemanticRecordLimits
    private let owner: SemanticRecordOwnerIdentity
    package init(limits: SemanticRecordLimits, owner: SemanticRecordOwnerIdentity) {
        self.limits = limits
        self.owner = owner
    }
    package var storageLimits: SemanticRecordLimits { limits }
    package var storageOwner: SemanticRecordOwnerIdentity { owner }

    package mutating func withLifetime<Payload, Result>(
        records: inout MutableSpan<SemanticRuntimeRecord>,
        paths: inout MutableSpan<SemanticPathEntry>,
        payloads: inout MutableSpan<Payload?>, scalars: inout MutableSpan<UInt32>,
        _ body: (borrowing SemanticRecordStore<Payload>) throws(SemanticExpansionError) -> Result
    ) throws(SemanticExpansionError) -> Result {
        var metadata = metadata.mutableSpan
        return try withSemanticRecordStore(
            metadata: &metadata, records: &records, paths: &paths,
            payloads: &payloads, scalars: &scalars, limits: limits, owner: owner, body)
    }
}
