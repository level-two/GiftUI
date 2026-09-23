import GiftUIDrawing
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUILayout
import GiftUIRenderCore
import GiftUIRenderLowering

package enum StaticSignalAnalyzerNRFPreparationFailure: Equatable, Sendable {
    case invalidRegions
    case layout(LayoutError)
    case drawing(DrawingProductionError)
    case render(RenderProductionError)
    case invalidInteractionOccurrences
}

package enum StaticSignalAnalyzerNRFPreparationResult<Value> {
    case ready(Value)
    case failure(StaticSignalAnalyzerNRFPreparationFailure)
}

/// Lends a complete preflighted candidate only within the profile's five
/// attempt-local region lifetimes. The callback must not retain any view.
package enum StaticSignalAnalyzerNRFPresentationPreparation {
    package static func withPreparedCandidate<Result>(
        inputs: inout StaticSignalAnalyzerNRFGeneratedPresentationInputs,
        profile: inout StaticSignalAnalyzerNRFProductionProfileBinding,
        cycle: RunCycleID,
        semanticRevision: SemanticRevision,
        renderSnapshotVersion: UInt32,
        _ body: (
            StaticSignalAnalyzerNRFUTF8RenderView,
            StaticSignalAnalyzerNRFResolvedLayoutView,
            StaticSignalAnalyzerNRFDrawingWorkspace,
            StaticSignalAnalyzerNRFInteractionOccurrences,
            RenderPlanHeader,
            inout StaticSignalAnalyzerNRFRenderWorkspace
        ) -> Result
    ) -> StaticSignalAnalyzerNRFPreparationResult<Result> {
        let prepared = profile.withPresentationRegions {
            semanticRegion, layoutRegion, renderRegion, pathRegion, planRegion
                -> StaticSignalAnalyzerNRFPreparationResult<Result> in
            guard
                let semantic = StaticSignalAnalyzerNRFUTF8LayoutView(
                    in: semanticRegion
                ),
                var layoutWorkspace = StaticSignalAnalyzerNRFLayoutWorkspace(
                    scopes: layoutRegion, text: renderRegion
                ),
                var layoutSink = StaticSignalAnalyzerNRFResolvedLayoutStorage(
                    scopes: layoutRegion, text: renderRegion
                )
            else { return .failure(.invalidRegions) }

            switch StaticSignalAnalyzerNRFLayoutPass.run(
                semantic: semantic,
                workspace: &layoutWorkspace,
                sink: &layoutSink
            ) {
            case .success:
                break
            case .failure(let error):
                return .failure(.layout(error))
            }

            guard
                var source = StaticSignalAnalyzerNRFCanvasInvocationSource(
                    semanticRegion: semanticRegion, inputs: inputs
                ),
                var drawing = StaticSignalAnalyzerNRFDrawingWorkspace(
                    pathRegion: pathRegion,
                    planRegion: planRegion,
                    capacity: GeneratedSignalAnalyzerPresets.nrf52840Static()
                        .runtimeLimits.drawing
                )
            else { return .failure(.invalidRegions) }
            switch StaticSignalAnalyzerNRFCanvasPass.derive(
                source: &source,
                layout: layoutSink.renderView,
                cycle: cycle,
                semanticRevision: semanticRevision,
                workspace: &drawing
            ) {
            case .success:
                break
            case .failure(let error):
                return .failure(.drawing(error))
            }

            guard
                let render = StaticSignalAnalyzerNRFUTF8RenderView(
                    in: semanticRegion,
                    renderSnapshotVersion: renderSnapshotVersion
                ),
                var preflightWorkspace = StaticSignalAnalyzerNRFRenderWorkspace(
                    region: renderRegion,
                    capacity: GeneratedSignalAnalyzerPresets.nrf52840Static()
                        .runtimeLimits.render,
                    structuralCapacity: GeneratedSignalAnalyzerPresets.nrf52840Static()
                        .runtimeLimits.renderWorkspace
                )
            else { return .failure(.invalidRegions) }
            let header: RenderPlanHeader
            switch StaticSignalAnalyzerNRFRenderOffer.preflight(
                semantic: render,
                layout: layoutSink.renderView,
                drawingPlan: drawing,
                workspace: &preflightWorkspace
            ) {
            case .success(let value):
                header = value
            case .failure(let error):
                return .failure(.render(error))
            }

            guard
                let occurrences = StaticSignalAnalyzerNRFInteractionOccurrences(
                    semanticRegion: semanticRegion,
                    layout: layoutSink.renderView
                )
            else { return .failure(.invalidInteractionOccurrences) }
            guard
                var renderWorkspace = StaticSignalAnalyzerNRFRenderWorkspace(
                    region: renderRegion,
                    capacity: GeneratedSignalAnalyzerPresets.nrf52840Static()
                        .runtimeLimits.render,
                    structuralCapacity: GeneratedSignalAnalyzerPresets.nrf52840Static()
                        .runtimeLimits.renderWorkspace
                )
            else { return .failure(.invalidRegions) }
            return .ready(
                body(
                    render,
                    layoutSink.renderView,
                    drawing,
                    occurrences,
                    header,
                    &renderWorkspace
                )
            )
        }
        return prepared ?? .failure(.invalidRegions)
    }
}
