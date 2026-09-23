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

            let diagnostic = SignalAnalyzerDiagnostic(exactUTF8: [0x45, 0x52, 0x52])!
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
                    #expect(view.layoutPrimitive(at: identity) == expected)
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
                    }
                }
                if view.scope(at: identity)?.kind == .text {
                    #expect(
                        view.textScalarCount(of: identity) == layout.textScalarCount(of: identity))
                }
            }
        }
    }
    model.retire()
}
