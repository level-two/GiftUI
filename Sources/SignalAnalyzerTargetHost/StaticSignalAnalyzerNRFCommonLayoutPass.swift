#if GIFTUI_NRF_EMBEDDED
    /// Runs the exact shared Layout validator, measure pass, and placer over
    /// the audited nRF regions, then publishes those records in place.
    package enum StaticSignalAnalyzerNRFCommonLayoutPass {
        package static func run(
            semantic: StaticSignalAnalyzerNRFEmbeddedSemanticView,
            workspace: inout StaticSignalAnalyzerNRFCommonLayoutWorkspace
        ) -> StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView? {
            guard workspace.acquireLayout(),
                let limits = LayoutLimits(
                    maximumScopes: 98,
                    maximumDepth: 13,
                    maximumTextScalars: 224,
                    maximumTextLines: 128,
                    maximumPositionedGlyphs: 224
                ), let proposal = ProposedSize(width: 480, height: 320)
            else { return nil }
            let layoutSemantic = StaticSignalAnalyzerNRFEmbeddedLayoutSemanticAdapter(
                source: semantic
            )
            let metrics = StaticSignalAnalyzerNRFEmbeddedFontMetrics()
            var validation = LayoutSemanticValidation(limits: limits)
            guard
                validation.validate(
                    semantic: layoutSemantic,
                    metrics: metrics,
                    workspace: &workspace
                ) == nil
            else {
                workspace.resetLayout()
                return nil
            }
            var engine = LayoutEngine(
                limits: limits,
                validatedCounters: validation.countersSnapshot
            )
            guard
                let measurement = engine.measure(
                    semantic: layoutSemantic,
                    metrics: metrics,
                    proposal: proposal,
                    workspace: &workspace
                ),
                let rootBounds = Rect(
                    origin: Point(x: 0, y: 0), size: measurement.resolvedSize
                ),
                engine.place(
                    semantic: layoutSemantic,
                    metrics: metrics,
                    rootBounds: rootBounds,
                    workspace: &workspace
                ),
                workspace.packed.reserveTextScalars(
                    engine.finalCounters.textScalarCount
                ),
                let result = workspace.packed.publish(
                    rootIdentity: layoutSemantic.rootIdentity,
                    expectedScopeCount: semantic.scopeCount
                )
            else {
                workspace.resetLayout()
                return nil
            }
            return result
        }
    }
#endif
