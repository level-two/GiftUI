import GiftUIFailureCore
@testable import GiftUIFailureDiagnostics
import XCTest

final class GiftUIFailureDiagnosticsTests: XCTestCase {
    func testDefaultDeveloperCapacityIsMacOSDynamicDefault() {
        XCTAssertEqual(GiftUIFixedDiagnosticBuffer.capacity, expectedCapacity)
    }

    func testAdmittedRecordsRemainInOrderAndFullBufferDropsNewRecord() {
        var buffer = GiftUIFixedDiagnosticBuffer()
        let records = (0 ... GiftUIFixedDiagnosticBuffer.capacity).map(record)

        for index in UInt8(0) ..< GiftUIFixedDiagnosticBuffer.capacity {
            XCTAssertEqual(buffer.consume(records[Int(index)]), .accepted)
        }
        let beforeDrop = (0 ..< GiftUIFixedDiagnosticBuffer.capacity).map { buffer[$0] }

        XCTAssertEqual(buffer.consume(records.last!), .saturated)
        XCTAssertEqual(buffer.count, GiftUIFixedDiagnosticBuffer.capacity)
        XCTAssertEqual(buffer.droppedRecordCount, 1)
        XCTAssertEqual(
            (0 ..< GiftUIFixedDiagnosticBuffer.capacity).map { buffer[$0] },
            beforeDrop
        )
        XCTAssertNil(buffer[GiftUIFixedDiagnosticBuffer.capacity])
        XCTAssertNil(buffer[.max])
    }

    func testDroppedRecordCounterSaturates() {
        var buffer = GiftUIFixedDiagnosticBuffer(droppedRecordCount: .max - 1)
        for index in UInt8(0) ..< GiftUIFixedDiagnosticBuffer.capacity {
            XCTAssertEqual(buffer.consume(record(index)), .accepted)
        }

        XCTAssertEqual(buffer.consume(record(250)), .saturated)
        XCTAssertEqual(buffer.droppedRecordCount, .max)
        XCTAssertEqual(buffer.consume(record(251)), .saturated)
        XCTAssertEqual(buffer.droppedRecordCount, .max)
    }

    func testDiagnosticConfigurationMatrixPreservesEveryCorrectnessValue() throws {
        let baseline = try correctnessSnapshot()
        let selected = GiftUIDiagnosticSelection(
            kindMask: 1 << GiftUIDiagnosticKind.failureOutcome.rawValue,
            originMask: 1 << GiftUIFailureOrigin.backend.rawValue,
            minimumSeverity: .warning
        )

        var enabled = GiftUIDiagnosticProjector(
            selection: selected,
            sink: ResultSink(result: .accepted)
        )
        let enabledConstruction = ConstructionCounter()
        enabled.projectFailure(counter: enabledConstruction)
        XCTAssertEqual(enabledConstruction.value, 1)
        XCTAssertEqual(enabled.sink.consumed, 1)
        XCTAssertEqual(enabled.counters.accepted, 1)
        XCTAssertEqual(try correctnessSnapshot(), baseline)

        var sourceFiltered = GiftUIDiagnosticProjector(
            selection: GiftUIDiagnosticSelection(
                kindMask: 0,
                originMask: .max,
                minimumSeverity: .debug
            ),
            sink: ResultSink(result: .accepted)
        )
        let sourceFilteredConstruction = ConstructionCounter()
        sourceFiltered.projectFailure(counter: sourceFilteredConstruction)
        XCTAssertEqual(sourceFilteredConstruction.value, 0)
        XCTAssertEqual(sourceFiltered.sink.consumed, 0)
        XCTAssertEqual(sourceFiltered.counters, .init())
        XCTAssertEqual(try correctnessSnapshot(), baseline)

        var sinkFiltered = GiftUIDiagnosticProjector(
            selection: selected,
            sink: FilteringSink(rejectedCondition: GiftUIConditionID.invariantViolation.rawValue)
        )
        let sinkFilteredConstruction = ConstructionCounter()
        sinkFiltered.projectFailure(counter: sinkFilteredConstruction)
        XCTAssertEqual(sinkFilteredConstruction.value, 1)
        XCTAssertEqual(sinkFiltered.sink.consumed, 1)
        XCTAssertEqual(sinkFiltered.counters.dropped, 1)
        XCTAssertEqual(try correctnessSnapshot(), baseline)

        for result in [
            GiftUIDiagnosticSinkResult.dropped,
            .failed,
        ] {
            var projector = GiftUIDiagnosticProjector(
                selection: selected,
                sink: ResultSink(result: result)
            )
            let construction = ConstructionCounter()
            projector.projectFailure(counter: construction)
            XCTAssertEqual(construction.value, 1)
            XCTAssertEqual(projector.sink.consumed, 1)
            XCTAssertEqual(projector.counters.dropped, result == .dropped ? 1 : 0)
            XCTAssertEqual(projector.counters.failed, result == .failed ? 1 : 0)
            XCTAssertEqual(try correctnessSnapshot(), baseline)
        }

        var counted = GiftUIDiagnosticProjector(
            selection: selected,
            sink: ResultSink(result: .accepted)
        )
        let countedConstruction = ConstructionCounter()
        for _ in 0 ..< 3 {
            counted.projectFailure(counter: countedConstruction)
        }
        XCTAssertEqual(countedConstruction.value, 3)
        XCTAssertEqual(counted.sink.consumed, 3)
        XCTAssertEqual(counted.counters.accepted, 3)
        XCTAssertEqual(try correctnessSnapshot(), baseline)

        var saturated = GiftUIDiagnosticProjector(
            selection: selected,
            sink: GiftUIFixedDiagnosticBuffer()
        )
        let saturatedConstruction = ConstructionCounter()
        for _ in UInt8(0) ... GiftUIFixedDiagnosticBuffer.capacity {
            saturated.projectFailure(counter: saturatedConstruction)
        }
        XCTAssertEqual(
            saturatedConstruction.value,
            UInt32(GiftUIFixedDiagnosticBuffer.capacity) + 1
        )
        XCTAssertEqual(saturated.sink.count, GiftUIFixedDiagnosticBuffer.capacity)
        XCTAssertEqual(saturated.sink.droppedRecordCount, 1)
        XCTAssertEqual(saturated.counters.saturated, 1)
        XCTAssertEqual(try correctnessSnapshot(), baseline)
    }

    func testDeliveryCountersSaturateWithoutAffectingFurtherResults() {
        var counters = GiftUIDiagnosticDeliveryCounters(
            accepted: .max,
            dropped: .max,
            saturated: .max,
            failed: .max
        )
        counters.record(.accepted)
        counters.record(.dropped)
        counters.record(.saturated)
        counters.record(.failed)

        XCTAssertEqual(counters.accepted, .max)
        XCTAssertEqual(counters.dropped, .max)
        XCTAssertEqual(counters.saturated, .max)
        XCTAssertEqual(counters.failed, .max)
        XCTAssertTrue(counters.countersSaturated)
    }

    private func record(_ index: UInt8) -> GiftUIDiagnosticRecord {
        GiftUIDiagnosticRecord(
            kind: .failureOutcome,
            severity: .error,
            flags: 1,
            origin: .backend,
            affectedScope: .candidateFrame,
            condition: UInt16(index),
            correlation0: UInt32(index)
        )
    }

    private func correctnessSnapshot() throws -> CorrectnessSnapshot {
        let fact = GiftUIFailureFact(
            condition: .invariantViolation,
            origin: .hostComposition,
            affectedScope: .runtime,
            containment: .safetyNotProven
        )
        let outcome = GiftUIOutcome<UInt8>.failure(fact)
        var health = GiftUIOperationalHealth()
        health.recordFailure(fact, resultingState: .quiesced)
        let residualOutcome = GiftUIOutcome<Void>.failure(GiftUIFailureFact(
            condition: .capacityExhausted,
            origin: .backend,
            affectedScope: .component,
            containment: .contained
        ))
        let input = try XCTUnwrap(GiftUIResidualPolicyInput(
            outcome: residualOutcome,
            context: UInt8(7),
            allowed: [.markFacilityUnavailable, .quiesceAffectedScope],
            attemptOrdinal: 0,
            attemptLimit: 1
        ))

        guard case let .failure(residualFailure) = input.outcome else {
            throw SnapshotError.unexpectedResidualOutcome
        }

        return CorrectnessSnapshot(
            outcome: outcome,
            health: health,
            coordinatorFact: fact,
            residualFailure: residualFailure,
            residualContext: input.context,
            residualAllowed: input.allowed,
            residualAttemptOrdinal: input.attemptOrdinal,
            residualAttemptLimit: input.attemptLimit,
            policyResult: .quiesceAffectedScope
        )
    }

    private var expectedCapacity: UInt8 {
        #if GIFTUI_DIAGNOSTICS_CAPACITY_ZERO
        0
        #elseif GIFTUI_DIAGNOSTICS_CAPACITY_8
        8
        #elseif GIFTUI_DIAGNOSTICS_CAPACITY_16
        16
        #else
        64
        #endif
    }
}

private struct CorrectnessSnapshot: Equatable {
    let outcome: GiftUIOutcome<UInt8>
    let health: GiftUIOperationalHealth
    let coordinatorFact: GiftUIFailureFact
    let residualFailure: GiftUIFailureFact
    let residualContext: UInt8
    let residualAllowed: GiftUIAllowedDispositions
    let residualAttemptOrdinal: UInt8
    let residualAttemptLimit: UInt8
    let policyResult: GiftUIResidualDisposition
}

private enum SnapshotError: Error {
    case unexpectedResidualOutcome
}

private struct ResultSink: GiftUIDiagnosticSink {
    let result: GiftUIDiagnosticSinkResult
    private(set) var consumed: UInt32 = 0

    mutating func consume(_ record: GiftUIDiagnosticRecord) -> GiftUIDiagnosticSinkResult {
        _ = record
        consumed += 1
        return result
    }
}

private struct FilteringSink: GiftUIDiagnosticSink {
    let rejectedCondition: UInt16
    private(set) var consumed: UInt32 = 0

    mutating func consume(_ record: GiftUIDiagnosticRecord) -> GiftUIDiagnosticSinkResult {
        consumed += 1
        return record.condition == rejectedCondition ? .dropped : .accepted
    }
}

private final class ConstructionCounter {
    var value: UInt32 = 0
}

private extension GiftUIDiagnosticProjector {
    mutating func projectFailure(counter: ConstructionCounter) {
        project(
            kind: .failureOutcome,
            origin: .backend,
            severity: .error
        ) {
            counter.value += 1
            return GiftUIDiagnosticRecord(
                kind: .failureOutcome,
                severity: .error,
                flags: 1,
                origin: .backend,
                affectedScope: .component,
                condition: GiftUIConditionID.invariantViolation.rawValue
            )
        }
    }
}
