import GiftUISemanticCore
@_cdecl("giftui_p04_layout_record") public func layout_record() -> UInt32 { UInt32(MemoryLayout<SemanticRuntimeRecord>.stride) }
@_cdecl("giftui_p04_layout_prefix") public func layout_prefix() -> UInt32 { UInt32(MemoryLayout<SemanticPathEntry>.stride) }
@_cdecl("giftui_p04_layout_component") public func layout_component() -> UInt32 { UInt32(MemoryLayout<SemanticPathComponent>.stride) }
@_cdecl("giftui_p04_layout_complete_key") public func layout_complete_key() -> UInt32 { UInt32(MemoryLayout<SemanticCompleteIdentity>.stride) }
@_cdecl("giftui_p04_layout_metadata") public func layout_metadata() -> UInt32 { UInt32(MemoryLayout<SemanticRecordBankMetadata>.stride) }
@_cdecl("giftui_p04_layout_payload_slot") public func layout_payload_slot() -> UInt32 { UInt32(MemoryLayout<SemanticStandardPayload?>.stride) }
@_cdecl("giftui_p04_layout_reference") public func layout_reference() -> UInt32 { UInt32(MemoryLayout<SemanticRecordReference>.stride) }
