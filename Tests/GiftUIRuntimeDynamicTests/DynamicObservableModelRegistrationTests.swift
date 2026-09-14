import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIRuntimeDynamic

private final class DynamicRegisteredModel: _GiftUIObservableReference {
    let identity: UInt8
    private var sink: _GiftUIObservableChangeSink?
    private(set) var detachments: [_GiftUIObservationAttachment] = []
    var reportDuringAttach = false

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
        detachments.append(attachment)
        sink = nil
    }

    func report() -> _GiftUIObservableChangeReportOutcome? {
        sink?.reportChange()
    }
}

@Test func dynamicRegistrationOwnsBindingReportsAndRetirement() {
    let initial = DynamicRegisteredModel(identity: 1)
    let registration = DynamicObservableModelRegistration<DynamicRegisteredModel>()
    var state = State(wrappedValue: initial)

    #expect(
        registration.bind(&state, generation: 0, replacementRoute: { _ in })
            == .success(.materialized)
    )
    #expect(registration.isActive)
    #expect(state.wrappedValue === initial)

    var repeated = State(wrappedValue: DynamicRegisteredModel(identity: 2))
    #expect(
        registration.bind(&repeated, generation: 99, replacementRoute: { _ in })
            == .success(.preserved)
    )
    #expect(repeated.wrappedValue === initial)

    registration.setExecutionPhase(.mutating)
    #expect(initial.report() == .dirtied)
    #expect(initial.report() == .coalesced)
    #expect(registration.isDirty)

    #expect(registration.retire() == .success(.associationsCommitted))
    #expect(!registration.isActive)
    #expect(!registration.isDirty)
    #expect(initial.detachments == [_GiftUIObservationAttachment(slot: 0, generation: 0)])
    #expect(registration.withModel { $0.identity } == nil)
}

@Test func dynamicRegistrationRejectsAndCleansUpAttachTimeReports() {
    let initial = DynamicRegisteredModel(identity: 3)
    initial.reportDuringAttach = true
    let registration = DynamicObservableModelRegistration<DynamicRegisteredModel>()
    var state = State(wrappedValue: initial)

    #expect(
        registration.bind(&state, generation: 7, replacementRoute: { _ in })
            == .failure(.staleAttachment)
    )
    #expect(!registration.isActive)
    #expect(initial.detachments == [_GiftUIObservationAttachment(slot: 0, generation: 7)])
    #expect(registration.withModel { $0.identity } == nil)
}

@Test func dynamicRegistrationCommitsReplacementOnlyAfterCandidateAttachment() {
    let initial = DynamicRegisteredModel(identity: 5)
    let replacement = DynamicRegisteredModel(identity: 6)
    let registration = DynamicObservableModelRegistration<DynamicRegisteredModel>()
    var state = State(wrappedValue: initial)
    _ = registration.bind(&state, generation: 0, replacementRoute: { _ in })
    registration.setExecutionPhase(.mutating)

    #expect(
        registration.replace(
            with: replacement,
            generation: ObservableTargetGeneration(rawValue: 1)
        ) == .success(.replaced)
    )
    #expect(registration.withModel { $0.identity } == 6)
    #expect(
        initial.detachments
            == [_GiftUIObservationAttachment(slot: 0, generation: 0)]
    )
    #expect(registration.isDirty)
    #expect(replacement.report() == .coalesced)
    #expect(registration.retire() == .success(.associationsCommitted))
    #expect(
        replacement.detachments
            == [_GiftUIObservationAttachment(slot: 0, generation: 1)]
    )
}

@Test func dynamicRegistrationDiscardsPoisonedReplacementAndPreservesLive() {
    let initial = DynamicRegisteredModel(identity: 7)
    let replacement = DynamicRegisteredModel(identity: 8)
    replacement.reportDuringAttach = true
    let registration = DynamicObservableModelRegistration<DynamicRegisteredModel>()
    var state = State(wrappedValue: initial)
    _ = registration.bind(&state, generation: 2, replacementRoute: { _ in })
    registration.setExecutionPhase(.mutating)

    #expect(
        registration.replace(
            with: replacement,
            generation: ObservableTargetGeneration(rawValue: 3)
        ) == .failure(.staleAttachment)
    )
    #expect(registration.withModel { $0.identity } == 7)
    #expect(initial.detachments.isEmpty)
    #expect(
        replacement.detachments
            == [_GiftUIObservationAttachment(slot: 0, generation: 3)]
    )
    #expect(initial.report() == .dirtied)
}
