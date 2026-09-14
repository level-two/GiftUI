import GiftUI
import Testing

@testable import GiftUIRuntimeStatic

private struct StaticStorageModel: _GiftUIObservableReference {
    let identity: UInt8
    var reportDuringAttach = false

    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        var offered = consume sink
        let attachment = offered.attachment
        if reportDuringAttach { _ = offered.reportChange() }
        return attachment
    }

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}

@Test func staticModelStorageMaterializesAttachesThenEvaluatesBoundBody() {
    var record = StaticObservableRegistrationRecord()
    var storage = StaticObservableModelStorage<StaticStorageModel>()
    #expect(record.beginAttachment(generation: 0) == nil)

    let result = storage.withMaterializedBoundState(
        State(wrappedValue: StaticStorageModel(identity: 4)),
        replacementRoute: { _ in },
        makeSink: {
            record.makeSink(reportRoute: { reported in
                record.acceptReport(reported)
            })
        },
        acceptAttachment: { record.acceptAttachmentReturn($0) },
        body: { state in
            #expect(record.isActive)
            return state.wrappedValue.identity
        }
    )
    guard case .bound(.materialized, let identity) = result else {
        Issue.record("static model did not complete materialized binding")
        return
    }
    #expect(identity == 4)
    #expect(record.isActive)
    #expect(storage.withModel { $0.identity } == 4)
}

@Test func staticModelStorageSuppressesBodyAndCleansPoisonedAttachment() {
    var record = StaticObservableRegistrationRecord()
    var storage = StaticObservableModelStorage<StaticStorageModel>()
    #expect(record.beginAttachment(generation: 1) == nil)
    var bodyWasEvaluated = false

    let result = storage.withMaterializedBoundState(
        State(
            wrappedValue: StaticStorageModel(
                identity: 5,
                reportDuringAttach: true
            )
        ),
        replacementRoute: { _ in },
        makeSink: {
            record.makeSink(reportRoute: { reported in
                record.acceptReport(reported)
            })
        },
        acceptAttachment: { record.acceptAttachmentReturn($0) },
        body: { _ in
            bodyWasEvaluated = true
        }
    )
    guard case .failure(let failure) = result else {
        Issue.record("poisoned static attachment unexpectedly evaluated")
        return
    }
    #expect(failure == .staleAttachment)
    #expect(!bodyWasEvaluated)
    #expect(!record.isActive)
    let isOccupied = storage.isOccupied
    #expect(!isOccupied)
}

@Test func staticModelStorageBindsAttemptLocallyAndPreservesFirstInitializer() {
    var storage = StaticObservableModelStorage<StaticStorageModel>()
    var routedReplacement: StaticStorageModel?

    let first = storage.withBoundState(
        State(wrappedValue: StaticStorageModel(identity: 1)),
        replacementRoute: { routedReplacement = $0 },
        body: { state in
            state.wrappedValue.identity
        }
    )
    guard case .bound(let firstOperation, let firstIdentity) = first else {
        Issue.record("first static binding failed")
        return
    }
    #expect(firstOperation == .materialized)
    #expect(firstIdentity == 1)
    let isOccupied = storage.isOccupied
    #expect(isOccupied)

    let repeated = storage.withBoundState(
        State(wrappedValue: StaticStorageModel(identity: 2)),
        replacementRoute: { routedReplacement = $0 },
        body: { state in
            let preservedIdentity = state.wrappedValue.identity
            state.wrappedValue = StaticStorageModel(identity: 3)
            return preservedIdentity
        }
    )
    guard case .bound(let repeatedOperation, let repeatedIdentity) = repeated else {
        Issue.record("repeated static binding failed")
        return
    }
    #expect(repeatedOperation == .preserved)
    #expect(repeatedIdentity == 1)
    #expect(routedReplacement?.identity == 3)
    #expect(storage.withModel { $0.identity } == 1)
}

@Test func staticModelStorageOwnsOnlyInlineTypedOptionalStorage() {
    #expect(
        MemoryLayout<StaticObservableModelStorage<StaticStorageModel>>.stride
            == MemoryLayout<(StaticStorageModel?, StaticStorageModel?)>.stride
    )
}

@Test func staticModelStorageStagesReplacementApartFromTheLiveModel() {
    var storage = StaticObservableModelStorage<StaticStorageModel>()
    _ = storage.withBoundState(
        State(wrappedValue: StaticStorageModel(identity: 1)),
        replacementRoute: { _ in },
        body: { _ in () }
    )

    let stagedFirst = storage.stageReplacement(StaticStorageModel(identity: 2))
    #expect(stagedFirst)
    let hasFirstCandidate = storage.hasStagedReplacement
    #expect(hasFirstCandidate)
    let stagedSecond = storage.stageReplacement(StaticStorageModel(identity: 3))
    #expect(!stagedSecond)
    #expect(storage.withModel { $0.identity } == 1)
    let former = storage.commitReplacement()
    #expect(former?.identity == 1)
    #expect(storage.withModel { $0.identity } == 2)
    let hasCommittedCandidate = storage.hasStagedReplacement
    #expect(!hasCommittedCandidate)

    let stagedDiscard = storage.stageReplacement(StaticStorageModel(identity: 4))
    #expect(stagedDiscard)
    let discarded = storage.discardReplacement()
    #expect(discarded?.identity == 4)
    #expect(storage.withModel { $0.identity } == 2)
}
