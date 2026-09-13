import Testing

@testable import GiftUIHostConfiguration

@Test func exactActionModelInputAndWakeProjectionsPass() {
    var validator = makeValidHostValidator()
    guard case .valid = validator.validate() else {
        Issue.record("exact application projections must validate")
        return
    }
}

@Test func everyActionDomainProjectionFailsAtTheActionModelStage() {
    let variants = [
        makeHostActionModelFixture(firstActionCode: 1),
        makeHostActionModelFixture(lastActionCode: 6),
        makeHostActionModelFixture(handlerCount: 0),
        makeHostActionModelFixture(handlerCount: 2),
        makeHostActionModelFixture(maximumNonTransitionPublicationsPerAction: 0),
        makeHostActionModelFixture(maximumNonTransitionPublicationsPerAction: 2),
    ]
    for variant in variants {
        var validator = makeValidHostValidator(actionAndModel: variant)
        #expect(
            validator.validate()
                == .invalid(
                    stage: .actionAndModel,
                    error: .invalidActionDomain
                )
        )
    }
}

@Test func invalidRootModelCardinalityPreservesItsDistinctError() {
    for count in [UInt8(0), UInt8(2)] {
        var validator = makeValidHostValidator(
            actionAndModel: makeHostActionModelFixture(
                rootModelTargetCount: count
            )
        )
        #expect(
            validator.validate()
                == .invalid(
                    stage: .actionAndModel,
                    error: .invalidModelTarget
                )
        )
    }
}

@Test func everyInputProjectionFailsAtTheInputWakeStage() {
    let variants = [
        makeHostInputWakeFixture(normalizedInputSourceCount: 0),
        makeHostInputWakeFixture(normalizedInputSourceCount: 2),
        makeHostInputWakeFixture(targetLocalPresentationGateCount: 0),
        makeHostInputWakeFixture(targetLocalPresentationGateCount: 2),
    ]
    for variant in variants {
        var validator = makeValidHostValidator(inputAndWake: variant)
        #expect(
            validator.validate()
                == .invalid(
                    stage: .inputAndWake,
                    error: .invalidInputIntegration
                )
        )
    }
}

@Test func everyWakeProjectionFailsAtTheInputWakeStage() {
    let variants = [
        makeHostInputWakeFixture(wakeRequesterCount: 0),
        makeHostInputWakeFixture(wakeRequesterCount: 2),
        makeHostInputWakeFixture(applicationAndMutationDomainsAreDistinct: false),
        makeHostInputWakeFixture(wakeRequesterIsNonReentrant: false),
    ]
    for variant in variants {
        var validator = makeValidHostValidator(inputAndWake: variant)
        #expect(
            validator.validate()
                == .invalid(
                    stage: .inputAndWake,
                    error: .invalidWakeIntegration
                )
        )
    }
}
