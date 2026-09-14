import GiftUI
import Testing

@testable import GiftUIObservableState

private final class BridgeModel: _GiftUIObservableReference {
    private var sink: _GiftUIObservableChangeSink?
    private(set) var detachments: [_GiftUIObservationAttachment] = []
    var reportDuringAttach = false

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        var installed = consume sink
        let attachment = installed.attachment
        if reportDuringAttach { _ = installed.reportChange() }
        self.sink = consume installed
        return attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        detachments.append(attachment)
        sink = nil
    }

    func report() -> _GiftUIObservableChangeReportOutcome? {
        sink?.reportChange()
    }
}

@Test func registrationBridgeIssuesOneSinkAndActivatesOnlyAfterExactReturn() {
    let attachment = _GiftUIObservationAttachment(slot: 0, generation: 0)
    var bridge = ObservableStateRegistrationBridge()
    let model = BridgeModel()

    #expect(bridge.beginAttachment(attachment) == nil)
    guard
        let sink = bridge.makeSink(reportRoute: { reported in
            bridge.acceptReport(reported) == nil ? .dirtied : .staleAttachment
        })
    else {
        Issue.record("registration bridge did not issue its sink")
        return
    }
    if let unexpected = bridge.makeSink(reportRoute: { _ in .invariantViolation }) {
        _ = consume unexpected
        Issue.record("registration bridge issued a second sink")
    }
    let returned = model._giftUIAttachChangeSink(consume sink)
    #expect(bridge.acceptAttachmentReturn(returned) == nil)
    #expect(bridge.isActive)
    #expect(model.report() == .dirtied)
    #expect(
        bridge.acceptReport(
            _GiftUIObservationAttachment(slot: 0, generation: 1)
        ) == .staleAttachment
    )
    #expect(bridge.retire(attachment) == nil)
    model._giftUIDetachChangeSink(attachment)
    #expect(model.report() == nil)
    #expect(model.detachments == [attachment])
}

@Test func registrationBridgePreservesAttachTimeReportAsAStaleFailure() {
    let attachment = _GiftUIObservationAttachment(slot: 0, generation: 7)
    var bridge = ObservableStateRegistrationBridge()
    let model = BridgeModel()
    model.reportDuringAttach = true

    #expect(bridge.beginAttachment(attachment) == nil)
    guard
        let sink = bridge.makeSink(reportRoute: { reported in
            bridge.acceptReport(reported) == nil ? .dirtied : .staleAttachment
        })
    else {
        Issue.record("registration bridge did not issue its sink")
        return
    }
    let returned = model._giftUIAttachChangeSink(consume sink)
    #expect(bridge.acceptAttachmentReturn(returned) == .staleAttachment)
    #expect(!bridge.isActive)
    model._giftUIDetachChangeSink(attachment)
    #expect(model.detachments == [attachment])
    let shutdownRequiredDetach = bridge.shutdown()
    #expect(!shutdownRequiredDetach)
}
