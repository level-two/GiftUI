import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIRuntimeCore
import GiftUISemanticCore

package struct DynamicStructuralIdentity: Equatable, Hashable, Sendable {
    package let rawValue: UInt32

    package init?(rawValue: UInt32) {
        guard rawValue > 0 else { return nil }
        self.rawValue = rawValue
    }
}

package struct DynamicProfileConstruction: Equatable, Sendable {
    package let structuralIdentity: DynamicStructuralIdentity
    package let limits: RuntimeProfileLimits
    package let storageAudit: RuntimeStorageAudit

    package init?(
        structuralIdentity: DynamicStructuralIdentity,
        validation: RuntimeProfileValidationResult
    ) {
        guard case .valid(let audit) = validation,
            audit.profile == .dynamic,
            audit.limits.staticCanvas == nil
        else {
            return nil
        }
        self.structuralIdentity = structuralIdentity
        limits = audit.limits
        storageAudit = audit
    }
}
