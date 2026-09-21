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

@Test func staticNRFLiveModifiersFollowRunningAndWindowState() {
    let model = staticNRFPresentationInputModel()
    StaticSignalAnalyzerNRFGeneratedPresentationInputFactory.withInputs(
        model: model
    ) { inputs in
        #expect(inputs.liveModifierInput(at: 12)?.payload0 == 16_777_215)
        #expect(inputs.liveModifierInput(at: 72)?.flags == 1)
        #expect(inputs.liveModifierInput(at: 76)?.flags == 65)
        #expect(inputs.liveModifierInput(at: 88)?.flags == 65)
    }
    #expect(model.apply(.acquisitionState(.running)) == .applied(changed: true))
    model.visibleDurationChanged(.fiveSeconds)
    StaticSignalAnalyzerNRFGeneratedPresentationInputFactory.withInputs(
        model: model
    ) { inputs in
        #expect(inputs.liveModifierInput(at: 12)?.payload0 != 16_777_215)
        #expect(inputs.liveModifierInput(at: 72)?.flags == 65)
        #expect(inputs.liveModifierInput(at: 76)?.flags == 1)
        #expect(inputs.liveModifierInput(at: 88)?.flags == 1)
        #expect(inputs.liveModifierInput(at: 92)?.flags == 65)
        #expect(inputs.liveModifierInput(at: 0) == nil)
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

            #expect(
                profile.withRegion(.semanticCandidate) { region in
                    region[72] ^= 0x01
                    return true
                } == true
            )
            #expect(
                StaticSignalAnalyzerNRFSemanticRegionStore.header(
                    in: .semanticCandidate,
                    profile: &profile
                ) == nil
            )
            #expect(inputs.publishSemanticCandidate(revision: 7, in: &profile) == nil)
            #expect(
                profile.withRegion(.semanticCandidate) { region in
                    region[72] ^= 0x01
                    return true
                } == true
            )
            #expect(
                profile.withRegion(.semanticCandidate) { region in
                    region[3_000] = 0xA5
                    return true
                } == true
            )
            #expect(inputs.publishSemanticCandidate(revision: 7, in: &profile) == nil)
            #expect(
                profile.withRegion(.semanticCandidate) { region in
                    region[3_000] = 0
                    return true
                } == true
            )

            let published = inputs.publishSemanticCandidate(
                revision: 7,
                in: &profile
            )
            #expect(published?.state == .published)
            #expect(published?.variant == .normal)
            #expect(published?.revision == 7)
            #expect(
                profile.withSemanticRegions { candidate, retained in
                    var index = 0
                    while index < candidate.count {
                        if index != 6 && !(28 ..< 32).contains(index)
                            && !(84 ..< 88).contains(index)
                            && candidate[index] != retained[index]
                        {
                            return false
                        }
                        index += 1
                    }
                    return true
                } == true)
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
            #expect(inputs.publishSemanticCandidate(revision: 7, in: &profile) == nil)
            #expect(
                profile.withRegion(.semanticPublished) { region in
                    region[28]
                } == 7
            )
            let published = inputs.publishSemanticCandidate(revision: 8, in: &profile)
            #expect(published?.variant == .diagnostic)
            #expect(published?.expansion.semanticNodeCount == 48)
            #expect(published?.revision == 8)
            #expect(
                profile.withRegion(.semanticPublished) { region in
                    region[3_000]
                } == 0
            )
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

@Test func staticNRFCompleteSemanticTableUsesCheckedRegionPublication() {
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
        let model = staticNRFPresentationInputModel()
        StaticSignalAnalyzerNRFGeneratedPresentationInputFactory.withInputs(
            model: model
        ) { inputs in
            #expect(
                StaticSignalAnalyzerNRFSemanticRegionStore.stageCompleteCandidate(
                    inputs: &inputs,
                    in: &profile,
                    populate: populateSyntheticNRFCompleteTable
                )
            )
            let expected = StaticSignalAnalyzerNRFPackedTableSummary(
                scopeCount: 96,
                scalarCount: 0
            )
            #expect(
                StaticSignalAnalyzerNRFSemanticRegionStore.completeTableSummary(
                    in: .semanticCandidate,
                    profile: &profile
                ) == expected
            )
            #expect(
                StaticSignalAnalyzerNRFSemanticRegionStore.generatedTableSummary(
                    in: .semanticCandidate,
                    profile: &profile
                ) == nil
            )
            #expect(
                !StaticSignalAnalyzerNRFSemanticRegionStore.publishGeneratedCandidate(
                    inputs: inputs,
                    revision: 1,
                    in: &profile
                )
            )
            #expect(
                profile.withRegion(.semanticCandidate) { region in
                    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
                    return table.hasDistinctActionScopes(in: region)
                        && table.hasExactCanvasOccurrences(in: region)
                } == true
            )
            #expect(
                profile.withRegion(.semanticCandidate) { region in
                    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
                    guard table.storeActionScope(0, at: 1, in: region) else {
                        return false
                    }
                    let rejected = !table.hasDistinctActionScopes(in: region)
                    return rejected && table.storeActionScope(1, at: 1, in: region)
                } == true
            )
            #expect(
                profile.withRegion(.semanticCandidate) { region in
                    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
                    guard let canvas = table.scope(at: 91, in: region) else {
                        return false
                    }
                    let payloadOffset = table.scopeOffset + 91 * table.scopeStride + 12
                    region[payloadOffset] = 1
                    let rejected = !table.hasExactCanvasOccurrences(in: region)
                    region[payloadOffset] = UInt8(canvas.payload0)
                    return rejected
                } == true
            )
            #expect(
                profile.withRegion(.semanticCandidate) { region in
                    region[StaticSignalAnalyzerNRFPackedSemanticRecords.scopeOffset + 2] ^= 1
                    return true
                } == true
            )
            #expect(
                !StaticSignalAnalyzerNRFSemanticRegionStore.publishCompleteCandidate(
                    inputs: inputs,
                    revision: 1,
                    in: &profile
                )
            )
            #expect(
                profile.withRegion(.semanticCandidate) { region in
                    region[StaticSignalAnalyzerNRFPackedSemanticRecords.scopeOffset + 2] ^= 1
                    return true
                } == true
            )
            #expect(
                StaticSignalAnalyzerNRFSemanticRegionStore.publishCompleteCandidate(
                    inputs: inputs,
                    revision: 1,
                    in: &profile
                )
            )
            #expect(
                StaticSignalAnalyzerNRFSemanticRegionStore.completeTableSummary(
                    in: .semanticPublished,
                    profile: &profile
                ) == expected
            )
        }
        let idle = ExecutionContext(
            cycle: nil,
            semanticRevision: nil,
            candidateFrame: nil,
            phase: .idle
        )
        #expect(profile.finishOpportunity(context: idle) == nil)
        #expect(
            StaticSignalAnalyzerNRFSemanticRegionStore.completeTableSummary(
                in: .semanticCandidate,
                profile: &profile
            ) == nil
        )
        #expect(
            StaticSignalAnalyzerNRFSemanticRegionStore.completeTableSummary(
                in: .semanticPublished,
                profile: &profile
            )?.scopeCount == 96
        )
        profile.quiesce()
    }
}

@Test func staticNRFGeneratedUTF8CandidateStagesExactHierarchyWithoutPrefixPublication() {
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
        let normal = staticNRFPresentationInputModel()
        let diagnostic = staticNRFPresentationInputModel()
        let maximum = SignalAnalyzerDiagnostic(
            exactUTF8: [UInt8](repeating: 65, count: 96)
        )!
        #expect(diagnostic.apply(.acquisitionState(.failed(maximum))) == .applied(changed: true))

        for (cycle, model, expectedScopes) in [
            (UInt32(1), normal, UInt16(96)),
            (UInt32(2), diagnostic, UInt16(98)),
        ] {
            let active = ExecutionContext(
                cycle: RunCycleID(rawValue: cycle),
                semanticRevision: SemanticRevision(rawValue: cycle),
                candidateFrame: nil,
                phase: .admitting
            )
            #expect(profile.beginOpportunity(context: active) == nil)
            StaticSignalAnalyzerNRFGeneratedPresentationInputFactory.withInputs(
                model: model
            ) { inputs in
                #expect(inputs.stageGeneratedSemanticCandidate(in: &profile)?.state == .candidate)
                let summary = StaticSignalAnalyzerNRFSemanticRegionStore.generatedUTF8TableSummary(
                    in: .semanticCandidate,
                    profile: &profile
                )
                #expect(summary?.scopeCount == expectedScopes)
                #expect(summary?.textByteCount == (expectedScopes == 98 ? 214 : 117))
                #expect(inputs.stageGeneratedSemanticCandidate(in: &profile) == nil)
                #expect(inputs.publishSemanticCandidate(revision: 1, in: &profile) == nil)
                #expect(
                    !StaticSignalAnalyzerNRFSemanticRegionStore.publishCandidate(
                        inputs: inputs,
                        revision: 1,
                        in: &profile
                    )
                )
                #expect(
                    StaticSignalAnalyzerNRFSemanticRegionStore.generatedUTF8TableSummary(
                        in: .semanticPublished,
                        profile: &profile
                    ) == nil
                )
            }
            let idle = ExecutionContext(
                cycle: nil,
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .idle
            )
            #expect(profile.finishOpportunity(context: idle) == nil)
        }
        profile.quiesce()
    }
}

private func populateSyntheticNRFCompleteTable(
    in region: UnsafeMutableRawBufferPointer
) -> StaticSignalAnalyzerNRFPackedTableSummary? {
    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
    var ordinal: UInt16 = 0
    while ordinal < 96 {
        let record = StaticSignalAnalyzerNRFScopeRecord(
            identity: ordinal + 1,
            parent: ordinal == 0 ? table.missingOrdinal : ordinal - 1,
            firstChild: ordinal == 95 ? table.missingOrdinal : ordinal + 1,
            nextSibling: table.missingOrdinal,
            kind: (90 ... 94).contains(ordinal) ? .canvas : .proxy,
            flags: 0,
            auxiliary: 0,
            payload0: (90 ... 94).contains(ordinal) ? UInt32(ordinal - 89) : 0,
            payload1: 0,
            payload2: 0
        )
        guard table.storeScope(record, at: ordinal, in: region) else { return nil }
        ordinal += 1
    }
    var action: UInt16 = 0
    while action < table.actionCount {
        guard table.storeActionScope(action, at: action, in: region) else {
            return nil
        }
        action += 1
    }
    return StaticSignalAnalyzerNRFPackedTableSummary(scopeCount: 96, scalarCount: 0)
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
