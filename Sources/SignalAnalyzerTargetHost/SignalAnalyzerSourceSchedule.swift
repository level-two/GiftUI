/// The host's wall-clock anchor for a source's relative logical delays.
/// Source generations reset the anchor; late polls and Clear do not.
package struct SignalAnalyzerSourceSchedule {
    package private(set) var generation: UInt32?
    package private(set) var deadline: UInt64?

    package init() {}

    package mutating func synchronize(
        generation nextGeneration: UInt32?, delayMicroseconds: UInt64?, now: UInt64
    ) -> Bool {
        guard nextGeneration != generation else { return true }
        guard nextGeneration != nil else {
            generation = nil
            deadline = nil
            return true
        }
        guard let delayMicroseconds else { return false }
        let next = now.addingReportingOverflow(delayMicroseconds)
        guard !next.overflow else { return false }
        generation = nextGeneration
        deadline = next.partialValue
        return true
    }

    package mutating func advance(by delayMicroseconds: UInt64) -> Bool {
        guard let deadline else { return false }
        let next = deadline.addingReportingOverflow(delayMicroseconds)
        guard !next.overflow else { return false }
        self.deadline = next.partialValue
        return true
    }
}
