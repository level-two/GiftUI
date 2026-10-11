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
    mutating func rejectActiveAfterCallbacks(seed: UInt8) -> Int {
        var escaped: P08ActivationHost? = nil
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
                                                semantic: semantic.borrowedStore(),
                                                values: values.borrowedValues(), control: pointer,
                                                audit: audit,
                                                geometry: geometry,
                                                interaction: movedInteraction.take()!)
                                            let suppliedOwner = P08ActivationOwner(
                                                supplied: consume supplied,
                                                activationSpan: activationBacking.span)
                                            var owner =
                                                SignalAnalyzerPresetHostInstances.macOSStatic(
                                                    report: p08ActivationComponentReport(audit),
                                                    owner: consume suppliedOwner)!
                                            precondition(pointer.pointee.teardowns == 0)
                                            owner.activate()
                                            precondition(!pointer.pointee.unavailable)
                                            escaped = consume owner
                                            return 1
                                        }
                                    }
                                }
                            }
                        } catch { preconditionFailure("Canvas scope") }
                    }
                } catch { preconditionFailure("semantic scope") }
            }
        } catch { preconditionFailure("model scope") }
        var escapedOwner = escaped.take()!
        _ = escapedOwner.runOpportunity()
        escapedOwner.quiesce()
        return checks
    }
}

@main struct CallbackNegativeMain {
    static func main() {
        var models = ObservableModelOwnerNamespace()
        var semantic = SemanticRecordOwnerNamespace()
        do {
            var profile = StaticCycleProfileStorage(
                modelOwner: try models.issue(), semanticOwner: try semantic.issue())
            print(
                profile.rejectActiveAfterCallbacks(
                    seed: UInt8(truncatingIfNeeded: CommandLine.arguments.count) | 1))
        } catch { preconditionFailure("namespace setup") }
    }
}
