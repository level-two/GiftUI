import GiftUIInteraction
import GiftUIRuntimeCore

/// Reads six generated action occurrences directly from the scoped semantic
/// candidate and its resolved layout. No candidate record is retained here.
package struct StaticSignalAnalyzerNRFInteractionOccurrences:
    RuntimeInteractionOccurrenceView
{
    package typealias Identity = UInt32

    private let semanticRegion: UnsafeMutableRawBufferPointer
    private let layout: StaticSignalAnalyzerNRFResolvedLayoutView
    package let interactionOccurrenceCount: UInt16 = 6

    package init?(
        semanticRegion: UnsafeMutableRawBufferPointer,
        layout: StaticSignalAnalyzerNRFResolvedLayoutView
    ) {
        guard
            StaticSignalAnalyzerNRFPackedSemanticRecords.utf8TableSummary(
                in: semanticRegion
            ) != nil,
            StaticSignalAnalyzerNRFPackedSemanticRecords.hasDistinctUTF8ActionScopes(
                in: semanticRegion
            )
        else { return nil }
        self.semanticRegion = semanticRegion
        self.layout = layout
        var index: UInt16 = 0
        while index < interactionOccurrenceCount {
            guard interactionOccurrence(at: index) != nil else { return nil }
            index += 1
        }
    }

    package borrowing func interactionOccurrence(
        at index: UInt16
    ) -> RuntimeInteractionOccurrence<UInt32>? {
        guard index < interactionOccurrenceCount,
            let ordinal = StaticSignalAnalyzerNRFPackedSemanticRecords.actionScope(
                at: index, in: semanticRegion
            ),
            let record = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                at: ordinal, in: semanticRegion
            ),
            let bounds = layout.bounds(of: record.identity),
            let clip = layout.clip(of: record.identity),
            let enabled = isEnabled(at: ordinal)
        else { return nil }
        return RuntimeInteractionOccurrence(
            identity: UInt32(record.identity),
            isEnabled: enabled,
            bounds: bounds,
            clip: clip,
            paintOrder: index,
            action: BoundedApplicationAction(code: index)
        )
    }

    private func isEnabled(at ordinal: UInt16) -> Bool? {
        var current = ordinal
        while current != StaticSignalAnalyzerNRFPackedSemanticRecords.missingOrdinal {
            guard
                let record = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                    at: current, in: semanticRegion
                )
            else { return nil }
            if record.kind == .modifier {
                guard let modifier = StaticSignalAnalyzerNRFModifierPayload(record: record),
                    let decoded = modifier.decoded()
                else { return nil }
                if decoded.2 { return false }
            }
            current = record.parent
        }
        return true
    }
}
