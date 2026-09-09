import GiftUIExecution

package struct ExecutionFixtureMeasurements: Equatable, Sendable {
    package let phaseDurations: PhaseDurations
    package let sealToPublicationLatency: UInt64
    package let offerLatency: UInt64
    package let dirtyToOpportunityLatency: UInt64
    package let retryAttempts: UInt32
    package let retryPacingInterval: UInt64
    package let queueHighWater: UInt32
    package let workspaceHighWater: UInt32
    package let stackHighWater: UInt32
    package let staleInputDrops: UInt32
    package let sequenceCancellations: UInt32
    package let activationCancellations: UInt32
    package let operationCount: UInt32
    package let heapAllocationCount: UInt32
    package let linkedSectionDelta: Int64
    package let linkMapDigest: LinkMapDigest

    package struct PhaseDurations: Equatable, Sendable {
        package let idle: UInt64
        package let admitting: UInt64
        package let mutating: UInt64
        package let deriving: UInt64
        package let publishing: UInt64
        package let offering: UInt64
        package let finalizing: UInt64
    }

    package struct LinkMapDigest: Equatable, Sendable {
        package let word0: UInt64
        package let word1: UInt64
        package let word2: UInt64
        package let word3: UInt64
    }
}

package enum ExecutionResourceProbe {
    @inline(never)
    package static func measurementSize() -> UInt32 {
        UInt32(MemoryLayout<ExecutionFixtureMeasurements>.size)
    }
}
