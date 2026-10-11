; ModuleID = '/Users/eugene/work/GiftUI/.build/rfc-014-swift64/resource-regression/003-nrf-layout/semantics/core-layout.ll'
source_filename = "/Users/eugene/work/GiftUI/.build/rfc-014-swift64/resource-regression/003-nrf-layout/semantics/core-layout.ll"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7em-none-none-eabihf"

%T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV = type <{ %Ts6UInt16V }>
%Ts6UInt16V = type <{ i16 }>
%Ts5UInt8V = type <{ i8 }>
%T28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV = type <{ %Ts5UInt8V }>
%TSi = type <{ i32 }>
%TSb = type <{ i1 }>
%swift.function = type { ptr, ptr }
%T28GiftUIFailureCoreLayoutProbe0aB11AnnotationsV = type <{ %Ts5UInt8V, [3 x i8], %T28GiftUIFailureCoreLayoutProbe0aB10AnnotationV, %T28GiftUIFailureCoreLayoutProbe0aB10AnnotationV }>
%T28GiftUIFailureCoreLayoutProbe0aB10AnnotationV = type <{ %Ts6UInt16V, [2 x i8], %Ts6UInt32V }>
%Ts6UInt32V = type <{ i32 }>
%T28GiftUIFailureCoreLayoutProbe0A19UIOperationalHealthV = type <{ %T28GiftUIFailureCoreLayoutProbe0A24UIOperationalHealthStateO, [3 x i8], %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V, %TSb }>
%T28GiftUIFailureCoreLayoutProbe0A24UIOperationalHealthStateO = type <{ i8 }>
%T28GiftUIFailureCoreLayoutProbe0A18UIDiagnosticRecordV = type <{ %T28GiftUIFailureCoreLayoutProbe0A16UIDiagnosticKindO, %T28GiftUIFailureCoreLayoutProbe0A20UIDiagnosticSeverityO, %Ts6UInt16V, %T28GiftUIFailureCoreLayoutProbe0aB6OriginO, %T28GiftUIFailureCoreLayoutProbe0A15UIAffectedScopeO, %Ts6UInt16V, %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V }>
%T28GiftUIFailureCoreLayoutProbe0A16UIDiagnosticKindO = type <{ i8 }>
%T28GiftUIFailureCoreLayoutProbe0A20UIDiagnosticSeverityO = type <{ i8 }>
%T28GiftUIFailureCoreLayoutProbe0aB6OriginO = type <{ i8 }>
%T28GiftUIFailureCoreLayoutProbe0A15UIAffectedScopeO = type <{ i8 }>
%TSvSg = type <{ [4 x i8] }>

@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV24unknownProducerConditionACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV zeroinitializer, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV12invalidValueACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 1 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV18arithmeticOverflowACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 2 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV17capacityExhaustedACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 3 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV15invalidIdentityACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 4 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV17invalidProvenanceACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 5 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV12invalidPhaseACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 6 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV19reentrancyViolationACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 7 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV27requiredFacilityUnavailableACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 8 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV19nonRetryableRefusalACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 9 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV18invariantViolationACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 10 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterMalformedRequirementACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 12 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterDuplicateContributorACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 13 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV24rasterMissingContributorACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 14 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV27rasterMalformedContributionACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 15 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterInsufficientCapacityACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 16 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterOperationSetMismatchACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 17 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV29rasterOperationStreamMismatchACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 18 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV27rasterLogicalExtentOverflowACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 19 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV30rasterUnsupportedLogicalExtentACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 20 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV36rasterNoCommonCanonicalPixelEncodingACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 21 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV36rasterIncompatibleSubmissionLifetimeACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 22 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV35rasterIncompatibleSubmissionHandoffACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 23 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV38rasterPolicyHasNoConformingRealizationACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 24 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV23rasterByteCountOverflowACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV <{ %Ts6UInt16V <{ i16 25 }> }>, align 2
@"$e28GiftUIFailureCoreLayoutProbe0aB11AnnotationsV8capacitys5UInt8VvpZ" = protected constant %Ts5UInt8V <{ i8 2 }>, align 1
@"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV17continueOperation_Wz" = protected local_unnamed_addr global i32 0, align 4
@"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV17continueOperationACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV <{ %Ts5UInt8V <{ i8 1 }> }>, align 1
@"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV17requestPacedRetry_Wz" = protected local_unnamed_addr global i32 0, align 4
@"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV17requestPacedRetryACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV <{ %Ts5UInt8V <{ i8 2 }> }>, align 1
@"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV23markFacilityUnavailable_Wz" = protected local_unnamed_addr global i32 0, align 4
@"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV23markFacilityUnavailableACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV <{ %Ts5UInt8V <{ i8 4 }> }>, align 1
@"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV20quiesceAffectedScope_Wz" = protected local_unnamed_addr global i32 0, align 4
@"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV20quiesceAffectedScopeACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV <{ %Ts5UInt8V <{ i8 8 }> }>, align 1
@"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV15invokeFatalHook_Wz" = protected local_unnamed_addr global i32 0, align 4
@"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV15invokeFatalHookACvpZ" = protected constant %T28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV <{ %Ts5UInt8V <{ i8 16 }> }>, align 1
@"$es16_emptyBoxStorageSi_Sitvp" = linkonce_odr protected global <{ %TSi, %TSi }> <{ %TSi zeroinitializer, %TSi <{ i32 -1 }> }>, align 4
@_swift_embedded_error_metadata_storage = weak_odr protected global <{ i32, i32, i32 }> zeroinitializer, align 4
@"$es25_errorMetadataInitialized33_21ED9D60359C2E63A6128CFAED697BD0LLSbvp" = linkonce_odr protected local_unnamed_addr global %TSb zeroinitializer, align 1
@"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvp" = linkonce_odr protected local_unnamed_addr global %swift.function { ptr @"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvpfiyBpcfU_", ptr null }, align 4
@_swift1_autolink_entries = private constant [0 x i8] zeroinitializer, section ".swift1_autolink_entries", no_sanitize_address, align 4
@llvm.used = appending global [2 x ptr] [ptr @_swift1_autolink_entries, ptr @_swift_exceptionPersonality], section "llvm.metadata"

@"$e28GiftUIFailureCoreLayoutProbe0A21UIResidualPolicyInputV7outcomeAA0A9UIOutcomeOyytGvg" = alias void (), ptr @_swift_dead_method_stub
@"$e28GiftUIFailureCoreLayoutProbe0A21UIResidualPolicyInputV7contextxvg" = alias void (), ptr @_swift_dead_method_stub
@"$e28GiftUIFailureCoreLayoutProbe0A21UIResidualPolicyInputV7allowedAA0A21UIAllowedDispositionsVvg" = alias void (), ptr @_swift_dead_method_stub
@"$e28GiftUIFailureCoreLayoutProbe0A21UIResidualPolicyInputV14attemptOrdinals5UInt8Vvg" = alias void (), ptr @_swift_dead_method_stub
@"$e28GiftUIFailureCoreLayoutProbe0A21UIResidualPolicyInputV12attemptLimits5UInt8Vvg" = alias void (), ptr @_swift_dead_method_stub
@"$e28GiftUIFailureCoreLayoutProbe0A21UIResidualPolicyInputV7outcome7context7allowed14attemptOrdinal0L5LimitACyxGSgAA0A9UIOutcomeOyytG_xAA0A21UIAllowedDispositionsVs5UInt8VAQtcfC" = alias void (), ptr @_swift_dead_method_stub

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV8rawValues6UInt16Vvg"(i16 returned %0) local_unnamed_addr #0 {
entry:
  ret i16 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV8rawValueACs6UInt16V_tcfC"(i16 returned %0) local_unnamed_addr #0 {
entry:
  ret i16 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV24unknownProducerConditionACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV24unknownProducerConditionACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV24unknownProducerConditionACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV12invalidValueACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV12invalidValueACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV12invalidValueACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV18arithmeticOverflowACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV18arithmeticOverflowACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV18arithmeticOverflowACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV17capacityExhaustedACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV17capacityExhaustedACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV17capacityExhaustedACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 3
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV15invalidIdentityACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV15invalidIdentityACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV15invalidIdentityACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 4
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV17invalidProvenanceACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV17invalidProvenanceACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV17invalidProvenanceACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 5
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV12invalidPhaseACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV12invalidPhaseACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV12invalidPhaseACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 6
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV19reentrancyViolationACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV19reentrancyViolationACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV19reentrancyViolationACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 7
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV27requiredFacilityUnavailableACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV27requiredFacilityUnavailableACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV27requiredFacilityUnavailableACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 8
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV19nonRetryableRefusalACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV19nonRetryableRefusalACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV19nonRetryableRefusalACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 9
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV18invariantViolationACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV18invariantViolationACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV18invariantViolationACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 10
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterMalformedRequirementACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterMalformedRequirementACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterMalformedRequirementACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 12
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterDuplicateContributorACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterDuplicateContributorACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterDuplicateContributorACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 13
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV24rasterMissingContributorACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV24rasterMissingContributorACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV24rasterMissingContributorACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 14
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV27rasterMalformedContributionACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV27rasterMalformedContributionACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV27rasterMalformedContributionACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 15
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterInsufficientCapacityACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterInsufficientCapacityACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterInsufficientCapacityACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 16
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterOperationSetMismatchACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterOperationSetMismatchACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV26rasterOperationSetMismatchACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 17
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV29rasterOperationStreamMismatchACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV29rasterOperationStreamMismatchACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV29rasterOperationStreamMismatchACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 18
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV27rasterLogicalExtentOverflowACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV27rasterLogicalExtentOverflowACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV27rasterLogicalExtentOverflowACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 19
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV30rasterUnsupportedLogicalExtentACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV30rasterUnsupportedLogicalExtentACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV30rasterUnsupportedLogicalExtentACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 20
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV36rasterNoCommonCanonicalPixelEncodingACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV36rasterNoCommonCanonicalPixelEncodingACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV36rasterNoCommonCanonicalPixelEncodingACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 21
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV36rasterIncompatibleSubmissionLifetimeACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV36rasterIncompatibleSubmissionLifetimeACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV36rasterIncompatibleSubmissionLifetimeACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 22
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV35rasterIncompatibleSubmissionHandoffACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV35rasterIncompatibleSubmissionHandoffACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV35rasterIncompatibleSubmissionHandoffACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 23
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV38rasterPolicyHasNoConformingRealizationACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV38rasterPolicyHasNoConformingRealizationACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV38rasterPolicyHasNoConformingRealizationACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 24
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV23rasterByteCountOverflowACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV23rasterByteCountOverflowACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i16 @"$e28GiftUIFailureCoreLayoutProbe0A13UIConditionIDV23rasterByteCountOverflowACvgZ"() local_unnamed_addr #0 {
entry:
  ret i16 25
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i16 @"$e28GiftUIFailureCoreLayoutProbe0aB4FactV9conditionAA0A13UIConditionIDVvg"(i32 %0, i8 %1) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i32 %0 to i16
  ret i16 %temp-coercion.coerced.sroa.0.0.extract.trunc
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #1

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0aB4FactV6originAA0aB6OriginOvg"(i32 %0, i8 %1) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.0.2.extract.shift = lshr i32 %0, 16
  %temp-coercion.coerced.sroa.0.2.extract.trunc = trunc i32 %temp-coercion.coerced.sroa.0.2.extract.shift to i8
  ret i8 %temp-coercion.coerced.sroa.0.2.extract.trunc
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0aB4FactV13affectedScopeAA0a10UIAffectedH0Ovg"(i32 %0, i8 %1) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.0.3.extract.shift = lshr i32 %0, 24
  %temp-coercion.coerced.sroa.0.3.extract.trunc = trunc nuw i32 %temp-coercion.coerced.sroa.0.3.extract.shift to i8
  ret i8 %temp-coercion.coerced.sroa.0.3.extract.trunc
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0aB4FactV11containmentAA0A13UIContainmentOvg"(i32 %0, i8 returned %1) local_unnamed_addr #0 {
entry:
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i8 } @"$e28GiftUIFailureCoreLayoutProbe0aB4FactV9condition6origin13affectedScope11containmentAcA0A13UIConditionIDV_AA0aB6OriginOAA0a10UIAffectedJ0OAA0A13UIContainmentOtcfC"(i16 %0, i8 %1, i8 %2, i8 %3) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.0.0.insert.ext = zext i16 %0 to i32
  %temp-coercion.coerced.sroa.0.2.insert.ext = zext i8 %1 to i32
  %temp-coercion.coerced.sroa.0.2.insert.shift = shl nuw nsw i32 %temp-coercion.coerced.sroa.0.2.insert.ext, 16
  %temp-coercion.coerced.sroa.0.2.insert.insert = or disjoint i32 %temp-coercion.coerced.sroa.0.2.insert.shift, %temp-coercion.coerced.sroa.0.0.insert.ext
  %temp-coercion.coerced.sroa.0.3.insert.ext = zext i8 %2 to i32
  %temp-coercion.coerced.sroa.0.3.insert.shift = shl nuw i32 %temp-coercion.coerced.sroa.0.3.insert.ext, 24
  %temp-coercion.coerced.sroa.0.3.insert.insert = or disjoint i32 %temp-coercion.coerced.sroa.0.2.insert.insert, %temp-coercion.coerced.sroa.0.3.insert.shift
  %4 = insertvalue { i32, i8 } undef, i32 %temp-coercion.coerced.sroa.0.3.insert.insert, 0
  %5 = insertvalue { i32, i8 } %4, i8 %3, 1
  ret { i32, i8 } %5
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e28GiftUIFailureCoreLayoutProbe0aB4FactV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i8 %1, i32 %2, i8 %3) local_unnamed_addr #0 {
entry:
  %or.cond8 = icmp eq i32 %0, %2
  %4 = icmp eq i8 %1, %3
  %5 = select i1 %or.cond8, i1 %4, i1 false
  ret i1 %5
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0A17UIOperationalFactV4kindAA0aF4KindOvg"(i32 %0) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i32 %0 to i8
  ret i8 %temp-coercion.coerced.sroa.0.0.extract.trunc
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0A17UIOperationalFactV6originAA0aB6OriginOvg"(i32 %0) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.3.0.extract.shift = lshr i32 %0, 8
  %temp-coercion.coerced.sroa.3.0.extract.trunc = trunc i32 %temp-coercion.coerced.sroa.3.0.extract.shift to i8
  ret i8 %temp-coercion.coerced.sroa.3.0.extract.trunc
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0A17UIOperationalFactV13affectedScopeAA0a10UIAffectedI0Ovg"(i32 %0) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.3.0.extract.shift = lshr i32 %0, 16
  %temp-coercion.coerced.sroa.3.0.extract.trunc = trunc i32 %temp-coercion.coerced.sroa.3.0.extract.shift to i8
  ret i8 %temp-coercion.coerced.sroa.3.0.extract.trunc
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc range(i32 0, 16777216) i32 @"$e28GiftUIFailureCoreLayoutProbe0A17UIOperationalFactV4kind6origin13affectedScopeAcA0aF4KindO_AA0aB6OriginOAA0a10UIAffectedK0OtcfC"(i8 %0, i8 %1, i8 %2) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.5.0.insert.ext = zext i8 %2 to i32
  %temp-coercion.coerced.sroa.5.0.insert.shift = shl nuw nsw i32 %temp-coercion.coerced.sroa.5.0.insert.ext, 16
  %temp-coercion.coerced.sroa.4.0.insert.ext = zext i8 %1 to i32
  %temp-coercion.coerced.sroa.4.0.insert.shift = shl nuw nsw i32 %temp-coercion.coerced.sroa.4.0.insert.ext, 8
  %temp-coercion.coerced.sroa.4.0.insert.insert = or disjoint i32 %temp-coercion.coerced.sroa.5.0.insert.shift, %temp-coercion.coerced.sroa.4.0.insert.shift
  %temp-coercion.coerced.sroa.0.0.insert.ext = zext i8 %0 to i32
  %temp-coercion.coerced.sroa.0.0.insert.insert = or disjoint i32 %temp-coercion.coerced.sroa.4.0.insert.insert, %temp-coercion.coerced.sroa.0.0.insert.ext
  ret i32 %temp-coercion.coerced.sroa.0.0.insert.insert
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e28GiftUIFailureCoreLayoutProbe0A17UIOperationalFactV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) local_unnamed_addr #0 {
entry:
  %2 = xor i32 %1, %0
  %3 = and i32 %2, 16777215
  %4 = icmp eq i32 %3, 0
  ret i1 %4
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i16 @"$e28GiftUIFailureCoreLayoutProbe0aB10AnnotationV3keys6UInt16Vvg"(i16 returned %0, i32 %1) local_unnamed_addr #0 {
entry:
  ret i16 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i32 @"$e28GiftUIFailureCoreLayoutProbe0aB10AnnotationV5values6UInt32Vvg"(i16 %0, i32 returned %1) local_unnamed_addr #0 {
entry:
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i16, i32 } @"$e28GiftUIFailureCoreLayoutProbe0aB10AnnotationV3key5valueACs6UInt16V_s6UInt32VtcfC"(i16 %0, i32 %1) local_unnamed_addr #0 {
entry:
  %2 = insertvalue { i16, i32 } undef, i16 %0, 0
  %3 = insertvalue { i16, i32 } %2, i32 %1, 1
  ret { i16, i32 } %3
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e28GiftUIFailureCoreLayoutProbe0aB10AnnotationV23__derived_struct_equalsySbAC_ACtFZ"(i16 %0, i32 %1, i16 %2, i32 %3) local_unnamed_addr #0 {
entry:
  %4 = icmp eq i16 %0, %2
  %5 = icmp eq i32 %1, %3
  %6 = select i1 %4, i1 %5, i1 false
  ret i1 %6
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0aB11AnnotationsV8capacitys5UInt8Vvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0aB11AnnotationsV8capacitys5UInt8VvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e28GiftUIFailureCoreLayoutProbe0aB11AnnotationsV8capacitys5UInt8VvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0aB11AnnotationsV5counts5UInt8Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(20) %0) local_unnamed_addr #2 {
entry:
  %1 = load i8, ptr %0, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e28GiftUIFailureCoreLayoutProbe0aB11AnnotationsVACycfC"(ptr noalias writeonly sret(%T28GiftUIFailureCoreLayoutProbe0aB11AnnotationsV) captures(none) initializes((0, 1), (4, 6), (8, 14), (16, 20)) %0) local_unnamed_addr #3 {
entry:
  store i8 0, ptr %0, align 4
  %.first = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i16 0, ptr %.first, align 4
  %.first.value = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 0, ptr %.first.value, align 4
  %.second = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i16 0, ptr %.second, align 4
  %.second.value = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i32 0, ptr %.second.value, align 4
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc noundef i1 @"$e28GiftUIFailureCoreLayoutProbe0aB11AnnotationsV6appendySbAA0aB10AnnotationVF"(i16 %0, i32 %1, ptr swiftself captures(none) dereferenceable(20) %2) local_unnamed_addr #4 {
entry:
  %3 = load i8, ptr %2, align 4
  switch i8 %3, label %5 [
    i8 0, label %.sink.split
    i8 1, label %4
  ]

4:                                                ; preds = %entry
  br label %.sink.split

.sink.split:                                      ; preds = %entry, %4
  %.sink4 = phi i32 [ 12, %4 ], [ 4, %entry ]
  %.sink3 = phi i32 [ 16, %4 ], [ 8, %entry ]
  %.sink = phi i8 [ 2, %4 ], [ 1, %entry ]
  %.first = getelementptr inbounds nuw i8, ptr %2, i32 %.sink4
  store i16 %0, ptr %.first, align 4
  %.first.value = getelementptr inbounds nuw i8, ptr %2, i32 %.sink3
  store i32 %1, ptr %.first.value, align 4
  store i8 %.sink, ptr %2, align 4
  br label %5

5:                                                ; preds = %.sink.split, %entry
  %6 = phi i1 [ false, %entry ], [ true, %.sink.split ]
  ret i1 %6
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc { i32, i32, i8 } @"$e28GiftUIFailureCoreLayoutProbe0aB11AnnotationsVyAA0aB10AnnotationVSgs5UInt8Vcig"(i8 %0, ptr noalias readonly swiftself captures(none) dereferenceable(20) %1) local_unnamed_addr #2 {
entry:
  switch i8 %0, label %8 [
    i8 0, label %2
    i8 1, label %3
  ]

2:                                                ; preds = %entry
  %.sroa.03.0.copyload = load i8, ptr %1, align 4
  %.not = icmp eq i8 %.sroa.03.0.copyload, 0
  br i1 %.not, label %8, label %.sink.split

3:                                                ; preds = %entry
  %.sroa.0.0.copyload = load i8, ptr %1, align 4
  %4 = icmp ugt i8 %.sroa.0.0.copyload, 1
  br i1 %4, label %.sink.split, label %8

.sink.split:                                      ; preds = %3, %2
  %.sink4 = phi i32 [ 4, %2 ], [ 12, %3 ]
  %.sink = phi i32 [ 8, %2 ], [ 16, %3 ]
  %.first = getelementptr inbounds nuw i8, ptr %1, i32 %.sink4
  %5 = load i16, ptr %.first, align 4
  %.first.value = getelementptr inbounds nuw i8, ptr %1, i32 %.sink
  %6 = load i32, ptr %.first.value, align 4
  %7 = zext i16 %5 to i32
  br label %8

8:                                                ; preds = %.sink.split, %2, %3, %entry
  %.shrunk = phi i32 [ 0, %entry ], [ 0, %3 ], [ 0, %2 ], [ %7, %.sink.split ]
  %9 = phi i32 [ 0, %entry ], [ 0, %3 ], [ 0, %2 ], [ %6, %.sink.split ]
  %10 = phi i8 [ 1, %entry ], [ 1, %3 ], [ 1, %2 ], [ 0, %.sink.split ]
  %11 = insertvalue { i32, i32, i8 } undef, i32 %.shrunk, 0
  %12 = insertvalue { i32, i32, i8 } %11, i32 %9, 1
  %13 = insertvalue { i32, i32, i8 } %12, i8 %10, 2
  ret { i32, i32, i8 } %13
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc noundef i1 @"$e28GiftUIFailureCoreLayoutProbe0aB11AnnotationsV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(20) %0, ptr noalias readonly captures(none) dereferenceable(20) %1) local_unnamed_addr #2 {
entry:
  %.sroa.034.0.copyload = load i8, ptr %0, align 4
  %.sroa.033.0.copyload = load i8, ptr %1, align 4
  %2 = icmp eq i8 %.sroa.034.0.copyload, %.sroa.033.0.copyload
  br i1 %2, label %3, label %12

3:                                                ; preds = %entry
  %.first = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.030.sroa.0.0.copyload = load i16, ptr %.first, align 4
  %.first3 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.026.sroa.0.0.copyload = load i16, ptr %.first3, align 4
  %4 = icmp eq i16 %.sroa.030.sroa.0.0.copyload, %.sroa.026.sroa.0.0.copyload
  br i1 %4, label %5, label %12

5:                                                ; preds = %3
  %.sroa.427.0..first3.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.427.0.copyload = load i32, ptr %.sroa.427.0..first3.sroa_idx, align 4
  %.sroa.431.0..first.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.431.0.copyload = load i32, ptr %.sroa.431.0..first.sroa_idx, align 4
  %6 = icmp eq i32 %.sroa.431.0.copyload, %.sroa.427.0.copyload
  br i1 %6, label %7, label %12

7:                                                ; preds = %5
  %.second = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.022.sroa.0.0.copyload = load i16, ptr %.second, align 4
  %.second10 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.019.sroa.0.0.copyload = load i16, ptr %.second10, align 4
  %8 = icmp eq i16 %.sroa.022.sroa.0.0.copyload, %.sroa.019.sroa.0.0.copyload
  br i1 %8, label %9, label %11

9:                                                ; preds = %7
  %.sroa.4.0..second10.sroa_idx = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.sroa.4.0.copyload = load i32, ptr %.sroa.4.0..second10.sroa_idx, align 4
  %.sroa.423.0..second.sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.423.0.copyload = load i32, ptr %.sroa.423.0..second.sroa_idx, align 4
  %10 = icmp eq i32 %.sroa.423.0.copyload, %.sroa.4.0.copyload
  br i1 %10, label %12, label %11

11:                                               ; preds = %7, %9
  br label %12

12:                                               ; preds = %entry, %5, %3, %9, %11
  %13 = phi i1 [ false, %11 ], [ true, %9 ], [ false, %3 ], [ false, %5 ], [ false, %entry ]
  ret i1 %13
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV8rawValues5UInt8Vvg"(i8 returned %0) local_unnamed_addr #0 {
entry:
  ret i8 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV8rawValueACs5UInt8V_tcfC"(i8 returned %0) local_unnamed_addr #0 {
entry:
  ret i8 %0
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected void @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV17continueOperation_WZ"(ptr readnone captures(none) %0) local_unnamed_addr #0 {
entry:
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV17continueOperationACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV17continueOperationACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV17continueOperationACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected void @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV17requestPacedRetry_WZ"(ptr readnone captures(none) %0) local_unnamed_addr #0 {
entry:
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV17requestPacedRetryACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV17requestPacedRetryACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV17requestPacedRetryACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 2
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected void @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV23markFacilityUnavailable_WZ"(ptr readnone captures(none) %0) local_unnamed_addr #0 {
entry:
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV23markFacilityUnavailableACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV23markFacilityUnavailableACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV23markFacilityUnavailableACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 4
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected void @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV20quiesceAffectedScope_WZ"(ptr readnone captures(none) %0) local_unnamed_addr #0 {
entry:
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV20quiesceAffectedScopeACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV20quiesceAffectedScopeACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV20quiesceAffectedScopeACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 8
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected void @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV15invokeFatalHook_WZ"(ptr readnone captures(none) %0) local_unnamed_addr #0 {
entry:
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV15invokeFatalHookACvau"() local_unnamed_addr #0 {
entry:
  ret ptr @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV15invokeFatalHookACvpZ"
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i8 @"$e28GiftUIFailureCoreLayoutProbe0A21UIAllowedDispositionsV15invokeFatalHookACvgZ"() local_unnamed_addr #0 {
entry:
  ret i8 16
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0A19UIOperationalHealthV5stateAA0afG5StateOvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) local_unnamed_addr #2 {
entry:
  %1 = load i8, ptr %0, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e28GiftUIFailureCoreLayoutProbe0A19UIOperationalHealthV15transitionCounts6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) local_unnamed_addr #2 {
entry:
  %.transitionCount = getelementptr inbounds nuw i8, ptr %0, i32 4
  %1 = load i32, ptr %.transitionCount, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e28GiftUIFailureCoreLayoutProbe0A19UIOperationalHealthV16operationalCounts6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) local_unnamed_addr #2 {
entry:
  %.operationalCount = getelementptr inbounds nuw i8, ptr %0, i32 8
  %1 = load i32, ptr %.operationalCount, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e28GiftUIFailureCoreLayoutProbe0A19UIOperationalHealthV12failureCounts6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) local_unnamed_addr #2 {
entry:
  %.failureCount = getelementptr inbounds nuw i8, ptr %0, i32 12
  %1 = load i32, ptr %.failureCount, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e28GiftUIFailureCoreLayoutProbe0A19UIOperationalHealthV17countersSaturatedSbvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) local_unnamed_addr #2 {
entry:
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %0, i32 16
  %1 = load i1, ptr %.countersSaturated, align 4
  ret i1 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e28GiftUIFailureCoreLayoutProbe0A19UIOperationalHealthV5stateAcA0afG5StateO_tcfC"(ptr noalias writeonly sret(%T28GiftUIFailureCoreLayoutProbe0A19UIOperationalHealthV) captures(none) initializes((0, 1), (4, 17)) %0, i8 %1) local_unnamed_addr #3 {
entry:
  store i8 %1, ptr %0, align 4
  %.transitionCount = getelementptr inbounds nuw i8, ptr %0, i32 4
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(13) %.transitionCount, i8 0, i64 13, i1 false)
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc void @"$e28GiftUIFailureCoreLayoutProbe0A19UIOperationalHealthV17recordOperational_14resultingStateyAA0aF4FactV_AA0afgK0OtF"(i32 %0, i8 %1, ptr swiftself captures(none) dereferenceable(17) %2) local_unnamed_addr #4 {
entry:
  %.operationalCount = getelementptr inbounds nuw i8, ptr %2, i32 8
  %3 = load i32, ptr %.operationalCount, align 4
  %4 = icmp eq i32 %3, -1
  %5 = add i32 %3, 1
  %spec.select = select i1 %4, i32 -1, i32 %5
  store i32 %spec.select, ptr %.operationalCount, align 4
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %2, i32 16
  %6 = load i1, ptr %.countersSaturated, align 4
  %. = or i1 %4, %6
  %7 = zext i1 %. to i8
  store i8 %7, ptr %.countersSaturated, align 4
  tail call swiftcc void @"$e28GiftUIFailureCoreLayoutProbe0A19UIOperationalHealthV10transition33_D65848AB79A3EBB703DBF6A55B6842C9LL2toyAA0afG5StateO_tF"(i8 %1, ptr nonnull swiftself captures(none) dereferenceable(17) %2)
  ret void
}

; Function Attrs: cold noreturn nounwind memory(inaccessiblemem: write)
declare void @llvm.trap() #5

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc void @"$e28GiftUIFailureCoreLayoutProbe0A19UIOperationalHealthV10transition33_D65848AB79A3EBB703DBF6A55B6842C9LL2toyAA0afG5StateO_tF"(i8 %0, ptr swiftself captures(none) dereferenceable(17) %1) local_unnamed_addr #4 {
entry:
  %2 = load i8, ptr %1, align 4
  %.not = icmp eq i8 %2, 3
  br i1 %.not, label %10, label %3

3:                                                ; preds = %entry
  %.not7 = icmp eq i8 %2, %0
  br i1 %.not7, label %10, label %4

4:                                                ; preds = %3
  %.transitionCount = getelementptr inbounds nuw i8, ptr %1, i32 4
  %5 = load i32, ptr %.transitionCount, align 4
  %6 = icmp eq i32 %5, -1
  %7 = add i32 %5, 1
  %spec.select = select i1 %6, i32 -1, i32 %7
  store i32 %spec.select, ptr %.transitionCount, align 4
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %1, i32 16
  %8 = load i1, ptr %.countersSaturated, align 4
  %. = or i1 %6, %8
  %9 = zext i1 %. to i8
  store i8 %9, ptr %.countersSaturated, align 4
  store i8 %0, ptr %1, align 4
  br label %10

10:                                               ; preds = %entry, %3, %4
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define protected swiftcc void @"$e28GiftUIFailureCoreLayoutProbe0A19UIOperationalHealthV13recordFailure_14resultingStateyAA0aB4FactV_AA0afgK0OtF"(i32 %0, i8 %1, i8 %2, ptr swiftself captures(none) dereferenceable(17) %3) local_unnamed_addr #4 {
entry:
  %.failureCount = getelementptr inbounds nuw i8, ptr %3, i32 12
  %4 = load i32, ptr %.failureCount, align 4
  %5 = icmp eq i32 %4, -1
  %6 = add i32 %4, 1
  %spec.select = select i1 %5, i32 -1, i32 %6
  store i32 %spec.select, ptr %.failureCount, align 4
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %3, i32 16
  %7 = load i1, ptr %.countersSaturated, align 4
  %. = or i1 %5, %7
  %8 = zext i1 %. to i8
  store i8 %8, ptr %.countersSaturated, align 4
  tail call swiftcc void @"$e28GiftUIFailureCoreLayoutProbe0A19UIOperationalHealthV10transition33_D65848AB79A3EBB703DBF6A55B6842C9LL2toyAA0afG5StateO_tF"(i8 %2, ptr nonnull swiftself captures(none) dereferenceable(17) %3)
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e28GiftUIFailureCoreLayoutProbe0A19UIOperationalHealthV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(17) %0, ptr noalias readonly captures(none) dereferenceable(17) %1) local_unnamed_addr #2 {
entry:
  %.unpack = load i8, ptr %0, align 4
  %.unpack29 = load i8, ptr %1, align 4
  %2 = icmp eq i8 %.unpack, %.unpack29
  br i1 %2, label %3, label %15

3:                                                ; preds = %entry
  %.transitionCount = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.sroa.021.0.copyload = load i32, ptr %.transitionCount, align 4
  %.transitionCount2 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.sroa.020.0.copyload = load i32, ptr %.transitionCount2, align 4
  %4 = icmp eq i32 %.sroa.021.0.copyload, %.sroa.020.0.copyload
  br i1 %4, label %5, label %15

5:                                                ; preds = %3
  %.operationalCount = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.019.0.copyload = load i32, ptr %.operationalCount, align 4
  %.operationalCount4 = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.018.0.copyload = load i32, ptr %.operationalCount4, align 4
  %6 = icmp eq i32 %.sroa.019.0.copyload, %.sroa.018.0.copyload
  br i1 %6, label %7, label %15

7:                                                ; preds = %5
  %.failureCount = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.017.0.copyload = load i32, ptr %.failureCount, align 4
  %.failureCount7 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.016.0.copyload = load i32, ptr %.failureCount7, align 4
  %8 = icmp eq i32 %.sroa.017.0.copyload, %.sroa.016.0.copyload
  br i1 %8, label %9, label %15

9:                                                ; preds = %7
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %0, i32 16
  %10 = load i8, ptr %.countersSaturated, align 4
  %.countersSaturated10 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %11 = load i8, ptr %.countersSaturated10, align 4
  %12 = xor i8 %10, %11
  %13 = trunc i8 %12 to i1
  %14 = xor i1 %13, true
  br label %15

15:                                               ; preds = %entry, %3, %5, %7, %9
  %16 = phi i1 [ %14, %9 ], [ false, %7 ], [ false, %5 ], [ false, %3 ], [ false, %entry ]
  ret i1 %16
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0A21UIDiagnosticSelectionV8kindMasks5UInt8Vvg"(i32 %0, i8 %1) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i32 %0 to i8
  ret i8 %temp-coercion.coerced.sroa.0.0.extract.trunc
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i16 @"$e28GiftUIFailureCoreLayoutProbe0A21UIDiagnosticSelectionV10originMasks6UInt16Vvg"(i32 %0, i8 %1) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.0.2.extract.shift = lshr i32 %0, 16
  %temp-coercion.coerced.sroa.0.2.extract.trunc = trunc nuw i32 %temp-coercion.coerced.sroa.0.2.extract.shift to i16
  ret i16 %temp-coercion.coerced.sroa.0.2.extract.trunc
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0A21UIDiagnosticSelectionV15minimumSeverityAA0afI0Ovg"(i32 %0, i8 returned %1) local_unnamed_addr #0 {
entry:
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc { i32, i8 } @"$e28GiftUIFailureCoreLayoutProbe0A21UIDiagnosticSelectionV8kindMask06originI015minimumSeverityACs5UInt8V_s6UInt16VAA0afL0OtcfC"(i8 %0, i16 %1, i8 %2) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.0.0.insert.ext = zext i8 %0 to i32
  %temp-coercion.coerced.sroa.0.2.insert.ext = zext i16 %1 to i32
  %temp-coercion.coerced.sroa.0.2.insert.shift = shl nuw i32 %temp-coercion.coerced.sroa.0.2.insert.ext, 16
  %temp-coercion.coerced.sroa.0.2.insert.insert = or disjoint i32 %temp-coercion.coerced.sroa.0.2.insert.shift, %temp-coercion.coerced.sroa.0.0.insert.ext
  %3 = insertvalue { i32, i8 } undef, i32 %temp-coercion.coerced.sroa.0.2.insert.insert, 0
  %4 = insertvalue { i32, i8 } %3, i8 %2, 1
  ret { i32, i8 } %4
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e28GiftUIFailureCoreLayoutProbe0A21UIDiagnosticSelectionV8includes4kind6origin8severitySbAA0aF4KindO_AA0aB6OriginOAA0aF8SeverityOtF"(i8 %0, i8 %1, i8 %2, i32 %3, i8 %4) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i32 %3 to i8
  %temp-coercion.coerced.sroa.0.2.extract.shift = lshr i32 %3, 16
  %temp-coercion.coerced.sroa.0.2.extract.trunc = trunc nuw i32 %temp-coercion.coerced.sroa.0.2.extract.shift to i16
  %5 = shl nuw i8 1, %0
  %6 = icmp ugt i8 %0, 7
  %7 = select i1 %6, i8 0, i8 %5
  %8 = icmp ugt i8 %1, 16
  br i1 %8, label %19, label %9

9:                                                ; preds = %entry
  %.not3 = icmp eq i8 %1, 16
  br i1 %.not3, label %19, label %10, !prof !6

10:                                               ; preds = %9
  %11 = zext nneg i8 %1 to i16
  %12 = shl nuw i16 1, %11
  %13 = and i8 %7, %temp-coercion.coerced.sroa.0.0.extract.trunc
  %14 = icmp ne i8 %13, 0
  %15 = and i16 %12, %temp-coercion.coerced.sroa.0.2.extract.trunc
  %16 = icmp ne i16 %15, 0
  %or.cond = select i1 %14, i1 %16, i1 false
  br i1 %or.cond, label %17, label %19

17:                                               ; preds = %10
  %18 = icmp uge i8 %2, %4
  br label %19

19:                                               ; preds = %10, %9, %entry, %17
  %20 = phi i1 [ %18, %17 ], [ false, %entry ], [ false, %9 ], [ false, %10 ]
  ret i1 %20
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.ssub.with.overflow.i32(i32, i32) #6

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc i1 @"$e28GiftUIFailureCoreLayoutProbe0A21UIDiagnosticSelectionV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i8 %1, i32 %2, i8 %3) local_unnamed_addr #0 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i32 %0 to i8
  %temp-coercion.coerced1.sroa.0.0.extract.trunc = trunc i32 %2 to i8
  %4 = icmp eq i8 %temp-coercion.coerced.sroa.0.0.extract.trunc, %temp-coercion.coerced1.sroa.0.0.extract.trunc
  %.unshifted = xor i32 %2, %0
  %5 = icmp ult i32 %.unshifted, 65536
  %or.cond = and i1 %4, %5
  br i1 %or.cond, label %6, label %8

6:                                                ; preds = %entry
  %7 = icmp eq i8 %1, %3
  br label %8

8:                                                ; preds = %entry, %6
  %9 = phi i1 [ %7, %6 ], [ false, %entry ]
  ret i1 %9
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0A18UIDiagnosticRecordV4kindAA0aF4KindOvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %1 = load i8, ptr %0, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0A18UIDiagnosticRecordV8severityAA0aF8SeverityOvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.severity = getelementptr inbounds nuw i8, ptr %0, i32 1
  %1 = load i8, ptr %.severity, align 1
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i16 @"$e28GiftUIFailureCoreLayoutProbe0A18UIDiagnosticRecordV5flagss6UInt16Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.flags = getelementptr inbounds nuw i8, ptr %0, i32 2
  %1 = load i16, ptr %.flags, align 2
  ret i16 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0A18UIDiagnosticRecordV6originAA0aB6OriginOvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.origin = getelementptr inbounds nuw i8, ptr %0, i32 4
  %1 = load i8, ptr %.origin, align 4
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i8 @"$e28GiftUIFailureCoreLayoutProbe0A18UIDiagnosticRecordV13affectedScopeAA0a10UIAffectedI0Ovg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.affectedScope = getelementptr inbounds nuw i8, ptr %0, i32 5
  %1 = load i8, ptr %.affectedScope, align 1
  ret i8 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i16 @"$e28GiftUIFailureCoreLayoutProbe0A18UIDiagnosticRecordV9conditions6UInt16Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.condition = getelementptr inbounds nuw i8, ptr %0, i32 6
  %1 = load i16, ptr %.condition, align 2
  ret i16 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e28GiftUIFailureCoreLayoutProbe0A18UIDiagnosticRecordV12correlation0s6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.correlation0 = getelementptr inbounds nuw i8, ptr %0, i32 8
  %1 = load i32, ptr %.correlation0, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e28GiftUIFailureCoreLayoutProbe0A18UIDiagnosticRecordV12correlation1s6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.correlation1 = getelementptr inbounds nuw i8, ptr %0, i32 12
  %1 = load i32, ptr %.correlation1, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e28GiftUIFailureCoreLayoutProbe0A18UIDiagnosticRecordV12observation0s6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.observation0 = getelementptr inbounds nuw i8, ptr %0, i32 16
  %1 = load i32, ptr %.observation0, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i32 @"$e28GiftUIFailureCoreLayoutProbe0A18UIDiagnosticRecordV12observation1s6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(24) %0) local_unnamed_addr #2 {
entry:
  %.observation1 = getelementptr inbounds nuw i8, ptr %0, i32 20
  %1 = load i32, ptr %.observation1, align 4
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write)
define protected swiftcc void @"$e28GiftUIFailureCoreLayoutProbe0A18UIDiagnosticRecordV4kind8severity5flags6origin13affectedScope9condition12correlation012correlation112observation012observation1AcA0aF4KindO_AA0aF8SeverityOs6UInt16VAA0aB6OriginOAA0a10UIAffectedM0OASs6UInt32VA3YtcfC"(ptr noalias writeonly sret(%T28GiftUIFailureCoreLayoutProbe0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0, i8 %1, i8 %2, i16 %3, i8 %4, i8 %5, i16 %6, i32 %7, i32 %8, i32 %9, i32 %10) local_unnamed_addr #3 {
entry:
  %11 = and i16 %3, 15
  store i8 %1, ptr %0, align 4
  %.sroa.42.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 1
  store i8 %2, ptr %.sroa.42.0..sroa_idx, align 1
  %.sroa.53.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 2
  store i16 %11, ptr %.sroa.53.0..sroa_idx, align 2
  %.sroa.64.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i8 %4, ptr %.sroa.64.0..sroa_idx, align 4
  %.sroa.75.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 5
  store i8 %5, ptr %.sroa.75.0..sroa_idx, align 1
  %.sroa.86.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 6
  store i16 %6, ptr %.sroa.86.0..sroa_idx, align 2
  %.sroa.97.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %7, ptr %.sroa.97.0..sroa_idx, align 4
  %.sroa.108.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i32 %8, ptr %.sroa.108.0..sroa_idx, align 4
  %.sroa.119.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 16
  store i32 %9, ptr %.sroa.119.0..sroa_idx, align 4
  %.sroa.1210.0..sroa_idx = getelementptr inbounds nuw i8, ptr %0, i32 20
  store i32 %10, ptr %.sroa.1210.0..sroa_idx, align 4
  ret void
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read)
define protected swiftcc i1 @"$e28GiftUIFailureCoreLayoutProbe0A18UIDiagnosticRecordV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(24) %0, ptr noalias readonly captures(none) dereferenceable(24) %1) local_unnamed_addr #2 {
entry:
  %.unpack = load i8, ptr %0, align 4
  %.unpack79 = load i8, ptr %1, align 4
  %2 = icmp eq i8 %.unpack, %.unpack79
  br i1 %2, label %3, label %21

3:                                                ; preds = %entry
  %.severity = getelementptr inbounds nuw i8, ptr %0, i32 1
  %.unpack80 = load i8, ptr %.severity, align 1
  %.severity2 = getelementptr inbounds nuw i8, ptr %1, i32 1
  %.unpack81 = load i8, ptr %.severity2, align 1
  %4 = icmp eq i8 %.unpack80, %.unpack81
  br i1 %4, label %5, label %21

5:                                                ; preds = %3
  %.flags = getelementptr inbounds nuw i8, ptr %0, i32 2
  %.sroa.062.0.copyload = load i16, ptr %.flags, align 2
  %.flags3 = getelementptr inbounds nuw i8, ptr %1, i32 2
  %.sroa.061.0.copyload = load i16, ptr %.flags3, align 2
  %6 = icmp eq i16 %.sroa.062.0.copyload, %.sroa.061.0.copyload
  br i1 %6, label %7, label %21

7:                                                ; preds = %5
  %.origin = getelementptr inbounds nuw i8, ptr %0, i32 4
  %.unpack82 = load i8, ptr %.origin, align 4
  %.origin5 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %.unpack83 = load i8, ptr %.origin5, align 4
  %8 = icmp eq i8 %.unpack82, %.unpack83
  br i1 %8, label %9, label %21

9:                                                ; preds = %7
  %.affectedScope = getelementptr inbounds nuw i8, ptr %0, i32 5
  %.unpack84 = load i8, ptr %.affectedScope, align 1
  %.affectedScope6 = getelementptr inbounds nuw i8, ptr %1, i32 5
  %.unpack85 = load i8, ptr %.affectedScope6, align 1
  %10 = icmp eq i8 %.unpack84, %.unpack85
  br i1 %10, label %11, label %21

11:                                               ; preds = %9
  %.condition = getelementptr inbounds nuw i8, ptr %0, i32 6
  %.sroa.045.0.copyload = load i16, ptr %.condition, align 2
  %.condition7 = getelementptr inbounds nuw i8, ptr %1, i32 6
  %.sroa.044.0.copyload = load i16, ptr %.condition7, align 2
  %12 = icmp eq i16 %.sroa.045.0.copyload, %.sroa.044.0.copyload
  br i1 %12, label %13, label %21

13:                                               ; preds = %11
  %.correlation0 = getelementptr inbounds nuw i8, ptr %0, i32 8
  %.sroa.043.0.copyload = load i32, ptr %.correlation0, align 4
  %.correlation010 = getelementptr inbounds nuw i8, ptr %1, i32 8
  %.sroa.042.0.copyload = load i32, ptr %.correlation010, align 4
  %14 = icmp eq i32 %.sroa.043.0.copyload, %.sroa.042.0.copyload
  br i1 %14, label %15, label %21

15:                                               ; preds = %13
  %.correlation1 = getelementptr inbounds nuw i8, ptr %0, i32 12
  %.sroa.041.0.copyload = load i32, ptr %.correlation1, align 4
  %.correlation113 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %.sroa.040.0.copyload = load i32, ptr %.correlation113, align 4
  %16 = icmp eq i32 %.sroa.041.0.copyload, %.sroa.040.0.copyload
  br i1 %16, label %17, label %21

17:                                               ; preds = %15
  %.observation0 = getelementptr inbounds nuw i8, ptr %0, i32 16
  %.sroa.039.0.copyload = load i32, ptr %.observation0, align 4
  %.observation016 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %.sroa.038.0.copyload = load i32, ptr %.observation016, align 4
  %18 = icmp eq i32 %.sroa.039.0.copyload, %.sroa.038.0.copyload
  br i1 %18, label %19, label %21

19:                                               ; preds = %17
  %.observation1 = getelementptr inbounds nuw i8, ptr %0, i32 20
  %.sroa.037.0.copyload = load i32, ptr %.observation1, align 4
  %.observation119 = getelementptr inbounds nuw i8, ptr %1, i32 20
  %.sroa.036.0.copyload = load i32, ptr %.observation119, align 4
  %20 = icmp eq i32 %.sroa.037.0.copyload, %.sroa.036.0.copyload
  br label %21

21:                                               ; preds = %entry, %3, %5, %7, %9, %11, %13, %15, %17, %19
  %22 = phi i1 [ %20, %19 ], [ false, %17 ], [ false, %15 ], [ false, %13 ], [ false, %11 ], [ false, %9 ], [ false, %7 ], [ false, %5 ], [ false, %3 ], [ false, %entry ]
  ret i1 %22
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO15conditionIDSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 2
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO17conditionIDStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 2
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO20conditionIDAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 2
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO17failureOriginSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO19failureOriginStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO22failureOriginAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO17affectedScopeSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO19affectedScopeStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO22affectedScopeAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO15containmentSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO17containmentStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO20containmentAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO15failureFactSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 5
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO17failureFactStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 6
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO20failureFactAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 2
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO19operationalKindSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO21operationalKindStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO24operationalKindAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO19operationalFactSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 3
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO21operationalFactStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 3
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO24operationalFactAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO11outcomeSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 6
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO13outcomeStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 8
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO16outcomeAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO21failureAnnotationSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 8
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO23failureAnnotationStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 8
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO26failureAnnotationAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO22failureAnnotationsSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 20
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO24failureAnnotationsStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 20
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO27failureAnnotationsAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO23residualDispositionSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO25residualDispositionStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO28residualDispositionAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO23allowedDispositionsSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO25allowedDispositionsStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO28allowedDispositionsAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO23residualPolicyInputSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 15
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO25residualPolicyInputStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 16
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO28residualPolicyInputAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO26operationalHealthStateSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO28operationalHealthStateStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO31operationalHealthStateAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO21operationalHealthSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 17
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO23operationalHealthStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 20
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO26operationalHealthAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO18diagnosticKindSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO20diagnosticKindStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO23diagnosticKindAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO22diagnosticSeveritySizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO24diagnosticSeverityStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO27diagnosticSeverityAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO23diagnosticSelectionSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 5
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO25diagnosticSelectionStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 6
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO28diagnosticSelectionAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 2
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO20diagnosticRecordSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 24
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO22diagnosticRecordStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 24
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO25diagnosticRecordAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 4
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO24diagnosticSinkResultSizes6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO26diagnosticSinkResultStrides6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none)
define protected swiftcc noundef i32 @"$e28GiftUIFailureCoreLayoutProbeAAO29diagnosticSinkResultAlignments6UInt32VyFZ"() local_unnamed_addr #7 {
entry:
  ret i32 1
}

; Function Attrs: minsize nounwind optsize sspreq
define weak_odr protected swiftcc { ptr, ptr } @swift_allocBox(ptr %0) local_unnamed_addr #8 {
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
  tail call void @llvm.trap() #16
  unreachable

24:                                               ; preds = %10
  call void @llvm.trap() #16
  unreachable
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32) #6

; Function Attrs: minsize nofree nounwind optsize
declare i32 @posix_memalign(ptr, i32, i32) local_unnamed_addr #9

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc { ptr, ptr } @swift_makeBoxUnique(ptr %0, ptr %1, i32 %2) local_unnamed_addr #10 {
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
define linkonce_odr hidden void @swift_releaseBox(ptr %0) local_unnamed_addr #10 {
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
define weak_odr protected void @swift_deallocBox(ptr %0) local_unnamed_addr #10 {
entry:
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize mustprogress nounwind optsize willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr noundef captures(none)) local_unnamed_addr #11

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_allocEmptyBox() local_unnamed_addr #10 {
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
define weak_odr protected ptr @swift_allocObject(ptr %0, i32 %1, i32 %2) local_unnamed_addr #10 {
entry:
  %3 = tail call swiftcc ptr @"$es17swift_allocObject8metadata12requiredSize0E13AlignmentMaskSpys04HeapC0VGSpys13ClassMetadataVG_S2itF"(ptr %0, i32 %1, i32 %2)
  ret ptr %3
}

; Function Attrs: minsize nounwind optsize sspreq
define linkonce_odr hidden swiftcc ptr @"$es17swift_allocObject8metadata12requiredSize0E13AlignmentMaskSpys04HeapC0VGSpys13ClassMetadataVG_S2itF"(ptr %0, i32 %1, i32 %2) local_unnamed_addr #8 {
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
  tail call void @llvm.trap() #16
  unreachable

18:                                               ; preds = %10
  call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_allocObjectTyped(ptr %0, i32 %1, i32 %2, i64 %3) local_unnamed_addr #10 {
entry:
  %4 = tail call swiftcc ptr @"$es17swift_allocObject8metadata12requiredSize0E13AlignmentMaskSpys04HeapC0VGSpys13ClassMetadataVG_S2itF"(ptr %0, i32 %1, i32 %2)
  ret ptr %4
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_initStackObject(ptr %0, ptr %1) local_unnamed_addr #10 {
entry:
  store ptr %0, ptr %1, align 4, !tbaa !16
  %.refcount = getelementptr inbounds nuw i8, ptr %1, i32 4
  store i32 -2147483647, ptr %.refcount, align 4
  ret ptr %1
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_initStaticObject(ptr %0, ptr %1) local_unnamed_addr #10 {
entry:
  store ptr %0, ptr %1, align 4, !tbaa !16
  %.refcount = getelementptr inbounds nuw i8, ptr %1, i32 4
  store i32 -1, ptr %.refcount, align 4
  ret ptr %1
}

; Function Attrs: minsize nounwind optsize
define private void @0(ptr %0, i32 %1, i32 %2) local_unnamed_addr #10 {
entry:
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocClassInstance(ptr %0, i32 %1, i32 %2) local_unnamed_addr #10 {
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
define weak_odr protected void @swift_deallocPartialClassInstance(ptr %0, ptr %1, i32 %2, i32 %3) local_unnamed_addr #10 {
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
define weak_odr protected ptr @swift_slowAlloc(i32 %0, i32 %1) local_unnamed_addr #8 {
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
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc void @swift_willThrow(ptr swiftself %0, ptr noalias swifterror captures(none) dereferenceable(4) %1) local_unnamed_addr #10 {
entry:
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc void @swift_errorInMain(ptr %0) local_unnamed_addr #10 {
entry:
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected swiftcc void @swift_unexpectedError(ptr %0, ptr %1, i32 %2, i1 %3, i32 %4) local_unnamed_addr #10 {
entry:
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_release_n(ptr %0, i32 %1) local_unnamed_addr #10 {
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
define weak_odr protected void @swift_setDeallocating(ptr %0) local_unnamed_addr #10 {
entry:
  ret void
}

; Function Attrs: minsize nounwind optsize
define private ptr @1(ptr %0, i32 %1) local_unnamed_addr #10 {
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
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_bridgeObjectRelease_n(ptr %0, i32 %1) local_unnamed_addr #10 {
entry:
  tail call void @swift_release_n(ptr %0, i32 %1)
  ret void
}

; Function Attrs: minsize nounwind optsize
define private ptr @2(ptr %0) local_unnamed_addr #10 {
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
define weak_odr protected void @swift_bridgeObjectRelease(ptr %0) local_unnamed_addr #10 {
entry:
  tail call void @swift_release_n(ptr %0, i32 1)
  ret void
}

; Function Attrs: minsize nounwind optsize
define private void @3(ptr %0) local_unnamed_addr #10 {
  tail call void @swift_releaseTm(ptr %0) #10
  ret void
}

; Function Attrs: minsize nounwind optsize
define internal void @swift_releaseTm(ptr %0) local_unnamed_addr #10 {
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
  tail call swiftcc void %18(ptr noundef nonnull swiftself %0) #17
  br label %19

19:                                               ; preds = %11, %entry, %2, %15
  ret void

20:                                               ; preds = %7
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected zeroext i1 @swift_isUniquelyReferenced_native(ptr %0) local_unnamed_addr #10 {
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
define weak_odr protected zeroext i1 @swift_isUniquelyReferenced_nonNull_native(ptr %0) local_unnamed_addr #10 {
entry:
  %1 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %2 = load atomic i32, ptr %1 acquire, align 4
  %3 = icmp eq i32 %2, 1
  ret i1 %3
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected zeroext i1 @swift_isEscapingClosureAtFileLocation(ptr %0, ptr %1, i32 %2, i32 %3, i32 %4, i32 %5) local_unnamed_addr #10 {
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
define weak_odr protected ptr @swift_dynamicCastClass(ptr %0, ptr %1) local_unnamed_addr #10 {
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
define weak_odr protected ptr @swift_dynamicCastClassUnconditional(ptr %0, ptr %1, ptr %2, i32 %3, i32 %4) local_unnamed_addr #10 {
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
define weak_odr protected zeroext i1 @swift_dynamicCast(ptr %0, ptr %1, ptr %2, ptr %3, i32 %4) local_unnamed_addr #10 {
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
define linkonce_odr hidden swiftcc i8 @"$es7tryCast33_8BFEAB69C69C8B87ED137407D82370D4LL3dst0J8Metadata3src0lK013takeOnSuccesss07DynamicB6ResultABLLOSv_S3VSbtF"(ptr %0, ptr %1, ptr %2, ptr %3, i1 %4) local_unnamed_addr #10 {
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
define linkonce_odr hidden swiftcc i8 @"$es12MetadataKindO8metadataABSgSV_tcfC"(ptr %0) local_unnamed_addr #10 {
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
define linkonce_odr hidden swiftcc i1 @"$es12MetadataKindO21__derived_enum_equalsySbAB_ABtFZ"(i8 %0, i8 %1) local_unnamed_addr #10 {
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
define linkonce_odr hidden swiftcc { ptr, ptr } @"$es29ExistentialTypeRepresentationO7projectySV8metadata_SV5valuetSVF"(ptr %0, i8 %1) local_unnamed_addr #10 {
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
define weak_odr protected void @swift_once(ptr %0, ptr %1, ptr %2) local_unnamed_addr #10 {
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
  tail call void %1(ptr %2) #18
  store atomic i32 -1, ptr %0 release, align 4
  br label %.loopexit

.loopexit:                                        ; preds = %.preheader, %entry, %10
  ret void
}

; Function Attrs: minsize nounwind optsize sspreq
define weak_odr protected ptr @swift_coroFrameAlloc(i32 %0, i64 %1) local_unnamed_addr #8 {
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
define weak_odr protected swiftcc { ptr, ptr } @swift_allocError(ptr %0, ptr %1, ptr %2, i1 %3) local_unnamed_addr #10 {
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
define linkonce_odr hidden swiftcc void @"$es23_errorBoxDestroyImplRef33_21ED9D60359C2E63A6128CFAED697BD0LLyyBpcvpfiyBpcfU_"(ptr %0) #10 {
entry:
  ret void
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc void @_swift_embedded_error_destroy_impl(ptr %0) #10 {
entry:
  %1 = tail call swiftcc { ptr, ptr, ptr } @"$es17_errorBoxContentsySV4type_SV11conformanceSV5valuetSVF"(ptr %0)
  %2 = extractvalue { ptr, ptr, ptr } %1, 0
  %3 = extractvalue { ptr, ptr, ptr } %1, 2
  %arrayidx.i.i = getelementptr inbounds i8, ptr %2, i32 -4
  %4 = load ptr, ptr %arrayidx.i.i, align 4, !tbaa !7
  %destroyFn.i = getelementptr inbounds nuw i8, ptr %4, i32 4
  %5 = load ptr, ptr %destroyFn.i, align 4, !tbaa !19
  tail call void %5(ptr noundef %3, ptr noundef %2) #17
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden swiftcc { ptr, ptr, ptr } @"$es17_errorBoxContentsySV4type_SV11conformanceSV5valuetSVF"(ptr %0) local_unnamed_addr #10 {
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
define weak_odr protected void @swift_deallocError(ptr %0, ptr %1) local_unnamed_addr #10 {
entry:
  tail call void @free(ptr %0)
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_getErrorValue(ptr %0, ptr %1, ptr %2) local_unnamed_addr #10 {
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
define weak_odr protected i32 @_swift_exceptionPersonality(i32 %0, i32 %1, i64 %2, ptr %3, ptr %4) #10 {
entry:
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize noinline nounwind optsize
define weak_odr protected void @swift_clearSensitive(ptr %0, i32 %1) local_unnamed_addr #12 {
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
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected i32 @swift_retainCount(ptr %0) local_unnamed_addr #10 {
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
define private void @4() #10 {
entry:
  tail call void @llvm.trap() #16
  unreachable
}

; Function Attrs: inlinehint nounwind optsize
define internal swiftcc void @_swift_embedded_error_box_destroy(ptr noundef swiftself %object) #13 {
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
  tail call void %8(ptr noundef %7, ptr noundef %1) #17
  tail call void @free(ptr %object)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smax.i32(i32, i32) #14

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #15

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i32(ptr writeonly captures(none), i8, i32, i1 immarg) #15

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_retain(ptr %0) local_unnamed_addr #10 {
  %2 = tail call ptr @2(ptr %0) #10
  ret ptr %2
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_bridgeObjectRetain(ptr %0) local_unnamed_addr #10 {
  %2 = tail call ptr @2(ptr %0) #10
  ret ptr %2
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_errorRetain(ptr %0) local_unnamed_addr #10 {
  %2 = tail call ptr @2(ptr %0) #10
  ret ptr %2
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_retain_n(ptr %0, i32 %1) local_unnamed_addr #10 {
  %3 = tail call ptr @1(ptr %0, i32 %1) #10
  ret ptr %3
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected ptr @swift_bridgeObjectRetain_n(ptr %0, i32 %1) local_unnamed_addr #10 {
  %3 = tail call ptr @1(ptr %0, i32 %1) #10
  ret ptr %3
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deletedMethodError() local_unnamed_addr #10 {
  tail call void @4() #10
  ret void
}

; Function Attrs: minsize nounwind optsize
define linkonce_odr hidden void @_swift_dead_method_stub() #10 {
  tail call void @4() #10
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocUninitializedObject(ptr %0, i32 %1, i32 %2) local_unnamed_addr #10 {
  tail call void @0(ptr %0, i32 %1, i32 %2) #10
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_deallocObject(ptr %0, i32 %1, i32 %2) local_unnamed_addr #10 {
  tail call void @0(ptr %0, i32 %1, i32 %2) #10
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_slowDealloc(ptr %0, i32 %1, i32 %2) local_unnamed_addr #10 {
  tail call void @0(ptr %0, i32 %1, i32 %2) #10
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_release(ptr %0) local_unnamed_addr #10 {
  tail call void @3(ptr %0) #10
  ret void
}

; Function Attrs: minsize nounwind optsize
define weak_odr protected void @swift_errorRelease(ptr %0) local_unnamed_addr #10 {
  tail call void @3(ptr %0) #10
  ret void
}

attributes #0 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: read) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #3 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: write) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #4 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #5 = { cold noreturn nounwind memory(inaccessiblemem: write) }
attributes #6 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #7 = { minsize mustprogress nofree noinline norecurse nosync nounwind optsize willreturn memory(none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #8 = { minsize nounwind optsize sspreq "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #9 = { minsize nofree nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #10 = { minsize nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #11 = { minsize mustprogress nounwind optsize willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #12 = { minsize noinline nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #13 = { inlinehint nounwind optsize "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m4" "target-features"="+armv7e-m,+dsp,+fp16,+hwdiv,+thumb-mode,+vfp2sp,+vfp3d16sp,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16fml,-fp64,-fullfp16,-hwdiv-arm,-i8mm,-lob,-mve,-mve.fp,-neon,-pacbti,-ras,-sb,-sha2,-vfp2,-vfp3,-vfp3d16,-vfp3sp,-vfp4,-vfp4d16,-vfp4sp" }
attributes #14 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #15 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #16 = { nomerge }
attributes #17 = { nounwind optsize }
attributes #18 = { nounwind }

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
