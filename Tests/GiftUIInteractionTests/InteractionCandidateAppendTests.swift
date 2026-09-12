import GiftUI
import GiftUIExecution
import XCTest

@testable import GiftUIInteraction

final class InteractionCandidateAppendTests: XCTestCase {
    func testGenerationAssignmentAndFinishAreExactlyOnceAndPhaseBound() {
        var state = makeState(capacity: 2)
        XCTAssertEqual(
            state.assignGeneration(ActionGeneration(rawValue: 1), to: 1),
            .invalidPhase
        )
        XCTAssertNil(
            state.beginCandidate(
                limits: InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!
            )
        )
        XCTAssertEqual(append(&state, identity: 1, paintOrder: 0), .requiresGeneration)
        XCTAssertNil(state.assignGeneration(ActionGeneration(rawValue: 8), to: 1))
        XCTAssertEqual(
            state.assignGeneration(ActionGeneration(rawValue: 9), to: 1),
            .invariantViolation
        )
        XCTAssertEqual(state.finishCandidate(), .invariantViolation)

        var unresolved = makeState(capacity: 1)
        XCTAssertNil(
            unresolved.beginCandidate(
                limits: InteractionLimits(maximumActions: 1, maximumHitRegions: 1)!
            )
        )
        XCTAssertEqual(append(&unresolved, identity: 1, paintOrder: 0), .requiresGeneration)
        XCTAssertEqual(unresolved.finishCandidate(), .invalidIdentity)

        var ready = makeState(capacity: 1)
        XCTAssertNil(
            ready.beginCandidate(
                limits: InteractionLimits(maximumActions: 1, maximumHitRegions: 1)!
            )
        )
        XCTAssertEqual(append(&ready, identity: 1, paintOrder: 0), .requiresGeneration)
        XCTAssertNil(ready.assignGeneration(ActionGeneration(rawValue: 8), to: 1))
        XCTAssertNil(ready.finishCandidate())
        XCTAssertEqual(ready.finishCandidate(), .invalidPhase)
        XCTAssertEqual(append(&ready, identity: 2, paintOrder: 1), .failure(.invalidPhase))
    }

    func testFirstCandidateErrorWinsUntilDiscard() {
        var state = makeState(capacity: 2)
        XCTAssertNil(
            state.beginCandidate(
                limits: InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!
            )
        )
        XCTAssertEqual(append(&state, identity: 1, paintOrder: 1), .failure(.invalidGeometry))
        XCTAssertEqual(append(&state, identity: 1, paintOrder: 0), .failure(.invalidGeometry))
        XCTAssertEqual(state.finishCandidate(), .invalidGeometry)
    }

    func testOnlyAnExactlyEqualCommittedRecordPreservesGeneration() {
        let committed = BoundActionRecord(
            identity: UInt16(7),
            generation: ActionGeneration(rawValue: 41),
            isEnabled: true,
            hitBounds: rect(x: 0, y: 0, width: 2, height: 2),
            paintOrder: 0,
            action: BoundedApplicationAction(code: 5),
            targetGeneration: ObservableTargetGeneration(rawValue: 9)
        )
        var equal = makeState(capacity: 2, committed: committed)
        XCTAssertNil(
            equal.beginCandidate(
                limits: InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!))
        XCTAssertEqual(
            appendRecord(&equal, identity: 7, isEnabled: true, action: 5, target: 9),
            .preserved
        )

        var changedAction = makeState(capacity: 2, committed: committed)
        XCTAssertNil(
            changedAction.beginCandidate(
                limits: InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!))
        XCTAssertEqual(
            appendRecord(&changedAction, identity: 7, isEnabled: true, action: 6, target: 9),
            .requiresGeneration
        )

        var changedTarget = makeState(capacity: 2, committed: committed)
        XCTAssertNil(
            changedTarget.beginCandidate(
                limits: InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!))
        XCTAssertEqual(
            appendRecord(&changedTarget, identity: 7, isEnabled: true, action: 5, target: 10),
            .requiresGeneration
        )

        var disabled = makeState(capacity: 2, committed: committed)
        XCTAssertNil(
            disabled.beginCandidate(
                limits: InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!))
        XCTAssertEqual(
            appendRecord(&disabled, identity: 7, isEnabled: false, action: 5, target: 9),
            .requiresGeneration
        )
    }

    func testAppendUsesExactClipAndRetainsEmptyIntersectionWithoutHit() {
        var state = makeState(capacity: 2)
        XCTAssertNil(
            state.beginCandidate(
                limits: InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!))

        XCTAssertEqual(
            state.append(
                identity: 1,
                isEnabled: true,
                bounds: rect(x: 0, y: 0, width: 10, height: 10),
                clip: rect(x: 5, y: 5, width: 10, height: 10),
                paintOrder: 0,
                action: BoundedApplicationAction(code: 1),
                targetGeneration: ObservableTargetGeneration(rawValue: 1)
            ),
            .requiresGeneration
        )
        XCTAssertEqual(
            state.append(
                identity: 2,
                isEnabled: true,
                bounds: rect(x: 20, y: 20, width: 2, height: 2),
                clip: rect(x: 0, y: 0, width: 2, height: 2),
                paintOrder: 1,
                action: BoundedApplicationAction(code: 2),
                targetGeneration: ObservableTargetGeneration(rawValue: 1)
            ),
            .requiresGeneration
        )
    }

    func testDuplicatePaintOrderAndFirstExcessFailDeterministically() {
        var duplicate = makeState(capacity: 2)
        let limits = InteractionLimits(maximumActions: 1, maximumHitRegions: 1)!
        XCTAssertNil(duplicate.beginCandidate(limits: limits))
        XCTAssertEqual(append(&duplicate, identity: 1, paintOrder: 0), .requiresGeneration)
        XCTAssertEqual(append(&duplicate, identity: 1, paintOrder: 1), .failure(.invalidIdentity))

        var excess = makeState(capacity: 2)
        XCTAssertNil(excess.beginCandidate(limits: limits))
        XCTAssertEqual(append(&excess, identity: 1, paintOrder: 0), .requiresGeneration)
        XCTAssertEqual(append(&excess, identity: 2, paintOrder: 1), .failure(.capacityExhausted))

        var order = makeState(capacity: 2)
        XCTAssertNil(
            order.beginCandidate(
                limits: InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!))
        XCTAssertEqual(append(&order, identity: 1, paintOrder: 1), .failure(.invalidGeometry))
    }
}

private func makeState(
    capacity: UInt16,
    committed: BoundActionRecord<UInt16>? = nil
) -> InteractionState<
    ArrayCandidateStorage, ArrayCommittedStorage, ArrayHitStorage
> {
    InteractionState(
        candidateRecords: ArrayCandidateStorage(capacity: capacity),
        candidateHitRegions: ArrayHitStorage(capacity: capacity),
        committedRecords: ArrayCommittedStorage(
            capacity: capacity,
            values: committed.map { [$0] } ?? []
        ),
        committedHitRegions: ArrayHitStorage(capacity: capacity)
    )
}

private func appendRecord(
    _ state:
        inout InteractionState<
            ArrayCandidateStorage, ArrayCommittedStorage, ArrayHitStorage
        >,
    identity: UInt16,
    isEnabled: Bool,
    action: UInt16,
    target: UInt32
) -> InteractionCandidateAppendResult {
    state.append(
        identity: identity,
        isEnabled: isEnabled,
        bounds: rect(x: 0, y: 0, width: 2, height: 2),
        clip: rect(x: 0, y: 0, width: 2, height: 2),
        paintOrder: 0,
        action: BoundedApplicationAction(code: action),
        targetGeneration: ObservableTargetGeneration(rawValue: target)
    )
}

private func append(
    _ state: inout InteractionState<ArrayCandidateStorage, ArrayCommittedStorage, ArrayHitStorage>,
    identity: UInt16,
    paintOrder: UInt16
) -> InteractionCandidateAppendResult {
    state.append(
        identity: identity,
        isEnabled: true,
        bounds: rect(x: 0, y: 0, width: 2, height: 2),
        clip: rect(x: 0, y: 0, width: 2, height: 2),
        paintOrder: paintOrder,
        action: BoundedApplicationAction(code: identity),
        targetGeneration: ObservableTargetGeneration(rawValue: 1)
    )
}

private func rect(x: Int32, y: Int32, width: Int32, height: Int32) -> Rect {
    Rect(origin: Point(x: x, y: y), size: Size(width: width, height: height)!)!
}

private struct ArrayCandidateStorage: InteractionCandidateRecordStorage {
    let capacity: UInt16
    var values: [InteractionCandidateRecord<UInt16>] = []
    var count: UInt16 { UInt16(values.count) }
    mutating func reset() { values.removeAll(keepingCapacity: true) }
    func record(at index: UInt16) -> InteractionCandidateRecord<UInt16>? {
        values.indices.contains(Int(index)) ? values[Int(index)] : nil
    }
    mutating func append(_ record: consuming InteractionCandidateRecord<UInt16>) -> Bool {
        guard count < capacity else { return false }
        values.append(record)
        return true
    }
    mutating func replace(
        at index: UInt16, with record: consuming InteractionCandidateRecord<UInt16>
    ) -> Bool {
        guard values.indices.contains(Int(index)) else { return false }
        values[Int(index)] = record
        return true
    }
}

private struct ArrayCommittedStorage: InteractionCommittedRecordStorage {
    let capacity: UInt16
    var values: [BoundActionRecord<UInt16>] = []
    var count: UInt16 { UInt16(values.count) }
    mutating func reset() { values.removeAll(keepingCapacity: true) }
    func record(at index: UInt16) -> BoundActionRecord<UInt16>? {
        values.indices.contains(Int(index)) ? values[Int(index)] : nil
    }
    mutating func append(_ record: consuming BoundActionRecord<UInt16>) -> Bool {
        guard count < capacity else { return false }
        values.append(record)
        return true
    }
}

private struct ArrayHitStorage: InteractionHitRegionStorage {
    let capacity: UInt16
    var values: [InteractionHitRegion<UInt16>] = []
    var count: UInt16 { UInt16(values.count) }
    mutating func reset() { values.removeAll(keepingCapacity: true) }
    func region(at index: UInt16) -> InteractionHitRegion<UInt16>? {
        values.indices.contains(Int(index)) ? values[Int(index)] : nil
    }
    mutating func append(_ region: consuming InteractionHitRegion<UInt16>) -> Bool {
        guard count < capacity else { return false }
        values.append(region)
        return true
    }
}
