import GiftUIDrawing
import GiftUIHostConfiguration
import GiftUIRuntimeStatic
import SignalAnalyzerPresentation

package struct StaticSignalAnalyzerNRFObservableSlots:
    StaticObservableSlotMetadata
{
    package let slotCount: UInt16 = 1
    private let rootIdentity: UInt32

    fileprivate init(rootIdentity: UInt32) {
        self.rootIdentity = rootIdentity
    }

    package func structuralIdentity(for slot: UInt16) -> UInt32? {
        slot == 0 ? rootIdentity : nil
    }
}

package struct StaticSignalAnalyzerNRFCanvasCoverage:
    StaticCanvasCoverageMetadata
{
    package let declaredEntryCount: UInt16 = 2
    package let maximumDeclaredID: UInt16 = 2

    fileprivate init() {}

    package func coverageMultiplicity(for id: UInt16) -> UInt8 {
        id == 1 || id == 2 ? 1 : 0
    }
}

package typealias StaticSignalAnalyzerNRFGeneratedMetadata<CanvasTable> =
    StaticGeneratedProfileMetadata<
        StaticSignalAnalyzerNRFObservableSlots,
        SignalAnalyzerAction,
        CanvasTable,
        StaticSignalAnalyzerNRFCanvasCoverage
    > where CanvasTable: StaticCanvasCallableTable

/// Joins the generated root, action domain, and Canvas coverage around the
/// concrete generated callable table selected by the Static target build.
package enum StaticSignalAnalyzerNRFGeneratedMetadataFactory {
    package static func make<CanvasTable>(
        assemblyReport: HostAssemblyReport,
        canvasTable: consuming CanvasTable
    ) -> StaticSignalAnalyzerNRFGeneratedMetadata<CanvasTable>?
    where CanvasTable: StaticCanvasCallableTable {
        let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
        guard StaticSignalAnalyzerNRFAssembly.validate() == .valid(assemblyReport),
            let root = preset.staticRoot,
            canvasTable.callableCaseCount == preset.workload.drawing.staticCallableCases,
            let metadata: StaticSignalAnalyzerNRFGeneratedMetadata<CanvasTable> =
                StaticGeneratedProfileMetadata(
                    observableSlots: StaticSignalAnalyzerNRFObservableSlots(
                        rootIdentity: root.structuralIdentity
                    ),
                    action: SignalAnalyzerAction.self,
                    canvasTable: consume canvasTable,
                    canvasCoverage: StaticSignalAnalyzerNRFCanvasCoverage()
                ),
            StaticCanvasHostValidation.validate(
                limits: preset.runtimeLimits.staticCanvas,
                metadata: metadata
            ) == nil
        else { return nil }
        return metadata
    }
}
