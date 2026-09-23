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
    let secondCaptureByteCount: UInt16
    let callableCaseCount: UInt16
    let declaredEntryCount: UInt16
    let maximumDeclaredID: UInt16

    init(callableCaseCount: UInt16 = 2, secondCaptureByteCount: UInt16 = 32) {
        self.callableCaseCount = callableCaseCount
        declaredEntryCount = callableCaseCount
        maximumDeclaredID = callableCaseCount
        self.secondCaptureByteCount = secondCaptureByteCount
    }

    func coverageMultiplicity(for id: UInt16) -> UInt8 {
        id > 0 && id <= callableCaseCount ? 1 : 0
    }

    func captureByteCount(for id: UInt16) -> UInt16? {
        switch id {
        case 1: 0
        case 2: secondCaptureByteCount
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

@Test func staticNRFProfileBindingRequiresExactGeneratedCanvasMetadata() {
    withProfileBindingStorage { storage in
        guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate() else {
            Issue.record("Static nRF assembly did not validate")
            return
        }
        let invalidMetadata = [
            StaticNRFBindingMetadata(callableCaseCount: 1),
            StaticNRFBindingMetadata(secondCaptureByteCount: 31),
        ]
        for metadata in invalidMetadata {
            let binding = StaticSignalAnalyzerNRFProfileBinding.make(
                assemblyReport: report,
                storage: storage,
                metadata: metadata
            )
            switch consume binding {
            case nil:
                break
            case .some:
                Issue.record("Static nRF profile binding accepted unequal Canvas metadata")
            }
        }
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
        #expect(nonzeroByteCount(in: storage) == 11_472)

        binding.quiesce()
        let isQuiescent = binding.isQuiescent
        let lifetimeState = binding.storageLifetimeState
        #expect(isQuiescent)
        #expect(lifetimeState == .tornDown)
        #expect(nonzeroByteCount(in: storage) == 0)
    }
}

@Test func staticNRFProfileBindingLendsRegionsOnlyForTheirActiveLifetime() {
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

        let beforeAttempt = binding.withRegion(.semanticCandidate) { $0.count }
        let beforePair = binding.withSemanticRegions { _, _ in true }
        let beforeLayoutPair = binding.withLayoutRegions { _, _ in true }
        let beforeLayoutJoin = binding.withSemanticCandidateAndLayoutRegions { _, _, _ in true }
        let beforePresentation = binding.withPresentationRegions { _, _, _, _, _ in true }
        let retained = binding.withRegion(.semanticPublished) { $0.count }
        #expect(beforeAttempt == nil)
        #expect(beforePair == nil)
        #expect(beforeLayoutPair == nil)
        #expect(beforeLayoutJoin == nil)
        #expect(beforePresentation == nil)
        #expect(retained == 3_024)

        let active = ExecutionContext(
            cycle: RunCycleID(rawValue: 1),
            semanticRevision: nil,
            candidateFrame: nil,
            phase: .admitting
        )
        #expect(binding.beginOpportunity(context: active) == nil)
        let candidate = binding.withRegion(.semanticCandidate) { region in
            region[0] = 0xA5
            return region.count
        }
        #expect(candidate == 3_024)
        let pair = binding.withSemanticRegions { candidate, published in
            #expect(candidate.count == 3_024)
            #expect(published.count == 3_024)
            #expect(candidate.baseAddress != published.baseAddress)
            published[0] = candidate[0]
            return published[0]
        }
        #expect(pair == 0xA5)
        let layoutPair = binding.withLayoutRegions { layout, render in
            #expect(layout.count == 3_136)
            #expect(render.count == 4_704)
            #expect(
                Int(bitPattern: layout.baseAddress)
                    - Int(bitPattern: storage.baseAddress) == 6_048
            )
            #expect(
                Int(bitPattern: render.baseAddress)
                    - Int(bitPattern: storage.baseAddress) == 9_184
            )
            layout[0] = 0x5A
            render[0] = 0xC3
            return layout[0] != render[0]
        }
        #expect(layoutPair == true)
        let layoutJoin = binding.withSemanticCandidateAndLayoutRegions {
            semantic, layout, render in
            #expect(semantic.count == 3_024)
            #expect(layout.count == 3_136)
            #expect(render.count == 4_704)
            #expect(semantic[0] == 0xA5)
            #expect(layout[0] == 0x5A)
            #expect(render[0] == 0xC3)
            #expect(semantic.baseAddress != layout.baseAddress)
            #expect(layout.baseAddress != render.baseAddress)
            return true
        }
        #expect(layoutJoin == true)
        let presentation = binding.withPresentationRegions {
            semantic, layout, render, path, plan in
            #expect(semantic.count == 3_024)
            #expect(layout.count == 3_136)
            #expect(render.count == 4_704)
            #expect(path.count == 3_280)
            #expect(plan.count == 13_536)
            #expect(semantic.baseAddress != layout.baseAddress)
            #expect(layout.baseAddress != render.baseAddress)
            #expect(render.baseAddress != path.baseAddress)
            #expect(path.baseAddress != plan.baseAddress)
            path[0] = 0xC4
            plan[0] = 0xD5
            return true
        }
        #expect(presentation == true)

        let idle = ExecutionContext(
            cycle: nil,
            semanticRevision: nil,
            candidateFrame: nil,
            phase: .idle
        )
        #expect(binding.finishOpportunity(context: idle) == nil)
        let afterAttempt = binding.withRegion(.semanticCandidate) { $0.count }
        let afterPair = binding.withSemanticRegions { _, _ in true }
        let afterLayoutPair = binding.withLayoutRegions { _, _ in true }
        let afterLayoutJoin = binding.withSemanticCandidateAndLayoutRegions { _, _, _ in true }
        let afterPresentation = binding.withPresentationRegions { _, _, _, _, _ in true }
        #expect(afterAttempt == nil)
        #expect(afterPair == nil)
        #expect(afterLayoutPair == nil)
        #expect(afterLayoutJoin == nil)
        #expect(afterPresentation == nil)
        #expect(storage[0] == 0)
        #expect(storage[3_024] == 0xA5)
        #expect(storage[6_048] == 0)
        #expect(storage[9_184] == 0)
        #expect(storage[14_048] == 0)
        #expect(storage[17_328] == 0)

        binding.quiesce()
        let afterTeardown = binding.withRegion(.semanticPublished) { $0.count }
        #expect(afterTeardown == nil)
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
