import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIObservableState

private struct ReportWakeRequester: ExecutionWakeRequester, Sendable {
    private(set) var requestCount: UInt16 = 0
    private(set) var reasons: ExecutionWakeReasons = []

    mutating func requestWake(for reasons: ExecutionWakeReasons) {
        requestCount += 1
        self.reasons.formUnion(reasons)
    }
}

private final class ReportRouteBox {
    var route: ObservableStateReportRoute<ReportWakeRequester>

    init(_ route: ObservableStateReportRoute<ReportWakeRequester>) {
        self.route = route
    }
}

private final class SynchronouslyReportingModel: _GiftUIObservableReference {
    private var sink: _GiftUIObservableChangeSink?
    private(set) var value: UInt16 = 0

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        let attachment = sink.attachment
        self.sink = consume sink
        return attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        sink = nil
    }

    func mutate(to newValue: UInt16) -> _GiftUIObservableChangeReportOutcome? {
        let changed = value != newValue
        value = newValue
        guard sink != nil else { return nil }
        return ObservableStateMutationReporting.reportIfChanged(
            changed,
            through: &sink!
        )
    }
}

@Test
func sinkActivatesOnlyAfterMatchingAttachmentReturn() {
    let attachment = _GiftUIObservationAttachment(slot: 1, generation: 9)
    let route = ObservableStateReportRoute(
        attachment: attachment,
        requester: ReportWakeRequester()
    )!
    let box = ReportRouteBox(route)
    let model = SynchronouslyReportingModel()
    let returned = model._giftUIAttachChangeSink(
        _GiftUIObservableChangeSink(
            attachment: attachment,
            reportRoute: { reported in
                box.route.acceptReport(
                    attachment: reported,
                    phase: .mutating
                ).sinkOutcome
            }
        )
    )

    #expect(!box.route.isActive)
    #expect(box.route.verifyAttachment(returned) == nil)
    #expect(box.route.isActive)
    #expect(model.mutate(to: 1) == .dirtied)
}

@Test
func validReportsDirtyOnceThenCoalesceIntoOneWakeIntent() {
    let attachment = _GiftUIObservationAttachment(slot: 2, generation: 12)
    var route = ObservableStateReportRoute(
        attachment: attachment,
        requester: ReportWakeRequester()
    )!
    #expect(route.verifyAttachment(attachment) == nil)

    let first = route.acceptReport(
        attachment: attachment,
        phase: .mutating
    )
    let second = route.acceptReport(
        attachment: attachment,
        phase: .mutating
    )
    let third = route.acceptReport(
        attachment: attachment,
        phase: .mutating
    )

    #expect(first == ObservableStateReportDisposition(.dirtied))
    #expect(second == ObservableStateReportDisposition(.coalesced))
    #expect(third == ObservableStateReportDisposition(.coalesced))
    #expect(route.isDirty)
    #expect(route.semanticWakeOutstanding)
    #expect(route.requester.requestCount == 1)
    #expect(route.requester.reasons == .semanticDirty)
}

@Test
func sinkAndOwnerOutcomesCorrespondExactly() {
    let outcomes: [_GiftUIObservableChangeReportOutcome] = [
        .dirtied,
        .coalesced,
        .staleAttachment,
        .invalidPhaseContained,
        .invalidPhaseSafetyNotProven,
        .reentrancyViolation,
        .invariantViolation,
    ]
    let results: [ObservableStateResult] = [
        .success(.dirtied),
        .success(.coalesced),
        .failure(.staleAttachment),
        .failure(.invalidPhaseContained),
        .failure(.invalidPhaseSafetyNotProven),
        .failure(.reentrancyViolation),
        .failure(.invariantViolation),
    ]

    for index in outcomes.indices {
        let disposition = ObservableStateReportDisposition(outcomes[index])
        #expect(disposition.sinkOutcome == outcomes[index])
        #expect(disposition.ownerResult == results[index])
    }
}

@Test
func changedMutationReportsSynchronouslyAndProvenNoopOmitsReport() {
    let attachment = _GiftUIObservationAttachment(slot: 3, generation: 21)
    let route = ObservableStateReportRoute(
        attachment: attachment,
        requester: ReportWakeRequester()
    )!
    let box = ReportRouteBox(route)
    let model = SynchronouslyReportingModel()
    let returned = model._giftUIAttachChangeSink(
        _GiftUIObservableChangeSink(
            attachment: attachment,
            reportRoute: { reported in
                box.route.acceptReport(
                    attachment: reported,
                    phase: .mutating
                ).sinkOutcome
            }
        )
    )
    #expect(box.route.verifyAttachment(returned) == nil)

    #expect(model.mutate(to: 7) == .dirtied)
    #expect(box.route.isDirty)
    #expect(box.route.requester.requestCount == 1)

    #expect(model.mutate(to: 7) == nil)
    #expect(box.route.requester.requestCount == 1)
}

@Test
func registrationRetainsNoCallableSinkOrReportHistory() {
    let sourceShape = MemoryLayout<
        ObservableStateRegistrationLifecycle
    >.size
    #expect(sourceShape <= 16)

    let attachment = _GiftUIObservationAttachment(slot: 4, generation: 33)
    var route = ObservableStateReportRoute(
        attachment: attachment,
        requester: ReportWakeRequester()
    )!
    #expect(
        route.acceptReport(attachment: attachment, phase: .mutating)
            == ObservableStateReportDisposition(.staleAttachment)
    )
    #expect(route.verifyAttachment(attachment) == .staleAttachment)
    #expect(!route.isActive)
}
