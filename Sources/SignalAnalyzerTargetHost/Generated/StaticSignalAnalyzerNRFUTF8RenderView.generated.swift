// Read-only render projection over one synchronously borrowed UTF-8 table.

import GiftUISemanticCore

package struct StaticSignalAnalyzerNRFUTF8RenderView: SemanticRenderView {
    package typealias Identity = UInt16

    private let region: UnsafeMutableRawBufferPointer
    package let semanticScopeCount: UInt16
    package let renderSnapshotVersion: UInt32

    package init?(
        in region: UnsafeMutableRawBufferPointer,
        renderSnapshotVersion: UInt32
    ) {
        guard renderSnapshotVersion > 0,
            let summary = StaticSignalAnalyzerNRFPackedSemanticRecords.utf8TableSummary(
                in: region
            )
        else { return nil }
        self.region = region
        semanticScopeCount = summary.scopeCount
        self.renderSnapshotVersion = renderSnapshotVersion
    }

    package var rootIdentity: UInt16 {
        StaticSignalAnalyzerNRFPackedSemanticRecords.scope(at: 0, in: region)!.identity
    }

    package func semanticIdentity(at ordinal: UInt16) -> UInt16? {
        guard ordinal < semanticScopeCount else { return nil }
        return StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
            at: ordinal,
            in: region
        )?.identity
    }

    package func semanticOrdinal(of identity: UInt16) -> UInt16? {
        var ordinal: UInt16 = 0
        while ordinal < semanticScopeCount {
            if semanticIdentity(at: ordinal) == identity { return ordinal }
            ordinal += 1
        }
        return nil
    }

    package func scope(at identity: UInt16) -> SemanticRenderScope? {
        guard let ordinal = semanticOrdinal(of: identity),
            let record = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                at: ordinal,
                in: region
            )
        else { return nil }
        if record.kind == .modifier {
            return StaticSignalAnalyzerNRFModifierPayload(record: record)?.decoded()?.1
        }
        switch record.kind {
        case .text: return .text
        case .canvas: return .canvas
        default: return .structural
        }
    }

    package func layoutIdentity(for identity: UInt16) -> UInt16? {
        semanticOrdinal(of: identity) == nil ? nil : identity
    }

    package func childCount(of identity: UInt16) -> UInt16? {
        guard let ordinal = semanticOrdinal(of: identity),
            let record = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                at: ordinal,
                in: region
            )
        else { return nil }
        var child = record.firstChild
        var count: UInt16 = 0
        while child != StaticSignalAnalyzerNRFPackedSemanticRecords.missingOrdinal {
            guard let next = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                at: child,
                in: region
            ) else { return nil }
            count += 1
            child = next.nextSibling
        }
        return count
    }

    package func child(of identity: UInt16, at index: UInt16) -> UInt16? {
        guard let ordinal = semanticOrdinal(of: identity),
            let record = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                at: ordinal,
                in: region
            )
        else { return nil }
        var child = record.firstChild
        var current: UInt16 = 0
        while child != StaticSignalAnalyzerNRFPackedSemanticRecords.missingOrdinal {
            guard let next = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                at: child,
                in: region
            ) else { return nil }
            if current == index { return next.identity }
            current += 1
            child = next.nextSibling
        }
        return nil
    }
}
