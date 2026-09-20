import GiftUIHostConfiguration
import GiftUIInteraction
import GiftUIRuntimeStatic
import SignalAnalyzerPresentation

/// Caller-owned, address-stable storage for the generated Static nRF
/// application join. Construction remains inert and requires the exact
/// validated assembly report.
package struct StaticSignalAnalyzerNRFApplicationStorage: ~Copyable {
    package let assemblyReport: HostAssemblyReport
    package var root: StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>
    package var interaction: StaticInteractionState<UInt32>
    package var input: StaticSignalAnalyzerNRFApplicationInputOwner

    package init?(
        assemblyReport: HostAssemblyReport,
        inputSourceRawValue: UInt16
    ) {
        let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
        guard StaticSignalAnalyzerNRFAssembly.validate() == .valid(assemblyReport),
            let descriptor = preset.staticRoot,
            let candidateRecords = StaticInteractionCandidateStorage<UInt32>(
                capacity: preset.runtimeLimits.interaction.maximumActions
            ),
            let candidateHitRegions = StaticInteractionHitStorage<UInt32>(
                capacity: preset.runtimeLimits.interaction.maximumHitRegions
            ),
            let candidateCommittedRecords = StaticInteractionCommittedStorage<UInt32>(
                capacity: preset.runtimeLimits.interaction.maximumActions
            ),
            let committedRecords = StaticInteractionCommittedStorage<UInt32>(
                capacity: preset.runtimeLimits.interaction.maximumActions
            ),
            let committedHitRegions = StaticInteractionHitStorage<UInt32>(
                capacity: preset.runtimeLimits.interaction.maximumHitRegions
            )
        else { return nil }

        self.assemblyReport = assemblyReport
        root = StaticObservableRootAdapter(
            structuralIdentity: descriptor.structuralIdentity,
            declarationOrdinal: descriptor.declarationOrdinal
        )
        interaction = StaticInteractionState(
            candidateRecords: candidateRecords,
            candidateHitRegions: candidateHitRegions,
            candidateCommittedRecords: candidateCommittedRecords,
            committedRecords: committedRecords,
            committedHitRegions: committedHitRegions
        )
        input = StaticSignalAnalyzerNRFApplicationInputOwner(
            sourceRawValue: inputSourceRawValue
        )
    }
}
