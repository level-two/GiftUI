import GiftUI
import GiftUIDrawing
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
import CycleSchema

// Caller-only correction: lend the existing imported profile's stored backing
// in place. This extension adds no stored state and changes no imported module.
// All supplying scopes and first activate-time construction remain unchanged.
extension StaticCycleProfileStorage {
    mutating func investigationPositiveWithinBacking() -> Int {
        guard case .valid(let audit) = audit() else { preconditionFailure("actual profile audit") }
        let limits = self.limits
        var movedInteraction = interaction.take()
        var checks = 0
        do throws(ObservableStateError) {
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
                                        let activationToken = InvestigationActivationToken()
                                        let supplied = InvestigationSupplied(models: models.borrowedScope(),
                                            root: root.borrowedRoot(), semantic: semantic.borrowedStore(),
                                            values: values.borrowedValues(), control: pointer, token: activationToken, audit: audit,
                                            geometry: geometry, interaction: movedInteraction.take()!)
                                        var owner = InvestigationOwner(supplied: consume supplied)
                                        precondition(pointer.pointee.teardowns == 0)
                                        owner.activate()
                                        precondition(!pointer.pointee.unavailable)
                                        precondition(owner.runOpportunity())
                                        owner.quiesce()
                                        precondition(pointer.pointee.unavailable)
                                        precondition(pointer.pointee.teardowns == 1)
                                        return 5
                                    }
                                }
                            }
                        } catch { preconditionFailure("Canvas scope") }
                    }
                } catch { preconditionFailure("semantic scope") }
            }
        } catch { preconditionFailure("model scope") }
        return checks
    }
}

func investigationPositiveCaller() -> Int {
    var modelNamespace = ObservableModelOwnerNamespace()
    var semanticNamespace = SemanticRecordOwnerNamespace()
    do {
        let modelOwner = try modelNamespace.issue()
        let semanticOwner = try semanticNamespace.issue()
        var profile = StaticCycleProfileStorage(modelOwner: modelOwner, semanticOwner: semanticOwner)
        return profile.investigationPositiveWithinBacking()
    } catch { preconditionFailure("owner namespace") }
}
