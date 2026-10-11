; ModuleID = '/Users/eugene/work/GiftUI/.build/raspberry-pi/p08-resource-regression/003-arm-layout/semantics/diagnostics-layout.ll'
source_filename = "/Users/eugene/work/GiftUI/.build/raspberry-pi/p08-resource-regression/003-arm-layout/semantics/diagnostics-layout.ll"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "armv6-unknown-linux-gnueabihf"

%Ts5UInt8V = type <{ i8 }>
%swift.protocol = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i32, i32, i32, i32, i32, i32 }
%swift.method_descriptor = type { i32, i32 }
%swift.protocol_conformance_descriptor = type { i32, i32, i32, i32 }
%swift.vwtable = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i32, i32, i32, i32 }
%swift.type_descriptor = type opaque
%swift.type_metadata_record = type { i32 }
%swift.type = type { i32 }
%T35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV = type <{ %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V, %TSb }>
%Ts6UInt32V = type <{ i32 }>
%TSb = type <{ i1 }>
%swift.opaque = type opaque
%swift.metadata_response = type { ptr, i32 }
%T17GiftUIFailureCore0A18UIDiagnosticRecordV = type <{ %T17GiftUIFailureCore0A16UIDiagnosticKindO, %T17GiftUIFailureCore0A20UIDiagnosticSeverityO, %Ts6UInt16V, %T17GiftUIFailureCore0aB6OriginO, %T17GiftUIFailureCore0A15UIAffectedScopeO, %Ts6UInt16V, %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V }>
%T17GiftUIFailureCore0A16UIDiagnosticKindO = type <{ i8 }>
%T17GiftUIFailureCore0A20UIDiagnosticSeverityO = type <{ i8 }>
%T17GiftUIFailureCore0aB6OriginO = type <{ i8 }>
%T17GiftUIFailureCore0A15UIAffectedScopeO = type <{ i8 }>
%Ts6UInt16V = type <{ i16 }>
%T35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV = type <{ %Ts5UInt8V, [3 x i8], %Ts6UInt32V, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV }>
%T17GiftUIFailureCore0A18UIDiagnosticRecordVSg = type <{ [24 x i8] }>

@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvpZ" = protected constant %Ts5UInt8V <{ i8 16 }>, align 1
@"$sSQMp" = external global %swift.protocol, align 4
@"got.$sSQMp" = private unnamed_addr constant ptr @"$sSQMp"
@"$sSQ2eeoiySbx_xtFZTq" = external global %swift.method_descriptor, align 4
@"got.$sSQ2eeoiySbx_xtFZTq" = private unnamed_addr constant ptr @"$sSQ2eeoiySbx_xtFZTq"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQMp" to i32), i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 1, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAASQ2eeoiySbx_xtFZTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc", i32 0, i32 6) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc", i32 0, i32 10) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAMc" = protected constant %swift.protocol_conformance_descriptor { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$s17GiftUIFailureCore0A16UIDiagnosticSinkMp" to i32), i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (%swift.protocol_conformance_descriptor, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAMc", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAWP" to i32), i32 ptrtoint (ptr getelementptr inbounds (%swift.protocol_conformance_descriptor, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAMc", i32 0, i32 2) to i32)), i32 0 }, section ".rodata", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAWP" = protected constant [2 x ptr] [ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAMc", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAadEP7consumeyAD0ajK6ResultOAD0aJ6RecordVFTW"], align 4
@"$s17GiftUIFailureCore0A16UIDiagnosticSinkMp" = external global %swift.protocol, align 4
@"got.$s17GiftUIFailureCore0A16UIDiagnosticSinkMp" = private unnamed_addr constant ptr @"$s17GiftUIFailureCore0A16UIDiagnosticSinkMp"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV" = protected unnamed_addr constant { i32 } zeroinitializer, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVWV" = internal constant %swift.vwtable { ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVwCP", ptr @__swift_noop_void_return, ptr @__swift_memcpy17_4, ptr @__swift_memcpy17_4, ptr @__swift_memcpy17_4, ptr @__swift_memcpy17_4, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVwet", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVwst", i32 17, i32 20, i32 131075, i32 254 }, align 4
@.str.35.GiftUIFailureDiagnosticsLayoutProbe = private constant [36 x i8] c"GiftUIFailureDiagnosticsLayoutProbe\00"
@"$s35GiftUIFailureDiagnosticsLayoutProbeMXM" = linkonce_odr hidden constant <{ i32, i32, i32 }> <{ i32 0, i32 0, i32 sub (i32 ptrtoint (ptr @.str.35.GiftUIFailureDiagnosticsLayoutProbe to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeMXM", i32 0, i32 2) to i32)) }>, section ".rodata", no_sanitize_address, align 4
@.str.32.GiftUIDiagnosticDeliveryCounters = private constant [33 x i8] c"GiftUIDiagnosticDeliveryCounters\00"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.32.GiftUIDiagnosticDeliveryCounters to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn", i32 0, i32 4) to i32)), i32 5, i32 2 }>, section ".rodata", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMf" = internal constant <{ ptr, ptr, i32, ptr, i32, i32, i32, i32, i32 }> <{ ptr null, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVWV", i32 512, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn", i32 0, i32 4, i32 8, i32 12, i32 16 }>, align 4
@"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$ss6UInt32VMn" = external global %swift.type_descriptor, align 4
@"got.$ss6UInt32VMn" = private unnamed_addr constant ptr @"$ss6UInt32VMn"
@"symbolic _____ s6UInt32V" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 sub (i32 ptrtoint (ptr @"got.$ss6UInt32VMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ s6UInt32V", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@0 = private constant [9 x i8] c"accepted\00", section "swift5_reflstr", no_sanitize_address
@1 = private constant [8 x i8] c"dropped\00", section "swift5_reflstr", no_sanitize_address
@2 = private constant [10 x i8] c"saturated\00", section "swift5_reflstr", no_sanitize_address
@3 = private constant [7 x i8] c"failed\00", section "swift5_reflstr", no_sanitize_address
@"symbolic Sb" = linkonce_odr hidden constant <{ [2 x i8], i8 }> <{ [2 x i8] c"Sb", i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@4 = private constant [18 x i8] c"countersSaturated\00", section "swift5_reflstr", no_sanitize_address
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV" to i32), i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF" to i32)), i32 0, i16 0, i16 12, i32 5, i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 6) to i32)), i32 sub (i32 ptrtoint (ptr @0 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 7) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 9) to i32)), i32 sub (i32 ptrtoint (ptr @1 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 10) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 12) to i32)), i32 sub (i32 ptrtoint (ptr @2 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 13) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 15) to i32)), i32 sub (i32 ptrtoint (ptr @3 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 16) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic Sb" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 18) to i32)), i32 sub (i32 ptrtoint (ptr @4 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 19) to i32)) }, section "swift5_fieldmd", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVWV" = internal constant %swift.vwtable { ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwCP", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwxx", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwcp", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwca", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwtk", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwta", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwet", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwst", i32 0, i32 0, i32 4194304, i32 0 }, align 4
@.str.25.GiftUIDiagnosticProjector = private constant [26 x i8] c"GiftUIDiagnosticProjector\00"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMI" = internal global [16 x ptr] zeroinitializer, align 4
@"symbolic x" = linkonce_odr hidden constant <{ [1 x i8], i8 }> <{ [1 x i8] c"x", i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }> <{ i32 209, i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.25.GiftUIDiagnosticProjector to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 4) to i32)), i32 3, i32 4, i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMI" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 7) to i32)), i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMP" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 8) to i32)), i16 1, i16 1, i16 2, i16 0, i8 -128, i8 0, i8 0, i8 0, i32 128, i32 sub (i32 ptrtoint (ptr @"symbolic x" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 18) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$s17GiftUIFailureCore0A16UIDiagnosticSinkMp" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 19) to i32)), i32 1) }>, section ".rodata", no_sanitize_address, align 4
@type_layout_5_2_fa_pod = private constant { i32, i32, i32, i32 } { i32 5, i32 6, i32 1, i32 250 }, align 4
@type_layout_17_4_fe_pod = private constant { i32, i32, i32, i32 } { i32 17, i32 20, i32 131075, i32 254 }, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMP" = internal constant <{ i32, i32, i32, i32 }> <{ i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMi" to i32), i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMP" to i32)), i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMr" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMP", i32 0, i32 1) to i32)), i32 1073741824, i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVWV" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMP", i32 0, i32 3) to i32)) }>, align 4
@"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s17GiftUIFailureCore0A21UIDiagnosticSelectionVMn" = external global %swift.type_descriptor, align 4
@"got.$s17GiftUIFailureCore0A21UIDiagnosticSelectionVMn" = private unnamed_addr constant ptr @"$s17GiftUIFailureCore0A21UIDiagnosticSelectionVMn"
@"symbolic _____ 17GiftUIFailureCore0A21UIDiagnosticSelectionV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 sub (i32 ptrtoint (ptr @"got.$s17GiftUIFailureCore0A21UIDiagnosticSelectionVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 17GiftUIFailureCore0A21UIDiagnosticSelectionV", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@5 = private constant [10 x i8] c"selection\00", section "swift5_reflstr", no_sanitize_address
@6 = private constant [5 x i8] c"sink\00", section "swift5_reflstr", no_sanitize_address
@7 = private constant [9 x i8] c"counters\00", section "swift5_reflstr", no_sanitize_address
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV" to i32), i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF" to i32)), i32 0, i16 0, i16 12, i32 3, i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A21UIDiagnosticSelectionV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF", i32 0, i32 6) to i32)), i32 sub (i32 ptrtoint (ptr @5 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF", i32 0, i32 7) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic x" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF", i32 0, i32 9) to i32)), i32 sub (i32 ptrtoint (ptr @6 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF", i32 0, i32 10) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF", i32 0, i32 12) to i32)), i32 sub (i32 ptrtoint (ptr @7 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF", i32 0, i32 13) to i32)) }, section "swift5_fieldmd", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVWV" = internal constant %swift.vwtable { ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVwCP", ptr @__swift_noop_void_return, ptr @__swift_memcpy392_4, ptr @__swift_memcpy392_4, ptr @__swift_memcpy392_4, ptr @__swift_memcpy392_4, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVwet", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVwst", i32 392, i32 392, i32 131075, i32 252 }, align 4
@.str.27.GiftUIFixedDiagnosticBuffer = private constant [28 x i8] c"GiftUIFixedDiagnosticBuffer\00"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.27.GiftUIFixedDiagnosticBuffer to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn", i32 0, i32 4) to i32)), i32 18, i32 2 }>, section ".rodata", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMf" = internal constant <{ ptr, ptr, i32, ptr, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }> <{ ptr null, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVWV", i32 512, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn", i32 0, i32 4, i32 8, i32 32, i32 56, i32 80, i32 104, i32 128, i32 152, i32 176, i32 200, i32 224, i32 248, i32 272, i32 296, i32 320, i32 344, i32 368 }>, align 4
@"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$ss5UInt8VMn" = external global %swift.type_descriptor, align 4
@"got.$ss5UInt8VMn" = private unnamed_addr constant ptr @"$ss5UInt8VMn"
@"symbolic _____ s5UInt8V" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 sub (i32 ptrtoint (ptr @"got.$ss5UInt8VMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ s5UInt8V", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@8 = private constant [6 x i8] c"count\00", section "swift5_reflstr", no_sanitize_address
@9 = private constant [19 x i8] c"droppedRecordCount\00", section "swift5_reflstr", no_sanitize_address
@"$s17GiftUIFailureCore0A18UIDiagnosticRecordVMn" = external global %swift.type_descriptor, align 4
@"got.$s17GiftUIFailureCore0A18UIDiagnosticRecordVMn" = private unnamed_addr constant ptr @"$s17GiftUIFailureCore0A18UIDiagnosticRecordVMn"
@"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 sub (i32 ptrtoint (ptr @"got.$s17GiftUIFailureCore0A18UIDiagnosticRecordVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@10 = private constant [8 x i8] c"record0\00", section "swift5_reflstr", no_sanitize_address
@11 = private constant [8 x i8] c"record1\00", section "swift5_reflstr", no_sanitize_address
@12 = private constant [8 x i8] c"record2\00", section "swift5_reflstr", no_sanitize_address
@13 = private constant [8 x i8] c"record3\00", section "swift5_reflstr", no_sanitize_address
@14 = private constant [8 x i8] c"record4\00", section "swift5_reflstr", no_sanitize_address
@15 = private constant [8 x i8] c"record5\00", section "swift5_reflstr", no_sanitize_address
@16 = private constant [8 x i8] c"record6\00", section "swift5_reflstr", no_sanitize_address
@17 = private constant [8 x i8] c"record7\00", section "swift5_reflstr", no_sanitize_address
@18 = private constant [8 x i8] c"record8\00", section "swift5_reflstr", no_sanitize_address
@19 = private constant [8 x i8] c"record9\00", section "swift5_reflstr", no_sanitize_address
@20 = private constant [9 x i8] c"record10\00", section "swift5_reflstr", no_sanitize_address
@21 = private constant [9 x i8] c"record11\00", section "swift5_reflstr", no_sanitize_address
@22 = private constant [9 x i8] c"record12\00", section "swift5_reflstr", no_sanitize_address
@23 = private constant [9 x i8] c"record13\00", section "swift5_reflstr", no_sanitize_address
@24 = private constant [9 x i8] c"record14\00", section "swift5_reflstr", no_sanitize_address
@25 = private constant [9 x i8] c"record15\00", section "swift5_reflstr", no_sanitize_address
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV" to i32), i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF" to i32)), i32 0, i16 0, i16 12, i32 18, i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ s5UInt8V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 6) to i32)), i32 sub (i32 ptrtoint (ptr @8 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 7) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 9) to i32)), i32 sub (i32 ptrtoint (ptr @9 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 10) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 12) to i32)), i32 sub (i32 ptrtoint (ptr @10 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 13) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 15) to i32)), i32 sub (i32 ptrtoint (ptr @11 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 16) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 18) to i32)), i32 sub (i32 ptrtoint (ptr @12 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 19) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 21) to i32)), i32 sub (i32 ptrtoint (ptr @13 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 22) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 24) to i32)), i32 sub (i32 ptrtoint (ptr @14 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 25) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 27) to i32)), i32 sub (i32 ptrtoint (ptr @15 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 28) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 30) to i32)), i32 sub (i32 ptrtoint (ptr @16 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 31) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 33) to i32)), i32 sub (i32 ptrtoint (ptr @17 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 34) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 36) to i32)), i32 sub (i32 ptrtoint (ptr @18 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 37) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 39) to i32)), i32 sub (i32 ptrtoint (ptr @19 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 40) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 42) to i32)), i32 sub (i32 ptrtoint (ptr @20 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 43) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 45) to i32)), i32 sub (i32 ptrtoint (ptr @21 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 46) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 48) to i32)), i32 sub (i32 ptrtoint (ptr @22 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 49) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 51) to i32)), i32 sub (i32 ptrtoint (ptr @23 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 52) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 54) to i32)), i32 sub (i32 ptrtoint (ptr @24 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 55) to i32)), i32 2, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 57) to i32)), i32 sub (i32 ptrtoint (ptr @25 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 58) to i32)) }, section "swift5_fieldmd", no_sanitize_address, align 4
@"$sytWV" = external global ptr, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 82, i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.35.GiftUIFailureDiagnosticsLayoutProbe to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn", i32 0, i32 4) to i32)), i32 0, i32 0 }>, section ".rodata", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMf" = internal constant <{ ptr, ptr, i32, ptr }> <{ ptr null, ptr @"$sytWV", i32 513, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn" }>, align 4
@"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbeAAO" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbeAAO", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMF" = internal constant { i32, i32, i16, i16, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbeAAO" to i32), i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMF" to i32)), i32 0, i16 2, i16 12, i32 0 }, section "swift5_fieldmd", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc" to i32), i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAMc" to i32), i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn" to i32), i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn" to i32), i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn" to i32), i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbeAAOHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn" to i32), i32 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@_swift1_autolink_entries = private constant [77 x i8] c"-lswift_Concurrency\00-lswiftCore\00-lswift_StringProcessing\00-lswift_RegexParser\00", section ".swift1_autolink_entries", no_sanitize_address, align 4
@llvm.used = appending global [83 x ptr] [ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV4sinkxvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV7project4kind6origin8severity6recordy0aB4Core0aF4KindO_AI0aB6OriginOAI0aF8SeverityOAI0aF6RecordVyXEtF", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV8countersAA0aF16DeliveryCountersVvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV9selection0aB4Core0aF9SelectionVvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV9selection4sinkACyxG0aB4Core0aF9SelectionV_xtcfC", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVHn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMa", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAHc", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAMc", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAWP", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCountACs6UInt32V_tcfC", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCounts6UInt32Vvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCounts6UInt32Vvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV5counts5UInt8Vvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV5counts5UInt8Vvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7consumey0aB4Core0A22UIDiagnosticSinkResultOAE0aK6RecordVF", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record133_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record233_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record333_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record433_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record533_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record633_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record733_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record833_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record933_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8Vvau", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvgZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvpZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1133_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1233_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1333_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1433_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1533_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVACycfC", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVHn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMa", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVN", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVy0aB4Core0A18UIDiagnosticRecordVSgs5UInt8Vcig", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV17countersSaturatedSbvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV17countersSaturatedSbvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6faileds6UInt32Vvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6faileds6UInt32Vvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV7droppeds6UInt32Vvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV7droppeds6UInt32Vvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepted7dropped9saturated6failed17countersSaturatedACs6UInt32V_A3JSbtcfC", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepted7dropped9saturated6failed17countersSaturatedACs6UInt32V_A3JSbtcfcfA3_", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32Vvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32Vvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV9saturateds6UInt32Vvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV9saturateds6UInt32Vvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVACycfC", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVHn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMa", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVN", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAHc", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO20deliveryCountersSizes6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO22deliveryCountersStrides6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO23diagnosticProjectorSizes6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO25deliveryCountersAlignments6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO25diagnosticProjectorStrides6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO25fixedDiagnosticBufferSizes6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO27fixedDiagnosticBufferStrides6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO28diagnosticProjectorAlignments6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO29fixedDiagnosticBufferCapacitys5UInt8VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO30fixedDiagnosticBufferAlignments6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOHn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMF", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMa", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAON", ptr @__swift_reflection_version, ptr @_swift1_autolink_entries], section "llvm.metadata"

@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV7droppeds6UInt32VvpMV" = protected alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV9saturateds6UInt32VvpMV" = protected alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6faileds6UInt32VvpMV" = protected alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV17countersSaturatedSbvpMV" = protected alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV9selection0aB4Core0aF9SelectionVvpMV" = protected alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV4sinkxvpMV" = protected alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV8countersAA0aF16DeliveryCountersVvpMV" = protected alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV5counts5UInt8VvpMV" = protected alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCounts6UInt32VvpMV" = protected alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvpZMV" = protected alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVy0aB4Core0A18UIDiagnosticRecordVSgs5UInt8VcipMV" = protected alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVN" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMf", i32 0, i32 2)
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVN" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMf", i32 0, i32 2)
@"$s35GiftUIFailureDiagnosticsLayoutProbeAAON" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMf", i32 0, i32 2)

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32Vvpfi"() #0 {
entry:
  ret i32 0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) #1 {
entry:
  %1 = load i32, ptr %0, align 4
  ret i32 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV7droppeds6UInt32Vvpfi"() #0 {
entry:
  ret i32 0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV7droppeds6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) #1 {
entry:
  %.dropped = getelementptr inbounds nuw i8, ptr %0, i32 4
  %1 = load i32, ptr %.dropped, align 4
  ret i32 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV9saturateds6UInt32Vvpfi"() #0 {
entry:
  ret i32 0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV9saturateds6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) #1 {
entry:
  %.saturated = getelementptr inbounds nuw i8, ptr %0, i32 8
  %1 = load i32, ptr %.saturated, align 4
  ret i32 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6faileds6UInt32Vvpfi"() #0 {
entry:
  ret i32 0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6faileds6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) #1 {
entry:
  %.failed = getelementptr inbounds nuw i8, ptr %0, i32 12
  %1 = load i32, ptr %.failed, align 4
  ret i32 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i1 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV17countersSaturatedSbvpfi"() #0 {
entry:
  ret i1 false
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc i1 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV17countersSaturatedSbvg"(ptr noalias readonly swiftself captures(none) dereferenceable(17) %0) #1 {
entry:
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %0, i32 16
  %1 = load i1, ptr %.countersSaturated, align 4
  ret i1 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVACycfC"(ptr noalias writeonly sret(%T35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV) captures(none) initializes((0, 17)) %0) #2 {
entry:
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(17) %0, i8 0, i64 17, i1 false)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i1 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepted7dropped9saturated6failed17countersSaturatedACs6UInt32V_A3JSbtcfcfA3_"() #0 {
entry:
  ret i1 false
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepted7dropped9saturated6failed17countersSaturatedACs6UInt32V_A3JSbtcfC"(ptr noalias writeonly sret(%T35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV) captures(none) initializes((0, 17)) %0, i32 %1, i32 %2, i32 %3, i32 %4, i1 %5) #2 {
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

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
define hidden swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6recordyy0aB4Core0aF10SinkResultOF"(i8 %0, ptr swiftself captures(none) dereferenceable(17) %1) local_unnamed_addr #3 {
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

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc i1 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias readonly captures(none) dereferenceable(17) %0, ptr noalias readonly captures(none) dereferenceable(17) %1) #1 {
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

define linkonce_odr hidden swiftcc i1 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias captures(none) dereferenceable(17) %0, ptr noalias captures(none) dereferenceable(17) %1, ptr swiftself %2, ptr %Self, ptr %SelfWitnessTable) #6 {
entry:
  %3 = load i32, ptr %0, align 4
  %.dropped = getelementptr inbounds nuw i8, ptr %0, i32 4
  %4 = load i32, ptr %.dropped, align 4
  %.saturated = getelementptr inbounds nuw i8, ptr %0, i32 8
  %5 = load i32, ptr %.saturated, align 4
  %.failed = getelementptr inbounds nuw i8, ptr %0, i32 12
  %6 = load i32, ptr %.failed, align 4
  %7 = load i32, ptr %1, align 4
  %.dropped2 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %8 = load i32, ptr %.dropped2, align 4
  %.saturated3 = getelementptr inbounds nuw i8, ptr %1, i32 8
  %9 = load i32, ptr %.saturated3, align 4
  %.failed4 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %10 = load i32, ptr %.failed4, align 4
  %11 = icmp eq i32 %3, %7
  %12 = icmp eq i32 %4, %8
  %or.cond = select i1 %11, i1 %12, i1 false
  %13 = icmp eq i32 %5, %9
  %or.cond6 = select i1 %or.cond, i1 %13, i1 false
  %14 = icmp eq i32 %6, %10
  %or.cond7 = select i1 %or.cond6, i1 %14, i1 false
  br i1 %or.cond7, label %15, label %20

15:                                               ; preds = %entry
  %.countersSaturated5 = getelementptr inbounds nuw i8, ptr %1, i32 16
  %16 = load i1, ptr %.countersSaturated5, align 4
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %0, i32 16
  %17 = load i1, ptr %.countersSaturated, align 4
  %18 = xor i1 %16, %17
  %19 = xor i1 %18, true
  br label %20

20:                                               ; preds = %15, %entry
  %21 = phi i1 [ false, %entry ], [ %19, %15 ]
  ret i1 %21
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc { i32, i8 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV9selection0aB4Core0aF9SelectionVvg"(ptr readnone captures(none) %"GiftUIDiagnosticProjector<Sink>", ptr noalias readonly swiftself captures(none) %0) #1 {
entry:
  %1 = load i8, ptr %0, align 4
  %.selection.originMask = getelementptr inbounds nuw i8, ptr %0, i32 2
  %2 = load i16, ptr %.selection.originMask, align 2
  %.selection.minimumSeverity = getelementptr inbounds nuw i8, ptr %0, i32 4
  %3 = load i8, ptr %.selection.minimumSeverity, align 4
  %temp-coercion.coerced.sroa.0.0.insert.ext = zext i8 %1 to i32
  %temp-coercion.coerced.sroa.0.2.insert.ext = zext i16 %2 to i32
  %temp-coercion.coerced.sroa.0.2.insert.shift = shl nuw i32 %temp-coercion.coerced.sroa.0.2.insert.ext, 16
  %temp-coercion.coerced.sroa.0.2.insert.insert = or disjoint i32 %temp-coercion.coerced.sroa.0.2.insert.shift, %temp-coercion.coerced.sroa.0.0.insert.ext
  %4 = insertvalue { i32, i8 } undef, i32 %temp-coercion.coerced.sroa.0.2.insert.insert, 0
  %5 = insertvalue { i32, i8 } %4, i8 %3, 1
  ret { i32, i8 } %5
}

define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV4sinkxvg"(ptr noalias sret(%swift.opaque) %0, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>", ptr noalias swiftself %1) #6 {
entry:
  %2 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 20
  %3 = load i32, ptr %2, align 4
  %4 = getelementptr inbounds i8, ptr %1, i32 %3
  %5 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 8
  %Sink = load ptr, ptr %5, align 4, !invariant.load !6
  %6 = getelementptr inbounds i8, ptr %Sink, i32 -4
  %Sink.valueWitnesses = load ptr, ptr %6, align 4, !invariant.load !6, !dereferenceable !7
  %7 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 8
  %InitializeWithCopy = load ptr, ptr %7, align 4, !invariant.load !6
  %8 = tail call ptr %InitializeWithCopy(ptr noalias %0, ptr noalias %4, ptr %Sink) #18
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV8countersAA0aF16DeliveryCountersVvg"(ptr noalias writeonly sret(%T35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV) captures(none) initializes((0, 17)) %0, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>", ptr noalias readonly swiftself captures(none) %1) #3 {
entry:
  %2 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 24
  %3 = load i32, ptr %2, align 4
  %4 = getelementptr inbounds i8, ptr %1, i32 %3
  %5 = load i32, ptr %4, align 4
  %.dropped = getelementptr inbounds nuw i8, ptr %4, i32 4
  %6 = load i32, ptr %.dropped, align 4
  %.saturated = getelementptr inbounds nuw i8, ptr %4, i32 8
  %7 = load i32, ptr %.saturated, align 4
  %.failed = getelementptr inbounds nuw i8, ptr %4, i32 12
  %8 = load i32, ptr %.failed, align 4
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %4, i32 16
  %9 = load i1, ptr %.countersSaturated, align 4
  store i32 %5, ptr %0, align 4
  %.dropped2 = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %6, ptr %.dropped2, align 4
  %.saturated3 = getelementptr inbounds nuw i8, ptr %0, i32 8
  store i32 %7, ptr %.saturated3, align 4
  %.failed4 = getelementptr inbounds nuw i8, ptr %0, i32 12
  store i32 %8, ptr %.failed4, align 4
  %.countersSaturated5 = getelementptr inbounds nuw i8, ptr %0, i32 16
  %10 = zext i1 %9 to i8
  store i8 %10, ptr %.countersSaturated5, align 4
  ret void
}

define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV9selection4sinkACyxG0aB4Core0aF9SelectionV_xtcfC"(ptr noalias sret(%swift.opaque) initializes((0, 1), (2, 5)) %0, i32 %1, i8 %2, ptr noalias %3, ptr %Sink, ptr %Sink.GiftUIDiagnosticSink) #6 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i32 %1 to i8
  %temp-coercion.coerced.sroa.0.2.extract.shift = lshr i32 %1, 16
  %temp-coercion.coerced.sroa.0.2.extract.trunc = trunc nuw i32 %temp-coercion.coerced.sroa.0.2.extract.shift to i16
  store i8 %temp-coercion.coerced.sroa.0.0.extract.trunc, ptr %0, align 4
  %.selection.originMask = getelementptr inbounds nuw i8, ptr %0, i32 2
  store i16 %temp-coercion.coerced.sroa.0.2.extract.trunc, ptr %.selection.originMask, align 2
  %.selection.minimumSeverity = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i8 %2, ptr %.selection.minimumSeverity, align 4
  %4 = tail call swiftcc %swift.metadata_response @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMa"(i32 0, ptr %Sink, ptr %Sink.GiftUIDiagnosticSink) #25
  %5 = extractvalue %swift.metadata_response %4, 0
  %6 = getelementptr inbounds nuw i8, ptr %5, i32 20
  %7 = load i32, ptr %6, align 4
  %8 = getelementptr inbounds i8, ptr %0, i32 %7
  %9 = getelementptr inbounds i8, ptr %Sink, i32 -4
  %Sink.valueWitnesses = load ptr, ptr %9, align 4, !invariant.load !6, !dereferenceable !7
  %10 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 16
  %InitializeWithTake = load ptr, ptr %10, align 4, !invariant.load !6
  %11 = tail call ptr %InitializeWithTake(ptr noalias nonnull %8, ptr noalias %3, ptr %Sink) #18
  %12 = getelementptr inbounds nuw i8, ptr %5, i32 24
  %13 = load i32, ptr %12, align 4
  %14 = getelementptr inbounds i8, ptr %0, i32 %13
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(17) %14, i8 0, i64 17, i1 false)
  ret void
}

; Function Attrs: mustprogress nofree noinline nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMa"(i32 %0, ptr readnone %1, ptr readnone %2) #7 {
entry:
  %3 = tail call swiftcc %swift.metadata_response @__swift_instantiateGenericMetadata(i32 %0, ptr %1, ptr %2, ptr undef, ptr nonnull @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn") #25
  ret %swift.metadata_response %3
}

define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV7project4kind6origin8severity6recordy0aB4Core0aF4KindO_AI0aB6OriginOAI0aF8SeverityOAI0aF6RecordVyXEtF"(i8 %0, i8 %1, i8 %2, ptr readonly captures(none) %3, ptr %4, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>", ptr swiftself %5) #6 {
entry:
  %6 = alloca %T17GiftUIFailureCore0A18UIDiagnosticRecordV, align 4
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %6)
  %7 = load i8, ptr %5, align 4
  %.selection.originMask = getelementptr inbounds nuw i8, ptr %5, i32 2
  %8 = load i16, ptr %.selection.originMask, align 2
  %.selection.minimumSeverity = getelementptr inbounds nuw i8, ptr %5, i32 4
  %9 = load i8, ptr %.selection.minimumSeverity, align 4
  %temp-coercion.coerced.sroa.0.0.insert.ext = zext i8 %7 to i32
  %temp-coercion.coerced.sroa.0.2.insert.ext = zext i16 %8 to i32
  %temp-coercion.coerced.sroa.0.2.insert.shift = shl nuw i32 %temp-coercion.coerced.sroa.0.2.insert.ext, 16
  %temp-coercion.coerced.sroa.0.2.insert.insert = or disjoint i32 %temp-coercion.coerced.sroa.0.2.insert.shift, %temp-coercion.coerced.sroa.0.0.insert.ext
  %10 = tail call swiftcc i1 @"$s17GiftUIFailureCore0A21UIDiagnosticSelectionV8includes4kind6origin8severitySbAA0aD4KindO_AA0aB6OriginOAA0aD8SeverityOtF"(i8 %0, i8 %1, i8 %2, i32 %temp-coercion.coerced.sroa.0.2.insert.insert, i8 %9)
  br i1 %10, label %11, label %23

11:                                               ; preds = %entry
  call swiftcc void %3(ptr noalias nonnull sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) %6, ptr swiftself %4)
  %12 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 20
  %13 = load i32, ptr %12, align 4
  %14 = getelementptr inbounds i8, ptr %5, i32 %13
  %15 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 12
  %Sink.GiftUIDiagnosticSink = load ptr, ptr %15, align 4, !invariant.load !6
  %16 = getelementptr inbounds nuw i8, ptr %Sink.GiftUIDiagnosticSink, i32 4
  %17 = load ptr, ptr %16, align 4, !invariant.load !6
  %18 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 8
  %Sink = load ptr, ptr %18, align 4, !invariant.load !6
  %19 = call swiftcc i8 %17(ptr noalias nonnull captures(none) dereferenceable(24) %6, ptr nonnull swiftself %14, ptr %Sink, ptr %Sink.GiftUIDiagnosticSink)
  %20 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 24
  %21 = load i32, ptr %20, align 4
  %22 = getelementptr inbounds i8, ptr %5, i32 %21
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6recordyy0aB4Core0aF10SinkResultOF"(i8 %19, ptr swiftself captures(none) dereferenceable(17) %22)
  br label %23

23:                                               ; preds = %entry, %11
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %6)
  ret void
}

declare swiftcc i1 @"$s17GiftUIFailureCore0A21UIDiagnosticSelectionV8includes4kind6origin8severitySbAA0aD4KindO_AA0aB6OriginOAA0aD8SeverityOtF"(i8, i8, i8, i32, i8) local_unnamed_addr #6

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i8 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV5counts5UInt8Vvpfi"() #0 {
entry:
  ret i8 0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc i8 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV5counts5UInt8Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(392) %0) #1 {
entry:
  %1 = load i8, ptr %0, align 4
  ret i8 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCounts6UInt32Vvpfi"() #0 {
entry:
  ret i32 0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCounts6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(392) %0) #1 {
entry:
  %.droppedRecordCount = getelementptr inbounds nuw i8, ptr %0, i32 4
  %1 = load i32, ptr %.droppedRecordCount, align 4
  ret i32 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef nonnull ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8Vvau"() #0 {
entry:
  ret ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvpZ"
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i8 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvgZ"() #0 {
entry:
  ret i8 16
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
entry:
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(24) %0, i8 0, i64 24, i1 false)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVACycfC"(ptr noalias writeonly sret(%T35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV) captures(none) initializes((0, 1), (4, 392)) %0) #2 {
entry:
  store i8 0, ptr %0, align 4
  %.sroa.5.0..sroa_idx157 = getelementptr inbounds nuw i8, ptr %0, i32 4
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(388) %.sroa.5.0..sroa_idx157, i8 0, i64 388, i1 false)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCountACs6UInt32V_tcfC"(ptr noalias writeonly sret(%T35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV) captures(none) initializes((0, 1), (4, 392)) %0, i32 %1) #2 {
entry:
  store i8 0, ptr %0, align 4
  %.sroa.5.0..sroa_idx157 = getelementptr inbounds nuw i8, ptr %0, i32 4
  store i32 %1, ptr %.sroa.5.0..sroa_idx157, align 4
  %.sroa.6.0..sroa_idx158 = getelementptr inbounds nuw i8, ptr %0, i32 8
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(384) %.sroa.6.0..sroa_idx158, i8 0, i64 384, i1 false)
  ret void
}

; Function Attrs: nounwind memory(argmem: readwrite, inaccessiblemem: write)
define protected swiftcc range(i8 0, 3) i8 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7consumey0aB4Core0A22UIDiagnosticSinkResultOAE0aK6RecordVF"(ptr noalias readonly captures(none) dereferenceable(24) %0, ptr swiftself captures(none) dereferenceable(392) %1) #8 {
entry:
  %2 = load i8, ptr %1, align 4
  %3 = icmp ult i8 %2, 16
  br i1 %3, label %switch.lookup, label %10

switch.lookup:                                    ; preds = %entry
  %switch.idx.cast = zext nneg i8 %2 to i32
  %switch.idx.mult = mul nuw nsw i32 %switch.idx.cast, 24
  %4 = getelementptr inbounds nuw i8, ptr %1, i32 %switch.idx.mult
  %.record0.i = getelementptr inbounds nuw i8, ptr %4, i32 8
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(24) %.record0.i, ptr noundef nonnull readonly align 4 dereferenceable(24) %0, i32 24, i1 false)
  %5 = load i8, ptr %1, align 4
  %6 = tail call { i8, i1 } @llvm.uadd.with.overflow.i8(i8 %5, i8 1)
  %7 = extractvalue { i8, i1 } %6, 1
  br i1 %7, label %16, label %8, !prof !8

8:                                                ; preds = %switch.lookup
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

16:                                               ; preds = %switch.lookup
  tail call void @llvm.trap() #26
  unreachable
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i8, i1 } @llvm.uadd.with.overflow.i8(i8, i8) #9

; Function Attrs: cold noreturn nounwind memory(inaccessiblemem: write)
declare void @llvm.trap() #10

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVy0aB4Core0A18UIDiagnosticRecordVSgs5UInt8Vcig"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordVSg) captures(none) initializes((0, 24)) %0, i8 %1, ptr noalias readonly swiftself captures(none) dereferenceable(392) %2) #3 {
entry:
  %.sroa.0.0.copyload = load i8, ptr %2, align 4
  %3 = icmp ult i8 %1, %.sroa.0.0.copyload
  %4 = icmp ult i8 %1, 16
  %or.cond = and i1 %3, %4
  br i1 %or.cond, label %switch.lookup, label %"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV12storedRecord33_481FAB364D938FDBB52660A85D053959LL2at0aB4Core0a12UIDiagnosticJ0VSgs5UInt8V_tF.exit"

switch.lookup:                                    ; preds = %entry
  %switch.idx.cast = zext nneg i8 %1 to i32
  %switch.idx.mult = mul nuw nsw i32 %switch.idx.cast, 24
  %switch.idx.cast1 = zext nneg i8 %1 to i32
  %switch.idx.mult2 = mul nuw nsw i32 %switch.idx.cast1, 24
  %switch.idx.cast4 = zext nneg i8 %1 to i32
  %switch.idx.mult5 = mul nuw nsw i32 %switch.idx.cast4, 24
  %switch.idx.cast7 = zext nneg i8 %1 to i32
  %switch.idx.mult8 = mul nuw nsw i32 %switch.idx.cast7, 24
  %switch.idx.cast10 = zext nneg i8 %1 to i32
  %switch.idx.mult11 = mul nuw nsw i32 %switch.idx.cast10, 24
  %switch.idx.cast13 = zext nneg i8 %1 to i32
  %switch.idx.mult14 = mul nuw nsw i32 %switch.idx.cast13, 24
  %5 = getelementptr inbounds nuw i8, ptr %2, i32 %switch.idx.mult
  %.record0.i = getelementptr inbounds nuw i8, ptr %5, i32 8
  %.sroa.0.0.copyload.i = load i32, ptr %.record0.i, align 4, !alias.scope !9, !noalias !12
  %6 = getelementptr inbounds nuw i8, ptr %2, i32 %switch.idx.mult2
  %.sroa.4.0..record0.sroa_idx.i = getelementptr inbounds nuw i8, ptr %6, i32 12
  %.sroa.4.0.copyload.i = load i32, ptr %.sroa.4.0..record0.sroa_idx.i, align 4, !alias.scope !9, !noalias !12
  %7 = getelementptr inbounds nuw i8, ptr %2, i32 %switch.idx.mult5
  %.sroa.5.0..record0.sroa_idx.i = getelementptr inbounds nuw i8, ptr %7, i32 16
  %.sroa.5.0.copyload.i = load i32, ptr %.sroa.5.0..record0.sroa_idx.i, align 4, !alias.scope !9, !noalias !12
  %8 = getelementptr inbounds nuw i8, ptr %2, i32 %switch.idx.mult8
  %.sroa.6.0..record0.sroa_idx.i = getelementptr inbounds nuw i8, ptr %8, i32 20
  %.sroa.6.0.copyload.i = load i32, ptr %.sroa.6.0..record0.sroa_idx.i, align 4, !alias.scope !9, !noalias !12
  %9 = getelementptr inbounds nuw i8, ptr %2, i32 %switch.idx.mult11
  %.sroa.7.0..record0.sroa_idx.i = getelementptr inbounds nuw i8, ptr %9, i32 24
  %.sroa.7.0.copyload.i = load i32, ptr %.sroa.7.0..record0.sroa_idx.i, align 4, !alias.scope !9, !noalias !12
  %10 = getelementptr inbounds nuw i8, ptr %2, i32 %switch.idx.mult14
  %.sroa.8.0..record0.sroa_idx.i = getelementptr inbounds nuw i8, ptr %10, i32 28
  %.sroa.8.0.copyload.i = load i32, ptr %.sroa.8.0..record0.sroa_idx.i, align 4, !alias.scope !9, !noalias !12
  br label %"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV12storedRecord33_481FAB364D938FDBB52660A85D053959LL2at0aB4Core0a12UIDiagnosticJ0VSgs5UInt8V_tF.exit"

"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV12storedRecord33_481FAB364D938FDBB52660A85D053959LL2at0aB4Core0a12UIDiagnosticJ0VSgs5UInt8V_tF.exit": ; preds = %switch.lookup, %entry
  %11 = phi i32 [ 4, %entry ], [ %.sroa.0.0.copyload.i, %switch.lookup ]
  %12 = phi i32 [ 0, %entry ], [ %.sroa.4.0.copyload.i, %switch.lookup ]
  %13 = phi i32 [ 0, %entry ], [ %.sroa.5.0.copyload.i, %switch.lookup ]
  %14 = phi i32 [ 0, %entry ], [ %.sroa.6.0.copyload.i, %switch.lookup ]
  %15 = phi i32 [ 0, %entry ], [ %.sroa.7.0.copyload.i, %switch.lookup ]
  %16 = phi i32 [ 0, %entry ], [ %.sroa.8.0.copyload.i, %switch.lookup ]
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

define linkonce_odr hidden swiftcc i8 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAadEP7consumeyAD0ajK6ResultOAD0aJ6RecordVFTW"(ptr noalias captures(none) dereferenceable(24) %0, ptr swiftself captures(none) dereferenceable(392) %1, ptr %Self, ptr %SelfWitnessTable) #6 {
entry:
  %2 = tail call swiftcc i8 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7consumey0aB4Core0A22UIDiagnosticSinkResultOAE0aK6RecordVF"(ptr noalias nonnull captures(none) dereferenceable(24) %0, ptr nonnull swiftself captures(none) dereferenceable(392) %1) #27
  ret i8 %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO20deliveryCountersSizes6UInt32VyFZ"() #11 {
entry:
  ret i32 17
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO22deliveryCountersStrides6UInt32VyFZ"() #11 {
entry:
  ret i32 20
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO25deliveryCountersAlignments6UInt32VyFZ"() #11 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO23diagnosticProjectorSizes6UInt32VyFZ"() #11 {
entry:
  ret i32 417
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO25diagnosticProjectorStrides6UInt32VyFZ"() #11 {
entry:
  ret i32 420
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO28diagnosticProjectorAlignments6UInt32VyFZ"() #11 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO25fixedDiagnosticBufferSizes6UInt32VyFZ"() #11 {
entry:
  ret i32 392
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO27fixedDiagnosticBufferStrides6UInt32VyFZ"() #11 {
entry:
  ret i32 392
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO30fixedDiagnosticBufferAlignments6UInt32VyFZ"() #11 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i8 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO29fixedDiagnosticBufferCapacitys5UInt8VyFZ"() #11 {
entry:
  ret i8 16
}

; Function Attrs: mustprogress nounwind willreturn
declare ptr @swift_retain(ptr returned) local_unnamed_addr #12

; Function Attrs: nounwind
define linkonce_odr hidden void @__swift_noop_void_return(ptr %0, ptr %1) #13 {
entry:
  ret void
}

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy17_4(ptr %0, ptr %1, ptr %2) #13 {
entry:
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(17) %0, ptr noundef nonnull align 4 dereferenceable(17) %1, i32 17, i1 false)
  ret ptr %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %GiftUIDiagnosticDeliveryCounters) #1 {
entry:
  %0 = icmp eq i32 %numEmptyCases, 0
  br i1 %0, label %21, label %1

1:                                                ; preds = %entry
  %2 = icmp ugt i32 %numEmptyCases, 254
  br i1 %2, label %3, label %11

3:                                                ; preds = %1
  %4 = getelementptr inbounds nuw i8, ptr %value, i32 17
  %5 = load i8, ptr %4, align 1
  %6 = icmp eq i8 %5, 0
  br i1 %6, label %11, label %7

7:                                                ; preds = %3
  %8 = load i136, ptr %value, align 1
  %9 = trunc i136 %8 to i32
  %10 = add i32 %9, 254
  br label %21

11:                                               ; preds = %3, %1
  %value.countersSaturated = getelementptr inbounds nuw i8, ptr %value, i32 16
  %12 = load i8, ptr %value.countersSaturated, align 4
  %13 = icmp ult i8 %12, 2
  br i1 %13, label %21, label %14

14:                                               ; preds = %11
  %15 = zext i8 %12 to i31
  %16 = and i31 %15, 1
  %17 = and i31 %15, 254
  %18 = add nsw i31 %17, -2
  %19 = or disjoint i31 %18, %16
  %20 = zext nneg i31 %19 to i32
  br label %21

21:                                               ; preds = %entry, %11, %14, %7
  %22 = phi i32 [ %10, %7 ], [ -1, %11 ], [ %20, %14 ], [ -1, %entry ]
  %23 = add i32 %22, 1
  ret i32 %23
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define internal void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %GiftUIDiagnosticDeliveryCounters) #2 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i32 17
  %1 = icmp ugt i32 %numEmptyCases, 254
  %2 = icmp ult i32 %whichCase, 255
  br i1 %2, label %3, label %14

3:                                                ; preds = %entry
  br i1 %1, label %4, label %5

4:                                                ; preds = %3
  store i8 0, ptr %0, align 1
  br label %5

5:                                                ; preds = %3, %4
  %6 = icmp eq i32 %whichCase, 0
  br i1 %6, label %18, label %7

7:                                                ; preds = %5
  %value.countersSaturated = getelementptr inbounds nuw i8, ptr %value, i32 16
  %8 = trunc nuw i32 %whichCase to i8
  %9 = add i8 %8, -1
  %10 = and i8 %9, 1
  %11 = and i8 %9, -2
  %12 = add nuw i8 %11, 2
  %13 = or disjoint i8 %12, %10
  store i8 %13, ptr %value.countersSaturated, align 4
  br label %18

14:                                               ; preds = %entry
  %15 = add i32 %whichCase, -255
  store i32 %15, ptr %value, align 4
  %16 = getelementptr inbounds nuw i8, ptr %value, i32 4
  tail call void @llvm.memset.p0.i32(ptr noundef nonnull align 4 dereferenceable(13) %16, i8 0, i32 13, i1 false)
  br i1 %1, label %17, label %18

17:                                               ; preds = %14
  store i8 1, ptr %0, align 1
  br label %18

18:                                               ; preds = %14, %17, %7, %5
  ret void
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i32(ptr writeonly captures(none), i8, i32, i1 immarg) #14

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMa"(i32 %0) #15 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: nounwind
define internal ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMi"(ptr %0, ptr %1, ptr %2) #16 {
entry:
  %3 = tail call ptr @swift_allocateGenericValueMetadata(ptr %0, ptr %1, ptr %2, i32 20) #18
  ret ptr %3
}

; Function Attrs: nounwind
define internal swiftcc %swift.metadata_response @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMr"(ptr %"GiftUIDiagnosticProjector<Sink>", ptr readnone captures(none) %0, ptr readnone captures(none) %1) #16 {
entry:
  %classFields = alloca [3 x ptr], align 4
  call void @llvm.lifetime.start.p0(i64 12, ptr nonnull %classFields)
  store ptr @type_layout_5_2_fa_pod, ptr %classFields, align 4
  %2 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 8
  %Sink = load ptr, ptr %2, align 4, !invariant.load !6
  %3 = tail call swiftcc %swift.metadata_response @swift_checkMetadataState(i32 319, ptr %Sink) #28
  %4 = extractvalue %swift.metadata_response %3, 0
  %5 = extractvalue %swift.metadata_response %3, 1
  %6 = icmp ult i32 %5, 64
  br i1 %6, label %dependency-satisfied, label %metadata-dependencies.cont

dependency-satisfied:                             ; preds = %entry
  %7 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 16
  %8 = getelementptr inbounds i8, ptr %4, i32 -4
  %.valueWitnesses = load ptr, ptr %8, align 4, !invariant.load !6, !dereferenceable !7
  %9 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i32 32
  %10 = getelementptr inbounds nuw i8, ptr %classFields, i32 4
  store ptr %9, ptr %10, align 4
  %11 = getelementptr inbounds nuw i8, ptr %classFields, i32 8
  store ptr @type_layout_17_4_fe_pod, ptr %11, align 4
  call void @swift_initStructMetadata(ptr nonnull %"GiftUIDiagnosticProjector<Sink>", i32 0, i32 3, ptr nonnull %classFields, ptr nonnull %7) #18
  call void @llvm.lifetime.end.p0(i64 12, ptr nonnull %classFields)
  br label %metadata-dependencies.cont

metadata-dependencies.cont:                       ; preds = %dependency-satisfied, %entry
  %12 = phi ptr [ %4, %entry ], [ null, %dependency-satisfied ]
  %13 = phi i32 [ 63, %entry ], [ 0, %dependency-satisfied ]
  %14 = insertvalue %swift.metadata_response undef, ptr %12, 0
  %15 = insertvalue %swift.metadata_response %14, i32 %13, 1
  ret %swift.metadata_response %15
}

; Function Attrs: nounwind
define internal ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwCP"(ptr noalias initializes((0, 4)) %dest, ptr noalias %src, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #13 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 8
  %Sink = load ptr, ptr %0, align 4, !invariant.load !6
  %1 = getelementptr inbounds i8, ptr %Sink, i32 -4
  %Sink.valueWitnesses = load ptr, ptr %1, align 4, !invariant.load !6, !dereferenceable !7
  %2 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 40
  %flags = load i32, ptr %2, align 4, !invariant.load !6
  %flags.alignmentMask = and i32 %flags, 255
  %3 = xor i32 %flags.alignmentMask, -1
  %4 = add nuw nsw i32 %flags.alignmentMask, 5
  %5 = and i32 %4, %3
  %6 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 32
  %size = load i32, ptr %6, align 4, !invariant.load !6
  %7 = add i32 %size, 3
  %8 = add i32 %7, %5
  %9 = and i32 %8, -4
  %size1 = add i32 %9, 17
  %10 = and i32 %flags, 1048576
  %flags.isBitwiseTakable = icmp eq i32 %10, 0
  %11 = icmp samesign ult i32 %flags.alignmentMask, 4
  %12 = icmp ult i32 %size1, 13
  %13 = and i1 %flags.isBitwiseTakable, %12
  %14 = and i1 %11, %13
  br i1 %14, label %inlineBB, label %allocateBB

inlineBB:                                         ; preds = %entry
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 2 dereferenceable(5) %dest, ptr noundef nonnull align 2 dereferenceable(5) %src, i32 5, i1 false)
  %15 = ptrtoint ptr %dest to i32
  %16 = add i32 %15, 5
  %17 = ptrtoint ptr %src to i32
  %18 = add i32 %17, 5
  %19 = add i32 %16, %flags.alignmentMask
  %20 = and i32 %19, %3
  %21 = inttoptr i32 %20 to ptr
  %22 = add i32 %18, %flags.alignmentMask
  %23 = and i32 %22, %3
  %24 = inttoptr i32 %23 to ptr
  %25 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 8
  %InitializeWithCopy = load ptr, ptr %25, align 4, !invariant.load !6
  %26 = tail call ptr %InitializeWithCopy(ptr noalias %21, ptr noalias %24, ptr nonnull %Sink) #18
  %27 = add i32 %7, %20
  %28 = and i32 %27, -4
  %29 = inttoptr i32 %28 to ptr
  %30 = add i32 %7, %23
  %31 = and i32 %30, -4
  %32 = inttoptr i32 %31 to ptr
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(17) %29, ptr noundef nonnull align 4 dereferenceable(17) %32, i32 17, i1 false)
  br label %40

allocateBB:                                       ; preds = %entry
  %33 = load ptr, ptr %src, align 4
  store ptr %33, ptr %dest, align 4
  %34 = add nuw nsw i32 %flags.alignmentMask, 8
  %35 = and i32 %flags, 252
  %36 = xor i32 %35, -4
  %37 = and i32 %34, %36
  %38 = getelementptr inbounds nuw i8, ptr %33, i32 %37
  %39 = tail call ptr @swift_retain(ptr returned %33) #29
  br label %40

40:                                               ; preds = %allocateBB, %inlineBB
  %41 = phi ptr [ %dest, %inlineBB ], [ %38, %allocateBB ]
  ret ptr %41
}

; Function Attrs: nounwind
define internal void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwxx"(ptr noalias %object, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #13 {
entry:
  %0 = ptrtoint ptr %object to i32
  %1 = add i32 %0, 5
  %2 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 8
  %Sink = load ptr, ptr %2, align 4, !invariant.load !6
  %3 = getelementptr inbounds i8, ptr %Sink, i32 -4
  %Sink.valueWitnesses = load ptr, ptr %3, align 4, !invariant.load !6, !dereferenceable !7
  %4 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 40
  %flags = load i32, ptr %4, align 4, !invariant.load !6
  %flags.alignmentMask = and i32 %flags, 255
  %5 = add i32 %1, %flags.alignmentMask
  %6 = xor i32 %flags.alignmentMask, -1
  %7 = and i32 %5, %6
  %8 = inttoptr i32 %7 to ptr
  %9 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 4
  %Destroy = load ptr, ptr %9, align 4, !invariant.load !6
  tail call void %Destroy(ptr noalias %8, ptr %Sink) #18
  ret void
}

; Function Attrs: nounwind
define internal noundef ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwcp"(ptr noalias returned initializes((0, 5)) %dest, ptr noalias %src, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #13 {
entry:
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 2 dereferenceable(5) %dest, ptr noundef nonnull align 2 dereferenceable(5) %src, i32 5, i1 false)
  %0 = ptrtoint ptr %dest to i32
  %1 = ptrtoint ptr %src to i32
  %2 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 8
  %Sink = load ptr, ptr %2, align 4, !invariant.load !6
  %3 = getelementptr inbounds i8, ptr %Sink, i32 -4
  %Sink.valueWitnesses = load ptr, ptr %3, align 4, !invariant.load !6, !dereferenceable !7
  %4 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 40
  %flags = load i32, ptr %4, align 4, !invariant.load !6
  %flags.alignmentMask = and i32 %flags, 255
  %5 = add nuw nsw i32 %flags.alignmentMask, 5
  %6 = add i32 %5, %0
  %7 = xor i32 %flags.alignmentMask, -1
  %8 = and i32 %6, %7
  %9 = inttoptr i32 %8 to ptr
  %10 = add i32 %5, %1
  %11 = and i32 %10, %7
  %12 = inttoptr i32 %11 to ptr
  %13 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 8
  %InitializeWithCopy = load ptr, ptr %13, align 4, !invariant.load !6
  %14 = tail call ptr %InitializeWithCopy(ptr noalias %9, ptr noalias %12, ptr %Sink) #18
  %15 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 32
  %size = load i32, ptr %15, align 4, !invariant.load !6
  %16 = add i32 %size, 3
  %17 = add i32 %16, %8
  %18 = and i32 %17, -4
  %19 = inttoptr i32 %18 to ptr
  %20 = add i32 %16, %11
  %21 = and i32 %20, -4
  %22 = inttoptr i32 %21 to ptr
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(17) %19, ptr noundef nonnull align 4 dereferenceable(17) %22, i32 17, i1 false)
  ret ptr %dest
}

; Function Attrs: nounwind
define internal noundef ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwca"(ptr returned initializes((0, 1), (2, 5)) %dest, ptr %src, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #13 {
entry:
  %0 = load i8, ptr %src, align 2
  store i8 %0, ptr %dest, align 2
  %dest.originMask = getelementptr inbounds nuw i8, ptr %dest, i32 2
  %src.originMask = getelementptr inbounds nuw i8, ptr %src, i32 2
  %1 = load i16, ptr %src.originMask, align 2
  store i16 %1, ptr %dest.originMask, align 2
  %dest.minimumSeverity = getelementptr inbounds nuw i8, ptr %dest, i32 4
  %src.minimumSeverity = getelementptr inbounds nuw i8, ptr %src, i32 4
  %2 = load i8, ptr %src.minimumSeverity, align 2
  store i8 %2, ptr %dest.minimumSeverity, align 2
  %3 = ptrtoint ptr %dest to i32
  %4 = ptrtoint ptr %src to i32
  %5 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 8
  %Sink = load ptr, ptr %5, align 4, !invariant.load !6
  %6 = getelementptr inbounds i8, ptr %Sink, i32 -4
  %Sink.valueWitnesses = load ptr, ptr %6, align 4, !invariant.load !6, !dereferenceable !7
  %7 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 40
  %flags = load i32, ptr %7, align 4, !invariant.load !6
  %flags.alignmentMask = and i32 %flags, 255
  %8 = add nuw nsw i32 %flags.alignmentMask, 5
  %9 = add i32 %8, %3
  %10 = xor i32 %flags.alignmentMask, -1
  %11 = and i32 %9, %10
  %12 = inttoptr i32 %11 to ptr
  %13 = add i32 %8, %4
  %14 = and i32 %13, %10
  %15 = inttoptr i32 %14 to ptr
  %16 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 12
  %AssignWithCopy = load ptr, ptr %16, align 4, !invariant.load !6
  %17 = tail call ptr %AssignWithCopy(ptr %12, ptr %15, ptr %Sink) #18
  %18 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 32
  %size = load i32, ptr %18, align 4, !invariant.load !6
  %19 = add i32 %size, 3
  %20 = add i32 %19, %11
  %21 = and i32 %20, -4
  %22 = inttoptr i32 %21 to ptr
  %23 = add i32 %19, %14
  %24 = and i32 %23, -4
  %25 = inttoptr i32 %24 to ptr
  %26 = load i32, ptr %25, align 4
  store i32 %26, ptr %22, align 4
  %.dropped = getelementptr inbounds nuw i8, ptr %22, i32 4
  %.dropped2 = getelementptr inbounds nuw i8, ptr %25, i32 4
  %27 = load i32, ptr %.dropped2, align 4
  store i32 %27, ptr %.dropped, align 4
  %.saturated = getelementptr inbounds nuw i8, ptr %22, i32 8
  %.saturated3 = getelementptr inbounds nuw i8, ptr %25, i32 8
  %28 = load i32, ptr %.saturated3, align 4
  store i32 %28, ptr %.saturated, align 4
  %.failed = getelementptr inbounds nuw i8, ptr %22, i32 12
  %.failed4 = getelementptr inbounds nuw i8, ptr %25, i32 12
  %29 = load i32, ptr %.failed4, align 4
  store i32 %29, ptr %.failed, align 4
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %22, i32 16
  %.countersSaturated5 = getelementptr inbounds nuw i8, ptr %25, i32 16
  %30 = load i1, ptr %.countersSaturated5, align 4
  %31 = zext i1 %30 to i8
  store i8 %31, ptr %.countersSaturated, align 4
  ret ptr %dest
}

; Function Attrs: nounwind
define internal noundef ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwtk"(ptr noalias returned initializes((0, 5)) %dest, ptr noalias %src, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #13 {
entry:
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 2 dereferenceable(5) %dest, ptr noundef nonnull align 2 dereferenceable(5) %src, i32 5, i1 false)
  %0 = ptrtoint ptr %dest to i32
  %1 = ptrtoint ptr %src to i32
  %2 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 8
  %Sink = load ptr, ptr %2, align 4, !invariant.load !6
  %3 = getelementptr inbounds i8, ptr %Sink, i32 -4
  %Sink.valueWitnesses = load ptr, ptr %3, align 4, !invariant.load !6, !dereferenceable !7
  %4 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 40
  %flags = load i32, ptr %4, align 4, !invariant.load !6
  %flags.alignmentMask = and i32 %flags, 255
  %5 = add nuw nsw i32 %flags.alignmentMask, 5
  %6 = add i32 %5, %0
  %7 = xor i32 %flags.alignmentMask, -1
  %8 = and i32 %6, %7
  %9 = inttoptr i32 %8 to ptr
  %10 = add i32 %5, %1
  %11 = and i32 %10, %7
  %12 = inttoptr i32 %11 to ptr
  %13 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 16
  %InitializeWithTake = load ptr, ptr %13, align 4, !invariant.load !6
  %14 = tail call ptr %InitializeWithTake(ptr noalias %9, ptr noalias %12, ptr %Sink) #18
  %15 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 32
  %size = load i32, ptr %15, align 4, !invariant.load !6
  %16 = add i32 %size, 3
  %17 = add i32 %16, %8
  %18 = and i32 %17, -4
  %19 = inttoptr i32 %18 to ptr
  %20 = add i32 %16, %11
  %21 = and i32 %20, -4
  %22 = inttoptr i32 %21 to ptr
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(17) %19, ptr noundef nonnull align 4 dereferenceable(17) %22, i32 17, i1 false)
  ret ptr %dest
}

; Function Attrs: nounwind
define internal noundef ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwta"(ptr noalias returned initializes((0, 1), (2, 5)) %dest, ptr noalias %src, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #13 {
entry:
  %0 = load i8, ptr %src, align 2
  store i8 %0, ptr %dest, align 2
  %dest.originMask = getelementptr inbounds nuw i8, ptr %dest, i32 2
  %src.originMask = getelementptr inbounds nuw i8, ptr %src, i32 2
  %1 = load i16, ptr %src.originMask, align 2
  store i16 %1, ptr %dest.originMask, align 2
  %dest.minimumSeverity = getelementptr inbounds nuw i8, ptr %dest, i32 4
  %src.minimumSeverity = getelementptr inbounds nuw i8, ptr %src, i32 4
  %2 = load i8, ptr %src.minimumSeverity, align 2
  store i8 %2, ptr %dest.minimumSeverity, align 2
  %3 = ptrtoint ptr %dest to i32
  %4 = ptrtoint ptr %src to i32
  %5 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 8
  %Sink = load ptr, ptr %5, align 4, !invariant.load !6
  %6 = getelementptr inbounds i8, ptr %Sink, i32 -4
  %Sink.valueWitnesses = load ptr, ptr %6, align 4, !invariant.load !6, !dereferenceable !7
  %7 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 40
  %flags = load i32, ptr %7, align 4, !invariant.load !6
  %flags.alignmentMask = and i32 %flags, 255
  %8 = add nuw nsw i32 %flags.alignmentMask, 5
  %9 = add i32 %8, %3
  %10 = xor i32 %flags.alignmentMask, -1
  %11 = and i32 %9, %10
  %12 = inttoptr i32 %11 to ptr
  %13 = add i32 %8, %4
  %14 = and i32 %13, %10
  %15 = inttoptr i32 %14 to ptr
  %16 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 20
  %AssignWithTake = load ptr, ptr %16, align 4, !invariant.load !6
  %17 = tail call ptr %AssignWithTake(ptr noalias %12, ptr noalias %15, ptr %Sink) #18
  %18 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 32
  %size = load i32, ptr %18, align 4, !invariant.load !6
  %19 = add i32 %size, 3
  %20 = add i32 %19, %11
  %21 = and i32 %20, -4
  %22 = inttoptr i32 %21 to ptr
  %23 = add i32 %19, %14
  %24 = and i32 %23, -4
  %25 = inttoptr i32 %24 to ptr
  %26 = load i32, ptr %25, align 4
  store i32 %26, ptr %22, align 4
  %.dropped = getelementptr inbounds nuw i8, ptr %22, i32 4
  %.dropped2 = getelementptr inbounds nuw i8, ptr %25, i32 4
  %27 = load i32, ptr %.dropped2, align 4
  store i32 %27, ptr %.dropped, align 4
  %.saturated = getelementptr inbounds nuw i8, ptr %22, i32 8
  %.saturated3 = getelementptr inbounds nuw i8, ptr %25, i32 8
  %28 = load i32, ptr %.saturated3, align 4
  store i32 %28, ptr %.saturated, align 4
  %.failed = getelementptr inbounds nuw i8, ptr %22, i32 12
  %.failed4 = getelementptr inbounds nuw i8, ptr %25, i32 12
  %29 = load i32, ptr %.failed4, align 4
  store i32 %29, ptr %.failed, align 4
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %22, i32 16
  %.countersSaturated5 = getelementptr inbounds nuw i8, ptr %25, i32 16
  %30 = load i1, ptr %.countersSaturated5, align 4
  %31 = zext i1 %30 to i8
  store i8 %31, ptr %.countersSaturated, align 4
  ret ptr %dest
}

; Function Attrs: nofree nounwind memory(read)
define internal i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwet"(ptr noalias %value, i32 %numEmptyCases, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #17 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 8
  %Sink = load ptr, ptr %0, align 4, !invariant.load !6
  %1 = getelementptr inbounds i8, ptr %Sink, i32 -4
  %Sink.valueWitnesses = load ptr, ptr %1, align 4, !invariant.load !6, !dereferenceable !7
  %2 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 44
  %extraInhabitantCount = load i32, ptr %2, align 4, !invariant.load !6
  %num-extra-inhabitants = tail call i32 @llvm.umax.i32(i32 %extraInhabitantCount, i32 254)
  %3 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 40
  %flags = load i32, ptr %3, align 4, !invariant.load !6
  %flags.alignmentMask = and i32 %flags, 255
  %4 = xor i32 %flags.alignmentMask, -1
  %5 = add nuw nsw i32 %flags.alignmentMask, 5
  %6 = and i32 %5, %4
  %7 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 32
  %size = load i32, ptr %7, align 4, !invariant.load !6
  %8 = add i32 %size, 3
  %9 = add i32 %8, %6
  %10 = and i32 %9, -4
  %size1 = add i32 %10, 17
  %11 = icmp eq i32 %numEmptyCases, 0
  br i1 %11, label %found_max_xi, label %12

12:                                               ; preds = %entry
  %13 = icmp ugt i32 %numEmptyCases, %num-extra-inhabitants
  br i1 %13, label %14, label %.thread

14:                                               ; preds = %12
  %15 = icmp ugt i32 %size1, 3
  %16 = add i32 %numEmptyCases, 255
  %17 = sub i32 %16, %num-extra-inhabitants
  %18 = lshr i32 %17, 8
  %19 = add nuw nsw i32 %18, 1
  %num-tags-phi = select i1 %15, i32 2, i32 %19
  %20 = icmp samesign ult i32 %num-tags-phi, 2
  %21 = icmp samesign ult i32 %num-tags-phi, 256
  %22 = icmp samesign ult i32 %num-tags-phi, 65536
  %23 = select i1 %22, i32 2, i32 4
  %24 = select i1 %21, i32 1, i32 %23
  %num-tag-bytes = select i1 %20, i32 0, i32 %24
  %25 = getelementptr inbounds i8, ptr %value, i32 %size1
  switch i32 %num-tag-bytes, label %34 [
    i32 0, label %.thread
    i32 1, label %26
    i32 2, label %29
    i32 4, label %32
  ]

26:                                               ; preds = %14
  %27 = load i8, ptr %25, align 1
  %28 = zext i8 %27 to i32
  br label %35

29:                                               ; preds = %14
  %30 = load i16, ptr %25, align 1
  %31 = zext i16 %30 to i32
  br label %35

32:                                               ; preds = %14
  %33 = load i32, ptr %25, align 1
  br label %35

34:                                               ; preds = %14
  unreachable

35:                                               ; preds = %32, %29, %26
  %36 = phi i32 [ %28, %26 ], [ %31, %29 ], [ %33, %32 ]
  %37 = icmp eq i32 %36, 0
  br i1 %37, label %.thread, label %38

38:                                               ; preds = %35
  %39 = add i32 %36, -1
  %40 = shl i32 %size1, 3
  %41 = shl i32 %39, %40
  %42 = select i1 %15, i32 0, i32 %41
  br i1 %15, label %46, label %43

43:                                               ; preds = %38
  %44 = load i8, ptr %value, align 4
  %45 = zext i8 %44 to i32
  br label %48

46:                                               ; preds = %38
  %47 = load i32, ptr %value, align 4
  br label %48

48:                                               ; preds = %43, %46
  %49 = phi i32 [ %45, %43 ], [ %47, %46 ]
  %50 = or i32 %49, %42
  %51 = add nuw i32 %num-extra-inhabitants, 1
  %52 = add i32 %51, %50
  br label %found_max_xi

.thread:                                          ; preds = %14, %35, %12
  %53 = ptrtoint ptr %value to i32
  %54 = add i32 %53, 5
  %55 = add i32 %54, %flags.alignmentMask
  %56 = and i32 %55, %4
  %57 = icmp ugt i32 %extraInhabitantCount, 253
  br i1 %57, label %58, label %62

58:                                               ; preds = %.thread
  %59 = inttoptr i32 %56 to ptr
  %60 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 24
  %GetEnumTagSinglePayload = load ptr, ptr %60, align 4, !invariant.load !6
  %61 = tail call i32 %GetEnumTagSinglePayload(ptr noalias %59, i32 %extraInhabitantCount, ptr nonnull %Sink) #30
  br label %found_max_xi

62:                                               ; preds = %.thread
  %63 = add i32 %8, %56
  %64 = and i32 %63, -4
  %65 = inttoptr i32 %64 to ptr
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %65, i32 16
  %66 = load i8, ptr %.countersSaturated, align 4
  %67 = icmp ult i8 %66, 2
  br i1 %67, label %found_max_xi, label %68

68:                                               ; preds = %62
  %69 = zext i8 %66 to i31
  %70 = and i31 %69, 1
  %71 = and i31 %69, 254
  %72 = add nsw i31 %71, -2
  %73 = or disjoint i31 %72, %70
  %74 = zext nneg i31 %73 to i32
  %75 = add nuw nsw i32 %74, 1
  br label %found_max_xi

found_max_xi:                                     ; preds = %68, %62, %entry, %58, %48
  %76 = phi i32 [ %52, %48 ], [ %61, %58 ], [ 0, %entry ], [ 0, %62 ], [ %75, %68 ]
  ret i32 %76
}

; Function Attrs: nounwind
define internal void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwst"(ptr noalias %value, i32 %whichCase, i32 %numEmptyCases, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #13 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i32 8
  %Sink = load ptr, ptr %0, align 4, !invariant.load !6
  %1 = getelementptr inbounds i8, ptr %Sink, i32 -4
  %Sink.valueWitnesses = load ptr, ptr %1, align 4, !invariant.load !6, !dereferenceable !7
  %2 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 44
  %extraInhabitantCount = load i32, ptr %2, align 4, !invariant.load !6
  %num-extra-inhabitants = tail call i32 @llvm.umax.i32(i32 %extraInhabitantCount, i32 254)
  %3 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 40
  %flags = load i32, ptr %3, align 4, !invariant.load !6
  %flags.alignmentMask = and i32 %flags, 255
  %4 = xor i32 %flags.alignmentMask, -1
  %5 = add nuw nsw i32 %flags.alignmentMask, 5
  %6 = and i32 %5, %4
  %7 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 32
  %size = load i32, ptr %7, align 4, !invariant.load !6
  %8 = add i32 %size, 3
  %9 = add i32 %8, %6
  %10 = and i32 %9, -4
  %size1 = add i32 %10, 17
  %11 = getelementptr inbounds i8, ptr %value, i32 %size1
  %12 = icmp ugt i32 %numEmptyCases, %num-extra-inhabitants
  br i1 %12, label %13, label %24

13:                                               ; preds = %entry
  %14 = icmp ugt i32 %size1, 3
  %15 = add i32 %numEmptyCases, 255
  %16 = sub i32 %15, %num-extra-inhabitants
  %17 = lshr i32 %16, 8
  %18 = add nuw nsw i32 %17, 1
  %num-tags-phi = select i1 %14, i32 2, i32 %18
  %19 = icmp samesign ult i32 %num-tags-phi, 2
  %20 = icmp samesign ult i32 %num-tags-phi, 256
  %21 = icmp samesign ult i32 %num-tags-phi, 65536
  %22 = select i1 %21, i32 2, i32 4
  %23 = select i1 %20, i32 1, i32 %22
  %num-tag-bytes = select i1 %19, i32 0, i32 %23
  br label %24

24:                                               ; preds = %13, %entry
  %25 = phi i32 [ 0, %entry ], [ %num-tag-bytes, %13 ]
  %.not = icmp ugt i32 %whichCase, %num-extra-inhabitants
  br i1 %.not, label %56, label %26

26:                                               ; preds = %24
  switch i32 %25, label %30 [
    i32 0, label %31
    i32 1, label %27
    i32 2, label %28
    i32 4, label %29
  ]

27:                                               ; preds = %26
  store i8 0, ptr %11, align 1
  br label %31

28:                                               ; preds = %26
  store i16 0, ptr %11, align 1
  br label %31

29:                                               ; preds = %26
  store i32 0, ptr %11, align 1
  br label %31

30:                                               ; preds = %26
  unreachable

31:                                               ; preds = %26, %29, %28, %27
  %.not4 = icmp eq i32 %whichCase, 0
  br i1 %.not4, label %found_max_xi, label %32

32:                                               ; preds = %31
  %33 = ptrtoint ptr %value to i32
  %34 = add i32 %33, 5
  %35 = add i32 %34, %flags.alignmentMask
  %36 = and i32 %35, %4
  %37 = icmp ugt i32 %extraInhabitantCount, 253
  br i1 %37, label %38, label %41

38:                                               ; preds = %32
  %39 = inttoptr i32 %36 to ptr
  %40 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i32 28
  %StoreEnumTagSinglePayload = load ptr, ptr %40, align 4, !invariant.load !6
  tail call void %StoreEnumTagSinglePayload(ptr noalias %39, i32 %whichCase, i32 %extraInhabitantCount, ptr nonnull %Sink) #18
  br label %found_max_xi

41:                                               ; preds = %32
  %42 = add i32 %8, %36
  %43 = and i32 %42, -4
  %44 = inttoptr i32 %43 to ptr
  %45 = icmp ult i32 %whichCase, 255
  br i1 %45, label %46, label %53

46:                                               ; preds = %41
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %44, i32 16
  %47 = trunc nuw i32 %whichCase to i8
  %48 = add i8 %47, -1
  %49 = and i8 %48, 1
  %50 = and i8 %48, -2
  %51 = add nuw i8 %50, 2
  %52 = or disjoint i8 %51, %49
  store i8 %52, ptr %.countersSaturated, align 4
  br label %found_max_xi

53:                                               ; preds = %41
  %54 = add i32 %whichCase, -255
  store i32 %54, ptr %44, align 4
  %55 = getelementptr inbounds nuw i8, ptr %44, i32 4
  tail call void @llvm.memset.p0.i32(ptr noundef nonnull align 4 dereferenceable(13) %55, i8 0, i32 13, i1 false)
  br label %found_max_xi

56:                                               ; preds = %24
  %57 = xor i32 %num-extra-inhabitants, -1
  %58 = add i32 %whichCase, %57
  %59 = icmp ugt i32 %size1, 3
  %60 = lshr i32 %58, 8
  %61 = add nuw nsw i32 %60, 1
  %62 = select i1 %59, i32 1, i32 %61
  tail call void @llvm.memset.p0.i32(ptr noundef nonnull align 4 dereferenceable(1) %value, i8 0, i32 %size1, i1 false)
  br i1 %59, label %65, label %63

63:                                               ; preds = %56
  %64 = trunc i32 %58 to i8
  store i8 %64, ptr %value, align 4
  br label %66

65:                                               ; preds = %56
  store i32 %58, ptr %value, align 4
  br label %66

66:                                               ; preds = %63, %65
  switch i32 %25, label %72 [
    i32 0, label %found_max_xi
    i32 1, label %67
    i32 2, label %69
    i32 4, label %71
  ]

67:                                               ; preds = %66
  %68 = trunc i32 %62 to i8
  store i8 %68, ptr %11, align 1
  br label %found_max_xi

69:                                               ; preds = %66
  %70 = trunc i32 %62 to i16
  store i16 %70, ptr %11, align 1
  br label %found_max_xi

71:                                               ; preds = %66
  store i32 %62, ptr %11, align 1
  br label %found_max_xi

72:                                               ; preds = %66
  unreachable

found_max_xi:                                     ; preds = %53, %67, %69, %71, %66, %46, %38, %31
  ret void
}

; Function Attrs: nounwind
declare ptr @swift_allocateGenericValueMetadata(ptr, ptr, ptr, i32) local_unnamed_addr #18

; Function Attrs: mustprogress nofree nounwind willreturn memory(read)
declare swiftcc %swift.metadata_response @swift_checkMetadataState(i32, ptr) local_unnamed_addr #19

; Function Attrs: nounwind
declare void @swift_initStructMetadata(ptr, i32, i32, ptr, ptr) local_unnamed_addr #18

; Function Attrs: mustprogress nounwind willreturn
define internal nonnull ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVwCP"(ptr noalias writeonly captures(none) initializes((0, 4)) %dest, ptr noalias readonly captures(none) %src, ptr readnone captures(none) %GiftUIFixedDiagnosticBuffer) #20 {
entry:
  %0 = load ptr, ptr %src, align 4
  store ptr %0, ptr %dest, align 4
  %1 = getelementptr inbounds nuw i8, ptr %0, i32 8
  %2 = tail call ptr @swift_retain(ptr returned %0) #29
  ret ptr %1
}

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy392_4(ptr %0, ptr %1, ptr %2) #13 {
entry:
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(392) %0, ptr noundef nonnull align 4 dereferenceable(392) %1, i32 392, i1 false)
  ret ptr %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %GiftUIFixedDiagnosticBuffer) #1 {
entry:
  %0 = icmp eq i32 %numEmptyCases, 0
  br i1 %0, label %17, label %1

1:                                                ; preds = %entry
  %2 = icmp ugt i32 %numEmptyCases, 252
  br i1 %2, label %3, label %11

3:                                                ; preds = %1
  %4 = getelementptr inbounds nuw i8, ptr %value, i32 392
  %5 = load i8, ptr %4, align 1
  %6 = icmp eq i8 %5, 0
  br i1 %6, label %11, label %7

7:                                                ; preds = %3
  %8 = load i3136, ptr %value, align 1
  %9 = trunc i3136 %8 to i32
  %10 = add i32 %9, 252
  br label %17

11:                                               ; preds = %3, %1
  %value.record0 = getelementptr inbounds nuw i8, ptr %value, i32 8
  %12 = load i8, ptr %value.record0, align 4
  %13 = zext i8 %12 to i32
  %14 = add nsw i32 %13, -4
  %15 = icmp ult i8 %12, 4
  %16 = select i1 %15, i32 -1, i32 %14
  br label %17

17:                                               ; preds = %entry, %11, %7
  %18 = phi i32 [ %16, %11 ], [ %10, %7 ], [ -1, %entry ]
  %19 = add i32 %18, 1
  ret i32 %19
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define internal void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %GiftUIFixedDiagnosticBuffer) #2 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i32 392
  %1 = icmp ugt i32 %numEmptyCases, 252
  %2 = icmp ult i32 %whichCase, 253
  br i1 %2, label %3, label %10

3:                                                ; preds = %entry
  br i1 %1, label %4, label %5

4:                                                ; preds = %3
  store i8 0, ptr %0, align 4
  br label %5

5:                                                ; preds = %3, %4
  %6 = icmp eq i32 %whichCase, 0
  br i1 %6, label %14, label %7

7:                                                ; preds = %5
  %value.record0 = getelementptr inbounds nuw i8, ptr %value, i32 8
  %8 = trunc nuw i32 %whichCase to i8
  %9 = add nuw i8 %8, 3
  store i8 %9, ptr %value.record0, align 4
  br label %14

10:                                               ; preds = %entry
  %11 = add i32 %whichCase, -253
  store i32 %11, ptr %value, align 4
  %12 = getelementptr inbounds nuw i8, ptr %value, i32 4
  tail call void @llvm.memset.p0.i32(ptr noundef nonnull align 4 dereferenceable(388) %12, i8 0, i32 388, i1 false)
  br i1 %1, label %13, label %14

13:                                               ; preds = %10
  store i8 1, ptr %0, align 4
  br label %14

14:                                               ; preds = %10, %13, %7, %5
  ret void
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMa"(i32 %0) #15 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMa"(i32 %0) #15 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: mustprogress nofree noinline nounwind willreturn memory(read)
define linkonce_odr hidden swiftcc %swift.metadata_response @__swift_instantiateGenericMetadata(i32 %0, ptr %1, ptr %2, ptr %3, ptr %4) local_unnamed_addr #21 {
entry:
  %generic.arguments = alloca [3 x ptr], align 4
  call void @llvm.lifetime.start.p0(i64 12, ptr nonnull %generic.arguments)
  store ptr %1, ptr %generic.arguments, align 4
  %5 = getelementptr inbounds nuw i8, ptr %generic.arguments, i32 4
  store ptr %2, ptr %5, align 4
  %6 = getelementptr inbounds nuw i8, ptr %generic.arguments, i32 8
  store ptr %3, ptr %6, align 4
  %7 = call swiftcc %swift.metadata_response @swift_getGenericMetadata(i32 %0, ptr nonnull %generic.arguments, ptr %4) #30
  ret %swift.metadata_response %7
}

; Function Attrs: nofree nounwind memory(read)
declare swiftcc %swift.metadata_response @swift_getGenericMetadata(i32, ptr, ptr) local_unnamed_addr #22

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.umax.i32(i32, i32) #23

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #24

; Function Attrs: mustprogress nounwind willreturn
define internal nonnull ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVwCP"(ptr noalias writeonly captures(none) initializes((0, 4)) %0, ptr noalias readonly captures(none) %1, ptr readnone captures(none) %2) #20 {
  %4 = tail call nonnull ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVwCP"(ptr noalias writeonly captures(none) initializes((0, 4)) %0, ptr noalias readonly captures(none) %1, ptr readnone captures(none) %2) #20
  ret ptr %4
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record133_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record233_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record333_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record433_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record533_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record633_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record733_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record833_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record933_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1133_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1233_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1333_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1433_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1533_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2 {
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"(ptr noalias writeonly sret(%T17GiftUIFailureCore0A18UIDiagnosticRecordV) captures(none) initializes((0, 24)) %0) #2
  ret void
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #1 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #2 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #3 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #4 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #6 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #7 = { mustprogress nofree noinline nosync nounwind willreturn memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #8 = { nounwind memory(argmem: readwrite, inaccessiblemem: write) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #9 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #10 = { cold noreturn nounwind memory(inaccessiblemem: write) }
attributes #11 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #12 = { mustprogress nounwind willreturn }
attributes #13 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #14 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #15 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #16 = { nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #17 = { nofree nounwind memory(read) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #18 = { nounwind }
attributes #19 = { mustprogress nofree nounwind willreturn memory(read) }
attributes #20 = { mustprogress nounwind willreturn "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #21 = { mustprogress nofree noinline nounwind willreturn memory(read) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #22 = { nofree nounwind memory(read) }
attributes #23 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #24 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #25 = { nounwind memory(none) }
attributes #26 = { nomerge }
attributes #27 = { noinline }
attributes #28 = { nounwind willreturn memory(read) }
attributes #29 = { nounwind willreturn }
attributes #30 = { nounwind memory(read) }

!swift.module.flags = !{!0}
!llvm.module.flags = !{!1, !2, !3, !4, !5}
!llvm.linker.options = !{}

!0 = !{!"standard-library", i1 false}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 1, !"min_enum_size", i32 4}
!3 = !{i32 8, !"PIC Level", i32 2}
!4 = !{i32 4, !"Objective-C Garbage Collection", i32 100927232}
!5 = !{i32 1, !"Swift Version", i32 7}
!6 = !{}
!7 = !{i64 48}
!8 = !{!"branch_weights", !"expected", i32 1, i32 2000}
!9 = !{!10}
!10 = distinct !{!10, !11, !"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV12storedRecord33_481FAB364D938FDBB52660A85D053959LL2at0aB4Core0a12UIDiagnosticJ0VSgs5UInt8V_tF: argument 1"}
!11 = distinct !{!11, !"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV12storedRecord33_481FAB364D938FDBB52660A85D053959LL2at0aB4Core0a12UIDiagnosticJ0VSgs5UInt8V_tF"}
!12 = !{!13}
!13 = distinct !{!13, !11, !"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV12storedRecord33_481FAB364D938FDBB52660A85D053959LL2at0aB4Core0a12UIDiagnosticJ0VSgs5UInt8V_tF: argument 0"}
