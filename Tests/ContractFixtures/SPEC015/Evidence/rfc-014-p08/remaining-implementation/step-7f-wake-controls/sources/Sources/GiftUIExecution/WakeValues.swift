package struct ExecutionWakeReasons: OptionSet, Equatable, Sendable {
    package let rawValue: UInt8

    package init(rawValue: UInt8) {
        self.rawValue = rawValue & 0x07
    }

    package static let admittedWork = Self(rawValue: 0x01)
    package static let semanticDirty = Self(rawValue: 0x02)
    package static let presentationPending = Self(rawValue: 0x04)
}

package protocol ExecutionWakeRequester {
    mutating func requestWake(for reasons: ExecutionWakeReasons)
}

package struct PresentationPendingIntent: Equatable, Sendable {
    package let semanticRevision: SemanticRevision
    package let retryableRefusalCount: UInt8

    package init(
        semanticRevision: SemanticRevision,
        retryableRefusalCount: UInt8
    ) {
        self.semanticRevision = semanticRevision
        self.retryableRefusalCount = retryableRefusalCount
    }
}
