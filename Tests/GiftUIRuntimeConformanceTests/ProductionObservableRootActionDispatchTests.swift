import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import Testing

@testable import GiftUIRuntimeDynamic
@testable import GiftUIRuntimeStatic

private enum RootDispatchAction: UInt16, GiftUIAction {
    case invoke = 0
}

private struct RootDispatchModel: _GiftUIObservableReference {
    let identity: UInt8
    let invocationTotal: UnsafeMutablePointer<UInt8>
    private(set) var attachment: _GiftUIObservationAttachment?

    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        attachment = sink.attachment
        return attachment
    }

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        guard self.attachment == attachment else { return }
        self.attachment = nil
    }
}

private struct RootDispatchHandler: GiftUIActionHandler {
    mutating func handle(
        _ action: RootDispatchAction,
        model: borrowing RootDispatchModel
    ) {
        switch action {
        case .invoke:
            model.invocationTotal.pointee += model.identity
        }
    }
}

private struct RootDispatchRecords: InteractionCommittedActionView {
    let targetGeneration: ObservableTargetGeneration

    func committedRecord(for identity: UInt16) -> BoundActionRecord<UInt16>? {
        guard identity == 1 else { return nil }
        return BoundActionRecord(
            identity: identity,
            generation: ActionGeneration(rawValue: 7),
            isEnabled: true,
            hitBounds: Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: 1, height: 1)!
            )!,
            paintOrder: 0,
            action: BoundedApplicationAction(code: RootDispatchAction.invoke.rawValue),
            targetGeneration: targetGeneration
        )
    }
}

private struct RootDispatchTranscript: Equatable {
    let initial: InteractionDispatchResult
    let failedReplacement: ObservableStateResult
    let afterFailedReplacement: InteractionDispatchResult
    let staleAfterReplacement: InteractionDispatchResult
    let currentAfterReplacement: InteractionDispatchResult
    let afterRemoval: InteractionDispatchResult
    let invocationTotal: UInt8
}

private let rootCapturedAction = CapturedAction(
    identity: UInt16(1),
    generation: ActionGeneration(rawValue: 7)
)

private func dynamicRootDispatchTranscript(
    invocationTotal: UnsafeMutablePointer<UInt8>
) -> RootDispatchTranscript {
    let root = DynamicObservableRootAdapter<RootDispatchModel, UInt32>(capacity: 1)
    var state = State(
        wrappedValue: RootDispatchModel(
            identity: 1,
            invocationTotal: invocationTotal
        )
    )
    _ = root.beginCandidate()
    _ = root.encounter(
        structuralIdentity: 0x5341_0500,
        declarationOrdinal: 0,
        state: &state,
        replacementRoute: { _ in }
    )
    _ = root.finishCandidate(.publish)

    var initialDispatcher = RuntimeInteractionDispatcher(
        records: RootDispatchRecords(
            targetGeneration: ObservableTargetGeneration(rawValue: 0)
        ),
        handler: RootDispatchHandler(),
        targetAccess: DynamicObservableRootTargetAccess(root: root)
    )
    let initial = initialDispatcher.dispatch(rootCapturedAction)

    root.setExecutionPhase(.mutating)
    let failedReplacement = root.replace(
        with: RootDispatchModel(
            identity: 9,
            invocationTotal: invocationTotal
        ),
        isCompatible: false
    )
    let afterFailedReplacement = initialDispatcher.dispatch(rootCapturedAction)
    _ = root.replace(
        with: RootDispatchModel(
            identity: 2,
            invocationTotal: invocationTotal
        )
    )
    let staleAfterReplacement = initialDispatcher.dispatch(rootCapturedAction)
    var replacementDispatcher = RuntimeInteractionDispatcher(
        records: RootDispatchRecords(
            targetGeneration: ObservableTargetGeneration(rawValue: 1)
        ),
        handler: RootDispatchHandler(),
        targetAccess: DynamicObservableRootTargetAccess(root: root)
    )
    let currentAfterReplacement = replacementDispatcher.dispatch(
        rootCapturedAction
    )

    _ = root.beginCandidate()
    _ = root.finishCandidate(.publish)
    let afterRemoval = replacementDispatcher.dispatch(rootCapturedAction)
    return RootDispatchTranscript(
        initial: initial,
        failedReplacement: failedReplacement,
        afterFailedReplacement: afterFailedReplacement,
        staleAfterReplacement: staleAfterReplacement,
        currentAfterReplacement: currentAfterReplacement,
        afterRemoval: afterRemoval,
        invocationTotal: invocationTotal.pointee
    )
}

private func staticRootDispatchTranscript(
    invocationTotal: UnsafeMutablePointer<UInt8>
) -> RootDispatchTranscript {
    var root = StaticObservableRootAdapter<RootDispatchModel, UInt32>(
        structuralIdentity: 0x5341_0500,
        declarationOrdinal: 0
    )
    _ = root.beginCandidate()
    _ = root.withEncounter(
        state: State(
            wrappedValue: RootDispatchModel(
                identity: 1,
                invocationTotal: invocationTotal
            )
        ),
        replacementRoute: { _ in },
        reportRoute: { _ in .staleAttachment },
        body: { _ in () }
    )
    _ = root.finishCandidate(.publish)

    return withUnsafeMutablePointer(to: &root) { rootPointer in
        var initialDispatcher = RuntimeInteractionDispatcher(
            records: RootDispatchRecords(
                targetGeneration: ObservableTargetGeneration(rawValue: 0)
            ),
            handler: RootDispatchHandler(),
            targetAccess: StaticObservableRootTargetAccess(root: rootPointer)
        )
        let initial = initialDispatcher.dispatch(rootCapturedAction)

        rootPointer.pointee.setExecutionPhase(.mutating)
        let failedReplacement = rootPointer.pointee.replace(
            with: RootDispatchModel(
                identity: 9,
                invocationTotal: invocationTotal
            ),
            reportRoute: { _ in .staleAttachment },
            isCompatible: false
        )
        let afterFailedReplacement = initialDispatcher.dispatch(
            rootCapturedAction
        )
        _ = rootPointer.pointee.replace(
            with: RootDispatchModel(
                identity: 2,
                invocationTotal: invocationTotal
            ),
            reportRoute: { _ in .staleAttachment }
        )
        let staleAfterReplacement = initialDispatcher.dispatch(
            rootCapturedAction
        )
        var replacementDispatcher = RuntimeInteractionDispatcher(
            records: RootDispatchRecords(
                targetGeneration: ObservableTargetGeneration(rawValue: 1)
            ),
            handler: RootDispatchHandler(),
            targetAccess: StaticObservableRootTargetAccess(root: rootPointer)
        )
        let currentAfterReplacement = replacementDispatcher.dispatch(
            rootCapturedAction
        )

        _ = rootPointer.pointee.beginCandidate()
        _ = rootPointer.pointee.finishCandidate(.publish)
        let afterRemoval = replacementDispatcher.dispatch(rootCapturedAction)
        return RootDispatchTranscript(
            initial: initial,
            failedReplacement: failedReplacement,
            afterFailedReplacement: afterFailedReplacement,
            staleAfterReplacement: staleAfterReplacement,
            currentAfterReplacement: currentAfterReplacement,
            afterRemoval: afterRemoval,
            invocationTotal: invocationTotal.pointee
        )
    }
}

@Test func rootTargetAdaptersProduceEqualDispatchAndCancellation() {
    var dynamicTotal: UInt8 = 0
    let dynamic = withUnsafeMutablePointer(to: &dynamicTotal) {
        dynamicRootDispatchTranscript(invocationTotal: $0)
    }
    var staticTotal: UInt8 = 0
    let fixed = withUnsafeMutablePointer(to: &staticTotal) {
        staticRootDispatchTranscript(invocationTotal: $0)
    }

    #expect(dynamic == fixed)
    #expect(dynamic.initial == .dispatched)
    #expect(dynamic.failedReplacement == .failure(.incompatibleAssociation))
    #expect(dynamic.afterFailedReplacement == .dispatched)
    #expect(dynamic.staleAfterReplacement == .cancelled)
    #expect(dynamic.currentAfterReplacement == .dispatched)
    #expect(dynamic.afterRemoval == .cancelled)
    #expect(dynamic.invocationTotal == 4)
}
