import GiftUI
import GiftUISemanticCore

package func forward(
    metadata: inout MutableSpan<SemanticRecordBankMetadata>,
    records: inout MutableSpan<SemanticRuntimeRecord>,
    paths: inout MutableSpan<SemanticPathEntry>,
    payloads: inout MutableSpan<UInt32?>,
    scalars: inout MutableSpan<UInt32>,
    limits: SemanticRecordLimits,
    owner: SemanticRecordOwnerIdentity
) throws(SemanticExpansionError) -> UInt32 {
    return try withSemanticRecordStore(
        metadata: &metadata, records: &records, paths: &paths,
        payloads: &payloads, scalars: &scalars, limits: limits, owner: owner
    ) { store in
        let borrowed = store.borrowedStore()
        _ = try borrowed.withCandidateView { _ in UInt32(0) }
        return UInt32(borrowed.limits.records)
    }
}
