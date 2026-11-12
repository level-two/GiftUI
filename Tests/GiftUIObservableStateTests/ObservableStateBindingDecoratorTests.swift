import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIObservableState

private struct FixtureBoundSeed {
    let value: UInt16
}

private enum FixtureBoundSchema: _GiftUIModelSchema {
    typealias Seed = FixtureBoundSeed
}

private struct FixtureBoundModel: ~Copyable, ObservableStateModel {
    typealias Schema = FixtureBoundSchema

    private var sink: _GiftUIObservableChangeSink?

    static func materialize(_ seed: FixtureBoundSeed) -> Self {
        Self(value: seed.value, sink: nil)
    }

    let value: UInt16

    var isEmptyReplacement: Bool { false }

    mutating func attach(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        let attachment = sink.attachment
        self.sink = consume sink
        return attachment
    }

    mutating func detach(_ attachment: _GiftUIObservationAttachment) -> Bool {
        guard sink?.attachment == attachment else { return false }
        sink = nil
        return true
    }

    mutating func reportChange() -> _GiftUIObservableChangeReportOutcome {
        sink?.reportChange() ?? .coalesced
    }
}

private enum FixtureBoundDomain: _GiftUIReadDomain {
    typealias Slot = UInt8
}

@ObservableStateHost
private struct FixtureStatefulHost: View {
    typealias Domain = FixtureBoundDomain

    @State<FixtureBoundSchema> private var first: _GiftUIModelKey<FixtureBoundSchema>?
    @State<FixtureBoundSchema> private var second: _GiftUIModelKey<FixtureBoundSchema>?

    init() {
        _first = State<FixtureBoundSchema>(seed: FixtureBoundSeed(value: 3))
        _second = State<FixtureBoundSchema>(seed: FixtureBoundSeed(value: 5))
    }

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> EmptyView<Domain>
    {
        EmptyView()
    }
}

private func withFixtureRoot<Result>(
    modelLimit: UInt16,
    _ body: (
        borrowing ObservableModelScope<FixtureBoundModel, FixtureBoundSchema>,
        borrowing ObservableStateRootScope<FixtureBoundModel, UInt16>
    ) throws(ObservableStateError) -> Result
) throws(ObservableStateError) -> Result {
    var namespace = ObservableModelOwnerNamespace()
    guard
        var ownership = ObservableModelOwnership(
            identity: try namespace.issue(), modelLimit: modelLimit, captureLimit: 0
        )
    else { throw .ownerCapacityExhausted }

    var backing = InlineArray<2, FixtureBoundModel?>.init { _ in nil }
    var models = backing.mutableSpan
    return try withObservableModelScope(
        ownership: &ownership, models: &models, schema: 7, needsCapture: false
    ) { scope in
        var rootStorage = ObservableStateRootStorage<UInt16>()
        return try scope.withRoot(storage: &rootStorage) { root in
            try body(scope, root)
        }
    }
}

@Test
func scopedRootBindsEveryDeclarationBeforeCallingTheBody() throws {
    var bodyCalls = 0
    try withFixtureRoot(modelLimit: 2) { scope, root in
        try scope.withFrame {
            try scope.withDiscovery {
                #expect(root.beginCandidate() == .success(.candidateStarted))
            }
            let result = try root.withBoundDeclaration(
                FixtureStatefulHost(), identity: 13
            ) { _ in
                bodyCalls += 1
                return true
            }
            #expect(result)
            try scope.withDiscovery {
                #expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
            }
        }
    }
    #expect(bodyCalls == 1)
}

@Test
func capacityBindingFailureSuppressesBodyAndDiscardsCandidate() throws {
    var bodyCalls = 0
    try withFixtureRoot(modelLimit: 1) { scope, root in
        try scope.withFrame {
            try scope.withDiscovery {
                #expect(root.beginCandidate() == .success(.candidateStarted))
            }
            do {
                _ = try root.withBoundDeclaration(
                    FixtureStatefulHost(), identity: 21
                ) { _ in
                    bodyCalls += 1
                    return true
                }
                Issue.record("the second declaration should exceed the model limit")
            } catch {
                #expect(error == .modelCapacityExhausted)
            }
            #expect(bodyCalls == 0)
            try scope.withDiscovery {
                #expect(root.finishCandidate(.discard) == .success(.candidateDiscarded))
            }
        }
    }
    #expect(bodyCalls == 0)
}
