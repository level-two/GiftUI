import Testing

@testable import GiftUIHostConfiguration

@Test func hostAndStageRawValuesAreExact() {
    #expect(MVPHostKind.macOSDynamic.rawValue == 0)
    #expect(MVPHostKind.macOSStatic.rawValue == 1)
    #expect(MVPHostKind.raspberryPiDynamic.rawValue == 2)
    #expect(MVPHostKind.nrf52840Static.rawValue == 3)
    #expect(HostValidationStage.graph.rawValue == 0)
    #expect(HostValidationStage.policy.rawValue == 8)
    #expect(MVPHostLifecycleState.valid.rawValue == 0)
    #expect(MVPHostLifecycleState.quiescent.rawValue == 5)
}

@Test func componentRoleBitsAreExact() {
    for rawValue in UInt8(0) ... 17 {
        let role = HostComponentRole(rawValue: rawValue)
        #expect(role != nil)
        #expect(role.map(HostComponentRoleSet.init)?.rawValue == UInt32(1) << UInt32(rawValue))
    }
    #expect(HostComponentRole(rawValue: 18) == nil)
}

@Test func pacingRejectsZeroAndOverflowAndAcceptsPreset() {
    #expect(
        HostPacingPolicy(
            minimumFrameIntervalMicroseconds: 0,
            maximumFactServiceLatencyMicroseconds: 250_000,
            minimumAcceptedTransitionSpacingMicroseconds: 50_000,
            maximumTransitionFactsPerServiceWindow: 20,
            maximumBootstrapFactsPerServiceWindow: 2,
            maximumActionInducedFactsPerServiceWindow: 6,
            maximumRetryableRefusals: 3
        ) == nil
    )
    #expect(
        HostPacingPolicy(
            minimumFrameIntervalMicroseconds: 1,
            maximumFactServiceLatencyMicroseconds: 1,
            minimumAcceptedTransitionSpacingMicroseconds: 1,
            maximumTransitionFactsPerServiceWindow: .max,
            maximumBootstrapFactsPerServiceWindow: 1,
            maximumActionInducedFactsPerServiceWindow: 1,
            maximumRetryableRefusals: 1
        ) == nil
    )
    let preset = HostPacingPolicy(
        minimumFrameIntervalMicroseconds: 250_000,
        maximumFactServiceLatencyMicroseconds: 250_000,
        minimumAcceptedTransitionSpacingMicroseconds: 50_000,
        maximumTransitionFactsPerServiceWindow: 20,
        maximumBootstrapFactsPerServiceWindow: 2,
        maximumActionInducedFactsPerServiceWindow: 6,
        maximumRetryableRefusals: 3
    )
    #expect(preset != nil)
}

@Test func validationGuardRejectsEveryRepeatWithoutAdvancing() {
    var guardState = HostValidationStateGuard()
    #expect(guardState.begin() == nil)
    #expect(
        guardState.begin()
            == .invalid(stage: .graph, error: .invariantViolation)
    )
    #expect(
        guardState.begin()
            == .invalid(stage: .graph, error: .invariantViolation)
    )
}
