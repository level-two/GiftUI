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

    func testAttachmentPreservesItsCompleteIdentity() {
        let attachment = _GiftUIObservationAttachment(slot: 17, generation: 41)

        XCTAssertEqual(attachment.slot, 17)
        XCTAssertEqual(attachment.generation, 41)
    }

    func testSinkReportsItsExactAttachmentThroughTheFixedRoute() {
        let attachment = _GiftUIObservationAttachment(slot: 3, generation: 5)
        var reportedAttachment: _GiftUIObservationAttachment?
        var sink = _GiftUIObservableChangeSink(attachment: attachment) { reported in
            reportedAttachment = reported
            return .dirtied
        }

        XCTAssertEqual(sink.attachment, attachment)
        XCTAssertEqual(sink.reportChange(), .dirtied)
        XCTAssertEqual(reportedAttachment, attachment)
    }

    func testBindingConsumesTheInitializerAndRoutesAccess() {
        let initial = TestObservableModel(value: 7)
        let live = TestObservableModel(value: 11)
        var replacement: TestObservableModel?
        var state = State(wrappedValue: initial)

        let consumedInitial = state._giftUIBind(
            read: { live },
            replace: { replacement = $0 }
        )
        state.wrappedValue = TestObservableModel(value: 13)

        XCTAssertTrue(consumedInitial === initial)
        XCTAssertTrue(state.wrappedValue === live)
        XCTAssertEqual(replacement?.value, 13)
        XCTAssertNil(state._giftUIBind(read: { live }, replace: { _ in }))
    }
}

private final class TestObservableModel: _GiftUIObservableReference {
    let value: Int

    init(value: Int) {
        self.value = value
    }

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}
