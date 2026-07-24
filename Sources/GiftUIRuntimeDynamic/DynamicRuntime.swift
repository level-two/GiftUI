import GiftUI

@MainActor
public final class DynamicRuntime {
    public private(set) var isInvalid = true
    public lazy var state = DynamicStateStore { [weak self] in
        self?.invalidate()
    }

    public init() {}

    public func invalidate() {
        isInvalid = true
    }

    public func markRendered() {
        isInvalid = false
    }
}
