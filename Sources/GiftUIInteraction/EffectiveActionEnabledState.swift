import GiftUI

package struct EffectiveActionEnabledState: Equatable, Sendable {
    package let isEnabled: Bool

    package init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    package func applying(_ payload: borrowing DisabledSemanticPayload)
        -> EffectiveActionEnabledState
    {
        EffectiveActionEnabledState(
            isEnabled: isEnabled && !payload.isDisabled
        )
    }
}
