; ModuleID = '/Users/eugene/work/GiftUI/.build/contract-reports/spec-002/rfc-014/.tmp-nrf52840-embedded-81830/build/foundation-layout.ll'
source_filename = "/Users/eugene/work/GiftUI/.build/contract-reports/spec-002/rfc-014/.tmp-nrf52840-embedded-81830/build/foundation-layout.ll"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-none-eabihf"

%TSi = type <{ i32 }>
%TSb = type <{ i1 }>
%swift.function = type { ptr, ptr }
%TSo23_SwiftHashingParametersV = type <{ %Ts6UInt64V, %Ts6UInt64V, %TSb, [7 x i8] }>
%Ts6UInt64V = type <{ i64 }>
%Ts6HasherV = type <{ %Ts6HasherV5_CoreV }>
%Ts6HasherV5_CoreV = type <{ %Ts6HasherV11_TailBufferV, %Ts6HasherV6_StateV }>
%Ts6HasherV11_TailBufferV = type <{ %Ts6UInt64V }>
%Ts6HasherV6_StateV = type <{ %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V }>
%T27GiftUIFoundationLayoutProbe4RectVSg = type <{ [16 x i8], [1 x i8] }>
%T27GiftUIFoundationLayoutProbe22NormalizedPointerEventV = type <{ %T27GiftUIFoundationLayoutProbe12PointerPhaseO, [3 x i8], %T27GiftUIFoundationLayoutProbe5PointV, %T27GiftUIFoundationLayoutProbe13InputSourceIDV, [2 x i8], %T27GiftUIFoundationLayoutProbe17PointerSequenceIDV, %T27GiftUIFoundationLayoutProbe12InputOrdinalV, %T27GiftUIFoundationLayoutProbe20PresentationRevisionV }>
%T27GiftUIFoundationLayoutProbe12PointerPhaseO = type <{ i8 }>
%T27GiftUIFoundationLayoutProbe5PointV = type <{ %Ts5Int32V, %Ts5Int32V }>
%Ts5Int32V = type <{ i32 }>
%T27GiftUIFoundationLayoutProbe13InputSourceIDV = type <{ %Ts6UInt16V }>
%Ts6UInt16V = type <{ i16 }>
%T27GiftUIFoundationLayoutProbe17PointerSequenceIDV = type <{ %Ts6UInt32V }>
%Ts6UInt32V = type <{ i32 }>
%T27GiftUIFoundationLayoutProbe12InputOrdinalV = type <{ %Ts6UInt32V }>
%T27GiftUIFoundationLayoutProbe20PresentationRevisionV = type <{ %Ts6UInt32V }>
%TSvSg = type <{ [4 x i8] }>

@"$es16_emptyBoxStorageSi_Sitvp" = linkonce_odr protected global <{ %TSi, %TSi }> <{ %TSi zeroinitializer, %TSi <{ i32 -1 }> }>, align 4
@_swift_embedded_error_metadata_storage = weak_odr protected global <{ i32, i32, i32 }> zeroinitializer, align 4
@"$es25_errorMetadataInitialized33_21ED9D60359C2E63A6128CFAED697BD0LLSbvp" = linkonce_odr protected local_unnamed_addr global %TSb zeroinitializer, align 1
@"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvp" = linkonce_odr protected local_unnamed_addr global %swift.function { ptr @"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvpfiyBpcfU_", ptr null }, align 4
@"$es32_swift_stdlib_Hashing_parameters_Wz" = linkonce_odr protected global i32 0, align 4
@"$es32_swift_stdlib_Hashing_parametersSo06_SwiftC10ParametersVvp" = linkonce_odr protected local_unnamed_addr global %TSo23_SwiftHashingParametersV zeroinitializer, align 8
@_swift1_autolink_entries = private constant [0 x i8] zeroinitializer, section ".swift1_autolink_entries", no_sanitize_address, align 4
@llvm.used = appending global [2 x ptr] [ptr @_swift1_autolink_entries, ptr @_swift_exceptionPersonality], section "llvm.metadata"

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe5PointV1xs5Int32Vvg"(i32 returned %0, i32 %1) local_unnamed_addr #0 {
entry:
  ret i32 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe5PointV1ys5Int32Vvg"(i32 %0, i32 returned %1) local_unnamed_addr #0 {
entry:
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i32 } @"$e27GiftUIFoundationLayoutProbe5PointV1x1yACs5Int32V_AGtcfC"(i32 %0, i32 %1) local_unnamed_addr #0 {
entry:
  %2 = insertvalue { i32, i32 } undef, i32 %0, 0
  %3 = insertvalue { i32, i32 } %2, i32 %1, 1
  ret { i32, i32 } %3
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe4SizeV5widths5Int32Vvg"(i32 returned %0, i32 %1) local_unnamed_addr #0 {
entry:
  ret i32 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe4SizeV6heights5Int32Vvg"(i32 %0, i32 returned %1) local_unnamed_addr #0 {
entry:
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i32, i8 } @"$e27GiftUIFoundationLayoutProbe4SizeV5width6heightACSgs5Int32V_AHtcfC"(i32 %0, i32 %1) local_unnamed_addr #0 {
entry:
  %2 = icmp slt i32 %0, 0
  %3 = icmp slt i32 %1, 0
  %or.cond.not = select i1 %2, i1 true, i1 %3
  %4 = select i1 %or.cond.not, i32 0, i32 %0
  %5 = select i1 %or.cond.not, i32 0, i32 %1
  %6 = zext i1 %or.cond.not to i8
  %7 = insertvalue { i32, i32, i8 } undef, i32 %4, 0
  %8 = insertvalue { i32, i32, i8 } %7, i32 %5, 1
  %9 = insertvalue { i32, i32, i8 } %8, i8 %6, 2
  ret { i32, i32, i8 } %9
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e27GiftUIFoundationLayoutProbe4SizeV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1, i32 %2, i32 %3) local_unnamed_addr #0 {
entry:
  %4 = icmp eq i32 %0, %2
  %5 = icmp eq i32 %1, %3
  %6 = select i1 %4, i1 %5, i1 false
  ret i1 %6
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc void @"$e27GiftUIFoundationLayoutProbe4SizeV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1, i32 %2) local_unnamed_addr #1 {
entry:
  tail call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe4SizeV9hashValueSivg"(i32 %0, i32 %1) local_unnamed_addr #1 {
  %3 = tail call swiftcc i32 @"$e27GiftUIFoundationLayoutProbe5PointV9hashValueSivgTm"(i32 %0, i32 %1) #1
  ret i32 %3
}

; Function Attrs: minsize nounwind optsize
define internal swiftcc i32 @"$e27GiftUIFoundationLayoutProbe5PointV9hashValueSivgTm"(i32 %0, i32 %1) local_unnamed_addr #1 {
entry:
  %2 = alloca %Ts6HasherV, align 8
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %2)
  call swiftcc void @"$es6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %2, i32 0)
  call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %0, ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  %3 = call swiftcc i32 @"$es6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %2)
  ret i32 %3
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i32 } @"$e27GiftUIFoundationLayoutProbe4RectV6originAA5PointVvg"(i32 %0, i32 %1, i32 %2, i32 %3) local_unnamed_addr #0 {
entry:
  %4 = insertvalue { i32, i32 } undef, i32 %0, 0
  %5 = insertvalue { i32, i32 } %4, i32 %1, 1
  ret { i32, i32 } %5
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i32 } @"$e27GiftUIFoundationLayoutProbe4RectV4sizeAA4SizeVvg"(i32 %0, i32 %1, i32 %2, i32 %3) local_unnamed_addr #0 {
entry:
  %4 = insertvalue { i32, i32 } undef, i32 %2, 0
  %5 = insertvalue { i32, i32 } %4, i32 %3, 1
  ret { i32, i32 } %5
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e27GiftUIFoundationLayoutProbe4RectV6origin4sizeACSgAA5PointV_AA4SizeVtcfC"(ptr noalias writeonly sret(%T27GiftUIFoundationLayoutProbe4RectVSg) captures(none) initializes((0, 17)) %0, i32 %1, i32 %2, i32 %3, i32 %4) local_unnamed_addr #2 {
entry:
  %5 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %1, i32 %3)
  %6 = extractvalue { i32, i1 } %5, 1
  br i1 %6, label %10, label %7

7:                                                ; preds = %entry
  %8 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %2, i32 %4)
  %9 = extractvalue { i32, i1 } %8, 1
  br i1 %9, label %10, label %11

10:                                               ; preds = %7, %entry
  br label %11

11:                                               ; preds = %7, %10
  %12 = phi i32 [ 0, %10 ], [ %1, %7 ]
  %13 = phi i32 [ 0, %10 ], [ %2, %7 ]
  %14 = phi i32 [ 0, %10 ], [ %3, %7 ]
  %15 = phi i32 [ 0, %10 ], [ %4, %7 ]
  %16 = phi i8 [ 1, %10 ], [ 0, %7 ]
  store i32 %12, ptr %0, align 4
  %17 = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %13, ptr %17, align 4
  %18 = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %14, ptr %18, align 4
  %19 = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i32 %15, ptr %19, align 4
  %20 = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i8 %16, ptr %20, align 4
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i8 } @"$e27GiftUIFoundationLayoutProbe18GeometryArithmeticO3addys5Int32VSgAF_AFtFZ"(i32 %0, i32 %1) local_unnamed_addr #0 {
entry:
  %2 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %0, i32 %1)
  %3 = extractvalue { i32, i1 } %2, 0
  %4 = extractvalue { i32, i1 } %2, 1
  %. = select i1 %4, i32 0, i32 %3
  %.1 = zext i1 %4 to i8
  %5 = insertvalue { i32, i8 } undef, i32 %., 0
  %6 = insertvalue { i32, i8 } %5, i8 %.1, 1
  ret { i32, i8 } %6
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe4RectV4minXs5Int32Vvg"(i32 returned %0, i32 %1, i32 %2, i32 %3) local_unnamed_addr #0 {
entry:
  ret i32 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe4RectV4minYs5Int32Vvg"(i32 %0, i32 returned %1, i32 %2, i32 %3) local_unnamed_addr #0 {
entry:
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe4RectV4maxXs5Int32Vvg"(i32 %0, i32 %1, i32 %2, i32 %3) local_unnamed_addr #0 {
entry:
  %4 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %0, i32 %2)
  %5 = extractvalue { i32, i1 } %4, 0
  %6 = extractvalue { i32, i1 } %4, 1
  %. = select i1 %6, i32 %0, i32 %5
  ret i32 %.
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe4RectV4maxYs5Int32Vvg"(i32 %0, i32 %1, i32 %2, i32 %3) local_unnamed_addr #0 {
entry:
  %4 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %1, i32 %3)
  %5 = extractvalue { i32, i1 } %4, 0
  %6 = extractvalue { i32, i1 } %4, 1
  %. = select i1 %6, i32 %1, i32 %5
  ret i32 %.
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e27GiftUIFoundationLayoutProbe4RectV8containsySbAA5PointVF"(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5) local_unnamed_addr #0 {
entry:
  %.not = icmp slt i32 %0, %2
  br i1 %.not, label %17, label %6

6:                                                ; preds = %entry
  %7 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %2, i32 %4)
  %8 = extractvalue { i32, i1 } %7, 0
  %9 = extractvalue { i32, i1 } %7, 1
  %. = select i1 %9, i32 %2, i32 %8
  %10 = icmp slt i32 %0, %.
  %11 = icmp sge i32 %1, %3
  %or.cond = select i1 %10, i1 %11, i1 false
  br i1 %or.cond, label %12, label %17

12:                                               ; preds = %6
  %13 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %3, i32 %5)
  %14 = extractvalue { i32, i1 } %13, 0
  %15 = extractvalue { i32, i1 } %13, 1
  %.1 = select i1 %15, i32 %3, i32 %14
  %16 = icmp slt i32 %1, %.1
  br label %17

17:                                               ; preds = %entry, %6, %12
  %18 = phi i1 [ %16, %12 ], [ false, %6 ], [ false, %entry ]
  ret i1 %18
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i1 @"$e27GiftUIFoundationLayoutProbe4RectV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5, i32 %6, i32 %7) local_unnamed_addr #0 {
entry:
  %8 = icmp eq i32 %0, %4
  %9 = icmp eq i32 %1, %5
  %or.cond = select i1 %8, i1 %9, i1 false
  br i1 %or.cond, label %10, label %14

10:                                               ; preds = %entry
  %11 = icmp eq i32 %2, %6
  %12 = icmp eq i32 %3, %7
  %or.cond1 = select i1 %11, i1 %12, i1 false
  br i1 %or.cond1, label %14, label %13

13:                                               ; preds = %10
  br label %14

14:                                               ; preds = %10, %entry, %13
  %15 = phi i1 [ false, %13 ], [ false, %entry ], [ true, %10 ]
  ret i1 %15
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc void @"$e27GiftUIFoundationLayoutProbe4RectV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1, i32 %2, i32 %3, i32 %4) local_unnamed_addr #1 {
entry:
  tail call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %4, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe4RectV9hashValueSivg"(i32 %0, i32 %1, i32 %2, i32 %3) local_unnamed_addr #1 {
entry:
  %4 = alloca %Ts6HasherV, align 8
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %4)
  call swiftcc void @"$es6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %4, i32 0)
  call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %0, ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  %5 = call swiftcc i32 @"$es6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %4)
  ret i32 %5
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i8 } @"$e27GiftUIFoundationLayoutProbe12ProposedSizeV5widths5Int32VSgvg"(i32 %0, i8 %1, i32 %2, i8 %3) local_unnamed_addr #0 {
entry:
  %4 = insertvalue { i32, i8 } undef, i32 %0, 0
  %5 = insertvalue { i32, i8 } %4, i8 %1, 1
  ret { i32, i8 } %5
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i8 } @"$e27GiftUIFoundationLayoutProbe12ProposedSizeV6heights5Int32VSgvg"(i32 %0, i8 %1, i32 %2, i8 %3) local_unnamed_addr #0 {
entry:
  %4 = insertvalue { i32, i8 } undef, i32 %2, 0
  %5 = insertvalue { i32, i8 } %4, i8 %3, 1
  ret { i32, i8 } %5
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i32, i32, i16 } @"$e27GiftUIFoundationLayoutProbe12ProposedSizeV5width6heightACSgs5Int32VSg_AItcfC"(i32 %0, i8 %1, i32 %2, i8 %3) local_unnamed_addr #0 {
entry:
  %4 = icmp ne i8 %1, 1
  %5 = icmp slt i32 %0, 0
  %or.cond = select i1 %4, i1 %5, i1 false
  br i1 %or.cond, label %11, label %6

6:                                                ; preds = %entry
  %7 = icmp ne i8 %3, 1
  %8 = icmp slt i32 %2, 0
  %or.cond1 = select i1 %7, i1 %8, i1 false
  br i1 %or.cond1, label %11, label %9

9:                                                ; preds = %6
  %10 = zext i8 %1 to i32
  br label %11

11:                                               ; preds = %6, %entry, %9
  %12 = phi i32 [ %0, %9 ], [ 0, %entry ], [ 0, %6 ]
  %13 = phi i32 [ %10, %9 ], [ 0, %entry ], [ 0, %6 ]
  %14 = phi i32 [ %2, %9 ], [ 0, %entry ], [ 0, %6 ]
  %15 = phi i8 [ %3, %9 ], [ 0, %entry ], [ 0, %6 ]
  %16 = phi i8 [ 0, %9 ], [ 1, %entry ], [ 1, %6 ]
  %temp-coercion.coerced.sroa.8.12.insert.ext = zext i8 %15 to i16
  %temp-coercion.coerced.sroa.8.13.insert.ext = zext nneg i8 %16 to i16
  %temp-coercion.coerced.sroa.8.13.insert.shift = shl nuw nsw i16 %temp-coercion.coerced.sroa.8.13.insert.ext, 8
  %temp-coercion.coerced.sroa.8.13.insert.insert = or disjoint i16 %temp-coercion.coerced.sroa.8.13.insert.shift, %temp-coercion.coerced.sroa.8.12.insert.ext
  %17 = insertvalue { i32, i32, i32, i16 } undef, i32 %12, 0
  %18 = insertvalue { i32, i32, i32, i16 } %17, i32 %13, 1
  %19 = insertvalue { i32, i32, i32, i16 } %18, i32 %14, 2
  %20 = insertvalue { i32, i32, i32, i16 } %19, i16 %temp-coercion.coerced.sroa.8.13.insert.insert, 3
  ret { i32, i32, i32, i16 } %20
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i1 @"$e27GiftUIFoundationLayoutProbe12ProposedSizeV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i8 %1, i32 %2, i8 %3, i32 %4, i8 %5, i32 %6, i8 %7) local_unnamed_addr #0 {
entry:
  %8 = icmp eq i8 %1, 1
  br i1 %8, label %12, label %9

9:                                                ; preds = %entry
  %10 = icmp ne i8 %5, 1
  %11 = icmp eq i32 %0, %4
  %or.cond = select i1 %10, i1 %11, i1 false
  br i1 %or.cond, label %14, label %22

12:                                               ; preds = %entry
  %13 = icmp eq i8 %5, 1
  br i1 %13, label %14, label %22

14:                                               ; preds = %9, %12
  %15 = icmp eq i8 %3, 1
  br i1 %15, label %19, label %16

16:                                               ; preds = %14
  %17 = icmp ne i8 %7, 1
  %18 = icmp eq i32 %2, %6
  %or.cond1 = select i1 %17, i1 %18, i1 false
  br i1 %or.cond1, label %22, label %21

19:                                               ; preds = %14
  %20 = icmp eq i8 %7, 1
  br i1 %20, label %22, label %21

21:                                               ; preds = %19, %16
  br label %22

22:                                               ; preds = %16, %9, %12, %19, %21
  %23 = phi i1 [ false, %21 ], [ true, %19 ], [ false, %12 ], [ false, %9 ], [ true, %16 ]
  ret i1 %23
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc void @"$e27GiftUIFoundationLayoutProbe12ProposedSizeV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1, i8 %2, i32 %3, i8 %4) local_unnamed_addr #1 {
entry:
  %5 = icmp eq i8 %2, 1
  br i1 %5, label %6, label %7

6:                                                ; preds = %entry
  tail call swiftcc void @"$es6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  br label %8

7:                                                ; preds = %entry
  tail call swiftcc void @"$es6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  br label %8

8:                                                ; preds = %6, %7
  %9 = icmp eq i8 %4, 1
  br i1 %9, label %10, label %11

10:                                               ; preds = %8
  tail call swiftcc void @"$es6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  br label %12

11:                                               ; preds = %8
  tail call swiftcc void @"$es6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  br label %12

12:                                               ; preds = %10, %11
  ret void
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe12ProposedSizeV9hashValueSivg"(i32 %0, i8 %1, i32 %2, i8 %3) local_unnamed_addr #1 {
entry:
  %4 = alloca %Ts6HasherV, align 8
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %4)
  call swiftcc void @"$es6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %4, i32 0)
  call swiftcc void @"$e27GiftUIFoundationLayoutProbe12ProposedSizeV4hash4intoys6HasherVz_tF"(ptr nonnull captures(none) dereferenceable(72) %4, i32 %0, i8 %1, i32 %2, i8 %3)
  %5 = call swiftcc i32 @"$es6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %4)
  ret i32 %5
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i8 } @"$e27GiftUIFoundationLayoutProbe18GeometryArithmeticO8subtractys5Int32VSgAF_AFtFZ"(i32 %0, i32 %1) local_unnamed_addr #0 {
entry:
  %2 = tail call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 %0, i32 %1)
  %3 = extractvalue { i32, i1 } %2, 0
  %4 = extractvalue { i32, i1 } %2, 1
  %. = select i1 %4, i32 0, i32 %3
  %.1 = zext i1 %4 to i8
  %5 = insertvalue { i32, i8 } undef, i32 %., 0
  %6 = insertvalue { i32, i8 } %5, i8 %.1, 1
  ret { i32, i8 } %6
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i8 } @"$e27GiftUIFoundationLayoutProbe18GeometryArithmeticO8multiplyys5Int32VSgAF_AFtFZ"(i32 %0, i32 %1) local_unnamed_addr #0 {
entry:
  %2 = tail call { i32, i1 } @llvm.smul.with.overflow.i32(i32 %0, i32 %1)
  %3 = extractvalue { i32, i1 } %2, 0
  %4 = extractvalue { i32, i1 } %2, 1
  %. = select i1 %4, i32 0, i32 %3
  %.1 = zext i1 %4 to i8
  %5 = insertvalue { i32, i8 } undef, i32 %., 0
  %6 = insertvalue { i32, i8 } %5, i8 %.1, 1
  ret { i32, i8 } %6
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc range(i8 0, 4) i8 @"$e27GiftUIFoundationLayoutProbe12PointerPhaseO8rawValueACSgs5UInt8V_tcfC"(i8 %0) local_unnamed_addr #0 {
entry:
  %. = tail call i8 @llvm.umin.i8(i8 %0, i8 3)
  ret i8 %.
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUIFoundationLayoutProbe12PointerPhaseO8rawValues5UInt8Vvg"(i8 returned %0) local_unnamed_addr #0 {
entry:
  ret i8 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i16 @"$e27GiftUIFoundationLayoutProbe13InputSourceIDV8rawValues6UInt16Vvg"(i16 returned %0) local_unnamed_addr #0 {
entry:
  ret i16 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i16 @"$e27GiftUIFoundationLayoutProbe13InputSourceIDV8rawValueACs6UInt16V_tcfC"(i16 returned %0) local_unnamed_addr #0 {
entry:
  ret i16 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e27GiftUIFoundationLayoutProbe13InputSourceIDV23__derived_struct_equalsySbAC_ACtFZ"(i16 %0, i16 %1) local_unnamed_addr #0 {
entry:
  %2 = icmp eq i16 %0, %1
  ret i1 %2
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc void @"$e27GiftUIFoundationLayoutProbe13InputSourceIDV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i16 %1) local_unnamed_addr #1 {
entry:
  tail call swiftcc void @"$es6HasherV8_combineyys6UInt16VF"(i16 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe13InputSourceIDV9hashValueSivg"(i16 %0) local_unnamed_addr #1 {
entry:
  %1 = alloca %Ts6HasherV, align 8
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %1)
  call swiftcc void @"$es6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %1, i32 0)
  call swiftcc void @"$es6HasherV8_combineyys6UInt16VF"(i16 %0, ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  %2 = call swiftcc i32 @"$es6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %1)
  ret i32 %2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe17PointerSequenceIDV8rawValues6UInt32Vvg"(i32 returned %0) local_unnamed_addr #0 {
entry:
  ret i32 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe17PointerSequenceIDV8rawValueACs6UInt32V_tcfC"(i32 returned %0) local_unnamed_addr #0 {
entry:
  ret i32 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe12InputOrdinalV8rawValues6UInt32Vvg"(i32 returned %0) local_unnamed_addr #0 {
entry:
  ret i32 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe12InputOrdinalV8rawValueACs6UInt32V_tcfC"(i32 returned %0) local_unnamed_addr #0 {
entry:
  ret i32 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e27GiftUIFoundationLayoutProbe12InputOrdinalV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) local_unnamed_addr #0 {
entry:
  %2 = icmp eq i32 %0, %1
  ret i1 %2
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc void @"$e27GiftUIFoundationLayoutProbe12InputOrdinalV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) local_unnamed_addr #1 {
entry:
  tail call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe12InputOrdinalV9hashValueSivg"(i32 %0) local_unnamed_addr #1 {
  %2 = tail call swiftcc i32 @"$e27GiftUIFoundationLayoutProbe17PointerSequenceIDV9hashValueSivgTm"(i32 %0) #1
  ret i32 %2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe20PresentationRevisionV8rawValues6UInt32Vvg"(i32 returned %0) local_unnamed_addr #0 {
entry:
  ret i32 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe20PresentationRevisionV8rawValueACs6UInt32V_tcfC"(i32 returned %0) local_unnamed_addr #0 {
entry:
  ret i32 %0
}

; Function Attrs: minsize nounwind optsize
define internal swiftcc i32 @"$e27GiftUIFoundationLayoutProbe17PointerSequenceIDV9hashValueSivgTm"(i32 %0) local_unnamed_addr #1 {
entry:
  %1 = alloca %Ts6HasherV, align 8
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %1)
  call swiftcc void @"$es6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %1, i32 0)
  call swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %0, ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  %2 = call swiftcc i32 @"$es6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %1)
  ret i32 %2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUIFoundationLayoutProbe22NormalizedPointerEventV5phaseAA0F5PhaseOvg"(ptr noalias readonly swiftself captures(none) dereferenceable(28) %0) local_unnamed_addr #3 {
entry:
  %1 = load i8, ptr %0, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc { i32, i32 } @"$e27GiftUIFoundationLayoutProbe22NormalizedPointerEventV8positionAA5PointVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(28) %0) local_unnamed_addr #3 {
entry:
  %.position = getelementptr inbounds nuw i8, ptr %0, i32 4
  %1 = load i32, ptr %.position, align 4
  %.position.y = getelementptr inbounds nuw i8, ptr %0, i32 8
  %2 = load i32, ptr %.position.y, align 4
  %3 = insertvalue { i32, i32 } undef, i32 %1, 0
  %4 = insertvalue { i32, i32 } %3, i32 %2, 1
  ret { i32, i32 } %4
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i16 @"$e27GiftUIFoundationLayoutProbe22NormalizedPointerEventV6sourceAA13InputSourceIDVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(28) %0) local_unnamed_addr #3 {
entry:
  %.source = getelementptr inbounds nuw i8, ptr %0, i32 12
  %1 = load i16, ptr %.source, align 4
  ret i16 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe22NormalizedPointerEventV8sequenceAA0F10SequenceIDVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(28) %0) local_unnamed_addr #3 {
entry:
  %.sequence = getelementptr inbounds nuw i8, ptr %0, i32 16
  %1 = load i32, ptr %.sequence, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe22NormalizedPointerEventV7ordinalAA12InputOrdinalVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(28) %0) local_unnamed_addr #3 {
entry:
  %.ordinal = getelementptr inbounds nuw i8, ptr %0, i32 20
  %1 = load i32, ptr %.ordinal, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe22NormalizedPointerEventV20presentationRevisionAA012PresentationI0Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(28) %0) local_unnamed_addr #3 {
entry:
  %.presentationRevision = getelementptr inbounds nuw i8, ptr %0, i32 24
  %1 = load i32, ptr %.presentationRevision, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e27GiftUIFoundationLayoutProbe22NormalizedPointerEventV5phase8position6source8sequence7ordinal20presentationRevisionAcA0F5PhaseO_AA5PointVAA13InputSourceIDVAA0f8SequenceS0VAA0Q7OrdinalVAA012PresentationN0VtcfC"(ptr noalias writeonly sret(%T27GiftUIFoundationLayoutProbe22NormalizedPointerEventV) captures(none) initializes((0, 1), (4, 14), (16, 28)) %0, i8 %1, i32 %2, i32 %3, i16 %4, i32 %5, i32 %6, i32 %7) local_unnamed_addr #2 {
entry:
  store i8 %1, ptr %0, align 4
  %.position8 = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %2, ptr %.position8, align 4
  %.position8.y = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %3, ptr %.position8.y, align 4
  %.source9 = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i16 %4, ptr %.source9, align 4
  %.sequence10 = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i32 %5, ptr %.sequence10, align 4
  %.ordinal11 = getelementptr inbounds nuw i8, ptr %0, i32 20
  store i32 %6, ptr %.ordinal11, align 4
  %.presentationRevision12 = getelementptr inbounds nuw i8, ptr %0, i32 24
  store i32 %7, ptr %.presentationRevision12, align 4
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e27GiftUIFoundationLayoutProbe22NormalizedPointerEventV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(28) %0, ptr noalias readonly captures(none) dereferenceable(28) %1) local_unnamed_addr #3 {
entry:
  %.unpack = load i8, ptr %0, align 4
  %.unpack69 = load i8, ptr %1, align 4
  %2 = icmp eq i8 %.unpack, %.unpack69
  br i1 %2, label %3, label %15

3:                                                ; preds = %entry
  %.position = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.058.0.copyload = load i32, ptr %.position, align 4
  %.position2 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.054.0.copyload = load i32, ptr %.position2, align 4
  %4 = icmp eq i32 %.sroa.058.0.copyload, %.sroa.054.0.copyload
  br i1 %4, label %5, label %15

5:                                                ; preds = %3
  %.sroa.4.0..position2.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.4.0.copyload = load i32, ptr %.sroa.4.0..position2.sroa_idx, align 4
  %.sroa.460.0..position.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.460.0.copyload = load i32, ptr %.sroa.460.0..position.sroa_idx, align 4
  %6 = icmp eq i32 %.sroa.460.0.copyload, %.sroa.4.0.copyload
  br i1 %6, label %7, label %15

7:                                                ; preds = %5
  %.source = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.050.0.copyload = load i16, ptr %.source, align 4
  %.source8 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.047.0.copyload = load i16, ptr %.source8, align 4
  %8 = icmp eq i16 %.sroa.050.0.copyload, %.sroa.047.0.copyload
  br i1 %8, label %9, label %15

9:                                                ; preds = %7
  %.sequence = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.044.0.copyload = load i32, ptr %.sequence, align 4
  %.sequence12 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.sroa.041.0.copyload = load i32, ptr %.sequence12, align 4
  %10 = icmp eq i32 %.sroa.044.0.copyload, %.sroa.041.0.copyload
  br i1 %10, label %11, label %15

11:                                               ; preds = %9
  %.ordinal = getelementptr inbounds nuw i8, ptr %0, i32 20
  %.sroa.038.0.copyload = load i32, ptr %.ordinal, align 4
  %.ordinal17 = getelementptr inbounds nuw i8, ptr %1, i32 20
  %.sroa.035.0.copyload = load i32, ptr %.ordinal17, align 4
  %12 = icmp eq i32 %.sroa.038.0.copyload, %.sroa.035.0.copyload
  br i1 %12, label %13, label %15

13:                                               ; preds = %11
  %.presentationRevision = getelementptr inbounds nuw i8, ptr %0, i32 24
  %.sroa.032.0.copyload = load i32, ptr %.presentationRevision, align 4
  %.presentationRevision22 = getelementptr inbounds nuw i8, ptr %1, i32 24
  %.sroa.029.0.copyload = load i32, ptr %.presentationRevision22, align 4
  %14 = icmp eq i32 %.sroa.032.0.copyload, %.sroa.029.0.copyload
  br label %15

15:                                               ; preds = %entry, %5, %3, %7, %9, %11, %13
  %16 = phi i1 [ %14, %13 ], [ false, %11 ], [ false, %9 ], [ false, %7 ], [ false, %3 ], [ false, %5 ], [ false, %entry ]
  ret i1 %16
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO18geometryScalarSizes6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO20geometryScalarStrides6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO23geometryScalarAlignments6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO9pointSizes6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 8
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO11pointStrides6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 8
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO14pointAlignments6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO8sizeSizes6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 8
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO10sizeStrides6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 8
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO13sizeAlignments6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO8rectSizes6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 16
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO10rectStrides6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 16
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO13rectAlignments6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO16proposedByteSizes6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 13
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO14proposedStrides6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 16
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO17proposedAlignments6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO16pointerPhaseSizes6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO18pointerPhaseStrides6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO21pointerPhaseAlignments6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO17inputSourceIDSizes6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 2
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO19inputSourceIDStrides6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 2
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO22inputSourceIDAlignments6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 2
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO21pointerSequenceIDSizes6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO23pointerSequenceIDStrides6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO26pointerSequenceIDAlignments6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO16inputOrdinalSizes6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO18inputOrdinalStrides6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO21inputOrdinalAlignments6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO24presentationRevisionSizes6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO26presentationRevisionStrides6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO29presentationRevisionAlignments6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO26normalizedPointerEventSizes6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 28
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO28normalizedPointerEventStrides6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 28
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUIFoundationLayoutProbeAAO31normalizedPointerEventAlignments6UInt32VyFZ"() local_unnamed_addr #4 {
entry:
  ret i32 4
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc void @"$es6HasherV5_seedABSi_tcfC"(ptr noalias sret(%Ts6HasherV) captures(none) %0, i32 %1) local_unnamed_addr #1 {
entry:
  tail call void @swift_once(ptr nonnull @"$es32_swift_stdlib_Hashing_parameters_Wz", ptr nonnull @"$es32_swift_stdlib_Hashing_parameters_WZ", ptr undef) #15
  %2 = load i64, ptr @"$es32_swift_stdlib_Hashing_parametersSo06_SwiftC10ParametersVvp", align 8
  %3 = load i64, ptr getelementptr inbounds nuw (i8, ptr @"$es32_swift_stdlib_Hashing_parametersSo06_SwiftC10ParametersVvp", i32 8), align 8
  %4 = zext i32 %1 to i64
  %5 = xor i64 %2, %4
  %6 = xor i64 %3, 8387220255154660723
  %7 = xor i64 %5, 7816392313619706465
  %8 = xor i64 %3, 7237128888997146477
  %9 = xor i64 %5, 8317987319222330741
  store i64 0, ptr %0, align 8
  %.sroa.419.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i64 %9, ptr %.sroa.419.0..sroa_idx, align 8
  %.sroa.520.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i64 %8, ptr %.sroa.520.0..sroa_idx, align 8
  %.sroa.621.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 24
  store i64 %7, ptr %.sroa.621.0..sroa_idx, align 8
  %.sroa.722.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 32
  store i64 %6, ptr %.sroa.722.0..sroa_idx, align 8
  %.sroa.823.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 40
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(32) %.sroa.823.0..sroa_idx, i8 0, i64 32, i1 false)
  ret void
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc i32 @"$es6HasherV9_finalizeSiyF"(ptr swiftself captures(none) dereferenceable(72) %0) local_unnamed_addr #1 {
entry:
  %1 = load i64, ptr %0, align 8
  %._core._state = getelementptr inbounds nuw i8, ptr %0, i32 8
  %._core._state.v3 = getelementptr inbounds nuw i8, ptr %0, i32 32
  %2 = load i64, ptr %._core._state.v3, align 8
  %3 = xor i64 %2, %1
  %4 = load i64, ptr %._core._state, align 8
  %._core._state.v1 = getelementptr inbounds nuw i8, ptr %0, i32 16
  %5 = load i64, ptr %._core._state.v1, align 8
  %6 = add i64 %5, %4
  %7 = tail call i64 @llvm.fshl.i64(i64 %5, i64 %5, i64 13)
  %8 = xor i64 %7, %6
  %9 = tail call i64 @llvm.fshl.i64(i64 %6, i64 %6, i64 32)
  %._core._state.v2 = getelementptr inbounds nuw i8, ptr %0, i32 24
  %10 = load i64, ptr %._core._state.v2, align 8
  %11 = add i64 %10, %3
  %12 = tail call i64 @llvm.fshl.i64(i64 %3, i64 %3, i64 16)
  %13 = xor i64 %11, %12
  %14 = add i64 %13, %9
  %15 = tail call i64 @llvm.fshl.i64(i64 %13, i64 %13, i64 21)
  %16 = xor i64 %15, %14
  %17 = add i64 %11, %8
  %18 = tail call i64 @llvm.fshl.i64(i64 %8, i64 %8, i64 17)
  %19 = xor i64 %18, %17
  %20 = tail call i64 @llvm.fshl.i64(i64 %17, i64 %17, i64 32)
  %21 = xor i64 %14, %1
  %22 = xor i64 %20, 255
  %23 = add i64 %21, %19
  %24 = tail call i64 @llvm.fshl.i64(i64 %19, i64 %19, i64 13)
  %25 = xor i64 %23, %24
  %26 = tail call i64 @llvm.fshl.i64(i64 %23, i64 %23, i64 32)
  %27 = add i64 %22, %16
  %28 = tail call i64 @llvm.fshl.i64(i64 %16, i64 %16, i64 16)
  %29 = xor i64 %28, %27
  %30 = add i64 %26, %29
  %31 = tail call i64 @llvm.fshl.i64(i64 %29, i64 %29, i64 21)
  %32 = xor i64 %31, %30
  %33 = add i64 %25, %27
  %34 = tail call i64 @llvm.fshl.i64(i64 %25, i64 %25, i64 17)
  %35 = xor i64 %34, %33
  %36 = tail call i64 @llvm.fshl.i64(i64 %33, i64 %33, i64 32)
  %37 = add i64 %35, %30
  %38 = tail call i64 @llvm.fshl.i64(i64 %35, i64 %35, i64 13)
  %39 = xor i64 %38, %37
  %40 = tail call i64 @llvm.fshl.i64(i64 %37, i64 %37, i64 32)
  %41 = add i64 %36, %32
  %42 = tail call i64 @llvm.fshl.i64(i64 %32, i64 %32, i64 16)
  %43 = xor i64 %42, %41
  %44 = add i64 %40, %43
  %45 = tail call i64 @llvm.fshl.i64(i64 %43, i64 %43, i64 21)
  %46 = xor i64 %45, %44
  %47 = add i64 %39, %41
  %48 = tail call i64 @llvm.fshl.i64(i64 %39, i64 %39, i64 17)
  %49 = xor i64 %48, %47
  %50 = tail call i64 @llvm.fshl.i64(i64 %47, i64 %47, i64 32)
  %51 = add i64 %49, %44
  %52 = tail call i64 @llvm.fshl.i64(i64 %49, i64 %49, i64 13)
  %53 = xor i64 %52, %51
  %54 = tail call i64 @llvm.fshl.i64(i64 %51, i64 %51, i64 32)
  %55 = add i64 %50, %46
  %56 = tail call i64 @llvm.fshl.i64(i64 %46, i64 %46, i64 16)
  %57 = xor i64 %56, %55
  %58 = add i64 %54, %57
  %59 = tail call i64 @llvm.fshl.i64(i64 %57, i64 %57, i64 21)
  %60 = xor i64 %59, %58
  %61 = add i64 %53, %55
  %62 = tail call i64 @llvm.fshl.i64(i64 %53, i64 %53, i64 17)
  %63 = xor i64 %62, %61
  %64 = tail call i64 @llvm.fshl.i64(i64 %61, i64 %61, i64 32)
  store i64 %60, ptr %._core._state.v3, align 8
  store i64 %64, ptr %._core._state.v2, align 8
  store i64 %63, ptr %._core._state.v1, align 8
  store i64 %58, ptr %._core._state, align 8
  %65 = xor i64 %63, %58
  %66 = xor i64 %65, %64
  %67 = xor i64 %66, %60
  %68 = trunc i64 %67 to i32
  ret i32 %68
}

; Function Attrs: minsize nounwind optsize sspreq
define linkonce_odr hidden void @"$es32_swift_stdlib_Hashing_parameters_WZ"(ptr %0) #5 {
entry:
  %1 = alloca %Ts6UInt64V, align 8
  %2 = alloca %Ts6UInt64V, align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %1)
  store i64 0, ptr %1, align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %2)
  store i64 0, ptr %2, align 8
  call void @arc4random_buf(ptr nonnull %1, i32 8)
  call void @arc4random_buf(ptr nonnull %2, i32 8)
  %3 = load i64, ptr %1, align 8
  %4 = load i64, ptr %2, align 8
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %2)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %1)
  store i64 %3, ptr @"$es32_swift_stdlib_Hashing_parametersSo06_SwiftC10ParametersVvp", align 8
  store i64 %4, ptr getelementptr inbounds nuw (i8, ptr @"$es32_swift_stdlib_Hashing_parametersSo06_SwiftC10ParametersVvp", i32 8), align 8
  store i8 0, ptr getelementptr inbounds nuw (i8, ptr @"$es32_swift_stdlib_Hashing_parametersSo06_SwiftC10ParametersVvp", i32 16), align 8
  ret void
}

; Function Attrs: minsize nounwind optsize sspreq
define weak_odr protected swiftcc { ptr, ptr } @swift_allocBox(ptr %0) local_unnamed_addr #5 {
entry:
  %1 = alloca %TSvSg, align 4
  %arrayidx.i.i = getelementptr inbounds i8, ptr %0, i32 -4
  %2 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !6
  %flags1.i.i = getelementptr inbounds nuw i8, ptr %2, i32 40
  %3 = load i32, ptr %flags1.i.i, align 4, !tbaa !11
  %and.i.i = and i32 %3, 255
  %size.i = getelementptr inbounds nuw i8, ptr %2, i32 32
  %4 = load i32, ptr %size.i, align 4, !tbaa !14
  %5 = add nuw nsw i32 %and.i.i, 8
  %6 = xor i32 %and.i.i, -1
  %7 = and i32 %5, %6
  %8 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %7, i32 %4)
  %9 = extractvalue { i32, i1 } %8, 1
  br i1 %9, label %23, label %10, !prof !15

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
  tail call void @llvm.trap() #16
  unreachable

24:                                               ; preds = %10
  call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc { ptr, ptr } @swift_makeBoxUnique(ptr %0, ptr %1, i32 %2) local_unnamed_addr #1 {
entry:
  %3 = load ptr, ptr %0, align 4
  %4 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %2, i32 8)
  %5 = extractvalue { i32, i1 } %4, 1
  br i1 %5, label %27, label %6, !prof !15

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
  %20 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !6
  %initializeWithCopyFn.i = getelementptr inbounds nuw i8, ptr %20, i32 8
  %21 = load ptr, ptr %initializeWithCopyFn.i, align 4, !tbaa !18
  %call1.i = tail call ptr %21(ptr noundef %19, ptr noundef %10, ptr noundef %1) #17
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
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden void @swift_releaseBox(ptr %0) local_unnamed_addr #1 {
entry:
  %1 = icmp eq ptr %0, null
  br i1 %1, label %22, label %2, !prof !15

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
  br i1 %10, label %23, label %11, !prof !15

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
  %18 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !6
  %flags1.i.i.i = getelementptr inbounds nuw i8, ptr %18, i32 40
  %19 = load i32, ptr %flags1.i.i.i, align 4, !tbaa !11
  %and.i.i.i = and i32 %19, 255
  %add.i.i = add nuw nsw i32 %and.i.i.i, 8
  %not.i.i = xor i32 %and.i.i.i, -1
  %and.i.i = and i32 %add.i.i, %not.i.i
  %add.ptr.i.i = getelementptr inbounds nuw i8, ptr %0, i32 %and.i.i
  %destroyFn.i = getelementptr inbounds nuw i8, ptr %18, i32 4
  %20 = load ptr, ptr %destroyFn.i, align 4, !tbaa !19
  tail call void %20(ptr noundef nonnull %add.ptr.i.i, ptr noundef %17) #17
  br label %21

21:                                               ; preds = %11, %2, %15
  ret void

22:                                               ; preds = %entry
  tail call void @llvm.trap() #16
  unreachable

23:                                               ; preds = %7
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocBox(ptr %0) local_unnamed_addr #1 {
entry:
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_allocEmptyBox() local_unnamed_addr #1 {
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
define weak_odr protected ptr @swift_allocObject(ptr %0, i32 %1, i32 %2) local_unnamed_addr #1 {
entry:
  %3 = tail call swiftcc ptr @"$es17swift_allocObject8metadata12requiredSize0E13AlignmentMaskSpys04HeapC0VGSpys13ClassMetadataVG_S2itF"(ptr %0, i32 %1, i32 %2)
  ret ptr %3
}

; Function Attrs: minsize nounwind optsize sspreq
define linkonce_odr hidden swiftcc ptr @"$es17swift_allocObject8metadata12requiredSize0E13AlignmentMaskSpys04HeapC0VGSpys13ClassMetadataVG_S2itF"(ptr %0, i32 %1, i32 %2) local_unnamed_addr #5 {
entry:
  %3 = alloca %TSvSg, align 4
  %4 = icmp eq i32 %2, -1
  br i1 %4, label %10, label %5

5:                                                ; preds = %entry
  %6 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %2, i32 1)
  %7 = extractvalue { i32, i1 } %6, 1
  br i1 %7, label %17, label %8, !prof !15

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
  tail call void @llvm.trap() #16
  unreachable

18:                                               ; preds = %10
  call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_allocObjectTyped(ptr %0, i32 %1, i32 %2, i64 %3) local_unnamed_addr #1 {
entry:
  %4 = tail call swiftcc ptr @"$es17swift_allocObject8metadata12requiredSize0E13AlignmentMaskSpys04HeapC0VGSpys13ClassMetadataVG_S2itF"(ptr %0, i32 %1, i32 %2)
  ret ptr %4
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_initStackObject(ptr %0, ptr %1) local_unnamed_addr #1 {
entry:
  store ptr %0, ptr %1, align 4, !tbaa !16
  %.refcount = getelementptr inbounds nuw i8, ptr %1, i32 4
  store i32 -2147483647, ptr %.refcount, align 4
  ret ptr %1
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_initStaticObject(ptr %0, ptr %1) local_unnamed_addr #1 {
entry:
  store ptr %0, ptr %1, align 4, !tbaa !16
  %.refcount = getelementptr inbounds nuw i8, ptr %1, i32 4
  store i32 -1, ptr %.refcount, align 4
  ret ptr %1
}

; Function Attrs: minsize nounwind optsize
define private void @0(ptr %0, i32 %1, i32 %2) local_unnamed_addr #1 {
entry:
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocClassInstance(ptr %0, i32 %1, i32 %2) local_unnamed_addr #1 {
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
define weak_odr protected void @swift_deallocPartialClassInstance(ptr %0, ptr %1, i32 %2, i32 %3) local_unnamed_addr #1 {
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
  tail call swiftcc void %8(ptr noundef nonnull swiftself %0) #17
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
define weak_odr protected ptr @swift_slowAlloc(i32 %0, i32 %1) local_unnamed_addr #5 {
entry:
  %2 = alloca %TSvSg, align 4
  %3 = icmp eq i32 %1, -1
  br i1 %3, label %9, label %4

4:                                                ; preds = %entry
  %5 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %1, i32 1)
  %6 = extractvalue { i32, i1 } %5, 1
  br i1 %6, label %14, label %7, !prof !15

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
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc void @swift_willThrow(ptr swiftself %0, ptr noalias swifterror captures(none) dereferenceable(4) %1) local_unnamed_addr #1 {
entry:
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc void @swift_errorInMain(ptr %0) local_unnamed_addr #1 {
entry:
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc void @swift_unexpectedError(ptr %0, ptr %1, i32 %2, i1 %3, i32 %4) local_unnamed_addr #1 {
entry:
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_release_n(ptr %0, i32 %1) local_unnamed_addr #1 {
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
  br i1 %9, label %23, label %10, !prof !15

10:                                               ; preds = %8
  %11 = atomicrmw sub ptr %4, i32 %1 acq_rel, align 4
  %12 = tail call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 %11, i32 %1)
  %13 = extractvalue { i32, i1 } %12, 1
  br i1 %13, label %24, label %14, !prof !15

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
  tail call swiftcc void %21(ptr noundef nonnull swiftself %0) #17
  br label %22

22:                                               ; preds = %14, %entry, %3, %18
  ret void

23:                                               ; preds = %8
  tail call void @llvm.trap() #16
  unreachable

24:                                               ; preds = %10
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_setDeallocating(ptr %0) local_unnamed_addr #1 {
entry:
  ret void
}

; Function Attrs: minsize nounwind optsize
define private ptr @1(ptr %0, i32 %1) local_unnamed_addr #1 {
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
  br i1 %9, label %13, label %10, !prof !15

10:                                               ; preds = %8
  %11 = atomicrmw add ptr %4, i32 %1 monotonic, align 4
  br label %12

12:                                               ; preds = %entry, %3, %10
  ret ptr %0

13:                                               ; preds = %8
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_bridgeObjectRelease_n(ptr %0, i32 %1) local_unnamed_addr #1 {
entry:
  tail call void @swift_release_n(ptr %0, i32 %1)
  ret void
}

; Function Attrs: minsize nounwind optsize
define private ptr @2(ptr %0) local_unnamed_addr #1 {
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
define weak_odr protected void @swift_bridgeObjectRelease(ptr %0) local_unnamed_addr #1 {
entry:
  tail call void @swift_release_n(ptr %0, i32 1)
  ret void
}

; Function Attrs: minsize nounwind optsize
define private void @3(ptr %0) local_unnamed_addr #1 {
  tail call void @swift_releaseTm(ptr %0) #1
  ret void
}

; Function Attrs: minsize nounwind optsize
define internal void @swift_releaseTm(ptr %0) local_unnamed_addr #1 {
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
  br i1 %10, label %20, label %11, !prof !15

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
  tail call swiftcc void %18(ptr noundef nonnull swiftself %0) #17
  br label %19

19:                                               ; preds = %11, %entry, %2, %15
  ret void

20:                                               ; preds = %7
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected zeroext i1 @swift_isUniquelyReferenced_native(ptr %0) local_unnamed_addr #1 {
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
define weak_odr protected zeroext i1 @swift_isUniquelyReferenced_nonNull_native(ptr %0) local_unnamed_addr #1 {
entry:
  %1 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %2 = load atomic i32, ptr %1 acquire, align 4
  %3 = icmp eq i32 %2, 1
  ret i1 %3
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected zeroext i1 @swift_isEscapingClosureAtFileLocation(ptr %0, ptr %1, i32 %2, i32 %3, i32 %4, i32 %5) local_unnamed_addr #1 {
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
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_dynamicCastClass(ptr %0, ptr %1) local_unnamed_addr #1 {
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
define weak_odr protected ptr @swift_dynamicCastClassUnconditional(ptr %0, ptr %1, ptr %2, i32 %3, i32 %4) local_unnamed_addr #1 {
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
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected zeroext i1 @swift_dynamicCast(ptr %0, ptr %1, ptr %2, ptr %3, i32 %4) local_unnamed_addr #1 {
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
  %14 = load ptr, ptr %arrayidx.i.i2, align 4, !tbaa !6
  %destroyFn.i3 = getelementptr inbounds nuw i8, ptr %14, i32 4
  %15 = load ptr, ptr %destroyFn.i3, align 4, !tbaa !19
  tail call void %15(ptr noundef %1, ptr noundef %2) #17
  br label %16

16:                                               ; preds = %.sink.split, %12, %9, %entry
  %17 = phi i1 [ true, %entry ], [ true, %9 ], [ false, %12 ], [ %.ph, %.sink.split ]
  ret i1 %17

18:                                               ; preds = %10
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc i8 @"$es7tryCast33_8BFEAB69C69C8B87ED137407D82370D4LL3dst0J8Metadata3src0lK013takeOnSuccesss07DynamicB6ResultABLLOSv_S3VSbtF"(ptr %0, ptr %1, ptr %2, ptr %3, i1 %4) local_unnamed_addr #1 {
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
  %38 = load ptr, ptr %arrayidx.i.i7, align 4, !tbaa !6
  br i1 %.tr12, label %41, label %39

39:                                               ; preds = %37
  %initializeWithCopyFn.i = getelementptr inbounds nuw i8, ptr %38, i32 8
  %40 = load ptr, ptr %initializeWithCopyFn.i, align 4, !tbaa !18
  %call1.i = tail call ptr %40(ptr noundef %0, ptr noundef %.tr10, ptr noundef %.tr11) #17
  br label %.loopexit

41:                                               ; preds = %37
  %initializeWithTakeFn.i = getelementptr inbounds nuw i8, ptr %38, i32 16
  %42 = load ptr, ptr %initializeWithTakeFn.i, align 4, !tbaa !22
  %call1.i8 = tail call ptr %42(ptr noundef %0, ptr noundef %.tr10, ptr noundef %.tr11) #17
  br label %.loopexit

.loopexit:                                        ; preds = %6, %6, %6, %26, %18, %24, %19, %8, %11, %41, %39
  %43 = phi i8 [ 1, %39 ], [ 2, %41 ], [ 0, %11 ], [ 0, %8 ], [ 1, %19 ], [ 1, %24 ], [ 2, %18 ], [ 0, %26 ], [ 0, %6 ], [ 0, %6 ], [ 0, %6 ]
  ret i8 %43
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc i8 @"$es12MetadataKindO8metadataABSgSV_tcfC"(ptr %0) local_unnamed_addr #1 {
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
define linkonce_odr hidden swiftcc i1 @"$es12MetadataKindO21__derived_enum_equalsySbAB_ABtFZ"(i8 %0, i8 %1) local_unnamed_addr #1 {
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
define linkonce_odr hidden swiftcc { ptr, ptr } @"$es29ExistentialTypeRepresentationO7projectySV8metadata_SV5valuetSVF"(ptr %0, i8 %1) local_unnamed_addr #1 {
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
  %7 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !6
  %flags1.i.i = getelementptr inbounds nuw i8, ptr %7, i32 40
  %8 = load i32, ptr %flags1.i.i, align 4, !tbaa !11
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
  %19 = load ptr, ptr %arrayidx.i.i7, align 4, !tbaa !6
  %flags.i = getelementptr inbounds nuw i8, ptr %19, i32 40
  %20 = load i32, ptr %flags.i, align 4, !tbaa !11
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
define weak_odr protected void @swift_once(ptr %0, ptr %1, ptr %2) local_unnamed_addr #1 {
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
  tail call void %1(ptr %2) #15
  store atomic i32 -1, ptr %0 release, align 4
  br label %.loopexit

.loopexit:                                        ; preds = %.preheader, %entry, %10
  ret void
}

; Function Attrs: minsize nounwind optsize sspreq
define weak_odr protected ptr @swift_coroFrameAlloc(i32 %0, i64 %1) local_unnamed_addr #5 {
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
define weak_odr protected void @swift_deletedMethodError() local_unnamed_addr #1 {
entry:
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc { ptr, ptr } @swift_allocError(ptr %0, ptr %1, ptr %2, i1 %3) local_unnamed_addr #1 {
entry:
  %arrayidx.i.i = getelementptr inbounds i8, ptr %0, i32 -4
  %4 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !6
  %flags1.i.i = getelementptr inbounds nuw i8, ptr %4, i32 40
  %5 = load i32, ptr %flags1.i.i, align 4, !tbaa !11
  %and.i.i = and i32 %5, 255
  %size.i = getelementptr inbounds nuw i8, ptr %4, i32 32
  %6 = load i32, ptr %size.i, align 4, !tbaa !14
  %7 = add nuw nsw i32 %and.i.i, 16
  %8 = xor i32 %and.i.i, -1
  %9 = and i32 %7, %8
  %10 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %9, i32 %6)
  %11 = extractvalue { i32, i1 } %10, 0
  %12 = extractvalue { i32, i1 } %10, 1
  br i1 %12, label %29, label %13, !prof !15

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
  %24 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !6
  %. = select i1 %3, i32 16, i32 8
  %initializeWithTakeFn.i = getelementptr inbounds nuw i8, ptr %24, i32 %.
  %25 = load ptr, ptr %initializeWithTakeFn.i, align 4, !tbaa !20
  %call1.i5 = tail call ptr %25(ptr noundef nonnull %22, ptr noundef nonnull %2, ptr noundef nonnull %0) #17
  br label %26

26:                                               ; preds = %.sink.split, %17
  %27 = insertvalue { ptr, ptr } undef, ptr %19, 0
  %28 = insertvalue { ptr, ptr } %27, ptr %22, 1
  ret { ptr, ptr } %28

29:                                               ; preds = %entry
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc void @"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvpfiyBpcfU_"(ptr %0) #1 {
entry:
  ret void
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc void @_swift_embedded_error_destroy_impl(ptr %0) #1 {
entry:
  %1 = tail call swiftcc { ptr, ptr, ptr } @"$es17_errorBoxContentsySV4type_SV11conformanceSV5valuetSVF"(ptr %0)
  %2 = extractvalue { ptr, ptr, ptr } %1, 0
  %3 = extractvalue { ptr, ptr, ptr } %1, 2
  %arrayidx.i.i = getelementptr inbounds i8, ptr %2, i32 -4
  %4 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !6
  %destroyFn.i = getelementptr inbounds nuw i8, ptr %4, i32 4
  %5 = load ptr, ptr %destroyFn.i, align 4, !tbaa !19
  tail call void %5(ptr noundef %3, ptr noundef %2) #17
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc { ptr, ptr, ptr } @"$es17_errorBoxContentsySV4type_SV11conformanceSV5valuetSVF"(ptr %0) local_unnamed_addr #1 {
entry:
  %1 = getelementptr inbounds nuw i8, ptr %0, i32 8
  %2 = load ptr, ptr %1, align 4
  %3 = getelementptr inbounds nuw i8, ptr %0, i32 12
  %4 = load ptr, ptr %3, align 4
  %arrayidx.i.i = getelementptr inbounds i8, ptr %2, i32 -4
  %5 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !6
  %flags1.i.i = getelementptr inbounds nuw i8, ptr %5, i32 40
  %6 = load i32, ptr %flags1.i.i, align 4, !tbaa !11
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
define weak_odr protected void @swift_deallocError(ptr %0, ptr %1) local_unnamed_addr #1 {
entry:
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_getErrorValue(ptr %0, ptr %1, ptr %2) local_unnamed_addr #1 {
entry:
  %3 = getelementptr inbounds nuw i8, ptr %0, i32 8
  %4 = load ptr, ptr %3, align 4
  %5 = getelementptr inbounds nuw i8, ptr %0, i32 12
  %6 = load ptr, ptr %5, align 4
  %arrayidx.i.i = getelementptr inbounds i8, ptr %4, i32 -4
  %7 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !6
  %flags1.i.i = getelementptr inbounds nuw i8, ptr %7, i32 40
  %8 = load i32, ptr %flags1.i.i, align 4, !tbaa !11
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
define weak_odr protected i32 @_swift_exceptionPersonality(i32 %0, i32 %1, i64 %2, ptr %3, ptr %4) #1 {
entry:
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize noinline nounwind optsize
define weak_odr protected void @swift_clearSensitive(ptr %0, i32 %1) local_unnamed_addr #6 {
entry:
  %2 = icmp slt i32 %1, 0
  br i1 %2, label %5, label %3, !prof !15

3:                                                ; preds = %entry
  %4 = icmp eq i32 %1, 0
  br i1 %4, label %.loopexit, label %.preheader.preheader

.preheader.preheader:                             ; preds = %3
  tail call void @llvm.memset.p0.i32(ptr align 1 %0, i8 0, i32 %1, i1 false)
  br label %.loopexit

.loopexit:                                        ; preds = %.preheader.preheader, %3
  ret void

5:                                                ; preds = %entry
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected i32 @swift_retainCount(ptr %0) local_unnamed_addr #1 {
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
define linkonce_odr hidden swiftcc void @"$es6HasherV8_combineyys6UInt32VF"(i32 %0, ptr swiftself captures(none) dereferenceable(72) %1) local_unnamed_addr #1 {
entry:
  %2 = zext i32 %0 to i64
  %3 = load i64, ptr %1, align 8
  %4 = lshr i64 %3, 56
  %5 = and i64 %4, 7
  %6 = shl nuw nsw i64 %5, 3
  %7 = icmp samesign ult i64 %5, 4
  br i1 %7, label %40, label %8

8:                                                ; preds = %entry
  %9 = and i64 %3, -72057594037927936
  %10 = add i64 %9, 288230376151711744
  %.not = icmp eq i64 %5, 4
  br i1 %.not, label %16, label %11

11:                                               ; preds = %8
  %12 = sub nsw i64 0, %6
  %13 = and i64 %12, 56
  %14 = lshr i64 %2, %13
  %15 = or disjoint i64 %14, %10
  br label %16

16:                                               ; preds = %8, %11
  %storemerge = phi i64 [ %15, %11 ], [ %10, %8 ]
  store i64 %storemerge, ptr %1, align 8
  %17 = and i64 %3, 72057594037927935
  %18 = shl i64 %2, %6
  %19 = or i64 %18, %17
  %._core._state = getelementptr inbounds nuw i8, ptr %1, i32 8
  %._core._state.v3 = getelementptr inbounds nuw i8, ptr %1, i32 32
  %20 = load i64, ptr %._core._state.v3, align 8
  %21 = xor i64 %20, %19
  %22 = load i64, ptr %._core._state, align 8
  %._core._state.v1 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %23 = load i64, ptr %._core._state.v1, align 8
  %24 = add i64 %23, %22
  %25 = tail call i64 @llvm.fshl.i64(i64 %23, i64 %23, i64 13)
  %26 = xor i64 %25, %24
  %27 = tail call i64 @llvm.fshl.i64(i64 %24, i64 %24, i64 32)
  %._core._state.v2 = getelementptr inbounds nuw i8, ptr %1, i32 24
  %28 = load i64, ptr %._core._state.v2, align 8
  %29 = add i64 %28, %21
  %30 = tail call i64 @llvm.fshl.i64(i64 %21, i64 %21, i64 16)
  %31 = xor i64 %29, %30
  %32 = add i64 %31, %27
  %33 = tail call i64 @llvm.fshl.i64(i64 %31, i64 %31, i64 21)
  %34 = xor i64 %33, %32
  store i64 %34, ptr %._core._state.v3, align 8
  %35 = add i64 %29, %26
  %36 = tail call i64 @llvm.fshl.i64(i64 %26, i64 %26, i64 17)
  %37 = xor i64 %36, %35
  store i64 %37, ptr %._core._state.v1, align 8
  %38 = tail call i64 @llvm.fshl.i64(i64 %35, i64 %35, i64 32)
  store i64 %38, ptr %._core._state.v2, align 8
  %39 = xor i64 %32, %19
  store i64 %39, ptr %._core._state, align 8
  br label %44

40:                                               ; preds = %entry
  %41 = shl nuw nsw i64 %2, %6
  %42 = or i64 %41, %3
  %43 = add i64 %42, 288230376151711744
  store i64 %43, ptr %1, align 8
  br label %44

44:                                               ; preds = %40, %16
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #7

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #7

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32) #8

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc void @"$es6HasherV8_combineyys6UInt16VF"(i16 %0, ptr swiftself captures(none) dereferenceable(72) %1) local_unnamed_addr #1 {
entry:
  %2 = zext i16 %0 to i64
  %3 = load i64, ptr %1, align 8
  %4 = lshr i64 %3, 56
  %5 = and i64 %4, 7
  %6 = shl nuw nsw i64 %5, 3
  %7 = icmp samesign ult i64 %5, 6
  br i1 %7, label %40, label %8

8:                                                ; preds = %entry
  %9 = and i64 %3, -72057594037927936
  %10 = add i64 %9, 144115188075855872
  %.not = icmp eq i64 %5, 6
  br i1 %.not, label %16, label %11

11:                                               ; preds = %8
  %12 = sub nsw i64 0, %6
  %13 = and i64 %12, 56
  %14 = lshr i64 %2, %13
  %15 = or disjoint i64 %14, %10
  br label %16

16:                                               ; preds = %8, %11
  %storemerge = phi i64 [ %15, %11 ], [ %10, %8 ]
  store i64 %storemerge, ptr %1, align 8
  %17 = and i64 %3, 72057594037927935
  %18 = shl i64 %2, %6
  %19 = or i64 %18, %17
  %._core._state = getelementptr inbounds nuw i8, ptr %1, i32 8
  %._core._state.v3 = getelementptr inbounds nuw i8, ptr %1, i32 32
  %20 = load i64, ptr %._core._state.v3, align 8
  %21 = xor i64 %20, %19
  %22 = load i64, ptr %._core._state, align 8
  %._core._state.v1 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %23 = load i64, ptr %._core._state.v1, align 8
  %24 = add i64 %23, %22
  %25 = tail call i64 @llvm.fshl.i64(i64 %23, i64 %23, i64 13)
  %26 = xor i64 %25, %24
  %27 = tail call i64 @llvm.fshl.i64(i64 %24, i64 %24, i64 32)
  %._core._state.v2 = getelementptr inbounds nuw i8, ptr %1, i32 24
  %28 = load i64, ptr %._core._state.v2, align 8
  %29 = add i64 %28, %21
  %30 = tail call i64 @llvm.fshl.i64(i64 %21, i64 %21, i64 16)
  %31 = xor i64 %29, %30
  %32 = add i64 %31, %27
  %33 = tail call i64 @llvm.fshl.i64(i64 %31, i64 %31, i64 21)
  %34 = xor i64 %33, %32
  store i64 %34, ptr %._core._state.v3, align 8
  %35 = add i64 %29, %26
  %36 = tail call i64 @llvm.fshl.i64(i64 %26, i64 %26, i64 17)
  %37 = xor i64 %36, %35
  store i64 %37, ptr %._core._state.v1, align 8
  %38 = tail call i64 @llvm.fshl.i64(i64 %35, i64 %35, i64 32)
  store i64 %38, ptr %._core._state.v2, align 8
  %39 = xor i64 %32, %19
  store i64 %39, ptr %._core._state, align 8
  br label %44

40:                                               ; preds = %entry
  %41 = shl i64 %2, %6
  %42 = or i64 %41, %3
  %43 = add i64 %42, 144115188075855872
  store i64 %43, ptr %1, align 8
  br label %44

44:                                               ; preds = %40, %16
  ret void
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc void @"$es6HasherV8_combineyys5UInt8VF"(i8 %0, ptr swiftself captures(none) dereferenceable(72) %1) local_unnamed_addr #1 {
entry:
  %2 = zext i8 %0 to i64
  %3 = load i64, ptr %1, align 8
  %4 = lshr i64 %3, 56
  %5 = and i64 %4, 7
  %6 = shl nuw nsw i64 %5, 3
  %.not = icmp eq i64 %5, 7
  br i1 %.not, label %7, label %32

7:                                                ; preds = %entry
  %8 = and i64 %3, -72057594037927936
  %9 = and i64 %3, 72057594037927935
  %10 = shl nuw i64 %2, %6
  %11 = or disjoint i64 %10, %9
  %._core._state = getelementptr inbounds nuw i8, ptr %1, i32 8
  %._core._state.v3 = getelementptr inbounds nuw i8, ptr %1, i32 32
  %12 = load i64, ptr %._core._state.v3, align 8
  %13 = xor i64 %12, %11
  %14 = load i64, ptr %._core._state, align 8
  %._core._state.v1 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %15 = load i64, ptr %._core._state.v1, align 8
  %16 = add i64 %15, %14
  %17 = tail call i64 @llvm.fshl.i64(i64 %15, i64 %15, i64 13)
  %18 = xor i64 %17, %16
  %19 = tail call i64 @llvm.fshl.i64(i64 %16, i64 %16, i64 32)
  %._core._state.v2 = getelementptr inbounds nuw i8, ptr %1, i32 24
  %20 = load i64, ptr %._core._state.v2, align 8
  %21 = add i64 %20, %13
  %22 = tail call i64 @llvm.fshl.i64(i64 %13, i64 %13, i64 16)
  %23 = xor i64 %21, %22
  %24 = add i64 %23, %19
  %25 = tail call i64 @llvm.fshl.i64(i64 %23, i64 %23, i64 21)
  %26 = xor i64 %25, %24
  store i64 %26, ptr %._core._state.v3, align 8
  %27 = add i64 %21, %18
  %28 = tail call i64 @llvm.fshl.i64(i64 %18, i64 %18, i64 17)
  %29 = xor i64 %28, %27
  store i64 %29, ptr %._core._state.v1, align 8
  %30 = tail call i64 @llvm.fshl.i64(i64 %27, i64 %27, i64 32)
  store i64 %30, ptr %._core._state.v2, align 8
  %31 = xor i64 %24, %11
  store i64 %31, ptr %._core._state, align 8
  br label %35

32:                                               ; preds = %entry
  %33 = shl nuw i64 %2, %6
  %34 = or i64 %33, %3
  br label %35

35:                                               ; preds = %32, %7
  %.sink.in = phi i64 [ %8, %7 ], [ %34, %32 ]
  %.sink = add i64 %.sink.in, 72057594037927936
  store i64 %.sink, ptr %1, align 8
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.ssub.with.overflow.i32(i32, i32) #8

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.smul.with.overflow.i32(i32, i32) #8

; Function Attrs: cold noreturn nounwind memory(inaccessiblemem: write)
declare void @llvm.trap() #9

; Function Attrs: minsize nofree nounwind optsize
declare i32 @posix_memalign(ptr, i32, i32) local_unnamed_addr #10

; Function Attrs: minsize mustprogress nounwind optsize willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr noundef captures(none)) local_unnamed_addr #11

; Function Attrs: minsize nounwind optsize
declare void @arc4random_buf(ptr, i32) local_unnamed_addr #1

; Function Attrs: inlinehint nounwind optsize
define internal swiftcc void @_swift_embedded_error_box_destroy(ptr noundef swiftself %object) #12 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %object, i32 8
  %1 = load ptr, ptr %0, align 4
  %arrayidx.i.i.i1 = getelementptr inbounds i8, ptr %1, i32 -4
  %2 = load ptr, ptr %arrayidx.i.i.i1, align 4, !tbaa !6
  %flags1.i.i.i = getelementptr inbounds nuw i8, ptr %2, i32 40
  %3 = load i32, ptr %flags1.i.i.i, align 4, !tbaa !11
  %and.i.i.i = and i32 %3, 255
  %4 = add nuw nsw i32 %and.i.i.i, 16
  %5 = xor i32 %and.i.i.i, -1
  %6 = and i32 %4, %5
  %7 = getelementptr inbounds nuw i8, ptr %object, i32 %6
  %destroyFn.i.i = getelementptr inbounds nuw i8, ptr %2, i32 4
  %8 = load ptr, ptr %destroyFn.i.i, align 4, !tbaa !19
  tail call void %8(ptr noundef %7, ptr noundef %1) #17
  tail call void @free(ptr %object)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.fshl.i64(i64, i64, i64) #13

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smax.i32(i32, i32) #13

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #14

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i32(ptr writeonly captures(none), i8, i32, i1 immarg) #14

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.umin.i8(i8, i8) #13

; Function Attrs: minsize nounwind optsize
define protected swiftcc void @"$e27GiftUIFoundationLayoutProbe5PointV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1, i32 %2) local_unnamed_addr #1 {
  tail call swiftcc void @"$e27GiftUIFoundationLayoutProbe4SizeV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1, i32 %2) #1
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e27GiftUIFoundationLayoutProbe17PointerSequenceIDV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) local_unnamed_addr #0 {
  %3 = tail call swiftcc i1 @"$e27GiftUIFoundationLayoutProbe12InputOrdinalV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) #0
  ret i1 %3
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e27GiftUIFoundationLayoutProbe20PresentationRevisionV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) local_unnamed_addr #0 {
  %3 = tail call swiftcc i1 @"$e27GiftUIFoundationLayoutProbe12InputOrdinalV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) #0
  ret i1 %3
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_retain(ptr %0) local_unnamed_addr #1 {
  %2 = tail call ptr @2(ptr %0) #1
  ret ptr %2
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_bridgeObjectRetain(ptr %0) local_unnamed_addr #1 {
  %2 = tail call ptr @2(ptr %0) #1
  ret ptr %2
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_errorRetain(ptr %0) local_unnamed_addr #1 {
  %2 = tail call ptr @2(ptr %0) #1
  ret ptr %2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e27GiftUIFoundationLayoutProbe5PointV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1, i32 %2, i32 %3) local_unnamed_addr #0 {
  %5 = tail call swiftcc i1 @"$e27GiftUIFoundationLayoutProbe4SizeV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1, i32 %2, i32 %3) #0
  ret i1 %5
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_retain_n(ptr %0, i32 %1) local_unnamed_addr #1 {
  %3 = tail call ptr @1(ptr %0, i32 %1) #1
  ret ptr %3
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_bridgeObjectRetain_n(ptr %0, i32 %1) local_unnamed_addr #1 {
  %3 = tail call ptr @1(ptr %0, i32 %1) #1
  ret ptr %3
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe5PointV9hashValueSivg"(i32 %0, i32 %1) local_unnamed_addr #1 {
  %3 = tail call swiftcc i32 @"$e27GiftUIFoundationLayoutProbe4SizeV9hashValueSivg"(i32 %0, i32 %1) #1
  ret i32 %3
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc void @"$e27GiftUIFoundationLayoutProbe17PointerSequenceIDV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) local_unnamed_addr #1 {
  tail call swiftcc void @"$e27GiftUIFoundationLayoutProbe12InputOrdinalV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) #1
  ret void
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc void @"$e27GiftUIFoundationLayoutProbe20PresentationRevisionV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) local_unnamed_addr #1 {
  tail call swiftcc void @"$e27GiftUIFoundationLayoutProbe12InputOrdinalV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) #1
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocUninitializedObject(ptr %0, i32 %1, i32 %2) local_unnamed_addr #1 {
  tail call void @0(ptr %0, i32 %1, i32 %2) #1
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocObject(ptr %0, i32 %1, i32 %2) local_unnamed_addr #1 {
  tail call void @0(ptr %0, i32 %1, i32 %2) #1
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_slowDealloc(ptr %0, i32 %1, i32 %2) local_unnamed_addr #1 {
  tail call void @0(ptr %0, i32 %1, i32 %2) #1
  ret void
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe17PointerSequenceIDV9hashValueSivg"(i32 %0) local_unnamed_addr #1 {
  %2 = tail call swiftcc i32 @"$e27GiftUIFoundationLayoutProbe12InputOrdinalV9hashValueSivg"(i32 %0) #1
  ret i32 %2
}

; Function Attrs: minsize nounwind optsize
define protected swiftcc i32 @"$e27GiftUIFoundationLayoutProbe20PresentationRevisionV9hashValueSivg"(i32 %0) local_unnamed_addr #1 {
  %2 = tail call swiftcc i32 @"$e27GiftUIFoundationLayoutProbe12InputOrdinalV9hashValueSivg"(i32 %0) #1
  ret i32 %2
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_release(ptr %0) local_unnamed_addr #1 {
  tail call void @3(ptr %0) #1
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_errorRelease(ptr %0) local_unnamed_addr #1 {
  tail call void @3(ptr %0) #1
  ret void
}

attributes #0 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #1 = { minsize nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #2 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #3 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #4 = { minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #5 = { minsize nounwind optsize sspreq "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #6 = { minsize noinline nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #7 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #8 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #9 = { cold noreturn nounwind memory(inaccessiblemem: write) }
attributes #10 = { minsize nofree nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #11 = { minsize mustprogress nounwind optsize willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #12 = { inlinehint nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #13 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #14 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #15 = { nounwind }
attributes #16 = { nomerge }
attributes #17 = { nounwind optsize }

!swift.module.flags = !{!0}
!llvm.module.flags = !{!1, !2, !3, !4, !5}
!llvm.linker.options = !{}

!0 = !{!"standard-library", i1 false}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 1, !"min_enum_size", i32 4}
!3 = !{i32 8, !"PIC Level", i32 2}
!4 = !{i32 4, !"Objective-C Garbage Collection", i32 100927232}
!5 = !{i32 1, !"Swift Version", i32 7}
!6 = !{!7, !8, i64 0}
!7 = !{!"", !8, i64 0}
!8 = !{!"any pointer", !9, i64 0}
!9 = !{!"omnipotent char", !10, i64 0}
!10 = !{!"Simple C/C++ TBAA"}
!11 = !{!12, !13, i64 40}
!12 = !{!"", !8, i64 0, !8, i64 4, !8, i64 8, !8, i64 12, !8, i64 16, !8, i64 20, !8, i64 24, !8, i64 28, !13, i64 32, !13, i64 36, !13, i64 40}
!13 = !{!"int", !9, i64 0}
!14 = !{!12, !13, i64 32}
!15 = !{!"branch_weights", !"expected", i32 1, i32 2000}
!16 = !{!17, !8, i64 0}
!17 = !{!"EmbeddedHeapObject", !8, i64 0}
!18 = !{!12, !8, i64 8}
!19 = !{!12, !8, i64 4}
!20 = !{!8, !8, i64 0}
!21 = !{!"branch_weights", !"expected", i32 2000, i32 1}
!22 = !{!12, !8, i64 16}
