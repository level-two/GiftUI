import XCTest

@testable import GiftUI

final class ObservableStateDeclarationsTests: XCTestCase {
    func testChangeReportOutcomesUseTheirExactUInt8Codes() {
        XCTAssertEqual(_GiftUIObservableChangeReportOutcome.dirtied.rawValue, 0)
        XCTAssertEqual(_GiftUIObservableChangeReportOutcome.coalesced.rawValue, 1)
        XCTAssertEqual(_GiftUIObservableChangeReportOutcome.staleAttachment.rawValue, 2)
        XCTAssertEqual(_GiftUIObservableChangeReportOutcome.invalidPhaseContained.rawValue, 3)
        XCTAssertEqual(
            _GiftUIObservableChangeReportOutcome.invalidPhaseSafetyNotProven.rawValue,
            4
        )
        XCTAssertEqual(_GiftUIObservableChangeReportOutcome.reentrancyViolation.rawValue, 5)
        XCTAssertEqual(_GiftUIObservableChangeReportOutcome.invariantViolation.rawValue, 6)
    }

    func testObservationAttachmentAndNoncopyableReportSinkKeepExactIdentity() {
        let attachment = _GiftUIObservationAttachment(slot: 17, generation: 41)
        var sink = _GiftUIObservableChangeSink(
            attachment: attachment,
            context: UnsafeMutableRawPointer(bitPattern: 1)!,
            reportRoute: reportDirtied
        )

        XCTAssertEqual(sink.attachment, attachment)
        XCTAssertEqual(sink.reportChange(), .dirtied)
    }

    func testStateUsesTheApprovedTypedSeedInitializer() {
        let state = State<FixtureModelSchema>(seed: 7)

        XCTAssertNotNil(state._giftUIInitial)
        XCTAssertNil(state.wrappedValue)
    }
}

private enum FixtureModelSchema: _GiftUIModelSchema {
    typealias Seed = Int
}

private func reportDirtied(
    _: UnsafeMutableRawPointer,
    _: UInt16,
    _: UInt32
) -> UInt8 {
    _GiftUIObservableChangeReportOutcome.dirtied.rawValue
}
