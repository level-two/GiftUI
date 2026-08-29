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

    private func requireSendable<T: Sendable>(_: T.Type) {
    }
}
