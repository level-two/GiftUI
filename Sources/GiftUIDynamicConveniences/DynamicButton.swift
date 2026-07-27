import GiftUI

public extension Button {
    /// Creates a callback-backed button for allocating runtimes.
    init(
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.init(dynamicAction: action, label: label)
    }
}

public extension Button where Label == Text {
    /// Creates a callback-backed text button for allocating runtimes.
    init(_ title: String, action: @escaping () -> Void) {
        self.init(action: action) {
            Text(title)
        }
    }
}
