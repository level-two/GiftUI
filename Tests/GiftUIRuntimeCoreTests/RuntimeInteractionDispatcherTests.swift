import GiftUI
import GiftUIExecution
import GiftUIInteraction
import Testing

@testable import GiftUIRuntimeCore

private enum DispatchAction: UInt16, GiftUIAction {
    case start = 0
    case stop = 1
}

private final class DispatchModel: _GiftUIObservableReference {
    private(set) var handledActions: [DispatchAction] = []

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        _ = attachment
    }

    func record(_ action: DispatchAction) {
        handledActions.append(action)
    }
}

private struct DispatchHandler: GiftUIActionHandler {
    mutating func handle(
        _ action: DispatchAction,
        model: borrowing DispatchModel
    ) {
        model.record(action)
    }
}

private final class DispatchAccessProbe {
    var generationReadCount = 0
    var borrowAttemptCount = 0
    var bodyCallCount = 0
}

private struct DispatchTargetAccess: ActionModelTargetAccess {
    let generation: ObservableTargetGeneration?
    let model: DispatchModel?
    let probe: DispatchAccessProbe

    func currentGeneration() -> ObservableTargetGeneration? {
        probe.generationReadCount += 1
        return generation
    }

    mutating func withCurrentModel(
        matching generation: ObservableTargetGeneration,
        _ body: (borrowing DispatchModel) -> Void
    ) -> Bool {
        probe.borrowAttemptCount += 1
        guard self.generation == generation, let model else { return false }
        body(model)
        probe.bodyCallCount += 1
        return true
    }
}

private struct DispatchRecordView: InteractionCommittedActionView {
    let record: BoundActionRecord<UInt16>?

    func committedRecord(
        for identity: UInt16
    ) -> BoundActionRecord<UInt16>? {
        guard record?.identity == identity else { return nil }
        return record
    }
}

private final class MutableDispatchRecordBox {
    var record: BoundActionRecord<UInt16>?

    init(record: BoundActionRecord<UInt16>?) {
        self.record = record
    }
}

private struct MutableDispatchRecordView: InteractionCommittedActionView {
    let box: MutableDispatchRecordBox

    func committedRecord(
        for identity: UInt16
    ) -> BoundActionRecord<UInt16>? {
        guard box.record?.identity == identity else { return nil }
        return box.record
    }
}

private final class MutableDispatchTargetBox {
    var generation: ObservableTargetGeneration?
    var model: DispatchModel?

    init(
        generation: ObservableTargetGeneration?,
        model: DispatchModel?
    ) {
        self.generation = generation
        self.model = model
    }
}

private struct MutableDispatchTargetAccess: ActionModelTargetAccess {
    let box: MutableDispatchTargetBox

    func currentGeneration() -> ObservableTargetGeneration? {
        box.generation
    }

    mutating func withCurrentModel(
        matching generation: ObservableTargetGeneration,
        _ body: (borrowing DispatchModel) -> Void
    ) -> Bool {
        guard box.generation == generation, let model = box.model else {
            return false
        }
        body(model)
        return true
    }
}

private let dispatchBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 2, height: 2)!
)!

private func dispatchRecord(
    action: UInt16 = DispatchAction.start.rawValue,
    generation: UInt32 = 8,
    target: UInt32 = 12,
    enabled: Bool = true
) -> BoundActionRecord<UInt16> {
    BoundActionRecord(
        identity: 4,
        generation: ActionGeneration(rawValue: generation),
        isEnabled: enabled,
        hitBounds: dispatchBounds,
        paintOrder: 0,
        action: BoundedApplicationAction(code: action),
        targetGeneration: ObservableTargetGeneration(rawValue: target)
    )
}

@Test
func dispatcherRevalidatesDecodesAndBorrowsCurrentModelExactlyOnce() {
    let model = DispatchModel()
    let probe = DispatchAccessProbe()
    var dispatcher = RuntimeInteractionDispatcher(
        records: DispatchRecordView(record: dispatchRecord()),
        handler: DispatchHandler(),
        targetAccess: DispatchTargetAccess(
            generation: ObservableTargetGeneration(rawValue: 12),
            model: model,
            probe: probe
        )
    )

    let result = dispatcher.dispatch(
        CapturedAction(
            identity: 4,
            generation: ActionGeneration(rawValue: 8)
        )
    )

    #expect(result == .dispatched)
    #expect(model.handledActions == [.start])
    #expect(probe.generationReadCount == 1)
    #expect(probe.borrowAttemptCount == 1)
    #expect(probe.bodyCallCount == 1)
}

@Test
func missingCommittedRecordCancelsWithoutConsultingTargetOrHandler() {
    let model = DispatchModel()
    let probe = DispatchAccessProbe()
    var dispatcher = RuntimeInteractionDispatcher(
        records: DispatchRecordView(record: nil),
        handler: DispatchHandler(),
        targetAccess: DispatchTargetAccess(
            generation: ObservableTargetGeneration(rawValue: 12),
            model: model,
            probe: probe
        )
    )

    let result = dispatcher.dispatch(
        CapturedAction(
            identity: 4,
            generation: ActionGeneration(rawValue: 8)
        )
    )

    #expect(result == .cancelled)
    #expect(model.handledActions.isEmpty)
    #expect(probe.generationReadCount == 0)
    #expect(probe.borrowAttemptCount == 0)
}

@Test(arguments: [
    dispatchRecord(generation: 9),
    dispatchRecord(enabled: false),
])
func changedOrDisabledCommittedRecordCancelsBeforeTargetBorrow(
    record: BoundActionRecord<UInt16>
) {
    let model = DispatchModel()
    let probe = DispatchAccessProbe()
    var dispatcher = RuntimeInteractionDispatcher(
        records: DispatchRecordView(record: record),
        handler: DispatchHandler(),
        targetAccess: DispatchTargetAccess(
            generation: ObservableTargetGeneration(rawValue: 12),
            model: model,
            probe: probe
        )
    )

    let result = dispatcher.dispatch(
        CapturedAction(
            identity: 4,
            generation: ActionGeneration(rawValue: 8)
        )
    )

    #expect(result == .cancelled)
    #expect(model.handledActions.isEmpty)
    #expect(probe.generationReadCount == 0)
    #expect(probe.borrowAttemptCount == 0)
}

@Test
func changedTargetGenerationCancelsBeforeModelBorrow() {
    let model = DispatchModel()
    let probe = DispatchAccessProbe()
    var dispatcher = RuntimeInteractionDispatcher(
        records: DispatchRecordView(record: dispatchRecord()),
        handler: DispatchHandler(),
        targetAccess: DispatchTargetAccess(
            generation: ObservableTargetGeneration(rawValue: 13),
            model: model,
            probe: probe
        )
    )

    let result = dispatcher.dispatch(
        CapturedAction(
            identity: 4,
            generation: ActionGeneration(rawValue: 8)
        )
    )

    #expect(result == .cancelled)
    #expect(model.handledActions.isEmpty)
    #expect(probe.generationReadCount == 1)
    #expect(probe.borrowAttemptCount == 0)
}

@Test
func targetDisappearingBeforeBorrowCancelsWithoutHandlerInvocation() {
    let model = DispatchModel()
    let probe = DispatchAccessProbe()
    var dispatcher = RuntimeInteractionDispatcher(
        records: DispatchRecordView(record: dispatchRecord()),
        handler: DispatchHandler(),
        targetAccess: DispatchTargetAccess(
            generation: ObservableTargetGeneration(rawValue: 12),
            model: nil,
            probe: probe
        )
    )

    let result = dispatcher.dispatch(
        CapturedAction(
            identity: 4,
            generation: ActionGeneration(rawValue: 8)
        )
    )

    #expect(result == .cancelled)
    #expect(model.handledActions.isEmpty)
    #expect(probe.generationReadCount == 1)
    #expect(probe.borrowAttemptCount == 1)
    #expect(probe.bodyCallCount == 0)
}

@Test
func invalidCommittedActionCodeReturnsInvariantFailureWithoutHandlerInvocation() {
    let model = DispatchModel()
    let probe = DispatchAccessProbe()
    var dispatcher = RuntimeInteractionDispatcher(
        records: DispatchRecordView(record: dispatchRecord(action: .max)),
        handler: DispatchHandler(),
        targetAccess: DispatchTargetAccess(
            generation: ObservableTargetGeneration(rawValue: 12),
            model: model,
            probe: probe
        )
    )

    let result = dispatcher.dispatch(
        CapturedAction(
            identity: 4,
            generation: ActionGeneration(rawValue: 8)
        )
    )

    #expect(result == .failure(.invariantViolation))
    #expect(model.handledActions.isEmpty)
    #expect(probe.generationReadCount == 1)
    #expect(probe.borrowAttemptCount == 0)
}

@Test
func committedReplacementAfterDownCancelsFormerCaptureForBothModels() {
    let former = DispatchModel()
    let replacement = DispatchModel()
    let records = MutableDispatchRecordBox(record: dispatchRecord())
    let target = MutableDispatchTargetBox(
        generation: ObservableTargetGeneration(rawValue: 12),
        model: former
    )
    var dispatcher = RuntimeInteractionDispatcher(
        records: MutableDispatchRecordView(box: records),
        handler: DispatchHandler(),
        targetAccess: MutableDispatchTargetAccess(box: target)
    )
    let capturedAtDown = CapturedAction(
        identity: UInt16(4),
        generation: ActionGeneration(rawValue: 8)
    )

    records.record = dispatchRecord(generation: 9, target: 13)
    target.generation = ObservableTargetGeneration(rawValue: 13)
    target.model = replacement

    #expect(dispatcher.dispatch(capturedAtDown) == .cancelled)
    #expect(former.handledActions.isEmpty)
    #expect(replacement.handledActions.isEmpty)
}

@Test
func committedReplacementAfterAdmissionCancelsAtFinalTargetValidation() {
    let former = DispatchModel()
    let replacement = DispatchModel()
    let records = MutableDispatchRecordBox(record: dispatchRecord())
    let target = MutableDispatchTargetBox(
        generation: ObservableTargetGeneration(rawValue: 12),
        model: former
    )
    var dispatcher = RuntimeInteractionDispatcher(
        records: MutableDispatchRecordView(box: records),
        handler: DispatchHandler(),
        targetAccess: MutableDispatchTargetAccess(box: target)
    )
    let admitted = CapturedAction(
        identity: UInt16(4),
        generation: ActionGeneration(rawValue: 8)
    )

    target.generation = ObservableTargetGeneration(rawValue: 13)
    target.model = replacement

    #expect(dispatcher.dispatch(admitted) == .cancelled)
    #expect(former.handledActions.isEmpty)
    #expect(replacement.handledActions.isEmpty)
}

@Test
func committedRemovalAfterAdmissionCancelsWithoutRetainingFormerModel() {
    let former = DispatchModel()
    let records = MutableDispatchRecordBox(record: dispatchRecord())
    let target = MutableDispatchTargetBox(
        generation: ObservableTargetGeneration(rawValue: 12),
        model: former
    )
    var dispatcher = RuntimeInteractionDispatcher(
        records: MutableDispatchRecordView(box: records),
        handler: DispatchHandler(),
        targetAccess: MutableDispatchTargetAccess(box: target)
    )

    target.generation = nil
    target.model = nil

    #expect(
        dispatcher.dispatch(
            CapturedAction(
                identity: 4,
                generation: ActionGeneration(rawValue: 8)
            )
        ) == .cancelled
    )
    #expect(former.handledActions.isEmpty)
}

@Test
func stagedReplacementPreservesFormerCaptureUntilCommit() {
    let former = DispatchModel()
    let staged = DispatchModel()
    let records = MutableDispatchRecordBox(record: dispatchRecord())
    let target = MutableDispatchTargetBox(
        generation: ObservableTargetGeneration(rawValue: 12),
        model: former
    )
    var dispatcher = RuntimeInteractionDispatcher(
        records: MutableDispatchRecordView(box: records),
        handler: DispatchHandler(),
        targetAccess: MutableDispatchTargetAccess(box: target)
    )

    _ = staged

    #expect(
        dispatcher.dispatch(
            CapturedAction(
                identity: 4,
                generation: ActionGeneration(rawValue: 8)
            )
        ) == .dispatched
    )
    #expect(former.handledActions == [.start])
    #expect(staged.handledActions.isEmpty)
}

@Test
func failedReplacementPreservesFormerRouteForNewValidGesture() {
    let former = DispatchModel()
    let failedCandidate = DispatchModel()
    let records = MutableDispatchRecordBox(record: dispatchRecord())
    let target = MutableDispatchTargetBox(
        generation: ObservableTargetGeneration(rawValue: 12),
        model: former
    )
    var dispatcher = RuntimeInteractionDispatcher(
        records: MutableDispatchRecordView(box: records),
        handler: DispatchHandler(),
        targetAccess: MutableDispatchTargetAccess(box: target)
    )

    _ = failedCandidate

    #expect(
        dispatcher.dispatch(
            CapturedAction(
                identity: 4,
                generation: ActionGeneration(rawValue: 8)
            )
        ) == .dispatched
    )
    #expect(former.handledActions == [.start])
    #expect(failedCandidate.handledActions.isEmpty)
}
