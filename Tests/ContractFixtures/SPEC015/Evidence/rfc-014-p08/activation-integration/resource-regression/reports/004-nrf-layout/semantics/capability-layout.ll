; ModuleID = '/Users/eugene/work/GiftUI/.build/rfc-014-swift64/resource-regression/004-nrf-layout/semantics/capability-layout.ll'
source_filename = "/Users/eugene/work/GiftUI/.build/rfc-014-swift64/resource-regression/004-nrf-layout/semantics/capability-layout.ll"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-none-eabihf"

%T27GiftUICapabilityLayoutProbe18RasterOperationSetV = type <{ %Ts5UInt8V }>
%Ts5UInt8V = type <{ i8 }>
%T27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV = type <{ %Ts5UInt8V }>
%T27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV = type <{ %Ts5UInt8V }>
%T27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV = type <{ %Ts5UInt8V }>
%T27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV = type <{ %Ts5UInt8V }>
%TSi = type <{ i32 }>
%TSb = type <{ i1 }>
%swift.function = type { ptr, ptr }
%T27GiftUICapabilityLayoutProbe29RasterPresentationRequirementVSg = type <{ [25 x i8] }>
%T27GiftUICapabilityLayoutProbe29RasterRealizationContributionVSg = type <{ [24 x i8] }>
%T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV = type <{ %T27GiftUICapabilityLayoutProbe21RasterRealizationKindO, %T27GiftUICapabilityLayoutProbe18RasterOperationSetV, %T27GiftUICapabilityLayoutProbe23OperationStreamLifetimeO, %T27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV, %T27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV, [1 x i8], %T27GiftUICapabilityLayoutProbe16CapabilityExtentV, %Ts6UInt16V, %Ts6UInt16V, %Ts6UInt16V, %T27GiftUICapabilityLayoutProbe19CapabilityByteCountV, %T27GiftUICapabilityLayoutProbe19CapabilityByteCountV }>
%T27GiftUICapabilityLayoutProbe21RasterRealizationKindO = type <{ i8 }>
%T27GiftUICapabilityLayoutProbe23OperationStreamLifetimeO = type <{ i8 }>
%T27GiftUICapabilityLayoutProbe16CapabilityExtentV = type <{ %Ts6UInt16V, %Ts6UInt16V }>
%Ts6UInt16V = type <{ i16 }>
%T27GiftUICapabilityLayoutProbe19CapabilityByteCountV = type <{ %Ts6UInt32V }>
%Ts6UInt32V = type <{ i32 }>
%T27GiftUICapabilityLayoutProbe25RasterBackendContributionVSg = type <{ [48 x i8] }>
%T27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionVSg = type <{ [20 x i8], [1 x i8] }>
%T27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV = type <{ %T27GiftUICapabilityLayoutProbe26RenderProducerContributionVSg, [2 x i8], %T27GiftUICapabilityLayoutProbe25RasterBackendContributionVSg, %T27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionVSg, [3 x i8], %T27GiftUICapabilityLayoutProbe24RasterPresentationPolicyVSg, %Ts5UInt8V }>
%T27GiftUICapabilityLayoutProbe26RenderProducerContributionVSg = type <{ [2 x i8] }>
%T27GiftUICapabilityLayoutProbe24RasterPresentationPolicyVSg = type <{ [16 x i8] }>
%T27GiftUICapabilityLayoutProbe25RasterBackendContributionV = type <{ %T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV, %T27GiftUICapabilityLayoutProbe29RasterRealizationContributionVSg }>
%T27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV = type <{ %T27GiftUICapabilityLayoutProbe16CapabilityExtentV, %T27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV, %T27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV, %T27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV, [1 x i8], %Ts6UInt16V, %Ts6UInt16V, %Ts6UInt16V, %Ts5UInt8V, [1 x i8], %T27GiftUICapabilityLayoutProbe19CapabilityByteCountV }>
%T27GiftUICapabilityLayoutProbe31RasterPresentationCandidatePathV = type <{ %T27GiftUICapabilityLayoutProbe21RasterRealizationKindO, %T27GiftUICapabilityLayoutProbe22CanonicalPixelEncodingO, %T27GiftUICapabilityLayoutProbe18SubmissionLifetimeO, %T27GiftUICapabilityLayoutProbe17SubmissionHandoffO, %T27GiftUICapabilityLayoutProbe33RasterPresentationArithmeticValueV }>
%T27GiftUICapabilityLayoutProbe22CanonicalPixelEncodingO = type <{ i8 }>
%T27GiftUICapabilityLayoutProbe18SubmissionLifetimeO = type <{ i8 }>
%T27GiftUICapabilityLayoutProbe17SubmissionHandoffO = type <{ i8 }>
%T27GiftUICapabilityLayoutProbe33RasterPresentationArithmeticValueV = type <{ %Ts6UInt32V, %T27GiftUICapabilityLayoutProbe16CapabilityExtentV, %T27GiftUICapabilityLayoutProbe19CapabilityByteCountV, %T27GiftUICapabilityLayoutProbe19CapabilityByteCountV, %T27GiftUICapabilityLayoutProbe19CapabilityByteCountV, %T27GiftUICapabilityLayoutProbe19CapabilityByteCountV }>
%T27GiftUICapabilityLayoutProbe34RasterPresentationCandidateOutcomeO = type <{ [28 x i8] }>
%T27GiftUICapabilityLayoutProbe37NormalizedRasterPresentationCandidateVSg = type <{ [24 x i8] }>
%T27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceVSg = type <{ [52 x i8] }>
%T27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV = type <{ %T27GiftUICapabilityLayoutProbe18RasterOperationSetV, [1 x i8], %T27GiftUICapabilityLayoutProbe16CapabilityExtentV, %T27GiftUICapabilityLayoutProbe16CapabilityExtentV, [2 x i8], %T27GiftUICapabilityLayoutProbe19CapabilityByteCountV, %T27GiftUICapabilityLayoutProbe23OperationStreamLifetimeO, %T27GiftUICapabilityLayoutProbe22CanonicalPixelEncodingO, %T27GiftUICapabilityLayoutProbe18SubmissionLifetimeO, %T27GiftUICapabilityLayoutProbe17SubmissionHandoffO, %T27GiftUICapabilityLayoutProbe21RasterRealizationKindO, [3 x i8], %T27GiftUICapabilityLayoutProbe19CapabilityByteCountV, %T27GiftUICapabilityLayoutProbe19CapabilityByteCountV, %Ts5UInt8V, [3 x i8], %T27GiftUICapabilityLayoutProbe19CapabilityByteCountV }>
%T27GiftUICapabilityLayoutProbe28RasterPresentationResolutionO = type <{ [40 x i8] }>
%T27GiftUICapabilityLayoutProbe37NormalizedRasterPresentationCandidateV = type <{ %T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV }>
%T27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationVSg = type <{ [40 x i8] }>
%T27GiftUICapabilityLayoutProbe18CapabilitySnapshotV = type <{ %T27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationVSg }>
%TSvSg = type <{ [4 x i8] }>

@"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV16opaqueRectanglesACvpZ" = protected constant %T27GiftUICapabilityLayoutProbe18RasterOperationSetV <{ %Ts5UInt8V <{ i8 1 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV14positionedTextACvpZ" = protected constant %T27GiftUICapabilityLayoutProbe18RasterOperationSetV <{ %Ts5UInt8V <{ i8 2 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV19straightLineStrokesACvpZ" = protected constant %T27GiftUICapabilityLayoutProbe18RasterOperationSetV <{ %Ts5UInt8V <{ i8 4 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV8clippingACvpZ" = protected constant %T27GiftUICapabilityLayoutProbe18RasterOperationSetV <{ %Ts5UInt8V <{ i8 8 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV6damageACvpZ" = protected constant %T27GiftUICapabilityLayoutProbe18RasterOperationSetV <{ %Ts5UInt8V <{ i8 16 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV15rgb565BigEndianACvpZ" = protected constant %T27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV <{ %Ts5UInt8V <{ i8 1 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV8rgba8888ACvpZ" = protected constant %T27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV <{ %Ts5UInt8V <{ i8 2 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV17synchronousBorrowACvpZ" = protected constant %T27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV <{ %Ts5UInt8V <{ i8 1 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV15synchronousCopyACvpZ" = protected constant %T27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV <{ %Ts5UInt8V <{ i8 2 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV17ownershipTransferACvpZ" = protected constant %T27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV <{ %Ts5UInt8V <{ i8 4 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV11synchronousACvpZ" = protected constant %T27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV <{ %Ts5UInt8V <{ i8 1 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV6queuedACvpZ" = protected constant %T27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV <{ %Ts5UInt8V <{ i8 2 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV11fullSurfaceACvpZ" = protected constant %T27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV <{ %Ts5UInt8V <{ i8 1 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV5tiledACvpZ" = protected constant %T27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV <{ %Ts5UInt8V <{ i8 2 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV8capacitys5UInt8VvpZ" = protected constant %Ts5UInt8V <{ i8 4 }>, align 1
@"$e27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceV17candidateCapacitys5UInt8VvpZ" = protected constant %Ts5UInt8V <{ i8 2 }>, align 1
@"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV11allDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLACvpZ" = protected local_unnamed_addr constant %T27GiftUICapabilityLayoutProbe18RasterOperationSetV <{ %Ts5UInt8V <{ i8 31 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV11allDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLACvpZ" = protected local_unnamed_addr constant %T27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV <{ %Ts5UInt8V <{ i8 3 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV11allDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLACvpZ" = protected local_unnamed_addr constant %T27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV <{ %Ts5UInt8V <{ i8 7 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV11allDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLACvpZ" = protected local_unnamed_addr constant %T27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV <{ %Ts5UInt8V <{ i8 3 }> }>, align 1
@"$e27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV11allDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLACvpZ" = protected local_unnamed_addr constant %T27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV <{ %Ts5UInt8V <{ i8 3 }> }>, align 1
@"$es16_emptyBoxStorageSi_Sitvp" = linkonce_odr protected global <{ %TSi, %TSi }> <{ %TSi zeroinitializer, %TSi <{ i32 -1 }> }>, align 4
@_swift_embedded_error_metadata_storage = weak_odr protected global <{ i32, i32, i32 }> zeroinitializer, align 4
@"$es25_errorMetadataInitialized33_21ED9D60359C2E63A6128CFAED697BD0LLSbvp" = linkonce_odr protected local_unnamed_addr global %TSb zeroinitializer, align 1
@"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvp" = linkonce_odr protected local_unnamed_addr global %swift.function { ptr @"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvpfiyBpcfU_", ptr null }, align 4
@_swift1_autolink_entries = private constant [0 x i8] zeroinitializer, section ".swift1_autolink_entries", no_sanitize_address, align 4
@llvm.used = appending global [2 x ptr] [ptr @_swift1_autolink_entries, ptr @_swift_exceptionPersonality], section "llvm.metadata"

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i16 @"$e27GiftUICapabilityLayoutProbe16CapabilityExtentV5widths6UInt16Vvg"(i32 %0) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i32 %0 to i16
  ret i16 %temp-coercion.coerced.sroa.0.0.extract.trunc
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #1

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i16 @"$e27GiftUICapabilityLayoutProbe16CapabilityExtentV6heights6UInt16Vvg"(i32 %0) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.3.0.extract.shift = lshr i32 %0, 16
  %temp-coercion.coerced.sroa.3.0.extract.trunc = trunc nuw i32 %temp-coercion.coerced.sroa.3.0.extract.shift to i16
  ret i16 %temp-coercion.coerced.sroa.3.0.extract.trunc
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i8 } @"$e27GiftUICapabilityLayoutProbe16CapabilityExtentV5width6heightACSgs6UInt16V_AHtcfC"(i16 %0, i16 %1) local_unnamed_addr #0 {
entry:
  %2 = icmp eq i16 %0, 0
  %3 = icmp eq i16 %1, 0
  %or.cond.not = select i1 %2, i1 true, i1 %3
  %4 = zext i16 %0 to i32
  %5 = zext i16 %1 to i32
  %6 = shl nuw i32 %5, 16
  %7 = or disjoint i32 %6, %4
  %8 = select i1 %or.cond.not, i32 0, i32 %7
  %9 = zext i1 %or.cond.not to i8
  %10 = insertvalue { i32, i8 } undef, i32 %8, 0
  %11 = insertvalue { i32, i8 } %10, i8 %9, 1
  ret { i32, i8 } %11
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe16CapabilityExtentV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) local_unnamed_addr #0 {
entry:
  %2 = icmp eq i32 %0, %1
  ret i1 %2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe19CapabilityByteCountV8rawValues6UInt32Vvg"(i32 returned %0) local_unnamed_addr #0 {
entry:
  ret i32 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe19CapabilityByteCountV8rawValueACs6UInt32V_tcfC"(i32 returned %0) local_unnamed_addr #0 {
entry:
  ret i32 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe19CapabilityByteCountV1loiySbAC_ACtFZ"(i32 %0, i32 %1) local_unnamed_addr #0 {
entry:
  %2 = icmp ult i32 %0, %1
  ret i1 %2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV8rawValues5UInt8Vvg"(i8 returned %0) local_unnamed_addr #0 {
entry:
  ret i8 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV8rawValueACs5UInt8V_tcfC"(i8 returned %0) local_unnamed_addr #0 {
entry:
  ret i8 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV16opaqueRectanglesACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV16opaqueRectanglesACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV16opaqueRectanglesACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV14positionedTextACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV14positionedTextACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV14positionedTextACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV19straightLineStrokesACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV19straightLineStrokesACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV19straightLineStrokesACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 4
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV8clippingACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV8clippingACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV8clippingACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 8
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV6damageACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV6damageACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe18RasterOperationSetV6damageACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 16
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV8rawValues5UInt8Vvg"(i8 returned %0) local_unnamed_addr #0 {
entry:
  ret i8 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV8rawValueACs5UInt8V_tcfC"(i8 returned %0) local_unnamed_addr #0 {
entry:
  ret i8 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV15rgb565BigEndianACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV15rgb565BigEndianACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV15rgb565BigEndianACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV8rgba8888ACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV8rgba8888ACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV8rgba8888ACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV8rawValues5UInt8Vvg"(i8 returned %0) local_unnamed_addr #0 {
entry:
  ret i8 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV8rawValueACs5UInt8V_tcfC"(i8 returned %0) local_unnamed_addr #0 {
entry:
  ret i8 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV17synchronousBorrowACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV17synchronousBorrowACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV17synchronousBorrowACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV15synchronousCopyACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV15synchronousCopyACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV15synchronousCopyACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV17ownershipTransferACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV17ownershipTransferACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe21SubmissionLifetimeSetV17ownershipTransferACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 4
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV8rawValues5UInt8Vvg"(i8 returned %0) local_unnamed_addr #0 {
entry:
  ret i8 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV8rawValueACs5UInt8V_tcfC"(i8 returned %0) local_unnamed_addr #0 {
entry:
  ret i8 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV11synchronousACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV11synchronousACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV11synchronousACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV6queuedACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV6queuedACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe20SubmissionHandoffSetV6queuedACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationRequirementV10operationsAA0E12OperationSetVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(25) %0) local_unnamed_addr #2 {
entry:
  %1 = load i8, ptr %0, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationRequirementV6extentAA16CapabilityExtentVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(25) %0) local_unnamed_addr #2 {
entry:
  %.extent = getelementptr inbounds nuw i8, ptr %0, i32 2
  %1 = load i32, ptr %.extent, align 2
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationRequirementV15operationStreamAA09OperationI8LifetimeOvg"(ptr noalias readonly swiftself captures(none) dereferenceable(25) %0) local_unnamed_addr #2 {
entry:
  %.operationStream = getelementptr inbounds nuw i8, ptr %0, i32 6
  %1 = load i8, ptr %.operationStream, align 2
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationRequirementV17acceptedEncodingsAA25CanonicalPixelEncodingSetVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(25) %0) local_unnamed_addr #2 {
entry:
  %.acceptedEncodings = getelementptr inbounds nuw i8, ptr %0, i32 7
  %1 = load i8, ptr %.acceptedEncodings, align 1
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationRequirementV27acceptedSubmissionLifetimesAA0I11LifetimeSetVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(25) %0) local_unnamed_addr #2 {
entry:
  %.acceptedSubmissionLifetimes = getelementptr inbounds nuw i8, ptr %0, i32 8
  %1 = load i8, ptr %.acceptedSubmissionLifetimes, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationRequirementV07maximumE5BytesAA19CapabilityByteCountVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(25) %0) local_unnamed_addr #2 {
entry:
  %.maximumRasterBytes = getelementptr inbounds nuw i8, ptr %0, i32 12
  %1 = load i32, ptr %.maximumRasterBytes, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationRequirementV19maximumPayloadBytesAA19CapabilityByteCountVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(25) %0) local_unnamed_addr #2 {
entry:
  %.maximumPayloadBytes = getelementptr inbounds nuw i8, ptr %0, i32 16
  %1 = load i32, ptr %.maximumPayloadBytes, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationRequirementV20maximumInFlightBytesAA19CapabilityByteCountVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(25) %0) local_unnamed_addr #2 {
entry:
  %.maximumInFlightBytes = getelementptr inbounds nuw i8, ptr %0, i32 20
  %1 = load i32, ptr %.maximumInFlightBytes, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationRequirementV7absenceAA17CapabilityAbsenceOvg"(ptr noalias readonly swiftself captures(none) dereferenceable(25) %0) local_unnamed_addr #2 {
entry:
  %.absence = getelementptr inbounds nuw i8, ptr %0, i32 24
  %1 = load i8, ptr %.absence, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe29RasterPresentationRequirementV10operations6extent15operationStream17acceptedEncodings0L19SubmissionLifetimes07maximumE5Bytes0p7PayloadQ00p8InFlightQ07absenceACSgAA0E12OperationSetV_AA16CapabilityExtentVAA0vK8LifetimeOAA022CanonicalPixelEncodingW0VAA0nzW0VAA0X9ByteCountVA2yA0X7AbsenceOtcfC"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe29RasterPresentationRequirementVSg) captures(none) initializes((0, 25)) %0, i8 %1, i32 %2, i8 %3, i8 %4, i8 %5, i32 %6, i32 %7, i32 %8, i8 %9) local_unnamed_addr #3 {
entry:
  %10 = icmp eq i8 %1, 31
  %11 = icmp eq i8 %3, 0
  %or.cond = select i1 %10, i1 %11, i1 false
  %12 = add i8 %4, -1
  %or.cond9 = icmp ult i8 %12, 3
  %or.cond11 = select i1 %or.cond, i1 %or.cond9, i1 false
  %13 = add i8 %5, -1
  %or.cond10 = icmp ult i8 %13, 7
  %or.cond12 = select i1 %or.cond11, i1 %or.cond10, i1 false
  br i1 %or.cond12, label %14, label %15

14:                                               ; preds = %entry
  %temp-coercion.coerced.sroa.4.0.extract.shift = lshr i32 %2, 16
  %.sroa.03.2.insert.ext = shl i32 %2, 16
  %.sroa.03.2.insert.insert = or disjoint i32 %.sroa.03.2.insert.ext, 31
  %.sroa.54.7.insert.ext = zext nneg i8 %4 to i32
  %.sroa.54.7.insert.shift = shl nuw nsw i32 %.sroa.54.7.insert.ext, 24
  %.sroa.54.7.insert.insert = or disjoint i32 %.sroa.54.7.insert.shift, %temp-coercion.coerced.sroa.4.0.extract.shift
  %.sroa.95.8.insert.ext = zext nneg i8 %5 to i32
  br label %15

15:                                               ; preds = %entry, %14
  %16 = phi i32 [ %.sroa.03.2.insert.insert, %14 ], [ 0, %entry ]
  %17 = phi i32 [ %.sroa.54.7.insert.insert, %14 ], [ 131072, %entry ]
  %18 = phi i32 [ %.sroa.95.8.insert.ext, %14 ], [ 0, %entry ]
  %19 = phi i32 [ %6, %14 ], [ 0, %entry ]
  %20 = phi i32 [ %7, %14 ], [ 0, %entry ]
  %21 = phi i32 [ %8, %14 ], [ 0, %entry ]
  %22 = phi i8 [ %9, %14 ], [ 0, %entry ]
  store i32 %16, ptr %0, align 4
  %23 = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %17, ptr %23, align 4
  %24 = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %18, ptr %24, align 4
  %25 = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i32 %19, ptr %25, align 4
  %26 = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i32 %20, ptr %26, align 4
  %27 = getelementptr inbounds nuw i8, ptr %0, i32 20
  store i32 %21, ptr %27, align 4
  %28 = getelementptr inbounds nuw i8, ptr %0, i32 24
  store i8 %22, ptr %28, align 4
  ret void
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i32(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i32, i1 immarg) #4

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationRequirementV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(25) %0, ptr noalias readonly captures(none) dereferenceable(25) %1) local_unnamed_addr #2 {
entry:
  %.sroa.0101.0.copyload = load i8, ptr %0, align 4
  %.sroa.098.0.copyload = load i8, ptr %1, align 4
  %2 = icmp eq i8 %.sroa.0101.0.copyload, %.sroa.098.0.copyload
  br i1 %2, label %3, label %21

3:                                                ; preds = %entry
  %.extent = getelementptr inbounds nuw i8, ptr %0, i32 2
  %.sroa.094.0.copyload = load i16, ptr %.extent, align 2
  %.extent4 = getelementptr inbounds nuw i8, ptr %1, i32 2
  %.sroa.090.0.copyload = load i16, ptr %.extent4, align 2
  %4 = icmp eq i16 %.sroa.094.0.copyload, %.sroa.090.0.copyload
  br i1 %4, label %5, label %21

5:                                                ; preds = %3
  %.sroa.4.0..extent4.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.4.0.copyload = load i16, ptr %.sroa.4.0..extent4.sroa_idx, align 2
  %.sroa.496.0..extent.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.496.0.copyload = load i16, ptr %.sroa.496.0..extent.sroa_idx, align 2
  %6 = icmp eq i16 %.sroa.496.0.copyload, %.sroa.4.0.copyload
  br i1 %6, label %7, label %21

7:                                                ; preds = %5
  %.operationStream = getelementptr inbounds nuw i8, ptr %0, i32 6
  %.unpack = load i8, ptr %.operationStream, align 2
  %.operationStream11 = getelementptr inbounds nuw i8, ptr %1, i32 6
  %.unpack104 = load i8, ptr %.operationStream11, align 2
  %8 = icmp eq i8 %.unpack, %.unpack104
  br i1 %8, label %9, label %21

9:                                                ; preds = %7
  %.acceptedEncodings = getelementptr inbounds nuw i8, ptr %0, i32 7
  %.sroa.078.0.copyload = load i8, ptr %.acceptedEncodings, align 1
  %.acceptedEncodings12 = getelementptr inbounds nuw i8, ptr %1, i32 7
  %.sroa.075.0.copyload = load i8, ptr %.acceptedEncodings12, align 1
  %10 = icmp eq i8 %.sroa.078.0.copyload, %.sroa.075.0.copyload
  br i1 %10, label %11, label %21

11:                                               ; preds = %9
  %.acceptedSubmissionLifetimes = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.072.0.copyload = load i8, ptr %.acceptedSubmissionLifetimes, align 4
  %.acceptedSubmissionLifetimes17 = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.069.0.copyload = load i8, ptr %.acceptedSubmissionLifetimes17, align 4
  %12 = icmp eq i8 %.sroa.072.0.copyload, %.sroa.069.0.copyload
  br i1 %12, label %13, label %21

13:                                               ; preds = %11
  %.maximumRasterBytes = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.066.0.copyload = load i32, ptr %.maximumRasterBytes, align 4
  %.maximumRasterBytes22 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.063.0.copyload = load i32, ptr %.maximumRasterBytes22, align 4
  %14 = icmp eq i32 %.sroa.066.0.copyload, %.sroa.063.0.copyload
  br i1 %14, label %15, label %21

15:                                               ; preds = %13
  %.maximumPayloadBytes = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.060.0.copyload = load i32, ptr %.maximumPayloadBytes, align 4
  %.maximumPayloadBytes27 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.sroa.057.0.copyload = load i32, ptr %.maximumPayloadBytes27, align 4
  %16 = icmp eq i32 %.sroa.060.0.copyload, %.sroa.057.0.copyload
  br i1 %16, label %17, label %21

17:                                               ; preds = %15
  %.maximumInFlightBytes = getelementptr inbounds nuw i8, ptr %0, i32 20
  %.sroa.054.0.copyload = load i32, ptr %.maximumInFlightBytes, align 4
  %.maximumInFlightBytes32 = getelementptr inbounds nuw i8, ptr %1, i32 20
  %.sroa.051.0.copyload = load i32, ptr %.maximumInFlightBytes32, align 4
  %18 = icmp eq i32 %.sroa.054.0.copyload, %.sroa.051.0.copyload
  br i1 %18, label %19, label %21

19:                                               ; preds = %17
  %.absence = getelementptr inbounds nuw i8, ptr %0, i32 24
  %.unpack105 = load i8, ptr %.absence, align 4
  %.absence37 = getelementptr inbounds nuw i8, ptr %1, i32 24
  %.unpack106 = load i8, ptr %.absence37, align 4
  %20 = icmp eq i8 %.unpack105, %.unpack106
  br label %21

21:                                               ; preds = %entry, %5, %3, %7, %9, %11, %13, %15, %17, %19
  %22 = phi i1 [ %20, %19 ], [ false, %17 ], [ false, %15 ], [ false, %13 ], [ false, %11 ], [ false, %9 ], [ false, %7 ], [ false, %3 ], [ false, %5 ], [ false, %entry ]
  ret i1 %22
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe26RenderProducerContributionV10operationsAA18RasterOperationSetVvg"(i16 %0) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i16 %0 to i8
  ret i8 %temp-coercion.coerced.sroa.0.0.extract.trunc
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe26RenderProducerContributionV15operationStreamAA09OperationI8LifetimeOvg"(i16 %0) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.3.0.extract.shift = lshr i16 %0, 8
  %temp-coercion.coerced.sroa.3.0.extract.trunc = trunc nuw i16 %temp-coercion.coerced.sroa.3.0.extract.shift to i8
  ret i8 %temp-coercion.coerced.sroa.3.0.extract.trunc
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc range(i16 1, 0) i16 @"$e27GiftUICapabilityLayoutProbe26RenderProducerContributionV10operations15operationStreamACSgAA18RasterOperationSetV_AA0lJ8LifetimeOtcfC"(i8 %0, i8 %1) local_unnamed_addr #0 {
entry:
  %2 = add i8 %0, -1
  %or.cond = icmp ult i8 %2, 31
  %3 = zext nneg i8 %0 to i16
  %4 = zext i8 %1 to i16
  %5 = shl nuw i16 %4, 8
  %6 = or disjoint i16 %5, %3
  %7 = select i1 %or.cond, i16 %6, i16 512
  ret i16 %7
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe26RenderProducerContributionV23__derived_struct_equalsySbAC_ACtFZ"(i16 %0, i16 %1) local_unnamed_addr #0 {
entry:
  %2 = icmp eq i16 %0, %1
  ret i1 %2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV8rawValues5UInt8Vvg"(i8 returned %0) local_unnamed_addr #0 {
entry:
  ret i8 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV8rawValueACs5UInt8V_tcfC"(i8 returned %0) local_unnamed_addr #0 {
entry:
  ret i8 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV11fullSurfaceACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV11fullSurfaceACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV11fullSurfaceACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV5tiledACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV5tiledACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe24RasterRealizationKindSetV5tiledACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV4kindAA0eF4KindOvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %1 = load i8, ptr %0, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV10operationsAA0E12OperationSetVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.operations = getelementptr inbounds nuw i8, ptr %0, i32 1
  %1 = load i8, ptr %.operations, align 1
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV15operationStreamAA09OperationI8LifetimeOvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.operationStream = getelementptr inbounds nuw i8, ptr %0, i32 2
  %1 = load i8, ptr %.operationStream, align 2
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV9encodingsAA25CanonicalPixelEncodingSetVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.encodings = getelementptr inbounds nuw i8, ptr %0, i32 3
  %1 = load i8, ptr %.encodings, align 1
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV27producedSubmissionLifetimesAA0I11LifetimeSetVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.producedSubmissionLifetimes = getelementptr inbounds nuw i8, ptr %0, i32 4
  %1 = load i8, ptr %.producedSubmissionLifetimes, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV13maximumExtentAA010CapabilityI0Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.maximumExtent = getelementptr inbounds nuw i8, ptr %0, i32 6
  %1 = load i32, ptr %.maximumExtent, align 2
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i16 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV18maximumRegionWidths6UInt16Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.maximumRegionWidth = getelementptr inbounds nuw i8, ptr %0, i32 10
  %1 = load i16, ptr %.maximumRegionWidth, align 2
  ret i16 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i16 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV19maximumRegionHeights6UInt16Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.maximumRegionHeight = getelementptr inbounds nuw i8, ptr %0, i32 12
  %1 = load i16, ptr %.maximumRegionHeight, align 4
  ret i16 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i16 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV16rowByteAlignments6UInt16Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.rowByteAlignment = getelementptr inbounds nuw i8, ptr %0, i32 14
  %1 = load i16, ptr %.rowByteAlignment, align 2
  ret i16 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV07maximumE5BytesAA19CapabilityByteCountVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.maximumRasterBytes = getelementptr inbounds nuw i8, ptr %0, i32 16
  %1 = load i32, ptr %.maximumRasterBytes, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV19maximumPayloadBytesAA19CapabilityByteCountVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.maximumPayloadBytes = getelementptr inbounds nuw i8, ptr %0, i32 20
  %1 = load i32, ptr %.maximumPayloadBytes, align 4
  ret i32 %1
}

; Function Attrs: minsize nounwind optsize memory(argmem: write, inaccessiblemem: write)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV4kind10operations15operationStream9encodings27producedSubmissionLifetimes13maximumExtent0P11RegionWidth0pR6Height16rowByteAlignment0pE5Bytes0p7PayloadX0ACSgAA0eF4KindO_AA0E12OperationSetVAA09OperationK8LifetimeOAA25CanonicalPixelEncodingSetVAA0N11LifetimeSetVAA010CapabilityQ0Vs6UInt16VA1_A1_AA010CapabilityV5CountVA3_tcfC"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe29RasterRealizationContributionVSg) captures(none) initializes((0, 24)) %0, i8 %1, i8 %2, i8 %3, i8 %4, i8 %5, i32 %6, i16 %7, i16 %8, i16 %9, i32 %10, i32 %11) local_unnamed_addr #5 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i32 %6 to i16
  %temp-coercion.coerced.sroa.4.0.extract.shift = lshr i32 %6, 16
  %temp-coercion.coerced.sroa.4.0.extract.trunc = trunc nuw i32 %temp-coercion.coerced.sroa.4.0.extract.shift to i16
  %12 = add i8 %2, -1
  %or.cond13 = icmp ult i8 %12, 31
  %13 = add i8 %4, -1
  %or.cond14 = icmp ult i8 %13, 3
  %or.cond15 = select i1 %or.cond13, i1 %or.cond14, i1 false
  br i1 %or.cond15, label %14, label %29

14:                                               ; preds = %entry
  %15 = icmp eq i8 %5, 0
  br i1 %15, label %29, label %16

16:                                               ; preds = %14
  %17 = icmp ult i8 %5, 8
  %18 = icmp ne i16 %7, 0
  %or.cond = select i1 %17, i1 %18, i1 false
  %19 = icmp ne i16 %8, 0
  %or.cond1 = select i1 %or.cond, i1 %19, i1 false
  %20 = icmp ule i16 %7, %temp-coercion.coerced.sroa.0.0.extract.trunc
  %or.cond2 = select i1 %or.cond1, i1 %20, i1 false
  %21 = icmp ule i16 %8, %temp-coercion.coerced.sroa.4.0.extract.trunc
  %or.cond3 = select i1 %or.cond2, i1 %21, i1 false
  %22 = icmp ne i16 %9, 0
  %or.cond4 = select i1 %or.cond3, i1 %22, i1 false
  br i1 %or.cond4, label %23, label %29

23:                                               ; preds = %16
  %24 = zext i8 %1 to i32
  %25 = icmp eq i8 %1, 1
  br i1 %25, label %26, label %28

26:                                               ; preds = %23
  %27 = tail call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV19payloadAdmitsOneRow33_E17D99E015B31087C87CFA5F821C9FD5LL5width9alignment9encodings19maximumPayloadBytesSbs6UInt16V_AkA25CanonicalPixelEncodingSetVs6UInt32VtFZ"(i16 %7, i16 %9, i8 %4, i32 %11)
  br i1 %27, label %28, label %29

28:                                               ; preds = %23, %26
  %.sroa.07.1.insert.ext = zext nneg i8 %2 to i32
  %.sroa.07.1.insert.shift = shl nuw nsw i32 %.sroa.07.1.insert.ext, 8
  %.sroa.07.1.insert.insert = or disjoint i32 %.sroa.07.1.insert.shift, %24
  %.sroa.07.2.insert.ext = zext i8 %3 to i32
  %.sroa.07.2.insert.shift = shl nuw nsw i32 %.sroa.07.2.insert.ext, 16
  %.sroa.07.2.insert.insert = or disjoint i32 %.sroa.07.1.insert.insert, %.sroa.07.2.insert.shift
  %.sroa.07.3.insert.ext = zext nneg i8 %4 to i32
  %.sroa.07.3.insert.shift = shl nuw nsw i32 %.sroa.07.3.insert.ext, 24
  %.sroa.07.3.insert.insert = or disjoint i32 %.sroa.07.2.insert.insert, %.sroa.07.3.insert.shift
  %.sroa.78.4.insert.ext = zext nneg i8 %5 to i32
  %.sroa.78.6.insert.ext = shl i32 %6, 16
  %.sroa.78.6.insert.insert = or disjoint i32 %.sroa.78.6.insert.ext, %.sroa.78.4.insert.ext
  %.sroa.10.10.insert.ext = zext i16 %7 to i32
  %.sroa.10.10.insert.shift = shl nuw i32 %.sroa.10.10.insert.ext, 16
  %.sroa.10.10.insert.insert = or disjoint i32 %.sroa.10.10.insert.shift, %temp-coercion.coerced.sroa.4.0.extract.shift
  %.sroa.13.12.insert.ext = zext i16 %8 to i32
  %.sroa.13.14.insert.ext = zext i16 %9 to i32
  %.sroa.13.14.insert.shift = shl nuw i32 %.sroa.13.14.insert.ext, 16
  %.sroa.13.14.insert.insert = or disjoint i32 %.sroa.13.14.insert.shift, %.sroa.13.12.insert.ext
  br label %29

29:                                               ; preds = %16, %26, %14, %entry, %28
  %30 = phi i32 [ %.sroa.07.3.insert.insert, %28 ], [ 2, %entry ], [ 2, %14 ], [ 2, %26 ], [ 2, %16 ]
  %31 = phi i32 [ %.sroa.78.6.insert.insert, %28 ], [ 0, %entry ], [ 0, %14 ], [ 0, %26 ], [ 0, %16 ]
  %32 = phi i32 [ %.sroa.10.10.insert.insert, %28 ], [ 0, %entry ], [ 0, %14 ], [ 0, %26 ], [ 0, %16 ]
  %33 = phi i32 [ %.sroa.13.14.insert.insert, %28 ], [ 0, %entry ], [ 0, %14 ], [ 0, %26 ], [ 0, %16 ]
  %34 = phi i32 [ %10, %28 ], [ 0, %entry ], [ 0, %14 ], [ 0, %26 ], [ 0, %16 ]
  %35 = phi i32 [ %11, %28 ], [ 0, %entry ], [ 0, %14 ], [ 0, %26 ], [ 0, %16 ]
  store i32 %30, ptr %0, align 4
  %36 = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %31, ptr %36, align 4
  %37 = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %32, ptr %37, align 4
  %38 = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i32 %33, ptr %38, align 4
  %39 = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i32 %34, ptr %39, align 4
  %40 = getelementptr inbounds nuw i8, ptr %0, i32 20
  store i32 %35, ptr %40, align 4
  ret void
}

; Function Attrs: minsize nounwind optsize memory(inaccessiblemem: write)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV19payloadAdmitsOneRow33_E17D99E015B31087C87CFA5F821C9FD5LL5width9alignment9encodings19maximumPayloadBytesSbs6UInt16V_AkA25CanonicalPixelEncodingSetVs6UInt32VtFZ"(i16 %0, i16 %1, i8 %2, i32 %3) local_unnamed_addr #6 {
entry:
  %4 = and i8 %2, 1
  %.not = icmp eq i8 %4, 0
  br i1 %.not, label %23, label %5

5:                                                ; preds = %entry
  %6 = zext i16 %0 to i32
  %7 = shl nuw nsw i32 %6, 1
  %8 = zext i16 %1 to i32
  %9 = icmp eq i16 %1, 0
  br i1 %9, label %48, label %10, !prof !6

10:                                               ; preds = %5
  %11 = urem i32 %7, %8
  %12 = icmp eq i32 %11, 0
  br i1 %12, label %21, label %13

13:                                               ; preds = %10
  %14 = tail call { i32, i1 } @llvm.usub.with.overflow.i32(i32 %8, i32 %11)
  %15 = extractvalue { i32, i1 } %14, 1
  br i1 %15, label %49, label %16, !prof !6

16:                                               ; preds = %13
  %17 = extractvalue { i32, i1 } %14, 0
  %18 = tail call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 %7, i32 %17)
  %19 = extractvalue { i32, i1 } %18, 0
  %20 = extractvalue { i32, i1 } %18, 1
  br i1 %20, label %44, label %21

21:                                               ; preds = %16, %10
  %22 = phi i32 [ %7, %10 ], [ %19, %16 ]
  %.not4 = icmp ult i32 %3, %22
  br i1 %.not4, label %44, label %23

23:                                               ; preds = %entry, %21
  %24 = and i8 %2, 2
  %.not5 = icmp eq i8 %24, 0
  br i1 %.not5, label %44, label %25

25:                                               ; preds = %23
  %26 = zext i16 %0 to i32
  %27 = shl nuw nsw i32 %26, 2
  %28 = zext i16 %1 to i32
  %29 = icmp eq i16 %1, 0
  br i1 %29, label %46, label %30, !prof !6

30:                                               ; preds = %25
  %31 = urem i32 %27, %28
  %32 = icmp eq i32 %31, 0
  br i1 %32, label %41, label %33

33:                                               ; preds = %30
  %34 = tail call { i32, i1 } @llvm.usub.with.overflow.i32(i32 %28, i32 %31)
  %35 = extractvalue { i32, i1 } %34, 1
  br i1 %35, label %47, label %36, !prof !6

36:                                               ; preds = %33
  %37 = extractvalue { i32, i1 } %34, 0
  %38 = tail call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 %27, i32 %37)
  %39 = extractvalue { i32, i1 } %38, 0
  %40 = extractvalue { i32, i1 } %38, 1
  br i1 %40, label %44, label %41

41:                                               ; preds = %36, %30
  %42 = phi i32 [ %27, %30 ], [ %39, %36 ]
  %43 = icmp uge i32 %3, %42
  br label %44

44:                                               ; preds = %36, %23, %21, %16, %41
  %45 = phi i1 [ %43, %41 ], [ false, %16 ], [ false, %21 ], [ true, %23 ], [ false, %36 ]
  ret i1 %45

46:                                               ; preds = %25
  tail call void @llvm.trap() #24
  unreachable

47:                                               ; preds = %33
  tail call void @llvm.trap() #24
  unreachable

48:                                               ; preds = %5
  tail call void @llvm.trap() #24
  unreachable

49:                                               ; preds = %13
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.umul.with.overflow.i32(i32, i32) #7

; Function Attrs: cold noreturn nounwind memory(inaccessiblemem: write)
declare void @llvm.trap() #8

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.usub.with.overflow.i32(i32, i32) #7

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.uadd.with.overflow.i32(i32, i32) #7

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(24) %0, ptr noalias readonly captures(none) dereferenceable(24) %1) local_unnamed_addr #2 {
entry:
  %.unpack = load i8, ptr %0, align 4
  %.unpack108 = load i8, ptr %1, align 4
  %2 = icmp eq i8 %.unpack, %.unpack108
  br i1 %2, label %3, label %25

3:                                                ; preds = %entry
  %.operations = getelementptr inbounds nuw i8, ptr %0, i32 1
  %.sroa.097.0.copyload = load i8, ptr %.operations, align 1
  %.operations2 = getelementptr inbounds nuw i8, ptr %1, i32 1
  %.sroa.094.0.copyload = load i8, ptr %.operations2, align 1
  %4 = icmp eq i8 %.sroa.097.0.copyload, %.sroa.094.0.copyload
  br i1 %4, label %5, label %25

5:                                                ; preds = %3
  %.operationStream = getelementptr inbounds nuw i8, ptr %0, i32 2
  %.unpack109 = load i8, ptr %.operationStream, align 2
  %.operationStream5 = getelementptr inbounds nuw i8, ptr %1, i32 2
  %.unpack110 = load i8, ptr %.operationStream5, align 2
  %6 = icmp eq i8 %.unpack109, %.unpack110
  br i1 %6, label %7, label %25

7:                                                ; preds = %5
  %.encodings = getelementptr inbounds nuw i8, ptr %0, i32 3
  %.sroa.084.0.copyload = load i8, ptr %.encodings, align 1
  %.encodings6 = getelementptr inbounds nuw i8, ptr %1, i32 3
  %.sroa.081.0.copyload = load i8, ptr %.encodings6, align 1
  %8 = icmp eq i8 %.sroa.084.0.copyload, %.sroa.081.0.copyload
  br i1 %8, label %9, label %25

9:                                                ; preds = %7
  %.producedSubmissionLifetimes = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.078.0.copyload = load i8, ptr %.producedSubmissionLifetimes, align 4
  %.producedSubmissionLifetimes11 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.075.0.copyload = load i8, ptr %.producedSubmissionLifetimes11, align 4
  %10 = icmp eq i8 %.sroa.078.0.copyload, %.sroa.075.0.copyload
  br i1 %10, label %11, label %25

11:                                               ; preds = %9
  %.maximumExtent = getelementptr inbounds nuw i8, ptr %0, i32 6
  %.sroa.071.0.copyload = load i16, ptr %.maximumExtent, align 2
  %.maximumExtent16 = getelementptr inbounds nuw i8, ptr %1, i32 6
  %.sroa.067.0.copyload = load i16, ptr %.maximumExtent16, align 2
  %12 = icmp eq i16 %.sroa.071.0.copyload, %.sroa.067.0.copyload
  br i1 %12, label %13, label %25

13:                                               ; preds = %11
  %.sroa.4.0..maximumExtent16.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.4.0.copyload = load i16, ptr %.sroa.4.0..maximumExtent16.sroa_idx, align 2
  %.sroa.473.0..maximumExtent.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.473.0.copyload = load i16, ptr %.sroa.473.0..maximumExtent.sroa_idx, align 2
  %14 = icmp eq i16 %.sroa.473.0.copyload, %.sroa.4.0.copyload
  br i1 %14, label %15, label %25

15:                                               ; preds = %13
  %.maximumRegionWidth = getelementptr inbounds nuw i8, ptr %0, i32 10
  %.sroa.065.0.copyload = load i16, ptr %.maximumRegionWidth, align 2
  %.maximumRegionWidth23 = getelementptr inbounds nuw i8, ptr %1, i32 10
  %.sroa.064.0.copyload = load i16, ptr %.maximumRegionWidth23, align 2
  %16 = icmp eq i16 %.sroa.065.0.copyload, %.sroa.064.0.copyload
  br i1 %16, label %17, label %25

17:                                               ; preds = %15
  %.maximumRegionHeight = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.063.0.copyload = load i16, ptr %.maximumRegionHeight, align 4
  %.maximumRegionHeight26 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.062.0.copyload = load i16, ptr %.maximumRegionHeight26, align 4
  %18 = icmp eq i16 %.sroa.063.0.copyload, %.sroa.062.0.copyload
  br i1 %18, label %19, label %25

19:                                               ; preds = %17
  %.rowByteAlignment = getelementptr inbounds nuw i8, ptr %0, i32 14
  %.sroa.061.0.copyload = load i16, ptr %.rowByteAlignment, align 2
  %.rowByteAlignment29 = getelementptr inbounds nuw i8, ptr %1, i32 14
  %.sroa.060.0.copyload = load i16, ptr %.rowByteAlignment29, align 2
  %20 = icmp eq i16 %.sroa.061.0.copyload, %.sroa.060.0.copyload
  br i1 %20, label %21, label %25

21:                                               ; preds = %19
  %.maximumRasterBytes = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.057.0.copyload = load i32, ptr %.maximumRasterBytes, align 4
  %.maximumRasterBytes32 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.sroa.054.0.copyload = load i32, ptr %.maximumRasterBytes32, align 4
  %22 = icmp eq i32 %.sroa.057.0.copyload, %.sroa.054.0.copyload
  br i1 %22, label %23, label %25

23:                                               ; preds = %21
  %.maximumPayloadBytes = getelementptr inbounds nuw i8, ptr %0, i32 20
  %.sroa.051.0.copyload = load i32, ptr %.maximumPayloadBytes, align 4
  %.maximumPayloadBytes37 = getelementptr inbounds nuw i8, ptr %1, i32 20
  %.sroa.048.0.copyload = load i32, ptr %.maximumPayloadBytes37, align 4
  %24 = icmp eq i32 %.sroa.051.0.copyload, %.sroa.048.0.copyload
  br label %25

25:                                               ; preds = %entry, %3, %5, %7, %9, %13, %11, %15, %17, %19, %21, %23
  %26 = phi i1 [ %24, %23 ], [ false, %21 ], [ false, %19 ], [ false, %17 ], [ false, %15 ], [ false, %11 ], [ false, %13 ], [ false, %9 ], [ false, %7 ], [ false, %5 ], [ false, %3 ], [ false, %entry ]
  ret i1 %26
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe25RasterBackendContributionV7primaryAA0e11RealizationG0Vvg"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV) captures(none) initializes((0, 24)) %0, ptr noalias readonly swiftself captures(none) dereferenceable(48) %1) local_unnamed_addr #9 {
entry:
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(24) %0, ptr noundef nonnull align 4 dereferenceable(24) %1, i32 24, i1 false)
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe25RasterBackendContributionV9alternateAA0e11RealizationG0VSgvg"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe29RasterRealizationContributionVSg) captures(none) initializes((0, 24)) %0, ptr noalias readonly swiftself captures(none) dereferenceable(48) %1) local_unnamed_addr #9 {
entry:
  %.alternate = getelementptr inbounds nuw i8, ptr %1, i32 24
  %2 = load i32, ptr %.alternate, align 4
  %3 = getelementptr inbounds nuw i8, ptr %1, i32 28
  %4 = load i32, ptr %3, align 4
  %5 = getelementptr inbounds nuw i8, ptr %1, i32 32
  %6 = load i32, ptr %5, align 4
  %7 = getelementptr inbounds nuw i8, ptr %1, i32 36
  %8 = load i32, ptr %7, align 4
  %9 = getelementptr inbounds nuw i8, ptr %1, i32 40
  %10 = load i32, ptr %9, align 4
  %11 = getelementptr inbounds nuw i8, ptr %1, i32 44
  %12 = load i32, ptr %11, align 4
  store i32 %2, ptr %0, align 4
  %13 = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %4, ptr %13, align 4
  %14 = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %6, ptr %14, align 4
  %15 = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i32 %8, ptr %15, align 4
  %16 = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i32 %10, ptr %16, align 4
  %17 = getelementptr inbounds nuw i8, ptr %0, i32 20
  store i32 %12, ptr %17, align 4
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe25RasterBackendContributionV7primary9alternateACSgAA0e11RealizationG0V_AHSgtcfC"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe25RasterBackendContributionVSg) captures(none) initializes((0, 48)) %0, ptr noalias readonly captures(none) dereferenceable(24) %1, ptr noalias readonly captures(none) dereferenceable(24) %2) local_unnamed_addr #9 {
entry:
  %.sroa.06.0.copyload = load i32, ptr %2, align 4
  %.sroa.58.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 4
  %3 = and i32 %.sroa.06.0.copyload, 255
  %4 = icmp eq i32 %3, 2
  br i1 %4, label %8, label %5

5:                                                ; preds = %entry
  %.unpack = load i8, ptr %1, align 4
  %6 = trunc i32 %.sroa.06.0.copyload to i8
  %7 = icmp eq i8 %.unpack, %6
  br i1 %7, label %9, label %8

8:                                                ; preds = %5, %entry
  %.sroa.041.0.copyload = load i32, ptr %1, align 4
  %.sroa.442.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.442.0.copyload = load i32, ptr %.sroa.442.0..sroa_idx, align 4
  %.sroa.543.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.543.0.copyload = load i32, ptr %.sroa.543.0..sroa_idx, align 4
  %.sroa.644.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.644.0.copyload = load i32, ptr %.sroa.644.0..sroa_idx, align 4
  %.sroa.745.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.sroa.745.0.copyload = load i32, ptr %.sroa.745.0..sroa_idx, align 4
  %.sroa.846.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 20
  %.sroa.846.0.copyload = load i32, ptr %.sroa.846.0..sroa_idx, align 4
  %.sroa.1148.24.copyload = load i32, ptr %.sroa.58.0..sroa_idx, align 4
  %.sroa.1249.24..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 8
  %.sroa.1249.24.copyload = load i32, ptr %.sroa.1249.24..sroa_idx, align 4
  %.sroa.1350.24..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 12
  %.sroa.1350.24.copyload = load i32, ptr %.sroa.1350.24..sroa_idx, align 4
  %.sroa.1451.24..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 16
  %.sroa.1451.24.copyload = load i32, ptr %.sroa.1451.24..sroa_idx, align 4
  %.sroa.1552.24..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 20
  %.sroa.1552.24.copyload = load i32, ptr %.sroa.1552.24..sroa_idx, align 4
  br label %9

9:                                                ; preds = %5, %8
  %.sroa.018.0 = phi i32 [ %.sroa.041.0.copyload, %8 ], [ 2, %5 ]
  %.sroa.520.0 = phi i32 [ %.sroa.442.0.copyload, %8 ], [ 0, %5 ]
  %.sroa.622.0 = phi i32 [ %.sroa.543.0.copyload, %8 ], [ 0, %5 ]
  %.sroa.724.0 = phi i32 [ %.sroa.644.0.copyload, %8 ], [ 0, %5 ]
  %.sroa.826.0 = phi i32 [ %.sroa.745.0.copyload, %8 ], [ 0, %5 ]
  %.sroa.928.0 = phi i32 [ %.sroa.846.0.copyload, %8 ], [ 0, %5 ]
  %.sroa.1030.0 = phi i32 [ %.sroa.06.0.copyload, %8 ], [ 0, %5 ]
  %.sroa.1132.0 = phi i32 [ %.sroa.1148.24.copyload, %8 ], [ 0, %5 ]
  %.sroa.1234.0 = phi i32 [ %.sroa.1249.24.copyload, %8 ], [ 0, %5 ]
  %.sroa.1336.0 = phi i32 [ %.sroa.1350.24.copyload, %8 ], [ 0, %5 ]
  %.sroa.1438.0 = phi i32 [ %.sroa.1451.24.copyload, %8 ], [ 0, %5 ]
  %.sroa.15.0 = phi i32 [ %.sroa.1552.24.copyload, %8 ], [ 0, %5 ]
  store i32 %.sroa.018.0, ptr %0, align 4
  %.sroa.520.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %.sroa.520.0, ptr %.sroa.520.0..sroa_idx, align 4
  %.sroa.622.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %.sroa.622.0, ptr %.sroa.622.0..sroa_idx, align 4
  %.sroa.724.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i32 %.sroa.724.0, ptr %.sroa.724.0..sroa_idx, align 4
  %.sroa.826.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i32 %.sroa.826.0, ptr %.sroa.826.0..sroa_idx, align 4
  %.sroa.928.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 20
  store i32 %.sroa.928.0, ptr %.sroa.928.0..sroa_idx, align 4
  %.sroa.1030.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 24
  store i32 %.sroa.1030.0, ptr %.sroa.1030.0..sroa_idx, align 4
  %.sroa.1132.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 28
  store i32 %.sroa.1132.0, ptr %.sroa.1132.0..sroa_idx, align 4
  %.sroa.1234.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 32
  store i32 %.sroa.1234.0, ptr %.sroa.1234.0..sroa_idx, align 4
  %.sroa.1336.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 36
  store i32 %.sroa.1336.0, ptr %.sroa.1336.0..sroa_idx, align 4
  %.sroa.1438.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 40
  store i32 %.sroa.1438.0, ptr %.sroa.1438.0..sroa_idx, align 4
  %.sroa.15.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 44
  store i32 %.sroa.15.0, ptr %.sroa.15.0..sroa_idx, align 4
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe25RasterBackendContributionV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(48) %0, ptr noalias readonly captures(none) dereferenceable(48) %1) local_unnamed_addr #2 {
entry:
  %2 = alloca %T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV, align 4
  %3 = alloca %T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV, align 4
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %2)
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %3)
  %4 = tail call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias nonnull captures(none) dereferenceable(24) %0, ptr noalias nonnull captures(none) dereferenceable(24) %1)
  br i1 %4, label %5, label %15

5:                                                ; preds = %entry
  %.alternate = getelementptr inbounds nuw i8, ptr %0, i32 24
  %.sroa.093.0.copyload = load i32, ptr %.alternate, align 4
  %.sroa.494.0..alternate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 28
  %.sroa.494.0.copyload = load i32, ptr %.sroa.494.0..alternate.sroa_idx, align 4
  %.sroa.595.0..alternate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 32
  %.sroa.595.0.copyload = load i32, ptr %.sroa.595.0..alternate.sroa_idx, align 4
  %.sroa.696.0..alternate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 36
  %.sroa.696.0.copyload = load i32, ptr %.sroa.696.0..alternate.sroa_idx, align 4
  %.sroa.797.0..alternate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 40
  %.sroa.797.0.copyload = load i32, ptr %.sroa.797.0..alternate.sroa_idx, align 4
  %.sroa.898.0..alternate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 44
  %.sroa.898.0.copyload = load i32, ptr %.sroa.898.0..alternate.sroa_idx, align 4
  %.alternate2 = getelementptr inbounds nuw i8, ptr %1, i32 24
  %.sroa.087.0.copyload = load i32, ptr %.alternate2, align 4
  %.sroa.488.0..alternate2.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 28
  %.sroa.488.0.copyload = load i32, ptr %.sroa.488.0..alternate2.sroa_idx, align 4
  %.sroa.589.0..alternate2.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 32
  %.sroa.589.0.copyload = load i32, ptr %.sroa.589.0..alternate2.sroa_idx, align 4
  %.sroa.690.0..alternate2.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 36
  %.sroa.690.0.copyload = load i32, ptr %.sroa.690.0..alternate2.sroa_idx, align 4
  %.sroa.791.0..alternate2.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 40
  %.sroa.791.0.copyload = load i32, ptr %.sroa.791.0..alternate2.sroa_idx, align 4
  %.sroa.892.0..alternate2.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 44
  %.sroa.892.0.copyload = load i32, ptr %.sroa.892.0..alternate2.sroa_idx, align 4
  %6 = and i32 %.sroa.093.0.copyload, 255
  %7 = icmp eq i32 %6, 2
  %8 = and i32 %.sroa.087.0.copyload, 255
  %9 = icmp eq i32 %8, 2
  br i1 %7, label %13, label %10

10:                                               ; preds = %5
  br i1 %9, label %15, label %11

11:                                               ; preds = %10
  store i32 %.sroa.087.0.copyload, ptr %2, align 4
  %.sroa.428.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 4
  store i32 %.sroa.488.0.copyload, ptr %.sroa.428.0..sroa_idx, align 4
  %.sroa.529.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 8
  store i32 %.sroa.589.0.copyload, ptr %.sroa.529.0..sroa_idx, align 4
  %.sroa.630.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 12
  store i32 %.sroa.690.0.copyload, ptr %.sroa.630.0..sroa_idx, align 4
  %.sroa.731.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 16
  store i32 %.sroa.791.0.copyload, ptr %.sroa.731.0..sroa_idx, align 4
  %.sroa.832.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 20
  store i32 %.sroa.892.0.copyload, ptr %.sroa.832.0..sroa_idx, align 4
  store i32 %.sroa.093.0.copyload, ptr %3, align 4
  %.sroa.434.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 4
  store i32 %.sroa.494.0.copyload, ptr %.sroa.434.0..sroa_idx, align 4
  %.sroa.535.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 8
  store i32 %.sroa.595.0.copyload, ptr %.sroa.535.0..sroa_idx, align 4
  %.sroa.636.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 12
  store i32 %.sroa.696.0.copyload, ptr %.sroa.636.0..sroa_idx, align 4
  %.sroa.737.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 16
  store i32 %.sroa.797.0.copyload, ptr %.sroa.737.0..sroa_idx, align 4
  %.sroa.838.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 20
  store i32 %.sroa.898.0.copyload, ptr %.sroa.838.0..sroa_idx, align 4
  %12 = call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias nonnull captures(none) dereferenceable(24) %3, ptr noalias nonnull captures(none) dereferenceable(24) %2)
  br label %15

13:                                               ; preds = %5
  br i1 %9, label %14, label %15

14:                                               ; preds = %13
  br label %15

15:                                               ; preds = %13, %10, %11, %entry, %14
  %16 = phi i1 [ true, %14 ], [ false, %entry ], [ %12, %11 ], [ false, %10 ], [ false, %13 ]
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %3)
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %2)
  ret i1 %16
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV6extentAA16CapabilityExtentVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(20) %0) local_unnamed_addr #2 {
entry:
  %1 = load i32, ptr %0, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV9encodingsAA25CanonicalPixelEncodingSetVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(20) %0) local_unnamed_addr #2 {
entry:
  %.encodings = getelementptr inbounds nuw i8, ptr %0, i32 4
  %1 = load i8, ptr %.encodings, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV27acceptedSubmissionLifetimesAA0I11LifetimeSetVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(20) %0) local_unnamed_addr #2 {
entry:
  %.acceptedSubmissionLifetimes = getelementptr inbounds nuw i8, ptr %0, i32 5
  %1 = load i8, ptr %.acceptedSubmissionLifetimes, align 1
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV8handoffsAA20SubmissionHandoffSetVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(20) %0) local_unnamed_addr #2 {
entry:
  %.handoffs = getelementptr inbounds nuw i8, ptr %0, i32 6
  %1 = load i8, ptr %.handoffs, align 2
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i16 @"$e27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV18maximumRegionWidths6UInt16Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(20) %0) local_unnamed_addr #2 {
entry:
  %.maximumRegionWidth = getelementptr inbounds nuw i8, ptr %0, i32 8
  %1 = load i16, ptr %.maximumRegionWidth, align 4
  ret i16 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i16 @"$e27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV19maximumRegionHeights6UInt16Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(20) %0) local_unnamed_addr #2 {
entry:
  %.maximumRegionHeight = getelementptr inbounds nuw i8, ptr %0, i32 10
  %1 = load i16, ptr %.maximumRegionHeight, align 2
  ret i16 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i16 @"$e27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV16rowByteAlignments6UInt16Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(20) %0) local_unnamed_addr #2 {
entry:
  %.rowByteAlignment = getelementptr inbounds nuw i8, ptr %0, i32 12
  %1 = load i16, ptr %.rowByteAlignment, align 4
  ret i16 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV20maximumInFlightCounts5UInt8Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(20) %0) local_unnamed_addr #2 {
entry:
  %.maximumInFlightCount = getelementptr inbounds nuw i8, ptr %0, i32 14
  %1 = load i8, ptr %.maximumInFlightCount, align 2
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV20maximumInFlightBytesAA19CapabilityByteCountVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(20) %0) local_unnamed_addr #2 {
entry:
  %.maximumInFlightBytes = getelementptr inbounds nuw i8, ptr %0, i32 16
  %1 = load i32, ptr %.maximumInFlightBytes, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV6extent9encodings27acceptedSubmissionLifetimes8handoffs18maximumRegionWidth0nO6Height16rowByteAlignment0N13InFlightCount0nuV5BytesACSgAA16CapabilityExtentV_AA25CanonicalPixelEncodingSetVAA0K11LifetimeSetVAA0K10HandoffSetVs6UInt16VA2Ws5UInt8VAA0ysW0VtcfC"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionVSg) captures(none) initializes((0, 21)) %0, i32 %1, i8 %2, i8 %3, i8 %4, i16 %5, i16 %6, i16 %7, i8 %8, i32 %9) local_unnamed_addr #3 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i32 %1 to i16
  %temp-coercion.coerced.sroa.4.0.extract.shift = lshr i32 %1, 16
  %temp-coercion.coerced.sroa.4.0.extract.trunc = trunc nuw i32 %temp-coercion.coerced.sroa.4.0.extract.shift to i16
  %10 = add i8 %2, -1
  %or.cond11 = icmp ult i8 %10, 3
  %11 = add i8 %3, -1
  %or.cond12 = icmp ult i8 %11, 7
  %or.cond13 = select i1 %or.cond11, i1 %or.cond12, i1 false
  br i1 %or.cond13, label %12, label %23

12:                                               ; preds = %entry
  %13 = icmp eq i8 %4, 0
  br i1 %13, label %23, label %14

14:                                               ; preds = %12
  %15 = icmp ult i8 %4, 4
  %16 = icmp ne i16 %5, 0
  %or.cond = select i1 %15, i1 %16, i1 false
  %17 = icmp ne i16 %6, 0
  %or.cond1 = select i1 %or.cond, i1 %17, i1 false
  %18 = icmp ule i16 %5, %temp-coercion.coerced.sroa.0.0.extract.trunc
  %or.cond2 = select i1 %or.cond1, i1 %18, i1 false
  %19 = icmp ule i16 %6, %temp-coercion.coerced.sroa.4.0.extract.trunc
  %or.cond3 = select i1 %or.cond2, i1 %19, i1 false
  %20 = icmp ne i16 %7, 0
  %or.cond4 = select i1 %or.cond3, i1 %20, i1 false
  %21 = icmp ne i8 %8, 0
  %or.cond5 = select i1 %or.cond4, i1 %21, i1 false
  br i1 %or.cond5, label %22, label %23

22:                                               ; preds = %14
  %.sroa.57.4.insert.ext = zext nneg i8 %2 to i32
  %.sroa.57.5.insert.ext = zext nneg i8 %3 to i32
  %.sroa.57.5.insert.shift = shl nuw nsw i32 %.sroa.57.5.insert.ext, 8
  %.sroa.57.5.insert.insert = or disjoint i32 %.sroa.57.5.insert.shift, %.sroa.57.4.insert.ext
  %.sroa.57.6.insert.ext = zext nneg i8 %4 to i32
  %.sroa.57.6.insert.shift = shl nuw nsw i32 %.sroa.57.6.insert.ext, 16
  %.sroa.57.6.insert.insert = or disjoint i32 %.sroa.57.5.insert.insert, %.sroa.57.6.insert.shift
  %.sroa.9.8.insert.ext = zext i16 %5 to i32
  %.sroa.9.10.insert.ext = zext i16 %6 to i32
  %.sroa.9.10.insert.shift = shl nuw i32 %.sroa.9.10.insert.ext, 16
  %.sroa.9.10.insert.insert = or disjoint i32 %.sroa.9.10.insert.shift, %.sroa.9.8.insert.ext
  %.sroa.12.12.insert.ext = zext i16 %7 to i32
  %.sroa.12.14.insert.ext = zext i8 %8 to i32
  %.sroa.12.14.insert.shift = shl nuw nsw i32 %.sroa.12.14.insert.ext, 16
  %.sroa.12.14.insert.insert = or disjoint i32 %.sroa.12.14.insert.shift, %.sroa.12.12.insert.ext
  br label %23

23:                                               ; preds = %14, %12, %entry, %22
  %24 = phi i32 [ %1, %22 ], [ 0, %entry ], [ 0, %12 ], [ 0, %14 ]
  %25 = phi i32 [ %.sroa.57.6.insert.insert, %22 ], [ 0, %entry ], [ 0, %12 ], [ 0, %14 ]
  %26 = phi i32 [ %.sroa.9.10.insert.insert, %22 ], [ 0, %entry ], [ 0, %12 ], [ 0, %14 ]
  %27 = phi i32 [ %.sroa.12.14.insert.insert, %22 ], [ 0, %entry ], [ 0, %12 ], [ 0, %14 ]
  %28 = phi i32 [ %9, %22 ], [ 0, %entry ], [ 0, %12 ], [ 0, %14 ]
  %29 = phi i8 [ 0, %22 ], [ 1, %entry ], [ 1, %12 ], [ 1, %14 ]
  store i32 %24, ptr %0, align 4
  %30 = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %25, ptr %30, align 4
  %31 = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %26, ptr %31, align 4
  %32 = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i32 %27, ptr %32, align 4
  %33 = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i32 %28, ptr %33, align 4
  %34 = getelementptr inbounds nuw i8, ptr %0, i32 20
  store i8 %29, ptr %34, align 4
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(20) %0, ptr noalias readonly captures(none) dereferenceable(20) %1) local_unnamed_addr #2 {
entry:
  %.sroa.074.0.copyload = load i16, ptr %0, align 4
  %.sroa.070.0.copyload = load i16, ptr %1, align 4
  %2 = icmp eq i16 %.sroa.074.0.copyload, %.sroa.070.0.copyload
  br i1 %2, label %3, label %21

3:                                                ; preds = %entry
  %.sroa.4.0..extent1.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 2
  %.sroa.4.0.copyload = load i16, ptr %.sroa.4.0..extent1.sroa_idx, align 2
  %.sroa.476.0..extent.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 2
  %.sroa.476.0.copyload = load i16, ptr %.sroa.476.0..extent.sroa_idx, align 2
  %4 = icmp eq i16 %.sroa.476.0.copyload, %.sroa.4.0.copyload
  br i1 %4, label %5, label %21

5:                                                ; preds = %3
  %.encodings = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.066.0.copyload = load i8, ptr %.encodings, align 4
  %.encodings7 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.063.0.copyload = load i8, ptr %.encodings7, align 4
  %6 = icmp eq i8 %.sroa.066.0.copyload, %.sroa.063.0.copyload
  br i1 %6, label %7, label %21

7:                                                ; preds = %5
  %.acceptedSubmissionLifetimes = getelementptr inbounds nuw i8, ptr %0, i32 5
  %.sroa.060.0.copyload = load i8, ptr %.acceptedSubmissionLifetimes, align 1
  %.acceptedSubmissionLifetimes11 = getelementptr inbounds nuw i8, ptr %1, i32 5
  %.sroa.057.0.copyload = load i8, ptr %.acceptedSubmissionLifetimes11, align 1
  %8 = icmp eq i8 %.sroa.060.0.copyload, %.sroa.057.0.copyload
  br i1 %8, label %9, label %21

9:                                                ; preds = %7
  %.handoffs = getelementptr inbounds nuw i8, ptr %0, i32 6
  %.sroa.054.0.copyload = load i8, ptr %.handoffs, align 2
  %.handoffs16 = getelementptr inbounds nuw i8, ptr %1, i32 6
  %.sroa.051.0.copyload = load i8, ptr %.handoffs16, align 2
  %10 = icmp eq i8 %.sroa.054.0.copyload, %.sroa.051.0.copyload
  br i1 %10, label %11, label %21

11:                                               ; preds = %9
  %.maximumRegionWidth = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.050.0.copyload = load i16, ptr %.maximumRegionWidth, align 4
  %.maximumRegionWidth21 = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.049.0.copyload = load i16, ptr %.maximumRegionWidth21, align 4
  %12 = icmp eq i16 %.sroa.050.0.copyload, %.sroa.049.0.copyload
  br i1 %12, label %13, label %21

13:                                               ; preds = %11
  %.maximumRegionHeight = getelementptr inbounds nuw i8, ptr %0, i32 10
  %.sroa.048.0.copyload = load i16, ptr %.maximumRegionHeight, align 2
  %.maximumRegionHeight24 = getelementptr inbounds nuw i8, ptr %1, i32 10
  %.sroa.047.0.copyload = load i16, ptr %.maximumRegionHeight24, align 2
  %14 = icmp eq i16 %.sroa.048.0.copyload, %.sroa.047.0.copyload
  br i1 %14, label %15, label %21

15:                                               ; preds = %13
  %.rowByteAlignment = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.046.0.copyload = load i16, ptr %.rowByteAlignment, align 4
  %.rowByteAlignment27 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.045.0.copyload = load i16, ptr %.rowByteAlignment27, align 4
  %16 = icmp eq i16 %.sroa.046.0.copyload, %.sroa.045.0.copyload
  br i1 %16, label %17, label %21

17:                                               ; preds = %15
  %.maximumInFlightCount = getelementptr inbounds nuw i8, ptr %0, i32 14
  %.sroa.044.0.copyload = load i8, ptr %.maximumInFlightCount, align 2
  %.maximumInFlightCount30 = getelementptr inbounds nuw i8, ptr %1, i32 14
  %.sroa.043.0.copyload = load i8, ptr %.maximumInFlightCount30, align 2
  %18 = icmp eq i8 %.sroa.044.0.copyload, %.sroa.043.0.copyload
  br i1 %18, label %19, label %21

19:                                               ; preds = %17
  %.maximumInFlightBytes = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.040.0.copyload = load i32, ptr %.maximumInFlightBytes, align 4
  %.maximumInFlightBytes33 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.sroa.0.0.copyload = load i32, ptr %.maximumInFlightBytes33, align 4
  %20 = icmp eq i32 %.sroa.040.0.copyload, %.sroa.0.0.copyload
  br label %21

21:                                               ; preds = %3, %entry, %5, %7, %9, %11, %13, %15, %17, %19
  %22 = phi i1 [ %20, %19 ], [ false, %17 ], [ false, %15 ], [ false, %13 ], [ false, %11 ], [ false, %9 ], [ false, %7 ], [ false, %5 ], [ false, %entry ], [ false, %3 ]
  ret i1 %22
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe24RasterPresentationPolicyV07maximumE5BytesAA19CapabilityByteCountVvg"(i32 returned %0, i32 %1, i32 %2, i32 %3) local_unnamed_addr #0 {
entry:
  ret i32 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe24RasterPresentationPolicyV19maximumPayloadBytesAA19CapabilityByteCountVvg"(i32 %0, i32 returned %1, i32 %2, i32 %3) local_unnamed_addr #0 {
entry:
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe24RasterPresentationPolicyV20maximumInFlightBytesAA19CapabilityByteCountVvg"(i32 %0, i32 %1, i32 returned %2, i32 %3) local_unnamed_addr #0 {
entry:
  ret i32 %2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe24RasterPresentationPolicyV19allowedRealizationsAA0E18RealizationKindSetVvg"(i32 %0, i32 %1, i32 %2, i32 %3) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.5.12.extract.trunc = trunc i32 %3 to i8
  ret i8 %temp-coercion.coerced.sroa.5.12.extract.trunc
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe24RasterPresentationPolicyV16allowedEncodingsAA25CanonicalPixelEncodingSetVvg"(i32 %0, i32 %1, i32 %2, i32 %3) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.5.13.extract.shift = lshr i32 %3, 8
  %temp-coercion.coerced.sroa.5.13.extract.trunc = trunc i32 %temp-coercion.coerced.sroa.5.13.extract.shift to i8
  ret i8 %temp-coercion.coerced.sroa.5.13.extract.trunc
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe24RasterPresentationPolicyV20preferredRealizationAA0eI4KindOvg"(i32 %0, i32 %1, i32 %2, i32 %3) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.5.14.extract.shift = lshr i32 %3, 16
  %temp-coercion.coerced.sroa.5.14.extract.trunc = trunc i32 %temp-coercion.coerced.sroa.5.14.extract.shift to i8
  ret i8 %temp-coercion.coerced.sroa.5.14.extract.trunc
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe24RasterPresentationPolicyV17preferredEncodingAA014CanonicalPixelI3SetVvg"(i32 %0, i32 %1, i32 %2, i32 %3) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.5.15.extract.shift = lshr i32 %3, 24
  %temp-coercion.coerced.sroa.5.15.extract.trunc = trunc nuw i32 %temp-coercion.coerced.sroa.5.15.extract.shift to i8
  ret i8 %temp-coercion.coerced.sroa.5.15.extract.trunc
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i32, i32, i32 } @"$e27GiftUICapabilityLayoutProbe24RasterPresentationPolicyV07maximumE5Bytes0h7PayloadI00h8InFlightI019allowedRealizations0M9Encodings20preferredRealization0P8EncodingACSgAA19CapabilityByteCountV_A2mA0eQ7KindSetVAA014CanonicalPixelrW0VAA0eqV0OAQtcfC"(i32 %0, i32 %1, i32 %2, i8 %3, i8 %4, i8 %5, i8 %6) local_unnamed_addr #0 {
entry:
  %7 = add i8 %3, -1
  %or.cond11 = icmp ult i8 %7, 3
  %8 = add i8 %4, -1
  %or.cond12 = icmp ult i8 %8, 3
  %or.cond15 = select i1 %or.cond11, i1 %or.cond12, i1 false
  br i1 %or.cond15, label %9, label %"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV16isSingleDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLSbvg.exit.thread"

9:                                                ; preds = %entry
  %10 = sub i8 -2, %5
  %11 = or i8 %10, %3
  %12 = icmp eq i8 %11, -1
  %13 = add i8 %6, -1
  %or.cond.i = icmp ult i8 %13, 3
  %or.cond14 = select i1 %12, i1 %or.cond.i, i1 false
  br i1 %or.cond14, label %"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV16isSingleDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLSbvg.exit", label %"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV16isSingleDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLSbvg.exit.thread"

"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV16isSingleDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLSbvg.exit": ; preds = %9
  %14 = tail call range(i8 1, 3) i8 @llvm.ctpop.i8(i8 %6)
  %15 = icmp samesign ult i8 %14, 2
  %16 = and i8 %6, %4
  %17 = icmp eq i8 %16, %6
  %or.cond = select i1 %15, i1 %17, i1 false
  br i1 %or.cond, label %18, label %"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV16isSingleDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLSbvg.exit.thread"

18:                                               ; preds = %"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV16isSingleDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLSbvg.exit"
  %19 = zext nneg i8 %3 to i32
  %20 = zext nneg i8 %4 to i32
  %21 = shl nuw nsw i32 %20, 8
  %22 = or disjoint i32 %21, %19
  %23 = zext i8 %5 to i32
  %24 = shl nuw nsw i32 %23, 16
  %25 = or disjoint i32 %24, %22
  %26 = zext nneg i8 %6 to i32
  %27 = shl nuw nsw i32 %26, 24
  %28 = or disjoint i32 %27, %25
  br label %"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV16isSingleDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLSbvg.exit.thread"

"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV16isSingleDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLSbvg.exit.thread": ; preds = %"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV16isSingleDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLSbvg.exit", %9, %entry, %18
  %29 = phi i32 [ %0, %18 ], [ 0, %entry ], [ 0, %9 ], [ 0, %"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV16isSingleDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLSbvg.exit" ]
  %30 = phi i32 [ %1, %18 ], [ 0, %entry ], [ 0, %9 ], [ 0, %"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV16isSingleDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLSbvg.exit" ]
  %31 = phi i32 [ %2, %18 ], [ 0, %entry ], [ 0, %9 ], [ 0, %"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV16isSingleDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLSbvg.exit" ]
  %32 = phi i32 [ %28, %18 ], [ 131072, %entry ], [ 131072, %9 ], [ 131072, %"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV16isSingleDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLSbvg.exit" ]
  %33 = insertvalue { i32, i32, i32, i32 } undef, i32 %29, 0
  %34 = insertvalue { i32, i32, i32, i32 } %33, i32 %30, 1
  %35 = insertvalue { i32, i32, i32, i32 } %34, i32 %31, 2
  %36 = insertvalue { i32, i32, i32, i32 } %35, i32 %32, 3
  ret { i32, i32, i32, i32 } %36
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe25CanonicalPixelEncodingSetV16isSingleDeclared33_E17D99E015B31087C87CFA5F821C9FD5LLSbvg"(i8 %0) local_unnamed_addr #0 {
entry:
  %1 = add i8 %0, -1
  %or.cond = icmp ult i8 %1, 3
  br i1 %or.cond, label %2, label %5

2:                                                ; preds = %entry
  %3 = tail call range(i8 1, 3) i8 @llvm.ctpop.i8(i8 %0)
  %4 = icmp samesign ult i8 %3, 2
  br label %5

5:                                                ; preds = %entry, %2
  %6 = phi i1 [ %4, %2 ], [ false, %entry ]
  ret i1 %6
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i8, i1 } @llvm.usub.with.overflow.i8(i8, i8) #7

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe24RasterPresentationPolicyV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5, i32 %6, i32 %7) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.8.12.extract.trunc = trunc i32 %3 to i8
  %temp-coercion.coerced.sroa.8.13.extract.shift = lshr i32 %3, 8
  %temp-coercion.coerced.sroa.8.13.extract.trunc = trunc i32 %temp-coercion.coerced.sroa.8.13.extract.shift to i8
  %temp-coercion.coerced1.sroa.8.12.extract.trunc = trunc i32 %7 to i8
  %temp-coercion.coerced1.sroa.8.13.extract.shift = lshr i32 %7, 8
  %temp-coercion.coerced1.sroa.8.13.extract.trunc = trunc i32 %temp-coercion.coerced1.sroa.8.13.extract.shift to i8
  %8 = icmp eq i32 %0, %4
  %9 = icmp eq i32 %1, %5
  %or.cond = select i1 %8, i1 %9, i1 false
  %10 = icmp eq i32 %2, %6
  %or.cond2 = select i1 %or.cond, i1 %10, i1 false
  %11 = icmp eq i8 %temp-coercion.coerced.sroa.8.12.extract.trunc, %temp-coercion.coerced1.sroa.8.12.extract.trunc
  %or.cond3 = select i1 %or.cond2, i1 %11, i1 false
  %12 = icmp eq i8 %temp-coercion.coerced.sroa.8.13.extract.trunc, %temp-coercion.coerced1.sroa.8.13.extract.trunc
  %or.cond4 = select i1 %or.cond3, i1 %12, i1 false
  br i1 %or.cond4, label %13, label %18

13:                                               ; preds = %entry
  %temp-coercion.coerced.sroa.8.14.extract.shift6 = xor i32 %7, %3
  %14 = and i32 %temp-coercion.coerced.sroa.8.14.extract.shift6, 16711680
  %15 = icmp eq i32 %14, 0
  br i1 %15, label %16, label %18

16:                                               ; preds = %13
  %17 = icmp ult i32 %temp-coercion.coerced.sroa.8.14.extract.shift6, 16777216
  br label %18

18:                                               ; preds = %entry, %13, %16
  %19 = phi i1 [ %17, %16 ], [ false, %13 ], [ false, %entry ]
  ret i1 %19
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe30RasterPresentationContributionO21__derived_enum_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(49) %0, ptr noalias readonly captures(none) dereferenceable(49) %1) local_unnamed_addr #2 {
entry:
  %2 = alloca %T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV, align 4
  %3 = alloca %T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV, align 4
  %4 = alloca %T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV, align 4
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %2)
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %3)
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %4)
  %.sroa.0192.sroa.0.0.copyload = load i8, ptr %0, align 4
  %.sroa.0192.sroa.7.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 1
  %.sroa.0192.sroa.7.0.copyload = load i8, ptr %.sroa.0192.sroa.7.0..sroa_idx, align 1
  %.sroa.0192.sroa.8.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 2
  %.sroa.0192.sroa.8.sroa.0.sroa.0.0.copyload = load i16, ptr %.sroa.0192.sroa.8.0..sroa_idx, align 2
  %.sroa.0192.sroa.8.sroa.0.sroa.6.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.0192.sroa.8.sroa.0.sroa.6.0.copyload = load i32, ptr %.sroa.0192.sroa.8.sroa.0.sroa.6.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx, align 2
  %.sroa.0192.sroa.8.sroa.0.sroa.7.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.0192.sroa.8.sroa.0.sroa.7.0.copyload = load i32, ptr %.sroa.0192.sroa.8.sroa.0.sroa.7.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx, align 2
  %.sroa.0192.sroa.8.sroa.0.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.0192.sroa.8.sroa.0.sroa.8.0.copyload = load i8, ptr %.sroa.0192.sroa.8.sroa.0.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx, align 2
  %.sroa.0192.sroa.8.sroa.0.sroa.9.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 13
  %.sroa.0192.sroa.8.sroa.0.sroa.9.0.copyload = load i8, ptr %.sroa.0192.sroa.8.sroa.0.sroa.9.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx, align 1
  %.sroa.0192.sroa.8.sroa.6.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 14
  %.sroa.0192.sroa.8.sroa.6.0.copyload = load i8, ptr %.sroa.0192.sroa.8.sroa.6.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx, align 2
  %.sroa.0192.sroa.8.sroa.7.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 15
  %.sroa.0192.sroa.8.sroa.7.0.copyload = load i8, ptr %.sroa.0192.sroa.8.sroa.7.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx, align 1
  %.sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.0192.sroa.8.sroa.8.sroa.0.0.copyload = load i32, ptr %.sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx, align 2
  %.sroa.0192.sroa.8.sroa.8.sroa.5.0..sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 20
  %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.0.0.copyload = load i32, ptr %.sroa.0192.sroa.8.sroa.8.sroa.5.0..sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx.sroa_idx, align 2
  %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.4.0..sroa.0192.sroa.8.sroa.8.sroa.5.0..sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx.sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 24
  %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.4.0.copyload = load i32, ptr %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.4.0..sroa.0192.sroa.8.sroa.8.sroa.5.0..sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx.sroa_idx.sroa_idx, align 2
  %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.5.0..sroa.0192.sroa.8.sroa.8.sroa.5.0..sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx.sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 28
  %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.5.0.copyload = load i32, ptr %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.5.0..sroa.0192.sroa.8.sroa.8.sroa.5.0..sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx.sroa_idx.sroa_idx, align 2
  %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.6.0..sroa.0192.sroa.8.sroa.8.sroa.5.0..sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx.sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 32
  %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.6.0.copyload = load i32, ptr %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.6.0..sroa.0192.sroa.8.sroa.8.sroa.5.0..sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx.sroa_idx.sroa_idx, align 2
  %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.7.0..sroa.0192.sroa.8.sroa.8.sroa.5.0..sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx.sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 36
  %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.7.0.copyload = load i32, ptr %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.7.0..sroa.0192.sroa.8.sroa.8.sroa.5.0..sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx.sroa_idx.sroa_idx, align 2
  %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.8.0..sroa.0192.sroa.8.sroa.8.sroa.5.0..sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx.sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 40
  %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.8.0.copyload = load i32, ptr %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.8.0..sroa.0192.sroa.8.sroa.8.sroa.5.0..sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx.sroa_idx.sroa_idx, align 2
  %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.9.0..sroa.0192.sroa.8.sroa.8.sroa.5.0..sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx.sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 44
  %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.9.0.copyload = load i32, ptr %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.9.0..sroa.0192.sroa.8.sroa.8.sroa.5.0..sroa.0192.sroa.8.sroa.8.0..sroa.0192.sroa.8.0..sroa_idx.sroa_idx.sroa_idx.sroa_idx, align 2
  %.sroa.7193.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 48
  %.sroa.7193.0.copyload = load i8, ptr %.sroa.7193.0..sroa_idx, align 4
  switch i8 %.sroa.7193.0.copyload, label %5 [
    i8 0, label %6
    i8 1, label %11
    i8 2, label %24
    i8 3, label %37
  ]

5:                                                ; preds = %entry
  unreachable

6:                                                ; preds = %entry
  %.sroa.4178.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 48
  %.sroa.4178.0.copyload = load i8, ptr %.sroa.4178.0..sroa_idx, align 4
  %.not348 = icmp eq i8 %.sroa.4178.0.copyload, 0
  br i1 %.not348, label %7, label %47

7:                                                ; preds = %6
  %.sroa.0177.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 1
  %.sroa.0177.sroa.4.0.copyload = load i8, ptr %.sroa.0177.sroa.4.0..sroa_idx, align 1
  %.sroa.0177.sroa.0.0.copyload = load i8, ptr %1, align 4
  %8 = icmp eq i8 %.sroa.0192.sroa.0.0.copyload, %.sroa.0177.sroa.0.0.copyload
  %9 = icmp eq i8 %.sroa.0192.sroa.7.0.copyload, %.sroa.0177.sroa.4.0.copyload
  %or.cond = select i1 %8, i1 %9, i1 false
  br i1 %or.cond, label %47, label %10

10:                                               ; preds = %7
  br label %47

11:                                               ; preds = %entry
  %.sroa.0182.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 24
  %.sroa.0182.sroa.4.0.copyload = load i32, ptr %.sroa.0182.sroa.4.0..sroa_idx, align 4
  %.sroa.0182.sroa.5.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 28
  %.sroa.0182.sroa.5.0.copyload = load i32, ptr %.sroa.0182.sroa.5.0..sroa_idx, align 4
  %.sroa.0182.sroa.6.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 32
  %.sroa.0182.sroa.6.0.copyload = load i32, ptr %.sroa.0182.sroa.6.0..sroa_idx, align 4
  %.sroa.0182.sroa.7.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 36
  %.sroa.0182.sroa.7.0.copyload = load i32, ptr %.sroa.0182.sroa.7.0..sroa_idx, align 4
  %.sroa.0182.sroa.8.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 40
  %.sroa.0182.sroa.8.0.copyload = load i32, ptr %.sroa.0182.sroa.8.0..sroa_idx, align 4
  %.sroa.0182.sroa.9.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 44
  %.sroa.0182.sroa.9.0.copyload = load i32, ptr %.sroa.0182.sroa.9.0..sroa_idx, align 4
  %.sroa.4183.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 48
  %.sroa.4183.0.copyload = load i8, ptr %.sroa.4183.0..sroa_idx, align 4
  %.not347 = icmp eq i8 %.sroa.4183.0.copyload, 1
  br i1 %.not347, label %12, label %47

12:                                               ; preds = %11
  store i8 %.sroa.0192.sroa.0.0.copyload, ptr %4, align 4
  %.sroa.4211.0..sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 1
  store i8 %.sroa.0192.sroa.7.0.copyload, ptr %.sroa.4211.0..sroa_idx, align 1
  %.sroa.5212.0..sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 2
  store i16 %.sroa.0192.sroa.8.sroa.0.sroa.0.0.copyload, ptr %.sroa.5212.0..sroa_idx, align 2
  %.sroa.5212.sroa.0.sroa.4.0..sroa.5212.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 4
  store i32 %.sroa.0192.sroa.8.sroa.0.sroa.6.0.copyload, ptr %.sroa.5212.sroa.0.sroa.4.0..sroa.5212.0..sroa_idx.sroa_idx, align 4
  %.sroa.5212.sroa.0.sroa.5.0..sroa.5212.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 8
  store i32 %.sroa.0192.sroa.8.sroa.0.sroa.7.0.copyload, ptr %.sroa.5212.sroa.0.sroa.5.0..sroa.5212.0..sroa_idx.sroa_idx, align 4
  %.sroa.5212.sroa.0.sroa.6.0..sroa.5212.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 12
  store i8 %.sroa.0192.sroa.8.sroa.0.sroa.8.0.copyload, ptr %.sroa.5212.sroa.0.sroa.6.0..sroa.5212.0..sroa_idx.sroa_idx, align 4
  %.sroa.5212.sroa.0.sroa.7.0..sroa.5212.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 13
  store i8 %.sroa.0192.sroa.8.sroa.0.sroa.9.0.copyload, ptr %.sroa.5212.sroa.0.sroa.7.0..sroa.5212.0..sroa_idx.sroa_idx, align 1
  %.sroa.5212.sroa.4.0..sroa.5212.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 14
  store i8 %.sroa.0192.sroa.8.sroa.6.0.copyload, ptr %.sroa.5212.sroa.4.0..sroa.5212.0..sroa_idx.sroa_idx, align 2
  %.sroa.5212.sroa.5.0..sroa.5212.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 15
  store i8 %.sroa.0192.sroa.8.sroa.7.0.copyload, ptr %.sroa.5212.sroa.5.0..sroa.5212.0..sroa_idx.sroa_idx, align 1
  %.sroa.5212.sroa.6.0..sroa.5212.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 16
  store i32 %.sroa.0192.sroa.8.sroa.8.sroa.0.0.copyload, ptr %.sroa.5212.sroa.6.0..sroa.5212.0..sroa_idx.sroa_idx, align 4
  %.sroa.5212.sroa.7.0..sroa.5212.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 20
  store i32 %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.0.0.copyload, ptr %.sroa.5212.sroa.7.0..sroa.5212.0..sroa_idx.sroa_idx, align 4
  %13 = call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias nonnull captures(none) dereferenceable(24) %4, ptr noalias nonnull captures(none) dereferenceable(24) %1)
  br i1 %13, label %14, label %47

14:                                               ; preds = %12
  %15 = and i32 %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.4.0.copyload, 255
  %16 = icmp eq i32 %15, 2
  %17 = and i32 %.sroa.0182.sroa.4.0.copyload, 255
  %18 = icmp eq i32 %17, 2
  br i1 %16, label %22, label %19

19:                                               ; preds = %14
  br i1 %18, label %47, label %20

20:                                               ; preds = %19
  store i32 %.sroa.0182.sroa.4.0.copyload, ptr %2, align 4
  %.sroa.4114.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 4
  store i32 %.sroa.0182.sroa.5.0.copyload, ptr %.sroa.4114.0..sroa_idx, align 4
  %.sroa.5115.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 8
  store i32 %.sroa.0182.sroa.6.0.copyload, ptr %.sroa.5115.0..sroa_idx, align 4
  %.sroa.6116.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 12
  store i32 %.sroa.0182.sroa.7.0.copyload, ptr %.sroa.6116.0..sroa_idx, align 4
  %.sroa.7117.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 16
  store i32 %.sroa.0182.sroa.8.0.copyload, ptr %.sroa.7117.0..sroa_idx, align 4
  %.sroa.8118.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 20
  store i32 %.sroa.0182.sroa.9.0.copyload, ptr %.sroa.8118.0..sroa_idx, align 4
  store i32 %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.4.0.copyload, ptr %3, align 4
  %.sroa.4120.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 4
  store i32 %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.5.0.copyload, ptr %.sroa.4120.0..sroa_idx, align 4
  %.sroa.5121.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 8
  store i32 %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.6.0.copyload, ptr %.sroa.5121.0..sroa_idx, align 4
  %.sroa.6122.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 12
  store i32 %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.7.0.copyload, ptr %.sroa.6122.0..sroa_idx, align 4
  %.sroa.7123.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 16
  store i32 %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.8.0.copyload, ptr %.sroa.7123.0..sroa_idx, align 4
  %.sroa.8124.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 20
  store i32 %.sroa.0192.sroa.8.sroa.8.sroa.5.sroa.9.0.copyload, ptr %.sroa.8124.0..sroa_idx, align 4
  %21 = call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias nonnull captures(none) dereferenceable(24) %3, ptr noalias nonnull captures(none) dereferenceable(24) %2)
  br label %47

22:                                               ; preds = %14
  br i1 %18, label %23, label %47

23:                                               ; preds = %22
  br label %47

24:                                               ; preds = %entry
  %.sroa.4185.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 48
  %.sroa.4185.0.copyload = load i8, ptr %.sroa.4185.0..sroa_idx, align 4
  %.not346 = icmp eq i8 %.sroa.4185.0.copyload, 2
  br i1 %.not346, label %25, label %47

25:                                               ; preds = %24
  %.sroa.0184.sroa.12.sroa.4.0..sroa.0184.sroa.12.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.sroa.0184.sroa.12.sroa.4.0.copyload = load i32, ptr %.sroa.0184.sroa.12.sroa.4.0..sroa.0184.sroa.12.0..sroa_idx.sroa_idx, align 1
  %.sroa.0184.sroa.11.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 14
  %.sroa.0184.sroa.11.0.copyload = load i8, ptr %.sroa.0184.sroa.11.0..sroa_idx, align 2
  %.sroa.0184.sroa.10.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.0184.sroa.10.0.copyload = load i16, ptr %.sroa.0184.sroa.10.0..sroa_idx, align 4
  %.sroa.0184.sroa.9.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 10
  %.sroa.0184.sroa.9.0.copyload = load i16, ptr %.sroa.0184.sroa.9.0..sroa_idx, align 2
  %.sroa.0184.sroa.8.sroa.4.0..sroa.0184.sroa.8.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.0184.sroa.8.sroa.4.0.copyload = load i16, ptr %.sroa.0184.sroa.8.sroa.4.0..sroa.0184.sroa.8.0..sroa_idx.sroa_idx, align 1
  %.sroa.0184.sroa.7.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 6
  %.sroa.0184.sroa.7.0.copyload = load i8, ptr %.sroa.0184.sroa.7.0..sroa_idx, align 2
  %.sroa.0184.sroa.6.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 5
  %.sroa.0184.sroa.6.0.copyload = load i8, ptr %.sroa.0184.sroa.6.0..sroa_idx, align 1
  %.sroa.0184.sroa.5.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.0184.sroa.5.0.copyload = load i8, ptr %.sroa.0184.sroa.5.0..sroa_idx, align 4
  %.sroa.0184.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 2
  %.sroa.0184.sroa.4.0.copyload = load i16, ptr %.sroa.0184.sroa.4.0..sroa_idx, align 2
  %.sroa.0184.sroa.0.0.copyload = load i16, ptr %1, align 4
  %.sroa.4261.0.insert.ext = zext i8 %.sroa.0192.sroa.7.0.copyload to i16
  %.sroa.4261.0.insert.shift = shl nuw i16 %.sroa.4261.0.insert.ext, 8
  %.sroa.0260.0.insert.ext = zext i8 %.sroa.0192.sroa.0.0.copyload to i16
  %.sroa.0260.0.insert.insert = or disjoint i16 %.sroa.4261.0.insert.shift, %.sroa.0260.0.insert.ext
  %26 = icmp eq i16 %.sroa.0260.0.insert.insert, %.sroa.0184.sroa.0.0.copyload
  %27 = icmp eq i16 %.sroa.0192.sroa.8.sroa.0.sroa.0.0.copyload, %.sroa.0184.sroa.4.0.copyload
  %or.cond349 = select i1 %26, i1 %27, i1 false
  %.sroa.5215.sroa.0.sroa.4.2.extract.trunc = trunc i32 %.sroa.0192.sroa.8.sroa.0.sroa.6.0.copyload to i8
  %28 = icmp eq i8 %.sroa.0184.sroa.5.0.copyload, %.sroa.5215.sroa.0.sroa.4.2.extract.trunc
  %or.cond350 = select i1 %or.cond349, i1 %28, i1 false
  %.sroa.5215.sroa.0.sroa.4.3.extract.shift = lshr i32 %.sroa.0192.sroa.8.sroa.0.sroa.6.0.copyload, 8
  %.sroa.5215.sroa.0.sroa.4.3.extract.trunc = trunc i32 %.sroa.5215.sroa.0.sroa.4.3.extract.shift to i8
  %29 = icmp eq i8 %.sroa.0184.sroa.6.0.copyload, %.sroa.5215.sroa.0.sroa.4.3.extract.trunc
  %or.cond351 = select i1 %or.cond350, i1 %29, i1 false
  %.sroa.5215.sroa.0.sroa.4.4.extract.shift = lshr i32 %.sroa.0192.sroa.8.sroa.0.sroa.6.0.copyload, 16
  %.sroa.5215.sroa.0.sroa.4.4.extract.trunc = trunc i32 %.sroa.5215.sroa.0.sroa.4.4.extract.shift to i8
  %30 = icmp eq i8 %.sroa.0184.sroa.7.0.copyload, %.sroa.5215.sroa.0.sroa.4.4.extract.trunc
  %or.cond352 = select i1 %or.cond351, i1 %30, i1 false
  %.sroa.5215.sroa.0.sroa.8.6.extract.trunc = trunc i32 %.sroa.0192.sroa.8.sroa.0.sroa.7.0.copyload to i16
  %31 = icmp eq i16 %.sroa.0184.sroa.8.sroa.4.0.copyload, %.sroa.5215.sroa.0.sroa.8.6.extract.trunc
  %or.cond353 = select i1 %or.cond352, i1 %31, i1 false
  %.sroa.5215.sroa.0.sroa.8.8.extract.shift = lshr i32 %.sroa.0192.sroa.8.sroa.0.sroa.7.0.copyload, 16
  %.sroa.5215.sroa.0.sroa.8.8.extract.trunc = trunc nuw i32 %.sroa.5215.sroa.0.sroa.8.8.extract.shift to i16
  %32 = icmp eq i16 %.sroa.0184.sroa.9.0.copyload, %.sroa.5215.sroa.0.sroa.8.8.extract.trunc
  %or.cond354 = select i1 %or.cond353, i1 %32, i1 false
  %.sroa.4271.0.insert.ext = zext i8 %.sroa.0192.sroa.8.sroa.0.sroa.9.0.copyload to i16
  %.sroa.4271.0.insert.shift = shl nuw i16 %.sroa.4271.0.insert.ext, 8
  %.sroa.0270.0.insert.ext = zext i8 %.sroa.0192.sroa.8.sroa.0.sroa.8.0.copyload to i16
  %.sroa.0270.0.insert.insert = or disjoint i16 %.sroa.4271.0.insert.shift, %.sroa.0270.0.insert.ext
  %33 = icmp eq i16 %.sroa.0270.0.insert.insert, %.sroa.0184.sroa.10.0.copyload
  %or.cond355 = select i1 %or.cond354, i1 %33, i1 false
  %34 = icmp eq i8 %.sroa.0192.sroa.8.sroa.6.0.copyload, %.sroa.0184.sroa.11.0.copyload
  %or.cond356 = select i1 %or.cond355, i1 %34, i1 false
  %35 = icmp eq i32 %.sroa.0192.sroa.8.sroa.8.sroa.0.0.copyload, %.sroa.0184.sroa.12.sroa.4.0.copyload
  %or.cond357 = select i1 %or.cond356, i1 %35, i1 false
  br i1 %or.cond357, label %47, label %36

36:                                               ; preds = %25
  br label %47

37:                                               ; preds = %entry
  %.sroa.4187.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 48
  %.sroa.4187.0.copyload = load i8, ptr %.sroa.4187.0..sroa_idx, align 4
  %.not = icmp eq i8 %.sroa.4187.0.copyload, 3
  br i1 %.not, label %38, label %47

38:                                               ; preds = %37
  %.sroa.0186.sroa.5.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 15
  %.sroa.0186.sroa.5.0.copyload = load i8, ptr %.sroa.0186.sroa.5.0..sroa_idx, align 1
  %.sroa.0186.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 14
  %.sroa.0186.sroa.4.0.copyload = load i8, ptr %.sroa.0186.sroa.4.0..sroa_idx, align 2
  %.sroa.0186.sroa.0.sroa.7.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 13
  %.sroa.0186.sroa.0.sroa.7.0.copyload = load i8, ptr %.sroa.0186.sroa.0.sroa.7.0..sroa_idx, align 1
  %.sroa.0186.sroa.0.sroa.6.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.0186.sroa.0.sroa.6.0.copyload = load i8, ptr %.sroa.0186.sroa.0.sroa.6.0..sroa_idx, align 4
  %.sroa.0186.sroa.0.sroa.5.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.0186.sroa.0.sroa.5.0.copyload = load i32, ptr %.sroa.0186.sroa.0.sroa.5.0..sroa_idx, align 4
  %.sroa.0186.sroa.0.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.0186.sroa.0.sroa.4.0.copyload = load i32, ptr %.sroa.0186.sroa.0.sroa.4.0..sroa_idx, align 4
  %.sroa.0186.sroa.0.sroa.0.0.copyload = load i32, ptr %1, align 4
  %.sroa.5233.0.insert.ext = zext i16 %.sroa.0192.sroa.8.sroa.0.sroa.0.0.copyload to i32
  %.sroa.5233.0.insert.shift = shl nuw i32 %.sroa.5233.0.insert.ext, 16
  %.sroa.4232.0.insert.ext = zext i8 %.sroa.0192.sroa.7.0.copyload to i32
  %.sroa.4232.0.insert.shift = shl nuw nsw i32 %.sroa.4232.0.insert.ext, 8
  %.sroa.0231.0.insert.ext = zext i8 %.sroa.0192.sroa.0.0.copyload to i32
  %.sroa.4232.0.insert.insert = or disjoint i32 %.sroa.4232.0.insert.shift, %.sroa.0231.0.insert.ext
  %.sroa.0231.0.insert.insert = or disjoint i32 %.sroa.4232.0.insert.insert, %.sroa.5233.0.insert.shift
  %39 = icmp eq i32 %.sroa.0231.0.insert.insert, %.sroa.0186.sroa.0.sroa.0.0.copyload
  %40 = icmp eq i32 %.sroa.0192.sroa.8.sroa.0.sroa.6.0.copyload, %.sroa.0186.sroa.0.sroa.4.0.copyload
  %or.cond358 = select i1 %39, i1 %40, i1 false
  %41 = icmp eq i32 %.sroa.0192.sroa.8.sroa.0.sroa.7.0.copyload, %.sroa.0186.sroa.0.sroa.5.0.copyload
  %or.cond359 = select i1 %or.cond358, i1 %41, i1 false
  %42 = icmp eq i8 %.sroa.0192.sroa.8.sroa.0.sroa.8.0.copyload, %.sroa.0186.sroa.0.sroa.6.0.copyload
  %or.cond360 = select i1 %or.cond359, i1 %42, i1 false
  %43 = icmp eq i8 %.sroa.0192.sroa.8.sroa.0.sroa.9.0.copyload, %.sroa.0186.sroa.0.sroa.7.0.copyload
  %or.cond361 = select i1 %or.cond360, i1 %43, i1 false
  %44 = icmp eq i8 %.sroa.0192.sroa.8.sroa.6.0.copyload, %.sroa.0186.sroa.4.0.copyload
  %or.cond362 = select i1 %or.cond361, i1 %44, i1 false
  %45 = icmp eq i8 %.sroa.0192.sroa.8.sroa.7.0.copyload, %.sroa.0186.sroa.5.0.copyload
  %or.cond363 = select i1 %or.cond362, i1 %45, i1 false
  br i1 %or.cond363, label %47, label %46

46:                                               ; preds = %38
  br label %47

47:                                               ; preds = %38, %25, %22, %19, %7, %20, %6, %11, %24, %37, %12, %23, %10, %36, %46
  %48 = phi i1 [ false, %46 ], [ false, %36 ], [ false, %10 ], [ true, %23 ], [ false, %12 ], [ false, %37 ], [ false, %24 ], [ false, %11 ], [ false, %6 ], [ %21, %20 ], [ true, %7 ], [ false, %19 ], [ false, %22 ], [ true, %25 ], [ true, %38 ]
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %4)
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %3)
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %2)
  ret i1 %48
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV8capacitys5UInt8Vvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV8capacitys5UInt8VvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV8capacitys5UInt8VvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 4
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV14renderProducerAA06RenderI12ContributionVSgvpfi"() local_unnamed_addr #0 {
entry:
  ret i16 512
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV13rasterBackendAA0eI12ContributionVSgvpfi"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe25RasterBackendContributionVSg) captures(none) initializes((0, 48)) %0) local_unnamed_addr #3 {
entry:
  store i32 2, ptr %0, align 4
  %.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(44) %.sroa.4.0..sroa_idx, i8 0, i64 44, i1 false)
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV14surfaceDisplayAA07SurfaceI12ContributionVSgvpfi"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionVSg) captures(none) initializes((0, 21)) %0) local_unnamed_addr #3 {
entry:
  %1 = getelementptr inbounds nuw i8, ptr %0, i32 20
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(20) %0, i8 0, i64 20, i1 false)
  store i8 1, ptr %1, align 4
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i32, i32, i32 } @"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV18hostResourcePolicyAA0efJ0VSgvpfi"() local_unnamed_addr #0 {
entry:
  ret { i32, i32, i32, i32 } { i32 0, i32 0, i32 0, i32 131072 }
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsVACycfC"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV) captures(none) initializes((0, 2), (4, 73), (76, 93)) %0) local_unnamed_addr #3 {
entry:
  store i16 512, ptr %0, align 4
  %.sroa.523.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 2, ptr %.sroa.523.0..sroa_idx, align 4
  %.sroa.624.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.2237.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 72
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(64) %.sroa.624.0..sroa_idx, i8 0, i64 64, i1 false)
  store i8 1, ptr %.sroa.2237.0..sroa_idx, align 4
  %.sroa.2438.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 76
  store i32 0, ptr %.sroa.2438.0..sroa_idx, align 4
  %.sroa.25.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 80
  store i32 0, ptr %.sroa.25.0..sroa_idx, align 4
  %.sroa.2639.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 84
  store i32 0, ptr %.sroa.2639.0..sroa_idx, align 4
  %.sroa.27.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 88
  store i32 131072, ptr %.sroa.27.0..sroa_idx, align 4
  %.sroa.28.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 92
  store i8 0, ptr %.sroa.28.0..sroa_idx, align 4
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc { i32, i32, i32 } @"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV6insertyAA0eF21ContributionInsertionOAA0efI0OF"(ptr noalias readonly captures(none) dereferenceable(49) %0, ptr swiftself captures(none) dereferenceable(93) %1) local_unnamed_addr #9 {
entry:
  %.sroa.0124.0.copyload = load i32, ptr %0, align 4
  %.sroa.8127.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.8127.0.copyload = load i32, ptr %.sroa.8127.0..sroa_idx, align 4
  %.sroa.10130.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.10130.0.copyload = load i32, ptr %.sroa.10130.0..sroa_idx, align 4
  %.sroa.12133.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.12133.0.copyload = load i32, ptr %.sroa.12133.0..sroa_idx, align 4
  %.sroa.17136.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.17136.0.copyload = load i32, ptr %.sroa.17136.0..sroa_idx, align 4
  %.sroa.18.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 20
  %.sroa.18140.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 48
  %.sroa.18140.0.copyload = load i8, ptr %.sroa.18140.0..sroa_idx, align 4
  switch i8 %.sroa.18140.0.copyload, label %2 [
    i8 0, label %3
    i8 1, label %12
    i8 2, label %19
    i8 3, label %31
  ]

2:                                                ; preds = %entry
  unreachable

3:                                                ; preds = %entry
  %4 = load i16, ptr %1, align 4
  %5 = and i16 %4, -256
  %6 = icmp eq i16 %5, 512
  br i1 %6, label %7, label %9

7:                                                ; preds = %3
  %8 = trunc i32 %.sroa.0124.0.copyload to i16
  store i16 %8, ptr %1, align 4
  br label %42

9:                                                ; preds = %3
  %.duplicateMask = getelementptr inbounds nuw i8, ptr %1, i32 92
  %10 = load i8, ptr %.duplicateMask, align 4
  %11 = or i8 %10, 1
  store i8 %11, ptr %.duplicateMask, align 4
  br label %42

12:                                               ; preds = %entry
  %.rasterBackend = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.029.0.copyload = load i32, ptr %.rasterBackend, align 4
  %13 = and i32 %.sroa.029.0.copyload, 255
  %14 = icmp eq i32 %13, 2
  br i1 %14, label %15, label %16

15:                                               ; preds = %12
  %.sroa.8.0..rasterBackend.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  store i32 %.sroa.0124.0.copyload, ptr %.rasterBackend, align 4
  store i32 %.sroa.8127.0.copyload, ptr %.sroa.8.0..rasterBackend.sroa_idx, align 4
  %.sroa.028.sroa.5.0..rasterBackend.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 12
  store i32 %.sroa.10130.0.copyload, ptr %.sroa.028.sroa.5.0..rasterBackend.sroa_idx, align 4
  %.sroa.028.sroa.6.0..rasterBackend.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 16
  store i32 %.sroa.12133.0.copyload, ptr %.sroa.028.sroa.6.0..rasterBackend.sroa_idx, align 4
  %.sroa.028.sroa.7.0..rasterBackend.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 20
  store i32 %.sroa.17136.0.copyload, ptr %.sroa.028.sroa.7.0..rasterBackend.sroa_idx, align 4
  %.sroa.028.sroa.8.0..rasterBackend.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 24
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(28) %.sroa.028.sroa.8.0..rasterBackend.sroa_idx, ptr noundef nonnull align 4 dereferenceable(28) %.sroa.18.0..sroa_idx, i32 28, i1 false)
  br label %42

16:                                               ; preds = %12
  %.duplicateMask.i = getelementptr inbounds nuw i8, ptr %1, i32 92
  %17 = load i8, ptr %.duplicateMask.i, align 4
  %18 = or i8 %17, 2
  store i8 %18, ptr %.duplicateMask.i, align 4
  br label %42

19:                                               ; preds = %entry
  %20 = getelementptr inbounds nuw i8, ptr %1, i32 72
  %21 = load i8, ptr %20, align 4
  %22 = icmp eq i8 %21, 1
  br i1 %22, label %23, label %28

23:                                               ; preds = %19
  %24 = getelementptr inbounds nuw i8, ptr %1, i32 68
  %25 = getelementptr inbounds nuw i8, ptr %1, i32 64
  %26 = getelementptr inbounds nuw i8, ptr %1, i32 60
  %27 = getelementptr inbounds nuw i8, ptr %1, i32 56
  %.surfaceDisplay = getelementptr inbounds nuw i8, ptr %1, i32 52
  store i32 %.sroa.0124.0.copyload, ptr %.surfaceDisplay, align 4
  store i32 %.sroa.8127.0.copyload, ptr %27, align 4
  store i32 %.sroa.10130.0.copyload, ptr %26, align 4
  store i32 %.sroa.12133.0.copyload, ptr %25, align 4
  store i32 %.sroa.17136.0.copyload, ptr %24, align 4
  store i8 0, ptr %20, align 4
  br label %42

28:                                               ; preds = %19
  %.duplicateMask.i186 = getelementptr inbounds nuw i8, ptr %1, i32 92
  %29 = load i8, ptr %.duplicateMask.i186, align 4
  %30 = or i8 %29, 4
  store i8 %30, ptr %.duplicateMask.i186, align 4
  br label %42

31:                                               ; preds = %entry
  %32 = getelementptr inbounds nuw i8, ptr %1, i32 88
  %33 = load i32, ptr %32, align 4
  %34 = and i32 %33, 16711680
  %35 = icmp eq i32 %34, 131072
  br i1 %35, label %36, label %39

36:                                               ; preds = %31
  %37 = getelementptr inbounds nuw i8, ptr %1, i32 84
  %38 = getelementptr inbounds nuw i8, ptr %1, i32 80
  %.hostResourcePolicy = getelementptr inbounds nuw i8, ptr %1, i32 76
  store i32 %.sroa.0124.0.copyload, ptr %.hostResourcePolicy, align 4
  store i32 %.sroa.8127.0.copyload, ptr %38, align 4
  store i32 %.sroa.10130.0.copyload, ptr %37, align 4
  store i32 %.sroa.12133.0.copyload, ptr %32, align 4
  br label %42

39:                                               ; preds = %31
  %.duplicateMask.i187 = getelementptr inbounds nuw i8, ptr %1, i32 92
  %40 = load i8, ptr %.duplicateMask.i187, align 4
  %41 = or i8 %40, 8
  store i8 %41, ptr %.duplicateMask.i187, align 4
  br label %42

42:                                               ; preds = %36, %23, %15, %7, %9, %16, %28, %39
  %43 = phi i32 [ 536870915, %39 ], [ 536870914, %28 ], [ 536870913, %16 ], [ 536870912, %9 ], [ -3856, %7 ], [ -3856, %15 ], [ -3856, %23 ], [ -3856, %36 ]
  %44 = insertvalue { i32, i32, i32 } undef, i32 %43, 0
  %45 = insertvalue { i32, i32, i32 } %44, i32 0, 1
  %46 = insertvalue { i32, i32, i32 } %45, i32 0, 2
  ret { i32, i32, i32 } %46
}

; Function Attrs: minsize nounwind optsize memory(argmem: readwrite, inaccessiblemem: write)
define protected swiftcc { i32, i32, i32 } @"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV15rejectDuplicate33_E17D99E015B31087C87CFA5F821C9FD5LLyAA0eF21ContributionInsertionOAA0eF15ContributorRoleOF"(i8 %0, ptr swiftself captures(none) dereferenceable(93) %1) local_unnamed_addr #10 {
entry:
  %2 = add i8 %0, 1
  %3 = tail call { i8, i1 } @llvm.usub.with.overflow.i8(i8 %2, i8 1)
  %4 = extractvalue { i8, i1 } %3, 1
  br i1 %4, label %17, label %5, !prof !6

5:                                                ; preds = %entry
  %6 = extractvalue { i8, i1 } %3, 0
  %7 = shl nuw i8 1, %6
  %8 = icmp ugt i8 %6, 7
  %9 = select i1 %8, i8 0, i8 %7
  %.duplicateMask = getelementptr inbounds nuw i8, ptr %1, i32 92
  %10 = load i8, ptr %.duplicateMask, align 4
  %11 = or i8 %10, %9
  store i8 %11, ptr %.duplicateMask, align 4
  %12 = zext i8 %0 to i32
  %13 = or disjoint i32 %12, 536870912
  %14 = insertvalue { i32, i32, i32 } undef, i32 %13, 0
  %15 = insertvalue { i32, i32, i32 } %14, i32 0, 1
  %16 = insertvalue { i32, i32, i32 } %15, i32 0, 2
  ret { i32, i32, i32 } %16

17:                                               ; preds = %entry
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.ssub.with.overflow.i32(i32, i32) #7

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV2eeoiySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(93) %0, ptr noalias readonly captures(none) dereferenceable(93) %1) local_unnamed_addr #2 {
entry:
  %2 = alloca %T27GiftUICapabilityLayoutProbe25RasterBackendContributionV, align 4
  %3 = alloca %T27GiftUICapabilityLayoutProbe25RasterBackendContributionV, align 4
  %4 = alloca %T27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV, align 4
  %5 = alloca %T27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV, align 4
  call void @llvm.lifetime.start.p0(i64 48, ptr nonnull %2)
  call void @llvm.lifetime.start.p0(i64 48, ptr nonnull %3)
  call void @llvm.lifetime.start.p0(i64 20, ptr nonnull %4)
  call void @llvm.lifetime.start.p0(i64 20, ptr nonnull %5)
  %.duplicateMask = getelementptr inbounds nuw i8, ptr %0, i32 92
  %.sroa.0137.0.copyload = load i8, ptr %.duplicateMask, align 4
  %.duplicateMask1 = getelementptr inbounds nuw i8, ptr %1, i32 92
  %.sroa.0136.0.copyload = load i8, ptr %.duplicateMask1, align 4
  %6 = icmp eq i8 %.sroa.0137.0.copyload, %.sroa.0136.0.copyload
  br i1 %6, label %7, label %55

7:                                                ; preds = %entry
  %8 = and i8 %.sroa.0137.0.copyload, 1
  %.not = icmp eq i8 %8, 0
  br i1 %.not, label %9, label %23

9:                                                ; preds = %7
  %10 = load i16, ptr %0, align 4
  %11 = load i16, ptr %1, align 4
  %12 = and i16 %10, -256
  %13 = icmp eq i16 %12, 512
  %14 = and i16 %11, -256
  br i1 %13, label %21, label %15

15:                                               ; preds = %9
  %16 = icmp ne i16 %14, 512
  %17 = trunc i16 %10 to i8
  %18 = trunc i16 %11 to i8
  %19 = icmp eq i8 %17, %18
  %or.cond = and i1 %16, %19
  %.unshifted = xor i16 %11, %10
  %20 = icmp ult i16 %.unshifted, 256
  %or.cond140 = select i1 %or.cond, i1 %20, i1 false
  br i1 %or.cond140, label %23, label %55

21:                                               ; preds = %9
  %22 = icmp eq i16 %14, 512
  br i1 %22, label %23, label %55

23:                                               ; preds = %15, %7, %21
  %24 = and i8 %.sroa.0137.0.copyload, 2
  %.not145 = icmp eq i8 %24, 0
  br i1 %.not145, label %25, label %34

25:                                               ; preds = %23
  %.rasterBackend = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.0134.0.copyload = load i32, ptr %.rasterBackend, align 4
  %.sroa.4135.0..rasterBackend.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.rasterBackend4 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.0132.0.copyload = load i32, ptr %.rasterBackend4, align 4
  %.sroa.4133.0..rasterBackend4.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %26 = and i32 %.sroa.0134.0.copyload, 255
  %27 = icmp eq i32 %26, 2
  %28 = and i32 %.sroa.0132.0.copyload, 255
  %29 = icmp eq i32 %28, 2
  br i1 %27, label %31, label %30

30:                                               ; preds = %25
  br i1 %29, label %55, label %32

31:                                               ; preds = %25
  br i1 %29, label %34, label %55

32:                                               ; preds = %30
  %.sroa.032.sroa.5.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 4
  call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(44) %.sroa.032.sroa.5.0..sroa_idx, ptr noundef nonnull align 4 dereferenceable(44) %.sroa.4133.0..rasterBackend4.sroa_idx, i32 44, i1 false)
  store i32 %.sroa.0132.0.copyload, ptr %2, align 4
  %.sroa.033.sroa.5.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 4
  call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(44) %.sroa.033.sroa.5.0..sroa_idx, ptr noundef nonnull align 4 dereferenceable(44) %.sroa.4135.0..rasterBackend.sroa_idx, i32 44, i1 false)
  store i32 %.sroa.0134.0.copyload, ptr %3, align 4
  %33 = call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe25RasterBackendContributionV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias nonnull captures(none) dereferenceable(48) %3, ptr noalias nonnull captures(none) dereferenceable(48) %2)
  br i1 %33, label %34, label %55

34:                                               ; preds = %31, %32, %23
  %35 = and i8 %.sroa.0137.0.copyload, 4
  %.not146 = icmp eq i8 %35, 0
  br i1 %.not146, label %36, label %43

36:                                               ; preds = %34
  %.surfaceDisplay = getelementptr inbounds nuw i8, ptr %0, i32 52
  %.sroa.0126.0.copyload = load i32, ptr %.surfaceDisplay, align 4
  %.sroa.4127.0..surfaceDisplay.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 56
  %.sroa.4127.0.copyload = load i32, ptr %.sroa.4127.0..surfaceDisplay.sroa_idx, align 4
  %.sroa.5128.0..surfaceDisplay.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 60
  %.sroa.5128.0.copyload = load i32, ptr %.sroa.5128.0..surfaceDisplay.sroa_idx, align 4
  %.sroa.6129.0..surfaceDisplay.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 64
  %.sroa.6129.0.copyload = load i32, ptr %.sroa.6129.0..surfaceDisplay.sroa_idx, align 4
  %.sroa.7130.0..surfaceDisplay.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 68
  %.sroa.7130.0.copyload = load i32, ptr %.sroa.7130.0..surfaceDisplay.sroa_idx, align 4
  %.sroa.8131.0..surfaceDisplay.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 72
  %.sroa.8131.0.copyload = load i8, ptr %.sroa.8131.0..surfaceDisplay.sroa_idx, align 4
  %.surfaceDisplay6 = getelementptr inbounds nuw i8, ptr %1, i32 52
  %.sroa.0120.0.copyload = load i32, ptr %.surfaceDisplay6, align 4
  %.sroa.4121.0..surfaceDisplay6.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 56
  %.sroa.4121.0.copyload = load i32, ptr %.sroa.4121.0..surfaceDisplay6.sroa_idx, align 4
  %.sroa.5122.0..surfaceDisplay6.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 60
  %.sroa.5122.0.copyload = load i32, ptr %.sroa.5122.0..surfaceDisplay6.sroa_idx, align 4
  %.sroa.6123.0..surfaceDisplay6.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 64
  %.sroa.6123.0.copyload = load i32, ptr %.sroa.6123.0..surfaceDisplay6.sroa_idx, align 4
  %.sroa.7124.0..surfaceDisplay6.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 68
  %.sroa.7124.0.copyload = load i32, ptr %.sroa.7124.0..surfaceDisplay6.sroa_idx, align 4
  %.sroa.8125.0..surfaceDisplay6.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 72
  %.sroa.8125.0.copyload = load i8, ptr %.sroa.8125.0..surfaceDisplay6.sroa_idx, align 4
  %37 = icmp eq i8 %.sroa.8131.0.copyload, 1
  %38 = icmp eq i8 %.sroa.8125.0.copyload, 1
  br i1 %37, label %42, label %39

39:                                               ; preds = %36
  br i1 %38, label %55, label %40

40:                                               ; preds = %39
  store i32 %.sroa.0126.0.copyload, ptr %5, align 4
  %.sroa.538.0..sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 4
  store i32 %.sroa.4127.0.copyload, ptr %.sroa.538.0..sroa_idx, align 4
  %.sroa.639.0..sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 8
  store i32 %.sroa.5128.0.copyload, ptr %.sroa.639.0..sroa_idx, align 4
  %.sroa.740.0..sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 12
  store i32 %.sroa.6129.0.copyload, ptr %.sroa.740.0..sroa_idx, align 4
  %.sroa.841.0..sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 16
  store i32 %.sroa.7130.0.copyload, ptr %.sroa.841.0..sroa_idx, align 4
  store i32 %.sroa.0120.0.copyload, ptr %4, align 4
  %.sroa.544.0..sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 4
  store i32 %.sroa.4121.0.copyload, ptr %.sroa.544.0..sroa_idx, align 4
  %.sroa.645.0..sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 8
  store i32 %.sroa.5122.0.copyload, ptr %.sroa.645.0..sroa_idx, align 4
  %.sroa.746.0..sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 12
  store i32 %.sroa.6123.0.copyload, ptr %.sroa.746.0..sroa_idx, align 4
  %.sroa.847.0..sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 16
  store i32 %.sroa.7124.0.copyload, ptr %.sroa.847.0..sroa_idx, align 4
  %41 = call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe26SurfaceDisplayContributionV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias nonnull captures(none) dereferenceable(20) %5, ptr noalias nonnull captures(none) dereferenceable(20) %4)
  br i1 %41, label %43, label %55

42:                                               ; preds = %36
  br i1 %38, label %43, label %55

43:                                               ; preds = %40, %42, %34
  %44 = and i8 %.sroa.0137.0.copyload, 8
  %.not147 = icmp eq i8 %44, 0
  br i1 %.not147, label %45, label %55

45:                                               ; preds = %43
  %.hostResourcePolicy = getelementptr inbounds nuw i8, ptr %0, i32 76
  %.sroa.0116.0.copyload = load i32, ptr %.hostResourcePolicy, align 4
  %.sroa.4117.0..hostResourcePolicy.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 80
  %.sroa.4117.0.copyload = load i32, ptr %.sroa.4117.0..hostResourcePolicy.sroa_idx, align 4
  %.sroa.5118.0..hostResourcePolicy.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 84
  %.sroa.5118.0.copyload = load i32, ptr %.sroa.5118.0..hostResourcePolicy.sroa_idx, align 4
  %.sroa.6119.0..hostResourcePolicy.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 88
  %.sroa.6119.0.copyload = load i32, ptr %.sroa.6119.0..hostResourcePolicy.sroa_idx, align 4
  %.hostResourcePolicy9 = getelementptr inbounds nuw i8, ptr %1, i32 76
  %.sroa.0112.0.copyload = load i32, ptr %.hostResourcePolicy9, align 4
  %.sroa.4113.0..hostResourcePolicy9.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 80
  %.sroa.4113.0.copyload = load i32, ptr %.sroa.4113.0..hostResourcePolicy9.sroa_idx, align 4
  %.sroa.5114.0..hostResourcePolicy9.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 84
  %.sroa.5114.0.copyload = load i32, ptr %.sroa.5114.0..hostResourcePolicy9.sroa_idx, align 4
  %.sroa.6115.0..hostResourcePolicy9.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 88
  %.sroa.6115.0.copyload = load i32, ptr %.sroa.6115.0..hostResourcePolicy9.sroa_idx, align 4
  %46 = and i32 %.sroa.6119.0.copyload, 16711680
  %47 = icmp eq i32 %46, 131072
  %48 = and i32 %.sroa.6115.0.copyload, 16711680
  %49 = icmp eq i32 %48, 131072
  br i1 %47, label %51, label %50

50:                                               ; preds = %45
  br i1 %49, label %55, label %52

51:                                               ; preds = %45
  br i1 %49, label %55, label %54

52:                                               ; preds = %50
  %53 = tail call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe24RasterPresentationPolicyV23__derived_struct_equalsySbAC_ACtFZ"(i32 %.sroa.0116.0.copyload, i32 %.sroa.4117.0.copyload, i32 %.sroa.5118.0.copyload, i32 %.sroa.6119.0.copyload, i32 %.sroa.0112.0.copyload, i32 %.sroa.4113.0.copyload, i32 %.sroa.5114.0.copyload, i32 %.sroa.6115.0.copyload)
  br label %55

54:                                               ; preds = %51
  br label %55

55:                                               ; preds = %30, %31, %32, %52, %50, %54, %51, %40, %42, %39, %entry, %15, %21, %43
  %56 = phi i1 [ true, %43 ], [ false, %21 ], [ false, %15 ], [ false, %entry ], [ false, %39 ], [ false, %42 ], [ false, %40 ], [ %53, %52 ], [ false, %50 ], [ false, %54 ], [ true, %51 ], [ false, %32 ], [ false, %31 ], [ false, %30 ]
  call void @llvm.lifetime.end.p0(i64 20, ptr nonnull %5)
  call void @llvm.lifetime.end.p0(i64 20, ptr nonnull %4)
  call void @llvm.lifetime.end.p0(i64 48, ptr nonnull %3)
  call void @llvm.lifetime.end.p0(i64 48, ptr nonnull %2)
  ret i1 %56
}

; Function Attrs: minsize nounwind optsize memory(argmem: read, inaccessiblemem: write)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV12hasDuplicate33_E17D99E015B31087C87CFA5F821C9FD5LLySbAA0eF15ContributorRoleOF"(i8 %0, ptr noalias readonly swiftself captures(none) dereferenceable(93) %1) local_unnamed_addr #11 {
entry:
  %2 = add i8 %0, 1
  %3 = tail call { i8, i1 } @llvm.usub.with.overflow.i8(i8 %2, i8 1)
  %4 = extractvalue { i8, i1 } %3, 1
  br i1 %4, label %12, label %5, !prof !6

5:                                                ; preds = %entry
  %6 = extractvalue { i8, i1 } %3, 0
  %7 = shl nuw i8 1, %6
  %8 = icmp ugt i8 %6, 7
  %9 = select i1 %8, i8 0, i8 %7
  %.duplicateMask = getelementptr inbounds nuw i8, ptr %1, i32 92
  %.sroa.0.0.copyload = load i8, ptr %.duplicateMask, align 4
  %10 = and i8 %.sroa.0.0.copyload, %9
  %11 = icmp ne i8 %10, 0
  ret i1 %11

12:                                               ; preds = %entry
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc range(i8 0, 5) i8 @"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV17lowestMissingRole33_E17D99E015B31087C87CFA5F821C9FD5LLAA0ef11ContributorJ0OSgvg"(ptr noalias readonly swiftself captures(none) dereferenceable(93) %0) local_unnamed_addr #2 {
entry:
  %.sroa.0125.sroa.0.0.copyload = load i16, ptr %0, align 4
  %1 = and i16 %.sroa.0125.sroa.0.0.copyload, -256
  %2 = icmp eq i16 %1, 512
  br i1 %2, label %11, label %3

3:                                                ; preds = %entry
  %.rasterBackend = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.0123.0.copyload = load i32, ptr %.rasterBackend, align 4
  %4 = and i32 %.sroa.0123.0.copyload, 255
  %5 = icmp eq i32 %4, 2
  br i1 %5, label %11, label %6

6:                                                ; preds = %3
  %.sroa.8122.0..surfaceDisplay.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 72
  %.sroa.8122.0.copyload = load i8, ptr %.sroa.8122.0..surfaceDisplay.sroa_idx, align 4
  %7 = icmp eq i8 %.sroa.8122.0.copyload, 1
  br i1 %7, label %11, label %8

8:                                                ; preds = %6
  %.sroa.6116.0..hostResourcePolicy.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 88
  %.sroa.6116.0.copyload = load i32, ptr %.sroa.6116.0..hostResourcePolicy.sroa_idx, align 4
  %9 = and i32 %.sroa.6116.0.copyload, 16711680
  %10 = icmp eq i32 %9, 131072
  %spec.select = select i1 %10, i8 3, i8 4
  br label %11

11:                                               ; preds = %8, %6, %3, %entry
  %12 = phi i8 [ 0, %entry ], [ 1, %3 ], [ 2, %6 ], [ %spec.select, %8 ]
  ret i8 %12
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(inaccessiblemem: write)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe39RasterPresentationContributionInsertionO21__derived_enum_equalsySbAC_ACtFZ"(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5) local_unnamed_addr #12 {
entry:
  %6 = and i32 %0, -3856
  %7 = icmp eq i32 %6, -3856
  %8 = and i32 %3, -3856
  %9 = icmp eq i32 %8, -3856
  br i1 %7, label %10, label %11

10:                                               ; preds = %entry
  br i1 %9, label %15, label %14

11:                                               ; preds = %entry
  br i1 %9, label %14, label %12

12:                                               ; preds = %11
  %13 = tail call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationUnavailableO21__derived_enum_equalsySbAC_ACtFZ"(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5)
  br label %15

14:                                               ; preds = %11, %10
  br label %15

15:                                               ; preds = %12, %10, %14
  %16 = phi i1 [ false, %14 ], [ true, %10 ], [ %13, %12 ]
  ret i1 %16
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe37NormalizedRasterPresentationCandidateV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(24) %0, ptr noalias readonly captures(none) dereferenceable(24) %1) local_unnamed_addr #2 {
entry:
  %2 = tail call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias nonnull captures(none) dereferenceable(24) %0, ptr noalias nonnull captures(none) dereferenceable(24) %1)
  ret i1 %2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe33RasterPresentationArithmeticValueV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(24) %0, ptr noalias readonly captures(none) dereferenceable(24) %1) local_unnamed_addr #2 {
entry:
  %.sroa.062.0.copyload = load i32, ptr %0, align 4
  %.sroa.061.0.copyload = load i32, ptr %1, align 4
  %2 = icmp eq i32 %.sroa.062.0.copyload, %.sroa.061.0.copyload
  br i1 %2, label %3, label %15

3:                                                ; preds = %entry
  %.regionExtent = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.057.0.copyload = load i16, ptr %.regionExtent, align 4
  %.regionExtent3 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.053.0.copyload = load i16, ptr %.regionExtent3, align 4
  %4 = icmp eq i16 %.sroa.057.0.copyload, %.sroa.053.0.copyload
  br i1 %4, label %5, label %15

5:                                                ; preds = %3
  %.sroa.4.0..regionExtent3.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 6
  %.sroa.4.0.copyload = load i16, ptr %.sroa.4.0..regionExtent3.sroa_idx, align 2
  %.sroa.459.0..regionExtent.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 6
  %.sroa.459.0.copyload = load i16, ptr %.sroa.459.0..regionExtent.sroa_idx, align 2
  %6 = icmp eq i16 %.sroa.459.0.copyload, %.sroa.4.0.copyload
  br i1 %6, label %7, label %15

7:                                                ; preds = %5
  %.rowBytes = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.049.0.copyload = load i32, ptr %.rowBytes, align 4
  %.rowBytes10 = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.046.0.copyload = load i32, ptr %.rowBytes10, align 4
  %8 = icmp eq i32 %.sroa.049.0.copyload, %.sroa.046.0.copyload
  br i1 %8, label %9, label %15

9:                                                ; preds = %7
  %.requiredRasterBytes = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.043.0.copyload = load i32, ptr %.requiredRasterBytes, align 4
  %.requiredRasterBytes14 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.040.0.copyload = load i32, ptr %.requiredRasterBytes14, align 4
  %10 = icmp eq i32 %.sroa.043.0.copyload, %.sroa.040.0.copyload
  br i1 %10, label %11, label %15

11:                                               ; preds = %9
  %.requiredPayloadBytes = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.037.0.copyload = load i32, ptr %.requiredPayloadBytes, align 4
  %.requiredPayloadBytes19 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.sroa.034.0.copyload = load i32, ptr %.requiredPayloadBytes19, align 4
  %12 = icmp eq i32 %.sroa.037.0.copyload, %.sroa.034.0.copyload
  br i1 %12, label %13, label %15

13:                                               ; preds = %11
  %.requiredInFlightBytes = getelementptr inbounds nuw i8, ptr %0, i32 20
  %.sroa.031.0.copyload = load i32, ptr %.requiredInFlightBytes, align 4
  %.requiredInFlightBytes24 = getelementptr inbounds nuw i8, ptr %1, i32 20
  %.sroa.0.0.copyload = load i32, ptr %.requiredInFlightBytes24, align 4
  %14 = icmp eq i32 %.sroa.031.0.copyload, %.sroa.0.0.copyload
  br label %15

15:                                               ; preds = %entry, %5, %3, %7, %9, %11, %13
  %16 = phi i1 [ %14, %13 ], [ false, %11 ], [ false, %9 ], [ false, %7 ], [ false, %3 ], [ false, %5 ], [ false, %entry ]
  ret i1 %16
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read, inaccessiblemem: write)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe35RasterPresentationArithmeticOutcomeO21__derived_enum_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(25) %0, ptr noalias readonly captures(none) dereferenceable(25) %1) local_unnamed_addr #13 {
entry:
  %.sroa.041.0.copyload = load i32, ptr %0, align 4
  %.sroa.543.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.543.0.copyload = load i32, ptr %.sroa.543.0..sroa_idx, align 4
  %.sroa.646.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.646.0.copyload = load i32, ptr %.sroa.646.0..sroa_idx, align 4
  %.sroa.749.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.749.sroa.0.0.copyload = load i32, ptr %.sroa.749.0..sroa_idx, align 4
  %.sroa.749.sroa.4.0..sroa.749.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.749.sroa.4.0.copyload = load i32, ptr %.sroa.749.sroa.4.0..sroa.749.0..sroa_idx.sroa_idx, align 4
  %.sroa.749.sroa.5.0..sroa.749.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 20
  %.sroa.749.sroa.5.0.copyload = load i32, ptr %.sroa.749.sroa.5.0..sroa.749.0..sroa_idx.sroa_idx, align 4
  %.sroa.751.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 24
  %.sroa.751.0.copyload = load i8, ptr %.sroa.751.0..sroa_idx, align 4
  %.not = icmp eq i8 %.sroa.751.0.copyload, 1
  %.sroa.738.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 24
  %.sroa.738.0.copyload = load i8, ptr %.sroa.738.0..sroa_idx, align 4
  %.not87 = icmp eq i8 %.sroa.738.0.copyload, 1
  br i1 %.not, label %11, label %2

2:                                                ; preds = %entry
  br i1 %.not87, label %14, label %3

3:                                                ; preds = %2
  %.sroa.0.sroa.9.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 20
  %.sroa.0.sroa.9.0.copyload = load i32, ptr %.sroa.0.sroa.9.0..sroa_idx, align 4
  %.sroa.0.sroa.8.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.sroa.0.sroa.8.0.copyload = load i32, ptr %.sroa.0.sroa.8.0..sroa_idx, align 4
  %.sroa.0.sroa.7.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.0.sroa.7.0.copyload = load i32, ptr %.sroa.0.sroa.7.0..sroa_idx, align 4
  %.sroa.0.sroa.6.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.0.sroa.6.0.copyload = load i32, ptr %.sroa.0.sroa.6.0..sroa_idx, align 4
  %.sroa.0.sroa.5.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.0.sroa.5.0.copyload = load i32, ptr %.sroa.0.sroa.5.0..sroa_idx, align 4
  %.sroa.0.sroa.0.0.copyload = load i32, ptr %1, align 4
  %4 = icmp eq i32 %.sroa.041.0.copyload, %.sroa.0.sroa.0.0.copyload
  %5 = icmp eq i32 %.sroa.543.0.copyload, %.sroa.0.sroa.5.0.copyload
  %or.cond89 = select i1 %4, i1 %5, i1 false
  %6 = icmp eq i32 %.sroa.646.0.copyload, %.sroa.0.sroa.6.0.copyload
  %or.cond90 = select i1 %or.cond89, i1 %6, i1 false
  %7 = icmp eq i32 %.sroa.749.sroa.0.0.copyload, %.sroa.0.sroa.7.0.copyload
  %or.cond91 = select i1 %or.cond90, i1 %7, i1 false
  %8 = icmp eq i32 %.sroa.749.sroa.4.0.copyload, %.sroa.0.sroa.8.0.copyload
  %or.cond92 = select i1 %or.cond91, i1 %8, i1 false
  %9 = icmp eq i32 %.sroa.749.sroa.5.0.copyload, %.sroa.0.sroa.9.0.copyload
  %or.cond93 = select i1 %or.cond92, i1 %9, i1 false
  br i1 %or.cond93, label %14, label %10

10:                                               ; preds = %3
  br label %14

11:                                               ; preds = %entry
  br i1 %.not87, label %12, label %14

12:                                               ; preds = %11
  %.sroa.6.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.6.0.copyload = load i32, ptr %.sroa.6.0..sroa_idx, align 4
  %.sroa.532.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.532.0.copyload = load i32, ptr %.sroa.532.0..sroa_idx, align 4
  %.sroa.030.0.copyload = load i32, ptr %1, align 4
  %13 = tail call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationUnavailableO21__derived_enum_equalsySbAC_ACtFZ"(i32 %.sroa.041.0.copyload, i32 %.sroa.543.0.copyload, i32 %.sroa.646.0.copyload, i32 %.sroa.030.0.copyload, i32 %.sroa.532.0.copyload, i32 %.sroa.6.0.copyload)
  br label %14

14:                                               ; preds = %11, %2, %3, %12, %10
  %15 = phi i1 [ false, %10 ], [ %13, %12 ], [ true, %3 ], [ false, %2 ], [ false, %11 ]
  ret i1 %15
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(inaccessiblemem: write)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe31RasterPresentationRegionOutcomeO21__derived_enum_equalsySbAC_ACtFZ"(i32 %0, i32 %1, i32 %2, i8 %3, i32 %4, i32 %5, i32 %6, i8 %7) local_unnamed_addr #12 {
entry:
  %.not = icmp eq i8 %3, 1
  %.not1 = icmp eq i8 %7, 1
  br i1 %.not, label %11, label %8

8:                                                ; preds = %entry
  br i1 %.not1, label %14, label %9

9:                                                ; preds = %8
  %or.cond = icmp eq i32 %0, %4
  br i1 %or.cond, label %14, label %10

10:                                               ; preds = %9
  br label %14

11:                                               ; preds = %entry
  br i1 %.not1, label %12, label %14

12:                                               ; preds = %11
  %13 = tail call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationUnavailableO21__derived_enum_equalsySbAC_ACtFZ"(i32 %0, i32 %1, i32 %2, i32 %4, i32 %5, i32 %6)
  br label %14

14:                                               ; preds = %9, %8, %11, %12, %10
  %15 = phi i1 [ false, %10 ], [ %13, %12 ], [ false, %11 ], [ false, %8 ], [ true, %9 ]
  ret i1 %15
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc { i32, i32, i32, i8 } @"$e27GiftUICapabilityLayoutProbe28RasterPresentationArithmeticO6region11requirement11realization7surfaceAA0eF13RegionOutcomeOAA0eF11RequirementV_AA0E23RealizationContributionVAA014SurfaceDisplayP0VtFZ"(ptr noalias readonly captures(none) dereferenceable(25) %0, ptr noalias readonly captures(none) dereferenceable(24) %1, ptr noalias readonly captures(none) dereferenceable(20) %2) local_unnamed_addr #2 {
entry:
  %.extent = getelementptr inbounds nuw i8, ptr %0, i32 2
  %.sroa.031.0.copyload = load i16, ptr %.extent, align 2
  %.sroa.432.0..extent.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.432.0.copyload = load i16, ptr %.sroa.432.0..extent.sroa_idx, align 2
  %.maximumExtent = getelementptr inbounds nuw i8, ptr %1, i32 6
  %.sroa.027.0.copyload = load i16, ptr %.maximumExtent, align 2
  %.not = icmp ult i16 %.sroa.027.0.copyload, %.sroa.031.0.copyload
  br i1 %.not, label %24, label %3

3:                                                ; preds = %entry
  %.sroa.429.0..maximumExtent.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.429.0.copyload = load i16, ptr %.sroa.429.0..maximumExtent.sroa_idx, align 2
  %.not34 = icmp ult i16 %.sroa.429.0.copyload, %.sroa.432.0.copyload
  br i1 %.not34, label %24, label %4

4:                                                ; preds = %3
  %.sroa.023.0.copyload = load i16, ptr %2, align 4
  %.not35 = icmp ult i16 %.sroa.023.0.copyload, %.sroa.031.0.copyload
  br i1 %.not35, label %24, label %5

5:                                                ; preds = %4
  %.sroa.4.0..extent4.sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 2
  %.sroa.4.0.copyload = load i16, ptr %.sroa.4.0..extent4.sroa_idx, align 2
  %.not36 = icmp ult i16 %.sroa.4.0.copyload, %.sroa.432.0.copyload
  br i1 %.not36, label %24, label %6

6:                                                ; preds = %5
  %.maximumRegionWidth = getelementptr inbounds nuw i8, ptr %1, i32 10
  %.sroa.021.0.copyload = load i16, ptr %.maximumRegionWidth, align 2
  %.not37 = icmp ult i16 %.sroa.021.0.copyload, %.sroa.031.0.copyload
  br i1 %.not37, label %24, label %7

7:                                                ; preds = %6
  %.maximumRegionWidth10 = getelementptr inbounds nuw i8, ptr %2, i32 8
  %.sroa.020.0.copyload = load i16, ptr %.maximumRegionWidth10, align 4
  %.not38 = icmp ult i16 %.sroa.020.0.copyload, %.sroa.031.0.copyload
  br i1 %.not38, label %24, label %8

8:                                                ; preds = %7
  %.unpack = load i8, ptr %1, align 4
  %.not39 = icmp eq i8 %.unpack, 1
  %.maximumRegionHeight = getelementptr inbounds nuw i8, ptr %1, i32 12
  %9 = load i16, ptr %.maximumRegionHeight, align 4
  br i1 %.not39, label %12, label %10

10:                                               ; preds = %8
  %.not40 = icmp ult i16 %9, %.sroa.432.0.copyload
  br i1 %.not40, label %24, label %11

11:                                               ; preds = %10
  %.maximumRegionHeight15 = getelementptr inbounds nuw i8, ptr %2, i32 10
  %.sroa.0.0.copyload = load i16, ptr %.maximumRegionHeight15, align 2
  %.not41 = icmp ult i16 %.sroa.0.0.copyload, %.sroa.432.0.copyload
  br i1 %.not41, label %24, label %15

12:                                               ; preds = %8
  %.maximumRegionHeight12 = getelementptr inbounds nuw i8, ptr %2, i32 10
  %13 = load i16, ptr %.maximumRegionHeight12, align 2
  %. = tail call i16 @llvm.umin.i16(i16 %13, i16 %9)
  %14 = tail call i16 @llvm.umin.i16(i16 %., i16 %.sroa.432.0.copyload)
  br label %15

15:                                               ; preds = %11, %12
  %16 = phi i16 [ %14, %12 ], [ %.sroa.432.0.copyload, %11 ]
  %17 = icmp ne i16 %.sroa.031.0.copyload, 0
  %18 = icmp ne i16 %16, 0
  %or.cond = select i1 %17, i1 %18, i1 false
  br i1 %or.cond, label %19, label %24

19:                                               ; preds = %15
  %20 = zext i16 %.sroa.031.0.copyload to i32
  %21 = zext i16 %16 to i32
  %22 = shl nuw i32 %21, 16
  %23 = or disjoint i32 %22, %20
  br label %24

24:                                               ; preds = %7, %6, %5, %4, %3, %entry, %15, %11, %10, %19
  %25 = phi i32 [ %23, %19 ], [ -1073741821, %10 ], [ -1073741821, %11 ], [ -1073741821, %15 ], [ -1073741821, %entry ], [ -1073741821, %3 ], [ -1073741821, %4 ], [ -1073741821, %5 ], [ -1073741821, %6 ], [ -1073741821, %7 ]
  %26 = phi i8 [ 0, %19 ], [ 1, %10 ], [ 1, %11 ], [ 1, %15 ], [ 1, %entry ], [ 1, %3 ], [ 1, %4 ], [ 1, %5 ], [ 1, %6 ], [ 1, %7 ]
  %27 = insertvalue { i32, i32, i32, i8 } undef, i32 %25, 0
  %28 = insertvalue { i32, i32, i32, i8 } %27, i32 0, 1
  %29 = insertvalue { i32, i32, i32, i8 } %28, i32 0, 2
  %30 = insertvalue { i32, i32, i32, i8 } %29, i8 %26, 3
  ret { i32, i32, i32, i8 } %30
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe31RasterPresentationCandidatePathV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(28) %0, ptr noalias readonly captures(none) dereferenceable(28) %1) local_unnamed_addr #2 {
entry:
  %.unpack = load i8, ptr %0, align 4
  %.unpack51 = load i8, ptr %1, align 4
  %2 = icmp eq i8 %.unpack, %.unpack51
  br i1 %2, label %3, label %11

3:                                                ; preds = %entry
  %.encoding = getelementptr inbounds nuw i8, ptr %0, i32 1
  %.unpack52 = load i8, ptr %.encoding, align 1
  %.encoding2 = getelementptr inbounds nuw i8, ptr %1, i32 1
  %.unpack53 = load i8, ptr %.encoding2, align 1
  %4 = icmp eq i8 %.unpack52, %.unpack53
  br i1 %4, label %5, label %11

5:                                                ; preds = %3
  %.submissionLifetime = getelementptr inbounds nuw i8, ptr %0, i32 2
  %.unpack54 = load i8, ptr %.submissionLifetime, align 2
  %.submissionLifetime3 = getelementptr inbounds nuw i8, ptr %1, i32 2
  %.unpack55 = load i8, ptr %.submissionLifetime3, align 2
  %6 = icmp eq i8 %.unpack54, %.unpack55
  br i1 %6, label %7, label %11

7:                                                ; preds = %5
  %.handoff = getelementptr inbounds nuw i8, ptr %0, i32 3
  %.unpack56 = load i8, ptr %.handoff, align 1
  %.handoff4 = getelementptr inbounds nuw i8, ptr %1, i32 3
  %.unpack57 = load i8, ptr %.handoff4, align 1
  %8 = icmp eq i8 %.unpack56, %.unpack57
  br i1 %8, label %9, label %11

9:                                                ; preds = %7
  %.arithmetic = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.arithmetic5 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %10 = tail call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe33RasterPresentationArithmeticValueV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias nonnull captures(none) dereferenceable(24) %.arithmetic, ptr noalias nonnull captures(none) dereferenceable(24) %.arithmetic5)
  br label %11

11:                                               ; preds = %entry, %3, %5, %7, %9
  %12 = phi i1 [ %10, %9 ], [ false, %7 ], [ false, %5 ], [ false, %3 ], [ false, %entry ]
  ret i1 %12
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read, inaccessiblemem: write)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe34RasterPresentationCandidateOutcomeO21__derived_enum_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(28) %0, ptr noalias readonly captures(none) dereferenceable(28) %1) local_unnamed_addr #13 {
entry:
  %2 = alloca %T27GiftUICapabilityLayoutProbe31RasterPresentationCandidatePathV, align 4
  %3 = alloca %T27GiftUICapabilityLayoutProbe31RasterPresentationCandidatePathV, align 4
  call void @llvm.lifetime.start.p0(i64 28, ptr nonnull %2)
  call void @llvm.lifetime.start.p0(i64 28, ptr nonnull %3)
  %.sroa.058.0.copyload = load i32, ptr %0, align 4
  %.sroa.1063.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.1063.0.copyload = load i32, ptr %.sroa.1063.0..sroa_idx, align 4
  %.sroa.1568.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.1568.0.copyload = load i32, ptr %.sroa.1568.0..sroa_idx, align 4
  %4 = and i32 %.sroa.058.0.copyload, 268435456
  %.not.not = icmp eq i32 %4, 0
  br i1 %.not.not, label %5, label %9

5:                                                ; preds = %entry
  %.sroa.3285.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 24
  %.sroa.3285.0.copyload = load i32, ptr %.sroa.3285.0..sroa_idx, align 4
  %.sroa.2881.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 20
  %.sroa.2881.0.copyload = load i32, ptr %.sroa.2881.0..sroa_idx, align 4
  %.sroa.2477.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.2477.0.copyload = load i32, ptr %.sroa.2477.0..sroa_idx, align 4
  %.sroa.2073.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.2073.0.copyload = load i32, ptr %.sroa.2073.0..sroa_idx, align 4
  store i32 %.sroa.058.0.copyload, ptr %2, align 4
  %.sroa.1063.0..sroa_idx64 = getelementptr inbounds nuw i8, ptr %2, i32 4
  store i32 %.sroa.1063.0.copyload, ptr %.sroa.1063.0..sroa_idx64, align 4
  %.sroa.1568.0..sroa_idx69 = getelementptr inbounds nuw i8, ptr %2, i32 8
  store i32 %.sroa.1568.0.copyload, ptr %.sroa.1568.0..sroa_idx69, align 4
  %.sroa.2073.0..sroa_idx74 = getelementptr inbounds nuw i8, ptr %2, i32 12
  store i32 %.sroa.2073.0.copyload, ptr %.sroa.2073.0..sroa_idx74, align 4
  %.sroa.2477.0..sroa_idx78 = getelementptr inbounds nuw i8, ptr %2, i32 16
  store i32 %.sroa.2477.0.copyload, ptr %.sroa.2477.0..sroa_idx78, align 4
  %.sroa.2881.0..sroa_idx82 = getelementptr inbounds nuw i8, ptr %2, i32 20
  store i32 %.sroa.2881.0.copyload, ptr %.sroa.2881.0..sroa_idx82, align 4
  %.sroa.3285.0..sroa_idx86 = getelementptr inbounds nuw i8, ptr %2, i32 24
  store i32 %.sroa.3285.0.copyload, ptr %.sroa.3285.0..sroa_idx86, align 4
  %.sroa.0.0.copyload = load i32, ptr %1, align 4
  %6 = and i32 %.sroa.0.0.copyload, 268435456
  %.not.not90 = icmp eq i32 %6, 0
  br i1 %.not.not90, label %7, label %15

7:                                                ; preds = %5
  %.sroa.30.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 24
  %.sroa.30.0.copyload = load i32, ptr %.sroa.30.0..sroa_idx, align 4
  %.sroa.26.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 20
  %.sroa.26.0.copyload = load i32, ptr %.sroa.26.0..sroa_idx, align 4
  %.sroa.22.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.sroa.22.0.copyload = load i32, ptr %.sroa.22.0..sroa_idx, align 4
  %.sroa.18.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.18.0.copyload = load i32, ptr %.sroa.18.0..sroa_idx, align 4
  %.sroa.14.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.14.0.copyload = load i32, ptr %.sroa.14.0..sroa_idx, align 4
  %.sroa.10.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.10.0.copyload = load i32, ptr %.sroa.10.0..sroa_idx, align 4
  store i32 %.sroa.0.0.copyload, ptr %3, align 4
  %.sroa.10.0..sroa_idx6 = getelementptr inbounds nuw i8, ptr %3, i32 4
  store i32 %.sroa.10.0.copyload, ptr %.sroa.10.0..sroa_idx6, align 4
  %.sroa.14.0..sroa_idx11 = getelementptr inbounds nuw i8, ptr %3, i32 8
  store i32 %.sroa.14.0.copyload, ptr %.sroa.14.0..sroa_idx11, align 4
  %.sroa.18.0..sroa_idx16 = getelementptr inbounds nuw i8, ptr %3, i32 12
  store i32 %.sroa.18.0.copyload, ptr %.sroa.18.0..sroa_idx16, align 4
  %.sroa.22.0..sroa_idx19 = getelementptr inbounds nuw i8, ptr %3, i32 16
  store i32 %.sroa.22.0.copyload, ptr %.sroa.22.0..sroa_idx19, align 4
  %.sroa.26.0..sroa_idx22 = getelementptr inbounds nuw i8, ptr %3, i32 20
  store i32 %.sroa.26.0.copyload, ptr %.sroa.26.0..sroa_idx22, align 4
  %.sroa.30.0..sroa_idx25 = getelementptr inbounds nuw i8, ptr %3, i32 24
  store i32 %.sroa.30.0.copyload, ptr %.sroa.30.0..sroa_idx25, align 4
  %8 = call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe31RasterPresentationCandidatePathV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias nonnull captures(none) dereferenceable(28) %2, ptr noalias nonnull captures(none) dereferenceable(28) %3)
  br label %15

9:                                                ; preds = %entry
  %.sroa.029.0.copyload = load i32, ptr %1, align 4
  %10 = and i32 %.sroa.029.0.copyload, 268435456
  %.not.not89 = icmp eq i32 %10, 0
  br i1 %.not.not89, label %15, label %11

11:                                               ; preds = %9
  %.sroa.15.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.15.0.copyload = load i32, ptr %.sroa.15.0..sroa_idx, align 4
  %.sroa.1034.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.1034.0.copyload = load i32, ptr %.sroa.1034.0..sroa_idx, align 4
  %12 = and i32 %.sroa.058.0.copyload, -268435457
  %13 = and i32 %.sroa.029.0.copyload, -268435457
  %14 = tail call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationUnavailableO21__derived_enum_equalsySbAC_ACtFZ"(i32 %12, i32 %.sroa.1063.0.copyload, i32 %.sroa.1568.0.copyload, i32 %13, i32 %.sroa.1034.0.copyload, i32 %.sroa.15.0.copyload)
  br label %15

15:                                               ; preds = %9, %5, %11, %7
  %16 = phi i1 [ %8, %7 ], [ %14, %11 ], [ false, %5 ], [ false, %9 ]
  call void @llvm.lifetime.end.p0(i64 28, ptr nonnull %3)
  call void @llvm.lifetime.end.p0(i64 28, ptr nonnull %2)
  ret i1 %16
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc { i32, i32, i32 } @"$e27GiftUICapabilityLayoutProbe31RasterPresentationCompatibilityO13producerIssue11requirement0H0AA0eF11UnavailableOSgAA0eF11RequirementV_AA26RenderProducerContributionVtFZ"(ptr noalias readonly captures(none) dereferenceable(25) %0, i16 %1) local_unnamed_addr #2 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i16 %1 to i8
  %.sroa.05.0.copyload = load i8, ptr %0, align 4
  %2 = and i8 %.sroa.05.0.copyload, %temp-coercion.coerced.sroa.0.0.extract.trunc
  %3 = icmp eq i8 %2, %.sroa.05.0.copyload
  br i1 %3, label %4, label %7

4:                                                ; preds = %entry
  %temp-coercion.coerced.sroa.4.0.extract.shift = lshr i16 %1, 8
  %.operationStream = getelementptr inbounds nuw i8, ptr %0, i32 6
  %.unpack = load i8, ptr %.operationStream, align 2
  %5 = zext i8 %.unpack to i16
  %6 = icmp eq i16 %temp-coercion.coerced.sroa.4.0.extract.shift, %5
  %. = select i1 %6, i32 -3856, i32 -1073741823
  br label %7

7:                                                ; preds = %entry, %4
  %8 = phi i32 [ %., %4 ], [ -1073741824, %entry ]
  %9 = insertvalue { i32, i32, i32 } undef, i32 %8, 0
  %10 = insertvalue { i32, i32, i32 } %9, i32 0, 1
  %11 = insertvalue { i32, i32, i32 } %10, i32 0, 2
  ret { i32, i32, i32 } %11
}

; Function Attrs: minsize nounwind optsize memory(argmem: readwrite, inaccessiblemem: write)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe31RasterPresentationCompatibilityO17evaluateCandidate11requirement11realization7surface6policyAA0efI7OutcomeOAA0eF11RequirementV_AA0E23RealizationContributionVAA014SurfaceDisplayQ0VAA0eF6PolicyVtFZ"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe34RasterPresentationCandidateOutcomeO) captures(none) %0, ptr noalias readonly captures(none) dereferenceable(25) %1, ptr noalias readonly captures(none) dereferenceable(24) %2, ptr noalias readonly captures(none) dereferenceable(20) %3, i32 %4, i32 %5, i32 %6, i32 %7) local_unnamed_addr #10 {
entry:
  %temp-coercion.coerced.sroa.8.12.extract.trunc = trunc i32 %7 to i8
  %temp-coercion.coerced.sroa.8.13.extract.shift = lshr i32 %7, 8
  %temp-coercion.coerced.sroa.8.13.extract.trunc = trunc i32 %temp-coercion.coerced.sroa.8.13.extract.shift to i8
  %temp-coercion.coerced.sroa.8.15.extract.shift = lshr i32 %7, 24
  %temp-coercion.coerced.sroa.8.15.extract.trunc = trunc nuw i32 %temp-coercion.coerced.sroa.8.15.extract.shift to i8
  %8 = tail call swiftcc { i32, i32, i32, i8 } @"$e27GiftUICapabilityLayoutProbe28RasterPresentationArithmeticO6region11requirement11realization7surfaceAA0eF13RegionOutcomeOAA0eF11RequirementV_AA0E23RealizationContributionVAA014SurfaceDisplayP0VtFZ"(ptr noalias nonnull captures(none) dereferenceable(25) %1, ptr noalias nonnull captures(none) dereferenceable(24) %2, ptr noalias nonnull captures(none) dereferenceable(20) %3)
  %9 = extractvalue { i32, i32, i32, i8 } %8, 0
  %10 = extractvalue { i32, i32, i32, i8 } %8, 3
  %.not = icmp eq i8 %10, 1
  br i1 %.not, label %11, label %13

11:                                               ; preds = %entry
  %12 = or i32 %9, 268435456
  br label %183

13:                                               ; preds = %entry
  %.operations = getelementptr inbounds nuw i8, ptr %2, i32 1
  %.sroa.0423.0.copyload = load i8, ptr %.operations, align 1
  %.sroa.0420.0.copyload = load i8, ptr %1, align 4
  %14 = and i8 %.sroa.0420.0.copyload, %.sroa.0423.0.copyload
  %15 = icmp eq i8 %14, %.sroa.0420.0.copyload
  br i1 %15, label %16, label %183

16:                                               ; preds = %13
  %.operationStream = getelementptr inbounds nuw i8, ptr %2, i32 2
  %.unpack = load i8, ptr %.operationStream, align 2
  %.operationStream4 = getelementptr inbounds nuw i8, ptr %1, i32 6
  %.unpack446 = load i8, ptr %.operationStream4, align 2
  %17 = icmp eq i8 %.unpack, %.unpack446
  br i1 %17, label %18, label %183

18:                                               ; preds = %16
  %.acceptedEncodings = getelementptr inbounds nuw i8, ptr %1, i32 7
  %.sroa.0410.0.copyload = load i8, ptr %.acceptedEncodings, align 1
  %.encodings = getelementptr inbounds nuw i8, ptr %2, i32 3
  %.sroa.0407.0.copyload = load i8, ptr %.encodings, align 1
  %19 = and i8 %.sroa.0407.0.copyload, %.sroa.0410.0.copyload
  %.encodings9 = getelementptr inbounds nuw i8, ptr %3, i32 4
  %.sroa.0404.0.copyload = load i8, ptr %.encodings9, align 4
  %20 = and i8 %19, %.sroa.0404.0.copyload
  %21 = icmp eq i8 %20, 0
  br i1 %21, label %183, label %22

22:                                               ; preds = %18
  %.acceptedSubmissionLifetimes = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.0401.0.copyload = load i8, ptr %.acceptedSubmissionLifetimes, align 4
  %.producedSubmissionLifetimes = getelementptr inbounds nuw i8, ptr %2, i32 4
  %.sroa.0398.0.copyload = load i8, ptr %.producedSubmissionLifetimes, align 4
  %23 = and i8 %.sroa.0398.0.copyload, %.sroa.0401.0.copyload
  %.acceptedSubmissionLifetimes16 = getelementptr inbounds nuw i8, ptr %3, i32 5
  %.sroa.0395.0.copyload = load i8, ptr %.acceptedSubmissionLifetimes16, align 1
  %24 = and i8 %23, %.sroa.0395.0.copyload
  %25 = icmp eq i8 %24, 0
  br i1 %25, label %183, label %26

26:                                               ; preds = %22
  %.handoffs = getelementptr inbounds nuw i8, ptr %3, i32 6
  %27 = load i8, ptr %.handoffs, align 2
  %28 = tail call swiftcc i16 @"$e27GiftUICapabilityLayoutProbe31RasterPresentationCompatibilityO33firstCompatibleLifetimeAndHandoff33_E17D99E015B31087C87CFA5F821C9FD5LL9lifetimes8handoffsAA010SubmissionJ0O_AA0xL0OtSgAA0xJ3SetV_AA0xlY0VtFZ"(i8 %24, i8 %27)
  %29 = and i16 %28, 768
  %30 = icmp eq i16 %29, 512
  br i1 %30, label %183, label %31

31:                                               ; preds = %26
  %32 = lshr i16 %28, 8
  %.sroa.0123.3.insert.ext = zext nneg i16 %32 to i32
  %33 = and i8 %20, 1
  %.not447 = icmp eq i8 %33, 0
  br i1 %.not447, label %79, label %34

34:                                               ; preds = %31
  %35 = lshr i32 %9, 16
  %.extent80 = getelementptr inbounds nuw i8, ptr %1, i32 2
  %.sroa.0393.0.copyload = load i16, ptr %.extent80, align 2
  %.rowByteAlignment81 = getelementptr inbounds nuw i8, ptr %2, i32 14
  %.sroa.0391.0.copyload = load i16, ptr %.rowByteAlignment81, align 2
  %36 = zext i16 %.sroa.0391.0.copyload to i32
  %.rowByteAlignment83 = getelementptr inbounds nuw i8, ptr %3, i32 12
  %.sroa.0390.0.copyload = load i16, ptr %.rowByteAlignment83, align 4
  %37 = zext i16 %.sroa.0390.0.copyload to i32
  %.not448 = icmp eq i16 %.sroa.0390.0.copyload, 0
  br i1 %.not448, label %.loopexit468, label %.preheader467

.preheader467:                                    ; preds = %34, %.preheader467
  %38 = phi i32 [ %39, %.preheader467 ], [ %36, %34 ]
  %39 = phi i32 [ %40, %.preheader467 ], [ %37, %34 ]
  %40 = urem i32 %38, %39
  %.not449 = icmp eq i32 %40, 0
  br i1 %.not449, label %.loopexit468, label %.preheader467

.loopexit468:                                     ; preds = %.preheader467, %34
  %41 = phi i32 [ %36, %34 ], [ %39, %.preheader467 ]
  %42 = icmp eq i32 %41, 0
  br i1 %42, label %198, label %43, !prof !6

43:                                               ; preds = %.loopexit468
  %44 = udiv i32 %36, %41
  %45 = mul nuw i32 %44, %37
  %46 = zext i16 %.sroa.0393.0.copyload to i32
  %47 = shl nuw nsw i32 %46, 1
  %48 = icmp eq i32 %45, 0
  br i1 %48, label %199, label %49, !prof !6

49:                                               ; preds = %43
  %50 = urem i32 %47, %45
  %51 = icmp eq i32 %50, 0
  br i1 %51, label %60, label %52

52:                                               ; preds = %49
  %53 = tail call { i32, i1 } @llvm.usub.with.overflow.i32(i32 %45, i32 %50)
  %54 = extractvalue { i32, i1 } %53, 1
  br i1 %54, label %200, label %55, !prof !6

55:                                               ; preds = %52
  %56 = extractvalue { i32, i1 } %53, 0
  %57 = tail call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 %47, i32 %56)
  %58 = extractvalue { i32, i1 } %57, 0
  %59 = extractvalue { i32, i1 } %57, 1
  br i1 %59, label %79, label %60

60:                                               ; preds = %55, %49
  %61 = phi i32 [ %47, %49 ], [ %58, %55 ]
  %62 = tail call { i32, i1 } @llvm.umul.with.overflow.i32(i32 %61, i32 %35)
  %63 = extractvalue { i32, i1 } %62, 0
  %64 = extractvalue { i32, i1 } %62, 1
  br i1 %64, label %79, label %65

65:                                               ; preds = %60
  %.maximumRasterBytes87 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %66 = load i32, ptr %.maximumRasterBytes87, align 4
  %.maximumRasterBytes88 = getelementptr inbounds nuw i8, ptr %2, i32 16
  %67 = load i32, ptr %.maximumRasterBytes88, align 4
  %. = tail call i32 @llvm.umin.i32(i32 %4, i32 %67)
  %68 = tail call i32 @llvm.umin.i32(i32 %., i32 %66)
  %.not450 = icmp ult i32 %68, %63
  br i1 %.not450, label %79, label %69

69:                                               ; preds = %65
  %.maximumPayloadBytes89 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %70 = load i32, ptr %.maximumPayloadBytes89, align 4
  %.maximumPayloadBytes90 = getelementptr inbounds nuw i8, ptr %2, i32 20
  %71 = load i32, ptr %.maximumPayloadBytes90, align 4
  %.99 = tail call i32 @llvm.umin.i32(i32 %5, i32 %71)
  %72 = tail call i32 @llvm.umin.i32(i32 %.99, i32 %70)
  %.not451 = icmp ult i32 %72, %63
  br i1 %.not451, label %79, label %73

73:                                               ; preds = %69
  %.maximumInFlightBytes91 = getelementptr inbounds nuw i8, ptr %1, i32 20
  %74 = load i32, ptr %.maximumInFlightBytes91, align 4
  %.maximumInFlightBytes92 = getelementptr inbounds nuw i8, ptr %3, i32 16
  %75 = load i32, ptr %.maximumInFlightBytes92, align 4
  %.100 = tail call i32 @llvm.umin.i32(i32 %6, i32 %75)
  %76 = tail call i32 @llvm.umin.i32(i32 %.100, i32 %74)
  %.not452 = icmp ult i32 %76, %63
  br i1 %.not452, label %79, label %77

77:                                               ; preds = %73
  %78 = load i8, ptr %2, align 4
  %.sroa.0108.0.insert.ext = zext i8 %78 to i32
  %.mask = and i16 %28, 255
  %.sroa.0108.2.insert.ext = zext nneg i16 %.mask to i32
  %.sroa.0108.2.insert.shift = shl nuw nsw i32 %.sroa.0108.2.insert.ext, 16
  %.sroa.0108.2.insert.insert = or disjoint i32 %.sroa.0108.2.insert.shift, %.sroa.0108.0.insert.ext
  %.sroa.0108.3.insert.shift = shl nuw nsw i32 %.sroa.0123.3.insert.ext, 24
  %.sroa.0108.3.insert.insert = or disjoint i32 %.sroa.0108.2.insert.insert, %.sroa.0108.3.insert.shift
  br label %79

79:                                               ; preds = %31, %55, %73, %69, %65, %60, %77
  %80 = phi i32 [ -3856, %77 ], [ -1610612735, %60 ], [ -2147483647, %65 ], [ -2147483646, %69 ], [ -2147483645, %73 ], [ -1610612735, %55 ], [ -3856, %31 ]
  %81 = phi i32 [ 0, %77 ], [ 0, %60 ], [ %63, %65 ], [ %63, %69 ], [ %63, %73 ], [ 0, %55 ], [ 0, %31 ]
  %82 = phi i32 [ 0, %77 ], [ 0, %60 ], [ %68, %65 ], [ %72, %69 ], [ %76, %73 ], [ 0, %55 ], [ 0, %31 ]
  %83 = phi i32 [ %.sroa.0108.3.insert.insert, %77 ], [ 2, %60 ], [ 2, %65 ], [ 2, %69 ], [ 2, %73 ], [ 2, %55 ], [ 2, %31 ]
  %84 = phi i32 [ %45, %77 ], [ 0, %60 ], [ 0, %65 ], [ 0, %69 ], [ 0, %73 ], [ 0, %55 ], [ 0, %31 ]
  %85 = phi i32 [ %9, %77 ], [ 0, %60 ], [ 0, %65 ], [ 0, %69 ], [ 0, %73 ], [ 0, %55 ], [ 0, %31 ]
  %86 = phi i32 [ %61, %77 ], [ 0, %60 ], [ 0, %65 ], [ 0, %69 ], [ 0, %73 ], [ 0, %55 ], [ 0, %31 ]
  %87 = phi i32 [ %63, %77 ], [ 0, %60 ], [ 0, %65 ], [ 0, %69 ], [ 0, %73 ], [ 0, %55 ], [ 0, %31 ]
  %88 = and i8 %20, 2
  %.not454 = icmp eq i8 %88, 0
  br i1 %.not454, label %143, label %89

89:                                               ; preds = %79
  %90 = lshr i32 %9, 16
  %.extent = getelementptr inbounds nuw i8, ptr %1, i32 2
  %.sroa.0388.0.copyload = load i16, ptr %.extent, align 2
  %.rowByteAlignment = getelementptr inbounds nuw i8, ptr %2, i32 14
  %.sroa.0386.0.copyload = load i16, ptr %.rowByteAlignment, align 2
  %91 = zext i16 %.sroa.0386.0.copyload to i32
  %.rowByteAlignment68 = getelementptr inbounds nuw i8, ptr %3, i32 12
  %.sroa.0385.0.copyload = load i16, ptr %.rowByteAlignment68, align 4
  %92 = zext i16 %.sroa.0385.0.copyload to i32
  %.not455 = icmp eq i16 %.sroa.0385.0.copyload, 0
  br i1 %.not455, label %.loopexit, label %.preheader

.preheader:                                       ; preds = %89, %.preheader
  %93 = phi i32 [ %94, %.preheader ], [ %91, %89 ]
  %94 = phi i32 [ %95, %.preheader ], [ %92, %89 ]
  %95 = urem i32 %93, %94
  %.not456 = icmp eq i32 %95, 0
  br i1 %.not456, label %.loopexit, label %.preheader

.loopexit:                                        ; preds = %.preheader, %89
  %96 = phi i32 [ %91, %89 ], [ %94, %.preheader ]
  %97 = icmp eq i32 %96, 0
  br i1 %97, label %195, label %98, !prof !6

98:                                               ; preds = %.loopexit
  %99 = udiv i32 %91, %96
  %100 = mul nuw i32 %99, %92
  %101 = zext i16 %.sroa.0388.0.copyload to i32
  %102 = shl nuw nsw i32 %101, 2
  %103 = icmp eq i32 %100, 0
  br i1 %103, label %196, label %104, !prof !6

104:                                              ; preds = %98
  %105 = urem i32 %102, %100
  %106 = icmp eq i32 %105, 0
  br i1 %106, label %115, label %107

107:                                              ; preds = %104
  %108 = tail call { i32, i1 } @llvm.usub.with.overflow.i32(i32 %100, i32 %105)
  %109 = extractvalue { i32, i1 } %108, 1
  br i1 %109, label %197, label %110, !prof !6

110:                                              ; preds = %107
  %111 = extractvalue { i32, i1 } %108, 0
  %112 = tail call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 %102, i32 %111)
  %113 = extractvalue { i32, i1 } %112, 0
  %114 = extractvalue { i32, i1 } %112, 1
  br i1 %114, label %135, label %115

115:                                              ; preds = %110, %104
  %116 = phi i32 [ %102, %104 ], [ %113, %110 ]
  %117 = tail call { i32, i1 } @llvm.umul.with.overflow.i32(i32 %116, i32 %90)
  %118 = extractvalue { i32, i1 } %117, 0
  %119 = extractvalue { i32, i1 } %117, 1
  br i1 %119, label %135, label %120

120:                                              ; preds = %115
  %.maximumRasterBytes = getelementptr inbounds nuw i8, ptr %1, i32 12
  %121 = load i32, ptr %.maximumRasterBytes, align 4
  %.maximumRasterBytes71 = getelementptr inbounds nuw i8, ptr %2, i32 16
  %122 = load i32, ptr %.maximumRasterBytes71, align 4
  %.101 = tail call i32 @llvm.umin.i32(i32 %4, i32 %122)
  %123 = tail call i32 @llvm.umin.i32(i32 %.101, i32 %121)
  %.not457 = icmp ult i32 %123, %118
  br i1 %.not457, label %135, label %124

124:                                              ; preds = %120
  %.maximumPayloadBytes = getelementptr inbounds nuw i8, ptr %1, i32 16
  %125 = load i32, ptr %.maximumPayloadBytes, align 4
  %.maximumPayloadBytes72 = getelementptr inbounds nuw i8, ptr %2, i32 20
  %126 = load i32, ptr %.maximumPayloadBytes72, align 4
  %.102 = tail call i32 @llvm.umin.i32(i32 %5, i32 %126)
  %127 = tail call i32 @llvm.umin.i32(i32 %.102, i32 %125)
  %.not458 = icmp ult i32 %127, %118
  br i1 %.not458, label %135, label %128

128:                                              ; preds = %124
  %.maximumInFlightBytes = getelementptr inbounds nuw i8, ptr %1, i32 20
  %129 = load i32, ptr %.maximumInFlightBytes, align 4
  %.maximumInFlightBytes73 = getelementptr inbounds nuw i8, ptr %3, i32 16
  %130 = load i32, ptr %.maximumInFlightBytes73, align 4
  %.103 = tail call i32 @llvm.umin.i32(i32 %6, i32 %130)
  %131 = tail call i32 @llvm.umin.i32(i32 %.103, i32 %129)
  %.not459 = icmp ult i32 %131, %118
  br i1 %.not459, label %135, label %132

132:                                              ; preds = %128
  %133 = load i8, ptr %2, align 4
  %.sroa.0123.0.insert.ext = zext i8 %133 to i32
  %134 = and i16 %28, 255
  %.sroa.0123.2.insert.ext = zext nneg i16 %134 to i32
  %.sroa.0123.2.insert.shift = shl nuw nsw i32 %.sroa.0123.2.insert.ext, 16
  %.sroa.0123.1.insert.insert = or disjoint i32 %.sroa.0123.2.insert.shift, %.sroa.0123.0.insert.ext
  %.sroa.0123.3.insert.shift = shl nuw nsw i32 %.sroa.0123.3.insert.ext, 24
  %.sroa.0123.2.insert.insert = or disjoint i32 %.sroa.0123.1.insert.insert, %.sroa.0123.3.insert.shift
  %.sroa.0123.3.insert.insert = or disjoint i32 %.sroa.0123.2.insert.insert, 256
  br label %143

135:                                              ; preds = %110, %128, %124, %120, %115
  %136 = phi i32 [ -1610612735, %115 ], [ -2147483647, %120 ], [ -2147483646, %124 ], [ -2147483645, %128 ], [ -1610612735, %110 ]
  %137 = phi i32 [ 0, %115 ], [ %118, %120 ], [ %118, %124 ], [ %118, %128 ], [ 0, %110 ]
  %138 = phi i32 [ 0, %115 ], [ %123, %120 ], [ %127, %124 ], [ %131, %128 ], [ 0, %110 ]
  %139 = and i32 %80, -3856
  %140 = icmp eq i32 %139, -3856
  br i1 %140, label %143, label %141

141:                                              ; preds = %135
  %142 = tail call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe31RasterPresentationCompatibilityO24arithmeticReasonPrecedes33_E17D99E015B31087C87CFA5F821C9FD5LLySbAA0eF11UnavailableO_AGtFZ"(i32 %136, i32 poison, i32 poison, i32 %80, i32 poison, i32 poison)
  %.104 = select i1 %142, i32 %136, i32 %80
  %.105 = select i1 %142, i32 %137, i32 %81
  %.106 = select i1 %142, i32 %138, i32 %82
  br label %143

143:                                              ; preds = %79, %135, %141, %132
  %144 = phi i32 [ %80, %132 ], [ %.104, %141 ], [ %136, %135 ], [ %80, %79 ]
  %145 = phi i32 [ %81, %132 ], [ %.105, %141 ], [ %137, %135 ], [ %81, %79 ]
  %146 = phi i32 [ %82, %132 ], [ %.106, %141 ], [ %138, %135 ], [ %82, %79 ]
  %147 = phi i32 [ %.sroa.0123.3.insert.insert, %132 ], [ 2, %141 ], [ 2, %135 ], [ 2, %79 ]
  %148 = phi i32 [ %100, %132 ], [ 0, %141 ], [ 0, %135 ], [ 0, %79 ]
  %149 = phi i32 [ %9, %132 ], [ 0, %141 ], [ 0, %135 ], [ 0, %79 ]
  %150 = phi i32 [ %116, %132 ], [ 0, %141 ], [ 0, %135 ], [ 0, %79 ]
  %151 = phi i32 [ %118, %132 ], [ 0, %141 ], [ 0, %135 ], [ 0, %79 ]
  %152 = and i32 %83, 255
  %153 = icmp eq i32 %152, 2
  %154 = and i32 %147, 255
  %155 = icmp eq i32 %154, 2
  %or.cond = select i1 %153, i1 %155, i1 false
  br i1 %or.cond, label %178, label %156

156:                                              ; preds = %143
  %157 = load i8, ptr %2, align 4
  %158 = sub i8 -2, %157
  %159 = or i8 %158, %temp-coercion.coerced.sroa.8.12.extract.trunc
  %160 = icmp eq i8 %159, -1
  br i1 %160, label %161, label %183

161:                                              ; preds = %156
  switch i8 %temp-coercion.coerced.sroa.8.15.extract.trunc, label %169 [
    i8 1, label %162
    i8 2, label %166
  ]

162:                                              ; preds = %161
  %163 = and i8 %temp-coercion.coerced.sroa.8.13.extract.trunc, 1
  %.not460 = icmp eq i8 %163, 0
  %brmerge = or i1 %.not460, %153
  br i1 %brmerge, label %169, label %164

164:                                              ; preds = %162
  %165 = and i32 %83, -519893233
  br label %183

166:                                              ; preds = %161
  %.old = and i8 %temp-coercion.coerced.sroa.8.13.extract.trunc, 2
  %.old107.not = icmp eq i8 %.old, 0
  %brmerge466 = select i1 %.old107.not, i1 true, i1 %155
  br i1 %brmerge466, label %169, label %167

167:                                              ; preds = %166
  %168 = and i32 %147, -519893233
  br label %183

169:                                              ; preds = %166, %162, %161
  %170 = and i8 %temp-coercion.coerced.sroa.8.13.extract.trunc, 1
  %.not461 = icmp eq i8 %170, 0
  %brmerge463 = or i1 %.not461, %153
  br i1 %brmerge463, label %173, label %171

171:                                              ; preds = %169
  %172 = and i32 %83, -519893233
  br label %183

173:                                              ; preds = %169
  %174 = and i8 %temp-coercion.coerced.sroa.8.13.extract.trunc, 2
  %.not462 = icmp eq i8 %174, 0
  br i1 %.not462, label %183, label %175

175:                                              ; preds = %173
  br i1 %155, label %183, label %176

176:                                              ; preds = %175
  %177 = and i32 %147, -519893233
  br label %183

178:                                              ; preds = %143
  %179 = and i32 %144, -3856
  %180 = icmp eq i32 %179, -3856
  br i1 %180, label %183, label %181

181:                                              ; preds = %178
  %182 = or i32 %144, 268435456
  br label %183

183:                                              ; preds = %13, %16, %18, %22, %26, %178, %156, %175, %173, %11, %181, %164, %167, %171, %176
  %184 = phi i32 [ %177, %176 ], [ %172, %171 ], [ %168, %167 ], [ %165, %164 ], [ %182, %181 ], [ %12, %11 ], [ -805306361, %173 ], [ -805306361, %175 ], [ -805306361, %156 ], [ -805306361, %178 ], [ -805306362, %26 ], [ -805306363, %22 ], [ -805306364, %18 ], [ -805306367, %16 ], [ -805306368, %13 ]
  %185 = phi i32 [ %148, %176 ], [ %84, %171 ], [ %148, %167 ], [ %84, %164 ], [ %145, %181 ], [ 0, %11 ], [ 0, %173 ], [ 0, %175 ], [ 0, %156 ], [ 0, %178 ], [ 0, %26 ], [ 0, %22 ], [ 0, %18 ], [ 0, %16 ], [ 0, %13 ]
  %186 = phi i32 [ %149, %176 ], [ %85, %171 ], [ %149, %167 ], [ %85, %164 ], [ %146, %181 ], [ 0, %11 ], [ 0, %173 ], [ 0, %175 ], [ 0, %156 ], [ 0, %178 ], [ 0, %26 ], [ 0, %22 ], [ 0, %18 ], [ 0, %16 ], [ 0, %13 ]
  %187 = phi i32 [ %150, %176 ], [ %86, %171 ], [ %150, %167 ], [ %86, %164 ], [ 0, %181 ], [ 0, %11 ], [ 0, %173 ], [ 0, %175 ], [ 0, %156 ], [ 0, %178 ], [ 0, %26 ], [ 0, %22 ], [ 0, %18 ], [ 0, %16 ], [ 0, %13 ]
  %188 = phi i32 [ %151, %176 ], [ %87, %171 ], [ %151, %167 ], [ %87, %164 ], [ 0, %181 ], [ 0, %11 ], [ 0, %173 ], [ 0, %175 ], [ 0, %156 ], [ 0, %178 ], [ 0, %26 ], [ 0, %22 ], [ 0, %18 ], [ 0, %16 ], [ 0, %13 ]
  store i32 %184, ptr %0, align 4
  %189 = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %185, ptr %189, align 4
  %190 = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %186, ptr %190, align 4
  %191 = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i32 %187, ptr %191, align 4
  %192 = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i32 %188, ptr %192, align 4
  %193 = getelementptr inbounds nuw i8, ptr %0, i32 20
  store i32 %188, ptr %193, align 4
  %194 = getelementptr inbounds nuw i8, ptr %0, i32 24
  store i32 %188, ptr %194, align 4
  ret void

195:                                              ; preds = %.loopexit
  tail call void @llvm.trap() #24
  unreachable

196:                                              ; preds = %98
  tail call void @llvm.trap() #24
  unreachable

197:                                              ; preds = %107
  tail call void @llvm.trap() #24
  unreachable

198:                                              ; preds = %.loopexit468
  tail call void @llvm.trap() #24
  unreachable

199:                                              ; preds = %43
  tail call void @llvm.trap() #24
  unreachable

200:                                              ; preds = %52
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc range(i16 0, 513) i16 @"$e27GiftUICapabilityLayoutProbe31RasterPresentationCompatibilityO33firstCompatibleLifetimeAndHandoff33_E17D99E015B31087C87CFA5F821C9FD5LL9lifetimes8handoffsAA010SubmissionJ0O_AA0xL0OtSgAA0xJ3SetV_AA0xlY0VtFZ"(i8 %0, i8 %1) local_unnamed_addr #0 {
entry:
  %2 = and i8 %0, 1
  %3 = icmp ne i8 %2, 0
  %4 = and i8 %1, 1
  %5 = icmp ne i8 %4, 0
  %or.cond = select i1 %3, i1 %5, i1 false
  br i1 %or.cond, label %15, label %6

6:                                                ; preds = %entry
  %7 = and i8 %0, 2
  %.not = icmp eq i8 %7, 0
  br i1 %.not, label %11, label %8

8:                                                ; preds = %6
  br i1 %5, label %15, label %9

9:                                                ; preds = %8
  %10 = and i8 %1, 2
  %.not2 = icmp eq i8 %10, 0
  br i1 %.not2, label %.thread6.thread, label %15

11:                                               ; preds = %6
  %12 = and i8 %0, 4
  %.not3 = icmp eq i8 %12, 0
  br i1 %.not3, label %.thread6.thread, label %13

13:                                               ; preds = %11
  br i1 %5, label %15, label %.thread6

.thread6:                                         ; preds = %13
  %.pre = and i8 %1, 2
  %14 = icmp eq i8 %.pre, 0
  br i1 %14, label %.thread6.thread, label %15

.thread6.thread:                                  ; preds = %9, %11, %.thread6
  br label %15

15:                                               ; preds = %entry, %.thread6, %13, %9, %8, %.thread6.thread
  %16 = phi i16 [ 512, %.thread6.thread ], [ 1, %8 ], [ 257, %9 ], [ 2, %13 ], [ 258, %.thread6 ], [ 0, %entry ]
  ret i16 %16
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe31RasterPresentationCompatibilityO24arithmeticReasonPrecedes33_E17D99E015B31087C87CFA5F821C9FD5LLySbAA0eF11UnavailableO_AGtFZ"(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5) local_unnamed_addr #0 {
entry:
  %6 = lshr i32 %0, 29
  %7 = trunc nuw nsw i32 %6 to i8
  switch i8 %7, label %11 [
    i8 4, label %8
    i8 5, label %12
  ]

8:                                                ; preds = %entry
  %9 = trunc i32 %0 to i8
  %10 = add i8 %9, 1
  br label %12

11:                                               ; preds = %entry
  br label %12

12:                                               ; preds = %entry, %8, %11
  %13 = phi i8 [ -1, %11 ], [ %10, %8 ], [ 1, %entry ]
  %14 = lshr i32 %3, 29
  %15 = trunc nuw nsw i32 %14 to i8
  switch i8 %15, label %19 [
    i8 4, label %16
    i8 5, label %20
  ]

16:                                               ; preds = %12
  %17 = trunc i32 %3 to i8
  %18 = add i8 %17, 1
  br label %20

19:                                               ; preds = %12
  br label %20

20:                                               ; preds = %12, %16, %19
  %21 = phi i8 [ -1, %19 ], [ %18, %16 ], [ 1, %12 ]
  %22 = icmp ult i8 %13, %21
  ret i1 %22
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe31RasterPresentationCompatibilityO7prefers_4over6policySbAA0eF13CandidatePathV_AhA0eF6PolicyVtFZ"(ptr noalias readonly captures(none) dereferenceable(28) %0, ptr noalias readonly captures(none) dereferenceable(28) %1, i32 %2, i32 %3, i32 %4, i32 %5) local_unnamed_addr #2 {
entry:
  %temp-coercion.coerced.sroa.5.14.extract.shift = lshr i32 %5, 16
  %6 = load i8, ptr %0, align 4
  %7 = trunc i32 %temp-coercion.coerced.sroa.5.14.extract.shift to i8
  %8 = icmp eq i8 %6, %7
  %9 = load i8, ptr %1, align 4
  %10 = icmp eq i8 %9, %7
  %11 = xor i1 %8, %10
  %12 = add i8 %6, 1
  %13 = add i8 %9, 1
  %14 = icmp ult i8 %12, %13
  %15 = select i1 %11, i1 %8, i1 %14
  ret i1 %15
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceV17candidateCapacitys5UInt8Vvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceV17candidateCapacitys5UInt8VvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceV17candidateCapacitys5UInt8VvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceV23usableCandidateCapacitys5UInt8Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(52) %0) local_unnamed_addr #2 {
entry:
  %1 = load i8, ptr %0, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceV14firstCandidateAA010NormalizedefJ0VSgvpfi"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe37NormalizedRasterPresentationCandidateVSg) captures(none) initializes((0, 24)) %0) local_unnamed_addr #3 {
entry:
  store i32 2, ptr %0, align 4
  %1 = getelementptr inbounds nuw i8, ptr %0, i32 4
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(20) %1, i8 0, i64 20, i1 false)
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceV23usableCandidateCapacityACSgs5UInt8V_tcfC"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceVSg) captures(none) initializes((0, 52)) %0, i8 %1) local_unnamed_addr #3 {
entry:
  %2 = icmp ult i8 %1, 3
  %.sroa.610.0 = select i1 %2, i32 2, i32 3
  %.sroa.1816.0 = select i1 %2, i32 2, i32 0
  %narrow = select i1 %2, i8 %1, i8 0
  %.sroa.0.sroa.021.0 = zext i8 %narrow to i32
  store i32 %.sroa.0.sroa.021.0, ptr %0, align 4
  %.sroa.610.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %.sroa.610.0, ptr %.sroa.610.0..sroa_idx, align 4
  %.sroa.811.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.1816.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 28
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(20) %.sroa.811.0..sroa_idx, i8 0, i64 20, i1 false)
  store i32 %.sroa.1816.0, ptr %.sroa.1816.0..sroa_idx, align 4
  %.sroa.2017.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 32
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(20) %.sroa.2017.0..sroa_idx, i8 0, i64 20, i1 false)
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc noundef i1 @"$e27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceV6appendySbAA010NormalizedeF9CandidateVF"(ptr noalias readonly captures(none) dereferenceable(24) %0, ptr swiftself captures(none) dereferenceable(52) %1) local_unnamed_addr #9 {
entry:
  %.sroa.0166.sroa.0.0.copyload = load i32, ptr %0, align 4
  %.sroa.0166.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.0166.sroa.4.0.copyload = load i32, ptr %.sroa.0166.sroa.4.0..sroa_idx, align 4
  %.sroa.0166.sroa.5.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.0166.sroa.5.0.copyload = load i32, ptr %.sroa.0166.sroa.5.0..sroa_idx, align 4
  %.sroa.0166.sroa.6.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.0166.sroa.6.0.copyload = load i32, ptr %.sroa.0166.sroa.6.0..sroa_idx, align 4
  %.sroa.0166.sroa.7.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.0166.sroa.7.0.copyload = load i32, ptr %.sroa.0166.sroa.7.0..sroa_idx, align 4
  %.sroa.0166.sroa.8.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 20
  %.sroa.0166.sroa.8.0.copyload = load i32, ptr %.sroa.0166.sroa.8.0..sroa_idx, align 4
  %.firstCandidate = getelementptr inbounds nuw i8, ptr %1, i32 4
  %2 = load i32, ptr %.firstCandidate, align 4
  %3 = getelementptr inbounds nuw i8, ptr %1, i32 8
  %4 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %5 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %6 = getelementptr inbounds nuw i8, ptr %1, i32 20
  %7 = getelementptr inbounds nuw i8, ptr %1, i32 24
  %8 = and i32 %2, 255
  %9 = icmp eq i32 %8, 2
  br i1 %9, label %10, label %13

10:                                               ; preds = %entry
  %11 = load i8, ptr %1, align 4
  %.not = icmp eq i8 %11, 0
  br i1 %.not, label %13, label %12

12:                                               ; preds = %10
  store i32 %.sroa.0166.sroa.0.0.copyload, ptr %.firstCandidate, align 4
  store i32 %.sroa.0166.sroa.4.0.copyload, ptr %3, align 4
  store i32 %.sroa.0166.sroa.5.0.copyload, ptr %4, align 4
  store i32 %.sroa.0166.sroa.6.0.copyload, ptr %5, align 4
  store i32 %.sroa.0166.sroa.7.0.copyload, ptr %6, align 4
  store i32 %.sroa.0166.sroa.8.0.copyload, ptr %7, align 4
  br label %26

13:                                               ; preds = %entry, %10
  %.secondCandidate = getelementptr inbounds nuw i8, ptr %1, i32 28
  %14 = load i32, ptr %.secondCandidate, align 4
  %15 = getelementptr inbounds nuw i8, ptr %1, i32 32
  %16 = getelementptr inbounds nuw i8, ptr %1, i32 36
  %17 = getelementptr inbounds nuw i8, ptr %1, i32 40
  %18 = getelementptr inbounds nuw i8, ptr %1, i32 44
  %19 = getelementptr inbounds nuw i8, ptr %1, i32 48
  %20 = and i32 %14, 255
  %21 = icmp eq i32 %20, 2
  br i1 %21, label %22, label %26

22:                                               ; preds = %13
  %23 = load i8, ptr %1, align 4
  %24 = icmp ugt i8 %23, 1
  br i1 %24, label %25, label %26

25:                                               ; preds = %22
  store i32 %.sroa.0166.sroa.0.0.copyload, ptr %.secondCandidate, align 4
  store i32 %.sroa.0166.sroa.4.0.copyload, ptr %15, align 4
  store i32 %.sroa.0166.sroa.5.0.copyload, ptr %16, align 4
  store i32 %.sroa.0166.sroa.6.0.copyload, ptr %17, align 4
  store i32 %.sroa.0166.sroa.7.0.copyload, ptr %18, align 4
  store i32 %.sroa.0166.sroa.8.0.copyload, ptr %19, align 4
  br label %26

26:                                               ; preds = %13, %22, %12, %25
  %27 = phi i1 [ true, %25 ], [ true, %12 ], [ false, %22 ], [ false, %13 ]
  ret i1 %27
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc noundef i1 @"$e27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(52) %0, ptr noalias readonly captures(none) dereferenceable(52) %1) local_unnamed_addr #2 {
entry:
  %2 = alloca %T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV, align 4
  %3 = alloca %T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV, align 4
  %4 = alloca %T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV, align 4
  %5 = alloca %T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV, align 4
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %2)
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %3)
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %4)
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %5)
  %.sroa.0184.0.copyload = load i8, ptr %0, align 4
  %.sroa.0183.0.copyload = load i8, ptr %1, align 4
  %6 = icmp eq i8 %.sroa.0184.0.copyload, %.sroa.0183.0.copyload
  br i1 %6, label %7, label %26

7:                                                ; preds = %entry
  %.firstCandidate = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.0177.0.copyload = load i32, ptr %.firstCandidate, align 4
  %.sroa.4178.0..firstCandidate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.4178.0.copyload = load i32, ptr %.sroa.4178.0..firstCandidate.sroa_idx, align 4
  %.sroa.5179.0..firstCandidate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.5179.0.copyload = load i32, ptr %.sroa.5179.0..firstCandidate.sroa_idx, align 4
  %.sroa.6180.0..firstCandidate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.6180.0.copyload = load i32, ptr %.sroa.6180.0..firstCandidate.sroa_idx, align 4
  %.sroa.7181.0..firstCandidate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 20
  %.sroa.7181.0.copyload = load i32, ptr %.sroa.7181.0..firstCandidate.sroa_idx, align 4
  %.sroa.8182.0..firstCandidate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 24
  %.sroa.8182.0.copyload = load i32, ptr %.sroa.8182.0..firstCandidate.sroa_idx, align 4
  %.firstCandidate3 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.0171.0.copyload = load i32, ptr %.firstCandidate3, align 4
  %.sroa.4172.0..firstCandidate3.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.4172.0.copyload = load i32, ptr %.sroa.4172.0..firstCandidate3.sroa_idx, align 4
  %.sroa.5173.0..firstCandidate3.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.5173.0.copyload = load i32, ptr %.sroa.5173.0..firstCandidate3.sroa_idx, align 4
  %.sroa.6174.0..firstCandidate3.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.sroa.6174.0.copyload = load i32, ptr %.sroa.6174.0..firstCandidate3.sroa_idx, align 4
  %.sroa.7175.0..firstCandidate3.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 20
  %.sroa.7175.0.copyload = load i32, ptr %.sroa.7175.0..firstCandidate3.sroa_idx, align 4
  %.sroa.8176.0..firstCandidate3.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 24
  %.sroa.8176.0.copyload = load i32, ptr %.sroa.8176.0..firstCandidate3.sroa_idx, align 4
  %8 = and i32 %.sroa.0177.0.copyload, 255
  %9 = icmp eq i32 %8, 2
  %10 = and i32 %.sroa.0171.0.copyload, 255
  %11 = icmp eq i32 %10, 2
  br i1 %9, label %15, label %12

12:                                               ; preds = %7
  br i1 %11, label %26, label %13

13:                                               ; preds = %12
  store i32 %.sroa.0177.0.copyload, ptr %3, align 4
  %.sroa.525.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 4
  store i32 %.sroa.4178.0.copyload, ptr %.sroa.525.0..sroa_idx, align 4
  %.sroa.626.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 8
  store i32 %.sroa.5179.0.copyload, ptr %.sroa.626.0..sroa_idx, align 4
  %.sroa.727.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 12
  store i32 %.sroa.6180.0.copyload, ptr %.sroa.727.0..sroa_idx, align 4
  %.sroa.828.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 16
  store i32 %.sroa.7181.0.copyload, ptr %.sroa.828.0..sroa_idx, align 4
  %.sroa.929.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 20
  store i32 %.sroa.8182.0.copyload, ptr %.sroa.929.0..sroa_idx, align 4
  store i32 %.sroa.0171.0.copyload, ptr %2, align 4
  %.sroa.519.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 4
  store i32 %.sroa.4172.0.copyload, ptr %.sroa.519.0..sroa_idx, align 4
  %.sroa.620.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 8
  store i32 %.sroa.5173.0.copyload, ptr %.sroa.620.0..sroa_idx, align 4
  %.sroa.721.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 12
  store i32 %.sroa.6174.0.copyload, ptr %.sroa.721.0..sroa_idx, align 4
  %.sroa.822.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 16
  store i32 %.sroa.7175.0.copyload, ptr %.sroa.822.0..sroa_idx, align 4
  %.sroa.923.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 20
  store i32 %.sroa.8176.0.copyload, ptr %.sroa.923.0..sroa_idx, align 4
  %14 = call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias nonnull captures(none) dereferenceable(24) %3, ptr noalias nonnull captures(none) dereferenceable(24) %2)
  br i1 %14, label %16, label %26

15:                                               ; preds = %7
  br i1 %11, label %16, label %26

16:                                               ; preds = %13, %15
  %.secondCandidate = getelementptr inbounds nuw i8, ptr %0, i32 28
  %.sroa.0165.0.copyload = load i32, ptr %.secondCandidate, align 4
  %.sroa.4166.0..secondCandidate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 32
  %.sroa.4166.0.copyload = load i32, ptr %.sroa.4166.0..secondCandidate.sroa_idx, align 4
  %.sroa.5167.0..secondCandidate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 36
  %.sroa.5167.0.copyload = load i32, ptr %.sroa.5167.0..secondCandidate.sroa_idx, align 4
  %.sroa.6168.0..secondCandidate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 40
  %.sroa.6168.0.copyload = load i32, ptr %.sroa.6168.0..secondCandidate.sroa_idx, align 4
  %.sroa.7169.0..secondCandidate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 44
  %.sroa.7169.0.copyload = load i32, ptr %.sroa.7169.0..secondCandidate.sroa_idx, align 4
  %.sroa.8170.0..secondCandidate.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 48
  %.sroa.8170.0.copyload = load i32, ptr %.sroa.8170.0..secondCandidate.sroa_idx, align 4
  %.secondCandidate5 = getelementptr inbounds nuw i8, ptr %1, i32 28
  %.sroa.0159.0.copyload = load i32, ptr %.secondCandidate5, align 4
  %.sroa.4160.0..secondCandidate5.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 32
  %.sroa.4160.0.copyload = load i32, ptr %.sroa.4160.0..secondCandidate5.sroa_idx, align 4
  %.sroa.5161.0..secondCandidate5.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 36
  %.sroa.5161.0.copyload = load i32, ptr %.sroa.5161.0..secondCandidate5.sroa_idx, align 4
  %.sroa.6162.0..secondCandidate5.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 40
  %.sroa.6162.0.copyload = load i32, ptr %.sroa.6162.0..secondCandidate5.sroa_idx, align 4
  %.sroa.7163.0..secondCandidate5.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 44
  %.sroa.7163.0.copyload = load i32, ptr %.sroa.7163.0..secondCandidate5.sroa_idx, align 4
  %.sroa.8164.0..secondCandidate5.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 48
  %.sroa.8164.0.copyload = load i32, ptr %.sroa.8164.0..secondCandidate5.sroa_idx, align 4
  %17 = and i32 %.sroa.0165.0.copyload, 255
  %18 = icmp eq i32 %17, 2
  %19 = and i32 %.sroa.0159.0.copyload, 255
  %20 = icmp eq i32 %19, 2
  br i1 %18, label %24, label %21

21:                                               ; preds = %16
  br i1 %20, label %25, label %22

22:                                               ; preds = %21
  store i32 %.sroa.0165.0.copyload, ptr %5, align 4
  %.sroa.562.0..sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 4
  store i32 %.sroa.4166.0.copyload, ptr %.sroa.562.0..sroa_idx, align 4
  %.sroa.663.0..sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 8
  store i32 %.sroa.5167.0.copyload, ptr %.sroa.663.0..sroa_idx, align 4
  %.sroa.764.0..sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 12
  store i32 %.sroa.6168.0.copyload, ptr %.sroa.764.0..sroa_idx, align 4
  %.sroa.865.0..sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 16
  store i32 %.sroa.7169.0.copyload, ptr %.sroa.865.0..sroa_idx, align 4
  %.sroa.966.0..sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 20
  store i32 %.sroa.8170.0.copyload, ptr %.sroa.966.0..sroa_idx, align 4
  store i32 %.sroa.0159.0.copyload, ptr %4, align 4
  %.sroa.556.0..sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 4
  store i32 %.sroa.4160.0.copyload, ptr %.sroa.556.0..sroa_idx, align 4
  %.sroa.657.0..sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 8
  store i32 %.sroa.5161.0.copyload, ptr %.sroa.657.0..sroa_idx, align 4
  %.sroa.758.0..sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 12
  store i32 %.sroa.6162.0.copyload, ptr %.sroa.758.0..sroa_idx, align 4
  %.sroa.859.0..sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 16
  store i32 %.sroa.7163.0.copyload, ptr %.sroa.859.0..sroa_idx, align 4
  %.sroa.960.0..sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 20
  store i32 %.sroa.8164.0.copyload, ptr %.sroa.960.0..sroa_idx, align 4
  %23 = call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterRealizationContributionV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias nonnull captures(none) dereferenceable(24) %5, ptr noalias nonnull captures(none) dereferenceable(24) %4)
  br i1 %23, label %26, label %25

24:                                               ; preds = %16
  br i1 %20, label %26, label %25

25:                                               ; preds = %21, %22, %24
  br label %26

26:                                               ; preds = %15, %13, %12, %24, %22, %entry, %25
  %27 = phi i1 [ false, %25 ], [ false, %entry ], [ true, %22 ], [ true, %24 ], [ false, %12 ], [ false, %13 ], [ false, %15 ]
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %5)
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %4)
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %3)
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %2)
  ret i1 %27
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV10operationsAA0F12OperationSetVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) local_unnamed_addr #2 {
entry:
  %1 = load i8, ptr %0, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV6extentAA16CapabilityExtentVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) local_unnamed_addr #2 {
entry:
  %.extent = getelementptr inbounds nuw i8, ptr %0, i32 2
  %1 = load i32, ptr %.extent, align 2
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV12regionExtentAA010CapabilityI0Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) local_unnamed_addr #2 {
entry:
  %.regionExtent = getelementptr inbounds nuw i8, ptr %0, i32 6
  %1 = load i32, ptr %.regionExtent, align 2
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV8rowBytesAA19CapabilityByteCountVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) local_unnamed_addr #2 {
entry:
  %.rowBytes = getelementptr inbounds nuw i8, ptr %0, i32 12
  %1 = load i32, ptr %.rowBytes, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV15operationStreamAA09OperationI8LifetimeOvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) local_unnamed_addr #2 {
entry:
  %.operationStream = getelementptr inbounds nuw i8, ptr %0, i32 16
  %1 = load i8, ptr %.operationStream, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV8encodingAA22CanonicalPixelEncodingOvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) local_unnamed_addr #2 {
entry:
  %.encoding = getelementptr inbounds nuw i8, ptr %0, i32 17
  %1 = load i8, ptr %.encoding, align 1
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV18submissionLifetimeAA010SubmissionI0Ovg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) local_unnamed_addr #2 {
entry:
  %.submissionLifetime = getelementptr inbounds nuw i8, ptr %0, i32 18
  %1 = load i8, ptr %.submissionLifetime, align 2
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV7handoffAA17SubmissionHandoffOvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) local_unnamed_addr #2 {
entry:
  %.handoff = getelementptr inbounds nuw i8, ptr %0, i32 19
  %1 = load i8, ptr %.handoff, align 1
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV11realizationAA0F15RealizationKindOvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) local_unnamed_addr #2 {
entry:
  %.realization = getelementptr inbounds nuw i8, ptr %0, i32 20
  %1 = load i8, ptr %.realization, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV08requiredF5BytesAA19CapabilityByteCountVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) local_unnamed_addr #2 {
entry:
  %.requiredRasterBytes = getelementptr inbounds nuw i8, ptr %0, i32 24
  %1 = load i32, ptr %.requiredRasterBytes, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV20requiredPayloadBytesAA19CapabilityByteCountVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) local_unnamed_addr #2 {
entry:
  %.requiredPayloadBytes = getelementptr inbounds nuw i8, ptr %0, i32 28
  %1 = load i32, ptr %.requiredPayloadBytes, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV13inFlightCounts5UInt8Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) local_unnamed_addr #2 {
entry:
  %.inFlightCount = getelementptr inbounds nuw i8, ptr %0, i32 32
  %1 = load i8, ptr %.inFlightCount, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV21requiredInFlightBytesAA19CapabilityByteCountVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) local_unnamed_addr #2 {
entry:
  %.requiredInFlightBytes = getelementptr inbounds nuw i8, ptr %0, i32 36
  %1 = load i32, ptr %.requiredInFlightBytes, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(40) %0, ptr noalias readonly captures(none) dereferenceable(40) %1) local_unnamed_addr #2 {
entry:
  %.sroa.0153.0.copyload = load i8, ptr %0, align 4
  %.sroa.0150.0.copyload = load i8, ptr %1, align 4
  %2 = icmp eq i8 %.sroa.0153.0.copyload, %.sroa.0150.0.copyload
  br i1 %2, label %3, label %31

3:                                                ; preds = %entry
  %.extent = getelementptr inbounds nuw i8, ptr %0, i32 2
  %.sroa.0146.0.copyload = load i16, ptr %.extent, align 2
  %.extent4 = getelementptr inbounds nuw i8, ptr %1, i32 2
  %.sroa.0141.0.copyload = load i16, ptr %.extent4, align 2
  %4 = icmp eq i16 %.sroa.0146.0.copyload, %.sroa.0141.0.copyload
  br i1 %4, label %5, label %31

5:                                                ; preds = %3
  %.sroa.4143.0..extent4.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.4143.0.copyload = load i16, ptr %.sroa.4143.0..extent4.sroa_idx, align 2
  %.sroa.4148.0..extent.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.4148.0.copyload = load i16, ptr %.sroa.4148.0..extent.sroa_idx, align 2
  %6 = icmp eq i16 %.sroa.4148.0.copyload, %.sroa.4143.0.copyload
  br i1 %6, label %7, label %31

7:                                                ; preds = %5
  %.regionExtent = getelementptr inbounds nuw i8, ptr %0, i32 6
  %.sroa.0136.0.copyload = load i16, ptr %.regionExtent, align 2
  %.regionExtent11 = getelementptr inbounds nuw i8, ptr %1, i32 6
  %.sroa.0132.0.copyload = load i16, ptr %.regionExtent11, align 2
  %8 = icmp eq i16 %.sroa.0136.0.copyload, %.sroa.0132.0.copyload
  br i1 %8, label %9, label %31

9:                                                ; preds = %7
  %.sroa.4.0..regionExtent11.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.4.0.copyload = load i16, ptr %.sroa.4.0..regionExtent11.sroa_idx, align 2
  %.sroa.4138.0..regionExtent.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.4138.0.copyload = load i16, ptr %.sroa.4138.0..regionExtent.sroa_idx, align 2
  %10 = icmp eq i16 %.sroa.4138.0.copyload, %.sroa.4.0.copyload
  br i1 %10, label %11, label %31

11:                                               ; preds = %9
  %.rowBytes = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.0128.0.copyload = load i32, ptr %.rowBytes, align 4
  %.rowBytes20 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.0125.0.copyload = load i32, ptr %.rowBytes20, align 4
  %12 = icmp eq i32 %.sroa.0128.0.copyload, %.sroa.0125.0.copyload
  br i1 %12, label %13, label %31

13:                                               ; preds = %11
  %.operationStream = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.unpack = load i8, ptr %.operationStream, align 4
  %.operationStream25 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.unpack156 = load i8, ptr %.operationStream25, align 4
  %14 = icmp eq i8 %.unpack, %.unpack156
  br i1 %14, label %15, label %31

15:                                               ; preds = %13
  %.encoding = getelementptr inbounds nuw i8, ptr %0, i32 17
  %.unpack157 = load i8, ptr %.encoding, align 1
  %.encoding26 = getelementptr inbounds nuw i8, ptr %1, i32 17
  %.unpack158 = load i8, ptr %.encoding26, align 1
  %16 = icmp eq i8 %.unpack157, %.unpack158
  br i1 %16, label %17, label %31

17:                                               ; preds = %15
  %.submissionLifetime = getelementptr inbounds nuw i8, ptr %0, i32 18
  %.unpack159 = load i8, ptr %.submissionLifetime, align 2
  %.submissionLifetime27 = getelementptr inbounds nuw i8, ptr %1, i32 18
  %.unpack160 = load i8, ptr %.submissionLifetime27, align 2
  %18 = icmp eq i8 %.unpack159, %.unpack160
  br i1 %18, label %19, label %31

19:                                               ; preds = %17
  %.handoff = getelementptr inbounds nuw i8, ptr %0, i32 19
  %.unpack161 = load i8, ptr %.handoff, align 1
  %.handoff28 = getelementptr inbounds nuw i8, ptr %1, i32 19
  %.unpack162 = load i8, ptr %.handoff28, align 1
  %20 = icmp eq i8 %.unpack161, %.unpack162
  br i1 %20, label %21, label %31

21:                                               ; preds = %19
  %.realization = getelementptr inbounds nuw i8, ptr %0, i32 20
  %.unpack163 = load i8, ptr %.realization, align 4
  %.realization29 = getelementptr inbounds nuw i8, ptr %1, i32 20
  %.unpack164 = load i8, ptr %.realization29, align 4
  %22 = icmp eq i8 %.unpack163, %.unpack164
  br i1 %22, label %23, label %31

23:                                               ; preds = %21
  %.requiredRasterBytes = getelementptr inbounds nuw i8, ptr %0, i32 24
  %.sroa.083.0.copyload = load i32, ptr %.requiredRasterBytes, align 4
  %.requiredRasterBytes30 = getelementptr inbounds nuw i8, ptr %1, i32 24
  %.sroa.080.0.copyload = load i32, ptr %.requiredRasterBytes30, align 4
  %24 = icmp eq i32 %.sroa.083.0.copyload, %.sroa.080.0.copyload
  br i1 %24, label %25, label %31

25:                                               ; preds = %23
  %.requiredPayloadBytes = getelementptr inbounds nuw i8, ptr %0, i32 28
  %.sroa.077.0.copyload = load i32, ptr %.requiredPayloadBytes, align 4
  %.requiredPayloadBytes35 = getelementptr inbounds nuw i8, ptr %1, i32 28
  %.sroa.074.0.copyload = load i32, ptr %.requiredPayloadBytes35, align 4
  %26 = icmp eq i32 %.sroa.077.0.copyload, %.sroa.074.0.copyload
  br i1 %26, label %27, label %31

27:                                               ; preds = %25
  %.inFlightCount = getelementptr inbounds nuw i8, ptr %0, i32 32
  %.sroa.073.0.copyload = load i8, ptr %.inFlightCount, align 4
  %.inFlightCount40 = getelementptr inbounds nuw i8, ptr %1, i32 32
  %.sroa.072.0.copyload = load i8, ptr %.inFlightCount40, align 4
  %28 = icmp eq i8 %.sroa.073.0.copyload, %.sroa.072.0.copyload
  br i1 %28, label %29, label %31

29:                                               ; preds = %27
  %.requiredInFlightBytes = getelementptr inbounds nuw i8, ptr %0, i32 36
  %.sroa.069.0.copyload = load i32, ptr %.requiredInFlightBytes, align 4
  %.requiredInFlightBytes43 = getelementptr inbounds nuw i8, ptr %1, i32 36
  %.sroa.066.0.copyload = load i32, ptr %.requiredInFlightBytes43, align 4
  %30 = icmp eq i32 %.sroa.069.0.copyload, %.sroa.066.0.copyload
  br label %31

31:                                               ; preds = %entry, %5, %3, %9, %7, %11, %13, %15, %17, %19, %21, %23, %25, %27, %29
  %32 = phi i1 [ %30, %29 ], [ false, %27 ], [ false, %25 ], [ false, %23 ], [ false, %21 ], [ false, %19 ], [ false, %17 ], [ false, %15 ], [ false, %13 ], [ false, %11 ], [ false, %7 ], [ false, %9 ], [ false, %3 ], [ false, %5 ], [ false, %entry ]
  ret i1 %32
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read, inaccessiblemem: write)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe28RasterPresentationResolutionO21__derived_enum_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(40) %0, ptr noalias readonly captures(none) dereferenceable(40) %1) local_unnamed_addr #13 {
entry:
  %2 = alloca %T27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV, align 4
  %3 = alloca %T27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV, align 4
  call void @llvm.lifetime.start.p0(i64 40, ptr nonnull %2)
  call void @llvm.lifetime.start.p0(i64 40, ptr nonnull %3)
  %.sroa.077.0.copyload = load i32, ptr %0, align 4
  %.sroa.981.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.981.0.copyload = load i32, ptr %.sroa.981.0..sroa_idx, align 4
  %.sroa.1486.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.1486.0.copyload = load i32, ptr %.sroa.1486.0..sroa_idx, align 4
  %.sroa.39111.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 32
  %.sroa.39111.0.copyload = load i32, ptr %.sroa.39111.0..sroa_idx, align 4
  %.not.not = icmp sgt i32 %.sroa.39111.0.copyload, -1
  br i1 %.not.not, label %4, label %7

4:                                                ; preds = %entry
  %.sroa.44116.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 36
  %.sroa.44116.0.copyload = load i32, ptr %.sroa.44116.0..sroa_idx, align 4
  %.sroa.35107.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 28
  %.sroa.35107.0.copyload = load i32, ptr %.sroa.35107.0..sroa_idx, align 4
  %.sroa.31103.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 24
  %.sroa.31103.0.copyload = load i32, ptr %.sroa.31103.0..sroa_idx, align 4
  %.sroa.2799.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 20
  %.sroa.2799.0.copyload = load i32, ptr %.sroa.2799.0..sroa_idx, align 4
  %.sroa.2395.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.2395.0.copyload = load i32, ptr %.sroa.2395.0..sroa_idx, align 4
  %.sroa.1991.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.1991.0.copyload = load i32, ptr %.sroa.1991.0..sroa_idx, align 4
  store i32 %.sroa.077.0.copyload, ptr %2, align 4
  %.sroa.981.0..sroa_idx82 = getelementptr inbounds nuw i8, ptr %2, i32 4
  store i32 %.sroa.981.0.copyload, ptr %.sroa.981.0..sroa_idx82, align 4
  %.sroa.1486.0..sroa_idx87 = getelementptr inbounds nuw i8, ptr %2, i32 8
  store i32 %.sroa.1486.0.copyload, ptr %.sroa.1486.0..sroa_idx87, align 4
  %.sroa.1991.0..sroa_idx92 = getelementptr inbounds nuw i8, ptr %2, i32 12
  store i32 %.sroa.1991.0.copyload, ptr %.sroa.1991.0..sroa_idx92, align 4
  %.sroa.2395.0..sroa_idx96 = getelementptr inbounds nuw i8, ptr %2, i32 16
  store i32 %.sroa.2395.0.copyload, ptr %.sroa.2395.0..sroa_idx96, align 4
  %.sroa.2799.0..sroa_idx100 = getelementptr inbounds nuw i8, ptr %2, i32 20
  store i32 %.sroa.2799.0.copyload, ptr %.sroa.2799.0..sroa_idx100, align 4
  %.sroa.31103.0..sroa_idx104 = getelementptr inbounds nuw i8, ptr %2, i32 24
  store i32 %.sroa.31103.0.copyload, ptr %.sroa.31103.0..sroa_idx104, align 4
  %.sroa.35107.0..sroa_idx108 = getelementptr inbounds nuw i8, ptr %2, i32 28
  store i32 %.sroa.35107.0.copyload, ptr %.sroa.35107.0..sroa_idx108, align 4
  %.sroa.39111.0..sroa_idx112 = getelementptr inbounds nuw i8, ptr %2, i32 32
  store i32 %.sroa.39111.0.copyload, ptr %.sroa.39111.0..sroa_idx112, align 4
  %.sroa.44116.0..sroa_idx117 = getelementptr inbounds nuw i8, ptr %2, i32 36
  store i32 %.sroa.44116.0.copyload, ptr %.sroa.44116.0..sroa_idx117, align 4
  %.sroa.37.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 32
  %.sroa.37.0.copyload = load i32, ptr %.sroa.37.0..sroa_idx, align 4
  %.not.not121 = icmp sgt i32 %.sroa.37.0.copyload, -1
  br i1 %.not.not121, label %5, label %10

5:                                                ; preds = %4
  %.sroa.42.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 36
  %.sroa.42.0.copyload = load i32, ptr %.sroa.42.0..sroa_idx, align 4
  %.sroa.33.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 28
  %.sroa.33.0.copyload = load i32, ptr %.sroa.33.0..sroa_idx, align 4
  %.sroa.29.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 24
  %.sroa.29.0.copyload = load i32, ptr %.sroa.29.0..sroa_idx, align 4
  %.sroa.25.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 20
  %.sroa.25.0.copyload = load i32, ptr %.sroa.25.0..sroa_idx, align 4
  %.sroa.21.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.sroa.21.0.copyload = load i32, ptr %.sroa.21.0..sroa_idx, align 4
  %.sroa.17.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.17.0.copyload = load i32, ptr %.sroa.17.0..sroa_idx, align 4
  %.sroa.13.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.13.0.copyload = load i32, ptr %.sroa.13.0..sroa_idx, align 4
  %.sroa.9.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.9.0.copyload = load i32, ptr %.sroa.9.0..sroa_idx, align 4
  %.sroa.0.0.copyload = load i32, ptr %1, align 4
  store i32 %.sroa.0.0.copyload, ptr %3, align 4
  %.sroa.9.0..sroa_idx5 = getelementptr inbounds nuw i8, ptr %3, i32 4
  store i32 %.sroa.9.0.copyload, ptr %.sroa.9.0..sroa_idx5, align 4
  %.sroa.13.0..sroa_idx10 = getelementptr inbounds nuw i8, ptr %3, i32 8
  store i32 %.sroa.13.0.copyload, ptr %.sroa.13.0..sroa_idx10, align 4
  %.sroa.17.0..sroa_idx15 = getelementptr inbounds nuw i8, ptr %3, i32 12
  store i32 %.sroa.17.0.copyload, ptr %.sroa.17.0..sroa_idx15, align 4
  %.sroa.21.0..sroa_idx18 = getelementptr inbounds nuw i8, ptr %3, i32 16
  store i32 %.sroa.21.0.copyload, ptr %.sroa.21.0..sroa_idx18, align 4
  %.sroa.25.0..sroa_idx21 = getelementptr inbounds nuw i8, ptr %3, i32 20
  store i32 %.sroa.25.0.copyload, ptr %.sroa.25.0..sroa_idx21, align 4
  %.sroa.29.0..sroa_idx24 = getelementptr inbounds nuw i8, ptr %3, i32 24
  store i32 %.sroa.29.0.copyload, ptr %.sroa.29.0..sroa_idx24, align 4
  %.sroa.33.0..sroa_idx27 = getelementptr inbounds nuw i8, ptr %3, i32 28
  store i32 %.sroa.33.0.copyload, ptr %.sroa.33.0..sroa_idx27, align 4
  %.sroa.37.0..sroa_idx30 = getelementptr inbounds nuw i8, ptr %3, i32 32
  store i32 %.sroa.37.0.copyload, ptr %.sroa.37.0..sroa_idx30, align 4
  %.sroa.42.0..sroa_idx34 = getelementptr inbounds nuw i8, ptr %3, i32 36
  store i32 %.sroa.42.0.copyload, ptr %.sroa.42.0..sroa_idx34, align 4
  %6 = call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias nonnull captures(none) dereferenceable(40) %2, ptr noalias nonnull captures(none) dereferenceable(40) %3)
  br label %10

7:                                                ; preds = %entry
  %.sroa.39.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 32
  %.sroa.39.0.copyload = load i32, ptr %.sroa.39.0..sroa_idx, align 4
  %.not.not120 = icmp sgt i32 %.sroa.39.0.copyload, -1
  br i1 %.not.not120, label %10, label %8

8:                                                ; preds = %7
  %.sroa.14.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.14.0.copyload = load i32, ptr %.sroa.14.0..sroa_idx, align 4
  %.sroa.942.0..sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.942.0.copyload = load i32, ptr %.sroa.942.0..sroa_idx, align 4
  %.sroa.038.0.copyload = load i32, ptr %1, align 4
  %9 = tail call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationUnavailableO21__derived_enum_equalsySbAC_ACtFZ"(i32 %.sroa.077.0.copyload, i32 %.sroa.981.0.copyload, i32 %.sroa.1486.0.copyload, i32 %.sroa.038.0.copyload, i32 %.sroa.942.0.copyload, i32 %.sroa.14.0.copyload)
  br label %10

10:                                               ; preds = %7, %4, %8, %5
  %11 = phi i1 [ %6, %5 ], [ %9, %8 ], [ false, %4 ], [ false, %7 ]
  call void @llvm.lifetime.end.p0(i64 40, ptr nonnull %3)
  call void @llvm.lifetime.end.p0(i64 40, ptr nonnull %2)
  ret i1 %11
}

; Function Attrs: minsize nounwind optsize memory(argmem: readwrite, inaccessiblemem: write)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe26RasterPresentationResolverO7resolve11requirement13contributions9workspaceAA0eF10ResolutionOAA0eF11RequirementV_AA0eF13ContributionsVAA0efG9WorkspaceVztFZ"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe28RasterPresentationResolutionO) captures(none) initializes((0, 40)) %0, ptr noalias readonly captures(none) dereferenceable(25) %1, ptr noalias readonly captures(none) dereferenceable(93) %2, ptr captures(none) dereferenceable(52) initializes((4, 52)) %3) local_unnamed_addr #10 {
entry:
  %4 = alloca %T27GiftUICapabilityLayoutProbe28RasterPresentationResolutionO, align 4
  call void @llvm.lifetime.start.p0(i64 40, ptr nonnull %4)
  %.firstCandidate = getelementptr inbounds nuw i8, ptr %3, i32 4
  store i32 2, ptr %.firstCandidate, align 4
  %5 = getelementptr inbounds nuw i8, ptr %3, i32 8
  %.secondCandidate = getelementptr inbounds nuw i8, ptr %3, i32 28
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(20) %5, i8 0, i64 20, i1 false)
  store i32 2, ptr %.secondCandidate, align 4
  %6 = getelementptr inbounds nuw i8, ptr %3, i32 32
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(20) %6, i8 0, i64 20, i1 false)
  call swiftcc void @"$e27GiftUICapabilityLayoutProbe26RasterPresentationResolverO15resolvePrepared33_E17D99E015B31087C87CFA5F821C9FD5LL11requirement13contributions9workspaceAA0eF10ResolutionOAA0eF11RequirementV_AA0eF13ContributionsVAA0efG9WorkspaceVztFZ"(ptr noalias nonnull sret(%T27GiftUICapabilityLayoutProbe28RasterPresentationResolutionO) captures(none) %4, ptr noalias nonnull captures(none) dereferenceable(25) %1, ptr noalias nonnull captures(none) dereferenceable(93) %2, ptr nonnull captures(none) dereferenceable(52) %3)
  store i32 2, ptr %.firstCandidate, align 4
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(20) %5, i8 0, i64 20, i1 false)
  store i32 2, ptr %.secondCandidate, align 4
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(20) %6, i8 0, i64 20, i1 false)
  call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(40) %0, ptr noundef nonnull align 4 dereferenceable(40) %4, i32 40, i1 false)
  call void @llvm.lifetime.end.p0(i64 40, ptr nonnull %4)
  ret void
}

; Function Attrs: minsize nounwind optsize memory(argmem: readwrite, inaccessiblemem: write)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe26RasterPresentationResolverO15resolvePrepared33_E17D99E015B31087C87CFA5F821C9FD5LL11requirement13contributions9workspaceAA0eF10ResolutionOAA0eF11RequirementV_AA0eF13ContributionsVAA0efG9WorkspaceVztFZ"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe28RasterPresentationResolutionO) captures(none) initializes((0, 40)) %0, ptr noalias readonly captures(none) dereferenceable(25) %1, ptr noalias readonly captures(none) dereferenceable(93) %2, ptr captures(none) dereferenceable(52) %3) local_unnamed_addr #10 {
entry:
  %4 = alloca %T27GiftUICapabilityLayoutProbe37NormalizedRasterPresentationCandidateV, align 4
  %5 = alloca %T27GiftUICapabilityLayoutProbe37NormalizedRasterPresentationCandidateV, align 4
  %6 = alloca %T27GiftUICapabilityLayoutProbe37NormalizedRasterPresentationCandidateV, align 4
  %7 = alloca %T27GiftUICapabilityLayoutProbe37NormalizedRasterPresentationCandidateV, align 4
  %8 = alloca %T27GiftUICapabilityLayoutProbe37NormalizedRasterPresentationCandidateV, align 4
  %9 = alloca %T27GiftUICapabilityLayoutProbe28RasterPresentationResolutionO, align 4
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %4)
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %5)
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %6)
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %7)
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %8)
  call void @llvm.lifetime.start.p0(i64 40, ptr nonnull %9)
  %.duplicateMask = getelementptr inbounds nuw i8, ptr %2, i32 92
  %.sroa.0158.0.copyload = load i8, ptr %.duplicateMask, align 4
  %10 = and i8 %.sroa.0158.0.copyload, 1
  %.not = icmp eq i8 %10, 0
  br i1 %.not, label %11, label %58

11:                                               ; preds = %entry
  %12 = and i8 %.sroa.0158.0.copyload, 2
  %.not227 = icmp eq i8 %12, 0
  br i1 %.not227, label %13, label %58

13:                                               ; preds = %11
  %14 = and i8 %.sroa.0158.0.copyload, 4
  %.not228 = icmp eq i8 %14, 0
  br i1 %.not228, label %15, label %58

15:                                               ; preds = %13
  %16 = and i8 %.sroa.0158.0.copyload, 8
  %.not230 = icmp eq i8 %16, 0
  br i1 %.not230, label %17, label %58

17:                                               ; preds = %15
  %18 = tail call swiftcc i8 @"$e27GiftUICapabilityLayoutProbe31RasterPresentationContributionsV17lowestMissingRole33_E17D99E015B31087C87CFA5F821C9FD5LLAA0ef11ContributorJ0OSgvg"(ptr noalias nonnull swiftself captures(none) dereferenceable(93) %2)
  %19 = icmp eq i8 %18, 4
  br i1 %19, label %23, label %20

20:                                               ; preds = %17
  %21 = zext nneg i8 %18 to i32
  %22 = or disjoint i32 %21, 1073741824
  br label %58

23:                                               ; preds = %17
  %.sroa.0157.sroa.0.0.copyload = load i8, ptr %2, align 4
  %.sroa.0157.sroa.4.0..renderProducer.sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 1
  %.sroa.0157.sroa.4.0.copyload = load i8, ptr %.sroa.0157.sroa.4.0..renderProducer.sroa_idx, align 1
  %.sroa.5161.0.insert.ext = zext i8 %.sroa.0157.sroa.4.0.copyload to i16
  %.sroa.5161.0.insert.shift = shl nuw i16 %.sroa.5161.0.insert.ext, 8
  %.sroa.0159.0.insert.ext = zext i8 %.sroa.0157.sroa.0.0.copyload to i16
  %.sroa.0159.0.insert.insert = or disjoint i16 %.sroa.5161.0.insert.shift, %.sroa.0159.0.insert.ext
  %24 = icmp eq i8 %.sroa.0157.sroa.4.0.copyload, 2
  br i1 %24, label %58, label %25

25:                                               ; preds = %23
  %.rasterBackend = getelementptr inbounds nuw i8, ptr %2, i32 4
  %.sroa.0156.sroa.0.0.copyload = load i32, ptr %.rasterBackend, align 4
  %.sroa.0156.sroa.4.0..rasterBackend.sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 8
  %.sroa.0156.sroa.4.sroa.4.0..sroa.0156.sroa.4.0..rasterBackend.sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 28
  %.sroa.0156.sroa.4.sroa.4.0.copyload = load i32, ptr %.sroa.0156.sroa.4.sroa.4.0..sroa.0156.sroa.4.0..rasterBackend.sroa_idx.sroa_idx, align 4
  %.sroa.0156.sroa.4.sroa.5.0..sroa.0156.sroa.4.0..rasterBackend.sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 32
  %.sroa.0156.sroa.4.sroa.5.0.copyload = load i32, ptr %.sroa.0156.sroa.4.sroa.5.0..sroa.0156.sroa.4.0..rasterBackend.sroa_idx.sroa_idx, align 4
  %.sroa.0156.sroa.4.sroa.6.0..sroa.0156.sroa.4.0..rasterBackend.sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 36
  %.sroa.0156.sroa.4.sroa.6.0.copyload = load i32, ptr %.sroa.0156.sroa.4.sroa.6.0..sroa.0156.sroa.4.0..rasterBackend.sroa_idx.sroa_idx, align 4
  %.sroa.0156.sroa.4.sroa.7.0..sroa.0156.sroa.4.0..rasterBackend.sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 40
  %.sroa.0156.sroa.4.sroa.7.0.copyload = load i32, ptr %.sroa.0156.sroa.4.sroa.7.0..sroa.0156.sroa.4.0..rasterBackend.sroa_idx.sroa_idx, align 4
  %.sroa.0156.sroa.4.sroa.8.0..sroa.0156.sroa.4.0..rasterBackend.sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 44
  %.sroa.0156.sroa.4.sroa.8.0.copyload = load i32, ptr %.sroa.0156.sroa.4.sroa.8.0..sroa.0156.sroa.4.0..rasterBackend.sroa_idx.sroa_idx, align 4
  %.sroa.0156.sroa.4.sroa.9.0..sroa.0156.sroa.4.0..rasterBackend.sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 48
  %.sroa.0156.sroa.4.sroa.9.0.copyload = load i32, ptr %.sroa.0156.sroa.4.sroa.9.0..sroa.0156.sroa.4.0..rasterBackend.sroa_idx.sroa_idx, align 4
  %26 = and i32 %.sroa.0156.sroa.0.0.copyload, 255
  %27 = icmp eq i32 %26, 2
  br i1 %27, label %58, label %28

28:                                               ; preds = %25
  %.sroa.0165.sroa.0.0.extract.trunc = trunc i32 %.sroa.0156.sroa.0.0.copyload to i8
  %.sroa.0165.sroa.5.0.extract.shift = lshr i32 %.sroa.0156.sroa.0.0.copyload, 8
  %.sroa.0165.sroa.5.0.extract.trunc = trunc nuw i32 %.sroa.0165.sroa.5.0.extract.shift to i24
  %.surfaceDisplay = getelementptr inbounds nuw i8, ptr %2, i32 52
  %.sroa.4171.0..surfaceDisplay.sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 72
  %.sroa.4171.0.copyload = load i8, ptr %.sroa.4171.0..surfaceDisplay.sroa_idx, align 4
  %29 = icmp eq i8 %.sroa.4171.0.copyload, 1
  br i1 %29, label %58, label %30

30:                                               ; preds = %28
  %.hostResourcePolicy = getelementptr inbounds nuw i8, ptr %2, i32 76
  %.sroa.0155.sroa.0.0.copyload = load i32, ptr %.hostResourcePolicy, align 4
  %.sroa.0155.sroa.4.0..hostResourcePolicy.sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 80
  %.sroa.0155.sroa.4.0.copyload = load i32, ptr %.sroa.0155.sroa.4.0..hostResourcePolicy.sroa_idx, align 4
  %.sroa.0155.sroa.5.0..hostResourcePolicy.sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 84
  %.sroa.0155.sroa.5.0.copyload = load i32, ptr %.sroa.0155.sroa.5.0..hostResourcePolicy.sroa_idx, align 4
  %.sroa.0155.sroa.6.0..hostResourcePolicy.sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 88
  %.sroa.0155.sroa.6.0.copyload = load i32, ptr %.sroa.0155.sroa.6.0..hostResourcePolicy.sroa_idx, align 4
  %31 = and i32 %.sroa.0155.sroa.6.0.copyload, 16711680
  %32 = icmp eq i32 %31, 131072
  br i1 %32, label %58, label %33

33:                                               ; preds = %30
  %34 = and i32 %.sroa.0156.sroa.4.sroa.4.0.copyload, 255
  %35 = icmp eq i32 %34, 2
  %36 = select i1 %35, i32 1, i32 2
  %37 = load i8, ptr %3, align 4
  %38 = zext i8 %37 to i32
  %.not229 = icmp samesign ugt i32 %36, %38
  br i1 %.not229, label %58, label %39

39:                                               ; preds = %33
  %40 = tail call swiftcc { i32, i32, i32 } @"$e27GiftUICapabilityLayoutProbe31RasterPresentationCompatibilityO13producerIssue11requirement0H0AA0eF11UnavailableOSgAA0eF11RequirementV_AA26RenderProducerContributionVtFZ"(ptr noalias nonnull captures(none) dereferenceable(25) %1, i16 %.sroa.0159.0.insert.insert)
  %41 = extractvalue { i32, i32, i32 } %40, 0
  %42 = and i32 %41, -3856
  %43 = icmp eq i32 %42, -3856
  br i1 %43, label %46, label %44

44:                                               ; preds = %39
  %45 = and i32 %41, -61441
  br label %58

46:                                               ; preds = %39
  %.sroa.0189.sroa.0.0.extract.trunc = trunc i32 %.sroa.0156.sroa.4.sroa.4.0.copyload to i8
  %.sroa.0189.sroa.5.0.extract.shift = lshr i32 %.sroa.0156.sroa.4.sroa.4.0.copyload, 8
  %.sroa.0189.sroa.5.0.extract.trunc = trunc nuw i32 %.sroa.0189.sroa.5.0.extract.shift to i24
  br i1 %35, label %55, label %47

47:                                               ; preds = %46
  %48 = add i8 %.sroa.0165.sroa.0.0.extract.trunc, 1
  %49 = add i8 %.sroa.0189.sroa.0.0.extract.trunc, 1
  %50 = icmp ult i8 %48, %49
  br i1 %50, label %51, label %53

51:                                               ; preds = %47
  %.sroa.086.sroa.4.sroa.4.0..sroa.086.sroa.4.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %7, i32 4
  call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(20) %.sroa.086.sroa.4.sroa.4.0..sroa.086.sroa.4.0..sroa_idx.sroa_idx, ptr noundef nonnull align 4 dereferenceable(20) %.sroa.0156.sroa.4.0..rasterBackend.sroa_idx, i32 20, i1 false)
  store i8 %.sroa.0165.sroa.0.0.extract.trunc, ptr %7, align 4
  %.sroa.086.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %7, i32 1
  store i24 %.sroa.0165.sroa.5.0.extract.trunc, ptr %.sroa.086.sroa.4.0..sroa_idx, align 1
  %52 = call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceV6appendySbAA010NormalizedeF9CandidateVF"(ptr noalias nonnull captures(none) dereferenceable(24) %7, ptr nonnull swiftself captures(none) dereferenceable(52) %3)
  store i8 %.sroa.0189.sroa.0.0.extract.trunc, ptr %8, align 4
  %.sroa.087.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %8, i32 1
  store i24 %.sroa.0189.sroa.5.0.extract.trunc, ptr %.sroa.087.sroa.4.0..sroa_idx, align 1
  %.sroa.087.sroa.4.sroa.4.0..sroa.087.sroa.4.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %8, i32 4
  store i32 %.sroa.0156.sroa.4.sroa.5.0.copyload, ptr %.sroa.087.sroa.4.sroa.4.0..sroa.087.sroa.4.0..sroa_idx.sroa_idx, align 4
  %.sroa.087.sroa.4.sroa.5.0..sroa.087.sroa.4.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %8, i32 8
  store i32 %.sroa.0156.sroa.4.sroa.6.0.copyload, ptr %.sroa.087.sroa.4.sroa.5.0..sroa.087.sroa.4.0..sroa_idx.sroa_idx, align 4
  %.sroa.087.sroa.4.sroa.6.0..sroa.087.sroa.4.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %8, i32 12
  store i32 %.sroa.0156.sroa.4.sroa.7.0.copyload, ptr %.sroa.087.sroa.4.sroa.6.0..sroa.087.sroa.4.0..sroa_idx.sroa_idx, align 4
  %.sroa.087.sroa.4.sroa.7.0..sroa.087.sroa.4.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %8, i32 16
  store i32 %.sroa.0156.sroa.4.sroa.8.0.copyload, ptr %.sroa.087.sroa.4.sroa.7.0..sroa.087.sroa.4.0..sroa_idx.sroa_idx, align 4
  %.sroa.087.sroa.4.sroa.8.0..sroa.087.sroa.4.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %8, i32 20
  store i32 %.sroa.0156.sroa.4.sroa.9.0.copyload, ptr %.sroa.087.sroa.4.sroa.8.0..sroa.087.sroa.4.0..sroa_idx.sroa_idx, align 4
  br label %56

53:                                               ; preds = %47
  store i8 %.sroa.0189.sroa.0.0.extract.trunc, ptr %5, align 4
  %.sroa.088.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 1
  store i24 %.sroa.0189.sroa.5.0.extract.trunc, ptr %.sroa.088.sroa.4.0..sroa_idx, align 1
  %.sroa.088.sroa.4.sroa.4.0..sroa.088.sroa.4.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 4
  store i32 %.sroa.0156.sroa.4.sroa.5.0.copyload, ptr %.sroa.088.sroa.4.sroa.4.0..sroa.088.sroa.4.0..sroa_idx.sroa_idx, align 4
  %.sroa.088.sroa.4.sroa.5.0..sroa.088.sroa.4.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 8
  store i32 %.sroa.0156.sroa.4.sroa.6.0.copyload, ptr %.sroa.088.sroa.4.sroa.5.0..sroa.088.sroa.4.0..sroa_idx.sroa_idx, align 4
  %.sroa.088.sroa.4.sroa.6.0..sroa.088.sroa.4.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 12
  store i32 %.sroa.0156.sroa.4.sroa.7.0.copyload, ptr %.sroa.088.sroa.4.sroa.6.0..sroa.088.sroa.4.0..sroa_idx.sroa_idx, align 4
  %.sroa.088.sroa.4.sroa.7.0..sroa.088.sroa.4.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 16
  store i32 %.sroa.0156.sroa.4.sroa.8.0.copyload, ptr %.sroa.088.sroa.4.sroa.7.0..sroa.088.sroa.4.0..sroa_idx.sroa_idx, align 4
  %.sroa.088.sroa.4.sroa.8.0..sroa.088.sroa.4.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %5, i32 20
  store i32 %.sroa.0156.sroa.4.sroa.9.0.copyload, ptr %.sroa.088.sroa.4.sroa.8.0..sroa.088.sroa.4.0..sroa_idx.sroa_idx, align 4
  %54 = call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceV6appendySbAA010NormalizedeF9CandidateVF"(ptr noalias nonnull captures(none) dereferenceable(24) %5, ptr nonnull swiftself captures(none) dereferenceable(52) %3)
  %.sroa.089.sroa.4.sroa.4.0..sroa.089.sroa.4.0..sroa_idx.sroa_idx = getelementptr inbounds nuw i8, ptr %6, i32 4
  call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(20) %.sroa.089.sroa.4.sroa.4.0..sroa.089.sroa.4.0..sroa_idx.sroa_idx, ptr noundef nonnull align 4 dereferenceable(20) %.sroa.0156.sroa.4.0..rasterBackend.sroa_idx, i32 20, i1 false)
  store i8 %.sroa.0165.sroa.0.0.extract.trunc, ptr %6, align 4
  %.sroa.089.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %6, i32 1
  store i24 %.sroa.0165.sroa.5.0.extract.trunc, ptr %.sroa.089.sroa.4.0..sroa_idx, align 1
  br label %56

55:                                               ; preds = %46
  %.sroa.098.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %4, i32 4
  call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(20) %.sroa.098.sroa.4.0..sroa_idx, ptr noundef nonnull align 4 dereferenceable(20) %.sroa.0156.sroa.4.0..rasterBackend.sroa_idx, i32 20, i1 false)
  store i32 %.sroa.0156.sroa.0.0.copyload, ptr %4, align 4
  br label %56

56:                                               ; preds = %51, %53, %55
  %.sink = phi ptr [ %8, %51 ], [ %6, %53 ], [ %4, %55 ]
  %57 = call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceV6appendySbAA010NormalizedeF9CandidateVF"(ptr noalias nonnull captures(none) dereferenceable(24) %.sink, ptr nonnull swiftself captures(none) dereferenceable(52) %3)
  call swiftcc void @"$e27GiftUICapabilityLayoutProbe26RasterPresentationResolverO17resolveCandidates33_E17D99E015B31087C87CFA5F821C9FD5LL11requirement7surface6policy9workspaceAA0eF10ResolutionOAA0eF11RequirementV_AA26SurfaceDisplayContributionVAA0eF6PolicyVAA0efG9WorkspaceVtFZ"(ptr noalias nonnull sret(%T27GiftUICapabilityLayoutProbe28RasterPresentationResolutionO) captures(none) %9, ptr noalias nonnull captures(none) dereferenceable(25) %1, ptr noalias nonnull captures(none) dereferenceable(20) %.surfaceDisplay, i32 %.sroa.0155.sroa.0.0.copyload, i32 %.sroa.0155.sroa.4.0.copyload, i32 %.sroa.0155.sroa.5.0.copyload, i32 %.sroa.0155.sroa.6.0.copyload, ptr noalias nonnull captures(none) dereferenceable(52) %3)
  %.sroa.0201.0.copyload202 = load i32, ptr %9, align 4
  %.sroa.9203.0..sroa_idx204 = getelementptr inbounds nuw i8, ptr %9, i32 4
  %.sroa.9203.0.copyload205 = load i32, ptr %.sroa.9203.0..sroa_idx204, align 4
  %.sroa.14206.0..sroa_idx207 = getelementptr inbounds nuw i8, ptr %9, i32 8
  %.sroa.14206.0.copyload208 = load i32, ptr %.sroa.14206.0..sroa_idx207, align 4
  %.sroa.19.0..sroa_idx209 = getelementptr inbounds nuw i8, ptr %9, i32 12
  %.sroa.19.0.copyload210 = load i32, ptr %.sroa.19.0..sroa_idx209, align 4
  %.sroa.24211.0..sroa_idx212 = getelementptr inbounds nuw i8, ptr %9, i32 16
  %.sroa.24211.0.copyload213 = load i32, ptr %.sroa.24211.0..sroa_idx212, align 4
  %.sroa.29214.0..sroa_idx215 = getelementptr inbounds nuw i8, ptr %9, i32 20
  %.sroa.29214.0.copyload216 = load i32, ptr %.sroa.29214.0..sroa_idx215, align 4
  %.sroa.34.0..sroa_idx217 = getelementptr inbounds nuw i8, ptr %9, i32 24
  %.sroa.34.0.copyload218 = load i32, ptr %.sroa.34.0..sroa_idx217, align 4
  %.sroa.39.0..sroa_idx219 = getelementptr inbounds nuw i8, ptr %9, i32 28
  %.sroa.39.0.copyload220 = load i32, ptr %.sroa.39.0..sroa_idx219, align 4
  %.sroa.44.0..sroa_idx221 = getelementptr inbounds nuw i8, ptr %9, i32 32
  %.sroa.44.0.copyload222 = load i32, ptr %.sroa.44.0..sroa_idx221, align 4
  %.sroa.49.0..sroa_idx223 = getelementptr inbounds nuw i8, ptr %9, i32 36
  %.sroa.49.0.copyload224 = load i32, ptr %.sroa.49.0..sroa_idx223, align 4
  br label %58

58:                                               ; preds = %23, %25, %28, %30, %33, %entry, %11, %13, %15, %20, %44, %56
  %.sroa.0201.0 = phi i32 [ %.sroa.0201.0.copyload202, %56 ], [ %45, %44 ], [ %22, %20 ], [ 536870912, %entry ], [ 536870913, %11 ], [ 536870914, %13 ], [ 536870915, %15 ], [ -2147483648, %33 ], [ 1073741824, %30 ], [ 1073741824, %28 ], [ 1073741824, %25 ], [ 1073741824, %23 ]
  %.sroa.9203.0 = phi i32 [ %.sroa.9203.0.copyload205, %56 ], [ 0, %44 ], [ 0, %20 ], [ 0, %entry ], [ 0, %11 ], [ 0, %13 ], [ 0, %15 ], [ %36, %33 ], [ 0, %30 ], [ 0, %28 ], [ 0, %25 ], [ 0, %23 ]
  %.sroa.14206.0 = phi i32 [ %.sroa.14206.0.copyload208, %56 ], [ 0, %44 ], [ 0, %20 ], [ 0, %entry ], [ 0, %11 ], [ 0, %13 ], [ 0, %15 ], [ %38, %33 ], [ 0, %30 ], [ 0, %28 ], [ 0, %25 ], [ 0, %23 ]
  %.sroa.19.0 = phi i32 [ %.sroa.19.0.copyload210, %56 ], [ undef, %44 ], [ undef, %20 ], [ undef, %entry ], [ undef, %11 ], [ undef, %13 ], [ undef, %15 ], [ undef, %33 ], [ undef, %30 ], [ undef, %28 ], [ undef, %25 ], [ undef, %23 ]
  %.sroa.24211.0 = phi i32 [ %.sroa.24211.0.copyload213, %56 ], [ 0, %44 ], [ 0, %20 ], [ 0, %entry ], [ 0, %11 ], [ 0, %13 ], [ 0, %15 ], [ 0, %33 ], [ 0, %30 ], [ 0, %28 ], [ 0, %25 ], [ 0, %23 ]
  %.sroa.29214.0 = phi i32 [ %.sroa.29214.0.copyload216, %56 ], [ 0, %44 ], [ 0, %20 ], [ 0, %entry ], [ 0, %11 ], [ 0, %13 ], [ 0, %15 ], [ 0, %33 ], [ 0, %30 ], [ 0, %28 ], [ 0, %25 ], [ 0, %23 ]
  %.sroa.34.0 = phi i32 [ %.sroa.34.0.copyload218, %56 ], [ undef, %44 ], [ undef, %20 ], [ undef, %entry ], [ undef, %11 ], [ undef, %13 ], [ undef, %15 ], [ undef, %33 ], [ undef, %30 ], [ undef, %28 ], [ undef, %25 ], [ undef, %23 ]
  %.sroa.39.0 = phi i32 [ %.sroa.39.0.copyload220, %56 ], [ undef, %44 ], [ undef, %20 ], [ undef, %entry ], [ undef, %11 ], [ undef, %13 ], [ undef, %15 ], [ undef, %33 ], [ undef, %30 ], [ undef, %28 ], [ undef, %25 ], [ undef, %23 ]
  %.sroa.44.0 = phi i32 [ %.sroa.44.0.copyload222, %56 ], [ -2147483648, %44 ], [ -2147483648, %20 ], [ -2147483648, %entry ], [ -2147483648, %11 ], [ -2147483648, %13 ], [ -2147483648, %15 ], [ -2147483648, %33 ], [ -2147483648, %30 ], [ -2147483648, %28 ], [ -2147483648, %25 ], [ -2147483648, %23 ]
  %.sroa.49.0 = phi i32 [ %.sroa.49.0.copyload224, %56 ], [ undef, %44 ], [ undef, %20 ], [ undef, %entry ], [ undef, %11 ], [ undef, %13 ], [ undef, %15 ], [ undef, %33 ], [ undef, %30 ], [ undef, %28 ], [ undef, %25 ], [ undef, %23 ]
  call void @llvm.lifetime.end.p0(i64 40, ptr nonnull %9)
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %8)
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %7)
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %6)
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %5)
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %4)
  store i32 %.sroa.0201.0, ptr %0, align 4
  %.sroa.9203.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %.sroa.9203.0, ptr %.sroa.9203.0..sroa_idx, align 4
  %.sroa.14206.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %.sroa.14206.0, ptr %.sroa.14206.0..sroa_idx, align 4
  %.sroa.19.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i32 %.sroa.19.0, ptr %.sroa.19.0..sroa_idx, align 4
  %.sroa.24211.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i32 %.sroa.24211.0, ptr %.sroa.24211.0..sroa_idx, align 4
  %.sroa.29214.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 20
  store i32 %.sroa.29214.0, ptr %.sroa.29214.0..sroa_idx, align 4
  %.sroa.34.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 24
  store i32 %.sroa.34.0, ptr %.sroa.34.0..sroa_idx, align 4
  %.sroa.39.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 28
  store i32 %.sroa.39.0, ptr %.sroa.39.0..sroa_idx, align 4
  %.sroa.44.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 32
  store i32 %.sroa.44.0, ptr %.sroa.44.0..sroa_idx, align 4
  %.sroa.49.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 36
  store i32 %.sroa.49.0, ptr %.sroa.49.0..sroa_idx, align 4
  ret void
}

; Function Attrs: minsize nounwind optsize memory(argmem: readwrite, inaccessiblemem: write)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe26RasterPresentationResolverO17resolveCandidates33_E17D99E015B31087C87CFA5F821C9FD5LL11requirement7surface6policy9workspaceAA0eF10ResolutionOAA0eF11RequirementV_AA26SurfaceDisplayContributionVAA0eF6PolicyVAA0efG9WorkspaceVtFZ"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe28RasterPresentationResolutionO) captures(none) initializes((0, 40)) %0, ptr noalias readonly captures(none) dereferenceable(25) %1, ptr noalias readonly captures(none) dereferenceable(20) %2, i32 %3, i32 %4, i32 %5, i32 %6, ptr noalias readonly captures(none) dereferenceable(52) %7) local_unnamed_addr #10 {
entry:
  %8 = alloca %T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV, align 4
  %9 = alloca %T27GiftUICapabilityLayoutProbe29RasterRealizationContributionV, align 4
  %10 = alloca %T27GiftUICapabilityLayoutProbe34RasterPresentationCandidateOutcomeO, align 4
  %11 = alloca %T27GiftUICapabilityLayoutProbe34RasterPresentationCandidateOutcomeO, align 4
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %8)
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %9)
  call void @llvm.lifetime.start.p0(i64 28, ptr nonnull %10)
  call void @llvm.lifetime.start.p0(i64 28, ptr nonnull %11)
  %.firstCandidate = getelementptr inbounds nuw i8, ptr %7, i32 4
  %.sroa.0750.sroa.0.0.copyload = load i32, ptr %.firstCandidate, align 4
  %12 = and i32 %.sroa.0750.sroa.0.0.copyload, 255
  %13 = icmp eq i32 %12, 2
  br i1 %13, label %19, label %14

14:                                               ; preds = %entry
  %.sroa.0750.sroa.4.0..firstCandidate.sroa_idx = getelementptr inbounds nuw i8, ptr %7, i32 8
  %.sroa.4764.0..sroa_idx = getelementptr inbounds nuw i8, ptr %8, i32 4
  call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(20) %.sroa.4764.0..sroa_idx, ptr noundef nonnull align 4 dereferenceable(20) %.sroa.0750.sroa.4.0..firstCandidate.sroa_idx, i32 20, i1 false)
  store i32 %.sroa.0750.sroa.0.0.copyload, ptr %8, align 4
  call swiftcc void @"$e27GiftUICapabilityLayoutProbe31RasterPresentationCompatibilityO17evaluateCandidate11requirement11realization7surface6policyAA0efI7OutcomeOAA0eF11RequirementV_AA0E23RealizationContributionVAA014SurfaceDisplayQ0VAA0eF6PolicyVtFZ"(ptr noalias nonnull sret(%T27GiftUICapabilityLayoutProbe34RasterPresentationCandidateOutcomeO) captures(none) %11, ptr noalias nonnull captures(none) dereferenceable(25) %1, ptr noalias nonnull captures(none) dereferenceable(24) %8, ptr noalias nonnull captures(none) dereferenceable(20) %2, i32 %3, i32 %4, i32 %5, i32 %6)
  %.sroa.0724.0.copyload = load i32, ptr %11, align 4
  %.sroa.16731.0..sroa_idx = getelementptr inbounds nuw i8, ptr %11, i32 8
  %.sroa.16731.0.copyload = load i32, ptr %.sroa.16731.0..sroa_idx, align 4
  %15 = and i32 %.sroa.0724.0.copyload, 268435456
  %.not.not = icmp eq i32 %15, 0
  br i1 %.not.not, label %16, label %17

16:                                               ; preds = %14
  %.sroa.37740.0..sroa_idx = getelementptr inbounds nuw i8, ptr %11, i32 24
  %.sroa.37740.0.copyload = load i32, ptr %.sroa.37740.0..sroa_idx, align 4
  %.sroa.32738.0..sroa_idx = getelementptr inbounds nuw i8, ptr %11, i32 20
  %.sroa.32738.0.copyload = load i32, ptr %.sroa.32738.0..sroa_idx, align 4
  %.sroa.27736.0..sroa_idx = getelementptr inbounds nuw i8, ptr %11, i32 16
  %.sroa.27736.0.copyload = load i32, ptr %.sroa.27736.0..sroa_idx, align 4
  %.sroa.22734.0..sroa_idx = getelementptr inbounds nuw i8, ptr %11, i32 12
  %.sroa.22734.0.copyload = load i32, ptr %.sroa.22734.0..sroa_idx, align 4
  br label %19

17:                                               ; preds = %14
  %.sroa.10728.0..sroa_idx = getelementptr inbounds nuw i8, ptr %11, i32 4
  %.sroa.10728.0.copyload = load i32, ptr %.sroa.10728.0..sroa_idx, align 4
  %18 = and i32 %.sroa.0724.0.copyload, -268435457
  br label %19

19:                                               ; preds = %entry, %16, %17
  %20 = phi i32 [ %18, %17 ], [ -3856, %16 ], [ -3856, %entry ]
  %21 = phi i32 [ %.sroa.10728.0.copyload, %17 ], [ 0, %16 ], [ 0, %entry ]
  %22 = phi i32 [ %.sroa.16731.0.copyload, %17 ], [ 0, %16 ], [ 0, %entry ]
  %23 = phi i32 [ 2, %17 ], [ %.sroa.0724.0.copyload, %16 ], [ 2, %entry ]
  %24 = phi i32 [ 0, %17 ], [ %.sroa.16731.0.copyload, %16 ], [ 0, %entry ]
  %25 = phi i32 [ 0, %17 ], [ %.sroa.22734.0.copyload, %16 ], [ 0, %entry ]
  %26 = phi i32 [ 0, %17 ], [ %.sroa.27736.0.copyload, %16 ], [ 0, %entry ]
  %27 = phi i32 [ 0, %17 ], [ %.sroa.32738.0.copyload, %16 ], [ 0, %entry ]
  %28 = phi i32 [ 0, %17 ], [ %.sroa.37740.0.copyload, %16 ], [ 0, %entry ]
  %.secondCandidate = getelementptr inbounds nuw i8, ptr %7, i32 28
  %.sroa.0749.sroa.0.0.copyload = load i32, ptr %.secondCandidate, align 4
  %29 = and i32 %.sroa.0749.sroa.0.0.copyload, 255
  %30 = icmp eq i32 %29, 2
  br i1 %30, label %71, label %31

31:                                               ; preds = %19
  %.sroa.0749.sroa.4.0..secondCandidate.sroa_idx = getelementptr inbounds nuw i8, ptr %7, i32 32
  %.sroa.4762.0..sroa_idx = getelementptr inbounds nuw i8, ptr %9, i32 4
  call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(20) %.sroa.4762.0..sroa_idx, ptr noundef nonnull align 4 dereferenceable(20) %.sroa.0749.sroa.4.0..secondCandidate.sroa_idx, i32 20, i1 false)
  store i32 %.sroa.0749.sroa.0.0.copyload, ptr %9, align 4
  call swiftcc void @"$e27GiftUICapabilityLayoutProbe31RasterPresentationCompatibilityO17evaluateCandidate11requirement11realization7surface6policyAA0efI7OutcomeOAA0eF11RequirementV_AA0E23RealizationContributionVAA014SurfaceDisplayQ0VAA0eF6PolicyVtFZ"(ptr noalias nonnull sret(%T27GiftUICapabilityLayoutProbe34RasterPresentationCandidateOutcomeO) captures(none) %10, ptr noalias nonnull captures(none) dereferenceable(25) %1, ptr noalias nonnull captures(none) dereferenceable(24) %9, ptr noalias nonnull captures(none) dereferenceable(20) %2, i32 %3, i32 %4, i32 %5, i32 %6)
  %.sroa.0593.0.copyload = load i32, ptr %10, align 4
  %.sroa.14598.0..sroa_idx = getelementptr inbounds nuw i8, ptr %10, i32 4
  %.sroa.14598.0.copyload = load i32, ptr %.sroa.14598.0..sroa_idx, align 4
  %.sroa.20603.0..sroa_idx = getelementptr inbounds nuw i8, ptr %10, i32 8
  %.sroa.20603.0.copyload = load i32, ptr %.sroa.20603.0..sroa_idx, align 4
  %.sroa.27608.0..sroa_idx = getelementptr inbounds nuw i8, ptr %10, i32 12
  %.sroa.27608.0.copyload = load i32, ptr %.sroa.27608.0..sroa_idx, align 4
  %.sroa.32612.0..sroa_idx = getelementptr inbounds nuw i8, ptr %10, i32 16
  %.sroa.32612.0.copyload = load i32, ptr %.sroa.32612.0..sroa_idx, align 4
  %.sroa.37.0..sroa_idx = getelementptr inbounds nuw i8, ptr %10, i32 20
  %.sroa.37.0.copyload = load i32, ptr %.sroa.37.0..sroa_idx, align 4
  %.sroa.42.0..sroa_idx = getelementptr inbounds nuw i8, ptr %10, i32 24
  %.sroa.42.0.copyload = load i32, ptr %.sroa.42.0..sroa_idx, align 4
  %32 = and i32 %.sroa.0593.0.copyload, 268435456
  %.not.not765 = icmp eq i32 %32, 0
  %33 = and i32 %23, 255
  %34 = icmp eq i32 %33, 2
  br i1 %.not.not765, label %35, label %54

35:                                               ; preds = %31
  %.sroa.20603.sroa.10.0.extract.shift648 = lshr i32 %.sroa.20603.0.copyload, 16
  br i1 %34, label %50, label %36

36:                                               ; preds = %35
  %37 = trunc i32 %23 to i8
  %38 = lshr i32 %24, 16
  %temp-coercion.coerced.sroa.5.14.extract.shift.i = lshr i32 %6, 16
  %.sroa.0.0.extract.trunc768 = trunc i32 %.sroa.0593.0.copyload to i8
  %39 = trunc i32 %temp-coercion.coerced.sroa.5.14.extract.shift.i to i8
  %40 = icmp eq i8 %.sroa.0.0.extract.trunc768, %39
  %41 = icmp eq i8 %37, %39
  %42 = xor i1 %41, %40
  %43 = add i8 %.sroa.0.0.extract.trunc768, 1
  %44 = add i8 %37, 1
  %45 = icmp ult i8 %43, %44
  %46 = select i1 %42, i1 %40, i1 %45
  %.sroa.0593.0.copyload. = select i1 %46, i32 %.sroa.0593.0.copyload, i32 %23
  %.sroa.20603.0.copyload. = select i1 %46, i32 %.sroa.20603.0.copyload, i32 %24
  %.sroa.20603.sroa.10.0.extract.shift648. = select i1 %46, i32 %.sroa.20603.sroa.10.0.extract.shift648, i32 %38
  %.sroa.27608.0.copyload. = select i1 %46, i32 %.sroa.27608.0.copyload, i32 %25
  %.sroa.32612.0.copyload. = select i1 %46, i32 %.sroa.32612.0.copyload, i32 %26
  %.sroa.37.0.copyload. = select i1 %46, i32 %.sroa.37.0.copyload, i32 %27
  %.sroa.42.0.copyload. = select i1 %46, i32 %.sroa.42.0.copyload, i32 %28
  %47 = load i8, ptr %1, align 4
  %.extent71 = getelementptr inbounds nuw i8, ptr %1, i32 2
  %48 = load i16, ptr %.extent71, align 2
  %.extent71.height = getelementptr inbounds nuw i8, ptr %1, i32 4
  %49 = load i16, ptr %.extent71.height, align 2
  %.sroa.25.sroa.0.0.extract.trunc = and i32 %.sroa.0593.0.copyload., 1
  %.sroa.0110.sroa.7.0.insert.ext167 = zext i16 %48 to i32
  %.sroa.0110.sroa.7.0.insert.shift168 = shl nuw i32 %.sroa.0110.sroa.7.0.insert.ext167, 16
  %.sroa.0110.sroa.0.0.insert.ext160 = zext i8 %47 to i32
  %.sroa.0110.sroa.0.0.insert.insert162 = or disjoint i32 %.sroa.0110.sroa.7.0.insert.shift168, %.sroa.0110.sroa.0.0.insert.ext160
  %.sroa.8111.sroa.6.0.insert.ext = shl i32 %.sroa.20603.0.copyload., 16
  %.sroa.8111.sroa.0.0.insert.ext = zext i16 %49 to i32
  %.sroa.8111.sroa.0.0.insert.insert = or disjoint i32 %.sroa.8111.sroa.6.0.insert.ext, %.sroa.8111.sroa.0.0.insert.ext
  %.sroa.19.sroa.6.0.insert.insert = and i32 %.sroa.0593.0.copyload., 16974080
  br label %84

50:                                               ; preds = %35
  %51 = load i8, ptr %1, align 4
  %.extent40 = getelementptr inbounds nuw i8, ptr %1, i32 2
  %52 = load i16, ptr %.extent40, align 2
  %.extent40.height = getelementptr inbounds nuw i8, ptr %1, i32 4
  %53 = load i16, ptr %.extent40.height, align 2
  %.sroa.25.sroa.0255.0.insert.ext = and i32 %.sroa.0593.0.copyload, 1
  %.sroa.0228.sroa.7.0.insert.ext312 = zext i16 %52 to i32
  %.sroa.0228.sroa.7.0.insert.shift313 = shl nuw i32 %.sroa.0228.sroa.7.0.insert.ext312, 16
  %.sroa.0228.sroa.0.0.insert.ext305 = zext i8 %51 to i32
  %.sroa.0228.sroa.0.0.insert.insert307 = or disjoint i32 %.sroa.0228.sroa.7.0.insert.shift313, %.sroa.0228.sroa.0.0.insert.ext305
  %.sroa.8229.sroa.6.0.insert.ext = shl i32 %.sroa.20603.0.copyload, 16
  %.sroa.8229.sroa.0.0.insert.ext = zext i16 %53 to i32
  %.sroa.8229.sroa.0.0.insert.insert = or disjoint i32 %.sroa.8229.sroa.6.0.insert.ext, %.sroa.8229.sroa.0.0.insert.ext
  %.sroa.19.sroa.6275.0.insert.insert = and i32 %.sroa.0593.0.copyload, 16974080
  br label %84

54:                                               ; preds = %31
  %.sroa.0593.sroa.0.0.insert.insert655 = and i32 %.sroa.0593.0.copyload, -268435457
  br i1 %34, label %60, label %55

55:                                               ; preds = %54
  %56 = lshr i32 %24, 16
  %57 = load i8, ptr %1, align 4
  %.extent20 = getelementptr inbounds nuw i8, ptr %1, i32 2
  %58 = load i16, ptr %.extent20, align 2
  %.extent20.height = getelementptr inbounds nuw i8, ptr %1, i32 4
  %59 = load i16, ptr %.extent20.height, align 2
  %.sroa.25.sroa.0380.0.extract.trunc = and i32 %23, 1
  %.sroa.0354.sroa.7.0.insert.ext433 = zext i16 %58 to i32
  %.sroa.0354.sroa.7.0.insert.shift434 = shl nuw i32 %.sroa.0354.sroa.7.0.insert.ext433, 16
  %.sroa.0354.sroa.0.0.insert.ext426 = zext i8 %57 to i32
  %.sroa.0354.sroa.0.0.insert.insert428 = or disjoint i32 %.sroa.0354.sroa.7.0.insert.shift434, %.sroa.0354.sroa.0.0.insert.ext426
  %.sroa.8355.sroa.6.0.insert.ext = shl i32 %24, 16
  %.sroa.8355.sroa.0.0.insert.ext = zext i16 %59 to i32
  %.sroa.8355.sroa.0.0.insert.insert = or disjoint i32 %.sroa.8355.sroa.6.0.insert.ext, %.sroa.8355.sroa.0.0.insert.ext
  %.sroa.19358.sroa.6.0.insert.insert = and i32 %23, 16974080
  br label %84

60:                                               ; preds = %54
  %61 = and i32 %20, -3856
  %62 = icmp eq i32 %61, -3856
  br i1 %62, label %69, label %63

63:                                               ; preds = %60
  %64 = tail call swiftcc { i32, i32, i32 } @"$e27GiftUICapabilityLayoutProbe26RasterPresentationResolverO13primaryReasonyAA0eF11UnavailableOAF_AFtFZ"(i32 %20, i32 %21, i32 %22, i32 %.sroa.0593.sroa.0.0.insert.insert655, i32 %.sroa.14598.0.copyload, i32 %.sroa.20603.0.copyload)
  %65 = extractvalue { i32, i32, i32 } %64, 0
  %66 = extractvalue { i32, i32, i32 } %64, 1
  %67 = extractvalue { i32, i32, i32 } %64, 2
  %68 = and i32 %65, -61441
  br label %84

69:                                               ; preds = %60
  %70 = and i32 %.sroa.0593.0.copyload, -268496897
  br label %84

71:                                               ; preds = %19
  %72 = and i32 %23, 255
  %73 = icmp eq i32 %72, 2
  br i1 %73, label %79, label %74

74:                                               ; preds = %71
  %75 = lshr i32 %24, 16
  %76 = load i8, ptr %1, align 4
  %.extent = getelementptr inbounds nuw i8, ptr %1, i32 2
  %77 = load i16, ptr %.extent, align 2
  %.extent.height = getelementptr inbounds nuw i8, ptr %1, i32 4
  %78 = load i16, ptr %.extent.height, align 2
  %.sroa.25.sroa.0512.0.extract.trunc = and i32 %23, 1
  %.sroa.0486.sroa.7.0.insert.ext565 = zext i16 %77 to i32
  %.sroa.0486.sroa.7.0.insert.shift566 = shl nuw i32 %.sroa.0486.sroa.7.0.insert.ext565, 16
  %.sroa.0486.sroa.0.0.insert.ext558 = zext i8 %76 to i32
  %.sroa.0486.sroa.0.0.insert.insert560 = or disjoint i32 %.sroa.0486.sroa.7.0.insert.shift566, %.sroa.0486.sroa.0.0.insert.ext558
  %.sroa.8487.sroa.6.0.insert.ext = shl i32 %24, 16
  %.sroa.8487.sroa.0.0.insert.ext = zext i16 %78 to i32
  %.sroa.8487.sroa.0.0.insert.insert = or disjoint i32 %.sroa.8487.sroa.6.0.insert.ext, %.sroa.8487.sroa.0.0.insert.ext
  %.sroa.19490.sroa.6.0.insert.insert = and i32 %23, 16974080
  br label %84

79:                                               ; preds = %71
  %80 = and i32 %20, -3856
  %81 = icmp eq i32 %80, -3856
  br i1 %81, label %84, label %82

82:                                               ; preds = %79
  %83 = and i32 %20, -61441
  br label %84

84:                                               ; preds = %79, %36, %50, %55, %63, %69, %74, %82
  %.sroa.0589.0 = phi i32 [ %83, %82 ], [ %.sroa.0486.sroa.0.0.insert.insert560, %74 ], [ %.sroa.0228.sroa.0.0.insert.insert307, %50 ], [ %.sroa.0110.sroa.0.0.insert.insert162, %36 ], [ %70, %69 ], [ %68, %63 ], [ %.sroa.0354.sroa.0.0.insert.insert428, %55 ], [ -1073741817, %79 ]
  %.sroa.11590.0 = phi i32 [ %21, %82 ], [ %.sroa.8487.sroa.0.0.insert.insert, %74 ], [ %.sroa.8229.sroa.0.0.insert.insert, %50 ], [ %.sroa.8111.sroa.0.0.insert.insert, %36 ], [ %.sroa.14598.0.copyload, %69 ], [ %66, %63 ], [ %.sroa.8355.sroa.0.0.insert.insert, %55 ], [ 0, %79 ]
  %.sroa.19591.0 = phi i32 [ %22, %82 ], [ %75, %74 ], [ %.sroa.20603.sroa.10.0.extract.shift648, %50 ], [ %.sroa.20603.sroa.10.0.extract.shift648., %36 ], [ %.sroa.20603.0.copyload, %69 ], [ %67, %63 ], [ %56, %55 ], [ 0, %79 ]
  %.sroa.27.0 = phi i32 [ undef, %82 ], [ %25, %74 ], [ %.sroa.27608.0.copyload, %50 ], [ %.sroa.27608.0.copyload., %36 ], [ undef, %69 ], [ undef, %63 ], [ %25, %55 ], [ undef, %79 ]
  %.sroa.35.0 = phi i32 [ 0, %82 ], [ %.sroa.19490.sroa.6.0.insert.insert, %74 ], [ %.sroa.19.sroa.6275.0.insert.insert, %50 ], [ %.sroa.19.sroa.6.0.insert.insert, %36 ], [ 0, %69 ], [ 0, %63 ], [ %.sroa.19358.sroa.6.0.insert.insert, %55 ], [ 0, %79 ]
  %.sroa.43.0 = phi i32 [ 0, %82 ], [ %.sroa.25.sroa.0512.0.extract.trunc, %74 ], [ %.sroa.25.sroa.0255.0.insert.ext, %50 ], [ %.sroa.25.sroa.0.0.extract.trunc, %36 ], [ 0, %69 ], [ 0, %63 ], [ %.sroa.25.sroa.0380.0.extract.trunc, %55 ], [ 0, %79 ]
  %.sroa.51.0 = phi i32 [ undef, %82 ], [ %26, %74 ], [ %.sroa.32612.0.copyload, %50 ], [ %.sroa.32612.0.copyload., %36 ], [ undef, %69 ], [ undef, %63 ], [ %26, %55 ], [ undef, %79 ]
  %.sroa.59.0 = phi i32 [ undef, %82 ], [ %27, %74 ], [ %.sroa.37.0.copyload, %50 ], [ %.sroa.37.0.copyload., %36 ], [ undef, %69 ], [ undef, %63 ], [ %27, %55 ], [ undef, %79 ]
  %.sroa.67.0 = phi i32 [ -2147483648, %82 ], [ 1, %74 ], [ 1, %50 ], [ 1, %36 ], [ -2147483648, %69 ], [ -2147483648, %63 ], [ 1, %55 ], [ -2147483648, %79 ]
  %.sroa.75.0 = phi i32 [ undef, %82 ], [ %28, %74 ], [ %.sroa.42.0.copyload, %50 ], [ %.sroa.42.0.copyload., %36 ], [ undef, %69 ], [ undef, %63 ], [ %28, %55 ], [ undef, %79 ]
  store i32 %.sroa.0589.0, ptr %0, align 4
  %.sroa.11590.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %.sroa.11590.0, ptr %.sroa.11590.0..sroa_idx, align 4
  %.sroa.19591.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %.sroa.19591.0, ptr %.sroa.19591.0..sroa_idx, align 4
  %.sroa.27.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i32 %.sroa.27.0, ptr %.sroa.27.0..sroa_idx, align 4
  %.sroa.35.0..sroa_idx592 = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i32 %.sroa.35.0, ptr %.sroa.35.0..sroa_idx592, align 4
  %.sroa.43.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 20
  store i32 %.sroa.43.0, ptr %.sroa.43.0..sroa_idx, align 4
  %.sroa.51.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 24
  store i32 %.sroa.51.0, ptr %.sroa.51.0..sroa_idx, align 4
  %.sroa.59.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 28
  store i32 %.sroa.59.0, ptr %.sroa.59.0..sroa_idx, align 4
  %.sroa.67.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 32
  store i32 %.sroa.67.0, ptr %.sroa.67.0..sroa_idx, align 4
  %.sroa.75.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 36
  store i32 %.sroa.75.0, ptr %.sroa.75.0..sroa_idx, align 4
  call void @llvm.lifetime.end.p0(i64 28, ptr nonnull %11)
  call void @llvm.lifetime.end.p0(i64 28, ptr nonnull %10)
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %9)
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %8)
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i32, i32 } @"$e27GiftUICapabilityLayoutProbe26RasterPresentationResolverO13primaryReasonyAA0eF11UnavailableOAF_AFtFZ"(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5) local_unnamed_addr #0 {
entry:
  %6 = lshr i32 %0, 29
  %7 = trunc nuw nsw i32 %6 to i8
  switch i8 %7, label %33 [
    i8 1, label %select_enum1
    i8 2, label %31
    i8 4, label %switch.lookup
    i8 5, label %32
    i8 6, label %8
  ]

8:                                                ; preds = %entry
  %9 = icmp eq i32 %0, -1073741824
  %10 = or i32 %2, %1
  %11 = icmp eq i32 %10, 0
  %12 = and i1 %9, %11
  br i1 %12, label %select_enum1, label %13

13:                                               ; preds = %8
  %14 = icmp eq i32 %0, -1073741823
  %15 = and i1 %14, %11
  br i1 %15, label %select_enum1, label %16

16:                                               ; preds = %13
  %17 = icmp eq i32 %0, -1073741821
  %18 = and i1 %17, %11
  br i1 %18, label %select_enum1, label %19

19:                                               ; preds = %16
  %20 = icmp eq i32 %0, -1073741820
  %21 = and i1 %20, %11
  br i1 %21, label %select_enum1, label %22

22:                                               ; preds = %19
  %23 = icmp eq i32 %0, -1073741819
  %24 = and i1 %23, %11
  br i1 %24, label %select_enum1, label %25

25:                                               ; preds = %22
  %26 = icmp eq i32 %0, -1073741818
  %27 = and i1 %26, %11
  br i1 %27, label %select_enum1, label %28

28:                                               ; preds = %25
  %29 = icmp eq i32 %0, -1073741817
  %30 = and i1 %29, %11
  br i1 %30, label %select_enum1, label %33

switch.lookup:                                    ; preds = %entry
  %switch.cast = trunc i32 %0 to i4
  %switch.downshift = lshr i4 -2, %switch.cast
  %switch.masked = trunc i4 %switch.downshift to i1
  %switch.cast61 = trunc i32 %0 to i4
  %switch.downshift63 = lshr i4 1, %switch.cast61
  %switch.masked64 = trunc nuw i4 %switch.downshift63 to i1
  %switch.cast65 = trunc i32 %0 to i4
  %switch.downshift67 = lshr i4 -2, %switch.cast65
  %switch.masked68 = trunc i4 %switch.downshift67 to i1
  %switch.cast69 = trunc i32 %0 to i4
  %switch.downshift71 = lshr i4 1, %switch.cast69
  %switch.masked72 = trunc nuw i4 %switch.downshift71 to i1
  %switch.cast73 = trunc i32 %0 to i4
  %switch.downshift75 = lshr i4 -2, %switch.cast73
  %switch.masked76 = trunc i4 %switch.downshift75 to i1
  %switch.cast77 = trunc i32 %0 to i4
  %switch.downshift79 = lshr i4 1, %switch.cast77
  %switch.masked80 = trunc nuw i4 %switch.downshift79 to i1
  %switch.cast81 = trunc i32 %0 to i4
  %switch.downshift83 = lshr i4 -2, %switch.cast81
  %switch.masked84 = trunc i4 %switch.downshift83 to i1
  %switch.cast85 = trunc i32 %0 to i4
  %switch.downshift87 = lshr i4 1, %switch.cast85
  %switch.masked88 = trunc nuw i4 %switch.downshift87 to i1
  %switch.cast89 = trunc i32 %0 to i4
  %switch.downshift91 = lshr i4 -2, %switch.cast89
  %switch.masked92 = trunc i4 %switch.downshift91 to i1
  %switch.cast93 = trunc i32 %0 to i4
  %switch.downshift95 = lshr i4 1, %switch.cast93
  %switch.masked96 = trunc nuw i4 %switch.downshift95 to i1
  %switch.cast97 = trunc i32 %0 to i4
  %switch.downshift99 = lshr i4 -2, %switch.cast97
  %switch.masked100 = trunc i4 %switch.downshift99 to i1
  %switch.cast101 = trunc i32 %0 to i4
  %switch.downshift103 = lshr i4 1, %switch.cast101
  %switch.masked104 = trunc nuw i4 %switch.downshift103 to i1
  %switch.cast105 = trunc i32 %0 to i4
  %switch.downshift107 = lshr i4 -2, %switch.cast105
  %switch.masked108 = trunc i4 %switch.downshift107 to i1
  %switch.cast109 = trunc i32 %0 to i4
  %switch.downshift111 = lshr i4 1, %switch.cast109
  %switch.masked112 = trunc nuw i4 %switch.downshift111 to i1
  %switch.cast113 = shl i32 %0, 3
  %switch.shiftamt114 = and i32 %switch.cast113, 2040
  %switch.downshift115 = lshr i32 252579075, %switch.shiftamt114
  %switch.masked116 = trunc i32 %switch.downshift115 to i8
  br label %select_enum1

31:                                               ; preds = %entry
  br label %select_enum1

32:                                               ; preds = %entry
  br label %select_enum1

33:                                               ; preds = %28, %entry
  br label %select_enum1

select_enum1:                                     ; preds = %switch.lookup, %28, %25, %22, %19, %13, %8, %16, %entry, %31, %32, %33
  %34 = phi i1 [ true, %33 ], [ false, %32 ], [ false, %31 ], [ false, %entry ], [ false, %16 ], [ false, %8 ], [ false, %13 ], [ false, %19 ], [ false, %22 ], [ false, %25 ], [ false, %28 ], [ false, %switch.lookup ]
  %35 = phi i1 [ false, %33 ], [ true, %32 ], [ true, %31 ], [ true, %entry ], [ true, %16 ], [ true, %8 ], [ true, %13 ], [ true, %19 ], [ true, %22 ], [ true, %25 ], [ false, %28 ], [ true, %switch.lookup ]
  %36 = phi i1 [ true, %33 ], [ true, %32 ], [ false, %31 ], [ false, %entry ], [ false, %16 ], [ false, %8 ], [ false, %13 ], [ false, %19 ], [ false, %22 ], [ false, %25 ], [ true, %28 ], [ %switch.masked, %switch.lookup ]
  %37 = phi i1 [ false, %33 ], [ false, %32 ], [ true, %31 ], [ true, %entry ], [ true, %16 ], [ true, %8 ], [ true, %13 ], [ true, %19 ], [ true, %22 ], [ false, %25 ], [ false, %28 ], [ %switch.masked64, %switch.lookup ]
  %38 = phi i1 [ true, %33 ], [ true, %32 ], [ false, %31 ], [ false, %entry ], [ false, %16 ], [ false, %8 ], [ false, %13 ], [ false, %19 ], [ false, %22 ], [ true, %25 ], [ true, %28 ], [ %switch.masked68, %switch.lookup ]
  %39 = phi i1 [ false, %33 ], [ false, %32 ], [ true, %31 ], [ true, %entry ], [ true, %16 ], [ true, %8 ], [ true, %13 ], [ true, %19 ], [ false, %22 ], [ false, %25 ], [ false, %28 ], [ %switch.masked72, %switch.lookup ]
  %40 = phi i1 [ true, %33 ], [ true, %32 ], [ false, %31 ], [ false, %entry ], [ false, %16 ], [ false, %8 ], [ false, %13 ], [ false, %19 ], [ true, %22 ], [ true, %25 ], [ true, %28 ], [ %switch.masked76, %switch.lookup ]
  %41 = phi i1 [ false, %33 ], [ false, %32 ], [ true, %31 ], [ true, %entry ], [ true, %16 ], [ true, %8 ], [ true, %13 ], [ false, %19 ], [ false, %22 ], [ false, %25 ], [ false, %28 ], [ %switch.masked80, %switch.lookup ]
  %42 = phi i1 [ true, %33 ], [ true, %32 ], [ false, %31 ], [ false, %entry ], [ false, %16 ], [ true, %8 ], [ true, %13 ], [ true, %19 ], [ true, %22 ], [ true, %25 ], [ true, %28 ], [ %switch.masked84, %switch.lookup ]
  %43 = phi i1 [ false, %33 ], [ false, %32 ], [ true, %31 ], [ true, %entry ], [ false, %16 ], [ false, %8 ], [ false, %13 ], [ false, %19 ], [ false, %22 ], [ false, %25 ], [ false, %28 ], [ %switch.masked88, %switch.lookup ]
  %44 = phi i1 [ true, %33 ], [ true, %32 ], [ false, %31 ], [ false, %entry ], [ false, %16 ], [ false, %8 ], [ false, %13 ], [ true, %19 ], [ true, %22 ], [ true, %25 ], [ true, %28 ], [ %switch.masked92, %switch.lookup ]
  %45 = phi i1 [ false, %33 ], [ false, %32 ], [ true, %31 ], [ true, %entry ], [ true, %16 ], [ true, %8 ], [ false, %13 ], [ false, %19 ], [ false, %22 ], [ false, %25 ], [ false, %28 ], [ %switch.masked96, %switch.lookup ]
  %46 = phi i1 [ true, %33 ], [ true, %32 ], [ false, %31 ], [ false, %entry ], [ false, %16 ], [ false, %8 ], [ true, %13 ], [ true, %19 ], [ true, %22 ], [ true, %25 ], [ true, %28 ], [ %switch.masked100, %switch.lookup ]
  %47 = phi i1 [ false, %33 ], [ false, %32 ], [ true, %31 ], [ true, %entry ], [ true, %16 ], [ false, %8 ], [ false, %13 ], [ false, %19 ], [ false, %22 ], [ false, %25 ], [ false, %28 ], [ %switch.masked104, %switch.lookup ]
  %48 = phi i1 [ true, %33 ], [ false, %32 ], [ false, %31 ], [ false, %entry ], [ false, %16 ], [ false, %8 ], [ false, %13 ], [ false, %19 ], [ false, %22 ], [ false, %25 ], [ true, %28 ], [ %switch.masked108, %switch.lookup ]
  %49 = phi i1 [ false, %33 ], [ false, %32 ], [ true, %31 ], [ true, %entry ], [ true, %16 ], [ true, %8 ], [ true, %13 ], [ true, %19 ], [ true, %22 ], [ true, %25 ], [ false, %28 ], [ %switch.masked112, %switch.lookup ]
  %50 = phi i1 [ true, %33 ], [ true, %32 ], [ false, %31 ], [ false, %entry ], [ true, %16 ], [ true, %8 ], [ true, %13 ], [ true, %19 ], [ true, %22 ], [ true, %25 ], [ true, %28 ], [ true, %switch.lookup ]
  %51 = phi i1 [ false, %33 ], [ false, %32 ], [ false, %31 ], [ true, %entry ], [ false, %16 ], [ false, %8 ], [ false, %13 ], [ false, %19 ], [ false, %22 ], [ false, %25 ], [ false, %28 ], [ false, %switch.lookup ]
  %52 = phi i1 [ true, %33 ], [ true, %32 ], [ true, %31 ], [ false, %entry ], [ true, %16 ], [ true, %8 ], [ true, %13 ], [ true, %19 ], [ true, %22 ], [ true, %25 ], [ true, %28 ], [ true, %switch.lookup ]
  %53 = phi i1 [ false, %33 ], [ true, %32 ], [ true, %31 ], [ true, %entry ], [ true, %16 ], [ true, %8 ], [ true, %13 ], [ true, %19 ], [ true, %22 ], [ true, %25 ], [ true, %28 ], [ true, %switch.lookup ]
  %54 = phi i8 [ -1, %33 ], [ 12, %32 ], [ %7, %31 ], [ %7, %entry ], [ 6, %16 ], [ 7, %8 ], [ 8, %13 ], [ 9, %19 ], [ 10, %22 ], [ 11, %25 ], [ 16, %28 ], [ %switch.masked116, %switch.lookup ]
  %55 = lshr i32 %3, 29
  %56 = trunc nuw nsw i32 %55 to i8
  switch i8 %56, label %91 [
    i8 1, label %81
    i8 2, label %82
    i8 4, label %switch.lookup117
    i8 5, label %89
    i8 6, label %57
  ]

57:                                               ; preds = %select_enum1
  %58 = icmp eq i32 %3, -1073741824
  %59 = or i32 %5, %4
  %60 = icmp eq i32 %59, 0
  %61 = and i1 %58, %60
  br i1 %61, label %84, label %62

62:                                               ; preds = %57
  %63 = icmp eq i32 %3, -1073741823
  %64 = and i1 %63, %60
  br i1 %64, label %85, label %65

65:                                               ; preds = %62
  %66 = icmp eq i32 %3, -1073741821
  %67 = and i1 %66, %60
  br i1 %67, label %83, label %68

68:                                               ; preds = %65
  %69 = icmp eq i32 %3, -1073741820
  %70 = and i1 %69, %60
  br i1 %70, label %86, label %71

71:                                               ; preds = %68
  %72 = icmp eq i32 %3, -1073741819
  %73 = and i1 %72, %60
  br i1 %73, label %87, label %74

74:                                               ; preds = %71
  %75 = icmp eq i32 %3, -1073741818
  %76 = and i1 %75, %60
  br i1 %76, label %88, label %77

77:                                               ; preds = %74
  %78 = icmp eq i32 %3, -1073741817
  %79 = and i1 %78, %60
  br i1 %79, label %90, label %91

switch.lookup117:                                 ; preds = %select_enum1
  %switch.cast118 = shl i32 %3, 3
  %switch.shiftamt119 = and i32 %switch.cast118, 2040
  %switch.downshift120 = lshr i32 252579075, %switch.shiftamt119
  %switch.masked121 = trunc i32 %switch.downshift120 to i8
  %80 = icmp ugt i8 %54, %switch.masked121
  br i1 %80, label %94, label %92

81:                                               ; preds = %select_enum1
  br i1 %52, label %94, label %101

82:                                               ; preds = %select_enum1
  %brmerge = or i1 %50, %51
  %.mux = select i1 %50, i32 %3, i32 %0
  %.mux27 = select i1 %50, i32 %4, i32 %1
  %.mux28 = select i1 %50, i32 %5, i32 %2
  br i1 %brmerge, label %94, label %101

83:                                               ; preds = %65
  %brmerge29 = or i1 %42, %43
  %.mux30 = select i1 %42, i32 -1073741821, i32 %0
  %.mux31 = select i1 %42, i32 0, i32 %1
  %.mux32 = select i1 %42, i32 0, i32 %2
  br i1 %brmerge29, label %94, label %101

84:                                               ; preds = %57
  %brmerge33 = or i1 %46, %47
  %.mux34 = select i1 %46, i32 -1073741824, i32 %0
  %.mux35 = select i1 %46, i32 0, i32 %1
  %.mux36 = select i1 %46, i32 0, i32 %2
  br i1 %brmerge33, label %94, label %101

85:                                               ; preds = %62
  %brmerge37 = or i1 %44, %45
  %.mux38 = select i1 %44, i32 -1073741823, i32 %0
  %.mux39 = select i1 %44, i32 0, i32 %1
  %.mux40 = select i1 %44, i32 0, i32 %2
  br i1 %brmerge37, label %94, label %101

86:                                               ; preds = %68
  %brmerge41 = or i1 %40, %41
  %.mux42 = select i1 %40, i32 -1073741820, i32 %0
  %.mux43 = select i1 %40, i32 0, i32 %1
  %.mux44 = select i1 %40, i32 0, i32 %2
  br i1 %brmerge41, label %94, label %101

87:                                               ; preds = %71
  %brmerge45 = or i1 %38, %39
  %.mux46 = select i1 %38, i32 -1073741819, i32 %0
  %.mux47 = select i1 %38, i32 0, i32 %1
  %.mux48 = select i1 %38, i32 0, i32 %2
  br i1 %brmerge45, label %94, label %101

88:                                               ; preds = %74
  %brmerge49 = or i1 %36, %37
  %.mux50 = select i1 %36, i32 -1073741818, i32 %0
  %.mux51 = select i1 %36, i32 0, i32 %1
  %.mux52 = select i1 %36, i32 0, i32 %2
  br i1 %brmerge49, label %94, label %101

89:                                               ; preds = %select_enum1
  %brmerge53 = or i1 %48, %49
  %.mux54 = select i1 %48, i32 %3, i32 %0
  %.mux55 = select i1 %48, i32 %4, i32 %1
  %.mux56 = select i1 %48, i32 %5, i32 %2
  br i1 %brmerge53, label %94, label %101

90:                                               ; preds = %77
  %brmerge57 = or i1 %34, %35
  %.mux58 = select i1 %34, i32 -1073741817, i32 %0
  %.mux59 = select i1 %34, i32 0, i32 %1
  %.mux60 = select i1 %34, i32 0, i32 %2
  br i1 %brmerge57, label %94, label %101

91:                                               ; preds = %77, %select_enum1
  br i1 %53, label %94, label %101

92:                                               ; preds = %switch.lookup117
  %93 = icmp samesign ult i8 %54, %switch.masked121
  br i1 %93, label %94, label %101

94:                                               ; preds = %90, %89, %88, %87, %86, %85, %84, %83, %82, %109, %103, %104, %102, %101, %91, %92, %81, %switch.lookup117, %114, %115
  %95 = phi i32 [ %3, %115 ], [ %3, %114 ], [ %.mux, %82 ], [ %.mux30, %83 ], [ %.mux34, %84 ], [ %.mux38, %85 ], [ %.mux42, %86 ], [ %.mux46, %87 ], [ %.mux50, %88 ], [ %.mux54, %89 ], [ %.mux58, %90 ], [ %3, %switch.lookup117 ], [ %3, %81 ], [ %0, %92 ], [ %0, %91 ], [ %0, %101 ], [ %0, %102 ], [ %0, %104 ], [ %0, %103 ], [ %0, %109 ]
  %96 = phi i32 [ %4, %115 ], [ %4, %114 ], [ %.mux27, %82 ], [ %.mux31, %83 ], [ %.mux35, %84 ], [ %.mux39, %85 ], [ %.mux43, %86 ], [ %.mux47, %87 ], [ %.mux51, %88 ], [ %.mux55, %89 ], [ %.mux59, %90 ], [ %4, %switch.lookup117 ], [ %4, %81 ], [ %1, %92 ], [ %1, %91 ], [ %1, %101 ], [ %1, %102 ], [ %1, %104 ], [ %1, %103 ], [ %1, %109 ]
  %97 = phi i32 [ %5, %115 ], [ %5, %114 ], [ %.mux28, %82 ], [ %.mux32, %83 ], [ %.mux36, %84 ], [ %.mux40, %85 ], [ %.mux44, %86 ], [ %.mux48, %87 ], [ %.mux52, %88 ], [ %.mux56, %89 ], [ %.mux60, %90 ], [ %5, %switch.lookup117 ], [ %5, %81 ], [ %2, %92 ], [ %2, %91 ], [ %2, %101 ], [ %2, %102 ], [ %2, %104 ], [ %2, %103 ], [ %2, %109 ]
  %98 = insertvalue { i32, i32, i32 } undef, i32 %95, 0
  %99 = insertvalue { i32, i32, i32 } %98, i32 %96, 1
  %100 = insertvalue { i32, i32, i32 } %99, i32 %97, 2
  ret { i32, i32, i32 } %100

101:                                              ; preds = %90, %89, %88, %87, %86, %85, %84, %83, %82, %81, %92, %91
  switch i8 %7, label %94 [
    i8 1, label %102
    i8 2, label %103
  ]

102:                                              ; preds = %101
  %.not25 = icmp eq i32 %55, 1
  br i1 %.not25, label %104, label %94

103:                                              ; preds = %101
  %.not = icmp eq i32 %55, 2
  br i1 %.not, label %109, label %94

104:                                              ; preds = %102
  %105 = trunc i32 %0 to i8
  %106 = trunc i32 %3 to i8
  %107 = add i8 %105, 1
  %108 = add i8 %106, 1
  %.not26 = icmp ult i8 %108, %107
  br i1 %.not26, label %114, label %94

109:                                              ; preds = %103
  %110 = trunc i32 %0 to i8
  %111 = trunc i32 %3 to i8
  %112 = add i8 %110, 1
  %113 = add i8 %111, 1
  %.not24 = icmp ult i8 %113, %112
  br i1 %.not24, label %115, label %94

114:                                              ; preds = %104
  br label %94

115:                                              ; preds = %109
  br label %94
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe18CapabilitySnapshotV18rasterPresentationAA015EffectiveRasterH0VSgvg"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationVSg) captures(none) initializes((0, 40)) %0, ptr noalias readonly swiftself captures(none) dereferenceable(40) %1) local_unnamed_addr #9 {
entry:
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(40) %0, ptr noundef nonnull align 4 dereferenceable(40) %1, i32 40, i1 false)
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe18CapabilitySnapshotV18rasterPresentationAcA015EffectiveRasterH0VSg_tcfC"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe18CapabilitySnapshotV) captures(none) initializes((0, 40)) %0, ptr noalias readonly captures(none) dereferenceable(40) %1) local_unnamed_addr #9 {
entry:
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(40) %0, ptr noundef nonnull align 4 dereferenceable(40) %1, i32 40, i1 false)
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe18CapabilitySnapshotV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(40) %0, ptr noalias readonly captures(none) dereferenceable(40) %1) local_unnamed_addr #2 {
entry:
  %2 = alloca %T27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV, align 4
  %3 = alloca %T27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV, align 4
  call void @llvm.lifetime.start.p0(i64 40, ptr nonnull %2)
  call void @llvm.lifetime.start.p0(i64 40, ptr nonnull %3)
  %.sroa.410.0..rasterPresentation.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.410.0.copyload = load i32, ptr %.sroa.410.0..rasterPresentation.sroa_idx, align 4
  %.sroa.511.0..rasterPresentation.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 20
  %.sroa.4.0..rasterPresentation1.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.sroa.4.0.copyload = load i32, ptr %.sroa.4.0..rasterPresentation1.sroa_idx, align 4
  %.sroa.5.0..rasterPresentation1.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 20
  %4 = and i32 %.sroa.410.0.copyload, 255
  %5 = icmp eq i32 %4, 2
  %6 = and i32 %.sroa.4.0.copyload, 255
  %7 = icmp eq i32 %6, 2
  br i1 %5, label %9, label %8

8:                                                ; preds = %entry
  br i1 %7, label %13, label %10

9:                                                ; preds = %entry
  br i1 %7, label %12, label %13

10:                                               ; preds = %8
  call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(16) %2, ptr noundef nonnull align 4 dereferenceable(16) %1, i32 16, i1 false)
  %.sroa.0.sroa.5.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 20
  call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(20) %.sroa.0.sroa.5.0..sroa_idx, ptr noundef nonnull align 4 dereferenceable(20) %.sroa.5.0..rasterPresentation1.sroa_idx, i32 20, i1 false)
  %.sroa.0.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %2, i32 16
  store i32 %.sroa.4.0.copyload, ptr %.sroa.0.sroa.4.0..sroa_idx, align 4
  call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(16) %3, ptr noundef nonnull align 4 dereferenceable(16) %0, i32 16, i1 false)
  %.sroa.03.sroa.5.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 20
  call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(20) %.sroa.03.sroa.5.0..sroa_idx, ptr noundef nonnull align 4 dereferenceable(20) %.sroa.511.0..rasterPresentation.sroa_idx, i32 20, i1 false)
  %.sroa.03.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %3, i32 16
  store i32 %.sroa.410.0.copyload, ptr %.sroa.03.sroa.4.0..sroa_idx, align 4
  %11 = call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe27EffectiveRasterPresentationV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias nonnull captures(none) dereferenceable(40) %3, ptr noalias nonnull captures(none) dereferenceable(40) %2)
  br label %13

12:                                               ; preds = %9
  br label %13

13:                                               ; preds = %8, %9, %10, %12
  %14 = phi i1 [ true, %12 ], [ %11, %10 ], [ false, %9 ], [ false, %8 ]
  call void @llvm.lifetime.end.p0(i64 40, ptr nonnull %3)
  call void @llvm.lifetime.end.p0(i64 40, ptr nonnull %2)
  ret i1 %14
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(inaccessiblemem: write)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe29RasterPresentationUnavailableO21__derived_enum_equalsySbAC_ACtFZ"(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5) local_unnamed_addr #12 {
entry:
  %6 = lshr i32 %0, 29
  %7 = trunc nuw nsw i32 %6 to i8
  switch i8 %7, label %33 [
    i8 0, label %34
    i8 1, label %35
    i8 2, label %36
    i8 3, label %37
    i8 4, label %38
    i8 5, label %39
    i8 6, label %8
  ]

8:                                                ; preds = %entry
  %9 = icmp eq i32 %0, -1073741824
  %10 = or i32 %2, %1
  %11 = icmp eq i32 %10, 0
  %12 = and i1 %9, %11
  br i1 %12, label %69, label %13

13:                                               ; preds = %8
  %14 = icmp eq i32 %0, -1073741823
  %15 = and i1 %14, %11
  br i1 %15, label %75, label %16

16:                                               ; preds = %13
  %17 = icmp eq i32 %0, -1073741822
  %18 = and i1 %17, %11
  br i1 %18, label %81, label %19

19:                                               ; preds = %16
  %20 = icmp eq i32 %0, -1073741821
  %21 = and i1 %20, %11
  br i1 %21, label %87, label %22

22:                                               ; preds = %19
  %23 = icmp eq i32 %0, -1073741820
  %24 = and i1 %23, %11
  br i1 %24, label %93, label %25

25:                                               ; preds = %22
  %26 = icmp eq i32 %0, -1073741819
  %27 = and i1 %26, %11
  br i1 %27, label %99, label %28

28:                                               ; preds = %25
  %29 = icmp eq i32 %0, -1073741818
  %30 = and i1 %29, %11
  br i1 %30, label %105, label %31

31:                                               ; preds = %28
  %32 = icmp eq i32 %0, -1073741817
  tail call void @llvm.assume(i1 %32)
  tail call void @llvm.assume(i1 %11)
  %.mask = and i32 %3, -536870912
  %.not = icmp eq i32 %.mask, -1073741824
  br i1 %.not, label %116, label %121

33:                                               ; preds = %entry
  unreachable

34:                                               ; preds = %entry
  %.not39 = icmp ult i32 %3, 536870912
  br i1 %.not39, label %40, label %121

35:                                               ; preds = %entry
  %.mask38 = and i32 %3, -536870912
  %.not37 = icmp eq i32 %.mask38, 536870912
  br i1 %.not37, label %45, label %121

36:                                               ; preds = %entry
  %.mask36 = and i32 %3, -536870912
  %.not35 = icmp eq i32 %.mask36, 1073741824
  br i1 %.not35, label %50, label %121

37:                                               ; preds = %entry
  %.mask34 = and i32 %3, -536870912
  %.not33 = icmp eq i32 %.mask34, 1610612736
  br i1 %.not33, label %55, label %121

38:                                               ; preds = %entry
  %.not31 = icmp slt i32 %3, -1610612736
  br i1 %.not31, label %62, label %121

39:                                               ; preds = %entry
  %.mask30 = and i32 %3, -536870912
  %.not29 = icmp eq i32 %.mask30, -1610612736
  br i1 %.not29, label %111, label %121

40:                                               ; preds = %34
  %41 = xor i32 %3, %0
  %42 = and i32 %41, 255
  %43 = icmp eq i32 %42, 0
  br i1 %43, label %122, label %44

44:                                               ; preds = %40
  br label %122

45:                                               ; preds = %35
  %46 = xor i32 %3, %0
  %47 = and i32 %46, 255
  %48 = icmp eq i32 %47, 0
  br i1 %48, label %122, label %49

49:                                               ; preds = %45
  br label %122

50:                                               ; preds = %36
  %51 = xor i32 %3, %0
  %52 = and i32 %51, 255
  %53 = icmp eq i32 %52, 0
  br i1 %53, label %122, label %54

54:                                               ; preds = %50
  br label %122

55:                                               ; preds = %37
  %56 = xor i32 %3, %0
  %57 = and i32 %56, 255
  %58 = icmp eq i32 %57, 0
  br i1 %58, label %59, label %122

59:                                               ; preds = %55
  %60 = and i32 %56, 65280
  %61 = icmp eq i32 %60, 0
  br label %122

62:                                               ; preds = %38
  %63 = xor i32 %3, %0
  %64 = and i32 %63, 255
  %65 = icmp eq i32 %64, 0
  %66 = icmp eq i32 %1, %4
  %or.cond = select i1 %65, i1 %66, i1 false
  br i1 %or.cond, label %67, label %122

67:                                               ; preds = %62
  %68 = icmp eq i32 %2, %5
  br label %122

69:                                               ; preds = %8
  %.mask28 = and i32 %3, -536870912
  %.not27 = icmp eq i32 %.mask28, -1073741824
  br i1 %.not27, label %70, label %121

70:                                               ; preds = %69
  %71 = icmp eq i32 %3, -1073741824
  %72 = or i32 %5, %4
  %73 = icmp eq i32 %72, 0
  %74 = and i1 %71, %73
  br i1 %74, label %122, label %121

75:                                               ; preds = %13
  %.mask26 = and i32 %3, -536870912
  %.not25 = icmp eq i32 %.mask26, -1073741824
  br i1 %.not25, label %76, label %121

76:                                               ; preds = %75
  %77 = icmp eq i32 %3, -1073741823
  %78 = or i32 %5, %4
  %79 = icmp eq i32 %78, 0
  %80 = and i1 %77, %79
  br i1 %80, label %122, label %121

81:                                               ; preds = %16
  %.mask24 = and i32 %3, -536870912
  %.not23 = icmp eq i32 %.mask24, -1073741824
  br i1 %.not23, label %82, label %121

82:                                               ; preds = %81
  %83 = icmp eq i32 %3, -1073741822
  %84 = or i32 %5, %4
  %85 = icmp eq i32 %84, 0
  %86 = and i1 %83, %85
  br i1 %86, label %122, label %121

87:                                               ; preds = %19
  %.mask22 = and i32 %3, -536870912
  %.not21 = icmp eq i32 %.mask22, -1073741824
  br i1 %.not21, label %88, label %121

88:                                               ; preds = %87
  %89 = icmp eq i32 %3, -1073741821
  %90 = or i32 %5, %4
  %91 = icmp eq i32 %90, 0
  %92 = and i1 %89, %91
  br i1 %92, label %122, label %121

93:                                               ; preds = %22
  %.mask20 = and i32 %3, -536870912
  %.not19 = icmp eq i32 %.mask20, -1073741824
  br i1 %.not19, label %94, label %121

94:                                               ; preds = %93
  %95 = icmp eq i32 %3, -1073741820
  %96 = or i32 %5, %4
  %97 = icmp eq i32 %96, 0
  %98 = and i1 %95, %97
  br i1 %98, label %122, label %121

99:                                               ; preds = %25
  %.mask18 = and i32 %3, -536870912
  %.not17 = icmp eq i32 %.mask18, -1073741824
  br i1 %.not17, label %100, label %121

100:                                              ; preds = %99
  %101 = icmp eq i32 %3, -1073741819
  %102 = or i32 %5, %4
  %103 = icmp eq i32 %102, 0
  %104 = and i1 %101, %103
  br i1 %104, label %122, label %121

105:                                              ; preds = %28
  %.mask16 = and i32 %3, -536870912
  %.not15 = icmp eq i32 %.mask16, -1073741824
  br i1 %.not15, label %106, label %121

106:                                              ; preds = %105
  %107 = icmp eq i32 %3, -1073741818
  %108 = or i32 %5, %4
  %109 = icmp eq i32 %108, 0
  %110 = and i1 %107, %109
  br i1 %110, label %122, label %121

111:                                              ; preds = %39
  %112 = xor i32 %3, %0
  %113 = and i32 %112, 255
  %114 = icmp eq i32 %113, 0
  br i1 %114, label %122, label %115

115:                                              ; preds = %111
  br label %122

116:                                              ; preds = %31
  %117 = icmp eq i32 %3, -1073741817
  %118 = or i32 %5, %4
  %119 = icmp eq i32 %118, 0
  %120 = and i1 %117, %119
  br i1 %120, label %122, label %121

121:                                              ; preds = %31, %116, %39, %105, %106, %99, %100, %93, %94, %87, %88, %81, %82, %75, %76, %69, %70, %38, %37, %36, %35, %34
  br label %122

122:                                              ; preds = %116, %111, %106, %100, %94, %88, %82, %76, %70, %62, %67, %55, %59, %50, %45, %40, %44, %49, %54, %115, %121
  %123 = phi i1 [ false, %121 ], [ false, %115 ], [ false, %54 ], [ false, %49 ], [ false, %44 ], [ true, %40 ], [ true, %45 ], [ true, %50 ], [ %61, %59 ], [ false, %55 ], [ %68, %67 ], [ false, %62 ], [ true, %70 ], [ true, %76 ], [ true, %82 ], [ true, %88 ], [ true, %94 ], [ true, %100 ], [ true, %106 ], [ true, %111 ], [ true, %116 ]
  ret i1 %123
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO15requirementSizes6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 25
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO17requirementStrides6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 28
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO20requirementAlignments6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO15realizationSizes6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 24
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO17realizationStrides6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 24
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO20realizationAlignments6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO11backendSizes6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 48
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO13backendStrides6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 48
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO16backendAlignments6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO11surfaceSizes6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 20
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO13surfaceStrides6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 20
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO16surfaceAlignments6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO10policySizes6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 16
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO12policyStrides6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 16
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO15policyAlignments6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO17contributionsSizes6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 93
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO19contributionsStrides6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 96
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO22contributionsAlignments6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO13workspaceSizes6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 52
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO15workspaceStrides6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 52
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO18workspaceAlignments6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO13effectiveSizes6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 40
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO15effectiveStrides6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 40
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO18effectiveAlignments6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO15unavailableSizes6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 12
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO17unavailableStrides6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 12
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO20unavailableAlignments6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO12snapshotSizes6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 40
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO14snapshotStrides6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 40
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e27GiftUICapabilityLayoutProbeAAO17snapshotAlignments6UInt32VyFZ"() local_unnamed_addr #14 {
entry:
  ret i32 4
}

; Function Attrs: minsize nounwind optsize sspreq
define weak_odr protected swiftcc { ptr, ptr } @swift_allocBox(ptr %0) local_unnamed_addr #15 {
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
  tail call void @llvm.trap() #24
  unreachable

24:                                               ; preds = %10
  call void @llvm.trap() #24
  unreachable
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32) #7

; Function Attrs: minsize nofree nounwind optsize
declare i32 @posix_memalign(ptr, i32, i32) local_unnamed_addr #16

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc { ptr, ptr } @swift_makeBoxUnique(ptr %0, ptr %1, i32 %2) local_unnamed_addr #17 {
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
  %call1.i = tail call ptr %21(ptr noundef %19, ptr noundef %10, ptr noundef %1) #25
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
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden void @swift_releaseBox(ptr %0) local_unnamed_addr #17 {
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
  tail call void %20(ptr noundef nonnull %add.ptr.i.i, ptr noundef %17) #25
  br label %21

21:                                               ; preds = %11, %2, %15
  ret void

22:                                               ; preds = %entry
  tail call void @llvm.trap() #24
  unreachable

23:                                               ; preds = %7
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocBox(ptr %0) local_unnamed_addr #17 {
entry:
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize mustprogress nounwind optsize willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr noundef captures(none)) local_unnamed_addr #18

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_allocEmptyBox() local_unnamed_addr #17 {
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
define weak_odr protected ptr @swift_allocObject(ptr %0, i32 %1, i32 %2) local_unnamed_addr #17 {
entry:
  %3 = tail call swiftcc ptr @"$es17swift_allocObject8metadata12requiredSize0E13AlignmentMaskSpys04HeapC0VGSpys13ClassMetadataVG_S2itF"(ptr %0, i32 %1, i32 %2)
  ret ptr %3
}

; Function Attrs: minsize nounwind optsize sspreq
define linkonce_odr hidden swiftcc ptr @"$es17swift_allocObject8metadata12requiredSize0E13AlignmentMaskSpys04HeapC0VGSpys13ClassMetadataVG_S2itF"(ptr %0, i32 %1, i32 %2) local_unnamed_addr #15 {
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
  tail call void @llvm.trap() #24
  unreachable

18:                                               ; preds = %10
  call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_allocObjectTyped(ptr %0, i32 %1, i32 %2, i64 %3) local_unnamed_addr #17 {
entry:
  %4 = tail call swiftcc ptr @"$es17swift_allocObject8metadata12requiredSize0E13AlignmentMaskSpys04HeapC0VGSpys13ClassMetadataVG_S2itF"(ptr %0, i32 %1, i32 %2)
  ret ptr %4
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_initStackObject(ptr %0, ptr %1) local_unnamed_addr #17 {
entry:
  store ptr %0, ptr %1, align 4, !tbaa !16
  %.refcount = getelementptr inbounds nuw i8, ptr %1, i32 4
  store i32 -2147483647, ptr %.refcount, align 4
  ret ptr %1
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_initStaticObject(ptr %0, ptr %1) local_unnamed_addr #17 {
entry:
  store ptr %0, ptr %1, align 4, !tbaa !16
  %.refcount = getelementptr inbounds nuw i8, ptr %1, i32 4
  store i32 -1, ptr %.refcount, align 4
  ret ptr %1
}

; Function Attrs: minsize nounwind optsize
define private void @0(ptr %0, i32 %1, i32 %2) local_unnamed_addr #17 {
entry:
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocClassInstance(ptr %0, i32 %1, i32 %2) local_unnamed_addr #17 {
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
define weak_odr protected void @swift_deallocPartialClassInstance(ptr %0, ptr %1, i32 %2, i32 %3) local_unnamed_addr #17 {
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
  tail call swiftcc void %8(ptr noundef nonnull swiftself %0) #25
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
define weak_odr protected ptr @swift_slowAlloc(i32 %0, i32 %1) local_unnamed_addr #15 {
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
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc void @swift_willThrow(ptr swiftself %0, ptr noalias swifterror captures(none) dereferenceable(4) %1) local_unnamed_addr #17 {
entry:
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc void @swift_errorInMain(ptr %0) local_unnamed_addr #17 {
entry:
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc void @swift_unexpectedError(ptr %0, ptr %1, i32 %2, i1 %3, i32 %4) local_unnamed_addr #17 {
entry:
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_release_n(ptr %0, i32 %1) local_unnamed_addr #17 {
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
  tail call swiftcc void %21(ptr noundef nonnull swiftself %0) #25
  br label %22

22:                                               ; preds = %14, %entry, %3, %18
  ret void

23:                                               ; preds = %8
  tail call void @llvm.trap() #24
  unreachable

24:                                               ; preds = %10
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_setDeallocating(ptr %0) local_unnamed_addr #17 {
entry:
  ret void
}

; Function Attrs: minsize nounwind optsize
define private ptr @1(ptr %0, i32 %1) local_unnamed_addr #17 {
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
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_bridgeObjectRelease_n(ptr %0, i32 %1) local_unnamed_addr #17 {
entry:
  tail call void @swift_release_n(ptr %0, i32 %1)
  ret void
}

; Function Attrs: minsize nounwind optsize
define private ptr @2(ptr %0) local_unnamed_addr #17 {
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
define weak_odr protected void @swift_bridgeObjectRelease(ptr %0) local_unnamed_addr #17 {
entry:
  tail call void @swift_release_n(ptr %0, i32 1)
  ret void
}

; Function Attrs: minsize nounwind optsize
define private void @3(ptr %0) local_unnamed_addr #17 {
  tail call void @swift_releaseTm(ptr %0) #17
  ret void
}

; Function Attrs: minsize nounwind optsize
define internal void @swift_releaseTm(ptr %0) local_unnamed_addr #17 {
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
  tail call swiftcc void %18(ptr noundef nonnull swiftself %0) #25
  br label %19

19:                                               ; preds = %11, %entry, %2, %15
  ret void

20:                                               ; preds = %7
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected zeroext i1 @swift_isUniquelyReferenced_native(ptr %0) local_unnamed_addr #17 {
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
define weak_odr protected zeroext i1 @swift_isUniquelyReferenced_nonNull_native(ptr %0) local_unnamed_addr #17 {
entry:
  %1 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %2 = load atomic i32, ptr %1 acquire, align 4
  %3 = icmp eq i32 %2, 1
  ret i1 %3
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected zeroext i1 @swift_isEscapingClosureAtFileLocation(ptr %0, ptr %1, i32 %2, i32 %3, i32 %4, i32 %5) local_unnamed_addr #17 {
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
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_dynamicCastClass(ptr %0, ptr %1) local_unnamed_addr #17 {
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
define weak_odr protected ptr @swift_dynamicCastClassUnconditional(ptr %0, ptr %1, ptr %2, i32 %3, i32 %4) local_unnamed_addr #17 {
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
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected zeroext i1 @swift_dynamicCast(ptr %0, ptr %1, ptr %2, ptr %3, i32 %4) local_unnamed_addr #17 {
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
  tail call void %15(ptr noundef %1, ptr noundef %2) #25
  br label %16

16:                                               ; preds = %.sink.split, %12, %9, %entry
  %17 = phi i1 [ true, %entry ], [ true, %9 ], [ false, %12 ], [ %.ph, %.sink.split ]
  ret i1 %17

18:                                               ; preds = %10
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc i8 @"$es7tryCast33_8BFEAB69C69C8B87ED137407D82370D4LL3dst0J8Metadata3src0lK013takeOnSuccesss07DynamicB6ResultABLLOSv_S3VSbtF"(ptr %0, ptr %1, ptr %2, ptr %3, i1 %4) local_unnamed_addr #17 {
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
  %call1.i = tail call ptr %40(ptr noundef %0, ptr noundef %.tr10, ptr noundef %.tr11) #25
  br label %.loopexit

41:                                               ; preds = %37
  %initializeWithTakeFn.i = getelementptr inbounds nuw i8, ptr %38, i32 16
  %42 = load ptr, ptr %initializeWithTakeFn.i, align 4, !tbaa !22
  %call1.i8 = tail call ptr %42(ptr noundef %0, ptr noundef %.tr10, ptr noundef %.tr11) #25
  br label %.loopexit

.loopexit:                                        ; preds = %6, %6, %6, %26, %18, %24, %19, %8, %11, %41, %39
  %43 = phi i8 [ 1, %39 ], [ 2, %41 ], [ 0, %11 ], [ 0, %8 ], [ 1, %19 ], [ 1, %24 ], [ 2, %18 ], [ 0, %26 ], [ 0, %6 ], [ 0, %6 ], [ 0, %6 ]
  ret i8 %43
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc i8 @"$es12MetadataKindO8metadataABSgSV_tcfC"(ptr %0) local_unnamed_addr #17 {
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
define linkonce_odr hidden swiftcc i1 @"$es12MetadataKindO21__derived_enum_equalsySbAB_ABtFZ"(i8 %0, i8 %1) local_unnamed_addr #17 {
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
define linkonce_odr hidden swiftcc { ptr, ptr } @"$es29ExistentialTypeRepresentationO7projectySV8metadata_SV5valuetSVF"(ptr %0, i8 %1) local_unnamed_addr #17 {
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
define weak_odr protected void @swift_once(ptr %0, ptr %1, ptr %2) local_unnamed_addr #17 {
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
  tail call void %1(ptr %2) #26
  store atomic i32 -1, ptr %0 release, align 4
  br label %.loopexit

.loopexit:                                        ; preds = %.preheader, %entry, %10
  ret void
}

; Function Attrs: minsize nounwind optsize sspreq
define weak_odr protected ptr @swift_coroFrameAlloc(i32 %0, i64 %1) local_unnamed_addr #15 {
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
define weak_odr protected void @swift_deletedMethodError() local_unnamed_addr #17 {
entry:
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc { ptr, ptr } @swift_allocError(ptr %0, ptr %1, ptr %2, i1 %3) local_unnamed_addr #17 {
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
  %call1.i5 = tail call ptr %25(ptr noundef nonnull %22, ptr noundef nonnull %2, ptr noundef nonnull %0) #25
  br label %26

26:                                               ; preds = %.sink.split, %17
  %27 = insertvalue { ptr, ptr } undef, ptr %19, 0
  %28 = insertvalue { ptr, ptr } %27, ptr %22, 1
  ret { ptr, ptr } %28

29:                                               ; preds = %entry
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc void @"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvpfiyBpcfU_"(ptr %0) #17 {
entry:
  ret void
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc void @_swift_embedded_error_destroy_impl(ptr %0) #17 {
entry:
  %1 = tail call swiftcc { ptr, ptr, ptr } @"$es17_errorBoxContentsySV4type_SV11conformanceSV5valuetSVF"(ptr %0)
  %2 = extractvalue { ptr, ptr, ptr } %1, 0
  %3 = extractvalue { ptr, ptr, ptr } %1, 2
  %arrayidx.i.i = getelementptr inbounds i8, ptr %2, i32 -4
  %4 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !7
  %destroyFn.i = getelementptr inbounds nuw i8, ptr %4, i32 4
  %5 = load ptr, ptr %destroyFn.i, align 4, !tbaa !19
  tail call void %5(ptr noundef %3, ptr noundef %2) #25
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc { ptr, ptr, ptr } @"$es17_errorBoxContentsySV4type_SV11conformanceSV5valuetSVF"(ptr %0) local_unnamed_addr #17 {
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
define weak_odr protected void @swift_deallocError(ptr %0, ptr %1) local_unnamed_addr #17 {
entry:
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_getErrorValue(ptr %0, ptr %1, ptr %2) local_unnamed_addr #17 {
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
define weak_odr protected i32 @_swift_exceptionPersonality(i32 %0, i32 %1, i64 %2, ptr %3, ptr %4) #17 {
entry:
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize noinline nounwind optsize
define weak_odr protected void @swift_clearSensitive(ptr %0, i32 %1) local_unnamed_addr #19 {
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
  tail call void @llvm.trap() #24
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected i32 @swift_retainCount(ptr %0) local_unnamed_addr #17 {
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

; Function Attrs: inlinehint nounwind optsize
define internal swiftcc void @_swift_embedded_error_box_destroy(ptr noundef swiftself %object) #20 {
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
  tail call void %8(ptr noundef %7, ptr noundef %1) #25
  tail call void @free(ptr %object)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #21

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.ctpop.i8(i8) #22

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i16 @llvm.umin.i16(i16, i16) #22

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.umin.i32(i32, i32) #22

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smax.i32(i32, i32) #22

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #23

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i32(ptr writeonly captures(none), i8, i32, i1 immarg) #23

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e27GiftUICapabilityLayoutProbe19CapabilityByteCountV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) local_unnamed_addr #0 {
  %3 = tail call swiftcc i1 @"$e27GiftUICapabilityLayoutProbe16CapabilityExtentV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) #0
  ret i1 %3
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_retain(ptr %0) local_unnamed_addr #17 {
  %2 = tail call ptr @2(ptr %0) #17
  ret ptr %2
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_bridgeObjectRetain(ptr %0) local_unnamed_addr #17 {
  %2 = tail call ptr @2(ptr %0) #17
  ret ptr %2
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_errorRetain(ptr %0) local_unnamed_addr #17 {
  %2 = tail call ptr @2(ptr %0) #17
  ret ptr %2
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_retain_n(ptr %0, i32 %1) local_unnamed_addr #17 {
  %3 = tail call ptr @1(ptr %0, i32 %1) #17
  ret ptr %3
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_bridgeObjectRetain_n(ptr %0, i32 %1) local_unnamed_addr #17 {
  %3 = tail call ptr @1(ptr %0, i32 %1) #17
  ret ptr %3
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocUninitializedObject(ptr %0, i32 %1, i32 %2) local_unnamed_addr #17 {
  tail call void @0(ptr %0, i32 %1, i32 %2) #17
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocObject(ptr %0, i32 %1, i32 %2) local_unnamed_addr #17 {
  tail call void @0(ptr %0, i32 %1, i32 %2) #17
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_slowDealloc(ptr %0, i32 %1, i32 %2) local_unnamed_addr #17 {
  tail call void @0(ptr %0, i32 %1, i32 %2) #17
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceV15secondCandidateAA010NormalizedefJ0VSgvpfi"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe37NormalizedRasterPresentationCandidateVSg) captures(none) initializes((0, 24)) %0) local_unnamed_addr #3 {
  tail call swiftcc void @"$e27GiftUICapabilityLayoutProbe35RasterPresentationResolverWorkspaceV14firstCandidateAA010NormalizedefJ0VSgvpfi"(ptr noalias writeonly sret(%T27GiftUICapabilityLayoutProbe37NormalizedRasterPresentationCandidateVSg) captures(none) initializes((0, 24)) %0) #3
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_release(ptr %0) local_unnamed_addr #17 {
  tail call void @3(ptr %0) #17
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_errorRelease(ptr %0) local_unnamed_addr #17 {
  tail call void @3(ptr %0) #17
  ret void
}

attributes #0 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #3 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #4 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { minsize nounwind optsize memory(argmem: write, inaccessiblemem: write) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #6 = { minsize nounwind optsize memory(inaccessiblemem: write) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #7 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #8 = { cold noreturn nounwind memory(inaccessiblemem: write) }
attributes #9 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #10 = { minsize nounwind optsize memory(argmem: readwrite, inaccessiblemem: write) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #11 = { minsize nounwind optsize memory(argmem: read, inaccessiblemem: write) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #12 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(inaccessiblemem: write) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #13 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read, inaccessiblemem: write) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #14 = { minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #15 = { minsize nounwind optsize sspreq "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #16 = { minsize nofree nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #17 = { minsize nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #18 = { minsize mustprogress nounwind optsize willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #19 = { minsize noinline nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #20 = { inlinehint nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #21 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #22 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #23 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #24 = { nomerge }
attributes #25 = { nounwind optsize }
attributes #26 = { nounwind }

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
