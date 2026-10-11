import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUISemanticCore
@testable import RuntimeCycleProbe
@testable import GiftUIHostConfiguration

// Workload-stage controls use a separately audited runtime only as the inert
// structural record payload. They do not claim that it implements analyzer storage.
func p08Workload(_ w: SignalAnalyzerHostWorkload, axis: Int, value: UInt32) -> SignalAnalyzerHostWorkload {
    .init(schemaVersion: axis == 6 ? UInt16(value) : w.schemaVersion,
          requiredPathEntries: axis == 0 ? value : w.requiredPathEntries,
          requiredPayloadBytesPerBank: axis == 1 ? value : w.requiredPayloadBytesPerBank,
          requiredInteractionIdentityComponents: axis == 2 ? value : w.requiredInteractionIdentityComponents,
          requiredPathDepth: axis == 3 ? UInt16(value) : w.requiredPathDepth,
          requiredPathChildFanout: axis == 4 ? UInt16(value) : w.requiredPathChildFanout,
          
          requiredRuntimeLimits: w.requiredRuntimeLimits, semanticNodeOccurrences: w.semanticNodeOccurrences,
          semanticStructuralOccurrences: w.semanticStructuralOccurrences,
          renderSemanticScopeOccurrences: w.renderSemanticScopeOccurrences,
          layoutScopeOccurrences: w.layoutScopeOccurrences, maximumRenderTraversalDepth: w.maximumRenderTraversalDepth,
          renderTextLineCount: w.renderTextLineCount, positionedGlyphCount: w.positionedGlyphCount,
          ordinaryRenderOperations: w.ordinaryRenderOperations, inputEventsPerOpportunity: w.inputEventsPerOpportunity,
          semanticActionsPerOpportunity: w.semanticActionsPerOpportunity,
          completionFactsPerOpportunity: w.completionFactsPerOpportunity, drawing: w.drawing)
}
func p08ValidateWorkload(_ preset: GeneratedSignalAnalyzerPreset, _ workload: SignalAnalyzerHostWorkload, _ audit: RuntimeStorageAudit) -> HostConfigurationError? {
    SignalAnalyzerWorkloadStartupValidation.validate(configuration: .init(kind: preset.kind, profile: preset.profile,
        runtimeLimits: preset.runtimeLimits, runtimeAudit: audit, cardinality: preset.cardinality,
        workload: workload, pacing: preset.pacing))
}
package func p08Schema4Workload() -> Int {
    var ownerNamespace = ObservableModelOwnerNamespace()
    var semanticNamespace = SemanticRecordOwnerNamespace()
    do {
        let owner = try ownerNamespace.issue()
        let semanticOwner = try semanticNamespace.issue()
        let storage = StaticCycleProfileStorage(modelOwner: owner, semanticOwner: semanticOwner)
        guard case .valid(let audit) = storage.audit() else { preconditionFailure("actual backing audit") }
        var assertions = 1
        let presets = [GeneratedSignalAnalyzerPresets.macOSDynamic(), GeneratedSignalAnalyzerPresets.macOSStatic(),
                       GeneratedSignalAnalyzerPresets.raspberryPiDynamic(), GeneratedSignalAnalyzerPresets.nrf52840Static()]
        for preset in presets {
            precondition(preset.workload.schemaVersion == 4); assertions += 1
            precondition(p08ValidateWorkload(preset, preset.workload, audit) == nil); assertions += 1
            precondition(preset.runtimeLimits.semantic.maximumDepth == 34 && preset.runtimeLimits.semantic.maximumBodyEvaluations == 14 && preset.runtimeLimits.semantic.maximumModifierApplications == 50 && preset.runtimeLimits.layout.maximumDepth == 13); assertions += 1
            let values = [preset.workload.requiredPathEntries, preset.workload.requiredPayloadBytesPerBank,
                          preset.workload.requiredInteractionIdentityComponents, UInt32(preset.workload.requiredPathDepth),
                          UInt32(preset.workload.requiredPathChildFanout), UInt32(preset.workload.requiredIdentityComponentsPerKey)]
            for axis in 0..<6 {
                precondition(p08ValidateWorkload(preset, p08Workload(preset.workload, axis: axis, value: values[axis] - 1), audit) == nil)
                precondition(p08ValidateWorkload(preset, p08Workload(preset.workload, axis: axis, value: values[axis]), audit) == nil)
                precondition(p08ValidateWorkload(preset, p08Workload(preset.workload, axis: axis, value: values[axis] + 1), audit) == .insufficientWorkloadCapacity)
                precondition(p08ValidateWorkload(preset, p08Workload(preset.workload, axis: axis, value: 0), audit) == .invalidWorkload)
                assertions += 4
            }
            precondition(p08ValidateWorkload(preset, p08Workload(preset.workload, axis: 0, value: 65_536), audit) == .insufficientWorkloadCapacity); assertions += 1
            for schema: UInt32 in 0...3 {
                precondition(p08ValidateWorkload(preset, p08Workload(preset.workload, axis: 6, value: schema), audit) == .invalidWorkload); assertions += 1
            }
            // A scalar preset cannot manufacture a valid audit from unrelated backing.
            precondition(preset.validatedStorageAudit(storage: storage) == .invalid(.invariantViolation)); assertions += 1
        }
        return assertions
    } catch { preconditionFailure("namespace exhaustion") }
}
