import GiftUI
import GiftUIDrawing
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
import CycleSchema
@testable import RuntimeCycleProbe

// This is a concrete caller inside every actual supplying scope, not a generic
// signature taking an already constructed coordinator. It is compiled, not run.
func investigationPositiveCaller() -> Int {
    var modelNamespace = ObservableModelOwnerNamespace()
    var semanticNamespace = SemanticRecordOwnerNamespace()
    do {
        let modelOwner = try modelNamespace.issue()
        let semanticOwner = try semanticNamespace.issue()
        var profile = StaticCycleProfileStorage(modelOwner: modelOwner, semanticOwner: semanticOwner)
        guard case .valid(let audit) = profile.audit() else { preconditionFailure("actual profile audit") }
        let limits = profile.limits
        var root = consume profile.root
        var semantic = consume profile.semantic
        var semanticBacking = consume profile.semanticBacking
        var canvas = consume profile.canvas
        var canvasBacking = profile.canvasBacking
        var workspace = profile.workspace
        var interaction = profile.interaction.take()!
        var control = profile.control
        var checks = 0
        try root.withLifetime(limits: limits.observableState) { (models, root) throws(ObservableStateError) in
            do throws(SemanticExpansionError) {
                var records = semanticBacking.records.mutableSpan
                var paths = semanticBacking.paths.mutableSpan
                var payloads = semanticBacking.payloads.mutableSpan
                var scalars = semanticBacking.scalars.mutableSpan
                try semantic.withLifetime(configuredLimits: cycleSemanticConfiguration(limits),
                    records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) {
                    (semantic) throws(SemanticExpansionError) in
                    do throws(DrawingError) {
                        var entries = canvasBacking.mutableSpan
                        try canvas.withLifetime(entries: &entries, table: CycleValueTable(),
                            capacity: limits.drawing.maximumCanvasOccurrences, limits: limits.staticCanvas!) { values in
                            checks = workspace.withGeometry { geometry in
                                withUnsafeMutablePointer(to: &control) { pointer in
                                    let supplied = InvestigationSupplied(models: models.borrowedScope(),
                                        root: root.borrowedRoot(), semantic: semantic.borrowedStore(),
                                        values: values.borrowedValues(), control: pointer, audit: audit,
                                        geometry: geometry, interaction: interaction)
                                    var owner = InvestigationOwner(supplied: consume supplied)
                                    owner.activate()
                                    owner.quiesce()
                                    return 1
                                }
                            }
                        }
                    } catch { preconditionFailure("Canvas scope") }
                }
            } catch { preconditionFailure("semantic scope") }
        }
        return checks
    } catch { preconditionFailure("owner namespace or model scope") }
}
