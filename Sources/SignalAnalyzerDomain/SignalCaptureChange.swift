/// One bounded capture update, with no collection-backed payload.
package enum SignalCaptureChange: Equatable, Sendable {
    case insertAndTrim(
        baseRevision: UInt32,
        insertionIndex: UInt16,
        transition: SignalTransition,
        evictedPrefixCount: UInt16,
        duration: Duration,
        retainedLowerBound: Duration,
        baselines: SignalChannelLevels
    )
    case reset(
        baseRevision: UInt32,
        baselines: SignalChannelLevels
    )
}
