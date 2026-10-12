import GiftUI
import GiftUICapabilities
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUIReferenceTextResources
import GiftUIRuntimeCore
import GiftUISurfaceCore
import GiftUITextResources
import GiftUIHostConfiguration

struct CounterHostGraph: HostComponentGraphView {
    let count: UInt8 = 18
    func record(at index: UInt8) -> HostComponentRecord? {
        guard index < count, let role = HostComponentRole(rawValue: index) else { return nil }
        return .init(role: role, dependencies: index == 0 ? .init(rawValue: 0) : .init(HostComponentRole(rawValue: index - 1)!))
    }
}

// Inert configuration records; actual endpoint projection is checked at construction.
struct CounterHostAssembly {
    let report: HostAssemblyReport
    let endpoint: HostEndpointConfiguration
    let ledger: HostValidationAccessLedger
    static func validate(_ audit: RuntimeStorageAudit, kind: MVPHostKind) -> Self? {
        let operations: RasterOperationSet = [.opaqueRectangles, .positionedText, .straightLineStrokes, .clipping, .damage]
        let extent = CapabilityExtent(width: 100, height: 100)!
        let bytes = CapabilityByteCount(rawValue: 40000)
        let requirement = RasterPresentationRequirement(operations: operations, extent: extent, operationStream: .synchronousBorrowedOneShot, acceptedEncodings: .rgba8888, acceptedSubmissionLifetimes: .synchronousBorrow, maximumRasterBytes: bytes, maximumPayloadBytes: bytes, maximumInFlightBytes: bytes, absence: .required)!
        let realization = RasterRealizationContribution(kind: .fullSurface, operations: operations, operationStream: .synchronousBorrowedOneShot, encodings: .rgba8888, producedSubmissionLifetimes: .synchronousBorrow, maximumExtent: extent, maximumRegionWidth: 100, maximumRegionHeight: 100, rowByteAlignment: 4, maximumRasterBytes: bytes, maximumPayloadBytes: bytes)!
        var contributions = RasterPresentationContributions()
        precondition(contributions.insert(.renderProducer(.init(operations: operations, operationStream: .synchronousBorrowedOneShot)!)) == .inserted)
        precondition(contributions.insert(.rasterBackend(.init(primary: realization, alternate: nil)!)) == .inserted)
        precondition(contributions.insert(.surfaceDisplay(.init(extent: extent, encodings: .rgba8888, acceptedSubmissionLifetimes: .synchronousBorrow, handoffs: .synchronous, maximumRegionWidth: 100, maximumRegionHeight: 100, rowByteAlignment: 4, maximumInFlightCount: 1, maximumInFlightBytes: bytes)!)) == .inserted)
        precondition(contributions.insert(.hostResourcePolicy(.init(maximumRasterBytes: bytes, maximumPayloadBytes: bytes, maximumInFlightBytes: bytes, allowedRealizations: .fullSurface, allowedEncodings: .rgba8888, preferredRealization: .fullSurface, preferredEncoding: .rgba8888)!)) == .inserted)
        var workspace = RasterPresentationResolverWorkspace()!
        guard case .available(let effective) = RasterPresentationResolver.resolve(requirement: requirement, contributions: contributions, workspace: &workspace) else { return nil }
        let endpoint = HostEndpointConfiguration(effectivePresentation: effective, descriptor: .init(bounds: counterSurface, encoding: .rgba8888, bytesPerRow: 400, realization: .fullSurface, regionWidth: 100, regionHeight: 100)!, payloadLimits: .init(maximumRasterBytes: 40000, maximumPayloadBytes: 40000, maximumRegionsPerPayload: 1, maximumRegionSubmissionsPerFrame: 1, maximumTileVisitsPerFrame: 1, maximumInFlightPayloads: 1, maximumGlyphRasterBytes: 40000, maximumStrokeWorkspaceBytes: 1)!, surfaceWritableCapacityBytes: 40000, displaySubmissionLifetime: .synchronousBorrow, displayHandoff: .synchronous, displayMaximumInFlightPayloads: 1, displayMaximumInFlightBytes: 40000, textRasterRealization: .init(rawValue: 0), healthOwnerCount: 1, endpointAndDisplayShareHealthOwner: true)
        var validator = CheckedMVPHostConfigurationValidator(structuralConfiguration: .init(kind: kind, profile: audit.profile, runtimeLimits: audit.limits, runtimeAudit: audit, cardinality: P08CounterWorkload.cardinality, workload: P08CounterWorkload.value(audit.limits), pacing: P08CounterWorkload.pacing), runtimeProfileValidation: .valid(audit), componentGraph: CounterHostGraph(), textResourceValidation: TextResourceValidator.validate(GiftUIReferenceTextResources.targetPackage, requiring: .init(rawValue: 0)), selectedTextRasterRealization: .init(rawValue: 0), capabilityRequirement: requirement, capabilityContributions: contributions, capabilityWorkspace: .init()!, endpoint: endpoint, actionAndModel: .init(firstActionCode: 0, lastActionCode: 1, handlerCount: 1, rootModelTargetCount: 1, sourceMinimumTransitionSpacingMicroseconds: 50000, maximumSourceCallbacksPerServiceWindow: 20, maximumCallbacksPerAction: 1, maximumRepositoryCallbacksPerAction: 1, maximumUseCaseCallbacksPerAction: 1, maximumNonTransitionPublicationsPerAction: 1, applicationExecutorFactLimit: 28, factAdmissionAdapterCount: 1, targetGenerationIsPublishable: true, actionHandlerIsTotal: true, retainsOwnerReferences: false, callbacksAreReentrant: false), inputAndWake: .init(normalizedInputSourceCount: 1, targetLocalPresentationGateCount: 1, wakeRequesterCount: 1, applicationAndMutationDomainsAreDistinct: true, wakeRequesterIsNonReentrant: true), residualPolicyTable: FixedMVPHostResidualPolicyTable(fatalHookIsAvailable: false))
        guard case .valid(let report) = validator.validate() else { return nil }
        return Self(report: report, endpoint: endpoint, ledger: validator.validationAccessLedger)
    }
}
