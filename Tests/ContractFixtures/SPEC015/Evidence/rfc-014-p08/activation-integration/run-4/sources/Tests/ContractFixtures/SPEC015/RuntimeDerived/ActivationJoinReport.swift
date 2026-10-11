import GiftUIRuntimeCore

@testable import GiftUICapabilities
@testable import GiftUIHostConfiguration

// Synthetic component sentinel: no nine-stage validator or analyzer workload
// conformance is claimed. Audit belongs to the actual supplied fixture backing.
func p08ActivationComponentReport(_ audit: RuntimeStorageAudit) -> HostAssemblyReport {
    let extent = CapabilityExtent(width: 100, height: 100)!
    let effective = EffectiveRasterPresentation(
        operations: [.opaqueRectangles, .positionedText, .straightLineStrokes], extent: extent,
        regionExtent: extent, rowBytes: .init(rawValue: 400),
        operationStream: .synchronousBorrowedOneShot, encoding: .rgba8888,
        submissionLifetime: .synchronousBorrow, handoff: .synchronous, realization: .fullSurface,
        requiredRasterBytes: .init(rawValue: 40000), requiredPayloadBytes: .init(rawValue: 40000),
        inFlightCount: 1, requiredInFlightBytes: .init(rawValue: 40000))
    return HostAssemblyReport(
        kind: .macOSStatic, profile: .static, storageAudit: audit,
        capabilitySnapshot: .init(rasterPresentation: effective), effectivePresentation: effective,
        drawingPlanOperationLimit: 3, minimumSinkOperationCapacity: 3,
        cardinality: .init(
            actionCaseCount: 0, rootModelLocationCount: 1, activeRegistrationCount: 1,
            stagedAssociationCount: 1, snapshotFactCapacity: 1, compactFactCapacity: 1,
            reservedFailureFactCapacity: 1, normalizedInputSourceCapacity: 1),
        minimumFrameIntervalMicroseconds: 1, maximumFactServiceLatencyMicroseconds: 1,
        minimumAcceptedTransitionSpacingMicroseconds: 1, maximumCompactFactsPerServiceWindow: 1,
        maximumRetryableRefusals: 1)
}
