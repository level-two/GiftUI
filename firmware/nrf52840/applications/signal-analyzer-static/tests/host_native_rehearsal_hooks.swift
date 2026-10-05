// Appended to the generated Swift amalgamation only for the macOS recorder.
// Clear uses the production repository/admission path, without a synthetic UI control.
@_cdecl("giftui_signal_analyzer_rehearsal_clear")
public func giftUISignalAnalyzerRehearsalClear(
    _ profile: UnsafeMutableRawPointer, _ capture: UnsafeMutableRawPointer
) -> UInt32 {
    let storage = UnsafeMutableRawBufferPointer(start: profile, count: 39_696)
    guard var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
        resumingActiveStorage: UnsafeMutableRawBufferPointer(rebasing: storage[31_632 ..< 35_472]),
        sealedStorage: UnsafeMutableRawBufferPointer(rebasing: storage[35_472 ..< 39_312])
    ), case .accepted = giftUIStaticRepository.clear(
        admission: &admission,
        captureStorage: UnsafeMutableRawBufferPointer(start: capture, count: 19_392)
    ) else { return 0 }
    giftUIStaticHasPendingFacts = true
    return 1
}

// This injects a model fact; the production host still schedules and presents it.
@_cdecl("giftui_signal_analyzer_rehearsal_diagnostic")
public func giftUISignalAnalyzerRehearsalDiagnostic() -> UInt32 {
    guard let diagnostic = giftUIStaticSampleDiagnostic(),
        giftUIStaticModelLocation.beginMutation(),
        giftUIStaticModelLocation.setAcquisitionState(.failed(diagnostic)),
        giftUIStaticModelLocation.endMutation()
    else { return 0 }
    return 1
}

// Exercise the maximum bounded diagnostic through the real render handoff.
@_cdecl("giftui_signal_analyzer_rehearsal_maximum_diagnostic")
public func giftUISignalAnalyzerRehearsalMaximumDiagnostic() -> UInt32 {
    let text: StaticString =
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    let diagnostic = text.withUTF8Buffer { SignalAnalyzerDiagnostic(exactUTF8: $0) }
    guard let diagnostic, diagnostic.utf8ByteCount == 96,
        giftUIStaticModelLocation.beginMutation(),
        giftUIStaticModelLocation.setAcquisitionState(.failed(diagnostic)),
        giftUIStaticModelLocation.endMutation()
    else { return 0 }
    return 1
}

nonisolated(unsafe) private var rehearsalWriteCount: UInt32 = 0

// Explicit native fixture only: run the selected firmware owner with typed
// boundary outcomes while retaining real model, regions, and cleanup methods.
private func rehearsalOwnerCycle(
    profile: UnsafeMutableRawBufferPointer, capture: UnsafeMutableRawBufferPointer,
    raster: UnsafeMutableRawPointer, coverage: UnsafeMutableRawPointer,
    failure: (RuntimeCompletePipelineStage, RunCycleFailure<SignalAnalyzerCycleOwnerFailure>)? =
        nil,
    offer: FrameOfferDisposition? = nil,
    partialPrefix: UInt16? = nil,
    admitChange: Bool = true,
    write: StaticSignalAnalyzerNRFEmbeddedPixelWrite = { _, _, _, _, _, _ in 0 },
    check: (
        borrowing StaticSignalAnalyzerCommonOwner,
        RuntimeCompletePipelineResult<SignalAnalyzerCycleOwnerFailure>, UInt32
    ) -> Void
) {
    withUnsafeMutablePointer(to: &giftUIStaticModelLocation) { model in
        withUnsafeMutablePointer(to: &giftUIStaticRepository) { repository in
            withUnsafeMutablePointer(to: &giftUIStaticInteractionOwner) { interaction in
                withUnsafeMutablePointer(to: &giftUIStaticGestureSession) { gestures in
                    guard
                        var owner = StaticSignalAnalyzerCommonOwner(
                            profile: profile, capture: capture, raster: raster, coverage: coverage,
                            write: write, model: model, repository: repository,
                            interaction: interaction, gestures: gestures,
                            presentationRevision: PresentationRevision(rawValue: 2), initial: false,
                            injectedFailure: failure, injectedOffer: offer)
                    else { preconditionFailure("production owner construction") }
                    if partialPrefix == nil && admitChange {
                        precondition(owner.admission.beginProducer(.action))
                        guard case .accepted = owner.admission.admitAcquisitionState(.stopped)
                        else { preconditionFailure("state admission") }
                        owner.admission.endProducer()
                    }
                    if let partialPrefix {
                        precondition(owner.admission.beginProducer(.action))
                        for ordinal in 0 ..< partialPrefix {
                            guard
                                case .accepted = owner.admission.admitAcquisitionState(
                                    ordinal.isMultiple(of: 2) ? .running : .stopped)
                            else { preconditionFailure("prefix admission") }
                        }
                        guard
                            case .accepted = owner.admission.admitCaptureMutation(
                                revision: owner.model.pointee.capture.revision + 2,
                                change: .reset(
                                    baseRevision: owner.model.pointee.capture.revision + 1,
                                    baselines: .allLow))
                        else { preconditionFailure("mismatch admission") }
                        owner.admission.endProducer()
                    }
                    let result = RuntimeCompletePipeline.run(owner: &owner)
                    let code = owner.finish(result)
                    check(owner, result, code)
                    precondition(owner.admission.takeNextSealed() == nil)
                    precondition(!owner.model.pointee.isMutating)
                    precondition(!owner.interaction.pointee.candidateIsReadyForOffer)
                    precondition(!owner.drawing.isActive && !owner.layoutWorkspace.packed.isActive)
                }
            }
        }
    }
}

@_cdecl("giftui_signal_analyzer_rehearsal_common_owner")
public func giftUISignalAnalyzerRehearsalCommonOwner(
    _ profilePointer: UnsafeMutableRawPointer, _ capturePointer: UnsafeMutableRawPointer,
    _ raster: UnsafeMutableRawPointer, _ coverage: UnsafeMutableRawPointer
) -> UInt32 {
    let profile = UnsafeMutableRawBufferPointer(start: profilePointer, count: 39_696)
    let capture = UnsafeMutableRawBufferPointer(start: capturePointer, count: 19_392)
    func start() {
        giftUISignalAnalyzerRetireInitial()
        // Each scenario is a fresh firmware/input graph, as terminal retirement requires.
        giftUIStaticInput = StaticSignalAnalyzerNRFFirmwareInputStorage()
        precondition(giftUISignalAnalyzerInputInitialize(1) == 0)
        precondition(
            giftUISignalAnalyzerPresentInitial(
                profilePointer, 39_696, capturePointer, 19_392, raster, 2_560, coverage, 160,
                { _, _, _, _, _, _ in 0 }) == 1)
        precondition(giftUISignalAnalyzerInputInstallPresentation(1) == 0)

    }
    let failures:
        [(RuntimeCompletePipelineStage, RunCycleFailure<SignalAnalyzerCycleOwnerFailure>)] = [
            (
                .observableCandidateAndSemanticExpansion,
                .focusedOwner(.runtime(.observableState(.locationCapacityExhausted)))
            ),
            (
                .observableCandidateAndSemanticExpansion,
                .focusedOwner(.runtime(.semantic(.capacityExhausted)))
            ),
            (.layout, .focusedOwner(.runtime(.layout(.capacityExhausted)))),
            (.canvasInvocationAndPlan, .focusedOwner(.runtime(.drawing(.capacityExhausted)))),
            (.combinedRenderPreflight, .renderProduction(.capacityExhausted)),
            (.interactionCandidate, .focusedOwner(.runtime(.interaction(.missingModelTarget)))),
            (
                .observableCandidateAndSemanticExpansion,
                .focusedOwner(.runtime(.observableState(.invalidPhaseContained)))
            ),
            (
                .observableCandidateAndSemanticExpansion,
                .focusedOwner(.runtime(.observableState(.invariantViolation)))
            ),
            (.applyAdmittedWork, .focusedOwner(.application(.captureRevisionMismatch))),
        ]
    for (stage, failure) in failures {
        start()
        let prior = StaticSignalAnalyzerNRFEmbeddedSemanticView(
            published: UnsafeMutableRawBufferPointer(rebasing: profile[3_024 ..< 6_048]))!.revision
        rehearsalOwnerCycle(
            profile: profile, capture: capture, raster: raster, coverage: coverage,
            failure: (stage, failure)
        ) { owner, result, code in
            guard case .failed(let record) = result else { preconditionFailure("first cause lost") }
            precondition(
                record.stage == stage && record.failure == failure && record.publication == nil)
            precondition(owner.state.finalizations == 2)
            precondition(
                owner.interaction.pointee.committedRevision == PresentationRevision(rawValue: 1))
            precondition(
                StaticSignalAnalyzerNRFEmbeddedSemanticView(
                    published: UnsafeMutableRawBufferPointer(rebasing: profile[3_024 ..< 6_048]))!
                    .revision == prior)
            if case .focusedOwner(.application) = failure {
                precondition(code == 0 && owner.state.applicationPolicyCalls == 1)
                precondition(owner.state.policy.callCount == 0 && !owner.state.isAvailable)
                precondition(
                    owner.state.lastApplicationEffects
                        == SignalAnalyzerRuntimeFailureRule.evaluate(
                            .captureRevisionMismatch, context: .activeDelivery,
                            stableStateProven: false, existingLiveModel: true
                        ).effectBits)
                if case .failed = owner.model.pointee.acquisitionState {
                } else {
                    preconditionFailure("mandatory failed state")
                }
                precondition(owner.firstFailure.detectingContext?.phase == .mutating)
            } else if failure == .focusedOwner(.runtime(.observableState(.invalidPhaseContained))) {
                precondition(
                    code == 2 && owner.state.policy.callCount == 0 && owner.state.semanticRetry)
            } else if failure == .focusedOwner(.runtime(.observableState(.invariantViolation))) {
                precondition(code == 0 && owner.state.policy.lastContext == .safetyNotProven)
            } else {
                precondition(
                    code == 2 && owner.state.policy.lastContext == .containedCandidateFailure)
                precondition(owner.state.policy.callCount == 1 && owner.state.semanticRetry)
            }
            let fact = SignalAnalyzerCycleFailureNormalizer.cycleFailure(
                record.failure,
                context: owner.firstFailure.detectingContext ?? owner.context)
            if failure != .focusedOwner(.runtime(.observableState(.invalidPhaseContained)))
                && failure != .focusedOwner(.runtime(.observableState(.invariantViolation)))
                && stage != .applyAdmittedWork
            {
                print(
                    "production-fault\tstage=\(stage.rawValue)\tcondition=\(fact.condition.rawValue)\torigin=\(fact.origin.rawValue)\tscope=\(fact.affectedScope.rawValue)\tcontainment=\(fact.containment.rawValue)\tdirty=\(record.disposition.semanticDisposition == .dirty ? 1 : 0)\tpriorRouting=1\tfinalizations=2"
                )
            }
            print(
                "static-owner-fault stage=\(stage.rawValue) cleanup=\(owner.state.lastCleanup) finalizations=\(owner.state.finalizations) policyCalls=\(owner.state.policy.callCount) status=passed"
            )
        }
    }
    for prefix: UInt16 in [0, 1, 3] {
        start()
        rehearsalOwnerCycle(
            profile: profile, capture: capture, raster: raster, coverage: coverage,
            partialPrefix: prefix
        ) { owner, result, code in
            guard case .failed(let record) = result else {
                preconditionFailure("partial rejection lost")
            }
            precondition(record.stage == .applyAdmittedWork)
            precondition(record.failure == .focusedOwner(.application(.captureRevisionMismatch)))
            precondition(
                record.disposition.semanticDisposition == (prefix == 0 ? .unchanged : .dirty))
            precondition(
                code == 0 && owner.state.finalizations == 2
                    && owner.state.applicationPolicyCalls == 1)
            precondition(owner.firstFailure.detectingContext?.phase == .mutating)
            precondition(
                owner.interaction.pointee.committedRevision == PresentationRevision(rawValue: 1))
            print(
                "static-owner-partial prefix=\(prefix) firstCause=captureRevisionMismatch finalizations=2 replay=0 status=passed"
            )
        }
    }
    start()
    var published: UInt32 = 0
    for (ordinal, disposition) in [
        FrameOfferDisposition.retryableRefusal, .backpressured, .retryableRefusal,
        .retryableRefusal,
    ].enumerated() {
        rehearsalOwnerCycle(
            profile: profile, capture: capture, raster: raster, coverage: coverage,
            offer: disposition, admitChange: ordinal == 0
        ) { owner, result, code in
            guard case .completed(let completion) = result else {
                preconditionFailure("recovery failed")
            }
            precondition(completion.committedPresentationRevision == nil)
            let revision = completion.publication.semanticRevision.rawValue
            if ordinal == 0 { published = revision } else { precondition(revision == published) }
            precondition(owner.state.finalizations == UInt32(ordinal + 2))
            precondition(
                owner.interaction.pointee.committedRevision == PresentationRevision(rawValue: 1))
            if ordinal < 3 {
                precondition(code == 2 && owner.state.isAvailable)
                precondition(
                    owner.state.recovery.pendingIntent?.retryableRefusalCount
                        == (ordinal < 2 ? 1 : 2))
                precondition(giftUIStaticPresentationPending)
            } else {
                precondition(
                    code == 0 && !owner.state.isAvailable
                        && owner.state.recovery.pendingIntent == nil)
            }
        }
    }
    print(
        "static-owner-recovery refusals=3 backpressure=preserved semanticRevision=\(published) status=passed"
    )
    start()
    rehearsalWriteCount = 0
    rehearsalOwnerCycle(profile: profile, capture: capture, raster: raster, coverage: coverage,
        write: { _, _, _, _, _, _ in
            rehearsalWriteCount += 1
            return rehearsalWriteCount == 1 ? 0 : -1
        }) { owner, result, code in
        guard case .completed(let completion) = result else { preconditionFailure("accepted responsibility lost") }
        precondition(completion.committedPresentationRevision == PresentationRevision(rawValue: 2))
        precondition(owner.interaction.pointee.committedRevision == PresentationRevision(rawValue: 2))
        precondition(code == 0 && !owner.state.isAvailable && owner.state.finalizations == 2)
        precondition(owner.state.policy.callCount == 1 && !owner.state.health.inputIsEligible)
        print("static-owner-health responsibility=accepted stream=failed input=quiescent finalizations=2 status=passed")
    }
    giftUISignalAnalyzerRetireInitial()
    return 1
}
