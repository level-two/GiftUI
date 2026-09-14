import GiftUI
import GiftUIExecution
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeDynamic
@testable import GiftUIRuntimeStatic

private final class DynamicProfileRegistrationModel: _GiftUIObservableReference {
    let identity: UInt8
    var reportDuringAttach = false
    private var sink: _GiftUIObservableChangeSink?

    init(identity: UInt8) {
        self.identity = identity
    }

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        var installed = consume sink
        let attachment = installed.attachment
        if reportDuringAttach { _ = installed.reportChange() }
        self.sink = consume installed
        return attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        sink = nil
    }

    func report() -> _GiftUIObservableChangeReportOutcome? {
        sink?.reportChange()
    }
}

private struct StaticProfileRegistrationModel: _GiftUIObservableReference {
    let identity: UInt8
    let reportDuringAttach: Bool

    init(identity: UInt8, reportDuringAttach: Bool = false) {
        self.identity = identity
        self.reportDuringAttach = reportDuringAttach
    }

    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        var installed = consume sink
        let attachment = installed.attachment
        if reportDuringAttach { _ = installed.reportChange() }
        return attachment
    }

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}

private struct ProductionRegistrationTranscript: Equatable {
    let initialResult: ObservableStateResult
    let firstReport: _GiftUIObservableChangeReportOutcome?
    let secondReport: _GiftUIObservableChangeReportOutcome?
    let replacementResult: ObservableStateResult
    let replacementReport: _GiftUIObservableChangeReportOutcome?
    let failedReplacementResult: ObservableStateResult
    let liveIdentity: UInt8?
    let isActive: Bool
    let isDirty: Bool
}

private func dynamicRegistrationTranscript() -> ProductionRegistrationTranscript {
    let initial = DynamicProfileRegistrationModel(identity: 1)
    let replacement = DynamicProfileRegistrationModel(identity: 2)
    let poisoned = DynamicProfileRegistrationModel(identity: 3)
    poisoned.reportDuringAttach = true
    let registration =
        DynamicObservableModelRegistration<DynamicProfileRegistrationModel>()
    var state = State(wrappedValue: initial)
    let initialResult = registration.bind(
        &state,
        generation: 0,
        replacementRoute: { _ in }
    )
    registration.setExecutionPhase(.mutating)
    let firstReport = initial.report()
    let secondReport = initial.report()
    let replacementResult = registration.replace(
        with: replacement,
        generation: ObservableTargetGeneration(rawValue: 1)
    )
    let replacementReport = replacement.report()
    let failedReplacementResult = registration.replace(
        with: poisoned,
        generation: ObservableTargetGeneration(rawValue: 2)
    )
    return ProductionRegistrationTranscript(
        initialResult: initialResult,
        firstReport: firstReport,
        secondReport: secondReport,
        replacementResult: replacementResult,
        replacementReport: replacementReport,
        failedReplacementResult: failedReplacementResult,
        liveIdentity: registration.withModel { $0.identity },
        isActive: registration.isActive,
        isDirty: registration.isDirty
    )
}

private func staticRegistrationTranscript() -> ProductionRegistrationTranscript {
    var record = StaticObservableRegistrationRecord()
    var storage = StaticObservableModelStorage<StaticProfileRegistrationModel>()
    _ = storage.withBoundState(
        State(wrappedValue: StaticProfileRegistrationModel(identity: 1)),
        replacementRoute: { _ in },
        body: { _ in () }
    )
    let initialFailure = record.beginAttachment(generation: 0)
    guard
        let initialSink = record.makeSink(reportRoute: { reported in
            record.acceptReport(reported)
        })
    else {
        Issue.record("Static profile did not issue the initial sink")
        return failedStaticRegistrationTranscript()
    }
    let initialAttachment = storage.attachChangeSink(consume initialSink)
    let initialReturnFailure = record.acceptAttachmentReturn(initialAttachment)
    let initialResult: ObservableStateResult
    if let failure = initialFailure ?? initialReturnFailure {
        initialResult = .failure(failure)
    } else {
        initialResult = .success(.materialized)
    }
    record.setExecutionPhase(.mutating)
    let firstReport = initialAttachment.map { record.acceptReport($0) }
    let secondReport = initialAttachment.map { record.acceptReport($0) }

    var replacementResult: ObservableStateResult = .failure(.invariantViolation)
    firstReplacement: do {
        if let failure = record.beginReplacement(
            generation: ObservableTargetGeneration(rawValue: 1)
        ) {
            replacementResult = .failure(failure)
            break firstReplacement
        }
        guard
            storage.stageReplacement(
                StaticProfileRegistrationModel(identity: 2)
            ),
            let sink = record.makeReplacementSink(reportRoute: { reported in
                record.acceptReport(reported)
            })
        else {
            _ = record.discardReplacement()
            storage.discardReplacement()
            break firstReplacement
        }
        let returned = storage.attachCandidateChangeSink(consume sink)
        if let failure = record.acceptReplacementAttachmentReturn(returned) {
            let discarded = record.discardReplacement()
            if let discarded {
                _ = storage.detachCandidateChangeSink(discarded)
            }
            storage.discardReplacement()
            replacementResult = .failure(failure)
            break firstReplacement
        }
        guard case .success(let commit) = record.commitReplacement() else {
            _ = record.discardReplacement()
            storage.discardReplacement()
            break firstReplacement
        }
        _ = storage.detachChangeSink(commit.formerAttachment)
        guard storage.commitReplacement() != nil else {
            break firstReplacement
        }
        replacementResult = .success(.replaced)
    }
    let replacementAttachment = _GiftUIObservationAttachment(
        slot: 0,
        generation: 1
    )
    let replacementReport = record.acceptReport(replacementAttachment)
    var failedReplacementResult: ObservableStateResult = .failure(
        .invariantViolation
    )
    poisonedReplacement: do {
        if let failure = record.beginReplacement(
            generation: ObservableTargetGeneration(rawValue: 2)
        ) {
            failedReplacementResult = .failure(failure)
            break poisonedReplacement
        }
        guard
            storage.stageReplacement(
                StaticProfileRegistrationModel(
                    identity: 3,
                    reportDuringAttach: true
                )
            ),
            let sink = record.makeReplacementSink(reportRoute: { reported in
                record.acceptReport(reported)
            })
        else {
            _ = record.discardReplacement()
            storage.discardReplacement()
            break poisonedReplacement
        }
        let returned = storage.attachCandidateChangeSink(consume sink)
        let failure = record.acceptReplacementAttachmentReturn(returned)
        let discarded = record.discardReplacement()
        if let discarded {
            _ = storage.detachCandidateChangeSink(discarded)
        }
        storage.discardReplacement()
        if let failure {
            failedReplacementResult = .failure(failure)
        }
    }

    return ProductionRegistrationTranscript(
        initialResult: initialResult,
        firstReport: firstReport,
        secondReport: secondReport,
        replacementResult: replacementResult,
        replacementReport: replacementReport,
        failedReplacementResult: failedReplacementResult,
        liveIdentity: storage.withModel { $0.identity },
        isActive: record.isActive,
        isDirty: record.isDirty
    )
}

private func failedStaticRegistrationTranscript()
    -> ProductionRegistrationTranscript
{
    ProductionRegistrationTranscript(
        initialResult: .failure(.invariantViolation),
        firstReport: nil,
        secondReport: nil,
        replacementResult: .failure(.invariantViolation),
        replacementReport: nil,
        failedReplacementResult: .failure(.invariantViolation),
        liveIdentity: nil,
        isActive: false,
        isDirty: false
    )
}

@Test func productionObservableRegistrationsHaveEqualReplacementTranscripts() {
    let dynamic = dynamicRegistrationTranscript()
    let fixed = staticRegistrationTranscript()

    #expect(dynamic == fixed)
    #expect(dynamic.initialResult == .success(.materialized))
    #expect(dynamic.firstReport == .dirtied)
    #expect(dynamic.secondReport == .coalesced)
    #expect(dynamic.replacementResult == .success(.replaced))
    #expect(dynamic.replacementReport == .coalesced)
    #expect(dynamic.failedReplacementResult == .failure(.staleAttachment))
    #expect(dynamic.liveIdentity == 2)
    #expect(dynamic.isActive)
    #expect(dynamic.isDirty)
}
