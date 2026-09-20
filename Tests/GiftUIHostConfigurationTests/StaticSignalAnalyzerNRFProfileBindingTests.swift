import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIRuntimeCore
import SignalAnalyzerTargetHost
import Testing

private struct StaticNRFBindingCapture {
    private var storage:
        (
            UInt64, UInt64, UInt64, UInt64
        ) = (0, 0, 0, 0)
}

private struct StaticNRFBindingMetadata:
    RuntimeStaticCanvasAuditMetadata, StaticCanvasCallableTable
{
    let callableCaseCount: UInt16 = 2
    let declaredEntryCount: UInt16 = 2
    let maximumDeclaredID: UInt16 = 2

    func coverageMultiplicity(for id: UInt16) -> UInt8 {
        id == 1 || id == 2 ? 1 : 0
    }

    func captureByteCount(for id: UInt16) -> UInt16? {
        switch id {
        case 1: 0
        case 2: UInt16(MemoryLayout<StaticNRFBindingCapture>.size)
        default: nil
        }
    }

    mutating func invoke(
        id: UInt16,
        captures: borrowing StaticNRFBindingCapture,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        guard id == 1 || id == 2 else { throw .invariantViolation }
    }
}

@Test func staticNRFProfileBindingOwnsTheExactRuntimeLifecycle() {
    withProfileBindingStorage { storage in
        guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate(),
            var binding = StaticSignalAnalyzerNRFProfileBinding.make(
                assemblyReport: report,
                storage: storage,
                metadata: StaticNRFBindingMetadata()
            )
        else {
            Issue.record("Static nRF profile binding did not construct")
            return
        }
        let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
        #expect(binding.storageAudit == preset.validatedStorageAudit().audit)
        #expect(binding.storageLifetimeState == .beforeUse)

        storage.initializeMemory(as: UInt8.self, repeating: 0xA5)
        let active = ExecutionContext(
            cycle: RunCycleID(rawValue: 1),
            semanticRevision: nil,
            candidateFrame: nil,
            phase: .admitting
        )
        #expect(binding.beginOpportunity(context: active) == nil)
        #expect(binding.storageLifetimeState == .attemptActive)
        let idle = ExecutionContext(
            cycle: nil,
            semanticRevision: nil,
            candidateFrame: nil,
            phase: .idle
        )
        #expect(binding.finishOpportunity(context: idle) == nil)
        #expect(nonzeroByteCount(in: storage) == 8_144)

        binding.quiesce()
        let isQuiescent = binding.isQuiescent
        let lifetimeState = binding.storageLifetimeState
        #expect(isQuiescent)
        #expect(lifetimeState == .tornDown)
        #expect(nonzeroByteCount(in: storage) == 0)
    }
}

@Test func staticNRFProfileBindingRejectsAnotherAssemblyReport() {
    withProfileBindingStorage { storage in
        guard case .valid(let report) = DynamicSignalAnalyzerPiAssembly.validate() else {
            Issue.record("Dynamic Pi assembly did not validate")
            return
        }
        let binding = StaticSignalAnalyzerNRFProfileBinding.make(
            assemblyReport: report,
            storage: storage,
            metadata: StaticNRFBindingMetadata()
        )
        switch consume binding {
        case nil:
            break
        case .some:
            Issue.record("Static nRF profile binding accepted another assembly report")
        }
    }
}

private func withProfileBindingStorage(
    _ body: (UnsafeMutableRawBufferPointer) -> Void
) {
    let byteCount = StaticSignalAnalyzerNRFProfileRegions.requiredByteCount
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: 8)
    defer { pointer.deallocate() }
    body(UnsafeMutableRawBufferPointer(start: pointer, count: byteCount))
}

private func nonzeroByteCount(in storage: UnsafeMutableRawBufferPointer) -> Int {
    storage.reduce(into: 0) { count, byte in
        if byte != 0 { count += 1 }
    }
}

private extension RuntimeProfileValidationResult {
    var audit: RuntimeStorageAudit? {
        guard case .valid(let audit) = self else { return nil }
        return audit
    }
}
