import GiftUIFailureCore
import GiftUIInteraction

package struct InteractionFailureEffectState: Equatable, Sendable {
    package fileprivate(set) var committedStateToken: UInt32
    package fileprivate(set) var candidateDiscardCount: UInt8
    package fileprivate(set) var captureCancellationCount: UInt8
    package fileprivate(set) var isDirty: Bool
    package fileprivate(set) var wakeRequestCount: UInt8
    package fileprivate(set) var normalCyclePermitted: Bool
    package fileprivate(set) var isQuiesced: Bool

    package init(committedStateToken: UInt32) {
        self.committedStateToken = committedStateToken
        candidateDiscardCount = 0
        captureCancellationCount = 0
        isDirty = false
        wakeRequestCount = 0
        normalCyclePermitted = true
        isQuiesced = false
    }
}

package struct InteractionMandatoryEffectResult: Equatable, Sendable {
    package let allowedDispositions: GiftUIAllowedDispositions
    package let mandatoryEffectsComplete: Bool
    package let fatalHookEligible: Bool
}

package enum InteractionFailureContainment {
    package static func apply(
        _ error: InteractionError,
        mutationAlreadyOccurred: Bool,
        to state: inout InteractionFailureEffectState
    ) -> InteractionMandatoryEffectResult {
        state.candidateDiscardCount = incremented(state.candidateDiscardCount)

        switch error {
        case .capacityExhausted, .invalidIdentity, .invalidGeometry,
            .incompatibleActionDomain, .invalidActionValue, .missingModelTarget:
            if mutationAlreadyOccurred {
                state.isDirty = true
                if state.wakeRequestCount == 0 {
                    state.wakeRequestCount = 1
                }
            }
            return InteractionMandatoryEffectResult(
                allowedDispositions: .continueOperation,
                mandatoryEffectsComplete: true,
                fatalHookEligible: false
            )
        case .invalidPhase, .reentrancyViolation, .invariantViolation:
            state.captureCancellationCount = incremented(state.captureCancellationCount)
            state.normalCyclePermitted = false
            state.isQuiesced = true
            return InteractionMandatoryEffectResult(
                allowedDispositions: [.quiesceAffectedScope, .invokeFatalHook],
                mandatoryEffectsComplete: true,
                fatalHookEligible: state.isQuiesced
            )
        }
    }

    private static func incremented(_ value: UInt8) -> UInt8 {
        let next = value.addingReportingOverflow(1)
        return next.overflow ? .max : next.partialValue
    }
}
