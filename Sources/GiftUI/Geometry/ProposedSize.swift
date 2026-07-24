public struct ProposedSize: Equatable, Hashable, Sendable {
    public var width: Int?
    public var height: Int?

    public init(width: Int? = nil, height: Int? = nil) {
        precondition(
            width.map { $0 >= 0 } ?? true,
            "Proposed width must not be negative"
        )
        precondition(
            height.map { $0 >= 0 } ?? true,
            "Proposed height must not be negative"
        )
        self.width = width
        self.height = height
    }
}
