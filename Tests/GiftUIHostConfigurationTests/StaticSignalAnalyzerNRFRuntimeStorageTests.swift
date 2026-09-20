import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIRuntimeCore
import SignalAnalyzerTargetHost
import Testing

private struct StaticNRFRuntimeCapture {
    private var storage:
        (
            UInt64, UInt64, UInt64, UInt64
        ) = (0, 0, 0, 0)
}

private struct StaticNRFRuntimeMetadata:
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
        case 2: UInt16(MemoryLayout<StaticNRFRuntimeCapture>.size)
        default: nil
        }
    }

    mutating func invoke(
        id: UInt16,
        captures: borrowing StaticNRFRuntimeCapture,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        guard id == 1 || id == 2 else { throw .invariantViolation }
    }
}

@Test func staticNRFRuntimeStorageOwnsOneValidatedCompositionLifetime() {
    withStaticNRFRuntimeProfileStorage { profileStorage in
        guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate(),
            var runtime = StaticSignalAnalyzerNRFRuntimeStorage(
                assemblyReport: report,
                inputSourceRawValue: 51,
                profileStorage: profileStorage,
                metadata: StaticNRFRuntimeMetadata()
            )
        else {
            Issue.record("Static nRF runtime storage did not construct")
            return
        }

        runtime.withAddressStableOwners { application, profile in
            let rootIsActive = application.rootIsActive
            let lifetimeBeforeUse = profile.storageLifetimeState
            #expect(!rootIsActive)
            #expect(lifetimeBeforeUse == .beforeUse)
            let active = ExecutionContext(
                cycle: RunCycleID(rawValue: 1),
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .admitting
            )
            #expect(profile.beginOpportunity(context: active) == nil)
            let idle = ExecutionContext(
                cycle: nil,
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .idle
            )
            #expect(profile.finishOpportunity(context: idle) == nil)
        }

        let profileIsQuiescent = runtime.profile.isQuiescent
        let profileLifetime = runtime.profile.storageLifetimeState
        let rootIsActive = runtime.application.root.isActive
        #expect(profileIsQuiescent)
        #expect(profileLifetime == .tornDown)
        #expect(!rootIsActive)
    }
}

@Test func staticNRFRuntimeStorageRejectsAnotherAssemblyReport() {
    withStaticNRFRuntimeProfileStorage { profileStorage in
        guard case .valid(let report) = DynamicSignalAnalyzerPiAssembly.validate() else {
            Issue.record("Dynamic Pi assembly did not validate")
            return
        }
        let runtime = StaticSignalAnalyzerNRFRuntimeStorage(
            assemblyReport: report,
            inputSourceRawValue: 51,
            profileStorage: profileStorage,
            metadata: StaticNRFRuntimeMetadata()
        )
        switch consume runtime {
        case nil:
            break
        case .some:
            Issue.record("Static nRF runtime storage accepted another assembly report")
        }
    }
}

private func withStaticNRFRuntimeProfileStorage(
    _ body: (UnsafeMutableRawBufferPointer) -> Void
) {
    let byteCount = StaticSignalAnalyzerNRFProfileRegions.requiredByteCount
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: 8)
    defer { pointer.deallocate() }
    body(UnsafeMutableRawBufferPointer(start: pointer, count: byteCount))
}
