import GiftUICapabilities
import GiftUIExecution
import GiftUIFailureCore
import GiftUIRuntimeCore
import GiftUITextResources

package protocol MVPHostResidualPolicyTable: ~Copyable {
    var fatalHookIsAvailable: Bool { get }
    borrowing func allowed(
        for context: HostResidualPolicyContext
    ) -> GiftUIAllowedDispositions
    borrowing func selection(
        for context: HostResidualPolicyContext
    ) -> GiftUIResidualDisposition
}

package enum HostValidationStage: UInt8, Equatable, Sendable {
    case graph = 0
    case runtimeProfile = 1
    case textResources = 2
    case workload = 3
    case capability = 4
    case endpoint = 5
    case actionAndModel = 6
    case inputAndWake = 7
    case policy = 8
}

package enum HostConfigurationError: Equatable, Sendable {
    case duplicateRole(HostComponentRole)
    case missingRole(HostComponentRole)
    case invalidGraph
    case profileMismatch
    case invalidRuntimeProfile(RuntimeProfileValidationError)
    case invalidTextResources(TextResourceValidationError)
    case invalidWorkload
    case insufficientWorkloadCapacity
    case capabilityUnavailable(RasterPresentationUnavailable)
    case invalidEndpointDescriptor
    case invalidActionDomain
    case invalidModelTarget
    case invalidInputIntegration
    case invalidWakeIntegration
    case invalidPacingPolicy
    case incompleteFailurePolicy
    case arithmeticOverflow
    case invariantViolation
}

package struct HostAssemblyReport: Equatable, Sendable {
    package let kind: MVPHostKind
    package let profile: RuntimeProfileKind
    package let storageAudit: RuntimeStorageAudit
    package let capabilitySnapshot: CapabilitySnapshot
    package let effectivePresentation: EffectiveRasterPresentation
    package let drawingPlanOperationLimit: UInt16
    package let minimumSinkOperationCapacity: UInt16
    package let cardinality: SignalAnalyzerHostCardinality
    package let minimumFrameIntervalMicroseconds: UInt32
    package let maximumFactServiceLatencyMicroseconds: UInt32
    package let minimumAcceptedTransitionSpacingMicroseconds: UInt32
    package let maximumCompactFactsPerServiceWindow: UInt16
    package let maximumRetryableRefusals: UInt8
}

package enum HostValidationResult: Equatable, Sendable {
    case valid(HostAssemblyReport)
    case invalid(stage: HostValidationStage, error: HostConfigurationError)
}

package struct HostValidationAccessLedger: Equatable, Sendable {
    package private(set) var accessedStages: UInt16 = 0
    package private(set) var accessCount: UInt8 = 0
    package let sideEffectCount: UInt16 = 0

    package init() {}

    package func contains(_ stage: HostValidationStage) -> Bool {
        accessedStages & (UInt16(1) << UInt16(stage.rawValue)) != 0
    }

    mutating func enter(_ stage: HostValidationStage) -> Bool {
        guard stage.rawValue == accessCount else { return false }
        accessedStages |= UInt16(1) << UInt16(stage.rawValue)
        accessCount += 1
        return true
    }
}

package enum MVPHostLifecycleState: UInt8, Equatable, Sendable {
    case valid = 0
    case activating = 1
    case active = 2
    case failed = 3
    case quiescing = 4
    case quiescent = 5
}

package enum HostActivationResult<Failure: Equatable & Sendable>:
    Equatable, Sendable
{
    case active
    case failure(Failure)
}

package enum HostOpportunityResult: Equatable, Sendable {
    case cycle(RunCycleResult<RuntimeOwnerFailure>)
    case invalidLifecycle
}

package protocol MVPHostInstance: ~Copyable {
    associatedtype ActivationFailure: Equatable & Sendable
    var lifecycleState: MVPHostLifecycleState { get }
    var assemblyReport: HostAssemblyReport { get }
    mutating func activate() -> HostActivationResult<ActivationFailure>
    mutating func runOpportunity() -> HostOpportunityResult
    mutating func teardown()
}

package protocol MVPHostConfigurationValidator: ~Copyable {
    associatedtype ComponentGraph: HostComponentGraphView
    associatedtype ResidualPolicyTable: MVPHostResidualPolicyTable
    var structuralConfiguration: HostStructuralConfiguration { get }
    var componentGraph: ComponentGraph { get }
    var textResourceValidation: TextResourceValidationResult { get }
    var capabilityRequirement: RasterPresentationRequirement { get }
    var capabilityContributions: RasterPresentationContributions { get }
    var capabilityWorkspace: RasterPresentationResolverWorkspace { get set }
    var endpoint: HostEndpointConfiguration { get }
    var actionAndModel: HostActionModelConfiguration { get }
    var inputAndWake: HostInputWakeConfiguration { get }
    var residualPolicyTable: ResidualPolicyTable { get }
    mutating func validate() -> HostValidationResult
}

package protocol MVPHostResidualPolicy: GiftUIResidualFailurePolicy
where Context == HostResidualPolicyContext {}

struct HostValidationStateGuard: ~Copyable {
    private var hasBegun = false

    mutating func begin() -> HostValidationResult? {
        guard !hasBegun else {
            return .invalid(stage: .graph, error: .invariantViolation)
        }
        hasBegun = true
        return nil
    }
}
