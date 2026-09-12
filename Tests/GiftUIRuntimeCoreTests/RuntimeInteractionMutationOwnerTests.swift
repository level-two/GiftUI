import GiftUI
import GiftUIExecution
import GiftUIInteraction
import Testing

@testable import GiftUIRuntimeCore

private struct MutationBatchView: ExecutionMutationBatchView {
    let stateChanges: [UInt8]
    let completions: [UInt8]
    let actions: [CapturedAction<UInt8>]

    var stateChangeCount: UInt16 { UInt16(stateChanges.count) }
    var completionCount: UInt16 { UInt16(completions.count) }
    var actionCount: UInt16 { UInt16(actions.count) }

    func stateChange(at index: UInt16) -> UInt8 {
        stateChanges[Int(index)]
    }

    func completion(at index: UInt16) -> UInt8 {
        completions[Int(index)]
    }

    func action(at index: UInt16) -> CapturedAction<UInt8> {
        actions[Int(index)]
    }
}

private final class MutationTrace {
    var events: [String] = []
    var isDirty = false
    var wakeCount: UInt16 = 0
    var reportCount: UInt16 = 0
    var pendingRepositoryFacts: [UInt8] = []

    func reportChange(for action: MutationAction) {
        reportCount += 1
        events.append("report-\(action.rawValue)")
        if !isDirty {
            isDirty = true
            wakeCount += 1
        }
        pendingRepositoryFacts.append(40 + UInt8(action.rawValue))
    }
}

private enum MutationAction: UInt16, GiftUIAction {
    case first = 0
    case second = 1
}

private final class MutationModel: _GiftUIObservableReference {
    let trace: MutationTrace

    init(trace: MutationTrace) {
        self.trace = trace
    }

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

    func handle(_ action: MutationAction) {
        trace.events.append("action-\(action.rawValue)-entered")
        trace.reportChange(for: action)
        trace.events.append("action-\(action.rawValue)-returned")
    }
}

private struct MutationHandler: GiftUIActionHandler {
    mutating func handle(
        _ action: MutationAction,
        model: borrowing MutationModel
    ) {
        model.handle(action)
    }
}

private struct MutationApplication: RuntimeMutationApplication {
    let trace: MutationTrace

    mutating func apply(stateChange: borrowing UInt8) {
        trace.events.append("state-\(stateChange)")
    }

    mutating func apply(completion: borrowing UInt8) {
        trace.events.append("completion-\(completion)")
    }
}

private struct MutationRecordView: InteractionCommittedActionView {
    let records: [BoundActionRecord<UInt8>]

    func committedRecord(
        for identity: UInt8
    ) -> BoundActionRecord<UInt8>? {
        records.first { $0.identity == identity }
    }
}

private struct MutationTargetAccess: ActionModelTargetAccess {
    let generation: ObservableTargetGeneration
    let model: MutationModel

    func currentGeneration() -> ObservableTargetGeneration? {
        generation
    }

    mutating func withCurrentModel(
        matching generation: ObservableTargetGeneration,
        _ body: (borrowing MutationModel) -> Void
    ) -> Bool {
        guard self.generation == generation else { return false }
        body(model)
        return true
    }
}

private let mutationBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 2, height: 2)!
)!

private let mutationLimits = ExecutionLimits(
    maximumInputEvents: 2,
    maximumStateChangeFacts: 2,
    maximumCompletionFacts: 1,
    maximumSemanticActions: 2,
    maximumActiveInputSources: 1,
    maximumCommittedActions: 2
)!

private func mutationRecord(
    identity: UInt8,
    action: MutationAction,
    generation: UInt32
) -> BoundActionRecord<UInt8> {
    BoundActionRecord(
        identity: identity,
        generation: ActionGeneration(rawValue: generation),
        isEnabled: true,
        hitBounds: mutationBounds,
        paintOrder: UInt16(identity),
        action: BoundedApplicationAction(code: action.rawValue),
        targetGeneration: ObservableTargetGeneration(rawValue: 20)
    )
}

private func mutationOwner(
    trace: MutationTrace
) -> RuntimeInteractionMutationOwner<
    MutationApplication,
    RuntimeInteractionDispatcher<
        MutationRecordView,
        MutationHandler,
        MutationTargetAccess
    >
> {
    let model = MutationModel(trace: trace)
    return RuntimeInteractionMutationOwner(
        application: MutationApplication(trace: trace),
        dispatcher: RuntimeInteractionDispatcher(
            records: MutationRecordView(
                records: [
                    mutationRecord(identity: 1, action: .first, generation: 11),
                    mutationRecord(identity: 2, action: .second, generation: 12),
                ]
            ),
            handler: MutationHandler(),
            targetAccess: MutationTargetAccess(
                generation: ObservableTargetGeneration(rawValue: 20),
                model: model
            )
        )
    )
}

@Test
func mutationBatchOrdersSynchronousDispatchAndDefersRepositoryFacts() {
    let trace = MutationTrace()
    var owner = mutationOwner(trace: trace)
    var batch = ExecutionMutationBatch(
        view: MutationBatchView(
            stateChanges: [1, 2],
            completions: [3],
            actions: [
                CapturedAction(
                    identity: 1,
                    generation: ActionGeneration(rawValue: 11)
                ),
                CapturedAction(
                    identity: 2,
                    generation: ActionGeneration(rawValue: 12)
                ),
            ]
        ),
        limits: mutationLimits
    )!

    #expect(batch.apply(phase: .mutating, to: &owner) == nil)
    #expect(
        trace.events == [
            "state-1",
            "state-2",
            "completion-3",
            "action-0-entered",
            "report-0",
            "action-0-returned",
            "action-1-entered",
            "report-1",
            "action-1-returned",
        ]
    )
    #expect(owner.firstDispatchFailure == nil)
    #expect(trace.reportCount == 2)
    #expect(trace.isDirty)
    #expect(trace.wakeCount == 1)
    #expect(trace.pendingRepositoryFacts == [40, 41])

    let afterFirstApplication = trace.events
    #expect(
        batch.apply(phase: .mutating, to: &owner)
            == .reentrancyViolation
    )
    #expect(trace.events == afterFirstApplication)

    var laterBatch = ExecutionMutationBatch(
        view: MutationBatchView(
            stateChanges: trace.pendingRepositoryFacts,
            completions: [],
            actions: []
        ),
        limits: mutationLimits
    )!
    #expect(laterBatch.apply(phase: .mutating, to: &owner) == nil)
    #expect(trace.events.suffix(2) == ["state-40", "state-41"])
    #expect(trace.wakeCount == 1)
}

@Test
func mutationBatchRejectsWrongPhaseAndOverLimitViewsWithoutEffects() {
    let trace = MutationTrace()
    var owner = mutationOwner(trace: trace)
    var batch = ExecutionMutationBatch(
        view: MutationBatchView(
            stateChanges: [],
            completions: [],
            actions: [
                CapturedAction(
                    identity: 1,
                    generation: ActionGeneration(rawValue: 11)
                )
            ]
        ),
        limits: mutationLimits
    )!

    #expect(batch.apply(phase: .admitting, to: &owner) == .invalidPhase)
    #expect(trace.events.isEmpty)

    #expect(
        ExecutionMutationBatch(
            view: MutationBatchView(
                stateChanges: [1, 2, 3],
                completions: [],
                actions: []
            ),
            limits: mutationLimits
        ) == nil
    )
}
