import Foundation
import XCTest

@testable import GiftUIFailureCore

final class GiftUIFailureCoreTests: XCTestCase {
    func testConditionIDAcceptsEveryBitPattern() {
        for rawValue in UInt16.min ... UInt16.max {
            XCTAssertEqual(GiftUIConditionID(rawValue: rawValue).rawValue, rawValue)
        }
    }

    func testSharedConditionCatalogueHasExactUniqueRawValues() {
        let catalogue: [(GiftUIConditionID, UInt16)] = [
            (.unknownProducerCondition, 0),
            (.invalidValue, 1),
            (.arithmeticOverflow, 2),
            (.capacityExhausted, 3),
            (.invalidIdentity, 4),
            (.invalidProvenance, 5),
            (.invalidPhase, 6),
            (.reentrancyViolation, 7),
            (.requiredFacilityUnavailable, 8),
            (.nonRetryableRefusal, 9),
            (.invariantViolation, 10),
        ]

        XCTAssertEqual(catalogue.map(\.0.rawValue), catalogue.map(\.1))
        XCTAssertEqual(Set(catalogue.map(\.0.rawValue)).count, catalogue.count)
        XCTAssertEqual(GiftUIConditionID(rawValue: 11).rawValue, 11)
        XCTAssertEqual(GiftUIConditionID(rawValue: .max).rawValue, .max)
    }

    func testFailureOriginsHaveExactRawValues() {
        let cases: [(GiftUIFailureOrigin, UInt8)] = [
            (.foundation, 0),
            (.capability, 1),
            (.semantic, 2),
            (.layout, 3),
            (.rendering, 4),
            (.execution, 5),
            (.observableState, 6),
            (.interaction, 7),
            (.backend, 8),
            (.presentationIntegration, 9),
            (.inputIntegration, 10),
            (.hostComposition, 11),
            (.displayDriver, 12),
            (.inputDriver, 13),
            (.transport, 14),
        ]

        XCTAssertEqual(cases.map(\.0.rawValue), cases.map(\.1))
        XCTAssertEqual(Set(cases.map(\.0.rawValue)).count, cases.count)
    }

    func testAffectedScopesAreDistinctTagsWithExactRawValues() {
        let cases: [(GiftUIAffectedScope, UInt8)] = [
            (.operation, 0),
            (.activeCycle, 1),
            (.candidateFrame, 2),
            (.component, 3),
            (.runtime, 4),
        ]

        XCTAssertEqual(cases.map(\.0.rawValue), cases.map(\.1))
        XCTAssertEqual(Set(cases.map(\.0.rawValue)).count, cases.count)
        XCTAssertNotEqual(GiftUIAffectedScope.activeCycle, .candidateFrame)
    }

    func testContainmentHasExactRawValues() {
        XCTAssertEqual(GiftUIContainment.contained.rawValue, 0)
        XCTAssertEqual(GiftUIContainment.safetyNotProven.rawValue, 1)
        XCTAssertNotEqual(GiftUIContainment.contained, .safetyNotProven)
    }

    func testFailureFactPreservesEveryFieldAndSourceIdentityPair() {
        let fact = GiftUIFailureFact(
            condition: .arithmeticOverflow,
            origin: .foundation,
            affectedScope: .operation,
            containment: .contained
        )
        let copy = fact
        let differentOrigin = GiftUIFailureFact(
            condition: .arithmeticOverflow,
            origin: .layout,
            affectedScope: .operation,
            containment: .contained
        )

        XCTAssertEqual(copy, fact)
        XCTAssertEqual(fact.condition, .arithmeticOverflow)
        XCTAssertEqual(fact.origin, .foundation)
        XCTAssertEqual(fact.affectedScope, .operation)
        XCTAssertEqual(fact.containment, .contained)
        XCTAssertNotEqual(differentOrigin, fact)
    }

    func testCoreFactLayoutsAreBounded() {
        XCTAssertEqual(MemoryLayout<GiftUIConditionID>.size, 2)
        XCTAssertEqual(MemoryLayout<GiftUIConditionID>.stride, 2)
        XCTAssertEqual(MemoryLayout<GiftUIFailureOrigin>.size, 1)
        XCTAssertEqual(MemoryLayout<GiftUIAffectedScope>.size, 1)
        XCTAssertEqual(MemoryLayout<GiftUIContainment>.size, 1)
        XCTAssertLessThanOrEqual(MemoryLayout<GiftUIFailureFact>.size, 8)
        XCTAssertLessThanOrEqual(MemoryLayout<GiftUIFailureFact>.stride, 8)
        XCTAssertLessThanOrEqual(MemoryLayout<GiftUIFailureFact>.alignment, 2)
    }

    func testCoreFactsSatisfySendableContracts() {
        requireSendable(GiftUIConditionID.self)
        requireSendable(GiftUIFailureOrigin.self)
        requireSendable(GiftUIAffectedScope.self)
        requireSendable(GiftUIContainment.self)
        requireSendable(GiftUIFailureFact.self)
    }

    func testOperationalKindsHaveExactRawValues() {
        let cases: [(GiftUIOperationalKind, UInt8)] = [
            (.noChange, 0),
            (.cacheMiss, 1),
            (.backpressured, 2),
            (.superseded, 3),
            (.deferredToLaterAdmission, 4),
            (.retryableRefusal, 5),
        ]

        XCTAssertEqual(cases.map(\.0.rawValue), cases.map(\.1))
        XCTAssertEqual(Set(cases.map(\.0.rawValue)).count, cases.count)
    }

    func testOperationalFactPreservesEveryField() {
        let fact = GiftUIOperationalFact(
            kind: .backpressured,
            origin: .inputIntegration,
            affectedScope: .operation
        )

        XCTAssertEqual(fact.kind, .backpressured)
        XCTAssertEqual(fact.origin, .inputIntegration)
        XCTAssertEqual(fact.affectedScope, .operation)
        XCTAssertEqual(fact, fact)
        XCTAssertLessThanOrEqual(MemoryLayout<GiftUIOperationalFact>.size, 4)
    }

    func testOutcomePreservesAllThreeCategories() {
        let success = GiftUIOutcome<UInt32>.success(42)
        let operational = GiftUIOutcome<UInt32>.operational(
            GiftUIOperationalFact(
                kind: .noChange,
                origin: .semantic,
                affectedScope: .activeCycle
            ))
        let failureFact = GiftUIFailureFact(
            condition: .invariantViolation,
            origin: .semantic,
            affectedScope: .activeCycle,
            containment: .safetyNotProven
        )
        let failure = GiftUIOutcome<UInt32>.failure(failureFact)

        guard case .success(let value) = success else {
            return XCTFail("expected success")
        }
        XCTAssertEqual(value, 42)

        guard case .operational(let fact) = operational else {
            return XCTFail("expected operational")
        }
        XCTAssertEqual(fact.kind, .noChange)

        guard case .failure(let fact) = failure else {
            return XCTFail("expected failure")
        }
        XCTAssertEqual(fact, failureFact)
    }

    func testOutcomeConditionalConformancesUseValueStorage() {
        requireSendable(GiftUIOutcome<UInt32>.self)
        requireEquatable(GiftUIOutcome<UInt32>.self)

        let first = GiftUIOutcome<UInt32>.success(7)
        let second = first
        XCTAssertEqual(first, second)
        XCTAssertLessThanOrEqual(
            MemoryLayout<GiftUIOutcome<UInt32>>.size,
            max(
                MemoryLayout<UInt32>.size,
                MemoryLayout<GiftUIFailureFact>.size
            ) + MemoryLayout<UInt>.size
        )
    }

    func testAnnotationsRetainTwoEntriesInOrder() {
        let first = GiftUIFailureAnnotation(key: .min, value: .max)
        let second = GiftUIFailureAnnotation(key: .max, value: .min)
        var annotations = GiftUIFailureAnnotations()

        XCTAssertEqual(GiftUIFailureAnnotations.capacity, 2)
        XCTAssertEqual(annotations.count, 0)
        XCTAssertNil(annotations[0])
        XCTAssertNil(annotations[1])
        XCTAssertTrue(annotations.append(first))
        XCTAssertTrue(annotations.append(second))
        XCTAssertEqual(annotations.count, 2)
        XCTAssertEqual(annotations[0], first)
        XCTAssertEqual(annotations[1], second)
        XCTAssertNil(annotations[2])
        XCTAssertNil(annotations[.max])
    }

    func testThirdAnnotationIsRefusedWithoutMutation() {
        var annotations = GiftUIFailureAnnotations()
        XCTAssertTrue(annotations.append(GiftUIFailureAnnotation(key: 1, value: 11)))
        XCTAssertTrue(annotations.append(GiftUIFailureAnnotation(key: 2, value: 22)))
        let beforeRefusal = annotations

        XCTAssertFalse(annotations.append(GiftUIFailureAnnotation(key: 3, value: 33)))
        XCTAssertEqual(annotations, beforeRefusal)
        XCTAssertEqual(annotations.count, 2)
        XCTAssertEqual(annotations[0], GiftUIFailureAnnotation(key: 1, value: 11))
        XCTAssertEqual(annotations[1], GiftUIFailureAnnotation(key: 2, value: 22))
    }

    func testAnnotationLayoutsAndConformancesAreBounded() {
        XCTAssertLessThanOrEqual(MemoryLayout<GiftUIFailureAnnotation>.size, 8)
        XCTAssertLessThanOrEqual(MemoryLayout<GiftUIFailureAnnotations>.size, 20)
        XCTAssertLessThanOrEqual(MemoryLayout<GiftUIFailureAnnotations>.stride, 20)
        requireSendable(GiftUIOperationalKind.self)
        requireSendable(GiftUIOperationalFact.self)
        requireSendable(GiftUIFailureAnnotation.self)
        requireSendable(GiftUIFailureAnnotations.self)
    }

    func testContainmentNormalizationIsExhaustivelyConservative() {
        for rawValue in UInt8.min ... UInt8.max {
            let fact = GiftUIFailureNormalization.normalizeFailure(
                condition: .invalidValue,
                origin: .backend,
                affectedScope: .candidateFrame,
                producerContainmentRawValue: rawValue
            )

            XCTAssertEqual(fact.condition, .invalidValue)
            XCTAssertEqual(fact.origin, .backend)
            XCTAssertEqual(fact.affectedScope, .candidateFrame)
            XCTAssertEqual(
                fact.containment,
                rawValue == GiftUIContainment.contained.rawValue
                    ? .contained
                    : .safetyNotProven
            )
        }
    }

    func testUnknownProducerFailureIsAlwaysSafetyNotProven() {
        for origin in allOrigins {
            for affectedScope in allAffectedScopes {
                let fact = GiftUIFailureNormalization.unknownProducerFailure(
                    origin: origin,
                    affectedScope: affectedScope
                )

                XCTAssertEqual(fact.condition, .unknownProducerCondition)
                XCTAssertEqual(fact.origin, origin)
                XCTAssertEqual(fact.affectedScope, affectedScope)
                XCTAssertEqual(fact.containment, .safetyNotProven)
            }
        }
    }

    func testPropagationWithoutProofPreservesEveryFactField() {
        for origin in allOrigins {
            for affectedScope in allAffectedScopes {
                for containment in allContainments {
                    let fact = GiftUIFailureFact(
                        condition: .invalidProvenance,
                        origin: origin,
                        affectedScope: affectedScope,
                        containment: containment
                    )

                    XCTAssertEqual(GiftUIFailureNormalization.propagate(fact), fact)
                }
            }
        }
    }

    func testExplicitProvenScopeMappingPreservesIdentityAndContainment() {
        for originalScope in allAffectedScopes {
            for provenScope in allAffectedScopes {
                let fact = GiftUIFailureFact(
                    condition: .capacityExhausted,
                    origin: .rendering,
                    affectedScope: originalScope,
                    containment: .safetyNotProven
                )
                let propagated = GiftUIFailureNormalization.propagate(
                    fact,
                    provenAffectedScope: provenScope
                )

                XCTAssertEqual(propagated.condition, fact.condition)
                XCTAssertEqual(propagated.origin, fact.origin)
                XCTAssertEqual(propagated.affectedScope, provenScope)
                XCTAssertEqual(propagated.containment, .safetyNotProven)
            }
        }
    }

    func testResidualDispositionRawValuesAndOptionBitsAreExact() {
        let cases: [(GiftUIResidualDisposition, UInt8, GiftUIAllowedDispositions)] = [
            (.continueOperation, 0, .continueOperation),
            (.requestPacedRetry, 1, .requestPacedRetry),
            (.markFacilityUnavailable, 2, .markFacilityUnavailable),
            (.quiesceAffectedScope, 3, .quiesceAffectedScope),
            (.invokeFatalHook, 4, .invokeFatalHook),
        ]

        for (disposition, rawValue, option) in cases {
            XCTAssertEqual(disposition.rawValue, rawValue)
            XCTAssertEqual(option.rawValue, 1 << rawValue)
        }
        requireSendable(GiftUIResidualDisposition.self)
        requireSendable(GiftUIAllowedDispositions.self)
    }

    func testResidualInputPreservesEveryValidField() throws {
        let fact = GiftUIOperationalFact(
            kind: .backpressured,
            origin: .inputIntegration,
            affectedScope: .operation
        )
        let outcome = GiftUIOutcome<Void>.operational(fact)
        let allowed: GiftUIAllowedDispositions = [
            .requestPacedRetry,
            .markFacilityUnavailable,
        ]
        let input = try XCTUnwrap(
            GiftUIResidualPolicyInput(
                outcome: outcome,
                context: UInt8(7),
                allowed: allowed,
                attemptOrdinal: 1,
                attemptLimit: 3
            ))

        guard case .operational(let preservedFact) = input.outcome else {
            return XCTFail("expected preserved operational outcome")
        }
        XCTAssertEqual(preservedFact, fact)
        XCTAssertEqual(input.context, 7)
        XCTAssertEqual(input.allowed, allowed)
        XCTAssertEqual(input.attemptOrdinal, 1)
        XCTAssertEqual(input.attemptLimit, 3)
    }

    func testResidualInputRejectsSuccessEmptyAndUnknownBits() {
        let operational = GiftUIOutcome<Void>.operational(
            GiftUIOperationalFact(
                kind: .noChange,
                origin: .semantic,
                affectedScope: .operation
            ))

        XCTAssertNil(policyInput(outcome: .success(()), allowed: .continueOperation))
        XCTAssertNil(policyInput(outcome: operational, allowed: []))
        for rawValue in UInt8(32) ... UInt8.max {
            XCTAssertNil(
                policyInput(
                    outcome: operational,
                    allowed: GiftUIAllowedDispositions(rawValue: rawValue)
                ))
        }
    }

    func testResidualInputRejectsEveryInvalidAttemptRange() {
        let outcome = GiftUIOutcome<Void>.operational(
            GiftUIOperationalFact(
                kind: .noChange,
                origin: .semantic,
                affectedScope: .operation
            ))

        for ordinal in UInt8.min ... UInt8.max {
            XCTAssertNil(
                policyInput(
                    outcome: outcome,
                    allowed: .continueOperation,
                    ordinal: ordinal,
                    limit: 0
                ))
        }
        for limit in UInt8(1) ... UInt8.max {
            for ordinal in limit ... UInt8.max {
                XCTAssertNil(
                    policyInput(
                        outcome: outcome,
                        allowed: .continueOperation,
                        ordinal: ordinal,
                        limit: limit
                    ))
            }
        }
    }

    func testPacedRetryRequiresExactKindAndUnexhaustedFutureAttempt() {
        for kind in allOperationalKinds {
            for limit in UInt8(1) ... UInt8.max {
                for ordinal in UInt8.min ..< limit {
                    let outcome = GiftUIOutcome<Void>.operational(
                        GiftUIOperationalFact(
                            kind: kind,
                            origin: .backend,
                            affectedScope: .candidateFrame
                        ))
                    let input = policyInput(
                        outcome: outcome,
                        allowed: .requestPacedRetry,
                        ordinal: ordinal,
                        limit: limit
                    )
                    let kindAllowsRetry = kind == .backpressured || kind == .retryableRefusal
                    let hasLaterAttempt = limit > 1 && ordinal < limit - 1
                    XCTAssertEqual(input != nil, kindAllowsRetry && hasLaterAttempt)
                }
            }
        }

        XCTAssertNil(
            policyInput(
                outcome: .failure(failureFact(containment: .contained)),
                allowed: .requestPacedRetry
            ))
    }

    func testSafetyNotProvenRejectsContinuation() {
        for scope in allAffectedScopes {
            XCTAssertNil(
                policyInput(
                    outcome: .failure(failureFact(scope: scope, containment: .safetyNotProven)),
                    allowed: [.continueOperation, .quiesceAffectedScope]
                ))
        }
    }

    func testRuntimeSafetyNotProvenAllowsOnlyTerminalChoices() {
        let outcome = GiftUIOutcome<Void>.failure(
            failureFact(
                scope: .runtime,
                containment: .safetyNotProven
            ))

        XCTAssertNotNil(policyInput(outcome: outcome, allowed: .quiesceAffectedScope))
        XCTAssertNotNil(policyInput(outcome: outcome, allowed: .invokeFatalHook))
        XCTAssertNotNil(
            policyInput(
                outcome: outcome,
                allowed: [.quiesceAffectedScope, .invokeFatalHook]
            ))
        XCTAssertNil(policyInput(outcome: outcome, allowed: .markFacilityUnavailable))
        XCTAssertNil(
            policyInput(
                outcome: outcome,
                allowed: [.quiesceAffectedScope, .markFacilityUnavailable]
            ))
    }

    func testContainedFailurePermitsDeclaredNonRetryChoices() {
        let outcome = GiftUIOutcome<Void>.failure(failureFact(containment: .contained))
        let allowed: GiftUIAllowedDispositions = [
            .continueOperation,
            .markFacilityUnavailable,
            .quiesceAffectedScope,
            .invokeFatalHook,
        ]

        XCTAssertNotNil(policyInput(outcome: outcome, allowed: allowed))
    }

    func testFixturePolicyEnumeratesEveryDeclaredInputExactlyOnce() throws {
        let rows = fixturePolicyRows
        XCTAssertEqual(rows.count, FixturePolicyContext.allCases.count)
        XCTAssertEqual(Set(rows.map(\.context.rawValue)).count, rows.count)
        XCTAssertEqual(
            Set(rows.map(\.context.rawValue)),
            Set(FixturePolicyContext.allCases.map(\.rawValue))
        )

        var policy = FixturePolicy()
        for row in rows {
            let input = try XCTUnwrap(
                GiftUIResidualPolicyInput(
                    outcome: row.outcome,
                    context: row.context,
                    allowed: row.allowed,
                    attemptOrdinal: row.attemptOrdinal,
                    attemptLimit: row.attemptLimit
                ))
            let result = policy.disposition(for: input)

            XCTAssertEqual(result, row.expected)
            XCTAssertTrue(row.allowed.contains(option(for: result)))
        }
        XCTAssertEqual(policy.invocationCount, rows.count)
        XCTAssertEqual(Set(rows.map(\.expected.rawValue)), Set(UInt8(0) ... UInt8(4)))
    }

    func testFixturePolicyCorpusMatchesCheckedInSharedRows() throws {
        let fixtureRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("ContractFixtures/SPEC003/SemanticCorpus/cases.tsv")
        let checkedInRows = try String(contentsOf: fixtureRoot, encoding: .utf8)
            .split(separator: "\n")
            .filter { !$0.hasPrefix("#") && !$0.isEmpty }
            .map(String.init)
            .filter { $0.contains("\tresidual-policy\t") }
        let expectedRows = fixturePolicyRows.map(\.corpusRow)

        XCTAssertEqual(checkedInRows, expectedRows)
    }

    func testUnexpectedPolicyInputNilMapsInvariantWithoutPolicyCall() throws {
        let invalidInput = GiftUIResidualPolicyInput<FixturePolicyContext>(
            outcome: .success(()),
            context: .continueAfterNoChange,
            allowed: .continueOperation,
            attemptOrdinal: 0,
            attemptLimit: 1
        )
        XCTAssertNil(invalidInput)

        var policy = CountingInvalidPolicy(result: .continueOperation)
        var owner = FixtureOwnerAdapter()
        XCTAssertNil(
            owner.evaluate(
                input: invalidInput,
                policy: &policy,
                fatalHookConfigured: true
            ))

        try assertInvariantContainment(owner, expectedPolicyInvocations: 0)
        XCTAssertEqual(policy.invocationCount, 0)
    }

    func testUnlistedPolicyReturnMapsInvariantWithoutReinvocation() throws {
        let input = try XCTUnwrap(
            GiftUIResidualPolicyInput(
                outcome: GiftUIOutcome<Void>.failure(failureFact(containment: .contained)),
                context: FixturePolicyContext.markContainedFacilityUnavailable,
                allowed: GiftUIAllowedDispositions.markFacilityUnavailable,
                attemptOrdinal: 0,
                attemptLimit: 1
            ))
        var policy = CountingInvalidPolicy(result: .continueOperation)
        var owner = FixtureOwnerAdapter()

        XCTAssertNil(
            owner.evaluate(
                input: input,
                policy: &policy,
                fatalHookConfigured: true
            ))

        try assertInvariantContainment(owner, expectedPolicyInvocations: 1)
        XCTAssertEqual(policy.invocationCount, 1)
    }

    func testOwnerInvariantCorpusMatchesCheckedInRows() throws {
        let fixtureRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("ContractFixtures/SPEC003/SemanticCorpus/cases.tsv")
        let checkedInRows = try String(contentsOf: fixtureRoot, encoding: .utf8)
            .split(separator: "\n")
            .map(String.init)
            .filter { $0.contains("\towner-invariant\t") }

        XCTAssertEqual(
            checkedInRows,
            [
                "owner-invalid-nil\towner-invariant\t0\t10,11,4,1,3,0",
                "owner-unlisted-return\towner-invariant\t1\t10,11,4,1,3,1",
            ])
    }

    func testOperationalHealthStatesHaveExactRawValuesAndLayout() {
        XCTAssertEqual(GiftUIOperationalHealthState.available.rawValue, 0)
        XCTAssertEqual(GiftUIOperationalHealthState.degraded.rawValue, 1)
        XCTAssertEqual(GiftUIOperationalHealthState.unavailable.rawValue, 2)
        XCTAssertEqual(GiftUIOperationalHealthState.quiesced.rawValue, 3)
        XCTAssertLessThanOrEqual(MemoryLayout<GiftUIOperationalHealth>.size, 20)
        XCTAssertLessThanOrEqual(MemoryLayout<GiftUIOperationalHealth>.stride, 20)
        requireSendable(GiftUIOperationalHealthState.self)
        requireSendable(GiftUIOperationalHealth.self)
    }

    func testOperationalRecordExhaustsEveryResultingState() {
        for initialState in allHealthStates {
            for resultingState in allHealthStates {
                var health = GiftUIOperationalHealth(state: initialState)
                health.recordOperational(operationalFact, resultingState: resultingState)

                XCTAssertEqual(health.operationalCount, 1)
                XCTAssertEqual(health.failureCount, 0)
                XCTAssertFalse(health.countersSaturated)
                if initialState == .quiesced {
                    XCTAssertEqual(health.state, .quiesced)
                    XCTAssertEqual(health.transitionCount, 0)
                } else {
                    XCTAssertEqual(health.state, resultingState)
                    XCTAssertEqual(
                        health.transitionCount,
                        initialState == resultingState ? 0 : 1
                    )
                }
            }
        }
    }

    func testFailureRecordExhaustsEveryResultingState() {
        for initialState in allHealthStates {
            for resultingState in allHealthStates {
                var health = GiftUIOperationalHealth(state: initialState)
                health.recordFailure(
                    failureFact(containment: .contained),
                    resultingState: resultingState
                )

                XCTAssertEqual(health.operationalCount, 0)
                XCTAssertEqual(health.failureCount, 1)
                XCTAssertFalse(health.countersSaturated)
                if initialState == .quiesced {
                    XCTAssertEqual(health.state, .quiesced)
                    XCTAssertEqual(health.transitionCount, 0)
                } else {
                    XCTAssertEqual(health.state, resultingState)
                    XCTAssertEqual(
                        health.transitionCount,
                        initialState == resultingState ? 0 : 1
                    )
                }
            }
        }
    }

    func testHealthCountersSaturateWithoutBlockingStateUpdates() {
        var health = GiftUIOperationalHealth(
            state: .available,
            transitionCount: .max,
            operationalCount: .max,
            failureCount: .max,
            countersSaturated: false
        )

        health.recordOperational(operationalFact, resultingState: .degraded)
        XCTAssertEqual(health.state, .degraded)
        XCTAssertEqual(health.transitionCount, .max)
        XCTAssertEqual(health.operationalCount, .max)
        XCTAssertEqual(health.failureCount, .max)
        XCTAssertTrue(health.countersSaturated)

        health.recordFailure(
            failureFact(containment: .contained),
            resultingState: .unavailable
        )
        XCTAssertEqual(health.state, .unavailable)
        XCTAssertEqual(health.transitionCount, .max)
        XCTAssertEqual(health.operationalCount, .max)
        XCTAssertEqual(health.failureCount, .max)
        XCTAssertTrue(health.countersSaturated)
    }

    func testQuiescedHealthRemainsTerminalAfterCounterSaturation() {
        var health = GiftUIOperationalHealth(
            state: .quiesced,
            transitionCount: .max,
            operationalCount: .max,
            failureCount: .max,
            countersSaturated: true
        )

        for resultingState in allHealthStates {
            health.recordOperational(operationalFact, resultingState: resultingState)
            health.recordFailure(
                failureFact(containment: .safetyNotProven),
                resultingState: resultingState
            )
            XCTAssertEqual(health.state, .quiesced)
            XCTAssertEqual(health.transitionCount, .max)
            XCTAssertEqual(health.operationalCount, .max)
            XCTAssertEqual(health.failureCount, .max)
            XCTAssertTrue(health.countersSaturated)
        }
    }

    func testDiagnosticKindsSeveritiesAndSinkResultsHaveExactRawValues() {
        XCTAssertEqual(
            [
                GiftUIDiagnosticKind.operationalOutcome.rawValue,
                GiftUIDiagnosticKind.failureOutcome.rawValue,
                GiftUIDiagnosticKind.healthTransition.rawValue,
                GiftUIDiagnosticKind.residualDisposition.rawValue,
            ], [0, 1, 2, 3])
        XCTAssertEqual(
            [
                GiftUIDiagnosticSeverity.debug.rawValue,
                GiftUIDiagnosticSeverity.information.rawValue,
                GiftUIDiagnosticSeverity.notice.rawValue,
                GiftUIDiagnosticSeverity.warning.rawValue,
                GiftUIDiagnosticSeverity.error.rawValue,
                GiftUIDiagnosticSeverity.critical.rawValue,
            ], [0, 1, 2, 3, 4, 5])
        XCTAssertEqual(
            [
                GiftUIDiagnosticSinkResult.accepted.rawValue,
                GiftUIDiagnosticSinkResult.dropped.rawValue,
                GiftUIDiagnosticSinkResult.saturated.rawValue,
                GiftUIDiagnosticSinkResult.failed.rawValue,
            ], [0, 1, 2, 3])
    }

    func testDiagnosticSelectionExhaustsEveryKindOriginAndThreshold() {
        for kind in allDiagnosticKinds {
            for origin in allOrigins {
                for minimum in allDiagnosticSeverities {
                    let selection = GiftUIDiagnosticSelection(
                        kindMask: 1 << kind.rawValue,
                        originMask: 1 << origin.rawValue,
                        minimumSeverity: minimum
                    )
                    for candidateKind in allDiagnosticKinds {
                        for candidateOrigin in allOrigins {
                            for severity in allDiagnosticSeverities {
                                XCTAssertEqual(
                                    selection.includes(
                                        kind: candidateKind,
                                        origin: candidateOrigin,
                                        severity: severity
                                    ),
                                    candidateKind == kind
                                        && candidateOrigin == origin
                                        && severity.rawValue >= minimum.rawValue
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    func testZeroDiagnosticMasksSelectNothing() {
        for severity in allDiagnosticSeverities {
            let selection = GiftUIDiagnosticSelection(
                kindMask: 0,
                originMask: 0,
                minimumSeverity: severity
            )
            for kind in allDiagnosticKinds {
                for origin in allOrigins {
                    XCTAssertFalse(
                        selection.includes(
                            kind: kind,
                            origin: origin,
                            severity: .critical
                        ))
                }
            }
        }
    }

    func testDiagnosticRecordPreservesFieldsAndZerosReservedFlags() {
        let record = GiftUIDiagnosticRecord(
            kind: .failureOutcome,
            severity: .critical,
            flags: .max,
            origin: .transport,
            affectedScope: .runtime,
            condition: .max,
            correlation0: 1,
            correlation1: 2,
            observation0: 3,
            observation1: 4
        )

        XCTAssertEqual(record.kind, .failureOutcome)
        XCTAssertEqual(record.severity, .critical)
        XCTAssertEqual(record.flags, 0x000F)
        XCTAssertEqual(record.origin, .transport)
        XCTAssertEqual(record.affectedScope, .runtime)
        XCTAssertEqual(record.condition, .max)
        XCTAssertEqual(record.correlation0, 1)
        XCTAssertEqual(record.correlation1, 2)
        XCTAssertEqual(record.observation0, 3)
        XCTAssertEqual(record.observation1, 4)
        XCTAssertLessThanOrEqual(MemoryLayout<GiftUIDiagnosticRecord>.size, 24)
        XCTAssertLessThanOrEqual(MemoryLayout<GiftUIDiagnosticRecord>.stride, 24)
    }

    func testDiagnosticRecordDefaultsUnusedWordsToZero() {
        let record = GiftUIDiagnosticRecord(
            kind: .operationalOutcome,
            severity: .debug,
            flags: 0,
            origin: .foundation,
            affectedScope: .operation,
            condition: 0
        )

        XCTAssertEqual(record.correlation0, 0)
        XCTAssertEqual(record.correlation1, 0)
        XCTAssertEqual(record.observation0, 0)
        XCTAssertEqual(record.observation1, 0)
        requireSendable(GiftUIDiagnosticKind.self)
        requireSendable(GiftUIDiagnosticSeverity.self)
        requireSendable(GiftUIDiagnosticSelection.self)
        requireSendable(GiftUIDiagnosticRecord.self)
        requireSendable(GiftUIDiagnosticSinkResult.self)
    }

    private func assertInvariantContainment(
        _ owner: FixtureOwnerAdapter,
        expectedPolicyInvocations: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let fact = try XCTUnwrap(owner.propagatedFacts.first, file: file, line: line)
        XCTAssertEqual(owner.propagatedFacts.count, 1, file: file, line: line)
        XCTAssertEqual(fact.condition, .invariantViolation, file: file, line: line)
        XCTAssertEqual(fact.origin, .hostComposition, file: file, line: line)
        XCTAssertEqual(fact.affectedScope, .runtime, file: file, line: line)
        XCTAssertEqual(fact.containment, .safetyNotProven, file: file, line: line)
        XCTAssertEqual(owner.health, .quiesced, file: file, line: line)
        XCTAssertEqual(owner.healthTransitions, [.quiesced], file: file, line: line)
        XCTAssertEqual(owner.fatalHookObservedHealth, .quiesced, file: file, line: line)
        XCTAssertEqual(
            owner.policyInvocationCountAtContainment,
            expectedPolicyInvocations,
            file: file,
            line: line
        )

        var owner = owner
        for _ in 0 ..< 3 {
            XCTAssertFalse(owner.attemptNormalCycle(), file: file, line: line)
        }
        XCTAssertEqual(owner.admittedNormalCycles, 0, file: file, line: line)
    }

    private var allOrigins: [GiftUIFailureOrigin] {
        [
            .foundation,
            .capability,
            .semantic,
            .layout,
            .rendering,
            .execution,
            .observableState,
            .interaction,
            .backend,
            .presentationIntegration,
            .inputIntegration,
            .hostComposition,
            .displayDriver,
            .inputDriver,
            .transport,
        ]
    }

    private var allAffectedScopes: [GiftUIAffectedScope] {
        [.operation, .activeCycle, .candidateFrame, .component, .runtime]
    }

    private var allContainments: [GiftUIContainment] {
        [.contained, .safetyNotProven]
    }

    private var allOperationalKinds: [GiftUIOperationalKind] {
        [
            .noChange,
            .cacheMiss,
            .backpressured,
            .superseded,
            .deferredToLaterAdmission,
            .retryableRefusal,
        ]
    }

    private var allHealthStates: [GiftUIOperationalHealthState] {
        [.available, .degraded, .unavailable, .quiesced]
    }

    private var allDiagnosticKinds: [GiftUIDiagnosticKind] {
        [.operationalOutcome, .failureOutcome, .healthTransition, .residualDisposition]
    }

    private var allDiagnosticSeverities: [GiftUIDiagnosticSeverity] {
        [.debug, .information, .notice, .warning, .error, .critical]
    }

    private var operationalFact: GiftUIOperationalFact {
        GiftUIOperationalFact(
            kind: .noChange,
            origin: .hostComposition,
            affectedScope: .component
        )
    }

    private func failureFact(
        scope: GiftUIAffectedScope = .component,
        containment: GiftUIContainment
    ) -> GiftUIFailureFact {
        GiftUIFailureFact(
            condition: .invariantViolation,
            origin: .hostComposition,
            affectedScope: scope,
            containment: containment
        )
    }

    private func policyInput(
        outcome: GiftUIOutcome<Void>,
        allowed: GiftUIAllowedDispositions,
        ordinal: UInt8 = 0,
        limit: UInt8 = 2
    ) -> GiftUIResidualPolicyInput<UInt8>? {
        GiftUIResidualPolicyInput(
            outcome: outcome,
            context: 0,
            allowed: allowed,
            attemptOrdinal: ordinal,
            attemptLimit: limit
        )
    }

    private var fixturePolicyRows: [FixturePolicyRow] {
        [
            FixturePolicyRow(
                id: "policy-continue",
                context: .continueAfterNoChange,
                outcome: .operational(
                    GiftUIOperationalFact(
                        kind: .noChange,
                        origin: .semantic,
                        affectedScope: .operation
                    )),
                allowed: [.continueOperation, .quiesceAffectedScope],
                attemptOrdinal: 0,
                attemptLimit: 1,
                expected: .continueOperation,
                corpusInput: "0,1,0,2,0,0,0x09,0,1"
            ),
            FixturePolicyRow(
                id: "policy-retry",
                context: .retryBackpressure,
                outcome: .operational(
                    GiftUIOperationalFact(
                        kind: .backpressured,
                        origin: .inputIntegration,
                        affectedScope: .operation
                    )),
                allowed: [.requestPacedRetry, .markFacilityUnavailable],
                attemptOrdinal: 0,
                attemptLimit: 3,
                expected: .requestPacedRetry,
                corpusInput: "1,1,2,10,0,0,0x06,0,3"
            ),
            FixturePolicyRow(
                id: "policy-unavailable",
                context: .markContainedFacilityUnavailable,
                outcome: .failure(
                    GiftUIFailureFact(
                        condition: .requiredFacilityUnavailable,
                        origin: .hostComposition,
                        affectedScope: .component,
                        containment: .contained
                    )),
                allowed: [.markFacilityUnavailable, .quiesceAffectedScope],
                attemptOrdinal: 0,
                attemptLimit: 1,
                expected: .markFacilityUnavailable,
                corpusInput: "2,2,8,11,3,0,0x0c,0,1"
            ),
            FixturePolicyRow(
                id: "policy-quiesce",
                context: .quiesceContainedComponent,
                outcome: .failure(
                    failureFact(
                        scope: .component,
                        containment: .contained
                    )),
                allowed: [.quiesceAffectedScope, .invokeFatalHook],
                attemptOrdinal: 0,
                attemptLimit: 1,
                expected: .quiesceAffectedScope,
                corpusInput: "3,2,10,11,3,0,0x18,0,1"
            ),
            FixturePolicyRow(
                id: "policy-fatal",
                context: .invokeFatalAfterContainedComponent,
                outcome: .failure(
                    failureFact(
                        scope: .component,
                        containment: .contained
                    )),
                allowed: [.quiesceAffectedScope, .invokeFatalHook],
                attemptOrdinal: 0,
                attemptLimit: 1,
                expected: .invokeFatalHook,
                corpusInput: "4,2,10,11,3,0,0x18,0,1"
            ),
        ]
    }

    private func option(
        for disposition: GiftUIResidualDisposition
    ) -> GiftUIAllowedDispositions {
        GiftUIAllowedDispositions(rawValue: 1 << disposition.rawValue)
    }

    private func requireSendable<T: Sendable>(_: T.Type) {
    }

    private func requireEquatable<T: Equatable>(_: T.Type) {
    }
}

private enum FixturePolicyContext: UInt8, CaseIterable {
    case continueAfterNoChange = 0
    case retryBackpressure = 1
    case markContainedFacilityUnavailable = 2
    case quiesceContainedComponent = 3
    case invokeFatalAfterContainedComponent = 4
}

private struct FixturePolicyRow {
    let id: String
    let context: FixturePolicyContext
    let outcome: GiftUIOutcome<Void>
    let allowed: GiftUIAllowedDispositions
    let attemptOrdinal: UInt8
    let attemptLimit: UInt8
    let expected: GiftUIResidualDisposition
    let corpusInput: String

    var corpusRow: String {
        "\(id)\tresidual-policy\t\(corpusInput)\t\(expected.rawValue)"
    }
}

private struct FixturePolicy: GiftUIResidualFailurePolicy {
    private(set) var invocationCount = 0

    mutating func disposition(
        for input: GiftUIResidualPolicyInput<FixturePolicyContext>
    ) -> GiftUIResidualDisposition {
        invocationCount += 1
        switch input.context {
        case .continueAfterNoChange:
            return .continueOperation
        case .retryBackpressure:
            return .requestPacedRetry
        case .markContainedFacilityUnavailable:
            return .markFacilityUnavailable
        case .quiesceContainedComponent:
            return .quiesceAffectedScope
        case .invokeFatalAfterContainedComponent:
            return .invokeFatalHook
        }
    }
}

private enum FixtureRuntimeHealth: UInt8 {
    case available = 0
    case quiesced = 3
}

private struct CountingInvalidPolicy: GiftUIResidualFailurePolicy {
    let result: GiftUIResidualDisposition
    private(set) var invocationCount = 0

    mutating func disposition(
        for input: GiftUIResidualPolicyInput<FixturePolicyContext>
    ) -> GiftUIResidualDisposition {
        invocationCount += 1
        return result
    }
}

private struct FixtureOwnerAdapter {
    private(set) var health = FixtureRuntimeHealth.available
    private(set) var healthTransitions: [FixtureRuntimeHealth] = []
    private(set) var propagatedFacts: [GiftUIFailureFact] = []
    private(set) var fatalHookObservedHealth: FixtureRuntimeHealth?
    private(set) var admittedNormalCycles = 0
    private(set) var policyInvocationCountAtContainment = 0

    mutating func evaluate<Policy: GiftUIResidualFailurePolicy>(
        input: GiftUIResidualPolicyInput<Policy.Context>?,
        policy: inout Policy,
        fatalHookConfigured: Bool
    ) -> GiftUIResidualDisposition? {
        guard let input else {
            containInvariant(
                policyInvocationCount: 0,
                fatalHookConfigured: fatalHookConfigured
            )
            return nil
        }

        let result = policy.disposition(for: input)
        let option = GiftUIAllowedDispositions(rawValue: 1 << result.rawValue)
        guard input.allowed.contains(option) else {
            containInvariant(
                policyInvocationCount: 1,
                fatalHookConfigured: fatalHookConfigured
            )
            return nil
        }
        return result
    }

    mutating func attemptNormalCycle() -> Bool {
        guard health != .quiesced else {
            return false
        }
        admittedNormalCycles += 1
        return true
    }

    private mutating func containInvariant(
        policyInvocationCount: Int,
        fatalHookConfigured: Bool
    ) {
        health = .quiesced
        healthTransitions.append(.quiesced)
        policyInvocationCountAtContainment = policyInvocationCount
        propagatedFacts.append(
            GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .hostComposition,
                affectedScope: .runtime,
                containment: .safetyNotProven
            ))
        if fatalHookConfigured {
            fatalHookObservedHealth = health
        }
    }
}
