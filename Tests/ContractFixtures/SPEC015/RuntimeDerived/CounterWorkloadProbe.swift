import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUISemanticCore
@testable import RuntimeCycleProbe
@testable import GiftUIHostConfiguration

// Pure workload controls only. This does not manufacture a counter audit from
// another profile and does not claim a nine-stage constructed application pass.
package func p08CounterWorkloadValidation() -> Int {
    var models = ObservableModelOwnerNamespace()
    var semantics = SemanticRecordOwnerNamespace()
    do {
        let storage = StaticCycleProfileStorage(modelOwner: try models.issue(),
            semanticOwner: try semantics.issue())
        guard case .valid(let unrelatedAudit) = storage.audit() else { preconditionFailure() }
        var checks = 0
        for profile: RuntimeProfileKind in [.static, .dynamic] {
            let limits = P08CounterWorkload.limits(profile)
            let kind: MVPHostKind = profile == .static ? .macOSStatic : .macOSDynamic
            func configuration(_ workload: SignalAnalyzerHostWorkload,
                               selected: RuntimeProfileLimits? = nil) -> HostStructuralConfiguration {
                .init(kind: kind, profile: profile, runtimeLimits: selected ?? limits,
                    runtimeAudit: unrelatedAudit, cardinality: P08CounterWorkload.cardinality,
                    workload: workload, pacing: P08CounterWorkload.pacing)
            }
            let workload = P08CounterWorkload.value(limits)
            precondition(SignalAnalyzerWorkloadStartupValidation.validate(configuration: configuration(workload)) == nil)
            checks += 1
            // The six new fields are independently checked below/equal/above,
            // including UInt32-to-UInt16 overflow, without body evaluation.
            let values: [UInt32] = [192, 4096, 48, 24, 5, 24]
            for axis in 0..<6 {
                for delta: UInt32 in 0...1 {
                    precondition(SignalAnalyzerWorkloadStartupValidation.validate(configuration:
                        configuration(p08Workload(workload, axis: axis, value: values[axis] - delta))) == nil)
                    checks += 1
                }
                precondition(SignalAnalyzerWorkloadStartupValidation.validate(configuration:
                    configuration(p08Workload(workload, axis: axis, value: values[axis] + 1))) == .insufficientWorkloadCapacity)
                checks += 1
            }
            precondition(SignalAnalyzerWorkloadStartupValidation.validate(configuration:
                configuration(p08Workload(workload, axis: 0, value: 65_536))) == .insufficientWorkloadCapacity)
            precondition(SignalAnalyzerWorkloadStartupValidation.validate(configuration:
                configuration(P08CounterWorkload.value(limits, schema: 3))) == .invalidWorkload)
            checks += 2
            for axis in 0..<4 {
                let badModels = RuntimeModelLimits(maximumModelSlots: axis == 0 ? 1 : 2,
                    maximumOwningTickets: axis == 1 ? 3 : 4,
                    maximumFramePins: axis == 2 ? 1 : 2, maximumModelCaptureBanks: axis == 3 ? 1 : 0)
                let badLimits = P08CounterWorkload.limits(profile, models: badModels)
                precondition(SignalAnalyzerWorkloadStartupValidation.validate(configuration:
                    configuration(P08CounterWorkload.value(badLimits), selected: badLimits)) == .insufficientWorkloadCapacity)
                checks += 1
            }
            let wrongActions = P08CounterWorkload.limits(profile, actionCount: 3)
            precondition(SignalAnalyzerWorkloadStartupValidation.validate(configuration:
                configuration(P08CounterWorkload.value(wrongActions), selected: wrongActions)) == .invalidWorkload)
            checks += 1
            for lastCode: UInt16 in [0, 1, 2, 5] {
                let action = HostActionModelConfiguration(firstActionCode: 0, lastActionCode: lastCode,
                    handlerCount: 1, rootModelTargetCount: 1,
                    sourceMinimumTransitionSpacingMicroseconds: 50_000,
                    maximumSourceCallbacksPerServiceWindow: 20, maximumCallbacksPerAction: 1,
                    maximumRepositoryCallbacksPerAction: 1, maximumUseCaseCallbacksPerAction: 1,
                    maximumNonTransitionPublicationsPerAction: 1, applicationExecutorFactLimit: 28,
                    factAdmissionAdapterCount: 1, targetGenerationIsPublishable: true,
                    actionHandlerIsTotal: true, retainsOwnerReferences: false, callbacksAreReentrant: false)
                let actual = HostApplicationStartupValidation.validateActionAndModel(action, structural: configuration(workload))
                precondition(actual == (lastCode == 1 ? nil : .invalidActionDomain))
                checks += 1
            }
        }
        return checks
    } catch { preconditionFailure("counter workload control identity") }
}
