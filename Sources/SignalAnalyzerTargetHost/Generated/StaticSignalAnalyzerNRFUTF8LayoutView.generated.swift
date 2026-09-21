// Layout projection over one synchronously borrowed generated UTF-8 table.

import GiftUISemanticCore

package struct StaticSignalAnalyzerNRFUTF8LayoutView: SemanticLayoutView {
    package typealias Identity = UInt16

    private let region: UnsafeMutableRawBufferPointer
    package let scopeCount: UInt16

    package init?(in region: UnsafeMutableRawBufferPointer) {
        guard let summary = StaticSignalAnalyzerNRFPackedSemanticRecords.utf8TableSummary(
            in: region
        ) else { return nil }
        self.region = region
        scopeCount = summary.scopeCount
        guard primitiveIdentity(beneath: 0) != nil else { return nil }
    }

    package var rootIdentity: UInt16 {
        primitiveIdentity(beneath: 0)!
    }

    package func primitive(at identity: UInt16) -> SemanticLayoutPrimitive? {
        guard let record = record(for: identity), record.kind != .modifier else {
            return nil
        }
        if record.kind == .text { return .text }
        return StaticSignalAnalyzerNRFPrimitivePayload(record: record)?.decoded()?.primitive
    }

    package func childCount(of identity: UInt16) -> UInt16? {
        guard let record = record(for: identity), record.kind != .modifier else {
            return nil
        }
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
        guard let record = record(for: identity), record.kind != .modifier else {
            return nil
        }
        var child = record.firstChild
        var current: UInt16 = 0
        while child != StaticSignalAnalyzerNRFPackedSemanticRecords.missingOrdinal {
            guard let next = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                at: child,
                in: region
            ) else { return nil }
            if current == index { return primitiveIdentity(beneath: child) }
            current += 1
            child = next.nextSibling
        }
        return nil
    }

    package func modifierCount(of identity: UInt16) -> UInt16? {
        guard let ordinal = ordinal(of: identity),
            let record = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                at: ordinal,
                in: region
            ), record.kind != .modifier
        else { return nil }
        var parent = record.parent
        var count: UInt16 = 0
        while parent != StaticSignalAnalyzerNRFPackedSemanticRecords.missingOrdinal {
            guard let next = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                at: parent,
                in: region
            ) else { return nil }
            if next.kind != .modifier { break }
            count += 1
            parent = next.parent
        }
        return count
    }

    package func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? {
        guard let ordinal = ordinal(of: identity),
            let record = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                at: ordinal,
                in: region
            ), record.kind != .modifier
        else { return nil }
        var parent = record.parent
        var current: UInt16 = 0
        while parent != StaticSignalAnalyzerNRFPackedSemanticRecords.missingOrdinal {
            guard let next = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                at: parent,
                in: region
            ), next.kind == .modifier
            else { return nil }
            if current == index { return next.identity }
            current += 1
            parent = next.parent
        }
        return nil
    }

    package func modifier(of identity: UInt16, at index: UInt16) -> SemanticLayoutModifier? {
        guard let modifierID = modifierScope(of: identity, at: index),
            let record = record(for: modifierID)
        else { return nil }
        return StaticSignalAnalyzerNRFModifierPayload(record: record)?.decoded()?.0
    }

    package func textScalarCount(of identity: UInt16) -> UInt16? {
        guard let record = record(for: identity), record.kind == .text else {
            return nil
        }
        return StaticSignalAnalyzerNRFUTF8TextPool.scalarCount(
            from: UInt16(record.payload0),
            byteCount: UInt16(record.payload1),
            in: region
        )
    }

    package func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? {
        guard let record = record(for: identity), record.kind == .text else {
            return nil
        }
        return StaticSignalAnalyzerNRFUTF8TextPool.scalar(
            at: index,
            from: UInt16(record.payload0),
            byteCount: UInt16(record.payload1),
            in: region
        )
    }

    private func ordinal(of identity: UInt16) -> UInt16? {
        var ordinal: UInt16 = 0
        while ordinal < scopeCount {
            if StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                at: ordinal,
                in: region
            )?.identity == identity { return ordinal }
            ordinal += 1
        }
        return nil
    }

    private func record(for identity: UInt16) -> StaticSignalAnalyzerNRFScopeRecord? {
        guard let ordinal = ordinal(of: identity) else { return nil }
        return StaticSignalAnalyzerNRFPackedSemanticRecords.scope(at: ordinal, in: region)
    }

    private func primitiveIdentity(beneath ordinal: UInt16) -> UInt16? {
        var current = ordinal
        while let record = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
            at: current,
            in: region
        ) {
            if record.kind != .modifier { return record.identity }
            guard record.firstChild != StaticSignalAnalyzerNRFPackedSemanticRecords.missingOrdinal,
                StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                    at: record.firstChild,
                    in: region
                )?.nextSibling == StaticSignalAnalyzerNRFPackedSemanticRecords.missingOrdinal
            else { return nil }
            current = record.firstChild
        }
        return nil
    }
}
