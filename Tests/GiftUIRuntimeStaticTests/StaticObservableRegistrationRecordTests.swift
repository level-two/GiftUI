import GiftUI
import GiftUIExecution
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeStatic

private struct StaticRegistrationModel: _GiftUIObservableReference {
    let reportDuringAttach: Bool
    private(set) var attachment: _GiftUIObservationAttachment?

    init(reportDuringAttach: Bool = false) {
        self.reportDuringAttach = reportDuringAttach
    }

    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        var offered = consume sink
        let attachment = offered.attachment
        if reportDuringAttach {
            _ = offered.reportChange()
        }
        self.attachment = attachment
        return attachment
    }

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        guard self.attachment == attachment else { return }
        self.attachment = nil
    }
}

@Test func staticRegistrationRecordOwnsDirectReportStateApartFromModelStorage() {
    var record = StaticObservableRegistrationRecord()
    var storage = StaticObservableModelStorage<StaticRegistrationModel>()
    let binding = storage.withBoundState(
        State(wrappedValue: StaticRegistrationModel()),
        replacementRoute: { _ in },
        body: { _ in () }
    )
    guard case .bound(.materialized, ()) = binding else {
        Issue.record("static model did not materialize")
        return
    }

    #expect(record.beginAttachment(generation: 0) == nil)
    guard
        let sink = record.makeSink(reportRoute: { reported in
            record.acceptReport(reported)
        })
    else {
        Issue.record("static registration did not issue a sink")
        return
    }
    let returned = storage.attachChangeSink(consume sink)
    #expect(record.acceptAttachmentReturn(returned) == nil)
    #expect(record.isActive)

    record.setExecutionPhase(.mutating)
    guard
        let storedAttachment = storage.withModel({ $0.attachment }),
        let attachment = storedAttachment
    else {
        Issue.record("static model did not retain its attachment")
        return
    }
    #expect(attachment == _GiftUIObservationAttachment(slot: 0, generation: 0))
    #expect(record.acceptReport(attachment) == .dirtied)
    #expect(record.acceptReport(attachment) == .coalesced)
    #expect(record.isDirty)

    #expect(record.retire() == nil)
    let didDetach = storage.detachChangeSink(attachment)
    #expect(didDetach)
    #expect(storage.removeModel() != nil)
    #expect(!record.isActive)
    #expect(!record.isDirty)
}

@Test func staticRegistrationRecordRejectsAttachTimeReportBeforeActivation() {
    var record = StaticObservableRegistrationRecord()
    var storage = StaticObservableModelStorage<StaticRegistrationModel>()
    _ = storage.withBoundState(
        State(wrappedValue: StaticRegistrationModel(reportDuringAttach: true)),
        replacementRoute: { _ in },
        body: { _ in () }
    )

    #expect(record.beginAttachment(generation: 4) == nil)
    guard
        let sink = record.makeSink(reportRoute: { reported in
            record.acceptReport(reported)
        })
    else {
        Issue.record("static registration did not issue a sink")
        return
    }
    let returned = storage.attachChangeSink(consume sink)
    #expect(record.acceptAttachmentReturn(returned) == .staleAttachment)
    #expect(!record.isActive)
    if let returned {
        let didDetach = storage.detachChangeSink(returned)
        #expect(didDetach)
    }
    #expect(storage.removeModel() != nil)
}
