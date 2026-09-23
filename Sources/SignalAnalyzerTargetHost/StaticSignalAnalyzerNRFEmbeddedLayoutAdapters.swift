#if GIFTUI_NRF_EMBEDDED
    package struct StaticSignalAnalyzerNRFEmbeddedLayoutSemanticAdapter:
        SemanticLayoutView
    {
        package typealias Identity = UInt16
        package let source: StaticSignalAnalyzerNRFEmbeddedSemanticView
        package var scopeCount: UInt16 { source.scopeCount }

        package var rootIdentity: UInt16 { source.rootPrimitiveIdentity! }

        package func primitive(at identity: UInt16) -> SemanticLayoutPrimitive? {
            guard let primitive = source.layoutPrimitive(at: identity) else { return nil }
            switch primitive {
            case .proxy: return .proxy
            case .vStack(let rawAlignment, let spacing):
                guard let alignment = HorizontalAlignment(rawValue: rawAlignment) else {
                    return nil
                }
                return .vStack(alignment: alignment, spacing: spacing)
            case .hStack(let rawAlignment, let spacing):
                guard let alignment = VerticalAlignment(rawValue: rawAlignment) else {
                    return nil
                }
                return .hStack(alignment: alignment, spacing: spacing)
            case .zStack(let rawHorizontal, let rawVertical):
                guard let horizontal = HorizontalAlignment(rawValue: rawHorizontal),
                    let vertical = VerticalAlignment(rawValue: rawVertical)
                else { return nil }
                return .zStack(
                    alignment: Alignment(
                        horizontal: horizontal, vertical: vertical
                    ))
            case .spacer(let length): return .spacer(minLength: length)
            case .text: return .text
            case .canvas: return .canvas
            }
        }

        package func childCount(of identity: UInt16) -> UInt16? {
            source.layoutChildCount(of: identity)
        }

        package func child(of identity: UInt16, at index: UInt16) -> UInt16? {
            source.layoutChild(of: identity, at: index)
        }

        package func modifierCount(of identity: UInt16) -> UInt16? {
            source.layoutModifierCount(of: identity)
        }

        package func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? {
            source.layoutModifierScope(of: identity, at: index)
        }

        package func modifier(
            of identity: UInt16, at index: UInt16
        ) -> SemanticLayoutModifier? {
            guard let modifier = source.layoutModifier(of: identity, at: index) else {
                return nil
            }
            func alignment(_ horizontal: UInt8, _ vertical: UInt8) -> Alignment? {
                guard let horizontal = HorizontalAlignment(rawValue: horizontal),
                    let vertical = VerticalAlignment(rawValue: vertical)
                else { return nil }
                return Alignment(horizontal: horizontal, vertical: vertical)
            }
            func limit(
                _ value: StaticSignalAnalyzerNRFEmbeddedLayoutModifier.Limit?
            ) -> FrameLimit? {
                guard let value else { return nil }
                switch value {
                case .points(let count): return .points(count)
                case .infinity: return .infinity
                }
            }
            switch modifier {
            case .passthrough: return .passthrough
            case .padding(let edges, let length):
                return .padding(edges: EdgeSet(rawValue: edges), length: length)
            case .fixedFrame(let width, let height, let horizontal, let vertical):
                guard let alignment = alignment(horizontal, vertical) else { return nil }
                return .fixedFrame(width: width, height: height, alignment: alignment)
            case .flexibleFrame(
                let minWidth, let maxWidth, let minHeight, let maxHeight,
                let horizontal, let vertical
            ):
                guard let alignment = alignment(horizontal, vertical) else { return nil }
                return .flexibleFrame(
                    minWidth: minWidth, maxWidth: limit(maxWidth),
                    minHeight: minHeight, maxHeight: limit(maxHeight),
                    alignment: alignment
                )
            }
        }

        package func textScalarCount(of identity: UInt16) -> UInt16? {
            source.textScalarCount(of: identity)
        }

        package func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? {
            source.textScalar(of: identity, at: index)
        }
    }

    package struct StaticSignalAnalyzerNRFEmbeddedFontMetrics:
        CanonicalTextMetricsView
    {
        package let descriptor = TextResourceDescriptor(instanceCount: 1)

        package func instance(at index: UInt16) -> FontInstanceDescriptor? {
            guard index == 0 else { return nil }
            return FontInstanceDescriptor(
                id: FontInstanceID(rawValue: 0),
                lineMetrics: FontLineMetrics(
                    ascent: GeometryScalar(StaticSignalAnalyzerNRFReferenceMetrics.ascent),
                    descent: GeometryScalar(StaticSignalAnalyzerNRFReferenceMetrics.descent),
                    lineGap: GeometryScalar(StaticSignalAnalyzerNRFReferenceMetrics.lineGap)
                ),
                replacementGlyph: GlyphID(
                    rawValue: StaticSignalAnalyzerNRFReferenceMetrics.replacementGlyph
                )
            )
        }

        package func mapScalar(
            _ scalar: UInt32, in instance: FontInstanceID
        ) -> GlyphMapping? {
            guard instance.rawValue == 0 else { return nil }
            if let glyph = StaticSignalAnalyzerNRFReferenceMetrics.glyph(for: scalar) {
                return .exact(GlyphID(rawValue: glyph))
            }
            return .replacement(
                GlyphID(
                    rawValue: StaticSignalAnalyzerNRFReferenceMetrics.replacementGlyph
                ))
        }

        package func metrics(
            for glyph: GlyphID, in instance: FontInstanceID
        ) -> GlyphMetrics? {
            guard instance.rawValue == 0,
                let metric = StaticSignalAnalyzerNRFReferenceMetrics.metric(
                    for: glyph.rawValue
                ),
                let inkSize = Size(
                    width: GeometryScalar(metric.width),
                    height: GeometryScalar(metric.height)
                )
            else { return nil }
            return GlyphMetrics(
                advanceX: GeometryScalar(metric.advanceX),
                offsetX: GeometryScalar(metric.offsetX),
                offsetY: GeometryScalar(metric.offsetY),
                inkSize: inkSize
            )
        }
    }
#endif
