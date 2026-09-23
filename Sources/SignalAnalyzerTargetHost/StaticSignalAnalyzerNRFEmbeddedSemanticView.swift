/// A synchronous read-only projection over one validated published region.
/// The caller keeps the region alive and unchanged for the entire borrow.
package struct StaticSignalAnalyzerNRFEmbeddedSemanticView {
    private let region: UnsafeMutableRawBufferPointer
    package let scopeCount: UInt16
    package let revision: UInt32

    package init?(published: UnsafeMutableRawBufferPointer) {
        guard StaticSignalAnalyzerNRFEmbeddedSemanticRegion.verifyPublished(published)
        else { return nil }
        region = published
        scopeCount = published[7] == 0 ? 96 : 98
        revision =
            UInt32(published[28]) | UInt32(published[29]) << 8
            | UInt32(published[30]) << 16 | UInt32(published[31]) << 24
    }

    package var rootSemanticIdentity: UInt16 {
        StaticSignalAnalyzerNRFPackedSemanticRecords.scope(at: 0, in: region)!.identity
    }

    package var rootPrimitiveIdentity: UInt16? {
        primitiveIdentity(beneath: 0)
    }

    package func semanticIdentity(at ordinal: UInt16) -> UInt16? {
        guard ordinal < scopeCount else { return nil }
        return StaticSignalAnalyzerNRFPackedSemanticRecords.scope(at: ordinal, in: region)?
            .identity
    }

    package func scope(at identity: UInt16) -> StaticSignalAnalyzerNRFScopeRecord? {
        guard let ordinal = ordinal(of: identity) else { return nil }
        return StaticSignalAnalyzerNRFPackedSemanticRecords.scope(at: ordinal, in: region)
    }

    package func childCount(of identity: UInt16) -> UInt16? {
        guard let record = scope(at: identity) else { return nil }
        var child = record.firstChild
        var count: UInt16 = 0
        while child != StaticSignalAnalyzerNRFPackedSemanticRecords.missingOrdinal {
            guard
                let next = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                    at: child, in: region
                )
            else { return nil }
            count += 1
            child = next.nextSibling
        }
        return count
    }

    package func child(of identity: UInt16, at index: UInt16) -> UInt16? {
        guard let record = scope(at: identity) else { return nil }
        var child = record.firstChild
        var current: UInt16 = 0
        while child != StaticSignalAnalyzerNRFPackedSemanticRecords.missingOrdinal {
            guard
                let next = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                    at: child, in: region
                )
            else { return nil }
            if current == index { return next.identity }
            current += 1
            child = next.nextSibling
        }
        return nil
    }

    package func textScalarCount(of identity: UInt16) -> UInt16? {
        guard let record = scope(at: identity), record.kind == .text else { return nil }
        return StaticSignalAnalyzerNRFUTF8TextPool.scalarCount(
            from: UInt16(record.payload0),
            byteCount: UInt16(record.payload1),
            in: region
        )
    }

    package func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? {
        guard let record = scope(at: identity), record.kind == .text else { return nil }
        return StaticSignalAnalyzerNRFUTF8TextPool.scalar(
            at: index, from: UInt16(record.payload0),
            byteCount: UInt16(record.payload1), in: region
        )
    }

    private func ordinal(of identity: UInt16) -> UInt16? {
        var ordinal: UInt16 = 0
        while ordinal < scopeCount {
            if semanticIdentity(at: ordinal) == identity { return ordinal }
            ordinal += 1
        }
        return nil
    }

    private func primitiveIdentity(beneath ordinal: UInt16) -> UInt16? {
        var current = ordinal
        while let record = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
            at: current, in: region
        ) {
            if record.kind != .modifier { return record.identity }
            guard record.firstChild != StaticSignalAnalyzerNRFPackedSemanticRecords.missingOrdinal,
                StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                    at: record.firstChild, in: region
                )?.nextSibling == StaticSignalAnalyzerNRFPackedSemanticRecords.missingOrdinal
            else { return nil }
            current = record.firstChild
        }
        return nil
    }
}
