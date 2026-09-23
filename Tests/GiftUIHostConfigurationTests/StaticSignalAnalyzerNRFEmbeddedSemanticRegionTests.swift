import GiftUI
import GiftUILayout
import GiftUIReferenceTextResources
import GiftUISemanticCore
import SignalAnalyzerDomain
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFEmbeddedSemanticRegionPublishesOnlyValidatedRevisions() {
    let capturePointer = UnsafeMutableRawPointer.allocate(
        byteCount: StaticSignalAnalyzerNRFCaptureRegions.requiredByteCount,
        alignment: 8
    )
    defer { capturePointer.deallocate() }
    guard
        let captures = StaticSignalAnalyzerNRFCaptureRegions(
            storage: UnsafeMutableRawBufferPointer(
                start: capturePointer,
                count: StaticSignalAnalyzerNRFCaptureRegions.requiredByteCount
            )
        )
    else {
        Issue.record("The exact capture region must construct")
        return
    }
    var model = StaticSignalAnalyzerNRFModelLocation()
    let generation = model.activate()
    #expect(generation == 0)
    var candidateBytes = [UInt8](repeating: 0, count: 3_024)
    var publishedBytes = [UInt8](repeating: 0, count: 3_024)
    candidateBytes.withUnsafeMutableBytes { candidate in
        publishedBytes.withUnsafeMutableBytes { published in
            let normalText = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.stage(
                variant: .normal, model: model, capture: captures, in: candidate
            )
            #expect(normalText != nil)
            #expect(
                StaticSignalAnalyzerNRFPackedSemanticRecords.utf8TableSummary(
                    in: candidate
                )?.scopeCount == 96
            )
            let overlap = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                revision: 1, candidate: candidate, published: candidate
            )
            #expect(!overlap)
            let first = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                revision: 1, candidate: candidate, published: published
            )
            #expect(first)
            #expect(StaticSignalAnalyzerNRFEmbeddedSemanticRegion.verifyPublished(published))
            let repeated = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                revision: 1, candidate: candidate, published: published
            )
            #expect(!repeated)
            let previous = [UInt8](published)
            candidate[StaticSignalAnalyzerNRFPackedSemanticRecords.scopeOffset + 6 * 24 + 12] = 1
            let corrupt = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                revision: 2, candidate: candidate, published: published
            )
            #expect(!corrupt)
            #expect([UInt8](published) == previous)

            let diagnostic = SignalAnalyzerDiagnostic(
                exactUTF8: [UInt8](repeating: 0x0A, count: 96)
            )!
            let began = model.beginMutation()
            let installed = model.setAcquisitionState(.failed(diagnostic))
            let ended = model.endMutation()
            #expect(began && installed && ended)
            let diagnosticText = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.stage(
                variant: .diagnostic, model: model, capture: captures, in: candidate
            )
            #expect(diagnosticText != nil)
            #expect(
                StaticSignalAnalyzerNRFPackedSemanticRecords.utf8TableSummary(
                    in: candidate
                )?.scopeCount == 98
            )
            let next = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                revision: 2, candidate: candidate, published: published
            )
            #expect(next)
            #expect(StaticSignalAnalyzerNRFEmbeddedSemanticRegion.verifyPublished(published))
            #expect(published[6] == 2)
            #expect(published[7] == 1)
            #expect(published[28] == 2)
            guard
                let view = StaticSignalAnalyzerNRFEmbeddedSemanticView(
                    published: published
                ),
                let layout = StaticSignalAnalyzerNRFUTF8LayoutView(in: published),
                let render = StaticSignalAnalyzerNRFUTF8RenderView(
                    in: published, renderSnapshotVersion: 2
                )
            else {
                Issue.record("The published table must project to both readers")
                return
            }
            #expect(view.rootSemanticIdentity == render.rootIdentity)
            #expect(view.rootPrimitiveIdentity == layout.rootIdentity)
            #expect(view.revision == 2)
            #expect(view.scopeCount == render.semanticScopeCount)
            for ordinal in UInt16(0) ..< view.scopeCount {
                guard let identity = view.semanticIdentity(at: ordinal) else {
                    Issue.record("A generated scope identity was missing")
                    return
                }
                #expect(identity == render.semanticIdentity(at: ordinal))
                #expect(view.childCount(of: identity) == render.childCount(of: identity))
                #expect(
                    (view.layoutPrimitiveKind(of: identity) != nil)
                        == (layout.primitive(at: identity) != nil)
                )
                if let primitive = layout.primitive(at: identity) {
                    let expected: StaticSignalAnalyzerNRFEmbeddedLayoutPrimitive
                    switch primitive {
                    case .proxy: expected = .proxy
                    case .vStack(let alignment, let spacing):
                        expected = .vStack(alignment: alignment.rawValue, spacing: spacing)
                    case .hStack(let alignment, let spacing):
                        expected = .hStack(alignment: alignment.rawValue, spacing: spacing)
                    case .zStack(let alignment):
                        expected = .zStack(
                            horizontal: alignment.horizontal.rawValue,
                            vertical: alignment.vertical.rawValue
                        )
                    case .spacer(let minLength):
                        expected = .spacer(minLength: minLength)
                    case .text: expected = .text
                    case .canvas: expected = .canvas
                    }
                    #expect(
                        view.layoutPrimitive(at: identity) == expected,
                        "semantic identity \(identity)"
                    )
                }
                if let children = view.childCount(of: identity) {
                    for child in UInt16(0) ..< children {
                        #expect(
                            view.child(of: identity, at: child)
                                == render.child(of: identity, at: child)
                        )
                    }
                }
                #expect(view.layoutChildCount(of: identity) == layout.childCount(of: identity))
                if let layoutChildren = layout.childCount(of: identity) {
                    for child in UInt16(0) ..< layoutChildren {
                        #expect(
                            view.layoutChild(of: identity, at: child)
                                == layout.child(of: identity, at: child)
                        )
                    }
                }
                #expect(
                    view.layoutModifierCount(of: identity)
                        == layout.modifierCount(of: identity)
                )
                if let modifiers = layout.modifierCount(of: identity) {
                    for modifier in UInt16(0) ..< modifiers {
                        #expect(
                            view.layoutModifierScope(of: identity, at: modifier)
                                == layout.modifierScope(of: identity, at: modifier)
                        )
                        guard let expected = layout.modifier(of: identity, at: modifier) else {
                            Issue.record("A generated layout modifier was missing")
                            return
                        }
                        let decoded: StaticSignalAnalyzerNRFEmbeddedLayoutModifier
                        switch expected {
                        case .passthrough:
                            decoded = .passthrough
                        case .padding(let edges, let length):
                            decoded = .padding(edges: edges.rawValue, length: length)
                        case .paddingInsets:
                            Issue.record("The nRF preset does not pack padding insets")
                            return
                        case .fixedFrame(let width, let height, let alignment):
                            decoded = .fixedFrame(
                                width: width, height: height,
                                horizontal: alignment.horizontal.rawValue,
                                vertical: alignment.vertical.rawValue
                            )
                        case .flexibleFrame(
                            let minWidth, let maxWidth, let minHeight, let maxHeight,
                            let alignment
                        ):
                            func targetLimit(
                                _ limit: FrameLimit?
                            ) -> StaticSignalAnalyzerNRFEmbeddedLayoutModifier.Limit? {
                                guard let limit else { return nil }
                                switch limit {
                                case .points(let value): return .points(value)
                                case .infinity: return .infinity
                                }
                            }
                            decoded = .flexibleFrame(
                                minWidth: minWidth, maxWidth: targetLimit(maxWidth),
                                minHeight: minHeight, maxHeight: targetLimit(maxHeight),
                                horizontal: alignment.horizontal.rawValue,
                                vertical: alignment.vertical.rawValue
                            )
                        }
                        #expect(view.layoutModifier(of: identity, at: modifier) == decoded)
                    }
                }
                if view.scope(at: identity)?.kind == .text {
                    #expect(
                        view.textScalarCount(of: identity) == layout.textScalarCount(of: identity))
                }
            }
            for ordinal in UInt16(0) ..< view.scopeCount {
                guard let identity = view.semanticIdentity(at: ordinal) else {
                    return
                }
                if view.layoutPrimitive(at: identity) == .text {
                    #expect(staticNRFEmbeddedTextMeasureMatchesHost(view, identity))
                }
            }
        }
    }
    model.retire()
}

private struct StaticNRFOneTextSemantic: SemanticLayoutView {
    let rootIdentity: UInt16
    let source: StaticSignalAnalyzerNRFEmbeddedSemanticView
    let scopeCount: UInt16 = 1

    func primitive(at identity: UInt16) -> SemanticLayoutPrimitive? {
        identity == rootIdentity ? .text : nil
    }

    func childCount(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    func child(of identity: UInt16, at index: UInt16) -> UInt16? { nil }

    func modifierCount(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? { nil }

    func modifier(of identity: UInt16, at index: UInt16) -> SemanticLayoutModifier? {
        nil
    }

    func textScalarCount(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? source.textScalarCount(of: identity) : nil
    }

    func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? {
        identity == rootIdentity ? source.textScalar(of: identity, at: index) : nil
    }
}

private func staticNRFEmbeddedTextMeasureMatchesHost(
    _ source: StaticSignalAnalyzerNRFEmbeddedSemanticView,
    _ identity: UInt16
) -> Bool {
    var targetScopes = [UInt8](repeating: 0, count: 3_136)
    var targetText = [UInt8](repeating: 0, count: 4_704)
    var hostScopes = [UInt8](repeating: 0, count: 3_136)
    var hostText = [UInt8](repeating: 0, count: 4_704)
    return targetScopes.withUnsafeMutableBytes { targetScopeRegion in
        targetText.withUnsafeMutableBytes { targetTextRegion in
            hostScopes.withUnsafeMutableBytes { hostScopeRegion in
                hostText.withUnsafeMutableBytes { hostTextRegion in
                    guard
                        var target = StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace(
                            scopes: targetScopeRegion, text: targetTextRegion
                        ),
                        var host = StaticSignalAnalyzerNRFLayoutWorkspace(
                            scopes: hostScopeRegion, text: hostTextRegion
                        ), target.acquire(), host.acquireLayout()
                    else { return false }
                    let zero = Size(width: 0, height: 0)!
                    guard
                        target.appendScope(
                            identity: identity,
                            idealWidth: 0, idealHeight: 0,
                            width: 0, height: 0
                        ),
                        host.appendScope(
                            identity: identity,
                            measurement: LayoutMeasurement(
                                idealSize: zero, resolvedSize: zero
                            )
                        )
                    else { return false }
                    let limits = LayoutLimits(
                        maximumScopes: 98, maximumDepth: 13,
                        maximumTextScalars: 224, maximumTextLines: 128,
                        maximumPositionedGlyphs: 224
                    )!
                    var engine = LayoutEngine(
                        limits: limits,
                        validatedCounters: LayoutCounters(limits: limits)
                    )
                    let measurement = engine.measure(
                        semantic: StaticNRFOneTextSemantic(
                            rootIdentity: identity, source: source
                        ),
                        metrics: GiftUIReferenceTextMetricsView(),
                        proposal: ProposedSize(width: 480, height: 320)!,
                        workspace: &host
                    )
                    guard measurement != nil,
                        StaticSignalAnalyzerNRFEmbeddedTextMeasure.run(
                            identity: identity, semantic: source,
                            proposalWidth: 480, proposalHeight: 320,
                            workspace: &target
                        )
                    else { return false }
                    return [UInt8](targetScopeRegion) == [UInt8](hostScopeRegion)
                        && [UInt8](targetTextRegion) == [UInt8](hostTextRegion)
                }
            }
        }
    }
}
