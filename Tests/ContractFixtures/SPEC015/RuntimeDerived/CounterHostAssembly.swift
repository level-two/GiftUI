import GiftUI
import GiftUICapabilities
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUIReferenceTextResources
import GiftUIRuntimeCore
import GiftUISurfaceCore
import GiftUITextResources
import GiftUIHostConfiguration

// Closed counter-local factory inputs. These values are inert and never retained
// by a live owner. Actual constructor paths below use the same selections.
enum CounterProfileConstructionInput {
    case supplied
    var origins: UInt32 { 1 << HostComponentRole.runtimeProfile.rawValue }
    func control(_ supplied: UnsafeMutablePointer<CounterControl>) -> UnsafeMutablePointer<CounterControl> { supplied }
    func audit(_ supplied: RuntimeStorageAudit) -> RuntimeStorageAudit { supplied }
}
enum CounterResolvedConfigurationInput {
    case fourContributions
    var origins: UInt32 {
        (1 << HostComponentRole.renderProducerContribution.rawValue) | (1 << HostComponentRole.rasterBackendContribution.rawValue)
            | (1 << HostComponentRole.surfaceDisplayContribution.rawValue) | (1 << HostComponentRole.hostResourcePolicyContribution.rawValue)
    }
    func configuration(_ resolved: HostEndpointConfiguration) -> HostEndpointConfiguration { resolved }
    func resolve(requirement: RasterPresentationRequirement, contributions: borrowing RasterPresentationContributions, workspace: inout RasterPresentationResolverWorkspace) -> RasterPresentationResolution {
        switch self { case .fourContributions: return RasterPresentationResolver.resolve(requirement: requirement, contributions: contributions, workspace: &workspace) }
    }
}
enum CounterReferenceTextInput {
    case reference
    var origins: UInt32 { 1 << HostComponentRole.textResourcePackage.rawValue }
    var realization: RasterRealizationID { .init(rawValue: 0) }
    func metrics() -> GiftUIReferenceTextMetricsView { .init() }
    func raster() -> GiftUIReferenceTextRasterView { .init() }
    func validate() -> TextResourceValidationResult {
        TextResourceValidator.validate(GiftUIReferenceTextResources.targetPackage, requiring: realization)
    }
}
enum CounterTextConstruction {
    case direct(CounterReferenceTextInput)
    case bound(CounterReferenceTextInput)
    var input: CounterReferenceTextInput {
        switch self { case .direct(let input), .bound(let input): return input }
    }
    var origins: UInt32 { input.origins }
    var realization: RasterRealizationID { input.realization }
    func validate() -> TextResourceValidationResult { input.validate() }
    func metrics() -> GiftUIReferenceTextMetricsView {
        switch self {
        case .direct(let input): return input.metrics()
        case .bound(let input): return { input.metrics() }()
        }
    }
    func raster() -> GiftUIReferenceTextRasterView {
        switch self {
        case .direct(let input): return input.raster()
        case .bound(let input): return { input.raster() }()
        }
    }
}
enum CounterFullReportInput {
    case validatedAssembly
    var origins: UInt32 {
        CounterProfileConstructionInput.supplied.origins | CounterResolvedConfigurationInput.fourContributions.origins
    }
    func scheduler(_ report: HostAssemblyReport) -> HostScheduledOpportunityController {
        .init(assemblyReport: report, initialFrameOriginMicroseconds: 0)
    }
}
enum CounterReportConstruction {
    case direct(CounterFullReportInput)
    case bound(CounterFullReportInput)
    // Negative factory branch: this callback requires a selected text input too.
    // Its construction precondition consumes that same input; it is not an
    // opaque closure whose captures can disappear from provenance.
    case boundWithText(CounterFullReportInput, CounterReferenceTextInput)
    var origins: UInt32 {
        switch self {
        case .direct(let input), .bound(let input): return input.origins
        case .boundWithText(let input, let text): return input.origins | text.origins
        }
    }
    func scheduler(_ report: HostAssemblyReport) -> HostScheduledOpportunityController {
        switch self {
        case .direct(let input): return input.scheduler(report)
        case .bound(let input): return { input.scheduler(report) }()
        case .boundWithText(let input, let text):
            return {
                guard case .valid = text.validate() else { preconditionFailure("bound counter text input") }
                return input.scheduler(report)
            }()
        }
    }
}
struct CounterConstructionInputs {
    let endpointBacking: CounterProfileConstructionInput = .supplied
    let endpointConfiguration: CounterResolvedConfigurationInput = .fourContributions
    let text: CounterTextConstruction = .bound(.reference)
    let root: CounterProfileConstructionInput = .supplied
    let admission: CounterProfileConstructionInput = .supplied
    var report: CounterReportConstruction = .bound(.validatedAssembly)
    static var canonical: Self { .init() }
    func origins(for role: HostComponentRole) -> UInt32 {
        switch role {
        case .rasterEndpoint: return endpointBacking.origins | endpointConfiguration.origins | text.origins
        case .rootModelTarget: return root.origins
        case .factAdmission: return admission.origins
        case .wakeRequester: return report.origins
        default: return 0
        }
    }
}
enum CounterConstructionNegative {
    case omitted(HostComponentRole, UInt8)
    case hiddenSelectedText
    case hiddenRetainedReport
    case undeclaredBoundText
    var actualInputs: CounterConstructionInputs {
        var inputs = CounterConstructionInputs.canonical
        if case .undeclaredBoundText = self { inputs.report = .boundWithText(.validatedAssembly, .reference) }
        return inputs
    }
    func declaredOrigins(_ original: UInt32, role: HostComponentRole) -> UInt32 {
        switch self {
        case .omitted(let target, let origin): return role == target ? original & ~(1 << origin) : original
        case .hiddenSelectedText: return role == .rasterEndpoint ? original & ~CounterReferenceTextInput.reference.origins : original
        case .hiddenRetainedReport: return role == .wakeRequester ? 0 : original
        case .undeclaredBoundText: return original
        }
    }
}
struct CounterConstructionObservation {
    var result: HostValidationResult?
    var runtimeReads: UInt8 = 0
    var textReads: UInt8 = 0
    var workloadReads: UInt8 = 0
    var capabilityReads: UInt8 = 0
    var endpointReads: UInt8 = 0
    var applicationReads: UInt8 = 0
    var inputReads: UInt8 = 0
    var policyReads: UInt8 = 0
    var hasNoLaterReads: Bool {
        runtimeReads == 0 && textReads == 0 && workloadReads == 0 && capabilityReads == 0
            && endpointReads == 0 && applicationReads == 0 && inputReads == 0 && policyReads == 0
    }
}

// Declarations are independent from actual selections under negative mutation.
struct CounterHostGraph: HostComponentGraphView {
    let count: UInt8 = 18
    var negative: CounterConstructionNegative? = nil
    func record(at index: UInt8) -> HostComponentRecord? {
        guard index < count, let role = HostComponentRole(rawValue: index) else { return nil }
        let origins = CounterConstructionInputs.canonical.origins(for: role)
        return .init(role: role, dependencies: .init(rawValue: negative?.declaredOrigins(origins, role: role) ?? origins))
    }
}

// Inert configuration records; actual endpoint projection is checked at construction.
struct CounterHostAssembly {
    let report: HostAssemblyReport
    let endpoint: HostEndpointConfiguration
    let ledger: HostValidationAccessLedger
    static func validate(_ audit: RuntimeStorageAudit, kind: MVPHostKind, sourceCallbacks: UInt16 = 20, repositoryCallbacks: UInt8 = 1, useCaseCallbacks: UInt8 = 1, nonTransitionPublications: UInt8 = 1) -> Self? {
        var observation = CounterConstructionObservation()
        return validate(audit, kind: kind, sourceCallbacks: sourceCallbacks, repositoryCallbacks: repositoryCallbacks, useCaseCallbacks: useCaseCallbacks, nonTransitionPublications: nonTransitionPublications, negative: nil, observation: &observation)
    }
    static func validate(_ audit: RuntimeStorageAudit, kind: MVPHostKind, sourceCallbacks: UInt16 = 20, repositoryCallbacks: UInt8 = 1, useCaseCallbacks: UInt8 = 1, nonTransitionPublications: UInt8 = 1, negative: CounterConstructionNegative?, observation: inout CounterConstructionObservation) -> Self? {
        let graph = CounterHostGraph(negative: negative)
        let inputs = negative?.actualInputs ?? .canonical
        // This is before even eager capability resolution/text validation.
        if let error = HostComponentGraphValidation.validate(graph) {
            observation.result = .invalid(stage: .graph, error: error)
            return nil
        }
        for index: UInt8 in 0..<18 {
            let declared = graph.record(at: index)!
            guard declared.dependencies.rawValue == inputs.origins(for: declared.role) else {
                observation.result = .invalid(stage: .graph, error: .invalidGraph)
                return nil
            }
        }
        observation.capabilityReads += 1
        let operations: RasterOperationSet = [.opaqueRectangles, .positionedText, .straightLineStrokes, .clipping, .damage]
        let extent = CapabilityExtent(width: 100, height: 120)!
        let bytes = CapabilityByteCount(rawValue: 48000)
        let requirement = RasterPresentationRequirement(operations: operations, extent: extent, operationStream: .synchronousBorrowedOneShot, acceptedEncodings: .rgba8888, acceptedSubmissionLifetimes: .synchronousBorrow, maximumRasterBytes: bytes, maximumPayloadBytes: bytes, maximumInFlightBytes: bytes, absence: .required)!
        let realization = RasterRealizationContribution(kind: .fullSurface, operations: operations, operationStream: .synchronousBorrowedOneShot, encodings: .rgba8888, producedSubmissionLifetimes: .synchronousBorrow, maximumExtent: extent, maximumRegionWidth: 100, maximumRegionHeight: 120, rowByteAlignment: 4, maximumRasterBytes: bytes, maximumPayloadBytes: bytes)!
        var contributions = RasterPresentationContributions()
        precondition(contributions.insert(.renderProducer(.init(operations: operations, operationStream: .synchronousBorrowedOneShot)!)) == .inserted)
        precondition(contributions.insert(.rasterBackend(.init(primary: realization, alternate: nil)!)) == .inserted)
        precondition(contributions.insert(.surfaceDisplay(.init(extent: extent, encodings: .rgba8888, acceptedSubmissionLifetimes: .synchronousBorrow, handoffs: .synchronous, maximumRegionWidth: 100, maximumRegionHeight: 120, rowByteAlignment: 4, maximumInFlightCount: 1, maximumInFlightBytes: bytes)!)) == .inserted)
        precondition(contributions.insert(.hostResourcePolicy(.init(maximumRasterBytes: bytes, maximumPayloadBytes: bytes, maximumInFlightBytes: bytes, allowedRealizations: .fullSurface, allowedEncodings: .rgba8888, preferredRealization: .fullSurface, preferredEncoding: .rgba8888)!)) == .inserted)
        var workspace = RasterPresentationResolverWorkspace()!
        guard case .available(let effective) = inputs.endpointConfiguration.resolve(requirement: requirement, contributions: contributions, workspace: &workspace) else { return nil }
        observation.endpointReads += 1
        let endpoint = HostEndpointConfiguration(effectivePresentation: effective, descriptor: .init(bounds: counterSurface, encoding: .rgba8888, bytesPerRow: 400, realization: .fullSurface, regionWidth: 100, regionHeight: 120)!, payloadLimits: .init(maximumRasterBytes: 48000, maximumPayloadBytes: 48000, maximumRegionsPerPayload: 120, maximumRegionSubmissionsPerFrame: 1, maximumTileVisitsPerFrame: 1, maximumInFlightPayloads: 1, maximumGlyphRasterBytes: 48000, maximumStrokeWorkspaceBytes: 1)!, surfaceWritableCapacityBytes: 48000, displaySubmissionLifetime: .synchronousBorrow, displayHandoff: .synchronous, displayMaximumInFlightPayloads: 1, displayMaximumInFlightBytes: 48000, textRasterRealization: inputs.text.realization, healthOwnerCount: 1, endpointAndDisplayShareHealthOwner: true)
        observation.runtimeReads += 1
        observation.workloadReads += 1
        observation.textReads += 1
        let selectedTextValidation = inputs.text.validate()
        observation.applicationReads += 1
        observation.inputReads += 1
        observation.policyReads += 1
        var validator = CheckedMVPHostConfigurationValidator(structuralConfiguration: .init(kind: kind, profile: audit.profile, runtimeLimits: audit.limits, runtimeAudit: audit, cardinality: P08CounterWorkload.cardinality, workload: P08CounterWorkload.value(audit.limits), pacing: P08CounterWorkload.pacing), runtimeProfileValidation: .valid(audit), componentGraph: graph, textResourceValidation: selectedTextValidation, selectedTextRasterRealization: inputs.text.realization, capabilityRequirement: requirement, capabilityContributions: contributions, capabilityWorkspace: .init()!, endpoint: endpoint, actionAndModel: .init(firstActionCode: 0, lastActionCode: 1, handlerCount: 1, rootModelTargetCount: 1, sourceMinimumTransitionSpacingMicroseconds: 50000, maximumSourceCallbacksPerServiceWindow: sourceCallbacks, maximumCallbacksPerAction: 1, maximumRepositoryCallbacksPerAction: repositoryCallbacks, maximumUseCaseCallbacksPerAction: useCaseCallbacks, maximumNonTransitionPublicationsPerAction: nonTransitionPublications, applicationExecutorFactLimit: 28, factAdmissionAdapterCount: 1, targetGenerationIsPublishable: true, actionHandlerIsTotal: true, retainsOwnerReferences: false, callbacksAreReentrant: false), inputAndWake: .init(normalizedInputSourceCount: 1, targetLocalPresentationGateCount: 1, wakeRequesterCount: 1, applicationAndMutationDomainsAreDistinct: true, wakeRequesterIsNonReentrant: true), residualPolicyTable: FixedMVPHostResidualPolicyTable(fatalHookIsAvailable: false))
        let result = validator.validate()
        observation.result = result
        guard case .valid(let report) = result else { return nil }
        return Self(report: report, endpoint: endpoint, ledger: validator.validationAccessLedger)
    }
}
