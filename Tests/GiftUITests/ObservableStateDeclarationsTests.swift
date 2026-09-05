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

    func testPreservedBindingReleasesTheRepeatedInitializer() {
        var repeated: TestObservableModel? = TestObservableModel(value: 7)
        weak let released = repeated
        let live = TestObservableModel(value: 11)
        var state = State(wrappedValue: repeated!)

        var consumedInitial = state._giftUIBind(
            read: { live },
            replace: { _ in }
        )
        XCTAssertTrue(consumedInitial === repeated)
        repeated = nil
        XCTAssertNotNil(released)

        consumedInitial = nil

        XCTAssertNil(released)
        XCTAssertTrue(state.wrappedValue === live)
    }

    func testSetterRoutePreservesTheFirstFailureUntilCoordinatorConsumption() {
        let initial = TestObservableModel(value: 1)
        let live = TestObservableModel(value: 2)
        var slot = TestMutationResultSlot()
        var nextResult = TestMutationResult.failure(.replacementRejected)
        var state = State(wrappedValue: initial)
        _ = state._giftUIBind(
            read: { live },
            replace: { _ in
                slot.record(nextResult)
            }
        )

        state.wrappedValue = TestObservableModel(value: 3)
        nextResult = .success
        state.wrappedValue = TestObservableModel(value: 4)

        XCTAssertEqual(slot.consume(), .failure(.replacementRejected))
        XCTAssertNil(slot.consume())
    }
}

private enum TestMutationError: Equatable {
    case replacementRejected
}

private enum TestMutationResult: Equatable {
    case success
    case failure(TestMutationError)
}

private struct TestMutationResultSlot {
    private var firstFailure: TestMutationResult?

    mutating func record(_ result: TestMutationResult) {
        guard firstFailure == nil, case .failure = result else {
            return
        }
        firstFailure = result
    }

    mutating func consume() -> TestMutationResult? {
        defer { firstFailure = nil }
        return firstFailure
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
