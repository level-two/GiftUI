import GiftUI

@testable import GiftUIInteraction

enum RecordingActionNormalizationResult: Equatable {
    case normalized(BoundedApplicationAction)
    case failure(InteractionError)
}

enum RecordingActionNormalizer<Handler: GiftUIActionHandler> {
    static func normalize<Action: GiftUIAction>(
        _ action: borrowing Action
    ) -> RecordingActionNormalizationResult {
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

struct RecordingActionValidationCoordinator<Handler: GiftUIActionHandler> {
    private(set) var appendCount = 0
    private(set) var offerCount = 0
    private(set) var discardCount = 0

    mutating func validateAndAppend<Action: GiftUIAction>(
        _ action: borrowing Action
    ) -> RecordingActionNormalizationResult {
        switch RecordingActionNormalizer<Handler>.normalize(action) {
        case .normalized(let bounded):
            appendCount += 1
            offerCount += 1
            return .normalized(bounded)
        case .failure(let error):
            discardCount += 1
            return .failure(error)
        }
    }
}
