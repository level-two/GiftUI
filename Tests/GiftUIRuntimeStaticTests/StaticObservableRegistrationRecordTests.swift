import GiftUI
import GiftUIExecution
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeStatic

private enum StaticRegistrationSchema: _GiftUIModelSchema {
    struct Seed {
        let identity: UInt8
        var reportDuringAttach = false
    }
}

private struct StaticRegistrationModel: ObservableStateModel {
    typealias Schema = StaticRegistrationSchema

    let identity: UInt8
    let reportDuringAttach: Bool
    private(set) var attachment: _GiftUIObservationAttachment?

    init(identity: UInt8 = 1, reportDuringAttach: Bool = false) {
        self.identity = identity
        self.reportDuringAttach = reportDuringAttach
    }

    static func materialize(_ seed: Schema.Seed) -> Self {
        Self(identity: seed.identity, reportDuringAttach: seed.reportDuringAttach)
    }

    var isEmptyReplacement: Bool { false }

    mutating func attach(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        var sink = consume sink
        let attachment = sink.attachment
        if reportDuringAttach {
            _ = sink.reportChange()
        }
        self.attachment = attachment
        return attachment
    }

    mutating func detach(
        _ attachment: _GiftUIObservationAttachment
    ) -> Bool {
        guard self.attachment == attachment else { return false }
        self.attachment = nil
        return true
    }

    mutating func reportChange() -> _GiftUIObservableChangeReportOutcome {
        .dirtied
    }
}

private struct StaticRegistrationStorage {
    private(set) var model: StaticRegistrationModel?
    private(set) var candidate: StaticRegistrationModel?

    mutating func install(_ model: StaticRegistrationModel) {
        self.model = model
    }

    mutating func attachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        model?.attach(consume sink)
    }

    mutating func stageReplacement(_ model: StaticRegistrationModel) -> Bool {
        guard candidate == nil else { return false }
        candidate = model
        return true
    }

    mutating func attachCandidateChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        candidate?.attach(consume sink)
    }

    mutating func detachChangeSink(_ attachment: _GiftUIObservationAttachment) -> Bool {
        model?.detach(attachment) ?? false
    }

    mutating func detachCandidateChangeSink(_ attachment: _GiftUIObservationAttachment) -> Bool {
        candidate?.detach(attachment) ?? false
    }

    mutating func commitReplacement() -> StaticRegistrationModel? {
        let former = model
        model = candidate
        candidate = nil
        return former
    }

    mutating func discardReplacement() -> StaticRegistrationModel? {
        defer { candidate = nil }
        return candidate
    }

    borrowing func withModel<Result>(
        _ body: (borrowing StaticRegistrationModel) -> Result
    ) -> Result? {
        guard let model else { return nil }
        return body(model)
    }

    mutating func removeModel() -> StaticRegistrationModel? {
        defer { model = nil }
        return model
    }
}

private func staticRegistrationReport(
    context: UnsafeMutableRawPointer,
    slot: UInt16,
    generation: UInt32
) -> UInt8 {
    context.assumingMemoryBound(to: StaticObservableRegistrationRecord.self).pointee
        .acceptReport(.init(slot: slot, generation: generation)).rawValue
}

private func makeStaticRegistrationSink(
    record: inout StaticObservableRegistrationRecord
) -> _GiftUIObservableChangeSink? {
    withUnsafeMutablePointer(to: &record) { pointer in
        pointer.pointee.makeSink(
            context: UnsafeMutableRawPointer(pointer), reportRoute: staticRegistrationReport
        )
    }
}

private func makeStaticReplacementSink(
    record: inout StaticObservableRegistrationRecord
) -> _GiftUIObservableChangeSink? {
    withUnsafeMutablePointer(to: &record) { pointer in
        pointer.pointee.makeReplacementSink(
            context: UnsafeMutableRawPointer(pointer), reportRoute: staticRegistrationReport
        )
    }
}

@Test func staticRegistrationRecordCommitsAndDiscardsTypedReplacement() {
    var record = StaticObservableRegistrationRecord()
    var storage = StaticRegistrationStorage()
    storage.install(StaticRegistrationModel(identity: 1))
    #expect(record.beginAttachment(generation: 0) == nil)
    guard
        let initialSink = makeStaticRegistrationSink(record: &record)
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
        let replacementSink = makeStaticReplacementSink(record: &record)
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
        let poisonedSink = makeStaticReplacementSink(record: &record)
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
    var storage = StaticRegistrationStorage()
    storage.install(StaticRegistrationModel())
    _ = record.beginAttachment(generation: 0)
    guard
        let sink = makeStaticRegistrationSink(record: &record)
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

@Test func staticRegistrationRecordResetsReplacementStateForReinsertion() {
    var record = StaticObservableRegistrationRecord()
    var storage = StaticRegistrationStorage()
    storage.install(StaticRegistrationModel(identity: 1))
    _ = record.beginAttachment(generation: 0)
    guard
        let initialSink = makeStaticRegistrationSink(record: &record)
    else {
        Issue.record("static registration did not issue its initial sink")
        return
    }
    _ = record.acceptAttachmentReturn(
        storage.attachChangeSink(consume initialSink)
    )
    record.setExecutionPhase(.mutating)
    _ = record.beginReplacement(
        generation: ObservableTargetGeneration(rawValue: 1)
    )
    _ = storage.stageReplacement(StaticRegistrationModel(identity: 2))
    guard
        let replacementSink = makeStaticReplacementSink(record: &record)
    else {
        Issue.record("static registration did not issue its replacement sink")
        return
    }
    let replacementReturn = storage.attachCandidateChangeSink(
        consume replacementSink
    )
    _ = record.acceptReplacementAttachmentReturn(replacementReturn)
    guard case .success(let commit) = record.commitReplacement() else {
        Issue.record("static replacement did not commit")
        return
    }
    _ = storage.detachChangeSink(commit.formerAttachment)
    _ = storage.commitReplacement()

    #expect(record.retire() == nil)
    let didDetachReplacement = storage.detachChangeSink(commit.activeAttachment)
    #expect(didDetachReplacement)
    #expect(storage.removeModel()?.identity == 2)
    #expect(!record.isActive)

    storage.install(StaticRegistrationModel(identity: 3))
    #expect(record.beginAttachment(generation: 2) == nil)
    guard
        let reinsertedSink = makeStaticRegistrationSink(record: &record)
    else {
        Issue.record("static registration did not issue its reinserted sink")
        return
    }
    let reinsertedReturn = storage.attachChangeSink(consume reinsertedSink)
    #expect(record.acceptAttachmentReturn(reinsertedReturn) == nil)
    #expect(record.isActive)
    #expect(!record.isDirty)
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
    var storage = StaticRegistrationStorage(model: StaticRegistrationModel())

    #expect(record.beginAttachment(generation: 0) == nil)
    guard
        let sink = makeStaticRegistrationSink(record: &record)
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
    var storage = StaticRegistrationStorage()
    storage.install(StaticRegistrationModel(reportDuringAttach: true))

    #expect(record.beginAttachment(generation: 4) == nil)
    guard
        let sink = makeStaticRegistrationSink(record: &record)
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
