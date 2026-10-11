import GiftUI
import GiftUIDrawing
import GiftUISemanticCore
import GiftUIRuntimeCore
import CounterSchema
import CounterCanvas
import CounterCanvasTable
import AnalyzerSchema
import AnalyzerCanvas
import AnalyzerCanvasTable
import SignalAnalyzerDomain
import CanvasStoreProbe

private enum ResourceAnalyzerDomain: AnalyzerReadDomain {
    typealias Slot = UInt8
    static func bind(_ key: _GiftUIModelKey<AnalyzerModelSchema>, slots: Span<UInt8>) throws(_GiftUIAccessFailure) -> Int { 0 }
    static func AnalyzerRead_state_acquisitionState(at index: Int, slots: Span<UInt8>) -> AcquisitionState { .running }
    static func AnalyzerRead_state_capture_count(at index: Int, slots: Span<UInt8>) -> UInt16 { 0 }
    static func AnalyzerRead_state_capture_transition(_ position: Int, at index: Int, slots: Span<UInt8>) throws(_GiftUIAccessFailure) -> SignalTransition { throw .outOfBounds }
}
@_cdecl("giftui_p06_layout_analyzer_staged_slot_size") public func analyzer_staged_slot_size() -> UInt32 { UInt32(MemoryLayout<CanvasStagedEntry<SemanticRecordReference, AnalyzerSchemaCanvasTable<ResourceAnalyzerDomain>.CaptureStorage>?>.size) }
@_cdecl("giftui_p06_layout_analyzer_staged_slot_stride") public func analyzer_staged_slot_stride() -> UInt32 { UInt32(MemoryLayout<CanvasStagedEntry<SemanticRecordReference, AnalyzerSchemaCanvasTable<ResourceAnalyzerDomain>.CaptureStorage>?>.stride) }
@_cdecl("giftui_p06_layout_analyzer_staged_slot_alignment") public func analyzer_staged_slot_alignment() -> UInt32 { UInt32(MemoryLayout<CanvasStagedEntry<SemanticRecordReference, AnalyzerSchemaCanvasTable<ResourceAnalyzerDomain>.CaptureStorage>?>.alignment) }
@_cdecl("giftui_p06_layout_counter_value_size") public func counter_value_size() -> UInt32 { UInt32(MemoryLayout<CounterTrace<CanvasDomain>>.size) }
@_cdecl("giftui_p06_layout_counter_value_stride") public func counter_value_stride() -> UInt32 { UInt32(MemoryLayout<CounterTrace<CanvasDomain>>.stride) }
@_cdecl("giftui_p06_layout_counter_value_alignment") public func counter_value_alignment() -> UInt32 { UInt32(MemoryLayout<CounterTrace<CanvasDomain>>.alignment) }
@_cdecl("giftui_p06_layout_empty_value_size") public func empty_value_size() -> UInt32 { UInt32(MemoryLayout<EmptyCanvas<CanvasDomain>>.size) }
@_cdecl("giftui_p06_layout_empty_value_stride") public func empty_value_stride() -> UInt32 { UInt32(MemoryLayout<EmptyCanvas<CanvasDomain>>.stride) }
@_cdecl("giftui_p06_layout_empty_value_alignment") public func empty_value_alignment() -> UInt32 { UInt32(MemoryLayout<EmptyCanvas<CanvasDomain>>.alignment) }
@_cdecl("giftui_p06_layout_analyzer_value_size") public func analyzer_value_size() -> UInt32 { UInt32(MemoryLayout<AnalyzerTrace<ResourceAnalyzerDomain>>.size) }
@_cdecl("giftui_p06_layout_analyzer_value_stride") public func analyzer_value_stride() -> UInt32 { UInt32(MemoryLayout<AnalyzerTrace<ResourceAnalyzerDomain>>.stride) }
@_cdecl("giftui_p06_layout_analyzer_value_alignment") public func analyzer_value_alignment() -> UInt32 { UInt32(MemoryLayout<AnalyzerTrace<ResourceAnalyzerDomain>>.alignment) }
@_cdecl("giftui_p06_layout_counter_union_size") public func counter_union_size() -> UInt32 { UInt32(MemoryLayout<CanvasTable.CaptureStorage>.size) }
@_cdecl("giftui_p06_layout_counter_union_stride") public func counter_union_stride() -> UInt32 { UInt32(MemoryLayout<CanvasTable.CaptureStorage>.stride) }
@_cdecl("giftui_p06_layout_counter_union_alignment") public func counter_union_alignment() -> UInt32 { UInt32(MemoryLayout<CanvasTable.CaptureStorage>.alignment) }
@_cdecl("giftui_p06_layout_analyzer_union_size") public func analyzer_union_size() -> UInt32 { UInt32(MemoryLayout<AnalyzerSchemaCanvasTable<ResourceAnalyzerDomain>.CaptureStorage>.size) }
@_cdecl("giftui_p06_layout_analyzer_union_stride") public func analyzer_union_stride() -> UInt32 { UInt32(MemoryLayout<AnalyzerSchemaCanvasTable<ResourceAnalyzerDomain>.CaptureStorage>.stride) }
@_cdecl("giftui_p06_layout_analyzer_union_alignment") public func analyzer_union_alignment() -> UInt32 { UInt32(MemoryLayout<AnalyzerSchemaCanvasTable<ResourceAnalyzerDomain>.CaptureStorage>.alignment) }
@_cdecl("giftui_p06_layout_witness_table_size") public func witness_table_size() -> UInt32 { UInt32(MemoryLayout<CanvasTable>.size) }
@_cdecl("giftui_p06_layout_witness_table_stride") public func witness_table_stride() -> UInt32 { UInt32(MemoryLayout<CanvasTable>.stride) }
@_cdecl("giftui_p06_layout_witness_table_alignment") public func witness_table_alignment() -> UInt32 { UInt32(MemoryLayout<CanvasTable>.alignment) }
@_cdecl("giftui_p06_layout_staged_entry_size") public func staged_entry_size() -> UInt32 { UInt32(MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CanvasTable.CaptureStorage>>.size) }
@_cdecl("giftui_p06_layout_staged_entry_stride") public func staged_entry_stride() -> UInt32 { UInt32(MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CanvasTable.CaptureStorage>>.stride) }
@_cdecl("giftui_p06_layout_staged_entry_alignment") public func staged_entry_alignment() -> UInt32 { UInt32(MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CanvasTable.CaptureStorage>>.alignment) }
@_cdecl("giftui_p06_layout_staged_slot_size") public func staged_slot_size() -> UInt32 { UInt32(MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CanvasTable.CaptureStorage>?>.size) }
@_cdecl("giftui_p06_layout_staged_slot_stride") public func staged_slot_stride() -> UInt32 { UInt32(MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CanvasTable.CaptureStorage>?>.stride) }
@_cdecl("giftui_p06_layout_staged_slot_alignment") public func staged_slot_alignment() -> UInt32 { UInt32(MemoryLayout<CanvasStagedEntry<SemanticRecordReference, CanvasTable.CaptureStorage>?>.alignment) }
@_cdecl("giftui_p06_layout_staged_metadata_size") public func staged_metadata_size() -> UInt32 { UInt32(MemoryLayout<CanvasStagedMetadata>.size) }
@_cdecl("giftui_p06_layout_staged_metadata_stride") public func staged_metadata_stride() -> UInt32 { UInt32(MemoryLayout<CanvasStagedMetadata>.stride) }
@_cdecl("giftui_p06_layout_staged_metadata_alignment") public func staged_metadata_alignment() -> UInt32 { UInt32(MemoryLayout<CanvasStagedMetadata>.alignment) }
@_cdecl("giftui_p06_layout_staged_scope_size") public func staged_scope_size() -> UInt32 { UInt32(MemoryLayout<CanvasStagedValues<SemanticRecordReference, CanvasTable>>.size) }
@_cdecl("giftui_p06_layout_staged_scope_stride") public func staged_scope_stride() -> UInt32 { UInt32(MemoryLayout<CanvasStagedValues<SemanticRecordReference, CanvasTable>>.stride) }
@_cdecl("giftui_p06_layout_staged_scope_alignment") public func staged_scope_alignment() -> UInt32 { UInt32(MemoryLayout<CanvasStagedValues<SemanticRecordReference, CanvasTable>>.alignment) }
@_cdecl("giftui_p06_layout_invocation_source_size") public func invocation_source_size() -> UInt32 { UInt32(MemoryLayout<ObservableCanvasInvocationSource<CanvasModel, CounterModelSchema, SemanticRecordReference, CanvasTable>>.size) }
@_cdecl("giftui_p06_layout_invocation_source_stride") public func invocation_source_stride() -> UInt32 { UInt32(MemoryLayout<ObservableCanvasInvocationSource<CanvasModel, CounterModelSchema, SemanticRecordReference, CanvasTable>>.stride) }
@_cdecl("giftui_p06_layout_invocation_source_alignment") public func invocation_source_alignment() -> UInt32 { UInt32(MemoryLayout<ObservableCanvasInvocationSource<CanvasModel, CounterModelSchema, SemanticRecordReference, CanvasTable>>.alignment) }
@_cdecl("giftui_p06_layout_semantic_payload_size") public func semantic_payload_size() -> UInt32 { UInt32(MemoryLayout<CanvasSemanticPayload<CanvasTable.CaptureStorage>>.size) }
@_cdecl("giftui_p06_layout_semantic_payload_stride") public func semantic_payload_stride() -> UInt32 { UInt32(MemoryLayout<CanvasSemanticPayload<CanvasTable.CaptureStorage>>.stride) }
@_cdecl("giftui_p06_layout_semantic_payload_alignment") public func semantic_payload_alignment() -> UInt32 { UInt32(MemoryLayout<CanvasSemanticPayload<CanvasTable.CaptureStorage>>.alignment) }
@_cdecl("giftui_p06_layout_semantic_slot_size") public func semantic_slot_size() -> UInt32 { UInt32(MemoryLayout<CanvasSemanticPayload<CanvasTable.CaptureStorage>?>.size) }
@_cdecl("giftui_p06_layout_semantic_slot_stride") public func semantic_slot_stride() -> UInt32 { UInt32(MemoryLayout<CanvasSemanticPayload<CanvasTable.CaptureStorage>?>.stride) }
@_cdecl("giftui_p06_layout_semantic_slot_alignment") public func semantic_slot_alignment() -> UInt32 { UInt32(MemoryLayout<CanvasSemanticPayload<CanvasTable.CaptureStorage>?>.alignment) }
@_cdecl("giftui_p06_layout_analyzer_semantic_slot_size") public func analyzer_semantic_slot_size() -> UInt32 { UInt32(MemoryLayout<CanvasSemanticPayload<AnalyzerSchemaCanvasTable<ResourceAnalyzerDomain>.CaptureStorage>?>.size) }
@_cdecl("giftui_p06_layout_analyzer_semantic_slot_stride") public func analyzer_semantic_slot_stride() -> UInt32 { UInt32(MemoryLayout<CanvasSemanticPayload<AnalyzerSchemaCanvasTable<ResourceAnalyzerDomain>.CaptureStorage>?>.stride) }
@_cdecl("giftui_p06_layout_analyzer_semantic_slot_alignment") public func analyzer_semantic_slot_alignment() -> UInt32 { UInt32(MemoryLayout<CanvasSemanticPayload<AnalyzerSchemaCanvasTable<ResourceAnalyzerDomain>.CaptureStorage>?>.alignment) }
@_cdecl("giftui_p06_layout_standard_slot_size") public func standard_slot_size() -> UInt32 { UInt32(MemoryLayout<SemanticStandardPayload?>.size) }
@_cdecl("giftui_p06_layout_standard_slot_stride") public func standard_slot_stride() -> UInt32 { UInt32(MemoryLayout<SemanticStandardPayload?>.stride) }
@_cdecl("giftui_p06_layout_standard_slot_alignment") public func standard_slot_alignment() -> UInt32 { UInt32(MemoryLayout<SemanticStandardPayload?>.alignment) }
@_cdecl("giftui_p06_layout_semantic_record_size") public func semantic_record_size() -> UInt32 { UInt32(MemoryLayout<SemanticRuntimeRecord>.size) }
@_cdecl("giftui_p06_layout_semantic_record_stride") public func semantic_record_stride() -> UInt32 { UInt32(MemoryLayout<SemanticRuntimeRecord>.stride) }
@_cdecl("giftui_p06_layout_semantic_record_alignment") public func semantic_record_alignment() -> UInt32 { UInt32(MemoryLayout<SemanticRuntimeRecord>.alignment) }
@_cdecl("giftui_p06_layout_semantic_prefix_size") public func semantic_prefix_size() -> UInt32 { UInt32(MemoryLayout<SemanticPathEntry>.size) }
@_cdecl("giftui_p06_layout_semantic_prefix_stride") public func semantic_prefix_stride() -> UInt32 { UInt32(MemoryLayout<SemanticPathEntry>.stride) }
@_cdecl("giftui_p06_layout_semantic_prefix_alignment") public func semantic_prefix_alignment() -> UInt32 { UInt32(MemoryLayout<SemanticPathEntry>.alignment) }
@_cdecl("giftui_p06_layout_semantic_metadata_size") public func semantic_metadata_size() -> UInt32 { UInt32(MemoryLayout<SemanticRecordBankMetadata>.size) }
@_cdecl("giftui_p06_layout_semantic_metadata_stride") public func semantic_metadata_stride() -> UInt32 { UInt32(MemoryLayout<SemanticRecordBankMetadata>.stride) }
@_cdecl("giftui_p06_layout_semantic_metadata_alignment") public func semantic_metadata_alignment() -> UInt32 { UInt32(MemoryLayout<SemanticRecordBankMetadata>.alignment) }
@_cdecl("giftui_p06_layout_semantic_reference_size") public func semantic_reference_size() -> UInt32 { UInt32(MemoryLayout<SemanticRecordReference>.size) }
@_cdecl("giftui_p06_layout_semantic_reference_stride") public func semantic_reference_stride() -> UInt32 { UInt32(MemoryLayout<SemanticRecordReference>.stride) }
@_cdecl("giftui_p06_layout_semantic_reference_alignment") public func semantic_reference_alignment() -> UInt32 { UInt32(MemoryLayout<SemanticRecordReference>.alignment) }
