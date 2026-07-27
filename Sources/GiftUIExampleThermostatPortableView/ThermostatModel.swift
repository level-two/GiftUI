import GiftUI

public enum ThermostatAction {
    public static let decrement = ActionID(rawValue: 0)
    public static let increment = ActionID(rawValue: 1)
}

/// The first static-profile state layout is application-specific and typed.
/// Generated/fixed `@State` slots can replace it without changing the view's
/// portable text or action declarations.
public struct ThermostatModel: Equatable, Sendable {
    public private(set) var target: Int

    public init(target: Int = 21) {
        self.target = target
    }

    @discardableResult
    public mutating func dispatch(_ action: ActionID) -> Bool {
        switch action {
        case ThermostatAction.decrement:
            target -= 1
        case ThermostatAction.increment:
            target += 1
        default:
            return false
        }
        return true
    }
}
