import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIRuntimeCore

/// Binds the Dynamic profile's concrete storage to Runtime Core's one shared
/// lifecycle without acquiring ownership of any focused algorithm.
package struct DynamicRuntimeProfileBinding: ~Copyable {
    private var storage: DynamicProfileStorage
    private var canvasCallables: DynamicCanvasCallableStorage<DynamicStructuralIdentity>
    private var lifecycle: RuntimeCoordinatorLifecycle

    package init?(
        structuralIdentity: DynamicStructuralIdentity,
        limits: RuntimeProfileLimits,
        byteCounts: RuntimeStorageByteCounts
    ) {
        guard
            let storage = DynamicProfileStorage(
                structuralIdentity: structuralIdentity,
                limits: limits,
                byteCounts: byteCounts
            )
        else {
            return nil
        }
        var lifecycle = RuntimeCoordinatorLifecycle()
        guard lifecycle.validate(storage.audit()) == nil,
            lifecycle.enterIdle() == nil
        else {
            return nil
        }

        self.storage = storage
        canvasCallables = DynamicCanvasCallableStorage(
            capacity: limits.drawing.maximumCanvasOccurrences
        )
        self.lifecycle = lifecycle
    }

    package var profile: RuntimeProfileKind { .dynamic }

    package var storageAudit: RuntimeStorageAudit? {
        lifecycle.storageAudit
    }

    package var executionContext: ExecutionContext {
        lifecycle.executionContext
    }

    package var isQuiescent: Bool {
        lifecycle.isQuiescent
    }

    package var storageLifetimeState: DynamicStorageLifetimeState {
        storage.storageLifetimeState
    }

    package var canvasOccurrenceCount: UInt16 {
        canvasCallables.canvasOccurrenceCount
    }

    package var canvasReleaseCount: UInt16 {
        canvasCallables.releaseCount
    }

    package var releaseCounters: DynamicStorageReleaseCounters {
        storage.releaseCounters
    }

    package mutating func beginOpportunity(
        context: ExecutionContext
    ) -> ExecutionError? {
        guard let error = lifecycle.beginOpportunity(context: context) else {
            guard storage.beginAttempt() else { return .invariantViolation }
            return nil
        }
        return error
    }

    package mutating func recordActiveContext(
        _ context: ExecutionContext
    ) -> ExecutionError? {
        lifecycle.recordActiveContext(context)
    }

    package mutating func reserve(
        _ count: UInt16,
        for limit: DynamicStorageLimit
    ) -> DynamicStorageReservation {
        storage.reserve(count, for: limit)
    }

    package mutating func stageCanvas(
        identity: consuming DynamicStructuralIdentity,
        canvas: consuming Canvas
    ) -> Bool {
        guard storage.storageLifetimeState == .attemptActive else { return false }
        return canvasCallables.stage(
            identity: consume identity,
            canvas: consume canvas
        )
    }

    package mutating func invokeCanvas(
        at identity: DynamicStructuralIdentity,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        defer { canvasCallables.releaseCanvas(at: identity) }
        try canvasCallables.invokeCanvas(
            at: identity,
            context: &context,
            size: size
        )
    }

    package mutating func finishOpportunity(
        context: ExecutionContext
    ) -> ExecutionError? {
        canvasCallables.discard()
        storage.finishAttempt()
        guard let error = lifecycle.finishOpportunity(context: context) else {
            finishTeardownIfQuiescent()
            return nil
        }
        return error
    }

    package mutating func runActivePipeline<Owner>(
        owner: inout Owner
    ) -> RuntimeCompletePipelineResult
    where Owner: RuntimeCompletePipelineOwner & ~Copyable {
        guard storage.storageLifetimeState == .attemptActive else {
            return RuntimeCompletePipeline.rejectInactive(owner: &owner)
        }
        return RuntimeCompletePipeline.run(owner: &owner)
    }

    package mutating func quiesce() {
        lifecycle.requestQuiescence()
        canvasCallables.discard()
        storage.quiesce()
        finishTeardownIfQuiescent()
    }

    private mutating func finishTeardownIfQuiescent() {
        guard lifecycle.isQuiescent,
            storage.storageLifetimeState == .tornDown
        else {
            return
        }
        _ = lifecycle.completeTeardown()
    }
}
