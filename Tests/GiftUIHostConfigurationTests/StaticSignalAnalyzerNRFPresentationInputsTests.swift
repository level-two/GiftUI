import GiftUIExecution
import GiftUIHostConfiguration
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFGeneratedPresentationInputsMatchBothSemanticVariants() {
    let normal = staticNRFPresentationInputModel()
    StaticSignalAnalyzerNRFGeneratedPresentationInputFactory.withInputs(
        model: normal
    ) { inputs in
        #expect(inputs.semantic.variant == .normal)
        #expect(inputs.semantic.expansion.semanticNodeCount == 47)
        #expect(inputs.semantic.expansion.bodyEvaluationCount == 14)
        #expect(inputs.semantic.expansion.modifierApplicationCount == 49)
        #expect(inputs.semantic.expansion.actionOccurrenceCount == 6)
        #expect(inputs.semantic.expansion.maximumObservedDepth == 34)
        #expect(inputs.semantic.structuralOccurrenceCount == 124)
        #expect(inputs.semantic.recordedTraversalIdentityCount == 201)
        #expect(inputs.semantic.canvasOccurrenceCount == 5)
    }

    let diagnostic = staticNRFPresentationInputModel()
    let message = SignalAnalyzerDiagnostic(exactUTF8: Array("fault".utf8))!
    #expect(
        diagnostic.apply(.acquisitionState(.failed(message)))
            == .applied(changed: true)
    )
    StaticSignalAnalyzerNRFGeneratedPresentationInputFactory.withInputs(
        model: diagnostic
    ) { inputs in
        #expect(inputs.semantic.variant == .diagnostic)
        #expect(inputs.semantic.expansion.semanticNodeCount == 48)
        #expect(inputs.semantic.expansion.modifierApplicationCount == 50)
        #expect(inputs.semantic.structuralOccurrenceCount == 126)
        #expect(inputs.semantic.recordedTraversalIdentityCount == 203)
    }
}

@Test func staticNRFGeneratedPresentationInputsReserveAndStageFiveCanvases() {
    withStaticNRFPresentationInputStorage { profileStorage in
        guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate(),
            let metadata = StaticSignalAnalyzerNRFGeneratedMetadataFactory.make(
                assemblyReport: report,
                canvasTable: StaticSignalAnalyzerNRFCanvasCallableTable()
            ),
            var runtime = StaticSignalAnalyzerNRFRuntimeStorage(
                assemblyReport: report,
                inputSourceRawValue: 51,
                profileStorage: profileStorage,
                metadata: metadata
            )
        else {
            Issue.record("Static nRF runtime did not construct")
            return
        }

        runtime.withAddressStableOwners { application, profile in
            let repository = StaticNRFPresentationInputRepository()
            guard case .bound = application.bindRoot(repository: repository) else {
                Issue.record("Static nRF root did not bind")
                return
            }
            let active = ExecutionContext(
                cycle: RunCycleID(rawValue: 1),
                semanticRevision: SemanticRevision(rawValue: 1),
                candidateFrame: nil,
                phase: .admitting
            )
            #expect(profile.beginOpportunity(context: active) == nil)
            guard
                application.withGeneratedPresentationInputs({ inputs in
                    let firstReservation = inputs.reserveCandidate(in: &profile)
                    let repeatedReservation = inputs.reserveCandidate(in: &profile)
                    #expect(firstReservation)
                    #expect(!repeatedReservation)

                    var index: UInt16 = 0
                    while index < inputs.semantic.canvasOccurrenceCount {
                        guard var occurrence = inputs.stageCanvas(at: index, in: &profile)
                        else {
                            Issue.record("Generated Canvas occurrence did not stage")
                            return false
                        }
                        #expect(occurrence.identity == index + 1)
                        #expect(occurrence.callableID == (index == 0 ? 1 : 2))
                        #expect(
                            occurrence.declaredCaptureByteCount
                                == (index == 0 ? 0 : 32)
                        )
                        occurrence.discard()
                        #expect(occurrence.releaseCount == 1)
                        index += 1
                    }
                    #expect(inputs.canvasInput(at: 5) == nil)
                    return true
                }) == true
            else {
                Issue.record("Generated presentation inputs were unavailable")
                return
            }
            let idle = ExecutionContext(
                cycle: nil,
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .idle
            )
            #expect(profile.finishOpportunity(context: idle) == nil)
        }
    }
}

@Test func staticNRFSemanticRegionsStagePublishAndRespectProfileLifetimes() {
    withStaticNRFPresentationInputStorage { storage in
        guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate(),
            let metadata = StaticSignalAnalyzerNRFGeneratedMetadataFactory.make(
                assemblyReport: report,
                canvasTable: StaticSignalAnalyzerNRFCanvasCallableTable()
            ),
            var profile = StaticSignalAnalyzerNRFProfileBinding.make(
                assemblyReport: report,
                storage: storage,
                metadata: metadata
            )
        else {
            Issue.record("Static nRF profile did not construct")
            return
        }

        let active = ExecutionContext(
            cycle: RunCycleID(rawValue: 1),
            semanticRevision: SemanticRevision(rawValue: 1),
            candidateFrame: nil,
            phase: .admitting
        )
        #expect(profile.beginOpportunity(context: active) == nil)
        let normal = staticNRFPresentationInputModel()
        StaticSignalAnalyzerNRFGeneratedPresentationInputFactory.withInputs(
            model: normal
        ) { inputs in
            let candidate = inputs.stageSemanticCandidate(in: &profile)
            #expect(candidate?.state == .candidate)
            #expect(candidate?.variant == .normal)
            #expect(candidate?.rootIdentity == 1_410_692_621)
            #expect(candidate?.revision == 0)
            #expect(candidate?.expansion.semanticNodeCount == 47)
            #expect(inputs.stageSemanticCandidate(in: &profile) == nil)

            var index: UInt16 = 0
            while index < StaticSignalAnalyzerNRFSemanticRegionStore.canvasDescriptorCount {
                let descriptor = StaticSignalAnalyzerNRFSemanticRegionStore.canvasDescriptor(
                    at: index,
                    in: .semanticCandidate,
                    profile: &profile
                )
                #expect(descriptor?.occurrenceIdentity == index + 1)
                #expect(descriptor?.callableID == (index == 0 ? 1 : 2))
                #expect(descriptor?.captureByteCount == (index == 0 ? 0 : 32))
                index += 1
            }
            #expect(
                StaticSignalAnalyzerNRFSemanticRegionStore.canvasDescriptor(
                    at: 5,
                    in: .semanticCandidate,
                    profile: &profile
                ) == nil
            )
            index = 0
            while index < StaticSignalAnalyzerNRFSemanticRegionStore.actionCodeCount {
                #expect(
                    StaticSignalAnalyzerNRFSemanticRegionStore.actionCode(
                        at: index,
                        in: .semanticCandidate,
                        profile: &profile
                    ) == index
                )
                index += 1
            }

            let published = inputs.publishSemanticCandidate(
                revision: 7,
                in: &profile
            )
            #expect(published?.state == .published)
            #expect(published?.variant == .normal)
            #expect(published?.revision == 7)
            #expect(inputs.publishSemanticCandidate(revision: 8, in: &profile) == nil)
        }

        let idle = ExecutionContext(
            cycle: nil,
            semanticRevision: nil,
            candidateFrame: nil,
            phase: .idle
        )
        #expect(profile.finishOpportunity(context: idle) == nil)
        #expect(
            StaticSignalAnalyzerNRFSemanticRegionStore.header(
                in: .semanticCandidate,
                profile: &profile
            ) == nil
        )
        #expect(
            StaticSignalAnalyzerNRFSemanticRegionStore.header(
                in: .semanticPublished,
                profile: &profile
            )?.revision == 7
        )

        let diagnostic = staticNRFPresentationInputModel()
        let message = SignalAnalyzerDiagnostic(exactUTF8: Array("fault".utf8))!
        #expect(
            diagnostic.apply(.acquisitionState(.failed(message)))
                == .applied(changed: true)
        )
        #expect(profile.beginOpportunity(context: active) == nil)
        StaticSignalAnalyzerNRFGeneratedPresentationInputFactory.withInputs(
            model: diagnostic
        ) { inputs in
            #expect(inputs.stageSemanticCandidate(in: &profile)?.variant == .diagnostic)
            let published = inputs.publishSemanticCandidate(revision: 8, in: &profile)
            #expect(published?.variant == .diagnostic)
            #expect(published?.expansion.semanticNodeCount == 48)
            #expect(published?.revision == 8)
        }
        #expect(profile.finishOpportunity(context: idle) == nil)
        profile.quiesce()
        #expect(
            StaticSignalAnalyzerNRFSemanticRegionStore.header(
                in: .semanticPublished,
                profile: &profile
            ) == nil
        )
    }
}

private final class StaticNRFPresentationInputRepository:
    SignalAcquisitionRepository
{
    func startObservingCapture(sink: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}
    func start() throws {}
    func stop() {}
    func clear() {}
}

private func staticNRFPresentationInputModel() -> SignalAnalyzerViewModel {
    let repository = StaticNRFPresentationInputRepository()
    return SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
}

private func withStaticNRFPresentationInputStorage(
    _ body: (UnsafeMutableRawBufferPointer) -> Void
) {
    let byteCount = StaticSignalAnalyzerNRFProfileRegions.requiredByteCount
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: 8)
    defer { pointer.deallocate() }
    body(UnsafeMutableRawBufferPointer(start: pointer, count: byteCount))
}
