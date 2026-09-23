#if GIFTUI_NRF_EMBEDDED
    /// Render projection of the same validated packed semantic publication.
    package struct StaticSignalAnalyzerNRFEmbeddedRenderSemanticAdapter:
        SemanticRenderView
    {
        package typealias Identity = UInt16
        package let source: StaticSignalAnalyzerNRFEmbeddedSemanticView

        package var rootIdentity: UInt16 { source.rootSemanticIdentity }
        package var semanticScopeCount: UInt16 { source.scopeCount }
        package var renderSnapshotVersion: UInt32 { source.revision }

        package func semanticIdentity(at ordinal: UInt16) -> UInt16? {
            source.semanticIdentity(at: ordinal)
        }

        package func semanticOrdinal(of identity: UInt16) -> UInt16? {
            var ordinal: UInt16 = 0
            while ordinal < source.scopeCount {
                if source.semanticIdentity(at: ordinal) == identity { return ordinal }
                ordinal += 1
            }
            return nil
        }

        package func scope(at identity: UInt16) -> SemanticRenderScope? {
            guard let record = source.scope(at: identity) else { return nil }
            if record.kind == .modifier {
                switch (record.flags >> 3) & 7 {
                case 0: return .structural
                case 1: return .clipBoundary
                case 2: return .foregroundStyle(color(record.payload0))
                case 3: return .background(color(record.payload0))
                default: return nil
                }
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
            source.childCount(of: identity)
        }

        package func child(of identity: UInt16, at index: UInt16) -> UInt16? {
            source.child(of: identity, at: index)
        }

        private func color(_ packed: UInt32) -> Color {
            Color(
                red: UInt8(truncatingIfNeeded: packed),
                green: UInt8(truncatingIfNeeded: packed >> 8),
                blue: UInt8(truncatingIfNeeded: packed >> 16)
            )
        }
    }
#endif
