#if GIFTUI_NRF_EMBEDDED
    /// Borrows the six generated action scopes for one resolved frame attempt.
    /// No semantic or layout pointer survives the attempt's workspace reset.
    package struct StaticSignalAnalyzerNRFEmbeddedInteractionOccurrences {
        package struct Occurrence {
            package let identity: UInt16
            package let actionCode: UInt8
            package let bounds: Rect
            package let clip: Rect
            package let isEnabled: Bool
        }

        private let semantic: StaticSignalAnalyzerNRFEmbeddedSemanticView
        private let layout: StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView
        package let count: UInt16 = 6

        package init?(
            semantic: StaticSignalAnalyzerNRFEmbeddedSemanticView,
            layout: StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView
        ) {
            guard layout.isPublished,
                layout.renderSnapshotVersion == semantic.revision,
                layout.scopeCount == semantic.scopeCount
            else { return nil }
            self.semantic = semantic
            self.layout = layout
            var index: UInt16 = 0
            while index < count {
                guard occurrence(at: index) != nil else { return nil }
                index += 1
            }
        }

        package func occurrence(at index: UInt16) -> Occurrence? {
            guard index < count,
                let ordinal = semantic.actionScopeOrdinal(at: index),
                let record = semantic.scope(atOrdinal: ordinal),
                let bounds = layout.bounds(of: record.identity),
                let clip = layout.clip(of: record.identity)
            else { return nil }
            var enabled = true
            var parent = ordinal
            var visits: UInt16 = 0
            while parent != StaticSignalAnalyzerNRFPackedSemanticRecords.missingOrdinal {
                guard visits < semantic.scopeCount,
                    let current = semantic.scope(atOrdinal: parent)
                else { return nil }
                if current.kind == .modifier {
                    guard StaticSignalAnalyzerNRFEmbeddedLayoutModifier(record: current) != nil
                    else { return nil }
                    if current.flags & 0x40 != 0 { enabled = false }
                }
                parent = current.parent
                visits += 1
            }
            return Occurrence(
                identity: record.identity,
                actionCode: UInt8(index),
                bounds: bounds, clip: clip,
                isEnabled: enabled
            )
        }
    }
#endif
