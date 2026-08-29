import GiftUIFailureCore

public struct GiftUIDiagnosticDeliveryCounters: Sendable, Equatable {
    public private(set) var accepted: UInt32 = 0
    public private(set) var dropped: UInt32 = 0
    public private(set) var saturated: UInt32 = 0
    public private(set) var failed: UInt32 = 0
    public private(set) var countersSaturated: Bool = false

    public init() {}

    package init(
        accepted: UInt32,
        dropped: UInt32,
        saturated: UInt32,
        failed: UInt32,
        countersSaturated: Bool = false
    ) {
        self.accepted = accepted
        self.dropped = dropped
        self.saturated = saturated
        self.failed = failed
        self.countersSaturated = countersSaturated
    }

    mutating func record(_ result: GiftUIDiagnosticSinkResult) {
        switch result {
        case .accepted:
            accepted = increment(accepted)
        case .dropped:
            dropped = increment(dropped)
        case .saturated:
            saturated = increment(saturated)
        case .failed:
            failed = increment(failed)
        }
    }

    private mutating func increment(_ value: UInt32) -> UInt32 {
        guard value < .max else {
            countersSaturated = true
            return .max
        }
        return value + 1
    }
}

public struct GiftUIDiagnosticProjector<Sink: GiftUIDiagnosticSink> {
    public let selection: GiftUIDiagnosticSelection
    public private(set) var sink: Sink
    public private(set) var counters: GiftUIDiagnosticDeliveryCounters

    public init(
        selection: GiftUIDiagnosticSelection,
        sink: Sink
    ) {
        self.selection = selection
        self.sink = sink
        counters = GiftUIDiagnosticDeliveryCounters()
    }

    public mutating func project(
        kind: GiftUIDiagnosticKind,
        origin: GiftUIFailureOrigin,
        severity: GiftUIDiagnosticSeverity,
        record: () -> GiftUIDiagnosticRecord
    ) {
        guard selection.includes(kind: kind, origin: origin, severity: severity) else {
            return
        }
        counters.record(sink.consume(record()))
    }
}

extension GiftUIDiagnosticProjector: Sendable where Sink: Sendable {}
