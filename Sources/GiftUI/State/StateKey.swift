public struct StateKey: Hashable, Sendable {
    public let path: String
    public let slot: Int

    public init(path: String, slot: Int) {
        self.path = path
        self.slot = slot
    }
}
