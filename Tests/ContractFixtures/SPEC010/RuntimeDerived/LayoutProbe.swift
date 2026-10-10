import GiftUI
@testable import GiftUIObservableState

@_cdecl("giftui_p03_layout_ledger") public func ledgerLayout() -> Int { MemoryLayout<ObservableModelOwnership>.stride }
@_cdecl("giftui_p03_layout_model_record") public func modelRecordLayout() -> Int { MemoryLayout<ObservableModelOwnership.Record>.stride }
@_cdecl("giftui_p03_layout_pin_offset") public func pinOffset() -> Int { {
    var record = ObservableModelOwnership.Record()
    let base = withUnsafePointer(to: &record) { Int(bitPattern: $0) }
    return withUnsafePointer(to: &record.pinned) { Int(bitPattern: $0) &- base }
}() }
@_cdecl("giftui_p03_layout_pin_field") public func pinFieldLayout() -> Int { MemoryLayout<Bool>.size }
@_cdecl("giftui_p03_layout_claim_record") public func claimRecordLayout() -> Int { MemoryLayout<ObservableModelOwnership.ClaimRecord>.stride }
@_cdecl("giftui_p03_layout_claim") public func claimLayout() -> Int { MemoryLayout<ObservableModelOwnership.Claim>.stride }
@_cdecl("giftui_p03_layout_ticket") public func ticketLayout() -> Int { MemoryLayout<ObservableModelTicket<UInt8>>.stride }
@_cdecl("giftui_p03_layout_ticket_alignment") public func ticketAlignment() -> Int { MemoryLayout<ObservableModelTicket<UInt8>>.alignment }
@_cdecl("giftui_p03_layout_scope") public func scopeLayout() -> Int { MemoryLayout<ObservableModelScope<UInt8, UInt8>>.stride }
@_cdecl("giftui_p03_layout_read_slot") public func readSlotLayout() -> Int { MemoryLayout<ObservableModelReadSlot<UInt8>>.stride }
@_cdecl("giftui_p03_layout_replacement") public func replacementLayout() -> Int { MemoryLayout<ObservableModelOwnership.Replacement>.stride }
@_cdecl("giftui_p03_layout_registration_record_u8") public func registrationRecordLayout() -> Int { MemoryLayout<ObservableStateRootStorage<UInt8>.Record>.stride }
@_cdecl("giftui_p03_layout_root_storage_u8") public func rootStorageLayout() -> Int { MemoryLayout<ObservableStateRootStorage<UInt8>>.stride }
@_cdecl("giftui_p03_layout_sink") public func sinkLayout() -> Int { MemoryLayout<_GiftUIObservableChangeSink>.stride }

@_cdecl("giftui_p03_layout_report_storage") public func reportStorageLayout() -> Int { MemoryLayout<ObservableStateRootReports>.stride }
@_cdecl("giftui_p03_layout_report_route") public func reportRouteLayout() -> Int { MemoryLayout<ObservableStateRootReports.Route>.stride }
