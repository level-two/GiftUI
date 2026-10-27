import CycleSchema
import GiftUI
import GiftUIDrawing
import GiftUIHostConfiguration
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore

// Caller-only correction: lend the existing imported profile's stored backing
// in place. This extension adds no stored state and changes no imported module.
// All supplying scopes and first activate-time construction remain unchanged.
extension StaticCycleProfileStorage {
    mutating func p08ActivationWithinBacking(seed: UInt8, failAfterRuntime: Bool) -> Int {
        guard case .valid(let audit) = audit() else { preconditionFailure("actual profile audit") }
        let limits = self.limits
        var movedInteraction = interaction.take()
        var checks = 0
        do throws(ObservableStateError) {
            try root.withLifetime(limits: limits.observableState) {
                (models, root) throws(ObservableStateError) in
                do throws(SemanticExpansionError) {
                    var records = semanticBacking.records.mutableSpan
                    var paths = semanticBacking.paths.mutableSpan
                    var payloads = semanticBacking.payloads.mutableSpan
                    var scalars = semanticBacking.scalars.mutableSpan
                    try semantic.withLifetime(
                        configuredLimits: cycleSemanticConfiguration(limits),
                        records: &records, paths: &paths, payloads: &payloads, scalars: &scalars
                    ) {
                        (semantic) throws(SemanticExpansionError) in
return try semanticPending.withLifetime { semanticCodec in
                        do throws(DrawingError) {
                            var entries = canvasBacking.mutableSpan
                            try canvas.withLifetime(
                                entries: &entries, table: CycleValueTable(),
                                capacity: limits.drawing.maximumCanvasOccurrences,
                                limits: limits.staticCanvas!
                            ) { values in
                                checks = workspace.withGeometry { geometry in
                                    withUnsafeMutablePointer(to: &control) { pointer in
                                        p08InvokeActivationCallback {
                                            let activationBacking: InlineArray<1, UInt8> = [seed]
                                            let supplied = P08ActivationSupplied(
                                                models: models.borrowedScope(),
                                                root: root.borrowedRoot(),
                                                semantic: semantic.borrowedStore(), semanticCodec: copy semanticCodec,
                                                values: values.borrowedValues(), control: pointer,
                                                audit: audit,
                                                geometry: geometry,
                                                interaction: movedInteraction.take()!)
                                            let owner = P08ActivationOwner(
                                                supplied: consume supplied,
                                                activationSpan: activationBacking.span,
                                                failAfterRuntime: failAfterRuntime)
                                            let report = p08ActivationComponentReport(audit)
                                            var host =
                                                SignalAnalyzerPresetHostInstances.macOSStatic(
                                                    report: report, owner: consume owner)!
                                            precondition(
                                                host.lifecycleState == .valid
                                                    && host.owner.constructions == 0
                                                    && pointer.pointee.teardowns == 0)
                                            precondition(host.runOpportunity() == .invalidLifecycle)
                                            var assertions = 2
                                            let activation = host.activate()
                                            precondition(host.owner.constructions == 1)
                                            assertions += 1
                                            if failAfterRuntime {
                                                precondition(
                                                    activation
                                                        == .failure(
                                                            .configuration(.arithmeticOverflow))
                                                        && host.lifecycleState == .failed)
                                                precondition(
                                                    host.owner.traceCount == 3
                                                        && host.owner.trace[0] == 1
                                                        && host.owner.trace[1] == 9
                                                        && host.owner.trace[2] == 10)
                                                precondition(
                                                    pointer.pointee.unavailable
                                                        && pointer.pointee.teardowns == 1)
                                                precondition(
                                                    host.runOpportunity() == .invalidLifecycle)
                                                assertions += 4
                                            } else {
                                                precondition(
                                                    activation == .active
                                                        && !pointer.pointee.unavailable)
                                                precondition(host.owner.traceCount == 7)
                                                for i in 0 ..< 7 {
                                                    precondition(
                                                        host.owner.trace[i] == UInt8(i + 1))
                                                    assertions += 1
                                                }
                                                guard case .cycle(.success) = host.runOpportunity()
                                                else {
                                                    preconditionFailure("real accepted opportunity")
                                                }
                                                assertions += 3
                                            }
                                            let before = host.owner.traceCount
                                            precondition(
                                                host.activate() == .failure(.invariant)
                                                    && host.owner.constructions == 1
                                                    && host.owner.traceCount == before)
                                            assertions += 1
                                            host.teardown()
                                            precondition(
                                                host.lifecycleState == .quiescent
                                                    && !host.controller
                                                        .assemblyReportRuntimeUseIsValid
                                                    && host.controller.progress == .init())
                                            precondition(
                                                pointer.pointee.unavailable
                                                    && pointer.pointee.teardowns == 1)
                                            precondition(host.owner.traceCount == before + 8)
                                            assertions += 3
                                            for i in 0 ..< 8 {
                                                precondition(
                                                    host.owner.trace[before + i] == UInt8(11 + i))
                                                assertions += 1
                                            }
                                            host.teardown()
                                            precondition(
                                                host.owner.traceCount == before + 8
                                                    && host.runOpportunity() == .invalidLifecycle)
                                            precondition(host.assemblyReport == report)
                                            assertions += 2
                                            return assertions
                                        }
                                    }
                                }
                            }
                        } catch { preconditionFailure("Canvas scope") }

}
}
                } catch { preconditionFailure("semantic scope") }
            }
        } catch { preconditionFailure("model scope") }
        return checks
    }
}

@inline(never)
func p08ActivationCaller(seed: UInt8, failAfterRuntime: Bool) -> Int {
    var modelNamespace = ObservableModelOwnerNamespace()
    var semanticNamespace = SemanticRecordOwnerNamespace()
    do {
        let modelOwner = try modelNamespace.issue()
        let semanticOwner = try semanticNamespace.issue()
        var profile = StaticCycleProfileStorage(
            modelOwner: modelOwner, semanticOwner: semanticOwner)
        let checks = profile.p08ActivationWithinBacking(
            seed: seed, failAfterRuntime: failAfterRuntime)
        return checks
    } catch { preconditionFailure("owner namespace") }
}

package func p08ActivationJoin() -> Int {
    p08ActivationCaller(seed: 1, failAfterRuntime: false)
        + p08ActivationCaller(seed: 1, failAfterRuntime: true)
}
