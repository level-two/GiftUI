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
