// Measurement roots only: no target execution or global initialization.
// Read-only extraction accepts a root only if its entire body returns an
// immediate UInt32 with no calls, loads, branches, relocations or stack work.
#if hasFeature(Embedded)
@inline(__always)
private func counterEmbeddedRegionFact(_ field: Int, _ component: Int) -> UInt32 {
    guard let layout = CounterEmbeddedLayout(suppliedByteCount: counterEmbeddedSlotBytes),
          layout.fields == 25, let region = layout.regions[field] else { preconditionFailure("invalid measured layout") }
    let value: Int
    switch component {
    case 0: value = region.offset
    case 1: value = region.count
    case 2: value = region.size
    case 3: value = region.stride
    case 4: value = region.alignment
    default: preconditionFailure("invalid region fact")
    }
    guard let result = UInt32(exactly: value) else { preconditionFailure("layout fact exceeds UInt32") }
    return result
}
@inline(__always)
private func counterEmbeddedSummaryFact(_ component: Int) -> UInt32 {
    guard let layout = CounterEmbeddedLayout(suppliedByteCount: counterEmbeddedSlotBytes),
          layout.fields == 25 else { preconditionFailure("invalid measured layout") }
    let value: Int
    switch component {
    case 0: value = layout.cursor
    case 1: value = layout.maximumAlignment
    case 2: value = layout.slotBytes
    case 3: value = layout.totalBytes
    default: preconditionFailure("invalid summary fact")
    }
    guard let result = UInt32(exactly: value) else { preconditionFailure("layout fact exceeds UInt32") }
    return result
}

@_cdecl("giftui_p08_layout_limits_offset")
@inline(__always)
func counterEmbeddedFact0_0() -> UInt32 { counterEmbeddedRegionFact(0, 0) }
@_cdecl("giftui_p08_layout_limits_count")
@inline(__always)
func counterEmbeddedFact0_1() -> UInt32 { counterEmbeddedRegionFact(0, 1) }
@_cdecl("giftui_p08_layout_limits_size")
@inline(__always)
func counterEmbeddedFact0_2() -> UInt32 { counterEmbeddedRegionFact(0, 2) }
@_cdecl("giftui_p08_layout_limits_stride")
@inline(__always)
func counterEmbeddedFact0_3() -> UInt32 { counterEmbeddedRegionFact(0, 3) }
@_cdecl("giftui_p08_layout_limits_alignment")
@inline(__always)
func counterEmbeddedFact0_4() -> UInt32 { counterEmbeddedRegionFact(0, 4) }
@_cdecl("giftui_p08_layout_root_offset")
@inline(__always)
func counterEmbeddedFact1_0() -> UInt32 { counterEmbeddedRegionFact(1, 0) }
@_cdecl("giftui_p08_layout_root_count")
@inline(__always)
func counterEmbeddedFact1_1() -> UInt32 { counterEmbeddedRegionFact(1, 1) }
@_cdecl("giftui_p08_layout_root_size")
@inline(__always)
func counterEmbeddedFact1_2() -> UInt32 { counterEmbeddedRegionFact(1, 2) }
@_cdecl("giftui_p08_layout_root_stride")
@inline(__always)
func counterEmbeddedFact1_3() -> UInt32 { counterEmbeddedRegionFact(1, 3) }
@_cdecl("giftui_p08_layout_root_alignment")
@inline(__always)
func counterEmbeddedFact1_4() -> UInt32 { counterEmbeddedRegionFact(1, 4) }
@_cdecl("giftui_p08_layout_semantic_offset")
@inline(__always)
func counterEmbeddedFact2_0() -> UInt32 { counterEmbeddedRegionFact(2, 0) }
@_cdecl("giftui_p08_layout_semantic_count")
@inline(__always)
func counterEmbeddedFact2_1() -> UInt32 { counterEmbeddedRegionFact(2, 1) }
@_cdecl("giftui_p08_layout_semantic_size")
@inline(__always)
func counterEmbeddedFact2_2() -> UInt32 { counterEmbeddedRegionFact(2, 2) }
@_cdecl("giftui_p08_layout_semantic_stride")
@inline(__always)
func counterEmbeddedFact2_3() -> UInt32 { counterEmbeddedRegionFact(2, 3) }
@_cdecl("giftui_p08_layout_semantic_alignment")
@inline(__always)
func counterEmbeddedFact2_4() -> UInt32 { counterEmbeddedRegionFact(2, 4) }
@_cdecl("giftui_p08_layout_semanticRecords_offset")
@inline(__always)
func counterEmbeddedFact3_0() -> UInt32 { counterEmbeddedRegionFact(3, 0) }
@_cdecl("giftui_p08_layout_semanticRecords_count")
@inline(__always)
func counterEmbeddedFact3_1() -> UInt32 { counterEmbeddedRegionFact(3, 1) }
@_cdecl("giftui_p08_layout_semanticRecords_size")
@inline(__always)
func counterEmbeddedFact3_2() -> UInt32 { counterEmbeddedRegionFact(3, 2) }
@_cdecl("giftui_p08_layout_semanticRecords_stride")
@inline(__always)
func counterEmbeddedFact3_3() -> UInt32 { counterEmbeddedRegionFact(3, 3) }
@_cdecl("giftui_p08_layout_semanticRecords_alignment")
@inline(__always)
func counterEmbeddedFact3_4() -> UInt32 { counterEmbeddedRegionFact(3, 4) }
@_cdecl("giftui_p08_layout_semanticPaths_offset")
@inline(__always)
func counterEmbeddedFact4_0() -> UInt32 { counterEmbeddedRegionFact(4, 0) }
@_cdecl("giftui_p08_layout_semanticPaths_count")
@inline(__always)
func counterEmbeddedFact4_1() -> UInt32 { counterEmbeddedRegionFact(4, 1) }
@_cdecl("giftui_p08_layout_semanticPaths_size")
@inline(__always)
func counterEmbeddedFact4_2() -> UInt32 { counterEmbeddedRegionFact(4, 2) }
@_cdecl("giftui_p08_layout_semanticPaths_stride")
@inline(__always)
func counterEmbeddedFact4_3() -> UInt32 { counterEmbeddedRegionFact(4, 3) }
@_cdecl("giftui_p08_layout_semanticPaths_alignment")
@inline(__always)
func counterEmbeddedFact4_4() -> UInt32 { counterEmbeddedRegionFact(4, 4) }
@_cdecl("giftui_p08_layout_semanticPayloads_offset")
@inline(__always)
func counterEmbeddedFact5_0() -> UInt32 { counterEmbeddedRegionFact(5, 0) }
@_cdecl("giftui_p08_layout_semanticPayloads_count")
@inline(__always)
func counterEmbeddedFact5_1() -> UInt32 { counterEmbeddedRegionFact(5, 1) }
@_cdecl("giftui_p08_layout_semanticPayloads_size")
@inline(__always)
func counterEmbeddedFact5_2() -> UInt32 { counterEmbeddedRegionFact(5, 2) }
@_cdecl("giftui_p08_layout_semanticPayloads_stride")
@inline(__always)
func counterEmbeddedFact5_3() -> UInt32 { counterEmbeddedRegionFact(5, 3) }
@_cdecl("giftui_p08_layout_semanticPayloads_alignment")
@inline(__always)
func counterEmbeddedFact5_4() -> UInt32 { counterEmbeddedRegionFact(5, 4) }
@_cdecl("giftui_p08_layout_semanticScalars_offset")
@inline(__always)
func counterEmbeddedFact6_0() -> UInt32 { counterEmbeddedRegionFact(6, 0) }
@_cdecl("giftui_p08_layout_semanticScalars_count")
@inline(__always)
func counterEmbeddedFact6_1() -> UInt32 { counterEmbeddedRegionFact(6, 1) }
@_cdecl("giftui_p08_layout_semanticScalars_size")
@inline(__always)
func counterEmbeddedFact6_2() -> UInt32 { counterEmbeddedRegionFact(6, 2) }
@_cdecl("giftui_p08_layout_semanticScalars_stride")
@inline(__always)
func counterEmbeddedFact6_3() -> UInt32 { counterEmbeddedRegionFact(6, 3) }
@_cdecl("giftui_p08_layout_semanticScalars_alignment")
@inline(__always)
func counterEmbeddedFact6_4() -> UInt32 { counterEmbeddedRegionFact(6, 4) }
@_cdecl("giftui_p08_layout_values_offset")
@inline(__always)
func counterEmbeddedFact7_0() -> UInt32 { counterEmbeddedRegionFact(7, 0) }
@_cdecl("giftui_p08_layout_values_count")
@inline(__always)
func counterEmbeddedFact7_1() -> UInt32 { counterEmbeddedRegionFact(7, 1) }
@_cdecl("giftui_p08_layout_values_size")
@inline(__always)
func counterEmbeddedFact7_2() -> UInt32 { counterEmbeddedRegionFact(7, 2) }
@_cdecl("giftui_p08_layout_values_stride")
@inline(__always)
func counterEmbeddedFact7_3() -> UInt32 { counterEmbeddedRegionFact(7, 3) }
@_cdecl("giftui_p08_layout_values_alignment")
@inline(__always)
func counterEmbeddedFact7_4() -> UInt32 { counterEmbeddedRegionFact(7, 4) }
@_cdecl("giftui_p08_layout_canvasEntry_offset")
@inline(__always)
func counterEmbeddedFact8_0() -> UInt32 { counterEmbeddedRegionFact(8, 0) }
@_cdecl("giftui_p08_layout_canvasEntry_count")
@inline(__always)
func counterEmbeddedFact8_1() -> UInt32 { counterEmbeddedRegionFact(8, 1) }
@_cdecl("giftui_p08_layout_canvasEntry_size")
@inline(__always)
func counterEmbeddedFact8_2() -> UInt32 { counterEmbeddedRegionFact(8, 2) }
@_cdecl("giftui_p08_layout_canvasEntry_stride")
@inline(__always)
func counterEmbeddedFact8_3() -> UInt32 { counterEmbeddedRegionFact(8, 3) }
@_cdecl("giftui_p08_layout_canvasEntry_alignment")
@inline(__always)
func counterEmbeddedFact8_4() -> UInt32 { counterEmbeddedRegionFact(8, 4) }
@_cdecl("giftui_p08_layout_b0_offset")
@inline(__always)
func counterEmbeddedFact9_0() -> UInt32 { counterEmbeddedRegionFact(9, 0) }
@_cdecl("giftui_p08_layout_b0_count")
@inline(__always)
func counterEmbeddedFact9_1() -> UInt32 { counterEmbeddedRegionFact(9, 1) }
@_cdecl("giftui_p08_layout_b0_size")
@inline(__always)
func counterEmbeddedFact9_2() -> UInt32 { counterEmbeddedRegionFact(9, 2) }
@_cdecl("giftui_p08_layout_b0_stride")
@inline(__always)
func counterEmbeddedFact9_3() -> UInt32 { counterEmbeddedRegionFact(9, 3) }
@_cdecl("giftui_p08_layout_b0_alignment")
@inline(__always)
func counterEmbeddedFact9_4() -> UInt32 { counterEmbeddedRegionFact(9, 4) }
@_cdecl("giftui_p08_layout_b1_offset")
@inline(__always)
func counterEmbeddedFact10_0() -> UInt32 { counterEmbeddedRegionFact(10, 0) }
@_cdecl("giftui_p08_layout_b1_count")
@inline(__always)
func counterEmbeddedFact10_1() -> UInt32 { counterEmbeddedRegionFact(10, 1) }
@_cdecl("giftui_p08_layout_b1_size")
@inline(__always)
func counterEmbeddedFact10_2() -> UInt32 { counterEmbeddedRegionFact(10, 2) }
@_cdecl("giftui_p08_layout_b1_stride")
@inline(__always)
func counterEmbeddedFact10_3() -> UInt32 { counterEmbeddedRegionFact(10, 3) }
@_cdecl("giftui_p08_layout_b1_alignment")
@inline(__always)
func counterEmbeddedFact10_4() -> UInt32 { counterEmbeddedRegionFact(10, 4) }
@_cdecl("giftui_p08_layout_b2_offset")
@inline(__always)
func counterEmbeddedFact11_0() -> UInt32 { counterEmbeddedRegionFact(11, 0) }
@_cdecl("giftui_p08_layout_b2_count")
@inline(__always)
func counterEmbeddedFact11_1() -> UInt32 { counterEmbeddedRegionFact(11, 1) }
@_cdecl("giftui_p08_layout_b2_size")
@inline(__always)
func counterEmbeddedFact11_2() -> UInt32 { counterEmbeddedRegionFact(11, 2) }
@_cdecl("giftui_p08_layout_b2_stride")
@inline(__always)
func counterEmbeddedFact11_3() -> UInt32 { counterEmbeddedRegionFact(11, 3) }
@_cdecl("giftui_p08_layout_b2_alignment")
@inline(__always)
func counterEmbeddedFact11_4() -> UInt32 { counterEmbeddedRegionFact(11, 4) }
@_cdecl("giftui_p08_layout_b3_offset")
@inline(__always)
func counterEmbeddedFact12_0() -> UInt32 { counterEmbeddedRegionFact(12, 0) }
@_cdecl("giftui_p08_layout_b3_count")
@inline(__always)
func counterEmbeddedFact12_1() -> UInt32 { counterEmbeddedRegionFact(12, 1) }
@_cdecl("giftui_p08_layout_b3_size")
@inline(__always)
func counterEmbeddedFact12_2() -> UInt32 { counterEmbeddedRegionFact(12, 2) }
@_cdecl("giftui_p08_layout_b3_stride")
@inline(__always)
func counterEmbeddedFact12_3() -> UInt32 { counterEmbeddedRegionFact(12, 3) }
@_cdecl("giftui_p08_layout_b3_alignment")
@inline(__always)
func counterEmbeddedFact12_4() -> UInt32 { counterEmbeddedRegionFact(12, 4) }
@_cdecl("giftui_p08_layout_g0_offset")
@inline(__always)
func counterEmbeddedFact13_0() -> UInt32 { counterEmbeddedRegionFact(13, 0) }
@_cdecl("giftui_p08_layout_g0_count")
@inline(__always)
func counterEmbeddedFact13_1() -> UInt32 { counterEmbeddedRegionFact(13, 1) }
@_cdecl("giftui_p08_layout_g0_size")
@inline(__always)
func counterEmbeddedFact13_2() -> UInt32 { counterEmbeddedRegionFact(13, 2) }
@_cdecl("giftui_p08_layout_g0_stride")
@inline(__always)
func counterEmbeddedFact13_3() -> UInt32 { counterEmbeddedRegionFact(13, 3) }
@_cdecl("giftui_p08_layout_g0_alignment")
@inline(__always)
func counterEmbeddedFact13_4() -> UInt32 { counterEmbeddedRegionFact(13, 4) }
@_cdecl("giftui_p08_layout_g1_offset")
@inline(__always)
func counterEmbeddedFact14_0() -> UInt32 { counterEmbeddedRegionFact(14, 0) }
@_cdecl("giftui_p08_layout_g1_count")
@inline(__always)
func counterEmbeddedFact14_1() -> UInt32 { counterEmbeddedRegionFact(14, 1) }
@_cdecl("giftui_p08_layout_g1_size")
@inline(__always)
func counterEmbeddedFact14_2() -> UInt32 { counterEmbeddedRegionFact(14, 2) }
@_cdecl("giftui_p08_layout_g1_stride")
@inline(__always)
func counterEmbeddedFact14_3() -> UInt32 { counterEmbeddedRegionFact(14, 3) }
@_cdecl("giftui_p08_layout_g1_alignment")
@inline(__always)
func counterEmbeddedFact14_4() -> UInt32 { counterEmbeddedRegionFact(14, 4) }
@_cdecl("giftui_p08_layout_g2_offset")
@inline(__always)
func counterEmbeddedFact15_0() -> UInt32 { counterEmbeddedRegionFact(15, 0) }
@_cdecl("giftui_p08_layout_g2_count")
@inline(__always)
func counterEmbeddedFact15_1() -> UInt32 { counterEmbeddedRegionFact(15, 1) }
@_cdecl("giftui_p08_layout_g2_size")
@inline(__always)
func counterEmbeddedFact15_2() -> UInt32 { counterEmbeddedRegionFact(15, 2) }
@_cdecl("giftui_p08_layout_g2_stride")
@inline(__always)
func counterEmbeddedFact15_3() -> UInt32 { counterEmbeddedRegionFact(15, 3) }
@_cdecl("giftui_p08_layout_g2_alignment")
@inline(__always)
func counterEmbeddedFact15_4() -> UInt32 { counterEmbeddedRegionFact(15, 4) }
@_cdecl("giftui_p08_layout_g3_offset")
@inline(__always)
func counterEmbeddedFact16_0() -> UInt32 { counterEmbeddedRegionFact(16, 0) }
@_cdecl("giftui_p08_layout_g3_count")
@inline(__always)
func counterEmbeddedFact16_1() -> UInt32 { counterEmbeddedRegionFact(16, 1) }
@_cdecl("giftui_p08_layout_g3_size")
@inline(__always)
func counterEmbeddedFact16_2() -> UInt32 { counterEmbeddedRegionFact(16, 2) }
@_cdecl("giftui_p08_layout_g3_stride")
@inline(__always)
func counterEmbeddedFact16_3() -> UInt32 { counterEmbeddedRegionFact(16, 3) }
@_cdecl("giftui_p08_layout_g3_alignment")
@inline(__always)
func counterEmbeddedFact16_4() -> UInt32 { counterEmbeddedRegionFact(16, 4) }
@_cdecl("giftui_p08_layout_g4_offset")
@inline(__always)
func counterEmbeddedFact17_0() -> UInt32 { counterEmbeddedRegionFact(17, 0) }
@_cdecl("giftui_p08_layout_g4_count")
@inline(__always)
func counterEmbeddedFact17_1() -> UInt32 { counterEmbeddedRegionFact(17, 1) }
@_cdecl("giftui_p08_layout_g4_size")
@inline(__always)
func counterEmbeddedFact17_2() -> UInt32 { counterEmbeddedRegionFact(17, 2) }
@_cdecl("giftui_p08_layout_g4_stride")
@inline(__always)
func counterEmbeddedFact17_3() -> UInt32 { counterEmbeddedRegionFact(17, 3) }
@_cdecl("giftui_p08_layout_g4_alignment")
@inline(__always)
func counterEmbeddedFact17_4() -> UInt32 { counterEmbeddedRegionFact(17, 4) }
@_cdecl("giftui_p08_layout_c0_offset")
@inline(__always)
func counterEmbeddedFact18_0() -> UInt32 { counterEmbeddedRegionFact(18, 0) }
@_cdecl("giftui_p08_layout_c0_count")
@inline(__always)
func counterEmbeddedFact18_1() -> UInt32 { counterEmbeddedRegionFact(18, 1) }
@_cdecl("giftui_p08_layout_c0_size")
@inline(__always)
func counterEmbeddedFact18_2() -> UInt32 { counterEmbeddedRegionFact(18, 2) }
@_cdecl("giftui_p08_layout_c0_stride")
@inline(__always)
func counterEmbeddedFact18_3() -> UInt32 { counterEmbeddedRegionFact(18, 3) }
@_cdecl("giftui_p08_layout_c0_alignment")
@inline(__always)
func counterEmbeddedFact18_4() -> UInt32 { counterEmbeddedRegionFact(18, 4) }
@_cdecl("giftui_p08_layout_h0_offset")
@inline(__always)
func counterEmbeddedFact19_0() -> UInt32 { counterEmbeddedRegionFact(19, 0) }
@_cdecl("giftui_p08_layout_h0_count")
@inline(__always)
func counterEmbeddedFact19_1() -> UInt32 { counterEmbeddedRegionFact(19, 1) }
@_cdecl("giftui_p08_layout_h0_size")
@inline(__always)
func counterEmbeddedFact19_2() -> UInt32 { counterEmbeddedRegionFact(19, 2) }
@_cdecl("giftui_p08_layout_h0_stride")
@inline(__always)
func counterEmbeddedFact19_3() -> UInt32 { counterEmbeddedRegionFact(19, 3) }
@_cdecl("giftui_p08_layout_h0_alignment")
@inline(__always)
func counterEmbeddedFact19_4() -> UInt32 { counterEmbeddedRegionFact(19, 4) }
@_cdecl("giftui_p08_layout_r0_offset")
@inline(__always)
func counterEmbeddedFact20_0() -> UInt32 { counterEmbeddedRegionFact(20, 0) }
@_cdecl("giftui_p08_layout_r0_count")
@inline(__always)
func counterEmbeddedFact20_1() -> UInt32 { counterEmbeddedRegionFact(20, 1) }
@_cdecl("giftui_p08_layout_r0_size")
@inline(__always)
func counterEmbeddedFact20_2() -> UInt32 { counterEmbeddedRegionFact(20, 2) }
@_cdecl("giftui_p08_layout_r0_stride")
@inline(__always)
func counterEmbeddedFact20_3() -> UInt32 { counterEmbeddedRegionFact(20, 3) }
@_cdecl("giftui_p08_layout_r0_alignment")
@inline(__always)
func counterEmbeddedFact20_4() -> UInt32 { counterEmbeddedRegionFact(20, 4) }
@_cdecl("giftui_p08_layout_r1_offset")
@inline(__always)
func counterEmbeddedFact21_0() -> UInt32 { counterEmbeddedRegionFact(21, 0) }
@_cdecl("giftui_p08_layout_r1_count")
@inline(__always)
func counterEmbeddedFact21_1() -> UInt32 { counterEmbeddedRegionFact(21, 1) }
@_cdecl("giftui_p08_layout_r1_size")
@inline(__always)
func counterEmbeddedFact21_2() -> UInt32 { counterEmbeddedRegionFact(21, 2) }
@_cdecl("giftui_p08_layout_r1_stride")
@inline(__always)
func counterEmbeddedFact21_3() -> UInt32 { counterEmbeddedRegionFact(21, 3) }
@_cdecl("giftui_p08_layout_r1_alignment")
@inline(__always)
func counterEmbeddedFact21_4() -> UInt32 { counterEmbeddedRegionFact(21, 4) }
@_cdecl("giftui_p08_layout_h1_offset")
@inline(__always)
func counterEmbeddedFact22_0() -> UInt32 { counterEmbeddedRegionFact(22, 0) }
@_cdecl("giftui_p08_layout_h1_count")
@inline(__always)
func counterEmbeddedFact22_1() -> UInt32 { counterEmbeddedRegionFact(22, 1) }
@_cdecl("giftui_p08_layout_h1_size")
@inline(__always)
func counterEmbeddedFact22_2() -> UInt32 { counterEmbeddedRegionFact(22, 2) }
@_cdecl("giftui_p08_layout_h1_stride")
@inline(__always)
func counterEmbeddedFact22_3() -> UInt32 { counterEmbeddedRegionFact(22, 3) }
@_cdecl("giftui_p08_layout_h1_alignment")
@inline(__always)
func counterEmbeddedFact22_4() -> UInt32 { counterEmbeddedRegionFact(22, 4) }
@_cdecl("giftui_p08_layout_control_offset")
@inline(__always)
func counterEmbeddedFact23_0() -> UInt32 { counterEmbeddedRegionFact(23, 0) }
@_cdecl("giftui_p08_layout_control_count")
@inline(__always)
func counterEmbeddedFact23_1() -> UInt32 { counterEmbeddedRegionFact(23, 1) }
@_cdecl("giftui_p08_layout_control_size")
@inline(__always)
func counterEmbeddedFact23_2() -> UInt32 { counterEmbeddedRegionFact(23, 2) }
@_cdecl("giftui_p08_layout_control_stride")
@inline(__always)
func counterEmbeddedFact23_3() -> UInt32 { counterEmbeddedRegionFact(23, 3) }
@_cdecl("giftui_p08_layout_control_alignment")
@inline(__always)
func counterEmbeddedFact23_4() -> UInt32 { counterEmbeddedRegionFact(23, 4) }
@_cdecl("giftui_p08_layout_used_offset")
@inline(__always)
func counterEmbeddedFact24_0() -> UInt32 { counterEmbeddedRegionFact(24, 0) }
@_cdecl("giftui_p08_layout_used_count")
@inline(__always)
func counterEmbeddedFact24_1() -> UInt32 { counterEmbeddedRegionFact(24, 1) }
@_cdecl("giftui_p08_layout_used_size")
@inline(__always)
func counterEmbeddedFact24_2() -> UInt32 { counterEmbeddedRegionFact(24, 2) }
@_cdecl("giftui_p08_layout_used_stride")
@inline(__always)
func counterEmbeddedFact24_3() -> UInt32 { counterEmbeddedRegionFact(24, 3) }
@_cdecl("giftui_p08_layout_used_alignment")
@inline(__always)
func counterEmbeddedFact24_4() -> UInt32 { counterEmbeddedRegionFact(24, 4) }
@_cdecl("giftui_p08_layout_cursor")
@inline(__always)
func counterEmbeddedSummary0() -> UInt32 { counterEmbeddedSummaryFact(0) }
@_cdecl("giftui_p08_layout_maximumAlignment")
@inline(__always)
func counterEmbeddedSummary1() -> UInt32 { counterEmbeddedSummaryFact(1) }
@_cdecl("giftui_p08_layout_slotBytes")
@inline(__always)
func counterEmbeddedSummary2() -> UInt32 { counterEmbeddedSummaryFact(2) }
@_cdecl("giftui_p08_layout_totalBytes")
@inline(__always)
func counterEmbeddedSummary3() -> UInt32 { counterEmbeddedSummaryFact(3) }
#endif
