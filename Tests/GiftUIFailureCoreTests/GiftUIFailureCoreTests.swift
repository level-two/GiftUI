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
        let operational = GiftUIOutcome<UInt32>.operational(GiftUIOperationalFact(
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

        guard case let .success(value) = success else {
            return XCTFail("expected success")
        }
        XCTAssertEqual(value, 42)

        guard case let .operational(fact) = operational else {
            return XCTFail("expected operational")
        }
        XCTAssertEqual(fact.kind, .noChange)

        guard case let .failure(fact) = failure else {
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
        let input = try XCTUnwrap(GiftUIResidualPolicyInput(
            outcome: outcome,
            context: UInt8(7),
            allowed: allowed,
            attemptOrdinal: 1,
            attemptLimit: 3
        ))

        guard case let .operational(preservedFact) = input.outcome else {
            return XCTFail("expected preserved operational outcome")
        }
        XCTAssertEqual(preservedFact, fact)
        XCTAssertEqual(input.context, 7)
        XCTAssertEqual(input.allowed, allowed)
        XCTAssertEqual(input.attemptOrdinal, 1)
        XCTAssertEqual(input.attemptLimit, 3)
    }

    func testResidualInputRejectsSuccessEmptyAndUnknownBits() {
        let operational = GiftUIOutcome<Void>.operational(GiftUIOperationalFact(
            kind: .noChange,
            origin: .semantic,
            affectedScope: .operation
        ))

        XCTAssertNil(policyInput(outcome: .success(()), allowed: .continueOperation))
        XCTAssertNil(policyInput(outcome: operational, allowed: []))
        for rawValue in UInt8(32) ... UInt8.max {
            XCTAssertNil(policyInput(
                outcome: operational,
                allowed: GiftUIAllowedDispositions(rawValue: rawValue)
            ))
        }
    }

    func testResidualInputRejectsEveryInvalidAttemptRange() {
        let outcome = GiftUIOutcome<Void>.operational(GiftUIOperationalFact(
            kind: .noChange,
            origin: .semantic,
            affectedScope: .operation
        ))

        for ordinal in UInt8.min ... UInt8.max {
            XCTAssertNil(policyInput(
                outcome: outcome,
                allowed: .continueOperation,
                ordinal: ordinal,
                limit: 0
            ))
        }
        for limit in UInt8(1) ... UInt8.max {
            for ordinal in limit ... UInt8.max {
                XCTAssertNil(policyInput(
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
                    let outcome = GiftUIOutcome<Void>.operational(GiftUIOperationalFact(
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

        XCTAssertNil(policyInput(
            outcome: .failure(failureFact(containment: .contained)),
            allowed: .requestPacedRetry
        ))
    }

    func testSafetyNotProvenRejectsContinuation() {
        for scope in allAffectedScopes {
            XCTAssertNil(policyInput(
                outcome: .failure(failureFact(scope: scope, containment: .safetyNotProven)),
                allowed: [.continueOperation, .quiesceAffectedScope]
            ))
        }
    }

    func testRuntimeSafetyNotProvenAllowsOnlyTerminalChoices() {
        let outcome = GiftUIOutcome<Void>.failure(failureFact(
            scope: .runtime,
            containment: .safetyNotProven
        ))

        XCTAssertNotNil(policyInput(outcome: outcome, allowed: .quiesceAffectedScope))
        XCTAssertNotNil(policyInput(outcome: outcome, allowed: .invokeFatalHook))
        XCTAssertNotNil(policyInput(
            outcome: outcome,
            allowed: [.quiesceAffectedScope, .invokeFatalHook]
        ))
        XCTAssertNil(policyInput(outcome: outcome, allowed: .markFacilityUnavailable))
        XCTAssertNil(policyInput(
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

    private func requireSendable<T: Sendable>(_: T.Type) {
    }

    private func requireEquatable<T: Equatable>(_: T.Type) {
    }
}
