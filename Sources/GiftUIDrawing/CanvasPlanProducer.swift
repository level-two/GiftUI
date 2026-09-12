import GiftUI
import GiftUIExecution
import GiftUILayout

package enum CanvasPlanProducer {
    package static func derive<Source, Layout, Workspace>(
        source: inout Source,
        layout: borrowing Layout,
        executionContext: ExecutionContext,
        limits: DrawingLimits,
        workspace: inout Workspace
    ) -> DrawingPlanResult
    where
        Source: CanvasInvocationSource,
        Layout: ResolvedRenderLayoutView,
        Workspace: DrawingPlanConstructionWorkspace,
        Source.Identity == Layout.Identity,
        Source.Identity == Workspace.Identity
    {
        guard !workspace.isActive else {
            return .failure(.reentrancyViolation)
        }
        guard executionContext.phase == .deriving else {
            return .failure(.invalidPhase)
        }
        guard executionContext.cycle != nil,
            executionContext.candidateFrame == nil
        else { return .failure(.invalidPhase) }
        guard workspace.acquire() else {
            return .failure(.reentrancyViolation)
        }

        let occurrenceCount = source.canvasOccurrenceCount
        guard occurrenceCount <= limits.maximumCanvasOccurrences else {
            return fail(
                .capacityExhausted,
                source: &source,
                releasingFrom: 0,
                workspace: &workspace
            )
        }
        guard
            validateOccurrences(
                source: source,
                layout: layout,
                occurrenceCount: occurrenceCount
            )
        else {
            return fail(
                .invariantViolation,
                source: &source,
                releasingFrom: 0,
                workspace: &workspace
            )
        }

        var index: UInt16 = 0
        while index < occurrenceCount {
            guard let identity = source.canvasIdentity(at: index),
                let bounds = layout.bounds(of: identity),
                let clip = layout.clip(of: identity)
            else {
                return fail(
                    .invariantViolation,
                    source: &source,
                    releasingFrom: index,
                    workspace: &workspace
                )
            }

            do {
                try workspace.withCanvasContext(
                    identity: identity,
                    surfaceOrigin: bounds.origin,
                    inheritedClip: clip
                ) { (context) throws(DrawingError) in
                    try source.invokeCanvas(
                        at: identity,
                        context: &context,
                        size: bounds.size
                    )
                }
            } catch let error as DrawingError {
                return fail(
                    productionError(for: error),
                    source: &source,
                    releasingFrom: index,
                    workspace: &workspace
                )
            } catch {
                return fail(
                    .invariantViolation,
                    source: &source,
                    releasingFrom: index,
                    workspace: &workspace
                )
            }

            source.releaseCanvas(at: identity)
            index += 1
        }

        let result = workspace.seal(canvasOccurrenceCount: occurrenceCount)
        guard case .success = result else {
            workspace.discard()
            workspace.reset()
            return result
        }
        return result
    }

    private static func validateOccurrences<Source, Layout>(
        source: borrowing Source,
        layout: borrowing Layout,
        occurrenceCount: UInt16
    ) -> Bool
    where
        Source: CanvasInvocationSource,
        Layout: ResolvedRenderLayoutView,
        Source.Identity == Layout.Identity
    {
        var previousOrdinal: UInt16?
        var index: UInt16 = 0
        while index < occurrenceCount {
            guard let identity = source.canvasIdentity(at: index),
                let ordinal = layout.layoutOrdinal(of: identity),
                ordinal < layout.layoutScopeCount,
                layout.layoutIdentity(at: ordinal) == identity,
                layout.bounds(of: identity) != nil,
                layout.clip(of: identity) != nil
            else { return false }
            if let previousOrdinal, ordinal <= previousOrdinal {
                return false
            }

            var earlierIndex: UInt16 = 0
            while earlierIndex < index {
                guard source.canvasIdentity(at: earlierIndex) != identity else {
                    return false
                }
                earlierIndex += 1
            }
            previousOrdinal = ordinal
            index += 1
        }
        return source.canvasIdentity(at: occurrenceCount) == nil
    }

    private static func fail<Source, Workspace>(
        _ error: DrawingProductionError,
        source: inout Source,
        releasingFrom firstIndex: UInt16,
        workspace: inout Workspace
    ) -> DrawingPlanResult
    where
        Source: CanvasInvocationSource,
        Workspace: DrawingPlanWorkspace,
        Source.Identity == Workspace.Identity
    {
        var index = firstIndex
        while index < source.canvasOccurrenceCount {
            if let identity = source.canvasIdentity(at: index) {
                var alreadyReleased = false
                var earlierIndex = firstIndex
                while earlierIndex < index {
                    if source.canvasIdentity(at: earlierIndex) == identity {
                        alreadyReleased = true
                        break
                    }
                    earlierIndex += 1
                }
                if !alreadyReleased {
                    source.releaseCanvas(at: identity)
                }
            }
            index += 1
        }
        workspace.discard()
        workspace.reset()
        return .failure(error)
    }

    private static func productionError(
        for error: DrawingError
    ) -> DrawingProductionError {
        switch error {
        case .invalidValue: .invalidValue
        case .invalidPathState: .invalidPathState
        case .arithmeticOverflow: .arithmeticOverflow
        case .capacityExhausted: .capacityExhausted
        case .invalidScope: .invalidScope
        case .invalidPhase: .invalidPhase
        case .reentrancyViolation: .reentrancyViolation
        case .invariantViolation: .invariantViolation
        }
    }
}
