import GiftUI

package struct BoundedApplicationAction: Equatable, Hashable, Sendable {
    package let code: UInt16

    package init(code: UInt16) {
        self.code = code
    }
}

package enum InteractionActionNormalizationResult: Equatable, Sendable {
    case normalized(BoundedApplicationAction)
    case failure(InteractionError)
}

package enum InteractionActionNormalizer<Handler: GiftUIActionHandler> {
    package static func normalize<Action: GiftUIAction>(
        _ action: borrowing Action
    ) -> InteractionActionNormalizationResult {
        let value = copy action
        guard let typed = value as? Handler.Action else {
            return .failure(.incompatibleActionDomain)
        }
        guard Handler.Action(rawValue: typed.rawValue) == typed else {
            return .failure(.invalidActionValue)
        }
        return .normalized(BoundedApplicationAction(code: typed.rawValue))
    }
}
