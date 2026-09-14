import GiftUI
import GiftUIExecution
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeStatic

private struct StaticRegistrationModel: _GiftUIObservableReference {
    let identity: UInt8
    let reportDuringAttach: Bool
    private(set) var attachment: _GiftUIObservationAttachment?

    init(identity: UInt8 = 1, reportDuringAttach: Bool = false) {
        self.identity = identity
        self.reportDuringAttach = reportDuringAttach
    }

    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        var offered = consume sink
        let attachment = offered.attachment
        if reportDuringAttach {
            _ = offered.reportChange()
        }
        self.attachment = attachment
        return attachment
    }

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        guard self.attachment == attachment else { return }
        self.attachment = nil
    }
}

@Test func staticRegistrationRecordCommitsAndDiscardsTypedReplacement() {
    var record = StaticObservableRegistrationRecord()
    var storage = StaticObservableModelStorage<StaticRegistrationModel>()
    _ = storage.withBoundState(
        State(wrappedValue: StaticRegistrationModel(identity: 1)),
        replacementRoute: { _ in },
        body: { _ in () }
    )
    #expect(record.beginAttachment(generation: 0) == nil)
    guard
        let initialSink = record.makeSink(reportRoute: { reported in
            record.acceptReport(reported)
        })
    else {
        Issue.record("static registration did not issue its initial sink")
        return
    }
    let initialReturn = storage.attachChangeSink(consume initialSink)
    #expect(record.acceptAttachmentReturn(initialReturn) == nil)
    record.setExecutionPhase(.mutating)

    #expect(
        record.beginReplacement(
            generation: ObservableTargetGeneration(rawValue: 1)
        ) == nil
    )
    let didStageReplacement = storage.stageReplacement(
        StaticRegistrationModel(identity: 2)
    )
    #expect(didStageReplacement)
    guard
        let replacementSink = record.makeReplacementSink(reportRoute: {
            reported in
            record.acceptReport(reported)
        })
    else {
        Issue.record("static registration did not issue its replacement sink")
        return
    }
    let replacementReturn = storage.attachCandidateChangeSink(
        consume replacementSink
    )
    #expect(record.acceptReplacementAttachmentReturn(replacementReturn) == nil)
    guard case .success(let commit) = record.commitReplacement() else {
        Issue.record("static replacement did not commit")
        return
    }
    let didDetachFormer = storage.detachChangeSink(commit.formerAttachment)
    #expect(didDetachFormer)
    #expect(storage.commitReplacement()?.identity == 1)
    #expect(storage.withModel { $0.identity } == 2)
    #expect(record.isActive)
    #expect(record.isDirty)

    #expect(
        record.beginReplacement(
            generation: ObservableTargetGeneration(rawValue: 2)
        ) == nil
    )
    let didStagePoisoned = storage.stageReplacement(
        StaticRegistrationModel(identity: 3, reportDuringAttach: true)
    )
    #expect(didStagePoisoned)
    guard
        let poisonedSink = record.makeReplacementSink(reportRoute: { reported in
            record.acceptReport(reported)
        })
    else {
        Issue.record("static registration did not issue the poisoned sink")
        return
    }
    let poisonedReturn = storage.attachCandidateChangeSink(consume poisonedSink)
    #expect(
        record.acceptReplacementAttachmentReturn(poisonedReturn)
            == .staleAttachment
    )
    let discarded = record.discardReplacement()
    #expect(discarded == poisonedReturn)
    if let discarded {
        let didDetachCandidate = storage.detachCandidateChangeSink(discarded)
        #expect(didDetachCandidate)
    }
    #expect(storage.discardReplacement()?.identity == 3)
    #expect(storage.withModel { $0.identity } == 2)
    #expect(record.isActive)
    #expect(record.isDirty)
}

@Test func staticRegistrationRecordPreflightsReplacementWithoutMutation() {
    var record = StaticObservableRegistrationRecord()
    var storage = StaticObservableModelStorage<StaticRegistrationModel>()
    _ = storage.withBoundState(
        State(wrappedValue: StaticRegistrationModel()),
        replacementRoute: { _ in },
        body: { _ in () }
    )
    _ = record.beginAttachment(generation: 0)
    guard
        let sink = record.makeSink(reportRoute: { reported in
            record.acceptReport(reported)
        })
    else {
        Issue.record("static registration did not issue its initial sink")
        return
    }
    let returned = storage.attachChangeSink(consume sink)
    _ = record.acceptAttachmentReturn(returned)

    #expect(
        record.preflightReplacement(
            isCompatible: true,
            candidateAlreadyOwned: false,
            registrationCapacityAvailable: true,
            replacementStagingAvailable: true
        ) == .invalidPhaseContained
    )
    #expect(record.isActive)
    #expect(!record.isDirty)
    record.setExecutionPhase(.mutating)
    #expect(
        record.preflightReplacement(
            isCompatible: true,
            candidateAlreadyOwned: false,
            registrationCapacityAvailable: true,
            replacementStagingAvailable: true
        ) == nil
    )
}

@Test func staticRegistrationRecordOwnsDirectReportStateApartFromModelStorage() {
    var record = StaticObservableRegistrationRecord()
    var storage = StaticObservableModelStorage<StaticRegistrationModel>()
    let binding = storage.withBoundState(
        State(wrappedValue: StaticRegistrationModel()),
        replacementRoute: { _ in },
        body: { _ in () }
    )
    guard case .bound(.materialized, ()) = binding else {
        Issue.record("static model did not materialize")
        return
    }

    #expect(record.beginAttachment(generation: 0) == nil)
    guard
        let sink = record.makeSink(reportRoute: { reported in
            record.acceptReport(reported)
        })
    else {
        Issue.record("static registration did not issue a sink")
        return
    }
    let returned = storage.attachChangeSink(consume sink)
    #expect(record.acceptAttachmentReturn(returned) == nil)
    #expect(record.isActive)

    record.setExecutionPhase(.mutating)
    guard
        let storedAttachment = storage.withModel({ $0.attachment }),
        let attachment = storedAttachment
    else {
        Issue.record("static model did not retain its attachment")
        return
    }
    #expect(attachment == _GiftUIObservationAttachment(slot: 0, generation: 0))
    #expect(record.acceptReport(attachment) == .dirtied)
    #expect(record.acceptReport(attachment) == .coalesced)
    #expect(record.isDirty)

    #expect(record.retire() == nil)
    let didDetach = storage.detachChangeSink(attachment)
    #expect(didDetach)
    #expect(storage.removeModel() != nil)
    #expect(!record.isActive)
    #expect(!record.isDirty)
}

@Test func staticRegistrationRecordRejectsAttachTimeReportBeforeActivation() {
    var record = StaticObservableRegistrationRecord()
    var storage = StaticObservableModelStorage<StaticRegistrationModel>()
    _ = storage.withBoundState(
        State(wrappedValue: StaticRegistrationModel(reportDuringAttach: true)),
        replacementRoute: { _ in },
        body: { _ in () }
    )

    #expect(record.beginAttachment(generation: 4) == nil)
    guard
        let sink = record.makeSink(reportRoute: { reported in
            record.acceptReport(reported)
        })
    else {
        Issue.record("static registration did not issue a sink")
        return
    }
    let returned = storage.attachChangeSink(consume sink)
    #expect(record.acceptAttachmentReturn(returned) == .staleAttachment)
    #expect(!record.isActive)
    if let returned {
        let didDetach = storage.detachChangeSink(returned)
        #expect(didDetach)
    }
    #expect(storage.removeModel() != nil)
}
