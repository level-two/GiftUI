@usableFromInline
package struct ObservableTargetGeneration: Equatable, Hashable, Sendable {
    @usableFromInline package let rawValue: UInt32

    @usableFromInline
    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}
