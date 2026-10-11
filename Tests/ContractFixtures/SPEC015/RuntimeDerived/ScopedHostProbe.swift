import GiftUIObservableState
import GiftUIRuntimeStatic
import GiftUIRuntimeCore
import GiftUIExecution
@testable import GiftUIHostConfiguration

// Component control: the real model backing lends this inert activation owner.
// It records the controller protocol, not a complete validated application host.
enum P08HostSchema {}
typealias P08HostFailure = MacOSStaticHostActivationFailure
struct P08ScopedLiveOwner: ~Copyable, ~Escapable, SignalAnalyzerPresetLiveOwner {
    typealias ActivationFailure = P08HostFailure
    let models: ObservableModelScope<UInt8, P08HostSchema>
    let trace: UnsafeMutablePointer<UInt8>
    let count: UnsafeMutablePointer<Int>
    let failAt: UInt8
    @_lifetime(copy models)
    init(models: borrowing ObservableModelScope<UInt8, P08HostSchema>, trace: UnsafeMutablePointer<UInt8>, count: UnsafeMutablePointer<Int>, failAt: UInt8) {
        self.models = models.borrowedScope()
        self.trace = trace
        self.count = count
        self.failAt = failAt
    }
    mutating func record(_ step: UInt8) {
        trace[count.pointee] = step
        count.pointee += 1
    }
    mutating func advance(_ step: UInt8) -> HostActivationStepResult<P08HostFailure> {
        record(step)
        return failAt == step ? .failure(.configuration(.arithmeticOverflow), progress: .init()) : .advanced
    }
    mutating func constructRuntimeAndEndpoint() -> HostActivationStepResult<P08HostFailure> { advance(1) }
    mutating func constructApplicationOwners() -> HostActivationStepResult<P08HostFailure> { advance(2) }
    mutating func attachRootModelInFirstCandidate() -> HostActivationStepResult<P08HostFailure> { advance(3) }
    mutating func installRepositoryObservationAndAdmitCurrentValues() -> HostActivationStepResult<P08HostFailure> { advance(4) }
    mutating func acceptFirstPresentationAndEnableInput() -> HostActivationStepResult<P08HostFailure> { advance(5) }
    mutating func startAcquisitionThroughApplicationOpportunity() -> HostActivationStepResult<P08HostFailure> { advance(6) }
    mutating func establishWakeAndPacingHostLoop() -> HostActivationStepResult<P08HostFailure> { advance(7) }
    mutating func stopSourceDeliveryAndRepositoryObservation() { record(8) }
    mutating func preventInputEligibility() { record(9) }
    mutating func quiesceConstructedRuntime() { record(10) }
    mutating func refuseApplicationDeliveryAndInput() { record(11) }
    mutating func stopSourceDeliveryAndDetachObservations() { record(12) }
    mutating func cancelPointerSequencesAndHostCallbacks() { record(13) }
    mutating func quiesceRuntimeAndFinalizeActiveCycle() { record(14) }
    mutating func retireObservableRegistrationAndRouting() { record(15) }
    mutating func releasePlatformOwners() { record(16) }
    mutating func resetProfileStorage() { record(17) }
    mutating func invalidateAssemblyReportRuntimeUse() { record(18) }
    mutating func runOpportunity() -> RunCycleResult<RuntimeOwnerFailure> { fatalError("component control does not execute a runtime") }
}
// Compile the actual concrete host return against the approved dependent owner.
// The report is supplied by the caller; this is not validation evidence.
@_lifetime(copy owner)
func p08Construct(report: HostAssemblyReport, owner: consuming P08ScopedLiveOwner)
    -> HostPresetConstructionResult<SignalAnalyzerPresetHostInstance<P08ScopedLiveOwner>> {
    guard let host = SignalAnalyzerPresetHostInstances.macOSStatic(report: report, owner: consume owner)
    else { return .invalid(.invalid(stage: .graph, error: .invalidGraph)) }
    return .constructed(consume host)
}
package func p08ScopedHostController() -> Int {
    var assertions = 0
    var namespace = ObservableModelOwnerNamespace()
    do {
        let identity = try namespace.issue()
        var storage = StaticObservableModelStorage<UInt8, P08HostSchema>(identity: identity, schema: 1, needsCapture: false)!
        for failure in UInt8(0)...7 {
            var trace = InlineArray<32, UInt8>(repeating: 0)
            var count = 0
            try storage.withLifetime { models in
                withUnsafeMutablePointer(to: &count) { countPointer in
                    var span = trace.mutableSpan
                    span.withUnsafeMutableBufferPointer { buffer in
                        var owner = P08ScopedLiveOwner(models: models, trace: buffer.baseAddress!, count: countPointer, failAt: failure)
                        var controller = MVPHostActivationController<P08HostFailure>()
                        precondition(controller.lifecycleState == .valid && countPointer.pointee == 0); assertions += 1
                        let result = controller.activate(owner: &owner, invariantFailure: .invariant)
                        if failure == 0 {
                            precondition(result == .active && controller.lifecycleState == .active)
                            precondition(countPointer.pointee == 7)
                            for index in 0..<7 { precondition(buffer[index] == UInt8(index + 1)); assertions += 1 }
                        } else {
                            precondition(result == .failure(.configuration(.arithmeticOverflow)) && controller.lifecycleState == .failed)
                            let expectedContainment: [UInt8] = failure == 1 ? [9] : failure <= 4 ? [9, 10] : [8, 9, 10]
                            precondition(countPointer.pointee == Int(failure) + expectedContainment.count)
                            for index in 0..<Int(failure) { precondition(buffer[index] == UInt8(index + 1)); assertions += 1 }
                            for (index, value) in expectedContainment.enumerated() { precondition(buffer[Int(failure) + index] == value); assertions += 1 }
                        }
                        assertions += 2
                        let before = countPointer.pointee
                        precondition(controller.activate(owner: &owner, invariantFailure: .invariant) == .failure(.invariant))
                        precondition(countPointer.pointee == before); assertions += 2
                        controller.teardown(owner: &owner)
                        precondition(controller.lifecycleState == .quiescent && !controller.assemblyReportRuntimeUseIsValid)
                        precondition(controller.progress == .init())
                        precondition(countPointer.pointee == before + 8); assertions += 3
                        for index in 0..<8 { precondition(buffer[before + index] == UInt8(11 + index)); assertions += 1 }
                        controller.teardown(owner: &owner)
                        precondition(countPointer.pointee == before + 8); assertions += 1
                    }
                }
            }
        }
    } catch { preconditionFailure("model backing control failed") }
    return assertions
}

// An ordinary owned conformer still produces an Escapable concrete host.
func p08OwnedHostCompatibility<Owner: SignalAnalyzerPresetLiveOwner>(
    report: HostAssemblyReport, owner: consuming Owner
) where Owner.ActivationFailure == MacOSStaticHostActivationFailure {
    let host = SignalAnalyzerPresetHostInstances.macOSStatic(report: report, owner: consume owner)
    p08RequireEscapable(host)
}
func p08RequireEscapable<T: ~Copyable>(_ value: borrowing T) {}
