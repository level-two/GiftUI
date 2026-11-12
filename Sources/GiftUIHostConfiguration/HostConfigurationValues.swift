import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIRasterCore
import GiftUIRuntimeCore
import GiftUISurfaceCore
import GiftUITextResources

@usableFromInline
package enum MVPHostKind: UInt8, Equatable, Sendable {
    case macOSDynamic = 0
    case macOSStatic = 1
    case raspberryPiDynamic = 2
    case nrf52840Static = 3
}

@usableFromInline
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
    #if GIFTUI_GRAPH_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    @usableFromInline
    package init?(rawValue: UInt8) {
        switch rawValue {
        case 0: self = .runtimeProfile
        case 1: self = .textResourcePackage
        case 2: self = .renderProducerContribution
        case 3: self = .rasterBackendContribution
        case 4: self = .surfaceDisplayContribution
        case 5: self = .hostResourcePolicyContribution
        case 6: self = .rasterEndpoint
        case 7: self = .applicationExecutor
        case 8: self = .signalSource
        case 9: self = .signalRepository
        case 10: self = .useCaseSet
        case 11: self = .factAdmission
        case 12: self = .actionDomain
        case 13: self = .actionHandler
        case 14: self = .rootModelTarget
        case 15: self = .normalizedInput
        case 16: self = .wakeRequester
        case 17: self = .residualPolicy
        default: return nil
        }
    }
}

package struct HostComponentRoleSet: OptionSet, Equatable, Sendable {
    package let rawValue: UInt32

    #if GIFTUI_GRAPH_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    #if GIFTUI_GRAPH_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    package init(_ role: HostComponentRole) {
        rawValue = UInt32(1) << UInt32(role.rawValue)
    }
}

@usableFromInline
package struct HostComponentRecord: Equatable, Sendable {
    package let role: HostComponentRole
    package let dependencies: HostComponentRoleSet

    #if GIFTUI_GRAPH_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    package init(role: HostComponentRole, dependencies: HostComponentRoleSet) {
        self.role = role
        self.dependencies = dependencies
    }
}

@usableFromInline
package protocol HostComponentGraphView: ~Copyable {
    var count: UInt8 { get }
    borrowing func record(at index: UInt8) -> HostComponentRecord?
}

@usableFromInline
package struct HostPacingPolicy: Equatable, Sendable {
    @usableFromInline
    package let minimumFrameIntervalMicroseconds: UInt32
    @usableFromInline
    package let maximumFactServiceLatencyMicroseconds: UInt32
    @usableFromInline
    package let minimumAcceptedTransitionSpacingMicroseconds: UInt32
    @usableFromInline
    package let maximumTransitionFactsPerServiceWindow: UInt16
    @usableFromInline
    package let maximumBootstrapFactsPerServiceWindow: UInt8
    @usableFromInline
    package let maximumActionInducedFactsPerServiceWindow: UInt8
    @usableFromInline
    package let maximumRetryableRefusals: UInt8

    #if GIFTUI_STARTUP_QUALIFICATION
        @_noAllocation
    #endif
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

@usableFromInline
package struct SignalAnalyzerHostCardinality: Equatable, Sendable {
    package let actionCaseCount: UInt16
    package let rootModelLocationCount: UInt16
    package let activeRegistrationCount: UInt16
    package let stagedAssociationCount: UInt16
    package let snapshotFactCapacity: UInt16
    package let compactFactCapacity: UInt16
    package let reservedFailureFactCapacity: UInt16
    package let normalizedInputSourceCapacity: UInt16

    #if GIFTUI_STARTUP_QUALIFICATION
        @_noAllocation
    #endif
    init(
        actionCaseCount: UInt16, rootModelLocationCount: UInt16, activeRegistrationCount: UInt16,
        stagedAssociationCount: UInt16, snapshotFactCapacity: UInt16, compactFactCapacity: UInt16,
        reservedFailureFactCapacity: UInt16, normalizedInputSourceCapacity: UInt16
    ) {
        self.actionCaseCount = actionCaseCount
        self.rootModelLocationCount = rootModelLocationCount
        self.activeRegistrationCount = activeRegistrationCount
        self.stagedAssociationCount = stagedAssociationCount
        self.snapshotFactCapacity = snapshotFactCapacity
        self.compactFactCapacity = compactFactCapacity
        self.reservedFailureFactCapacity = reservedFailureFactCapacity
        self.normalizedInputSourceCapacity = normalizedInputSourceCapacity
    }
}

@usableFromInline
package struct SignalAnalyzerDrawingWorkload: Equatable, Sendable {
    package let canvasOccurrences: UInt16
    package let maximumLivePathPoints: UInt16
    package let maximumLivePathSubpaths: UInt16
    package let submittedStrokes: UInt16
    package let snapshottedPoints: UInt16
    package let snapshottedSubpaths: UInt16
    @usableFromInline
    package let normalizedStrokeOperations: UInt16
    package let greatestLineWidth: GeometryScalar
    package let staticCallableCases: UInt16?
    package let maximumStaticCaptureBytes: UInt16?

    #if GIFTUI_STARTUP_QUALIFICATION
        @_noAllocation
    #endif
    init(
        canvasOccurrences: UInt16, maximumLivePathPoints: UInt16, maximumLivePathSubpaths: UInt16,
        submittedStrokes: UInt16, snapshottedPoints: UInt16, snapshottedSubpaths: UInt16,
        normalizedStrokeOperations: UInt16, greatestLineWidth: GeometryScalar,
        staticCallableCases: UInt16?, maximumStaticCaptureBytes: UInt16?
    ) {
        self.canvasOccurrences = canvasOccurrences
        self.maximumLivePathPoints = maximumLivePathPoints
        self.maximumLivePathSubpaths = maximumLivePathSubpaths
        self.submittedStrokes = submittedStrokes
        self.snapshottedPoints = snapshottedPoints
        self.snapshottedSubpaths = snapshottedSubpaths
        self.normalizedStrokeOperations = normalizedStrokeOperations
        self.greatestLineWidth = greatestLineWidth
        self.staticCallableCases = staticCallableCases
        self.maximumStaticCaptureBytes = maximumStaticCaptureBytes
    }
}

@usableFromInline
package struct SignalAnalyzerHostWorkload: Equatable, Sendable {
    package let schemaVersion: UInt16
    package let requiredPathEntries: UInt32
    package let requiredPayloadBytesPerBank: UInt32
    package let requiredInteractionIdentityComponents: UInt32
    package let requiredPathDepth: UInt16
    package let requiredPathChildFanout: UInt16
    package let requiredIdentityComponentsPerKey: UInt16
    package let requiredRuntimeLimits: RuntimeProfileLimits
    package let semanticNodeOccurrences: UInt16
    package let semanticStructuralOccurrences: UInt16
    package let renderSemanticScopeOccurrences: UInt16
    package let layoutScopeOccurrences: UInt16
    package let maximumRenderTraversalDepth: UInt16
    package let renderTextLineCount: UInt16
    package let positionedGlyphCount: UInt16
    @usableFromInline
    package let ordinaryRenderOperations: UInt16
    package let inputEventsPerOpportunity: UInt16
    package let semanticActionsPerOpportunity: UInt16
    package let completionFactsPerOpportunity: UInt16
    @usableFromInline
    package let drawing: SignalAnalyzerDrawingWorkload

    #if GIFTUI_STARTUP_QUALIFICATION
        @_noAllocation
    #endif
    init(
        schemaVersion: UInt16, requiredPathEntries: UInt32, requiredPayloadBytesPerBank: UInt32,
        requiredInteractionIdentityComponents: UInt32, requiredPathDepth: UInt16,
        requiredPathChildFanout: UInt16, requiredIdentityComponentsPerKey: UInt16,
        requiredRuntimeLimits: RuntimeProfileLimits, semanticNodeOccurrences: UInt16,
        semanticStructuralOccurrences: UInt16, renderSemanticScopeOccurrences: UInt16,
        layoutScopeOccurrences: UInt16, maximumRenderTraversalDepth: UInt16,
        renderTextLineCount: UInt16, positionedGlyphCount: UInt16, ordinaryRenderOperations: UInt16,
        inputEventsPerOpportunity: UInt16, semanticActionsPerOpportunity: UInt16,
        completionFactsPerOpportunity: UInt16, drawing: SignalAnalyzerDrawingWorkload
    ) {
        self.schemaVersion = schemaVersion
        self.requiredPathEntries = requiredPathEntries
        self.requiredPayloadBytesPerBank = requiredPayloadBytesPerBank
        self.requiredInteractionIdentityComponents = requiredInteractionIdentityComponents
        self.requiredPathDepth = requiredPathDepth
        self.requiredPathChildFanout = requiredPathChildFanout
        self.requiredIdentityComponentsPerKey = requiredIdentityComponentsPerKey
        self.requiredRuntimeLimits = requiredRuntimeLimits
        self.semanticNodeOccurrences = semanticNodeOccurrences
        self.semanticStructuralOccurrences = semanticStructuralOccurrences
        self.renderSemanticScopeOccurrences = renderSemanticScopeOccurrences
        self.layoutScopeOccurrences = layoutScopeOccurrences
        self.maximumRenderTraversalDepth = maximumRenderTraversalDepth
        self.renderTextLineCount = renderTextLineCount
        self.positionedGlyphCount = positionedGlyphCount
        self.ordinaryRenderOperations = ordinaryRenderOperations
        self.inputEventsPerOpportunity = inputEventsPerOpportunity
        self.semanticActionsPerOpportunity = semanticActionsPerOpportunity
        self.completionFactsPerOpportunity = completionFactsPerOpportunity
        self.drawing = drawing
    }
}

@usableFromInline
package struct HostStructuralConfiguration: Equatable, Sendable {
    @usableFromInline
    package let kind: MVPHostKind
    @usableFromInline
    package let profile: RuntimeProfileKind
    @usableFromInline
    package let runtimeLimits: RuntimeProfileLimits
    @usableFromInline
    package let runtimeAudit: RuntimeStorageAudit
    @usableFromInline
    package let cardinality: SignalAnalyzerHostCardinality
    @usableFromInline
    package let workload: SignalAnalyzerHostWorkload
    @usableFromInline
    package let pacing: HostPacingPolicy

    #if GIFTUI_STARTUP_QUALIFICATION
        @_noAllocation
    #endif
    package init(
        kind: MVPHostKind,
        profile: RuntimeProfileKind,
        runtimeLimits: RuntimeProfileLimits,
        runtimeAudit: RuntimeStorageAudit,
        cardinality: SignalAnalyzerHostCardinality,
        workload: SignalAnalyzerHostWorkload,
        pacing: HostPacingPolicy
    ) {
        self.kind = kind
        self.profile = profile
        self.runtimeLimits = runtimeLimits
        self.runtimeAudit = runtimeAudit
        self.cardinality = cardinality
        self.workload = workload
        self.pacing = pacing
    }
}

@usableFromInline
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

    #if GIFTUI_STARTUP_QUALIFICATION
        @_noAllocation
    #endif
    package init(
        firstActionCode: UInt16,
        lastActionCode: UInt16,
        handlerCount: UInt8,
        rootModelTargetCount: UInt8,
        sourceMinimumTransitionSpacingMicroseconds: UInt32,
        maximumSourceCallbacksPerServiceWindow: UInt16,
        maximumCallbacksPerAction: UInt8,
        maximumRepositoryCallbacksPerAction: UInt8,
        maximumUseCaseCallbacksPerAction: UInt8,
        maximumNonTransitionPublicationsPerAction: UInt8,
        applicationExecutorFactLimit: UInt16,
        factAdmissionAdapterCount: UInt8,
        targetGenerationIsPublishable: Bool,
        actionHandlerIsTotal: Bool,
        retainsOwnerReferences: Bool,
        callbacksAreReentrant: Bool
    ) {
        self.firstActionCode = firstActionCode
        self.lastActionCode = lastActionCode
        self.handlerCount = handlerCount
        self.rootModelTargetCount = rootModelTargetCount
        self.sourceMinimumTransitionSpacingMicroseconds =
            sourceMinimumTransitionSpacingMicroseconds
        self.maximumSourceCallbacksPerServiceWindow =
            maximumSourceCallbacksPerServiceWindow
        self.maximumCallbacksPerAction = maximumCallbacksPerAction
        self.maximumRepositoryCallbacksPerAction = maximumRepositoryCallbacksPerAction
        self.maximumUseCaseCallbacksPerAction = maximumUseCaseCallbacksPerAction
        self.maximumNonTransitionPublicationsPerAction =
            maximumNonTransitionPublicationsPerAction
        self.applicationExecutorFactLimit = applicationExecutorFactLimit
        self.factAdmissionAdapterCount = factAdmissionAdapterCount
        self.targetGenerationIsPublishable = targetGenerationIsPublishable
        self.actionHandlerIsTotal = actionHandlerIsTotal
        self.retainsOwnerReferences = retainsOwnerReferences
        self.callbacksAreReentrant = callbacksAreReentrant
    }
}

@usableFromInline
package struct HostInputWakeConfiguration: Equatable, Sendable {
    package let normalizedInputSourceCount: UInt16
    package let targetLocalPresentationGateCount: UInt8
    package let wakeRequesterCount: UInt8
    package let applicationAndMutationDomainsAreDistinct: Bool
    package let wakeRequesterIsNonReentrant: Bool

    #if GIFTUI_STARTUP_QUALIFICATION
        @_noAllocation
    #endif
    package init(
        normalizedInputSourceCount: UInt16,
        targetLocalPresentationGateCount: UInt8,
        wakeRequesterCount: UInt8,
        applicationAndMutationDomainsAreDistinct: Bool,
        wakeRequesterIsNonReentrant: Bool
    ) {
        self.normalizedInputSourceCount = normalizedInputSourceCount
        self.targetLocalPresentationGateCount = targetLocalPresentationGateCount
        self.wakeRequesterCount = wakeRequesterCount
        self.applicationAndMutationDomainsAreDistinct =
            applicationAndMutationDomainsAreDistinct
        self.wakeRequesterIsNonReentrant = wakeRequesterIsNonReentrant
    }
}

@usableFromInline
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

    #if GIFTUI_STARTUP_QUALIFICATION
        @_noAllocation
    #endif
    package init(
        effectivePresentation: EffectiveRasterPresentation,
        descriptor: RasterSurfaceDescriptor,
        payloadLimits: RasterPayloadLimits,
        surfaceWritableCapacityBytes: UInt32,
        displaySubmissionLifetime: SubmissionLifetime,
        displayHandoff: SubmissionHandoff,
        displayMaximumInFlightPayloads: UInt8,
        displayMaximumInFlightBytes: UInt32,
        textRasterRealization: RasterRealizationID,
        healthOwnerCount: UInt8,
        endpointAndDisplayShareHealthOwner: Bool
    ) {
        self.effectivePresentation = effectivePresentation
        self.descriptor = descriptor
        self.payloadLimits = payloadLimits
        self.surfaceWritableCapacityBytes = surfaceWritableCapacityBytes
        self.displaySubmissionLifetime = displaySubmissionLifetime
        self.displayHandoff = displayHandoff
        self.displayMaximumInFlightPayloads = displayMaximumInFlightPayloads
        self.displayMaximumInFlightBytes = displayMaximumInFlightBytes
        self.textRasterRealization = textRasterRealization
        self.healthOwnerCount = healthOwnerCount
        self.endpointAndDisplayShareHealthOwner = endpointAndDisplayShareHealthOwner
    }
}
