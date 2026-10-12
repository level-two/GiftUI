import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore

extension StaticCounterProfileStorage {
    mutating func rejectCounterHostEscape(failAfterRuntime: Bool) -> Int {
        var escaped: SignalAnalyzerPresetHostInstance<CounterHostOwner>? = nil
        guard case .valid(let audit) = audit(), let assembly = CounterHostAssembly.validate(audit, kind: .macOSStatic) else { preconditionFailure("counter valid-only host") }
        let ownedChecks = 0
        let limits = self.limits
        var keys = interaction.take()
        var checks = 0
        do throws(ObservableStateError) {
            try root.withLifetime(limits: limits.observableState) { (models, root) throws(ObservableStateError) in
                do throws(SemanticExpansionError) {
                    var records = semanticBacking.records.mutableSpan
                    var paths = semanticBacking.paths.mutableSpan
                    var payloads = semanticBacking.payloads.mutableSpan
                    var scalars = semanticBacking.scalars.mutableSpan
                    try semantic.withLifetime(configuredLimits: counterSemanticConfiguration(limits), records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) { (semantic) throws(SemanticExpansionError) in
                        do throws(DrawingError) {
                            var entries = canvasBacking.mutableSpan
                            try canvas.withLifetime(entries: &entries, table: CounterValueTable(), capacity: 1, limits: limits.staticCanvas!) { values in
                                checks = workspace.withGeometry { geometry in
                                    withUnsafeMutablePointer(to: &control) { pointer in
                                        let activationBacking: InlineArray<1, UInt8> = [1]
                                        let supplied = CounterHostSupplied(models: models.borrowedScope(), root: root.borrowedRoot(), semantic: semantic.borrowedStore(), values: values.borrowedValues(), control: pointer, audit: audit, geometry: geometry, interaction: keys.take()!)
                                        let owner = CounterHostOwner(supplied: consume supplied, activationSpan: activationBacking.span, assembly: assembly, failAfterRuntime: failAfterRuntime)
                                        var host = SignalAnalyzerPresetHostInstances.macOSStatic(report: assembly.report, owner: consume owner)!
                                        _ = host.activate()
                                        escaped = consume host
                                        return 1
                                    }
                                }
                            }
                        } catch { preconditionFailure("counter host Canvas") }
                    }
                } catch { preconditionFailure("counter host semantics") }
            }
        } catch { preconditionFailure("counter host model") }
        var escapedOwner = escaped.take()!
        _ = escapedOwner.runOpportunity()
        escapedOwner.teardown()
        return checks + ownedChecks
    }
}

