; ModuleID = '/Users/eugene/work/GiftUI/.build/rfc-014-swift64/resource-regression/003-nrf-layout/semantics/diagnostics-layout.ll'
source_filename = "/Users/eugene/work/GiftUI/.build/rfc-014-swift64/resource-regression/003-nrf-layout/semantics/diagnostics-layout.ll"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-none-eabihf"

%Ts5UInt8V = type <{ i8 }>
%Ts6UInt16V = type <{ i16 }>
%Ts6UInt32V = type <{ i32 }>
%TSi = type <{ i32 }>
%TSb = type <{ i1 }>
%swift.function = type { ptr, ptr }
%T35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV = type <{ %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V, %TSb }>
%T17GiftUIFailureCore0A18UIDiagnosticRecordV = type <{ %T17GiftUIFailureCore0A16UIDiagnosticKindO, %T17GiftUIFailureCore0A20UIDiagnosticSeverityO, %Ts6UInt16V, %T17GiftUIFailureCore0aB6OriginO, %T17GiftUIFailureCore0A15UIAffectedScopeO, %Ts6UInt16V, %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V }>
%T17GiftUIFailureCore0A16UIDiagnosticKindO = type <{ i8 }>
%T17GiftUIFailureCore0A20UIDiagnosticSeverityO = type <{ i8 }>
%T17GiftUIFailureCore0aB6OriginO = type <{ i8 }>
%T17GiftUIFailureCore0A15UIAffectedScopeO = type <{ i8 }>
%T17GiftUIFailureCore0A18UIDiagnosticRecordVSg = type <{ [24 x i8] }>
%T35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV = type <{ %Ts5UInt8V, [3 x i8], %Ts6UInt32V, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV }>
%TSvSg = type <{ [4 x i8] }>

@"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvpZ" = protected constant %Ts5UInt8V <{ i8 8 }>, align 1
@"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV11placeholder33_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpZ" = protected local_unnamed_addr constant <{ i8, i8, %Ts6UInt16V, i8, i8, %Ts6UInt16V, %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V }> zeroinitializer, align 4
@"$es16_emptyBoxStorageSi_Sitvp" = linkonce_odr protected global <{ %TSi, %TSi }> <{ %TSi zeroinitializer, %TSi <{ i32 -1 }> }>, align 4
@_swift_embedded_error_metadata_storage = weak_odr protected global <{ i32, i32, i32 }> zeroinitializer, align 4
@"$es25_errorMetadataInitialized33_21ED9D60359C2E63A6128CFAED697BD0LLSbvp" = linkonce_odr protected local_unnamed_addr global %TSb zeroinitializer, align 1
@"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvp" = linkonce_odr protected local_unnamed_addr global %swift.function { ptr @"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvpfiyBpcfU_", ptr null }, align 4
@_swift1_autolink_entries = private constant [0 x i8] zeroinitializer, section ".swift1_autolink_entries", no_sanitize_address, align 4
@llvm.used = appending global [2 x ptr] [ptr @_swift1_autolink_entries, ptr @_swift_exceptionPersonality], section "llvm.metadata"

@"$e35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV9selection0aB4Core0aF9SelectionVvg" = alias void (), ptr @_swift_dead_method_stub
@"$e35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV4sinkxvg" = alias void (), ptr @_swift_dead_method_stub
@"$e35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV8countersAA0aF16DeliveryCountersVvg" = alias void (), ptr @_swift_dead_method_stub
@"$e35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV9selection4sinkACyxG0aB4Core0aF9SelectionV_xtcfC" = alias void (), ptr @_swift_dead_method_stub
@"$e35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV7project4kind6origin8severity6recordy0aB4Core0aF4KindO_AI0aB6OriginOAI0aF8SeverityOAI0aF6RecordVyXEtF" = alias void (), ptr @_swift_dead_method_stub

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32Vvpfi"() local_unnamed_addr #0 {
entry:
  ret i32 0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) local_unnamed_addr #1 {
entry:
  %1 = load i32, ptr %0, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV7droppeds6UInt32Vvpfi"() local_unnamed_addr #0 {
entry:
  ret i32 0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV7droppeds6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) local_unnamed_addr #1 {
entry:
  %.dropped = getelementptr inbounds nuw i8, ptr %0, i32 4
  %1 = load i32, ptr %.dropped, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV9saturateds6UInt32Vvpfi"() local_unnamed_addr #0 {
entry:
  ret i32 0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV9saturateds6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) local_unnamed_addr #1 {
entry:
  %.saturated = getelementptr inbounds nuw i8, ptr %0, i32 8
  %1 = load i32, ptr %.saturated, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6faileds6UInt32Vvpfi"() local_unnamed_addr #0 {
entry:
  ret i32 0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6faileds6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) local_unnamed_addr #1 {
entry:
  %.failed = getelementptr inbounds nuw i8, ptr %0, i32 12
  %1 = load i32, ptr %.failed, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i1 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV17countersSaturatedSbvpfi"() local_unnamed_addr #0 {
entry:
  ret i1 false
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV17countersSaturatedSbvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) local_unnamed_addr #1 {
entry:
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %0, i32 16
  %1 = load i1, ptr %.countersSaturated, align 4
  ret i1 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVACycfC"(ptr noalias writeonly sret(%T35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV) captures(none) initializes((0, 17)) %0) local_unnamed_addr #2 {
entry:
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(17) %0, i8 0, i64 17, i1 false)
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i1 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepted7dropped9saturated6failed17countersSaturatedACs6UInt32V_A3JSbtcfcfA3_"() local_unnamed_addr #0 {
entry:
  ret i1 false
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepted7dropped9saturated6failed17countersSaturatedACs6UInt32V_A3JSbtcfC"(ptr noalias writeonly sret(%T35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV) captures(none) initializes((0, 17)) %0, i32 %1, i32 %2, i32 %3, i32 %4, i1 %5) local_unnamed_addr #2 {
entry:
  store i32 %1, ptr %0, align 4
  %.dropped = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %2, ptr %.dropped, align 4
  %.saturated = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %3, ptr %.saturated, align 4
  %.failed = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i32 %4, ptr %.failed, align 4
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %0, i32 16
  %6 = zext i1 %5 to i8
  store i8 %6, ptr %.countersSaturated, align 4
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6recordyy0aB4Core0aF10SinkResultOF"(i8 %0, ptr swiftself captures(none) dereferenceable(17) %1) local_unnamed_addr #3 {
entry:
  switch i8 %0, label %2 [
    i8 0, label %3
    i8 1, label %10
    i8 2, label %17
    i8 3, label %24
  ]

2:                                                ; preds = %entry
  unreachable

3:                                                ; preds = %entry
  %4 = load i32, ptr %1, align 4
  %.not13 = icmp eq i32 %4, -1
  br i1 %.not13, label %7, label %5

5:                                                ; preds = %3
  %6 = add nuw i32 %4, 1
  br label %8

7:                                                ; preds = %3
  %.countersSaturated6 = getelementptr inbounds nuw i8, ptr %1, i32 16
  store i8 1, ptr %.countersSaturated6, align 4
  br label %8

8:                                                ; preds = %5, %7
  %9 = phi i32 [ -1, %7 ], [ %6, %5 ]
  store i32 %9, ptr %1, align 4
  br label %31

10:                                               ; preds = %entry
  %.dropped = getelementptr inbounds nuw i8, ptr %1, i32 4
  %11 = load i32, ptr %.dropped, align 4
  %.not12 = icmp eq i32 %11, -1
  br i1 %.not12, label %14, label %12

12:                                               ; preds = %10
  %13 = add nuw i32 %11, 1
  br label %15

14:                                               ; preds = %10
  %.countersSaturated4 = getelementptr inbounds nuw i8, ptr %1, i32 16
  store i8 1, ptr %.countersSaturated4, align 4
  br label %15

15:                                               ; preds = %12, %14
  %16 = phi i32 [ -1, %14 ], [ %13, %12 ]
  store i32 %16, ptr %.dropped, align 4
  br label %31

17:                                               ; preds = %entry
  %.saturated = getelementptr inbounds nuw i8, ptr %1, i32 8
  %18 = load i32, ptr %.saturated, align 4
  %.not11 = icmp eq i32 %18, -1
  br i1 %.not11, label %21, label %19

19:                                               ; preds = %17
  %20 = add nuw i32 %18, 1
  br label %22

21:                                               ; preds = %17
  %.countersSaturated2 = getelementptr inbounds nuw i8, ptr %1, i32 16
  store i8 1, ptr %.countersSaturated2, align 4
  br label %22

22:                                               ; preds = %19, %21
  %23 = phi i32 [ -1, %21 ], [ %20, %19 ]
  store i32 %23, ptr %.saturated, align 4
  br label %31

24:                                               ; preds = %entry
  %.failed = getelementptr inbounds nuw i8, ptr %1, i32 12
  %25 = load i32, ptr %.failed, align 4
  %.not = icmp eq i32 %25, -1
  br i1 %.not, label %28, label %26

26:                                               ; preds = %24
  %27 = add nuw i32 %25, 1
  br label %29

28:                                               ; preds = %24
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %1, i32 16
  store i8 1, ptr %.countersSaturated, align 4
  br label %29

29:                                               ; preds = %26, %28
  %30 = phi i32 [ -1, %28 ], [ %27, %26 ]
  store i32 %30, ptr %.failed, align 4
  br label %31

31:                                               ; preds = %8, %15, %22, %29
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(17) %0, ptr noalias readonly captures(none) dereferenceable(17) %1) local_unnamed_addr #1 {
entry:
  %.sroa.022.0.copyload = load i32, ptr %0, align 4
  %.sroa.021.0.copyload = load i32, ptr %1, align 4
  %2 = icmp eq i32 %.sroa.022.0.copyload, %.sroa.021.0.copyload
  br i1 %2, label %3, label %15

3:                                                ; preds = %entry
  %.dropped = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.020.0.copyload = load i32, ptr %.dropped, align 4
  %.dropped3 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.019.0.copyload = load i32, ptr %.dropped3, align 4
  %4 = icmp eq i32 %.sroa.020.0.copyload, %.sroa.019.0.copyload
  br i1 %4, label %5, label %15

5:                                                ; preds = %3
  %.saturated = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.018.0.copyload = load i32, ptr %.saturated, align 4
  %.saturated6 = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.017.0.copyload = load i32, ptr %.saturated6, align 4
  %6 = icmp eq i32 %.sroa.018.0.copyload, %.sroa.017.0.copyload
  br i1 %6, label %7, label %15

7:                                                ; preds = %5
  %.failed = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.016.0.copyload = load i32, ptr %.failed, align 4
  %.failed9 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.0.0.copyload = load i32, ptr %.failed9, align 4
  %8 = icmp eq i32 %.sroa.016.0.copyload, %.sroa.0.0.copyload
  br i1 %8, label %9, label %15

9:                                                ; preds = %7
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %0, i32 16
  %10 = load i8, ptr %.countersSaturated, align 4
  %.countersSaturated12 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %11 = load i8, ptr %.countersSaturated12, align 4
  %12 = xor i8 %10, %11
  %13 = trunc i8 %12 to i1
  %14 = xor i1 %13, true
  br label %15

15:                                               ; preds = %entry, %3, %5, %7, %9
  %16 = phi i1 [ %14, %9 ], [ false, %7 ], [ false, %5 ], [ false, %3 ], [ false, %entry ]
  ret i1 %16
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #4

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i32(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i32, i1 immarg) #5

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #4

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV5counts5UInt8Vvpfi"() local_unnamed_addr #0 {
entry:
  ret i8 0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV5counts5UInt8Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(200) %0) local_unnamed_addr #1 {
entry:
  %1 = load i8, ptr %0, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCounts6UInt32Vvpfi"() local_unnamed_addr #0 {
entry:
  ret i32 0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCounts6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(200) %0) local_unnamed_addr #1 {
entry:
  %.droppedRecordCount = getelementptr inbounds nuw i8, ptr %0, i32 4
  %1 = load i32, ptr %.droppedRecordCount, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8Vvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 8
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) local_unnamed_addr #2 {
entry:
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(24) %0, i8 0, i64 24, i1 false)
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV5store33_481FAB364D938FDBB52660A85D053959LL_2aty0aB4Core0A18UIDiagnosticRecordV_s5UInt8VtF"(ptr noalias readonly captures(none) dereferenceable(24) %0, i8 %1, ptr swiftself writeonly captures(none) dereferenceable(200) %2) local_unnamed_addr #3 {
entry:
  %3 = icmp ult i8 %1, 8
  br i1 %3, label %switch.lookup, label %5

switch.lookup:                                    ; preds = %entry
  %narrow = mul nuw i8 %1, 24
  %switch.idx.mult = zext i8 %narrow to i32
  %4 = getelementptr inbounds nuw i8, ptr %2, i32 %switch.idx.mult
  %.record0 = getelementptr inbounds nuw i8, ptr %4, i32 8
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(24) %.record0, ptr noundef nonnull align 4 dereferenceable(24) %0, i32 24, i1 false)
  br label %5

5:                                                ; preds = %entry, %switch.lookup
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV12storedRecord33_481FAB364D938FDBB52660A85D053959LL2at0aB4Core0a12UIDiagnosticJ0VSgs5UInt8V_tF"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordVSg) captures(none) initializes((0, 24)) %0, i8 %1, ptr noalias readonly swiftself captures(none) dereferenceable(200) %2) local_unnamed_addr #3 {
entry:
  %3 = icmp ult i8 %1, 8
  br i1 %3, label %switch.lookup, label %10

switch.lookup:                                    ; preds = %entry
  %narrow = mul nuw i8 %1, 24
  %switch.idx.mult = zext i8 %narrow to i32
  %narrow68 = mul nuw i8 %1, 24
  %switch.idx.mult54 = zext i8 %narrow68 to i32
  %narrow69 = mul nuw i8 %1, 24
  %switch.idx.mult57 = zext i8 %narrow69 to i32
  %narrow70 = mul nuw i8 %1, 24
  %switch.idx.mult60 = zext i8 %narrow70 to i32
  %narrow71 = mul nuw i8 %1, 24
  %switch.idx.mult63 = zext i8 %narrow71 to i32
  %narrow72 = mul nuw i8 %1, 24
  %switch.idx.mult66 = zext i8 %narrow72 to i32
  %4 = getelementptr inbounds nuw i8, ptr %2, i32 %switch.idx.mult
  %.record0 = getelementptr inbounds nuw i8, ptr %4, i32 8
  %.sroa.0.0.copyload = load i32, ptr %.record0, align 4
  %5 = getelementptr inbounds nuw i8, ptr %2, i32 %switch.idx.mult54
  %.sroa.4.0..record0.sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 12
  %.sroa.4.0.copyload = load i32, ptr %.sroa.4.0..record0.sroa_idx, align 4
  %6 = getelementptr inbounds nuw i8, ptr %2, i32 %switch.idx.mult57
  %.sroa.5.0..record0.sroa_idx = getelementptr inbounds nuw i8, ptr %6, i32 16
  %.sroa.5.0.copyload = load i32, ptr %.sroa.5.0..record0.sroa_idx, align 4
  %7 = getelementptr inbounds nuw i8, ptr %2, i32 %switch.idx.mult60
  %.sroa.6.0..record0.sroa_idx = getelementptr inbounds nuw i8, ptr %7, i32 20
  %.sroa.6.0.copyload = load i32, ptr %.sroa.6.0..record0.sroa_idx, align 4
  %8 = getelementptr inbounds nuw i8, ptr %2, i32 %switch.idx.mult63
  %.sroa.7.0..record0.sroa_idx = getelementptr inbounds nuw i8, ptr %8, i32 24
  %.sroa.7.0.copyload = load i32, ptr %.sroa.7.0..record0.sroa_idx, align 4
  %9 = getelementptr inbounds nuw i8, ptr %2, i32 %switch.idx.mult66
  %.sroa.8.0..record0.sroa_idx = getelementptr inbounds nuw i8, ptr %9, i32 28
  %.sroa.8.0.copyload = load i32, ptr %.sroa.8.0..record0.sroa_idx, align 4
  br label %10

10:                                               ; preds = %entry, %switch.lookup
  %11 = phi i32 [ 4, %entry ], [ %.sroa.0.0.copyload, %switch.lookup ]
  %12 = phi i32 [ 0, %entry ], [ %.sroa.4.0.copyload, %switch.lookup ]
  %13 = phi i32 [ 0, %entry ], [ %.sroa.5.0.copyload, %switch.lookup ]
  %14 = phi i32 [ 0, %entry ], [ %.sroa.6.0.copyload, %switch.lookup ]
  %15 = phi i32 [ 0, %entry ], [ %.sroa.7.0.copyload, %switch.lookup ]
  %16 = phi i32 [ 0, %entry ], [ %.sroa.8.0.copyload, %switch.lookup ]
  store i32 %11, ptr %0, align 4
  %17 = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %12, ptr %17, align 4
  %18 = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %13, ptr %18, align 4
  %19 = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i32 %14, ptr %19, align 4
  %20 = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i32 %15, ptr %20, align 4
  %21 = getelementptr inbounds nuw i8, ptr %0, i32 20
  store i32 %16, ptr %21, align 4
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVACycfC"(ptr noalias writeonly sret(%T35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV) captures(none) initializes((0, 1), (4, 200)) %0) local_unnamed_addr #2 {
entry:
  store i8 0, ptr %0, align 4
  %.sroa.5.0..sroa_idx77 = getelementptr inbounds nuw i8, ptr %0, i32 4
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(196) %.sroa.5.0..sroa_idx77, i8 0, i64 196, i1 false)
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCountACs6UInt32V_tcfC"(ptr noalias writeonly sret(%T35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV) captures(none) initializes((0, 1), (4, 200)) %0, i32 %1) local_unnamed_addr #2 {
entry:
  store i8 0, ptr %0, align 4
  %.sroa.5.0..sroa_idx77 = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %1, ptr %.sroa.5.0..sroa_idx77, align 4
  %.sroa.6.0..sroa_idx78 = getelementptr inbounds nuw i8, ptr %0, i32 8
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(192) %.sroa.6.0..sroa_idx78, i8 0, i64 192, i1 false)
  ret void
}

; Function Attrs: minsize nounwind optsize memory(argmem: readwrite, inaccessiblemem: write)
define protected swiftcc range(i8 0, 3) i8 @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7consumey0aB4Core0A22UIDiagnosticSinkResultOAE0aK6RecordVF"(ptr noalias readonly captures(none) dereferenceable(24) %0, ptr swiftself captures(none) dereferenceable(200) %1) local_unnamed_addr #6 {
entry:
  %2 = load i8, ptr %1, align 4
  %3 = icmp ult i8 %2, 8
  br i1 %3, label %4, label %10

4:                                                ; preds = %entry
  tail call swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV5store33_481FAB364D938FDBB52660A85D053959LL_2aty0aB4Core0A18UIDiagnosticRecordV_s5UInt8VtF"(ptr noalias nonnull captures(none) dereferenceable(24) %0, i8 %2, ptr nonnull swiftself captures(none) dereferenceable(200) %1)
  %5 = load i8, ptr %1, align 4
  %6 = tail call { i8, i1 } @llvm.uadd.with.overflow.i8(i8 %5, i8 1)
  %7 = extractvalue { i8, i1 } %6, 1
  br i1 %7, label %16, label %8, !prof !6

8:                                                ; preds = %4
  %9 = extractvalue { i8, i1 } %6, 0
  store i8 %9, ptr %1, align 4
  br label %14

10:                                               ; preds = %entry
  %.droppedRecordCount = getelementptr inbounds nuw i8, ptr %1, i32 4
  %11 = load i32, ptr %.droppedRecordCount, align 4
  %.not = icmp eq i32 %11, -1
  br i1 %.not, label %14, label %12

12:                                               ; preds = %10
  %13 = add nuw i32 %11, 1
  store i32 %13, ptr %.droppedRecordCount, align 4
  br label %14

14:                                               ; preds = %12, %10, %8
  %15 = phi i8 [ 0, %8 ], [ 2, %10 ], [ 2, %12 ]
  ret i8 %15

16:                                               ; preds = %4
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i8, i1 } @llvm.uadd.with.overflow.i8(i8, i8) #7

; Function Attrs: cold noreturn nounwind memory(inaccessiblemem: write)
declare void @llvm.trap() #8

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVy0aB4Core0A18UIDiagnosticRecordVSgs5UInt8Vcig"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordVSg) captures(none) initializes((0, 24)) %0, i8 %1, ptr noalias readonly swiftself captures(none) dereferenceable(200) %2) local_unnamed_addr #3 {
entry:
  %3 = alloca %T17GiftUIFailureCore0A18UIDiagnosticRecordVSg, align 4
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %3)
  %.sroa.0.0.copyload = load i8, ptr %2, align 4
  %4 = icmp ult i8 %1, %.sroa.0.0.copyload
  br i1 %4, label %5, label %17

5:                                                ; preds = %entry
  call swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV12storedRecord33_481FAB364D938FDBB52660A85D053959LL2at0aB4Core0a12UIDiagnosticJ0VSgs5UInt8V_tF"(ptr noalias nonnull sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordVSg) captures(none) %3, i8 %1, ptr noalias nonnull swiftself captures(none) dereferenceable(200) %2)
  %6 = load i32, ptr %3, align 4
  %7 = getelementptr inbounds nuw i8, ptr %3, i32 4
  %8 = load i32, ptr %7, align 4
  %9 = getelementptr inbounds nuw i8, ptr %3, i32 8
  %10 = load i32, ptr %9, align 4
  %11 = getelementptr inbounds nuw i8, ptr %3, i32 12
  %12 = load i32, ptr %11, align 4
  %13 = getelementptr inbounds nuw i8, ptr %3, i32 16
  %14 = load i32, ptr %13, align 4
  %15 = getelementptr inbounds nuw i8, ptr %3, i32 20
  %16 = load i32, ptr %15, align 4
  br label %17

17:                                               ; preds = %entry, %5
  %18 = phi i32 [ %6, %5 ], [ 4, %entry ]
  %19 = phi i32 [ %8, %5 ], [ 0, %entry ]
  %20 = phi i32 [ %10, %5 ], [ 0, %entry ]
  %21 = phi i32 [ %12, %5 ], [ 0, %entry ]
  %22 = phi i32 [ %14, %5 ], [ 0, %entry ]
  %23 = phi i32 [ %16, %5 ], [ 0, %entry ]
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %3)
  store i32 %18, ptr %0, align 4
  %24 = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %19, ptr %24, align 4
  %25 = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %20, ptr %25, align 4
  %26 = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i32 %21, ptr %26, align 4
  %27 = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i32 %22, ptr %27, align 4
  %28 = getelementptr inbounds nuw i8, ptr %0, i32 20
  store i32 %23, ptr %28, align 4
  ret void
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e35GiftUIFailureDiagnosticsLayoutProbeAAO20deliveryCountersSizes6UInt32VyFZ"() local_unnamed_addr #9 {
entry:
  ret i32 17
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e35GiftUIFailureDiagnosticsLayoutProbeAAO22deliveryCountersStrides6UInt32VyFZ"() local_unnamed_addr #9 {
entry:
  ret i32 20
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e35GiftUIFailureDiagnosticsLayoutProbeAAO25deliveryCountersAlignments6UInt32VyFZ"() local_unnamed_addr #9 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e35GiftUIFailureDiagnosticsLayoutProbeAAO23diagnosticProjectorSizes6UInt32VyFZ"() local_unnamed_addr #9 {
entry:
  ret i32 225
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e35GiftUIFailureDiagnosticsLayoutProbeAAO25diagnosticProjectorStrides6UInt32VyFZ"() local_unnamed_addr #9 {
entry:
  ret i32 228
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e35GiftUIFailureDiagnosticsLayoutProbeAAO28diagnosticProjectorAlignments6UInt32VyFZ"() local_unnamed_addr #9 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e35GiftUIFailureDiagnosticsLayoutProbeAAO25fixedDiagnosticBufferSizes6UInt32VyFZ"() local_unnamed_addr #9 {
entry:
  ret i32 200
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e35GiftUIFailureDiagnosticsLayoutProbeAAO27fixedDiagnosticBufferStrides6UInt32VyFZ"() local_unnamed_addr #9 {
entry:
  ret i32 200
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e35GiftUIFailureDiagnosticsLayoutProbeAAO30fixedDiagnosticBufferAlignments6UInt32VyFZ"() local_unnamed_addr #9 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e35GiftUIFailureDiagnosticsLayoutProbeAAO29fixedDiagnosticBufferCapacitys5UInt8VyFZ"() local_unnamed_addr #9 {
entry:
  ret i8 8
}

; Function Attrs: minsize nounwind optsize sspreq
define weak_odr protected swiftcc { ptr, ptr } @swift_allocBox(ptr %0) local_unnamed_addr #10 {
entry:
  %1 = alloca %TSvSg, align 4
  %arrayidx.i.i = getelementptr inbounds i8, ptr %0, i32 -4
  %2 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !7
  %flags1.i.i = getelementptr inbounds nuw i8, ptr %2, i32 40
  %3 = load i32, ptr %flags1.i.i, align 4, !tbaa !12
  %and.i.i = and i32 %3, 255
  %size.i = getelementptr inbounds nuw i8, ptr %2, i32 32
  %4 = load i32, ptr %size.i, align 4, !tbaa !15
  %5 = add nuw nsw i32 %and.i.i, 8
  %6 = xor i32 %and.i.i, -1
  %7 = and i32 %5, %6
  %8 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %7, i32 %4)
  %9 = extractvalue { i32, i1 } %8, 1
  br i1 %9, label %23, label %10, !prof !6

10:                                               ; preds = %entry
  %11 = extractvalue { i32, i1 } %8, 0
  %12 = icmp samesign ult i32 %and.i.i, 4
  %13 = or i32 %and.i.i, 3
  %14 = add nuw nsw i32 %13, 1
  %. = select i1 %12, i32 4, i32 %14
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %1)
  store i32 0, ptr %1, align 4
  %15 = call i32 @posix_memalign(ptr nonnull %1, i32 %., i32 %11)
  %16 = load i32, ptr %1, align 4
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %1)
  %17 = icmp eq i32 %16, 0
  br i1 %17, label %24, label %18

18:                                               ; preds = %10
  %19 = inttoptr i32 %16 to ptr
  store ptr %0, ptr %19, align 4, !tbaa !16
  %.refcount = getelementptr inbounds nuw i8, ptr %19, i32 4
  store i32 1, ptr %.refcount, align 4
  %20 = getelementptr inbounds nuw i8, ptr %19, i32 %7
  %21 = insertvalue { ptr, ptr } undef, ptr %19, 0
  %22 = insertvalue { ptr, ptr } %21, ptr %20, 1
  ret { ptr, ptr } %22

23:                                               ; preds = %entry
  tail call void @llvm.trap() #18
  unreachable

24:                                               ; preds = %10
  call void @llvm.trap() #18
  unreachable
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32) #7

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.ssub.with.overflow.i32(i32, i32) #7

; Function Attrs: minsize nofree nounwind optsize
declare i32 @posix_memalign(ptr, i32, i32) local_unnamed_addr #11

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc { ptr, ptr } @swift_makeBoxUnique(ptr %0, ptr %1, i32 %2) local_unnamed_addr #12 {
entry:
  %3 = load ptr, ptr %0, align 4
  %4 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %2, i32 8)
  %5 = extractvalue { i32, i1 } %4, 1
  br i1 %5, label %27, label %6, !prof !6

6:                                                ; preds = %entry
  %7 = extractvalue { i32, i1 } %4, 0
  %8 = xor i32 %2, -1
  %9 = and i32 %7, %8
  %10 = getelementptr inbounds i8, ptr %3, i32 %9
  %11 = icmp eq ptr %3, null
  br i1 %11, label %16, label %12

12:                                               ; preds = %6
  %13 = getelementptr inbounds nuw i8, ptr %3, i32 4
  %14 = load atomic i32, ptr %13 acquire, align 4
  %15 = icmp eq i32 %14, 1
  br i1 %15, label %22, label %16

16:                                               ; preds = %6, %12
  %17 = tail call swiftcc { ptr, ptr } @swift_allocBox(ptr %1)
  %18 = extractvalue { ptr, ptr } %17, 0
  %19 = extractvalue { ptr, ptr } %17, 1
  %arrayidx.i.i = getelementptr inbounds i8, ptr %1, i32 -4
  %20 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !7
  %initializeWithCopyFn.i = getelementptr inbounds nuw i8, ptr %20, i32 8
  %21 = load ptr, ptr %initializeWithCopyFn.i, align 4, !tbaa !18
  %call1.i = tail call ptr %21(ptr noundef %19, ptr noundef %10, ptr noundef %1) #19
  tail call void @swift_releaseBox(ptr %3)
  store ptr %18, ptr %0, align 4
  br label %22

22:                                               ; preds = %12, %16
  %23 = phi ptr [ %18, %16 ], [ %3, %12 ]
  %24 = phi ptr [ %19, %16 ], [ %10, %12 ]
  %25 = insertvalue { ptr, ptr } undef, ptr %23, 0
  %26 = insertvalue { ptr, ptr } %25, ptr %24, 1
  ret { ptr, ptr } %26

27:                                               ; preds = %entry
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden void @swift_releaseBox(ptr %0) local_unnamed_addr #12 {
entry:
  %1 = icmp eq ptr %0, null
  br i1 %1, label %22, label %2, !prof !6

2:                                                ; preds = %entry
  %3 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %4 = load atomic i32, ptr %3 monotonic, align 4
  %5 = and i32 %4, 2147483647
  %6 = icmp eq i32 %5, 2147483647
  br i1 %6, label %21, label %7

7:                                                ; preds = %2
  %8 = atomicrmw sub ptr %3, i32 1 acq_rel, align 4
  %9 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %8, i32 -1)
  %10 = extractvalue { i32, i1 } %9, 1
  br i1 %10, label %23, label %11, !prof !6

11:                                               ; preds = %7
  %12 = extractvalue { i32, i1 } %9, 0
  %13 = and i32 %12, 2147483647
  %14 = icmp eq i32 %13, 0
  br i1 %14, label %15, label %21

15:                                               ; preds = %11
  %16 = or i32 %4, 2147483647
  store atomic i32 %16, ptr %3 monotonic, align 4
  %17 = load ptr, ptr %0, align 4, !tbaa !16
  %arrayidx.i.i = getelementptr inbounds i8, ptr %17, i32 -4
  %18 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !7
  %flags1.i.i.i = getelementptr inbounds nuw i8, ptr %18, i32 40
  %19 = load i32, ptr %flags1.i.i.i, align 4, !tbaa !12
  %and.i.i.i = and i32 %19, 255
  %add.i.i = add nuw nsw i32 %and.i.i.i, 8
  %not.i.i = xor i32 %and.i.i.i, -1
  %and.i.i = and i32 %add.i.i, %not.i.i
  %add.ptr.i.i = getelementptr inbounds nuw i8, ptr %0, i32 %and.i.i
  %destroyFn.i = getelementptr inbounds nuw i8, ptr %18, i32 4
  %20 = load ptr, ptr %destroyFn.i, align 4, !tbaa !19
  tail call void %20(ptr noundef nonnull %add.ptr.i.i, ptr noundef %17) #19
  br label %21

21:                                               ; preds = %11, %2, %15
  ret void

22:                                               ; preds = %entry
  tail call void @llvm.trap() #18
  unreachable

23:                                               ; preds = %7
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocBox(ptr %0) local_unnamed_addr #12 {
entry:
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize mustprogress nounwind optsize willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr noundef captures(none)) local_unnamed_addr #13

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_allocEmptyBox() local_unnamed_addr #12 {
entry:
  %0 = load atomic i32, ptr getelementptr inbounds nuw (i8, ptr @"$es16_emptyBoxStorageSi_Sitvp", i32 4) monotonic, align 4
  %1 = and i32 %0, 2147483647
  %2 = icmp eq i32 %1, 2147483647
  br i1 %2, label %5, label %3

3:                                                ; preds = %entry
  %4 = atomicrmw add ptr getelementptr inbounds nuw (i8, ptr @"$es16_emptyBoxStorageSi_Sitvp", i32 4), i32 1 monotonic, align 4
  br label %5

5:                                                ; preds = %entry, %3
  ret ptr @"$es16_emptyBoxStorageSi_Sitvp"
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_allocObject(ptr %0, i32 %1, i32 %2) local_unnamed_addr #12 {
entry:
  %3 = tail call swiftcc ptr @"$es17swift_allocObject8metadata12requiredSize0E13AlignmentMaskSpys04HeapC0VGSpys13ClassMetadataVG_S2itF"(ptr %0, i32 %1, i32 %2)
  ret ptr %3
}

; Function Attrs: minsize nounwind optsize sspreq
define linkonce_odr hidden swiftcc ptr @"$es17swift_allocObject8metadata12requiredSize0E13AlignmentMaskSpys04HeapC0VGSpys13ClassMetadataVG_S2itF"(ptr %0, i32 %1, i32 %2) local_unnamed_addr #10 {
entry:
  %3 = alloca %TSvSg, align 4
  %4 = icmp eq i32 %2, -1
  br i1 %4, label %10, label %5

5:                                                ; preds = %entry
  %6 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %2, i32 1)
  %7 = extractvalue { i32, i1 } %6, 1
  br i1 %7, label %17, label %8, !prof !6

8:                                                ; preds = %5
  %9 = extractvalue { i32, i1 } %6, 0
  %. = tail call i32 @llvm.smax.i32(i32 %9, i32 4)
  br label %10

10:                                               ; preds = %entry, %8
  %11 = phi i32 [ %., %8 ], [ 16, %entry ]
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %3)
  store i32 0, ptr %3, align 4
  %12 = call i32 @posix_memalign(ptr nonnull %3, i32 %11, i32 %1)
  %13 = load i32, ptr %3, align 4
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %3)
  %14 = icmp eq i32 %13, 0
  br i1 %14, label %18, label %15

15:                                               ; preds = %10
  %16 = inttoptr i32 %13 to ptr
  store ptr %0, ptr %16, align 4, !tbaa !16
  %.refcount = getelementptr inbounds nuw i8, ptr %16, i32 4
  store i32 1, ptr %.refcount, align 4
  ret ptr %16

17:                                               ; preds = %5
  tail call void @llvm.trap() #18
  unreachable

18:                                               ; preds = %10
  call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_allocObjectTyped(ptr %0, i32 %1, i32 %2, i64 %3) local_unnamed_addr #12 {
entry:
  %4 = tail call swiftcc ptr @"$es17swift_allocObject8metadata12requiredSize0E13AlignmentMaskSpys04HeapC0VGSpys13ClassMetadataVG_S2itF"(ptr %0, i32 %1, i32 %2)
  ret ptr %4
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_initStackObject(ptr %0, ptr %1) local_unnamed_addr #12 {
entry:
  store ptr %0, ptr %1, align 4, !tbaa !16
  %.refcount = getelementptr inbounds nuw i8, ptr %1, i32 4
  store i32 -2147483647, ptr %.refcount, align 4
  ret ptr %1
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_initStaticObject(ptr %0, ptr %1) local_unnamed_addr #12 {
entry:
  store ptr %0, ptr %1, align 4, !tbaa !16
  %.refcount = getelementptr inbounds nuw i8, ptr %1, i32 4
  store i32 -1, ptr %.refcount, align 4
  ret ptr %1
}

; Function Attrs: minsize nounwind optsize
define private void @0(ptr %0, i32 %1, i32 %2) local_unnamed_addr #12 {
entry:
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocClassInstance(ptr %0, i32 %1, i32 %2) local_unnamed_addr #12 {
entry:
  %.refcount = getelementptr inbounds nuw i8, ptr %0, i32 4
  %3 = load i32, ptr %.refcount, align 4
  %.not = icmp sgt i32 %3, -1
  br i1 %.not, label %4, label %5

4:                                                ; preds = %entry
  tail call void @free(ptr nonnull %0)
  br label %5

5:                                                ; preds = %entry, %4
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocPartialClassInstance(ptr %0, ptr %1, i32 %2, i32 %3) local_unnamed_addr #12 {
entry:
  %4 = load ptr, ptr %0, align 4, !tbaa !16
  br label %5

5:                                                ; preds = %11, %entry
  %6 = phi ptr [ %4, %entry ], [ %12, %11 ]
  %.not = icmp eq ptr %6, %1
  br i1 %.not, label %13, label %7

7:                                                ; preds = %5
  %arrayidx.i = getelementptr inbounds nuw i8, ptr %6, i32 8
  %8 = load ptr, ptr %arrayidx.i, align 4, !tbaa !20
  %tobool.not.i = icmp eq ptr %8, null
  br i1 %tobool.not.i, label %_swift_embedded_invoke_heap_object_optional_ivardestroyer.exit, label %if.then.i

if.then.i:                                        ; preds = %7
  tail call swiftcc void %8(ptr noundef nonnull swiftself %0) #19
  br label %_swift_embedded_invoke_heap_object_optional_ivardestroyer.exit

_swift_embedded_invoke_heap_object_optional_ivardestroyer.exit: ; preds = %7, %if.then.i
  %9 = load i32, ptr %6, align 4
  %10 = icmp eq i32 %9, 0
  br i1 %10, label %13, label %11

11:                                               ; preds = %_swift_embedded_invoke_heap_object_optional_ivardestroyer.exit
  %12 = inttoptr i32 %9 to ptr
  br label %5

13:                                               ; preds = %_swift_embedded_invoke_heap_object_optional_ivardestroyer.exit, %5
  ret void
}

; Function Attrs: minsize nounwind optsize sspreq
define weak_odr protected ptr @swift_slowAlloc(i32 %0, i32 %1) local_unnamed_addr #10 {
entry:
  %2 = alloca %TSvSg, align 4
  %3 = icmp eq i32 %1, -1
  br i1 %3, label %9, label %4

4:                                                ; preds = %entry
  %5 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %1, i32 1)
  %6 = extractvalue { i32, i1 } %5, 1
  br i1 %6, label %14, label %7, !prof !6

7:                                                ; preds = %4
  %8 = extractvalue { i32, i1 } %5, 0
  %. = tail call i32 @llvm.smax.i32(i32 %8, i32 4)
  br label %9

9:                                                ; preds = %entry, %7
  %10 = phi i32 [ %., %7 ], [ 16, %entry ]
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %2)
  store i32 0, ptr %2, align 4
  %11 = call i32 @posix_memalign(ptr nonnull %2, i32 %10, i32 %0)
  %12 = load i32, ptr %2, align 4
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %2)
  %13 = inttoptr i32 %12 to ptr
  ret ptr %13

14:                                               ; preds = %4
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc void @swift_willThrow(ptr swiftself %0, ptr noalias swifterror captures(none) dereferenceable(4) %1) local_unnamed_addr #12 {
entry:
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc void @swift_errorInMain(ptr %0) local_unnamed_addr #12 {
entry:
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc void @swift_unexpectedError(ptr %0, ptr %1, i32 %2, i1 %3, i32 %4) local_unnamed_addr #12 {
entry:
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_release_n(ptr %0, i32 %1) local_unnamed_addr #12 {
entry:
  %2 = icmp eq ptr %0, null
  br i1 %2, label %22, label %3

3:                                                ; preds = %entry
  %4 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %5 = load atomic i32, ptr %4 monotonic, align 4
  %6 = and i32 %5, 2147483647
  %7 = icmp eq i32 %6, 2147483647
  br i1 %7, label %22, label %8

8:                                                ; preds = %3
  %9 = icmp slt i32 %1, 0
  br i1 %9, label %23, label %10, !prof !6

10:                                               ; preds = %8
  %11 = atomicrmw sub ptr %4, i32 %1 acq_rel, align 4
  %12 = tail call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 %11, i32 %1)
  %13 = extractvalue { i32, i1 } %12, 1
  br i1 %13, label %24, label %14, !prof !6

14:                                               ; preds = %10
  %15 = extractvalue { i32, i1 } %12, 0
  %16 = and i32 %15, 2147483647
  %17 = icmp eq i32 %16, 0
  br i1 %17, label %18, label %22

18:                                               ; preds = %14
  %19 = or i32 %5, 2147483647
  store atomic i32 %19, ptr %4 monotonic, align 4
  %20 = load ptr, ptr %0, align 4, !tbaa !16
  %arrayidx.i = getelementptr inbounds nuw i8, ptr %20, i32 4
  %21 = load ptr, ptr %arrayidx.i, align 4, !tbaa !20
  tail call swiftcc void %21(ptr noundef nonnull swiftself %0) #19
  br label %22

22:                                               ; preds = %14, %entry, %3, %18
  ret void

23:                                               ; preds = %8
  tail call void @llvm.trap() #18
  unreachable

24:                                               ; preds = %10
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_setDeallocating(ptr %0) local_unnamed_addr #12 {
entry:
  ret void
}

; Function Attrs: minsize nounwind optsize
define private ptr @1(ptr %0, i32 %1) local_unnamed_addr #12 {
entry:
  %2 = icmp eq ptr %0, null
  br i1 %2, label %12, label %3

3:                                                ; preds = %entry
  %4 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %5 = load atomic i32, ptr %4 monotonic, align 4
  %6 = and i32 %5, 2147483647
  %7 = icmp eq i32 %6, 2147483647
  br i1 %7, label %12, label %8

8:                                                ; preds = %3
  %9 = icmp slt i32 %1, 0
  br i1 %9, label %13, label %10, !prof !6

10:                                               ; preds = %8
  %11 = atomicrmw add ptr %4, i32 %1 monotonic, align 4
  br label %12

12:                                               ; preds = %entry, %3, %10
  ret ptr %0

13:                                               ; preds = %8
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_bridgeObjectRelease_n(ptr %0, i32 %1) local_unnamed_addr #12 {
entry:
  tail call void @swift_release_n(ptr %0, i32 %1)
  ret void
}

; Function Attrs: minsize nounwind optsize
define private ptr @2(ptr %0) local_unnamed_addr #12 {
entry:
  %1 = icmp eq ptr %0, null
  br i1 %1, label %9, label %2

2:                                                ; preds = %entry
  %3 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %4 = load atomic i32, ptr %3 monotonic, align 4
  %5 = and i32 %4, 2147483647
  %6 = icmp eq i32 %5, 2147483647
  br i1 %6, label %9, label %7

7:                                                ; preds = %2
  %8 = atomicrmw add ptr %3, i32 1 monotonic, align 4
  br label %9

9:                                                ; preds = %entry, %2, %7
  ret ptr %0
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_bridgeObjectRelease(ptr %0) local_unnamed_addr #12 {
entry:
  tail call void @swift_release_n(ptr %0, i32 1)
  ret void
}

; Function Attrs: minsize nounwind optsize
define private void @3(ptr %0) local_unnamed_addr #12 {
  tail call void @swift_releaseTm(ptr %0) #12
  ret void
}

; Function Attrs: minsize nounwind optsize
define internal void @swift_releaseTm(ptr %0) local_unnamed_addr #12 {
entry:
  %1 = icmp eq ptr %0, null
  br i1 %1, label %19, label %2

2:                                                ; preds = %entry
  %3 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %4 = load atomic i32, ptr %3 monotonic, align 4
  %5 = and i32 %4, 2147483647
  %6 = icmp eq i32 %5, 2147483647
  br i1 %6, label %19, label %7

7:                                                ; preds = %2
  %8 = atomicrmw sub ptr %3, i32 1 acq_rel, align 4
  %9 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %8, i32 -1)
  %10 = extractvalue { i32, i1 } %9, 1
  br i1 %10, label %20, label %11, !prof !6

11:                                               ; preds = %7
  %12 = extractvalue { i32, i1 } %9, 0
  %13 = and i32 %12, 2147483647
  %14 = icmp eq i32 %13, 0
  br i1 %14, label %15, label %19

15:                                               ; preds = %11
  %16 = or i32 %4, 2147483647
  store atomic i32 %16, ptr %3 monotonic, align 4
  %17 = load ptr, ptr %0, align 4, !tbaa !16
  %arrayidx.i = getelementptr inbounds nuw i8, ptr %17, i32 4
  %18 = load ptr, ptr %arrayidx.i, align 4, !tbaa !20
  tail call swiftcc void %18(ptr noundef nonnull swiftself %0) #19
  br label %19

19:                                               ; preds = %11, %entry, %2, %15
  ret void

20:                                               ; preds = %7
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected zeroext i1 @swift_isUniquelyReferenced_native(ptr %0) local_unnamed_addr #12 {
entry:
  %1 = icmp eq ptr %0, null
  br i1 %1, label %6, label %2

2:                                                ; preds = %entry
  %3 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %4 = load atomic i32, ptr %3 acquire, align 4
  %5 = icmp eq i32 %4, 1
  br label %6

6:                                                ; preds = %entry, %2
  %7 = phi i1 [ %5, %2 ], [ false, %entry ]
  ret i1 %7
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected zeroext i1 @swift_isUniquelyReferenced_nonNull_native(ptr %0) local_unnamed_addr #12 {
entry:
  %1 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %2 = load atomic i32, ptr %1 acquire, align 4
  %3 = icmp eq i32 %2, 1
  ret i1 %3
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected zeroext i1 @swift_isEscapingClosureAtFileLocation(ptr %0, ptr %1, i32 %2, i32 %3, i32 %4, i32 %5) local_unnamed_addr #12 {
entry:
  %6 = icmp eq ptr %0, null
  br i1 %6, label %10, label %7

7:                                                ; preds = %entry
  %8 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %9 = load atomic i32, ptr %8 acquire, align 4
  %.not = icmp eq i32 %9, 1
  br i1 %.not, label %10, label %11, !prof !21

10:                                               ; preds = %entry, %7
  ret i1 false

11:                                               ; preds = %7
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_dynamicCastClass(ptr %0, ptr %1) local_unnamed_addr #12 {
entry:
  %2 = load ptr, ptr %0, align 4, !tbaa !16
  br label %3

3:                                                ; preds = %8, %entry
  %4 = phi ptr [ %2, %entry ], [ %9, %8 ]
  %.not = icmp eq ptr %4, %1
  br i1 %.not, label %10, label %5

5:                                                ; preds = %3
  %6 = load i32, ptr %4, align 4
  %7 = icmp eq i32 %6, 0
  br i1 %7, label %10, label %8

8:                                                ; preds = %5
  %9 = inttoptr i32 %6 to ptr
  br label %3

10:                                               ; preds = %3, %5
  %11 = phi ptr [ null, %5 ], [ %0, %3 ]
  ret ptr %11
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_dynamicCastClassUnconditional(ptr %0, ptr %1, ptr %2, i32 %3, i32 %4) local_unnamed_addr #12 {
entry:
  %5 = load ptr, ptr %0, align 4, !tbaa !16
  br label %6

6:                                                ; preds = %12, %entry
  %7 = phi ptr [ %5, %entry ], [ %13, %12 ]
  %.not = icmp eq ptr %7, %1
  br i1 %.not, label %8, label %9

8:                                                ; preds = %6
  ret ptr %0

9:                                                ; preds = %6
  %10 = load i32, ptr %7, align 4
  %11 = icmp eq i32 %10, 0
  br i1 %11, label %14, label %12

12:                                               ; preds = %9
  %13 = inttoptr i32 %10 to ptr
  br label %6

14:                                               ; preds = %9
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected zeroext i1 @swift_dynamicCast(ptr %0, ptr %1, ptr %2, ptr %3, i32 %4) local_unnamed_addr #12 {
entry:
  %5 = and i32 %4, 2
  %6 = icmp ne i32 %5, 0
  %7 = tail call swiftcc i8 @"$es7tryCast33_8BFEAB69C69C8B87ED137407D82370D4LL3dst0J8Metadata3src0lK013takeOnSuccesss07DynamicB6ResultABLLOSv_S3VSbtF"(ptr %0, ptr %3, ptr %1, ptr %2, i1 %6)
  switch i8 %7, label %8 [
    i8 0, label %10
    i8 1, label %9
    i8 2, label %16
  ]

8:                                                ; preds = %entry
  unreachable

9:                                                ; preds = %entry
  br i1 %6, label %.sink.split, label %16

10:                                               ; preds = %entry
  %11 = and i32 %4, 1
  %.not = icmp eq i32 %11, 0
  br i1 %.not, label %12, label %18, !prof !21

12:                                               ; preds = %10
  %13 = and i32 %4, 4
  %.not1 = icmp eq i32 %13, 0
  br i1 %.not1, label %16, label %.sink.split

.sink.split:                                      ; preds = %12, %9
  %.ph = phi i1 [ true, %9 ], [ false, %12 ]
  %arrayidx.i.i2 = getelementptr inbounds i8, ptr %2, i32 -4
  %14 = load ptr, ptr %arrayidx.i.i2, align 4, !tbaa !7
  %destroyFn.i3 = getelementptr inbounds nuw i8, ptr %14, i32 4
  %15 = load ptr, ptr %destroyFn.i3, align 4, !tbaa !19
  tail call void %15(ptr noundef %1, ptr noundef %2) #19
  br label %16

16:                                               ; preds = %.sink.split, %12, %9, %entry
  %17 = phi i1 [ true, %entry ], [ true, %9 ], [ false, %12 ], [ %.ph, %.sink.split ]
  ret i1 %17

18:                                               ; preds = %10
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc i8 @"$es7tryCast33_8BFEAB69C69C8B87ED137407D82370D4LL3dst0J8Metadata3src0lK013takeOnSuccesss07DynamicB6ResultABLLOSv_S3VSbtF"(ptr %0, ptr %1, ptr %2, ptr %3, i1 %4) local_unnamed_addr #12 {
entry:
  br label %tailrecurse

tailrecurse:                                      ; preds = %31, %entry
  %.tr10 = phi ptr [ %2, %entry ], [ %34, %31 ]
  %.tr11 = phi ptr [ %3, %entry ], [ %33, %31 ]
  %.tr12 = phi i1 [ %4, %entry ], [ %36, %31 ]
  %5 = icmp eq ptr %.tr11, %1
  br i1 %5, label %37, label %6

6:                                                ; preds = %tailrecurse
  %7 = tail call swiftcc i8 @"$es12MetadataKindO8metadataABSgSV_tcfC"(ptr %.tr11)
  switch i8 %7, label %31 [
    i8 6, label %.loopexit
    i8 3, label %8
    i8 4, label %.loopexit
    i8 5, label %.loopexit
  ]

8:                                                ; preds = %6
  %9 = tail call swiftcc i8 @"$es12MetadataKindO8metadataABSgSV_tcfC"(ptr %1)
  %10 = icmp eq i8 %9, 6
  br i1 %10, label %.loopexit, label %11

11:                                               ; preds = %8
  %12 = tail call swiftcc i1 @"$es12MetadataKindO21__derived_enum_equalsySbAB_ABtFZ"(i8 %9, i8 3)
  br i1 %12, label %13, label %.loopexit

13:                                               ; preds = %11
  %14 = load ptr, ptr %.tr10, align 4
  %15 = load ptr, ptr %14, align 4, !tbaa !16
  br label %16

16:                                               ; preds = %29, %13
  %17 = phi ptr [ %15, %13 ], [ %30, %29 ]
  %.not = icmp eq ptr %17, %1
  br i1 %.not, label %18, label %26

18:                                               ; preds = %16
  store ptr %14, ptr %0, align 4
  br i1 %.tr12, label %.loopexit, label %19

19:                                               ; preds = %18
  %20 = getelementptr inbounds nuw i8, ptr %14, i32 4
  %21 = load atomic i32, ptr %20 monotonic, align 4
  %22 = and i32 %21, 2147483647
  %23 = icmp eq i32 %22, 2147483647
  br i1 %23, label %.loopexit, label %24

24:                                               ; preds = %19
  %25 = atomicrmw add ptr %20, i32 1 monotonic, align 4
  br label %.loopexit

26:                                               ; preds = %16
  %27 = load i32, ptr %17, align 4
  %28 = icmp eq i32 %27, 0
  br i1 %28, label %.loopexit, label %29

29:                                               ; preds = %26
  %30 = inttoptr i32 %27 to ptr
  br label %16

31:                                               ; preds = %6
  %32 = tail call swiftcc { ptr, ptr } @"$es29ExistentialTypeRepresentationO7projectySV8metadata_SV5valuetSVF"(ptr %.tr10, i8 %7)
  %33 = extractvalue { ptr, ptr } %32, 0
  %34 = extractvalue { ptr, ptr } %32, 1
  %35 = icmp eq ptr %.tr10, %34
  %36 = select i1 %.tr12, i1 %35, i1 false
  br label %tailrecurse

37:                                               ; preds = %tailrecurse
  %arrayidx.i.i7 = getelementptr inbounds i8, ptr %.tr11, i32 -4
  %38 = load ptr, ptr %arrayidx.i.i7, align 4, !tbaa !7
  br i1 %.tr12, label %41, label %39

39:                                               ; preds = %37
  %initializeWithCopyFn.i = getelementptr inbounds nuw i8, ptr %38, i32 8
  %40 = load ptr, ptr %initializeWithCopyFn.i, align 4, !tbaa !18
  %call1.i = tail call ptr %40(ptr noundef %0, ptr noundef %.tr10, ptr noundef %.tr11) #19
  br label %.loopexit

41:                                               ; preds = %37
  %initializeWithTakeFn.i = getelementptr inbounds nuw i8, ptr %38, i32 16
  %42 = load ptr, ptr %initializeWithTakeFn.i, align 4, !tbaa !22
  %call1.i8 = tail call ptr %42(ptr noundef %0, ptr noundef %.tr10, ptr noundef %.tr11) #19
  br label %.loopexit

.loopexit:                                        ; preds = %6, %6, %6, %26, %18, %24, %19, %8, %11, %41, %39
  %43 = phi i8 [ 1, %39 ], [ 2, %41 ], [ 0, %11 ], [ 0, %8 ], [ 1, %19 ], [ 1, %24 ], [ 2, %18 ], [ 0, %26 ], [ 0, %6 ], [ 0, %6 ], [ 0, %6 ]
  ret i8 %43
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc i8 @"$es12MetadataKindO8metadataABSgSV_tcfC"(ptr %0) local_unnamed_addr #12 {
entry:
  %1 = load i32, ptr %0, align 4
  switch i32 %1, label %2 [
    i32 0, label %11
    i32 512, label %10
    i32 513, label %switch.lookup
    i32 771, label %4
  ]

2:                                                ; preds = %entry
  %3 = icmp ugt i32 %1, 2047
  br i1 %3, label %switch.lookup, label %9

4:                                                ; preds = %entry
  %5 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %6 = load i32, ptr %5, align 4
  %7 = trunc nuw i32 %6 to i8
  %8 = icmp ult i32 %6, 3
  br i1 %8, label %switch.lookup, label %9

9:                                                ; preds = %4, %2
  br label %switch.lookup

10:                                               ; preds = %entry
  br label %switch.lookup

11:                                               ; preds = %entry
  br label %switch.lookup

switch.lookup:                                    ; preds = %4, %entry, %2, %11, %10, %9
  %12 = phi i8 [ 6, %9 ], [ 4, %10 ], [ 3, %11 ], [ 3, %2 ], [ 5, %entry ], [ %7, %4 ]
  ret i8 %12
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc i1 @"$es12MetadataKindO21__derived_enum_equalsySbAB_ABtFZ"(i8 %0, i8 %1) local_unnamed_addr #12 {
entry:
  switch i8 %0, label %2 [
    i8 3, label %7
    i8 4, label %6
    i8 5, label %5
  ]

2:                                                ; preds = %entry
  %.off = add i8 %1, -3
  %switch = icmp ult i8 %.off, 3
  br i1 %switch, label %8, label %3

3:                                                ; preds = %2
  %4 = icmp eq i8 %0, %1
  br label %9

5:                                                ; preds = %entry
  %cond = icmp eq i8 %1, 5
  br i1 %cond, label %9, label %8

6:                                                ; preds = %entry
  %cond1 = icmp eq i8 %1, 4
  br i1 %cond1, label %9, label %8

7:                                                ; preds = %entry
  %cond2 = icmp eq i8 %1, 3
  br i1 %cond2, label %9, label %8

8:                                                ; preds = %2, %7, %6, %5
  br label %9

9:                                                ; preds = %7, %6, %5, %3, %8
  %10 = phi i1 [ false, %8 ], [ %4, %3 ], [ true, %5 ], [ true, %6 ], [ true, %7 ]
  ret i1 %10
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc { ptr, ptr } @"$es29ExistentialTypeRepresentationO7projectySV8metadata_SV5valuetSVF"(ptr %0, i8 %1) local_unnamed_addr #12 {
entry:
  switch i8 %1, label %2 [
    i8 0, label %16
    i8 1, label %13
    i8 2, label %3
  ]

2:                                                ; preds = %entry
  unreachable

3:                                                ; preds = %entry
  %4 = load ptr, ptr %0, align 4
  %5 = getelementptr inbounds nuw i8, ptr %4, i32 8
  %6 = load ptr, ptr %5, align 4
  %arrayidx.i.i = getelementptr inbounds i8, ptr %6, i32 -4
  %7 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !7
  %flags1.i.i = getelementptr inbounds nuw i8, ptr %7, i32 40
  %8 = load i32, ptr %flags1.i.i, align 4, !tbaa !12
  %and.i.i = and i32 %8, 255
  %9 = add nuw nsw i32 %and.i.i, 16
  %10 = xor i32 %and.i.i, -1
  %11 = and i32 %9, %10
  %12 = getelementptr inbounds nuw i8, ptr %4, i32 %11
  br label %28

13:                                               ; preds = %entry
  %14 = load ptr, ptr %0, align 4
  %15 = load ptr, ptr %14, align 4
  br label %28

16:                                               ; preds = %entry
  %17 = getelementptr inbounds nuw i8, ptr %0, i32 12
  %18 = load ptr, ptr %17, align 4
  %arrayidx.i.i7 = getelementptr inbounds i8, ptr %18, i32 -4
  %19 = load ptr, ptr %arrayidx.i.i7, align 4, !tbaa !7
  %flags.i = getelementptr inbounds nuw i8, ptr %19, i32 40
  %20 = load i32, ptr %flags.i, align 4, !tbaa !12
  %21 = and i32 %20, 131072
  %.not = icmp eq i32 %21, 0
  br i1 %.not, label %28, label %22

22:                                               ; preds = %16
  %23 = load ptr, ptr %0, align 4
  %and.i.i10 = and i32 %20, 255
  %24 = add nuw nsw i32 %and.i.i10, 8
  %25 = xor i32 %and.i.i10, -1
  %26 = and i32 %24, %25
  %27 = getelementptr inbounds nuw i8, ptr %23, i32 %26
  br label %28

28:                                               ; preds = %16, %22, %13, %3
  %29 = phi ptr [ %6, %3 ], [ %15, %13 ], [ %18, %22 ], [ %18, %16 ]
  %30 = phi ptr [ %12, %3 ], [ %14, %13 ], [ %27, %22 ], [ %0, %16 ]
  %31 = insertvalue { ptr, ptr } undef, ptr %29, 0
  %32 = insertvalue { ptr, ptr } %31, ptr %30, 1
  ret { ptr, ptr } %32
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_once(ptr %0, ptr %1, ptr %2) local_unnamed_addr #12 {
entry:
  %3 = load atomic i32, ptr %0 acquire, align 4
  %4 = icmp slt i32 %3, 0
  br i1 %4, label %.loopexit, label %5

5:                                                ; preds = %entry
  %6 = cmpxchg ptr %0, i32 0, i32 1 monotonic monotonic, align 4
  %7 = extractvalue { i32, i1 } %6, 1
  br i1 %7, label %10, label %.preheader

.preheader:                                       ; preds = %5, %.preheader
  %8 = load atomic i32, ptr %0 acquire, align 4
  %9 = icmp sgt i32 %8, -1
  br i1 %9, label %.preheader, label %.loopexit

10:                                               ; preds = %5
  tail call void %1(ptr %2) #20
  store atomic i32 -1, ptr %0 release, align 4
  br label %.loopexit

.loopexit:                                        ; preds = %.preheader, %entry, %10
  ret void
}

; Function Attrs: minsize nounwind optsize sspreq
define weak_odr protected ptr @swift_coroFrameAlloc(i32 %0, i64 %1) local_unnamed_addr #10 {
entry:
  %2 = alloca %TSvSg, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %2)
  store i32 0, ptr %2, align 4
  %3 = call i32 @posix_memalign(ptr nonnull %2, i32 16, i32 %0)
  %4 = load i32, ptr %2, align 4
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %2)
  %5 = inttoptr i32 %4 to ptr
  ret ptr %5
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc { ptr, ptr } @swift_allocError(ptr %0, ptr %1, ptr %2, i1 %3) local_unnamed_addr #12 {
entry:
  %arrayidx.i.i = getelementptr inbounds i8, ptr %0, i32 -4
  %4 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !7
  %flags1.i.i = getelementptr inbounds nuw i8, ptr %4, i32 40
  %5 = load i32, ptr %flags1.i.i, align 4, !tbaa !12
  %and.i.i = and i32 %5, 255
  %size.i = getelementptr inbounds nuw i8, ptr %4, i32 32
  %6 = load i32, ptr %size.i, align 4, !tbaa !15
  %7 = add nuw nsw i32 %and.i.i, 16
  %8 = xor i32 %and.i.i, -1
  %9 = and i32 %7, %8
  %10 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %9, i32 %6)
  %11 = extractvalue { i32, i1 } %10, 0
  %12 = extractvalue { i32, i1 } %10, 1
  br i1 %12, label %29, label %13, !prof !6

13:                                               ; preds = %entry
  %14 = load i1, ptr @"$es25_errorMetadataInitialized33_21ED9D60359C2E63A6128CFAED697BD0LLSbvp", align 1
  br i1 %14, label %17, label %15

15:                                               ; preds = %13
  %16 = load ptr, ptr getelementptr inbounds nuw (i8, ptr @"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvp", i32 4), align 4
  store ptr @_swift_embedded_error_destroy_impl, ptr @"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvp", align 4
  store ptr null, ptr getelementptr inbounds nuw (i8, ptr @"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvp", i32 4), align 4
  call void @swift_releaseTm(ptr %16)
  store i32 ptrtoint (ptr @_swift_embedded_error_box_destroy to i32), ptr getelementptr inbounds nuw (i8, ptr @_swift_embedded_error_metadata_storage, i32 4), align 4
  store i8 1, ptr @"$es25_errorMetadataInitialized33_21ED9D60359C2E63A6128CFAED697BD0LLSbvp", align 1
  br label %17

17:                                               ; preds = %13, %15
  %18 = or i32 %and.i.i, 3
  %19 = tail call swiftcc ptr @"$es17swift_allocObject8metadata12requiredSize0E13AlignmentMaskSpys04HeapC0VGSpys13ClassMetadataVG_S2itF"(ptr nonnull @_swift_embedded_error_metadata_storage, i32 %11, i32 %18)
  %20 = getelementptr inbounds nuw i8, ptr %19, i32 8
  store ptr %0, ptr %20, align 4
  %21 = getelementptr inbounds nuw i8, ptr %19, i32 12
  store ptr %1, ptr %21, align 4
  %22 = getelementptr inbounds nuw i8, ptr %19, i32 %9
  %23 = icmp eq ptr %2, null
  br i1 %23, label %26, label %.sink.split

.sink.split:                                      ; preds = %17
  %24 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !7
  %. = select i1 %3, i32 16, i32 8
  %initializeWithTakeFn.i = getelementptr inbounds nuw i8, ptr %24, i32 %.
  %25 = load ptr, ptr %initializeWithTakeFn.i, align 4, !tbaa !20
  %call1.i5 = tail call ptr %25(ptr noundef nonnull %22, ptr noundef nonnull %2, ptr noundef nonnull %0) #19
  br label %26

26:                                               ; preds = %.sink.split, %17
  %27 = insertvalue { ptr, ptr } undef, ptr %19, 0
  %28 = insertvalue { ptr, ptr } %27, ptr %22, 1
  ret { ptr, ptr } %28

29:                                               ; preds = %entry
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc void @"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvpfiyBpcfU_"(ptr %0) #12 {
entry:
  ret void
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc void @_swift_embedded_error_destroy_impl(ptr %0) #12 {
entry:
  %1 = tail call swiftcc { ptr, ptr, ptr } @"$es17_errorBoxContentsySV4type_SV11conformanceSV5valuetSVF"(ptr %0)
  %2 = extractvalue { ptr, ptr, ptr } %1, 0
  %3 = extractvalue { ptr, ptr, ptr } %1, 2
  %arrayidx.i.i = getelementptr inbounds i8, ptr %2, i32 -4
  %4 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !7
  %destroyFn.i = getelementptr inbounds nuw i8, ptr %4, i32 4
  %5 = load ptr, ptr %destroyFn.i, align 4, !tbaa !19
  tail call void %5(ptr noundef %3, ptr noundef %2) #19
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc { ptr, ptr, ptr } @"$es17_errorBoxContentsySV4type_SV11conformanceSV5valuetSVF"(ptr %0) local_unnamed_addr #12 {
entry:
  %1 = getelementptr inbounds nuw i8, ptr %0, i32 8
  %2 = load ptr, ptr %1, align 4
  %3 = getelementptr inbounds nuw i8, ptr %0, i32 12
  %4 = load ptr, ptr %3, align 4
  %arrayidx.i.i = getelementptr inbounds i8, ptr %2, i32 -4
  %5 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !7
  %flags1.i.i = getelementptr inbounds nuw i8, ptr %5, i32 40
  %6 = load i32, ptr %flags1.i.i, align 4, !tbaa !12
  %and.i.i = and i32 %6, 255
  %7 = add nuw nsw i32 %and.i.i, 16
  %8 = xor i32 %and.i.i, -1
  %9 = and i32 %7, %8
  %10 = getelementptr inbounds nuw i8, ptr %0, i32 %9
  %11 = insertvalue { ptr, ptr, ptr } undef, ptr %2, 0
  %12 = insertvalue { ptr, ptr, ptr } %11, ptr %4, 1
  %13 = insertvalue { ptr, ptr, ptr } %12, ptr %10, 2
  ret { ptr, ptr, ptr } %13
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocError(ptr %0, ptr %1) local_unnamed_addr #12 {
entry:
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_getErrorValue(ptr %0, ptr %1, ptr %2) local_unnamed_addr #12 {
entry:
  %3 = getelementptr inbounds nuw i8, ptr %0, i32 8
  %4 = load ptr, ptr %3, align 4
  %5 = getelementptr inbounds nuw i8, ptr %0, i32 12
  %6 = load ptr, ptr %5, align 4
  %arrayidx.i.i = getelementptr inbounds i8, ptr %4, i32 -4
  %7 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !7
  %flags1.i.i = getelementptr inbounds nuw i8, ptr %7, i32 40
  %8 = load i32, ptr %flags1.i.i, align 4, !tbaa !12
  %and.i.i = and i32 %8, 255
  %9 = add nuw nsw i32 %and.i.i, 16
  %10 = xor i32 %and.i.i, -1
  %11 = and i32 %9, %10
  %12 = getelementptr inbounds nuw i8, ptr %0, i32 %11
  store ptr %12, ptr %2, align 4
  %.elt2 = getelementptr inbounds nuw i8, ptr %2, i32 4
  store ptr %4, ptr %.elt2, align 4
  %.elt3 = getelementptr inbounds nuw i8, ptr %2, i32 8
  store ptr %6, ptr %.elt3, align 4
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected i32 @_swift_exceptionPersonality(i32 %0, i32 %1, i64 %2, ptr %3, ptr %4) #12 {
entry:
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize noinline nounwind optsize
define weak_odr protected void @swift_clearSensitive(ptr %0, i32 %1) local_unnamed_addr #14 {
entry:
  %2 = icmp slt i32 %1, 0
  br i1 %2, label %5, label %3, !prof !6

3:                                                ; preds = %entry
  %4 = icmp eq i32 %1, 0
  br i1 %4, label %.loopexit, label %.preheader.preheader

.preheader.preheader:                             ; preds = %3
  tail call void @llvm.memset.p0.i32(ptr align 1 %0, i8 0, i32 %1, i1 false)
  br label %.loopexit

.loopexit:                                        ; preds = %.preheader.preheader, %3
  ret void

5:                                                ; preds = %entry
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected i32 @swift_retainCount(ptr %0) local_unnamed_addr #12 {
entry:
  %1 = icmp eq ptr %0, null
  br i1 %1, label %6, label %2

2:                                                ; preds = %entry
  %3 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %4 = load atomic i32, ptr %3 acquire, align 4
  %5 = and i32 %4, 2147483647
  br label %6

6:                                                ; preds = %entry, %2
  %7 = phi i32 [ %5, %2 ], [ 0, %entry ]
  ret i32 %7
}

; Function Attrs: minsize nounwind optsize
define private void @4() #12 {
entry:
  tail call void @llvm.trap() #18
  unreachable
}

; Function Attrs: inlinehint nounwind optsize
define internal swiftcc void @_swift_embedded_error_box_destroy(ptr noundef swiftself %object) #15 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %object, i32 8
  %1 = load ptr, ptr %0, align 4
  %arrayidx.i.i.i1 = getelementptr inbounds i8, ptr %1, i32 -4
  %2 = load ptr, ptr %arrayidx.i.i.i1, align 4, !tbaa !7
  %flags1.i.i.i = getelementptr inbounds nuw i8, ptr %2, i32 40
  %3 = load i32, ptr %flags1.i.i.i, align 4, !tbaa !12
  %and.i.i.i = and i32 %3, 255
  %4 = add nuw nsw i32 %and.i.i.i, 16
  %5 = xor i32 %and.i.i.i, -1
  %6 = and i32 %4, %5
  %7 = getelementptr inbounds nuw i8, ptr %object, i32 %6
  %destroyFn.i.i = getelementptr inbounds nuw i8, ptr %2, i32 4
  %8 = load ptr, ptr %destroyFn.i.i, align 4, !tbaa !19
  tail call void %8(ptr noundef %7, ptr noundef %1) #19
  tail call void @free(ptr %object)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smax.i32(i32, i32) #16

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #17

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i32(ptr writeonly captures(none), i8, i32, i1 immarg) #17

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_retain(ptr %0) local_unnamed_addr #12 {
  %2 = tail call ptr @2(ptr %0) #12
  ret ptr %2
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_bridgeObjectRetain(ptr %0) local_unnamed_addr #12 {
  %2 = tail call ptr @2(ptr %0) #12
  ret ptr %2
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_errorRetain(ptr %0) local_unnamed_addr #12 {
  %2 = tail call ptr @2(ptr %0) #12
  ret ptr %2
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_retain_n(ptr %0, i32 %1) local_unnamed_addr #12 {
  %3 = tail call ptr @1(ptr %0, i32 %1) #12
  ret ptr %3
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_bridgeObjectRetain_n(ptr %0, i32 %1) local_unnamed_addr #12 {
  %3 = tail call ptr @1(ptr %0, i32 %1) #12
  ret ptr %3
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deletedMethodError() local_unnamed_addr #12 {
  tail call void @4() #12
  ret void
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden void @_swift_dead_method_stub() #12 {
  tail call void @4() #12
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocUninitializedObject(ptr %0, i32 %1, i32 %2) local_unnamed_addr #12 {
  tail call void @0(ptr %0, i32 %1, i32 %2) #12
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocObject(ptr %0, i32 %1, i32 %2) local_unnamed_addr #12 {
  tail call void @0(ptr %0, i32 %1, i32 %2) #12
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_slowDealloc(ptr %0, i32 %1, i32 %2) local_unnamed_addr #12 {
  tail call void @0(ptr %0, i32 %1, i32 %2) #12
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record133_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) local_unnamed_addr #2 {
  tail call swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record233_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) local_unnamed_addr #2 {
  tail call swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record333_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) local_unnamed_addr #2 {
  tail call swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record433_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) local_unnamed_addr #2 {
  tail call swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record533_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) local_unnamed_addr #2 {
  tail call swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record633_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) local_unnamed_addr #2 {
  tail call swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record733_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) local_unnamed_addr #2 {
  tail call swiftcc void @"$e35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_release(ptr %0) local_unnamed_addr #12 {
  tail call void @3(ptr %0) #12
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_errorRelease(ptr %0) local_unnamed_addr #12 {
  tail call void @3(ptr %0) #12
  ret void
}

attributes #0 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #1 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #2 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #3 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #4 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #6 = { minsize nounwind optsize memory(argmem: readwrite, inaccessiblemem: write) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #7 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #8 = { cold noreturn nounwind memory(inaccessiblemem: write) }
attributes #9 = { minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #10 = { minsize nounwind optsize sspreq "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #11 = { minsize nofree nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #12 = { minsize nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #13 = { minsize mustprogress nounwind optsize willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #14 = { minsize noinline nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #15 = { inlinehint nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #16 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #17 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #18 = { nomerge }
attributes #19 = { nounwind optsize }
attributes #20 = { nounwind }

!swift.module.flags = !{!0}
!llvm.module.flags = !{!1, !2, !3, !4, !5}
!llvm.linker.options = !{}

!0 = !{!"standard-library", i1 false}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 1, !"min_enum_size", i32 4}
!3 = !{i32 8, !"PIC Level", i32 2}
!4 = !{i32 4, !"Objective-C Garbage Collection", i32 100927232}
!5 = !{i32 1, !"Swift Version", i32 7}
!6 = !{!"branch_weights", !"expected", i32 1, i32 2000}
!7 = !{!8, !9, i64 0}
!8 = !{!"", !9, i64 0}
!9 = !{!"any pointer", !10, i64 0}
!10 = !{!"omnipotent char", !11, i64 0}
!11 = !{!"Simple C/C++ TBAA"}
!12 = !{!13, !14, i64 40}
!13 = !{!"", !9, i64 0, !9, i64 4, !9, i64 8, !9, i64 12, !9, i64 16, !9, i64 20, !9, i64 24, !9, i64 28, !14, i64 32, !14, i64 36, !14, i64 40}
!14 = !{!"int", !10, i64 0}
!15 = !{!13, !14, i64 32}
!16 = !{!17, !9, i64 0}
!17 = !{!"EmbeddedHeapObject", !9, i64 0}
!18 = !{!13, !9, i64 8}
!19 = !{!13, !9, i64 4}
!20 = !{!9, !9, i64 0}
!21 = !{!"branch_weights", !"expected", i32 2000, i32 1}
!22 = !{!13, !9, i64 16}
