#if !hasFeature(Embedded)
    import P08CounterSchema
    import GiftUI
    import GiftUIDrawing
    import GiftUIExecution
    import GiftUIHostConfiguration
    import GiftUIObservableState
    import GiftUIRuntimeCore
    import GiftUIRuntimeDynamic
    import GiftUISemanticCore

    func counterRunDynamicHostLifecycle<Geometry, Candidate, Committed, Hits>(
        host:
            inout SignalAnalyzerPresetHostInstance<
                CounterDynamicHostOwner<Geometry, Candidate, Committed, Hits>
            >, control pointer: UnsafeMutablePointer<CounterControl>, report: HostAssemblyReport,
        failAfterRuntime: Bool, joinChecks: Int
    ) -> Int
    where
        Geometry: CounterGeometry & ~Copyable & ~Escapable,
        Candidate: CounterCandidateBacking & ~Copyable & ~Escapable,
        Committed: CounterCommittedBacking & ~Copyable & ~Escapable,
        Hits: CounterHitBacking & ~Copyable & ~Escapable,
        Candidate.Identity == SemanticCompleteIdentity,
        Committed.Identity == SemanticCompleteIdentity, Hits.Identity == SemanticCompleteIdentity
    {
        let p08ExactCase75: Bool
        if case .valid = host.lifecycleState {
            if host.owner.constructions == 0 {
                if pointer.pointee.finalized == 0 {
                    p08ExactCase75 = true
                } else {
                    p08ExactCase75 = false
                }
            } else {
                p08ExactCase75 = false
            }
        } else {
            p08ExactCase75 = false
        }
        precondition(p08ExactCase75)
        let p08ExactCase76: Bool
        if case .invalidLifecycle = host.runOpportunity() {
            p08ExactCase76 = true
        } else {
            p08ExactCase76 = false
        }
        precondition(p08ExactCase76)
        var count = 2 + joinChecks
        let activation = host.activate()
        if failAfterRuntime || pointer.pointee.idleQuiesceMode != 0 {
            let p08ExactCase77: Bool
            if case .failure(.configuration(.arithmeticOverflow)) = activation {
                if case .failed = host.lifecycleState {
                    p08ExactCase77 = true
                } else {
                    p08ExactCase77 = false
                }
            } else {
                p08ExactCase77 = false
            }
            precondition(p08ExactCase77)
            let failedStep: UInt8 = failAfterRuntime ? 1 : pointer.pointee.idleQuiesceMode
            precondition(host.owner.activationStep == failedStep && host.owner.constructions == 1)
            precondition(
                pointer.pointee.teardowns == 1
                    && pointer.pointee.finalized == (failedStep < 3 ? 0 : failedStep < 5 ? 1 : 2))
            precondition(pointer.pointee.unavailable && !pointer.pointee.inputGate.inputIsEligible)
            precondition(pointer.pointee.admission.pendingStateCount == 0)
            precondition(
                pointer.pointee.observationsInstalled == (failedStep >= 4 ? 1 : 0)
                    && pointer.pointee.observationsDetached == (failedStep >= 4 ? 1 : 0))
            count += 6
        } else {
            let p08ExactCase78: Bool
            if case .active = activation {
                if host.owner.activationStep == 7 {
                    if host.owner.constructions == 1 {
                        p08ExactCase78 = true
                    } else {
                        p08ExactCase78 = false
                    }
                } else {
                    p08ExactCase78 = false
                }
            } else {
                p08ExactCase78 = false
            }
            precondition(p08ExactCase78)
            precondition(
                pointer.pointee.finalized == 2 && pointer.pointee.commits == 1
                    && pointer.pointee.committedRecords == 2)
            precondition(pointer.pointee.admission.pendingStateCount == 1)
            let wakeControl = CounterHostControl(pointer: pointer)
            guard
                case .wait(untilMicroseconds: 250000) = counterServiceHost(
                    at: 0, host: &host, control: wakeControl)
            else { preconditionFailure("counter actual wake pacing") }
            guard
                case .cycle(.admittedWork, .cycle(.success)) = counterServiceHost(
                    at: 250000, host: &host, control: wakeControl)
            else { preconditionFailure("counter actual paced wake") }
            precondition(
                pointer.pointee.finalized == 3 && pointer.pointee.admission.pendingStateCount == 0)
            guard case .noWork = counterServiceHost(at: 250000, host: &host, control: wakeControl)
            else { preconditionFailure("counter no idle polling") }
            count += 7 + counterHostCorpus(host: &host, control: pointer)
        }
        let p08ExactCase79: Bool
        if case .failure(.invariant) = host.activate() {
            if host.owner.constructions == 1 {
                p08ExactCase79 = true
            } else {
                p08ExactCase79 = false
            }
        } else {
            p08ExactCase79 = false
        }
        precondition(p08ExactCase79)
        host.teardown()
        let p08ExactCase80: Bool
        if case .quiescent = host.lifecycleState {
            if !host.controller.assemblyReportRuntimeUseIsValid {
                if host.owner.teardownStep == 8 {
                    p08ExactCase80 = true
                } else {
                    p08ExactCase80 = false
                }
            } else {
                p08ExactCase80 = false
            }
        } else {
            p08ExactCase80 = false
        }
        precondition(p08ExactCase80)
        precondition(
            pointer.pointee.teardowns == 1 && pointer.pointee.committedRecords == 0
                && !pointer.pointee.hasRoot)
        host.teardown()
        let p08ExactCase81: Bool
        if host.owner.teardownStep == 8 {
            if case .invalidLifecycle = host.runOpportunity() {
                p08ExactCase81 = true
            } else {
                p08ExactCase81 = false
            }
        } else {
            p08ExactCase81 = false
        }
        precondition(p08ExactCase81)
        precondition(host.assemblyReport == report)
        let selectedFailure: UInt8 = failAfterRuntime ? 1 : pointer.pointee.idleQuiesceMode
        let expectedApplication = selectedFailure == 1 ? 0 : 1
        let expectedObservation = selectedFailure == 0 || selectedFailure >= 4 ? 1 : 0
        let expectedCallback = selectedFailure == 0 || selectedFailure >= 6 ? 1 : 0
        precondition(pointer.pointee.applicationConstructions == expectedApplication)
        precondition(
            pointer.pointee.applicationCallbacks == expectedCallback
                && pointer.pointee.reentrantApplicationRejections == expectedCallback)
        precondition(
            pointer.pointee.observationsInstalled == expectedObservation
                && pointer.pointee.observationsDetached == expectedObservation)
        precondition(pointer.pointee.stoppedApplicationChecks >= expectedApplication)
        var stoppedAdmission = CounterAdmission(borrowing: pointer)
        let p08ExactCase82: Bool
        if case .unavailable = stoppedAdmission.submit(stateChange: 9).result {
            p08ExactCase82 = true
        } else {
            p08ExactCase82 = false
        }
        precondition(p08ExactCase82)
        precondition(pointer.pointee.admission.pendingStateCount == 0)
        precondition(!pointer.pointee.inputGate.inputIsEligible)
        let rejectedInput = pointer.pointee.inputGate.submit(
            phase: .down, position: .init(x: 0, y: 0), source: .init(rawValue: 0),
            observedPresentationRevision: pointer.pointee.runtime.committedPresentation,
            isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &stoppedAdmission)
        let p08ExactCase83: Bool
        if case .sourceQuiesced(.inputUnavailable) = rejectedInput {
            p08ExactCase83 = true
        } else {
            p08ExactCase83 = false
        }
        precondition(p08ExactCase83)
        return count + 13
    }

    func counterCheckDynamicRejectedBindings<Geometry, Candidate, Committed, Hits>(
        owner: inout CounterDynamicHostOwner<Geometry, Candidate, Committed, Hits>,
        models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>,
        root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>,
        foreignModels: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>,
        foreignRoot:
            borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>,
        control pointer: UnsafeMutablePointer<CounterControl>,
        foreignControl: UnsafeMutablePointer<CounterControl>,
        audit: RuntimeStorageAudit, report: HostAssemblyReport,
        expected: CounterJoinSnapshot, foreignExpected: CounterJoinSnapshot
    ) -> Int
    where
        Geometry: CounterGeometry & ~Copyable & ~Escapable,
        Candidate: CounterCandidateBacking & ~Copyable & ~Escapable,
        Committed: CounterCommittedBacking & ~Copyable & ~Escapable,
        Hits: CounterHitBacking & ~Copyable & ~Escapable,
        Candidate.Identity == SemanticCompleteIdentity,
        Committed.Identity == SemanticCompleteIdentity, Hits.Identity == SemanticCompleteIdentity
    {
        var joinChecks = 0
        let rejected0 = owner.constructRuntimeAndEndpoint(
            models: models, root: root, control: foreignControl, audit: audit, report: report)
        let p08RejectedBinding0: Bool
        if case .failure(.configuration(.invalidWakeIntegration), let progress) = rejected0 {
            p08RejectedBinding0 =
                !progress.runtimeConstructed
                && !progress.observationInstalled && !progress.sourceStarted
        } else {
            p08RejectedBinding0 = false
        }
        precondition(p08RejectedBinding0)
        precondition(owner.constructions == 0 && owner.activationStep == 0)
        precondition(
            counterJoinSnapshot(pointer) == expected
                && counterJoinSnapshot(foreignControl) == foreignExpected)
        joinChecks += 3
        let rejected1 = owner.constructRuntimeAndEndpoint(
            models: foreignModels, root: foreignRoot, control: pointer, audit: audit, report: report
        )
        let p08RejectedBinding1: Bool
        if case .failure(.configuration(.invalidModelTarget), let progress) = rejected1 {
            p08RejectedBinding1 =
                !progress.runtimeConstructed
                && !progress.observationInstalled && !progress.sourceStarted
        } else {
            p08RejectedBinding1 = false
        }
        precondition(p08RejectedBinding1)
        precondition(owner.constructions == 0 && owner.activationStep == 0)
        precondition(
            counterJoinSnapshot(pointer) == expected
                && counterJoinSnapshot(foreignControl) == foreignExpected)
        joinChecks += 3
        let rejected2 = owner.constructRuntimeAndEndpoint(
            models: models, root: foreignRoot, control: pointer, audit: audit, report: report)
        let p08RejectedBinding2: Bool
        if case .failure(.configuration(.invalidModelTarget), let progress) = rejected2 {
            p08RejectedBinding2 =
                !progress.runtimeConstructed
                && !progress.observationInstalled && !progress.sourceStarted
        } else {
            p08RejectedBinding2 = false
        }
        precondition(p08RejectedBinding2)
        precondition(owner.constructions == 0 && owner.activationStep == 0)
        precondition(
            counterJoinSnapshot(pointer) == expected
                && counterJoinSnapshot(foreignControl) == foreignExpected)
        joinChecks += 3
        let rejected3 = owner.constructRuntimeAndEndpoint(
            models: models, root: root, control: pointer,
            audit: counterJoinAudit(audit, profile: .static), report: report)
        let p08RejectedBinding3: Bool
        if case .failure(.configuration(.profileMismatch), let progress) = rejected3 {
            p08RejectedBinding3 =
                !progress.runtimeConstructed
                && !progress.observationInstalled && !progress.sourceStarted
        } else {
            p08RejectedBinding3 = false
        }
        precondition(p08RejectedBinding3)
        precondition(owner.constructions == 0 && owner.activationStep == 0)
        precondition(
            counterJoinSnapshot(pointer) == expected
                && counterJoinSnapshot(foreignControl) == foreignExpected)
        joinChecks += 3
        let rejected4 = owner.constructRuntimeAndEndpoint(
            models: models, root: root, control: pointer,
            audit: counterJoinAudit(audit, profile: audit.profile), report: report)
        let p08RejectedBinding4: Bool
        if case .failure(.configuration(.invalidWorkload), let progress) = rejected4 {
            p08RejectedBinding4 =
                !progress.runtimeConstructed
                && !progress.observationInstalled && !progress.sourceStarted
        } else {
            p08RejectedBinding4 = false
        }
        precondition(p08RejectedBinding4)
        precondition(owner.constructions == 0 && owner.activationStep == 0)
        precondition(
            counterJoinSnapshot(pointer) == expected
                && counterJoinSnapshot(foreignControl) == foreignExpected)
        joinChecks += 3
        let rejected5 = owner.constructRuntimeAndEndpoint(
            models: models, root: root, control: pointer, audit: audit,
            report: counterJoinReport(report))
        let p08RejectedBinding5: Bool
        if case .failure(.configuration(.invalidWakeIntegration), let progress) = rejected5 {
            p08RejectedBinding5 =
                !progress.runtimeConstructed
                && !progress.observationInstalled && !progress.sourceStarted
        } else {
            p08RejectedBinding5 = false
        }
        precondition(p08RejectedBinding5)
        precondition(owner.constructions == 0 && owner.activationStep == 0)
        precondition(
            counterJoinSnapshot(pointer) == expected
                && counterJoinSnapshot(foreignControl) == foreignExpected)
        joinChecks += 3
        return joinChecks
    }

#endif
