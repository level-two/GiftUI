import GiftUISemanticCore
import GiftUIInteraction
import GiftUIExecution
import GiftUIRuntimeStatic
// Each retained physical inline copy is classified, including spare slots.
// The ABI totals include optional tags, alignment and storage control separately.
private typealias Key = SemanticCompleteIdentity
private typealias Candidate = StaticSixInteractionCandidateStorage<Key>
private typealias Committed = StaticSixInteractionCommittedStorage<Key>
private typealias Hits = StaticSixInteractionHitStorage<Key>
private typealias State = InteractionOwnedKeyState<Candidate, Committed, Hits>
@_cdecl("p05_key_stride") public func keyStride() -> UInt32 { UInt32(MemoryLayout<Key>.stride) }
@_cdecl("p05_component_stride") public func componentStride() -> UInt32 { UInt32(MemoryLayout<SemanticPathComponent>.stride) }
@_cdecl("p05_candidate_record_stride") public func candidateStride() -> UInt32 { UInt32(MemoryLayout<InteractionCandidateRecord<Key>?>.stride) }
@_cdecl("p05_committed_record_stride") public func committedStride() -> UInt32 { UInt32(MemoryLayout<BoundActionRecord<Key>?>.stride) }
@_cdecl("p05_hit_stride") public func hitStride() -> UInt32 { UInt32(MemoryLayout<InteractionHitRegion<Key>?>.stride) }
@_cdecl("p05_static_owned_state_stride") public func stateStride() -> UInt32 { UInt32(MemoryLayout<State>.stride) }
@_cdecl("p05_static_candidate_storage_stride") public func candidateStorageStride() -> UInt32 { UInt32(MemoryLayout<Candidate>.stride) }
@_cdecl("p05_static_committed_storage_stride") public func committedStorageStride() -> UInt32 { UInt32(MemoryLayout<Committed>.stride) }
@_cdecl("p05_static_hit_storage_stride") public func hitStorageStride() -> UInt32 { UInt32(MemoryLayout<Hits>.stride) }

@_cdecl("p05_candidate_element_stride") public func candidateElementStride() -> UInt32 { UInt32(MemoryLayout<InteractionCandidateRecord<Key>>.stride) }
@_cdecl("p05_committed_element_stride") public func committedElementStride() -> UInt32 { UInt32(MemoryLayout<BoundActionRecord<Key>>.stride) }
@_cdecl("p05_hit_element_stride") public func hitElementStride() -> UInt32 { UInt32(MemoryLayout<InteractionHitRegion<Key>>.stride) }
@_cdecl("p05_captured_action_stride") public func capturedActionStride() -> UInt32 { UInt32(MemoryLayout<CapturedAction<Key>>.stride) }
@_cdecl("p05_pointer_capture_stride") public func pointerCaptureStride() -> UInt32 { UInt32(MemoryLayout<PointerActionCapture<Key>>.stride) }
