import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIObservableState

private struct FixtureStructuralIdentity: Equatable, Sendable {
    let component: UInt16
    let role: UInt16
}

private struct FixtureModel: _GiftUIObservableReference {
    var token: UInt16

    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}

private struct FixtureReconciler: ObservableStateReconciler {
    var lastIdentity: FixtureStructuralIdentity?
    var lastOrdinal: UInt16?
    var finishDisposition: ObservableStateCandidateDisposition?

    mutating func beginCandidate() -> ObservableStateResult {
        .success(.candidateStarted)
    }

    mutating func encounter<Model: _GiftUIObservableReference>(
        structuralIdentity: FixtureStructuralIdentity,
        declarationOrdinal: UInt16,
        state: inout State<Model>
    ) -> ObservableStateResult {
        lastIdentity = structuralIdentity
        lastOrdinal = declarationOrdinal
        return .success(.preserved)
    }

    mutating func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition
    ) -> ObservableStateResult {
        finishDisposition = disposition
        return disposition == .publish
            ? .success(.associationsCommitted)
            : .success(.candidateDiscarded)
    }
}

private struct FixtureMutationOwner: ObservableStateMutationOwner {
    var lastIdentity: FixtureStructuralIdentity?
    var lastOrdinal: UInt16?
    var lastAttachment: _GiftUIObservationAttachment?

    mutating func replace<Model: _GiftUIObservableReference>(
        structuralIdentity: FixtureStructuralIdentity,
        declarationOrdinal: UInt16,
        with candidate: consuming Model
    ) -> ObservableStateResult {
        lastIdentity = structuralIdentity
        lastOrdinal = declarationOrdinal
        return .success(.replaced)
    }

    mutating func acceptReport(
        attachment: _GiftUIObservationAttachment
    ) -> ObservableStateResult {
        lastAttachment = attachment
        return .success(.dirtied)
    }
}

private struct FixtureTargetView: ObservableStateTargetView {
    let liveIdentity: FixtureStructuralIdentity
    let liveOrdinal: UInt16
    let liveGeneration: ObservableTargetGeneration
    let candidateIdentity: FixtureStructuralIdentity
    let candidateOrdinal: UInt16
    let candidateGeneration: ObservableTargetGeneration

    func targetGeneration(
        structuralIdentity: FixtureStructuralIdentity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        structuralIdentity == liveIdentity && declarationOrdinal == liveOrdinal
            ? liveGeneration
            : nil
    }

    func publishableTargetGeneration(
        structuralIdentity: FixtureStructuralIdentity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        structuralIdentity == candidateIdentity && declarationOrdinal == candidateOrdinal
            ? candidateGeneration
            : nil
    }
}

private struct FixtureLiveLocationFields: Equatable, Sendable {
    let structuralIdentity: FixtureStructuralIdentity
    let declarationOrdinal: UInt16
    let modelDiscriminator: UInt16
    let attachmentSlot: UInt16
    let generation: UInt32
    let isDirty: Bool
    let isRemovalStaged: Bool
}

private struct FixtureRegistrationFields: Equatable, Sendable {
    let isOccupied: Bool
    let slot: UInt16
    let generation: UInt32
    let ownerIdentity: FixtureStructuralIdentity
    let ownerOrdinal: UInt16
    let routeState: UInt8
}

private struct FixtureCandidateAssociationFields: Equatable, Sendable {
    let structuralIdentity: FixtureStructuralIdentity
    let declarationOrdinal: UInt16
    let isEncountered: Bool
    let isCandidateOnly: Bool
    let publishableGeneration: UInt32
    let pendingChange: UInt8
}

private struct FixtureReplacementFields: Equatable, Sendable {
    let structuralIdentity: FixtureStructuralIdentity
    let declarationOrdinal: UInt16
    let candidateModelToken: UInt16
    let attachmentSlot: UInt16
    let generation: UInt32
    let verificationState: UInt8
}

private struct FixtureRuntimeBookkeeping: Equatable, Sendable {
    let nextGeneration: UInt32?
    let candidateState: UInt8
    let firstMutationFailure: ObservableStateError?
}

@Test
func reconcilerPreservesTypedStructuralIdentityAndExactResults() {
    let identity = FixtureStructuralIdentity(component: 3, role: 5)
    var reconciler = FixtureReconciler()
    var state = State(wrappedValue: FixtureModel(token: 8))

    #expect(reconciler.beginCandidate() == .success(.candidateStarted))
    #expect(
        reconciler.encounter(
            structuralIdentity: identity,
            declarationOrdinal: 13,
            state: &state
        ) == .success(.preserved)
    )
    #expect(reconciler.lastIdentity == identity)
    #expect(reconciler.lastOrdinal == 13)
    #expect(reconciler.finishCandidate(.discard) == .success(.candidateDiscarded))
    #expect(reconciler.finishDisposition == .discard)
}

@Test
func mutationOwnerKeepsReplacementAndReportOperationsDistinct() {
    let identity = FixtureStructuralIdentity(component: 21, role: 34)
    var owner = FixtureMutationOwner()
    #expect(
        owner.replace(
            structuralIdentity: identity,
            declarationOrdinal: 55,
            with: FixtureModel(token: 89)
        ) == .success(.replaced)
    )
    #expect(owner.lastIdentity == identity)
    #expect(owner.lastOrdinal == 55)

    let attachment = _GiftUIObservationAttachment(slot: 1, generation: 2)
    #expect(owner.acceptReport(attachment: attachment) == .success(.dirtied))
    #expect(owner.lastAttachment == attachment)
}

@Test
func targetViewReturnsOnlyOpaqueGenerationsForExactKeys() {
    let liveIdentity = FixtureStructuralIdentity(component: 1, role: 2)
    let candidateIdentity = FixtureStructuralIdentity(component: 3, role: 4)
    let liveGeneration = ObservableTargetGeneration(rawValue: 5)
    let candidateGeneration = ObservableTargetGeneration(rawValue: 6)
    let view = FixtureTargetView(
        liveIdentity: liveIdentity,
        liveOrdinal: 7,
        liveGeneration: liveGeneration,
        candidateIdentity: candidateIdentity,
        candidateOrdinal: 8,
        candidateGeneration: candidateGeneration
    )

    #expect(
        view.targetGeneration(structuralIdentity: liveIdentity, declarationOrdinal: 7)
            == liveGeneration)
    #expect(view.targetGeneration(structuralIdentity: liveIdentity, declarationOrdinal: 8) == nil)
    #expect(
        view.publishableTargetGeneration(
            structuralIdentity: candidateIdentity,
            declarationOrdinal: 8
        ) == candidateGeneration
    )
    #expect(
        view.publishableTargetGeneration(
            structuralIdentity: candidateIdentity,
            declarationOrdinal: 7
        ) == nil
    )
}

@Test
func fixtureAccountsForEveryLogicalStorageFamilyIndependently() {
    let identity = FixtureStructuralIdentity(component: 1, role: 1)
    let live = FixtureLiveLocationFields(
        structuralIdentity: identity,
        declarationOrdinal: 0,
        modelDiscriminator: 2,
        attachmentSlot: 0,
        generation: 3,
        isDirty: false,
        isRemovalStaged: false
    )
    let registration = FixtureRegistrationFields(
        isOccupied: true,
        slot: 0,
        generation: 3,
        ownerIdentity: identity,
        ownerOrdinal: 0,
        routeState: 1
    )
    let association = FixtureCandidateAssociationFields(
        structuralIdentity: identity,
        declarationOrdinal: 0,
        isEncountered: true,
        isCandidateOnly: false,
        publishableGeneration: 3,
        pendingChange: 0
    )
    let replacement = FixtureReplacementFields(
        structuralIdentity: identity,
        declarationOrdinal: 0,
        candidateModelToken: 5,
        attachmentSlot: 1,
        generation: 4,
        verificationState: 1
    )
    let bookkeeping = FixtureRuntimeBookkeeping(
        nextGeneration: 5,
        candidateState: 1,
        firstMutationFailure: nil
    )

    #expect(live.generation == registration.generation)
    #expect(association.publishableGeneration == live.generation)
    #expect(replacement.generation != live.generation)
    #expect(bookkeeping.nextGeneration == 5)
    #expect(MemoryLayout<FixtureReplacementFields>.size > 0)
    #expect(MemoryLayout<FixtureRegistrationFields>.size > 0)
}
