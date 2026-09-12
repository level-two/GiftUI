import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIRuntimeCore

/// Binds generated Static storage and callable tables to Runtime Core's one
/// shared lifecycle while leaving each focused algorithm with its owner.
package struct StaticRuntimeProfileBinding<Regions, Metadata>: ~Copyable
where
    Regions: StaticProfileStorageRegions & ~Copyable,
    Metadata: RuntimeStaticCanvasAuditMetadata & StaticCanvasCallableTable
{
    private var storage: StaticProfileStorage<Regions, Metadata>
    private var lifecycle: RuntimeCoordinatorLifecycle

    package init?(
        structuralIdentity: StaticStructuralIdentity,
        limits: RuntimeProfileLimits,
        regions: consuming Regions,
        metadata: consuming Metadata
    ) {
        guard
            let storage = StaticProfileStorage(
                structuralIdentity: structuralIdentity,
                limits: limits,
                regions: consume regions,
                metadata: consume metadata
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
        self.storage = consume storage
        self.lifecycle = lifecycle
    }

    package var profile: RuntimeProfileKind { .static }

    package var storageAudit: RuntimeStorageAudit? {
        lifecycle.storageAudit
    }

    package var executionContext: ExecutionContext {
        lifecycle.executionContext
    }

    package var isQuiescent: Bool {
        lifecycle.isQuiescent
    }

    package var storageLifetimeState: StaticStorageLifetimeState {
        storage.storageLifetimeState
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
        for limit: RuntimeStorageLimit
    ) -> StaticStorageReservation {
        storage.reserve(count, for: limit)
    }

    package mutating func stageCanvas<Identity>(
        identity: consuming Identity,
        callableID: UInt16,
        declaredCaptureByteCount: UInt16,
        capture: consuming Metadata.CaptureStorage
    ) -> StaticCanvasOccurrence<Identity, Metadata.CaptureStorage>?
    where Identity: Equatable & Sendable {
        storage.stageCanvas(
            identity: consume identity,
            callableID: callableID,
            declaredCaptureByteCount: declaredCaptureByteCount,
            capture: consume capture
        )
    }

    package mutating func invokeCanvas<Identity>(
        occurrence: inout StaticCanvasOccurrence<Identity, Metadata.CaptureStorage>,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError)
    where Identity: Equatable & Sendable {
        try storage.invokeCanvas(
            occurrence: &occurrence,
            context: &context,
            size: size
        )
    }

    package mutating func finishOpportunity(
        context: ExecutionContext
    ) -> ExecutionError? {
        storage.finishAttempt()
        guard let error = lifecycle.finishOpportunity(context: context) else {
            finishTeardownIfQuiescent()
            return nil
        }
        return error
    }

    package mutating func quiesce() {
        lifecycle.requestQuiescence()
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
