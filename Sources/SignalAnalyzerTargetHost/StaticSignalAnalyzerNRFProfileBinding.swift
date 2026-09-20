import GiftUIDrawing
import GiftUIHostConfiguration
import GiftUIRuntimeCore
import GiftUIRuntimeStatic

/// Constructs the generated Static runtime binding only after the exact nRF
/// assembly report and caller-owned profile workspace have been validated.
package enum StaticSignalAnalyzerNRFProfileBinding {
    package static func make<Metadata>(
        assemblyReport: HostAssemblyReport,
        storage: UnsafeMutableRawBufferPointer,
        metadata: consuming Metadata
    ) -> StaticRuntimeProfileBinding<StaticSignalAnalyzerNRFProfileRegions, Metadata>?
    where
        Metadata: RuntimeStaticCanvasAuditMetadata & StaticCanvasCallableTable
    {
        let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
        guard StaticSignalAnalyzerNRFAssembly.validate() == .valid(assemblyReport),
            preset.profile == .static,
            metadata.callableCaseCount == preset.workload.drawing.staticCallableCases,
            greatestCaptureByteCount(in: metadata)
                == preset.workload.drawing.maximumStaticCaptureBytes,
            let root = preset.staticRoot,
            let identity = StaticStructuralIdentity(rawValue: root.structuralIdentity),
            let regions = StaticSignalAnalyzerNRFProfileRegions(storage: storage),
            regions.byteCounts == preset.expectedStorageBytes
        else { return nil }

        return StaticRuntimeProfileBinding(
            structuralIdentity: identity,
            limits: preset.runtimeLimits,
            regions: consume regions,
            metadata: consume metadata
        )
    }

    private static func greatestCaptureByteCount<Metadata>(
        in metadata: borrowing Metadata
    ) -> UInt16? where Metadata: RuntimeStaticCanvasAuditMetadata {
        guard metadata.callableCaseCount > 0 else { return nil }
        var greatest: UInt16 = 0
        var id: UInt16 = 1
        while true {
            guard let byteCount = metadata.captureByteCount(for: id) else {
                return nil
            }
            greatest = max(greatest, byteCount)
            if id == metadata.callableCaseCount { return greatest }
            id += 1
        }
    }
}
