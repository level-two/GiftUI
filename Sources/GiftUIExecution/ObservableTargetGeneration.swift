@usableFromInline
package struct ObservableTargetGeneration: Equatable, Hashable, Sendable {
    @usableFromInline package let rawValue: UInt32

    @inlinable
    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    @inlinable
    package static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
