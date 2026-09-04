import GiftUI

enum FixtureAction: UInt16, GiftUIAction {
    case minimum = 0
    case ordinary = 17
    case maximum = 65_535
}

func acceptActionDomain(_ action: FixtureAction) -> UInt16 {
    action.rawValue
}
