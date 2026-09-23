import GiftUIDrawing
import GiftUIExecution
import GiftUIHostConfiguration

/// Derives the five generated Canvas occurrences into the fixed Drawing plan
/// while the semantic, path, and plan regions share one active attempt.
package enum StaticSignalAnalyzerNRFCanvasPass {
    package static func derive(
        source: inout StaticSignalAnalyzerNRFCanvasInvocationSource,
        layout: borrowing StaticSignalAnalyzerNRFResolvedLayoutView,
        cycle: RunCycleID,
        semanticRevision: SemanticRevision,
        workspace: inout StaticSignalAnalyzerNRFDrawingWorkspace
    ) -> DrawingPlanResult {
        let limits = GeneratedSignalAnalyzerPresets.nrf52840Static().runtimeLimits.drawing
        guard workspace.limits == limits else {
            return .failure(.capacityExhausted)
        }
        let result = CanvasPlanProducer.derive(
            source: &source,
            layout: layout,
            executionContext: ExecutionContext(
                cycle: cycle,
                semanticRevision: semanticRevision,
                candidateFrame: nil,
                phase: .deriving
            ),
            limits: limits,
            workspace: &workspace
        )
        if case .success = result, !source.allReleased {
            workspace.discard()
            return .failure(.invariantViolation)
        }
        return result
    }
}
