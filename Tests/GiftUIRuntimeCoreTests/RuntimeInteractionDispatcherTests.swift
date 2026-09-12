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
