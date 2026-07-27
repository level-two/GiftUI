import GiftUI

public extension Text {
    /// Creates text from an unbounded, heap-backed string.
    init(_ content: String) {
        self.init(dynamicContent: content)
    }
}
