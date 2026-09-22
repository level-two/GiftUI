import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIInteraction
import GiftUILayout
import GiftUIReferenceTextResources
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
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
        let wideDiagnostic = staticNRFPresentationInputModel()
        let multilineDiagnostic = staticNRFPresentationInputModel()
        let mixedOne = staticNRFPresentationInputModel()
        let mixedTwo = staticNRFPresentationInputModel()
        let mixedThree = staticNRFPresentationInputModel()
        let mixedFour = staticNRFPresentationInputModel()
        let maximum = SignalAnalyzerDiagnostic(
            exactUTF8: [UInt8](repeating: 65, count: 96)
        )!
        let wide = SignalAnalyzerDiagnostic(
            exactUTF8: [UInt8](repeating: 87, count: 96)
        )!
        let multiline = SignalAnalyzerDiagnostic(
            exactUTF8: [UInt8](repeating: 10, count: 96)
        )!
        #expect(diagnostic.apply(.acquisitionState(.failed(maximum))) == .applied(changed: true))
        #expect(wideDiagnostic.apply(.acquisitionState(.failed(wide))) == .applied(changed: true))
        #expect(
            multilineDiagnostic.apply(.acquisitionState(.failed(multiline)))
                == .applied(changed: true)
        )
        let mixedPatterns: [[UInt8]] = [
            Array(repeating: [87, 10], count: 48).flatMap { $0 },
            Array(repeating: [87, 87, 10], count: 32).flatMap { $0 },
            Array(repeating: [87, 87, 87, 10], count: 24).flatMap { $0 },
            Array(repeating: [87, 87, 87, 87, 87, 10], count: 16).flatMap { $0 },
        ]
        for (model, bytes) in zip(
            [mixedOne, mixedTwo, mixedThree, mixedFour], mixedPatterns
        ) {
            #expect(
                model.apply(.acquisitionState(.failed(SignalAnalyzerDiagnostic(exactUTF8: bytes)!)))
                    == .applied(changed: true)
            )
        }

        let cases: [(UInt32, SignalAnalyzerViewModel, UInt16, UInt16, UInt16?)] = [
            (1, normal, 96, 117, nil),
            (2, diagnostic, 98, 214, 96),
            (3, wideDiagnostic, 98, 214, 98),
            (4, multilineDiagnostic, 98, 214, 98),
            (5, mixedOne, 98, 214, 98),
            (6, mixedTwo, 98, 214, 98),
            (7, mixedThree, 98, 214, 98),
            (8, mixedFour, 98, 214, 98),
        ]
        for (cycle, model, expectedScopes, expectedBytes, previousScopes) in cases {
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
                #expect(summary?.textByteCount == expectedBytes)
                let candidateRead =
                    StaticSignalAnalyzerNRFSemanticRegionStore.withGeneratedUTF8RenderView(
                        in: .semanticCandidate,
                        renderSnapshotVersion: cycle,
                        profile: &profile
                    ) { view in
                        #expect(view.semanticScopeCount == expectedScopes)
                        #expect(view.renderSnapshotVersion == cycle)
                        #expect(view.semanticIdentity(at: 0) == view.rootIdentity)
                        #expect(view.childCount(of: view.rootIdentity) == 1)
                        return true
                    }
                #expect(candidateRead)
                let candidateLayoutRead =
                    StaticSignalAnalyzerNRFSemanticRegionStore.withGeneratedUTF8LayoutView(
                        in: .semanticCandidate,
                        profile: &profile
                    ) { view in
                        #expect(view.scopeCount == expectedScopes)
                        #expect(view.primitive(at: view.rootIdentity) != nil)
                        return true
                    }
                #expect(candidateLayoutRead)
                let candidatePairedRead =
                    StaticSignalAnalyzerNRFSemanticRegionStore.withGeneratedUTF8Views(
                        in: .semanticCandidate,
                        renderSnapshotVersion: cycle,
                        profile: &profile
                    ) { layoutView, renderView in
                        #expect(layoutView.scopeCount == renderView.semanticScopeCount)
                        #expect(renderView.semanticOrdinal(of: layoutView.rootIdentity) != nil)
                        #expect(renderView.renderSnapshotVersion == cycle)
                        var requiredScalars: UInt16 = 0
                        for ordinal in 0 ..< expectedScopes {
                            guard let identity = renderView.semanticIdentity(at: ordinal) else {
                                Issue.record("generated scope identity is missing")
                                return false
                            }
                            requiredScalars += layoutView.textScalarCount(of: identity) ?? 0
                        }
                        #expect(requiredScalars == expectedBytes)
                        let limits = GeneratedSignalAnalyzerPresets.nrf52840Static()
                            .runtimeLimits.layout
                        var workspace = StaticNRFValidationOnlyLayoutWorkspace(limits: limits)
                        var validation = LayoutSemanticValidation(limits: limits)
                        let validationError = validation.validate(
                            semantic: layoutView,
                            metrics: GiftUIReferenceTextResources.targetPackage.metrics,
                            workspace: &workspace
                        )
                        #expect(validationError == nil)
                        #expect(limits.maximumTextScalars == 224)
                        #expect(limits.maximumTextLines == 128)
                        #expect(limits.maximumPositionedGlyphs == 224)
                        #expect(workspace.scopeCount == expectedScopes)
                        return true
                    }
                #expect(candidatePairedRead)
                let resolvedLayoutRead = profile.withPresentationRegions {
                    semanticRegion, layoutRegion, renderRegion, pathRegion, planRegion in
                    guard
                        let semanticView = StaticSignalAnalyzerNRFUTF8LayoutView(
                            in: semanticRegion
                        ),
                        var workspace = StaticSignalAnalyzerNRFLayoutWorkspace(
                            scopes: layoutRegion, text: renderRegion
                        ),
                        var sink = StaticSignalAnalyzerNRFResolvedLayoutStorage(
                            scopes: layoutRegion, text: renderRegion
                        )
                    else { return false }
                    let packedLimits = GeneratedSignalAnalyzerPresets.nrf52840Static()
                        .runtimeLimits.layout
                    let result = layout(
                        semantic: semanticView,
                        metrics: GiftUIReferenceTextResources.targetPackage.metrics,
                        proposal: ProposedSize(width: 480, height: 320)!,
                        limits: packedLimits,
                        workspace: &workspace,
                        sink: &sink
                    )
                    guard case .success(let layoutSummary) = result else {
                        Issue.record("generated Static hierarchy did not resolve layout: \(result)")
                        return false
                    }
                    #expect(layoutSummary.scopeCount == expectedScopes)
                    #expect(sink.hasPublishedResult)
                    #expect(sink.renderView.layoutScopeCount == expectedScopes)
                    #expect(sink.renderView.bounds(of: semanticView.rootIdentity) != nil)
                    guard
                        let occurrences = StaticSignalAnalyzerNRFInteractionOccurrences(
                            semanticRegion: semanticRegion,
                            layout: sink.renderView
                        )
                    else {
                        Issue.record("generated action occurrences did not resolve")
                        return false
                    }
                    #expect(occurrences.interactionOccurrenceCount == 6)
                    #expect(occurrences.interactionOccurrence(at: 6) == nil)
                    for index: UInt16 in 0 ..< 6 {
                        guard let occurrence = occurrences.interactionOccurrence(at: index),
                            let actionOrdinal =
                                StaticSignalAnalyzerNRFPackedSemanticRecords
                                .actionScope(at: index, in: semanticRegion),
                            let action = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                                at: actionOrdinal, in: semanticRegion
                            )
                        else {
                            Issue.record("generated action occurrence \(index) is missing")
                            return false
                        }
                        #expect(occurrence.identity == UInt32(action.identity))
                        #expect(occurrence.action.code == index)
                        #expect(occurrence.paintOrder == index)
                    }
                    #expect(occurrences.interactionOccurrence(at: 0)?.isEnabled == true)
                    #expect(occurrences.interactionOccurrence(at: 1)?.isEnabled == false)
                    let interactionLimits = GeneratedSignalAnalyzerPresets.nrf52840Static()
                        .runtimeLimits.interaction
                    var interaction = StaticInteractionState<UInt32>(
                        candidateRecords: StaticInteractionCandidateStorage(
                            capacity: interactionLimits.maximumActions
                        )!,
                        candidateHitRegions: StaticInteractionHitStorage(
                            capacity: interactionLimits.maximumHitRegions
                        )!,
                        candidateCommittedRecords: StaticInteractionCommittedStorage(
                            capacity: interactionLimits.maximumActions
                        )!,
                        committedRecords: StaticInteractionCommittedStorage(
                            capacity: interactionLimits.maximumActions
                        )!,
                        committedHitRegions: StaticInteractionHitStorage(
                            capacity: interactionLimits.maximumHitRegions
                        )!
                    )
                    var generations = RuntimeActionGenerationAllocator<UInt32>()
                    #expect(
                        StaticSignalAnalyzerNRFInteractionCandidateProducer.build(
                            occurrences: occurrences,
                            targetGeneration: ObservableTargetGeneration(rawValue: 1),
                            limits: interactionLimits,
                            interaction: &interaction,
                            generations: &generations
                        ) == .ready
                    )
                    interaction.resolveCandidate(
                        .commit(PresentationRevision(rawValue: cycle))
                    )
                    generations.resolveCandidate(committed: true)
                    #expect(interaction.committedRevision?.rawValue == cycle)
                    #expect(interaction.committedRecordCount == 6)
                    #expect(interaction.committedRecord(at: 0)?.isEnabled == true)
                    #expect(interaction.committedRecord(at: 1)?.isEnabled == false)
                    #expect(generations.committedReservationCount == 6)
                    #expect(
                        StaticSignalAnalyzerNRFInteractionCandidateProducer.build(
                            occurrences: occurrences,
                            targetGeneration: ObservableTargetGeneration(rawValue: 1),
                            limits: interactionLimits,
                            interaction: &interaction,
                            generations: &generations
                        ) == .ready
                    )
                    interaction.resolveCandidate(.discard)
                    generations.resolveCandidate(committed: false)
                    #expect(generations.retiredReservationCount == 0)
                    #expect(interaction.committedRevision?.rawValue == cycle)
                    guard
                        var source = StaticSignalAnalyzerNRFCanvasInvocationSource(
                            semanticRegion: semanticRegion, inputs: inputs
                        ),
                        var drawingWorkspace = StaticSignalAnalyzerNRFDrawingWorkspace(
                            pathRegion: pathRegion,
                            planRegion: planRegion,
                            capacity: GeneratedSignalAnalyzerPresets.nrf52840Static()
                                .runtimeLimits.drawing
                        )
                    else {
                        Issue.record(
                            "generated Canvas source or Static drawing workspace is invalid")
                        return false
                    }
                    let drawingResult = CanvasPlanProducer.derive(
                        source: &source,
                        layout: sink.renderView,
                        executionContext: ExecutionContext(
                            cycle: RunCycleID(rawValue: cycle),
                            semanticRevision: SemanticRevision(rawValue: cycle),
                            candidateFrame: nil,
                            phase: .deriving
                        ),
                        limits: drawingWorkspace.limits,
                        workspace: &drawingWorkspace
                    )
                    guard case .success(let drawingSummary) = drawingResult else {
                        Issue.record("generated Canvas derivation failed: \(drawingResult)")
                        return false
                    }
                    #expect(drawingSummary.canvasOccurrenceCount == 5)
                    #expect(drawingSummary.strokeCount == 5)
                    #expect(source.allReleased)
                    guard
                        let renderView = StaticSignalAnalyzerNRFUTF8RenderView(
                            in: semanticRegion, renderSnapshotVersion: cycle
                        ),
                        var renderWorkspace = StaticSignalAnalyzerNRFRenderWorkspace(
                            region: renderRegion,
                            capacity: GeneratedSignalAnalyzerPresets.nrf52840Static()
                                .runtimeLimits.render,
                            structuralCapacity: GeneratedSignalAnalyzerPresets.nrf52840Static()
                                .runtimeLimits.renderWorkspace
                        )
                    else {
                        Issue.record("generated render view or workspace is invalid")
                        return false
                    }
                    let renderLimits = GeneratedSignalAnalyzerPresets.nrf52840Static()
                        .runtimeLimits
                    let preflight = CanvasRenderProducer.preflight(
                        semantic: renderView,
                        layout: sink.renderView,
                        textMetrics: GiftUIReferenceTextResources.targetPackage.metrics,
                        drawingPlan: drawingWorkspace,
                        surfaceBounds: sink.renderView.rootBounds,
                        damageMode: .initializeCompleteSurface,
                        rootForeground: .white,
                        limits: renderLimits.render,
                        configuredSinkCapacity: renderLimits.renderSink,
                        workspace: &renderWorkspace
                    )
                    let acceptedHeader: RenderPlanHeader
                    let acceptedLimits: RenderLimits
                    let acceptedSinkCapacity: RenderSinkCapacity
                    if cycle == 1 || cycle == 4 {
                        guard case .success(let header) = preflight else {
                            Issue.record("generated Canvas render preflight failed: \(preflight)")
                            return false
                        }
                        #expect(header.operationCount <= renderLimits.render.maximumOperations)
                        #expect(header.positionedGlyphCount > 0)
                        acceptedHeader = header
                        acceptedLimits = renderLimits.render
                        acceptedSinkCapacity = renderLimits.renderSink
                    } else {
                        // Valid 96-byte printable and mixed-line diagnostics
                        // exceed the approved 35-operation nRF ceiling.
                        #expect(preflight == .failure(.capacityExhausted))
                        let measuredLimits = RenderLimits(
                            maximumOperations: 39,
                            maximumPositionedGlyphs: 224,
                            maximumClipDepth: 4
                        )!
                        var measuredWorkspace = StaticSignalAnalyzerNRFRenderWorkspace(
                            region: renderRegion,
                            capacity: measuredLimits,
                            structuralCapacity: renderLimits.renderWorkspace
                        )!
                        let measured = CanvasRenderProducer.preflight(
                            semantic: renderView,
                            layout: sink.renderView,
                            textMetrics: GiftUIReferenceTextResources.targetPackage.metrics,
                            drawingPlan: drawingWorkspace,
                            surfaceBounds: sink.renderView.rootBounds,
                            damageMode: .initializeCompleteSurface,
                            rootForeground: .white,
                            limits: measuredLimits,
                            configuredSinkCapacity: RenderSinkCapacity(
                                maximumOperations: 39,
                                maximumPositionedGlyphs: 224
                            ),
                            workspace: &measuredWorkspace
                        )
                        guard case .success(let measuredHeader) = measured else {
                            Issue.record("measured diagnostic preflight failed: \(measured)")
                            return false
                        }
                        #expect(
                            measuredHeader.operationCount
                                == (cycle == 2 ? 37 : cycle == 3 ? 38 : 39)
                        )
                        let expectedGlyphs: UInt16
                        switch cycle {
                        case 2, 3: expectedGlyphs = 214
                        case 5: expectedGlyphs = 123
                        case 6: expectedGlyphs = 128
                        case 7: expectedGlyphs = 133
                        default: expectedGlyphs = 143
                        }
                        #expect(measuredHeader.positionedGlyphCount == expectedGlyphs)
                        acceptedHeader = measuredHeader
                        acceptedLimits = measuredLimits
                        acceptedSinkCapacity = RenderSinkCapacity(
                            maximumOperations: 39,
                            maximumPositionedGlyphs: 224
                        )
                    }
                    var operationSink = StaticNRFCountingRenderSink(
                        capacity: acceptedSinkCapacity
                    )
                    var productionWorkspace = StaticSignalAnalyzerNRFRenderWorkspace(
                        region: renderRegion,
                        capacity: acceptedLimits,
                        structuralCapacity: renderLimits.renderWorkspace
                    )!
                    let production = CanvasRenderProducer.produce(
                        semantic: renderView,
                        layout: sink.renderView,
                        textMetrics: GiftUIReferenceTextResources.targetPackage.metrics,
                        drawingPlan: drawingWorkspace,
                        surfaceBounds: sink.renderView.rootBounds,
                        damageMode: .initializeCompleteSurface,
                        rootForeground: .white,
                        limits: acceptedLimits,
                        expectedHeader: acceptedHeader,
                        workspace: &productionWorkspace,
                        sink: &operationSink
                    )
                    #expect(production == .success(acceptedHeader))
                    #expect(operationSink.publishedHeader == acceptedHeader)
                    #expect(operationSink.strokeCount == 5)
                    return true
                }
                #expect(resolvedLayoutRead == true)
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
                    )?.scopeCount == previousScopes
                )
                if cycle == 2 {
                    #expect(
                        inputs.publishGeneratedSemanticCandidate(revision: 1, in: &profile) == nil)
                    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
                    #expect(
                        profile.withRegion(.semanticCandidate) { region in
                            region[table.scalarOffset] ^= 1
                            return true
                        } == true
                    )
                    #expect(
                        inputs.publishGeneratedSemanticCandidate(revision: 2, in: &profile) == nil)
                    #expect(
                        StaticSignalAnalyzerNRFSemanticRegionStore.generatedUTF8TableSummary(
                            in: .semanticPublished,
                            profile: &profile
                        )?.scopeCount == 96
                    )
                    #expect(
                        profile.withRegion(.semanticCandidate) { region in
                            region[table.scalarOffset] ^= 1
                            return true
                        } == true
                    )
                }
                #expect(
                    inputs.publishGeneratedSemanticCandidate(
                        revision: cycle,
                        in: &profile
                    )?.revision == cycle
                )
                #expect(
                    inputs.publishGeneratedSemanticCandidate(revision: cycle + 1, in: &profile)
                        == nil)
                #expect(
                    StaticSignalAnalyzerNRFSemanticRegionStore.generatedUTF8TableSummary(
                        in: .semanticPublished,
                        profile: &profile
                    ) == summary
                )
                let publishedRead =
                    StaticSignalAnalyzerNRFSemanticRegionStore.withGeneratedUTF8RenderView(
                        in: .semanticPublished,
                        renderSnapshotVersion: cycle,
                        profile: &profile
                    ) { view in
                        #expect(view.semanticScopeCount == expectedScopes)
                        return true
                    }
                #expect(publishedRead)
                let publishedLayoutRead =
                    StaticSignalAnalyzerNRFSemanticRegionStore.withGeneratedUTF8LayoutView(
                        in: .semanticPublished,
                        profile: &profile
                    ) { view in
                        #expect(view.scopeCount == expectedScopes)
                        return true
                    }
                #expect(publishedLayoutRead)
                let publishedPairedRead =
                    StaticSignalAnalyzerNRFSemanticRegionStore.withGeneratedUTF8Views(
                        in: .semanticPublished,
                        renderSnapshotVersion: cycle,
                        profile: &profile
                    ) { layoutView, renderView in
                        #expect(layoutView.scopeCount == renderView.semanticScopeCount)
                        #expect(renderView.semanticOrdinal(of: layoutView.rootIdentity) != nil)
                        return true
                    }
                #expect(publishedPairedRead)
            }
            let idle = ExecutionContext(
                cycle: nil,
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .idle
            )
            #expect(profile.finishOpportunity(context: idle) == nil)
            #expect(
                !StaticSignalAnalyzerNRFSemanticRegionStore.withGeneratedUTF8RenderView(
                    in: .semanticCandidate,
                    renderSnapshotVersion: cycle,
                    profile: &profile
                ) { _ in true }
            )
            #expect(
                !StaticSignalAnalyzerNRFSemanticRegionStore.withGeneratedUTF8LayoutView(
                    in: .semanticCandidate,
                    profile: &profile
                ) { _ in true }
            )
            #expect(
                !StaticSignalAnalyzerNRFSemanticRegionStore.withGeneratedUTF8Views(
                    in: .semanticCandidate,
                    renderSnapshotVersion: cycle,
                    profile: &profile
                ) { _, _ in true }
            )
        }
        profile.quiesce()
        #expect(
            !StaticSignalAnalyzerNRFSemanticRegionStore.withGeneratedUTF8RenderView(
                in: .semanticPublished,
                renderSnapshotVersion: 3,
                profile: &profile
            ) { _ in true }
        )
        #expect(
            !StaticSignalAnalyzerNRFSemanticRegionStore.withGeneratedUTF8LayoutView(
                in: .semanticPublished,
                profile: &profile
            ) { _ in true }
        )
        #expect(
            !StaticSignalAnalyzerNRFSemanticRegionStore.withGeneratedUTF8Views(
                in: .semanticPublished,
                renderSnapshotVersion: 3,
                profile: &profile
            ) { _, _ in true }
        )
    }
}

/// Host-only probe for the common validation stage. It is not the production
/// packed layout workspace and does not claim embedded storage conformance.
private struct StaticNRFValidationOnlyLayoutWorkspace: LayoutWorkspace {
    typealias Identity = UInt16

    let maximumScopes: UInt16
    let maximumDepth: UInt16
    let maximumTextScalars: UInt16
    let maximumTextLines: UInt16
    let maximumPositionedGlyphs: UInt16
    private(set) var isLayoutActive = false
    private var identities: [UInt16] = []
    private var depth: UInt16 = 0

    init(limits: LayoutLimits) {
        maximumScopes = limits.maximumScopes
        maximumDepth = limits.maximumDepth
        maximumTextScalars = limits.maximumTextScalars
        maximumTextLines = limits.maximumTextLines
        maximumPositionedGlyphs = limits.maximumPositionedGlyphs
    }

    mutating func acquireLayout() -> Bool {
        guard !isLayoutActive else { return false }
        isLayoutActive = true
        return true
    }

    mutating func appendScope(identity: borrowing UInt16, measurement: LayoutMeasurement) -> Bool {
        guard identities.count < Int(maximumScopes), !identities.contains(identity) else {
            return false
        }
        identities.append(copy identity)
        return true
    }

    var scopeCount: UInt16 { UInt16(identities.count) }

    func scopeIdentity(at index: UInt16) -> UInt16? {
        index < scopeCount ? identities[Int(index)] : nil
    }

    func measurement(for identity: borrowing UInt16) -> LayoutMeasurement? { nil }
    mutating func storeMeasurement(_ measurement: LayoutMeasurement, for identity: borrowing UInt16)
        -> Bool
    { false }
    mutating func storePlacement(_ placement: LayoutPlacement, for identity: borrowing UInt16)
        -> Bool
    { false }
    func placement(for identity: borrowing UInt16) -> LayoutPlacement? { nil }
    var textLineCount: UInt16 { 0 }
    mutating func appendTextLine(_ line: LayoutTextLine<UInt16>) -> Bool { false }
    func textLine(at index: UInt16) -> LayoutTextLine<UInt16>? { nil }
    mutating func storeTextLine(_ line: LayoutTextLine<UInt16>, at index: UInt16) -> Bool { false }
    var positionedGlyphCount: UInt16 { 0 }
    mutating func appendPositionedGlyph(_ glyph: LayoutPositionedGlyph<UInt16>) -> Bool { false }
    func positionedGlyph(at index: UInt16) -> LayoutPositionedGlyph<UInt16>? { nil }
    mutating func storePositionedGlyph(_ glyph: LayoutPositionedGlyph<UInt16>, at index: UInt16)
        -> Bool
    { false }

    mutating func pushScope(_ identity: borrowing UInt16) -> Bool {
        guard depth < maximumDepth else { return false }
        depth += 1
        return true
    }

    mutating func popScope() { depth -= 1 }

    mutating func resetLayout() {
        identities.removeAll(keepingCapacity: true)
        depth = 0
        isLayoutActive = false
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

private struct StaticNRFCountingRenderSink: DrawingOperationSink {
    let capacity: RenderSinkCapacity
    private var stagedHeader: RenderPlanHeader?
    private var operationCount: UInt16 = 0
    private var glyphCount: UInt16 = 0
    private(set) var strokeCount: UInt16 = 0
    private(set) var publishedHeader: RenderPlanHeader?

    init(capacity: RenderSinkCapacity) { self.capacity = capacity }

    mutating func begin(_ header: RenderPlanHeader) -> Bool {
        guard stagedHeader == nil,
            header.operationCount <= capacity.maximumOperations,
            header.positionedGlyphCount <= capacity.maximumPositionedGlyphs
        else { return false }
        stagedHeader = header
        operationCount = 0
        glyphCount = 0
        strokeCount = 0
        return true
    }

    mutating func fillRect(_: FillRectOperation) -> Bool { countOperation() }
    mutating func beginPositionedGlyphs(_: PositionedGlyphOperationHeader) -> Bool {
        countOperation()
    }
    mutating func positionedGlyph(_: PositionedGlyph) -> Bool {
        guard stagedHeader != nil, glyphCount < capacity.maximumPositionedGlyphs else {
            return false
        }
        glyphCount += 1
        return true
    }
    mutating func endPositionedGlyphs() -> Bool { stagedHeader != nil }

    mutating func straightLineStroke<Stroke: StraightLineStrokeView>(
        _ stroke: borrowing Stroke
    ) -> Bool {
        var point: UInt16 = 0
        while point < stroke.header.pointCount {
            guard stroke.point(at: point) != nil else { return false }
            point += 1
        }
        var subpath: UInt16 = 0
        while subpath < stroke.header.subpathCount {
            guard stroke.subpath(at: subpath) != nil else { return false }
            subpath += 1
        }
        guard countOperation() else { return false }
        strokeCount += 1
        return true
    }

    mutating func finish() -> Bool {
        guard let stagedHeader,
            operationCount == stagedHeader.operationCount,
            glyphCount == stagedHeader.positionedGlyphCount
        else { return false }
        publishedHeader = stagedHeader
        self.stagedHeader = nil
        return true
    }

    mutating func discard() {
        stagedHeader = nil
        operationCount = 0
        glyphCount = 0
        strokeCount = 0
    }

    private mutating func countOperation() -> Bool {
        guard stagedHeader != nil, operationCount < capacity.maximumOperations else {
            return false
        }
        operationCount += 1
        return true
    }
}
