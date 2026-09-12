import GiftUI
import GiftUIExecution
import XCTest

@testable import GiftUIInteraction

final class InteractionValueTests: XCTestCase {
    func testDisabledStateConjoinsAndSiblingCopiesDoNotLeak() {
        let root = EffectiveActionEnabledState()
        let disabled = root.applying(DisabledSemanticPayload(isDisabled: true))
        let falseBelowDisabled = disabled.applying(
            DisabledSemanticPayload(isDisabled: false)
        )
        let enabledSibling = root.applying(DisabledSemanticPayload(isDisabled: false))

        XCTAssertFalse(disabled.isEnabled)
        XCTAssertFalse(falseBelowDisabled.isEnabled)
        XCTAssertTrue(enabledSibling.isEnabled)
    }

    func testActionNormalizerRejectsWrongDomainAndPreservesExactCodes() {
        XCTAssertEqual(
            InteractionActionNormalizer<TestHandler>.normalize(TestAction.maximum),
            .normalized(BoundedApplicationAction(code: .max))
        )
        XCTAssertEqual(
            InteractionActionNormalizer<TestHandler>.normalize(OtherAction.value),
            .failure(.incompatibleActionDomain)
        )
    }

    func testBoundedApplicationActionIsExactlyTwoBytes() {
        XCTAssertEqual(MemoryLayout<BoundedApplicationAction>.size, 2)
        XCTAssertEqual(BoundedApplicationAction(code: .min).code, .min)
        XCTAssertEqual(BoundedApplicationAction(code: .max).code, .max)
    }

    func testLimitsRejectZeroAndTooManyHitRegions() {
        XCTAssertNil(InteractionLimits(maximumActions: 0, maximumHitRegions: 1))
        XCTAssertNil(InteractionLimits(maximumActions: 1, maximumHitRegions: 0))
        XCTAssertNil(InteractionLimits(maximumActions: 1, maximumHitRegions: 2))
        XCTAssertEqual(
            InteractionLimits(maximumActions: 2, maximumHitRegions: 2),
            InteractionLimits(maximumActions: 2, maximumHitRegions: 2)
        )
    }
}

private enum TestAction: UInt16, GiftUIAction {
    case maximum = 65_535
}

private enum OtherAction: UInt16, GiftUIAction {
    case value = 65_535
}

private final class TestModel: _GiftUIObservableReference {
    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    func _giftUIDetachChangeSink(_ attachment: _GiftUIObservationAttachment) {}
}

private struct TestHandler: GiftUIActionHandler {
    mutating func handle(_ action: TestAction, model: borrowing TestModel) {}
}
