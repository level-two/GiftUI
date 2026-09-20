import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIInteraction
import GiftUIRuntimeCore
import SignalAnalyzerPresentation
import SignalAnalyzerTargetHost
import Testing

private struct StaticNRFRuntimeCapture {
    private var storage:
        (
            UInt64, UInt64, UInt64, UInt64
        ) = (0, 0, 0, 0)
}

private struct StaticNRFRuntimeCanvasTable: StaticCanvasCallableTable {
    let callableCaseCount: UInt16

    init(callableCaseCount: UInt16 = 2) {
        self.callableCaseCount = callableCaseCount
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

@Test func staticNRFGeneratedMetadataRejectsWrongAssemblyAndCallableCount() {
    guard case .valid(let staticReport) = StaticSignalAnalyzerNRFAssembly.validate(),
        case .valid(let dynamicReport) = DynamicSignalAnalyzerPiAssembly.validate()
    else {
        Issue.record("Required assembly did not validate")
        return
    }

    let incomplete = StaticSignalAnalyzerNRFGeneratedMetadataFactory.make(
        assemblyReport: staticReport,
        canvasTable: StaticNRFRuntimeCanvasTable(callableCaseCount: 1)
    )
    switch consume incomplete {
    case nil:
        break
    case .some:
        Issue.record("Static nRF metadata accepted incomplete Canvas coverage")
    }

    let wrongAssembly = StaticSignalAnalyzerNRFGeneratedMetadataFactory.make(
        assemblyReport: dynamicReport,
        canvasTable: StaticNRFRuntimeCanvasTable()
    )
    switch consume wrongAssembly {
    case nil:
        break
    case .some:
        Issue.record("Static nRF metadata accepted another assembly report")
    }
}

@Test func staticNRFRuntimeStorageOwnsOneValidatedCompositionLifetime() {
    withStaticNRFRuntimeProfileStorage { profileStorage in
        guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate(),
            let metadata = StaticSignalAnalyzerNRFGeneratedMetadataFactory.make(
                assemblyReport: report,
                canvasTable: StaticNRFRuntimeCanvasTable()
            ),
            var runtime = StaticSignalAnalyzerNRFRuntimeStorage(
                assemblyReport: report,
                inputSourceRawValue: 51,
                profileStorage: profileStorage,
                metadata: metadata
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

@Test func staticNRFGeneratedMetadataBindsRootActionsAndCanvasCoverage() {
    guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate(),
        let metadata = StaticSignalAnalyzerNRFGeneratedMetadataFactory.make(
            assemblyReport: report,
            canvasTable: StaticNRFRuntimeCanvasTable()
        ),
        let root = GeneratedSignalAnalyzerPresets.nrf52840Static().staticRoot
    else {
        Issue.record("Static nRF generated metadata did not construct")
        return
    }

    #expect(metadata.observableSlots.slotCount == 1)
    #expect(metadata.observableSlots.structuralIdentity(for: 0) == root.structuralIdentity)
    #expect(metadata.observableSlots.structuralIdentity(for: 1) == nil)
    for action in SignalAnalyzerAction.allCasesForStaticMetadataTest {
        let encoded = BoundedApplicationAction(code: action.rawValue)
        #expect(metadata.actionSpecialization.decode(encoded) == action)
    }
    #expect(
        metadata.actionSpecialization.decode(BoundedApplicationAction(code: 6)) == nil
    )
    #expect(metadata.callableCaseCount == 2)
    #expect(metadata.declaredEntryCount == 2)
    #expect(metadata.maximumDeclaredID == 2)
    #expect(metadata.coverageMultiplicity(for: 0) == 0)
    #expect(metadata.coverageMultiplicity(for: 1) == 1)
    #expect(metadata.coverageMultiplicity(for: 2) == 1)
    #expect(metadata.coverageMultiplicity(for: 3) == 0)
}

@Test func staticNRFRuntimeStorageRejectsAnotherAssemblyReport() {
    withStaticNRFRuntimeProfileStorage { profileStorage in
        guard case .valid(let staticReport) = StaticSignalAnalyzerNRFAssembly.validate(),
            let metadata = StaticSignalAnalyzerNRFGeneratedMetadataFactory.make(
                assemblyReport: staticReport,
                canvasTable: StaticNRFRuntimeCanvasTable()
            ),
            case .valid(let report) = DynamicSignalAnalyzerPiAssembly.validate()
        else {
            Issue.record("Required assembly did not validate")
            return
        }
        let runtime = StaticSignalAnalyzerNRFRuntimeStorage(
            assemblyReport: report,
            inputSourceRawValue: 51,
            profileStorage: profileStorage,
            metadata: metadata
        )
        switch consume runtime {
        case nil:
            break
        case .some:
            Issue.record("Static nRF runtime storage accepted another assembly report")
        }
    }
}

private extension SignalAnalyzerAction {
    static var allCasesForStaticMetadataTest: [SignalAnalyzerAction] {
        [.start, .stop, .clear, .selectOneSecond, .selectTwoSeconds, .selectFiveSeconds]
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
