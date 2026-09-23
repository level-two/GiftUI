#if GIFTUI_NRF_EMBEDDED
    package struct StaticSignalAnalyzerNRFEmptyCanvasPreflight:
        RenderPreflightExtension
    {
        package typealias Identity = UInt16

        package mutating func visit(
            scope: SemanticRenderScope, identity: UInt16,
            bounds: Rect, clip: Rect
        ) -> RenderExtensionVisitResult {
            .success(RenderExtensionVisit(operationCount: 0))
        }

        package mutating func complete() -> RenderExtensionCompletionResult {
            .success
        }
    }

    package enum StaticSignalAnalyzerNRFEmbeddedRenderPreflight {
        package static func streamCombined(
            semantic: StaticSignalAnalyzerNRFEmbeddedSemanticView,
            layout: StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView,
            textRegion: UnsafeMutableRawBufferPointer,
            drawing: StaticSignalAnalyzerNRFDrawingWorkspace,
            expectedHeader: RenderPlanHeader,
            sink: inout StaticSignalAnalyzerNRFEmbeddedCountingSink
        ) -> RenderProductionResult {
            guard
                let limits = RenderLimits(
                    maximumOperations: 150,
                    maximumPositionedGlyphs: 224,
                    maximumClipDepth: 4
                ),
                let structural = RenderWorkspaceCapacity(
                    maximumSemanticScopes: 98,
                    maximumLayoutScopes: 98,
                    maximumTraversalDepth: 13,
                    maximumTextLines: 128
                ),
                var workspace = StaticSignalAnalyzerNRFRenderWorkspace(
                    region: textRegion, capacity: limits,
                    structuralCapacity: structural
                ),
                let surface = Rect(
                    origin: Point(x: 0, y: 0),
                    size: Size(width: 480, height: 320)!
                )
            else { return .failure(.invariantViolation) }
            return CanvasRenderProducer.produce(
                semantic: StaticSignalAnalyzerNRFEmbeddedRenderSemanticAdapter(
                    source: semantic
                ), layout: layout,
                textMetrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
                drawingPlan: drawing,
                surfaceBounds: surface,
                damageMode: .initializeCompleteSurface,
                rootForeground: .white,
                limits: limits,
                expectedHeader: expectedHeader,
                workspace: &workspace,
                sink: &sink
            )
        }

        package static func runCombined(
            semantic: StaticSignalAnalyzerNRFEmbeddedSemanticView,
            layout: StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView,
            textRegion: UnsafeMutableRawBufferPointer,
            drawing: StaticSignalAnalyzerNRFDrawingWorkspace
        ) -> RenderProductionResult {
            guard
                let limits = RenderLimits(
                    maximumOperations: 150,
                    maximumPositionedGlyphs: 224,
                    maximumClipDepth: 4
                ),
                let structural = RenderWorkspaceCapacity(
                    maximumSemanticScopes: 98,
                    maximumLayoutScopes: 98,
                    maximumTraversalDepth: 13,
                    maximumTextLines: 128
                ),
                var workspace = StaticSignalAnalyzerNRFRenderWorkspace(
                    region: textRegion, capacity: limits,
                    structuralCapacity: structural
                ),
                let surface = Rect(
                    origin: Point(x: 0, y: 0),
                    size: Size(width: 480, height: 320)!
                )
            else { return .failure(.invariantViolation) }
            return CanvasRenderProducer.preflight(
                semantic: StaticSignalAnalyzerNRFEmbeddedRenderSemanticAdapter(
                    source: semantic
                ), layout: layout,
                textMetrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
                drawingPlan: drawing,
                surfaceBounds: surface,
                damageMode: .initializeCompleteSurface,
                rootForeground: .white,
                limits: limits,
                configuredSinkCapacity: RenderSinkCapacity(
                    maximumOperations: 150, maximumPositionedGlyphs: 224
                ), workspace: &workspace
            )
        }

        package static func run(
            semantic: StaticSignalAnalyzerNRFEmbeddedSemanticView,
            layout: StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView,
            textRegion: UnsafeMutableRawBufferPointer
        ) -> RenderProductionResult {
            guard
                let limits = RenderLimits(
                    maximumOperations: 150,
                    maximumPositionedGlyphs: 224,
                    maximumClipDepth: 4
                ),
                let structural = RenderWorkspaceCapacity(
                    maximumSemanticScopes: 98,
                    maximumLayoutScopes: 98,
                    maximumTraversalDepth: 13,
                    maximumTextLines: 128
                ),
                var workspace = StaticSignalAnalyzerNRFRenderWorkspace(
                    region: textRegion, capacity: limits,
                    structuralCapacity: structural
                ),
                let surface = Rect(
                    origin: Point(x: 0, y: 0),
                    size: Size(width: 480, height: 320)!
                )
            else { return .failure(.invariantViolation) }
            var canvas = StaticSignalAnalyzerNRFEmptyCanvasPreflight()
            return RenderProducer.preflight(
                semantic: StaticSignalAnalyzerNRFEmbeddedRenderSemanticAdapter(
                    source: semantic
                ), layout: layout,
                textMetrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
                surfaceBounds: surface,
                damageMode: .initializeCompleteSurface,
                limits: limits,
                configuredSinkCapacity: RenderSinkCapacity(
                    maximumOperations: 150, maximumPositionedGlyphs: 224
                ), workspace: &workspace,
                extensionVisitor: &canvas
            )
        }
    }
#endif
