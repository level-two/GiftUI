import GiftUI

public extension TextRun {
    /// Creates a render text run from unbounded, heap-backed string storage.
    init(_ content: String, color: Color = .white) {
        self.init(dynamic: content, color: color)
    }
}
