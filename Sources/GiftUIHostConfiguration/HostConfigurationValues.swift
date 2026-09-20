import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIRasterCore
import GiftUIRuntimeCore
import GiftUISurfaceCore
import GiftUITextResources

package enum MVPHostKind: UInt8, Equatable, Sendable {
    case macOSDynamic = 0
    case macOSStatic = 1
    case raspberryPiDynamic = 2
    case nrf52840Static = 3
}

package enum HostComponentRole: UInt8, Equatable, Sendable {
    case runtimeProfile = 0
    case textResourcePackage = 1
    case renderProducerContribution = 2
    case rasterBackendContribution = 3
    case surfaceDisplayContribution = 4
    case hostResourcePolicyContribution = 5
    case rasterEndpoint = 6
    case applicationExecutor = 7
    case signalSource = 8
    case signalRepository = 9
    case useCaseSet = 10
    case factAdmission = 11
    case actionDomain = 12
    case actionHandler = 13
    case rootModelTarget = 14
    case normalizedInput = 15
    case wakeRequester = 16
    case residualPolicy = 17
}

package struct HostComponentRoleSet: OptionSet, Equatable, Sendable {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    package init(_ role: HostComponentRole) {
        rawValue = UInt32(1) << UInt32(role.rawValue)
    }
}

package struct HostComponentRecord: Equatable, Sendable {
    package let role: HostComponentRole
    package let dependencies: HostComponentRoleSet

    package init(role: HostComponentRole, dependencies: HostComponentRoleSet) {
        self.role = role
        self.dependencies = dependencies
    }
}

package protocol HostComponentGraphView: ~Copyable {
    var count: UInt8 { get }
    borrowing func record(at index: UInt8) -> HostComponentRecord?
}

package struct HostPacingPolicy: Equatable, Sendable {
    package let minimumFrameIntervalMicroseconds: UInt32
    package let maximumFactServiceLatencyMicroseconds: UInt32
    package let minimumAcceptedTransitionSpacingMicroseconds: UInt32
    package let maximumTransitionFactsPerServiceWindow: UInt16
    package let maximumBootstrapFactsPerServiceWindow: UInt8
    package let maximumActionInducedFactsPerServiceWindow: UInt8
    package let maximumRetryableRefusals: UInt8

    package init?(
        minimumFrameIntervalMicroseconds: UInt32,
        maximumFactServiceLatencyMicroseconds: UInt32,
        minimumAcceptedTransitionSpacingMicroseconds: UInt32,
        maximumTransitionFactsPerServiceWindow: UInt16,
        maximumBootstrapFactsPerServiceWindow: UInt8,
        maximumActionInducedFactsPerServiceWindow: UInt8,
        maximumRetryableRefusals: UInt8
    ) {
        guard minimumFrameIntervalMicroseconds > 0,
            maximumFactServiceLatencyMicroseconds > 0,
            minimumAcceptedTransitionSpacingMicroseconds > 0,
            maximumTransitionFactsPerServiceWindow > 0,
            maximumBootstrapFactsPerServiceWindow > 0,
            maximumActionInducedFactsPerServiceWindow > 0,
            maximumRetryableRefusals > 0
        else { return nil }

        let (withBootstrap, bootstrapOverflow) =
            maximumTransitionFactsPerServiceWindow.addingReportingOverflow(
                UInt16(maximumBootstrapFactsPerServiceWindow)
            )
        let (_, actionOverflow) = withBootstrap.addingReportingOverflow(
            UInt16(maximumActionInducedFactsPerServiceWindow)
        )
        guard !bootstrapOverflow, !actionOverflow else { return nil }

        self.minimumFrameIntervalMicroseconds = minimumFrameIntervalMicroseconds
        self.maximumFactServiceLatencyMicroseconds = maximumFactServiceLatencyMicroseconds
        self.minimumAcceptedTransitionSpacingMicroseconds =
            minimumAcceptedTransitionSpacingMicroseconds
        self.maximumTransitionFactsPerServiceWindow = maximumTransitionFactsPerServiceWindow
        self.maximumBootstrapFactsPerServiceWindow = maximumBootstrapFactsPerServiceWindow
        self.maximumActionInducedFactsPerServiceWindow =
            maximumActionInducedFactsPerServiceWindow
        self.maximumRetryableRefusals = maximumRetryableRefusals
    }
}

package enum HostResidualPolicyContext: UInt8, Equatable, Sendable {
    case startupValidation = 0
    case activation = 1
    case presentationBackpressure = 2
    case presentationRetryableRefusal = 3
    case presentationUnavailable = 4
    case containedCandidateFailure = 5
    case staleInputOrRegistration = 6
    case backendOperationalFailure = 7
    case safetyNotProven = 8
}

package struct SignalAnalyzerHostCardinality: Equatable, Sendable {
    package let actionCaseCount: UInt16
    package let rootModelLocationCount: UInt16
    package let activeRegistrationCount: UInt16
    package let stagedAssociationCount: UInt16
    package let snapshotFactCapacity: UInt16
    package let compactFactCapacity: UInt16
    package let reservedFailureFactCapacity: UInt16
    package let normalizedInputSourceCapacity: UInt16
}

package struct SignalAnalyzerDrawingWorkload: Equatable, Sendable {
    package let canvasOccurrences: UInt16
    package let maximumLivePathPoints: UInt16
    package let maximumLivePathSubpaths: UInt16
    package let submittedStrokes: UInt16
    package let snapshottedPoints: UInt16
    package let snapshottedSubpaths: UInt16
    package let normalizedStrokeOperations: UInt16
    package let greatestLineWidth: GeometryScalar
    package let staticCallableCases: UInt16?
    package let maximumStaticCaptureBytes: UInt16?
}

package struct SignalAnalyzerHostWorkload: Equatable, Sendable {
    package let schemaVersion: UInt16
    package let requiredRuntimeLimits: RuntimeProfileLimits
    package let semanticNodeOccurrences: UInt16
    package let semanticStructuralOccurrences: UInt16
    package let renderSemanticScopeOccurrences: UInt16
    package let layoutScopeOccurrences: UInt16
    package let maximumRenderTraversalDepth: UInt16
    package let renderTextLineCount: UInt16
    package let positionedGlyphCount: UInt16
    package let ordinaryRenderOperations: UInt16
    package let inputEventsPerOpportunity: UInt16
    package let semanticActionsPerOpportunity: UInt16
    package let completionFactsPerOpportunity: UInt16
    package let drawing: SignalAnalyzerDrawingWorkload
}

package struct HostStructuralConfiguration: Equatable, Sendable {
    package let kind: MVPHostKind
    package let profile: RuntimeProfileKind
    package let runtimeLimits: RuntimeProfileLimits
    package let runtimeAudit: RuntimeStorageAudit
    package let cardinality: SignalAnalyzerHostCardinality
    package let workload: SignalAnalyzerHostWorkload
    package let pacing: HostPacingPolicy
}

package struct HostActionModelConfiguration: Equatable, Sendable {
    package let firstActionCode: UInt16
    package let lastActionCode: UInt16
    package let handlerCount: UInt8
    package let rootModelTargetCount: UInt8
    package let sourceMinimumTransitionSpacingMicroseconds: UInt32
    package let maximumSourceCallbacksPerServiceWindow: UInt16
    package let maximumCallbacksPerAction: UInt8
    package let maximumRepositoryCallbacksPerAction: UInt8
    package let maximumUseCaseCallbacksPerAction: UInt8
    package let maximumNonTransitionPublicationsPerAction: UInt8
    package let applicationExecutorFactLimit: UInt16
    package let factAdmissionAdapterCount: UInt8
    package let targetGenerationIsPublishable: Bool
    package let actionHandlerIsTotal: Bool
    package let retainsOwnerReferences: Bool
    package let callbacksAreReentrant: Bool
}

package struct HostInputWakeConfiguration: Equatable, Sendable {
    package let normalizedInputSourceCount: UInt16
    package let targetLocalPresentationGateCount: UInt8
    package let wakeRequesterCount: UInt8
    package let applicationAndMutationDomainsAreDistinct: Bool
    package let wakeRequesterIsNonReentrant: Bool
}

package struct HostEndpointConfiguration: Equatable, Sendable {
    package let effectivePresentation: EffectiveRasterPresentation
    package let descriptor: RasterSurfaceDescriptor
    package let payloadLimits: RasterPayloadLimits
    package let surfaceWritableCapacityBytes: UInt32
    package let displaySubmissionLifetime: SubmissionLifetime
    package let displayHandoff: SubmissionHandoff
    package let displayMaximumInFlightPayloads: UInt8
    package let displayMaximumInFlightBytes: UInt32
    package let textRasterRealization: RasterRealizationID
    package let healthOwnerCount: UInt8
    package let endpointAndDisplayShareHealthOwner: Bool
}
