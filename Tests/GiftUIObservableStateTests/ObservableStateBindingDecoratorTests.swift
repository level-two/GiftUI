import GiftUI
import Testing

@testable import GiftUIObservableState

private final class FixtureBoundModel: _GiftUIObservableReference {
    var value: UInt16

    init(value: UInt16) {
        self.value = value
    }

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}

private final class FixtureModelBox<Model> {
    var model: Model?
}

@ObservableStateHost
private struct FixtureStatefulHost: View {
    @State private var first = FixtureBoundModel(value: 3)
    @State private var second = FixtureBoundModel(value: 5)

    var body: EmptyView {
        EmptyView()
    }

    func values() -> (UInt16, UInt16) {
        (first.value, second.value)
    }
}

private struct FixtureBindingReconciler: ObservableStateReconciler {
    typealias StructuralIdentity = UInt16

    var ordinals: [UInt16] = []
    var identities: [UInt16] = []
    var failureOrdinal: UInt16?
    var failure: ObservableStateError = .incompatibleAssociation
    var success: ObservableStateOperational = .preserved

    mutating func beginCandidate() -> ObservableStateResult {
        .success(.candidateStarted)
    }

    mutating func encounter<Model: _GiftUIObservableReference>(
        structuralIdentity: UInt16,
        declarationOrdinal: UInt16,
        state: inout State<Model>
    ) -> ObservableStateResult {
        ordinals.append(declarationOrdinal)
        identities.append(structuralIdentity)
        if failureOrdinal == declarationOrdinal {
            return .failure(failure)
        }

        let box = FixtureModelBox<Model>()
        guard
            let initial = state._giftUIBind(
                read: { box.model! },
                replace: { box.model = $0 }
            )
        else {
            return .failure(.invariantViolation)
        }
        box.model = initial
        return .success(success)
    }

    mutating func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition
    ) -> ObservableStateResult {
        disposition == .publish
            ? .success(.associationsCommitted)
            : .success(.candidateDiscarded)
    }
}

@Test
func decoratorBindsLexicallyOnOneTransientCopyBeforeOneBodyCall() {
    let original = FixtureStatefulHost()
    var decorator = ObservableStateBindingDecorator(
        reconciler: FixtureBindingReconciler()
    )
    var bodyCalls: UInt16 = 0
    var observedValues: (UInt16, UInt16)?

    let result = decorator.withBoundDeclaration(
        original,
        structuralIdentity: 13
    ) { declaration in
        bodyCalls += 1
        observedValues = declaration.values()
    }

    #expect(result == .success(.unchanged))
    #expect(decorator.reconciler.ordinals == [0, 1])
    #expect(decorator.reconciler.identities == [13, 13])
    #expect(bodyCalls == 1)
    #expect(observedValues?.0 == 3)
    #expect(observedValues?.1 == 5)
}

@Test
func decoratorAcceptsBothExactEncounterSuccesses() {
    for success in [ObservableStateOperational.materialized, .preserved] {
        var decorator = ObservableStateBindingDecorator(
            reconciler: FixtureBindingReconciler(success: success)
        )
        var bodyCalls: UInt16 = 0

        #expect(
            decorator.withBoundDeclaration(
                FixtureStatefulHost(),
                structuralIdentity: 21
            ) { _ in
                bodyCalls += 1
            } == .success(.unchanged)
        )
        #expect(bodyCalls == 1)
    }
}

@Test
func decoratorStopsAtFirstBindingFailureAndSuppressesBody() {
    var decorator = ObservableStateBindingDecorator(
        reconciler: FixtureBindingReconciler(failureOrdinal: 0)
    )
    var bodyCalls: UInt16 = 0

    let result = decorator.withBoundDeclaration(
        FixtureStatefulHost(),
        structuralIdentity: 34
    ) { _ in
        bodyCalls += 1
    }

    #expect(result == .failure(.incompatibleAssociation))
    #expect(decorator.reconciler.ordinals == [0])
    #expect(bodyCalls == 0)
}

@Test
func decoratorPreservesLaterBindingFailureAndSuppressesBody() {
    var decorator = ObservableStateBindingDecorator(
        reconciler: FixtureBindingReconciler(failureOrdinal: 1)
    )
    var bodyCalls: UInt16 = 0

    let result = decorator.withBoundDeclaration(
        FixtureStatefulHost(),
        structuralIdentity: 55
    ) { _ in
        bodyCalls += 1
    }

    #expect(result == .failure(.incompatibleAssociation))
    #expect(decorator.reconciler.ordinals == [0, 1])
    #expect(bodyCalls == 0)
}

@Test
func decoratorSuppressesBodyForEveryCandidateBindingFailure() {
    let failures: [ObservableStateError] = [
        .locationCapacityExhausted,
        .registrationCapacityExhausted,
        .associationStagingCapacityExhausted,
        .duplicateOwner,
        .incompatibleAssociation,
        .staleAttachment,
        .invariantViolation,
    ]

    for failure in failures {
        var decorator = ObservableStateBindingDecorator(
            reconciler: FixtureBindingReconciler(
                failureOrdinal: 0,
                failure: failure
            )
        )
        var bodyCalls: UInt16 = 0

        #expect(
            decorator.withBoundDeclaration(
                FixtureStatefulHost(),
                structuralIdentity: 73
            ) { _ in
                bodyCalls += 1
            } == .failure(failure)
        )
        #expect(bodyCalls == 0)
    }
}

@Test
func unexpectedEncounterSuccessFailsClosedBeforeBody() {
    var decorator = ObservableStateBindingDecorator(
        reconciler: FixtureBindingReconciler(success: .coalesced)
    )
    var bodyCalls: UInt16 = 0

    let result = decorator.withBoundDeclaration(
        FixtureStatefulHost(),
        structuralIdentity: 89
    ) { _ in
        bodyCalls += 1
    }

    #expect(result == .failure(.invariantViolation))
    #expect(decorator.reconciler.ordinals == [0])
    #expect(bodyCalls == 0)
}
