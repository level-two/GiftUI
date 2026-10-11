; ModuleID = '/Users/eugene/work/GiftUI/.build/rfc-014-swift64/resource-regression/003-native/semantics/diagnostics-layout.ll'
source_filename = "/Users/eugene/work/GiftUI/.build/rfc-014-swift64/resource-regression/003-native/semantics/diagnostics-layout.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%Ts5UInt8V = type <{ i8 }>
%swift.protocol = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i32, i32, i32, i32, i32, i32 }
%swift.method_descriptor = type { i32, i32 }
%swift.protocol_conformance_descriptor = type { i32, i32, i32, i32 }
%swift.vwtable = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i32, i32 }
%swift.type_descriptor = type opaque
%swift.type_metadata_record = type { i32 }
%swift.type = type { i64 }
%swift.opaque = type opaque
%swift.metadata_response = type { ptr, i64 }
%T35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV = type <{ %Ts5UInt8V, [3 x i8], %Ts6UInt32V, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV, %T17GiftUIFailureCore0A18UIDiagnosticRecordV }>
%Ts6UInt32V = type <{ i32 }>
%T17GiftUIFailureCore0A18UIDiagnosticRecordV = type <{ %T17GiftUIFailureCore0A16UIDiagnosticKindO, %T17GiftUIFailureCore0A20UIDiagnosticSeverityO, %Ts6UInt16V, %T17GiftUIFailureCore0aB6OriginO, %T17GiftUIFailureCore0A15UIAffectedScopeO, %Ts6UInt16V, %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V, %Ts6UInt32V }>
%T17GiftUIFailureCore0A16UIDiagnosticKindO = type <{ i8 }>
%T17GiftUIFailureCore0A20UIDiagnosticSeverityO = type <{ i8 }>
%T17GiftUIFailureCore0aB6OriginO = type <{ i8 }>
%T17GiftUIFailureCore0A15UIAffectedScopeO = type <{ i8 }>
%Ts6UInt16V = type <{ i16 }>

@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvpZ" = constant %Ts5UInt8V <{ i8 16 }>, align 1
@"$sSQMp" = external global %swift.protocol, align 4
@"got.$sSQMp" = private unnamed_addr constant ptr @"$sSQMp"
@"$sSQ2eeoiySbx_xtFZTq" = external global %swift.method_descriptor, align 4
@"got.$sSQ2eeoiySbx_xtFZTq" = private unnamed_addr constant ptr @"$sSQ2eeoiySbx_xtFZTq"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQMp" to i64), i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 1, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAASQ2eeoiySbx_xtFZTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc", i32 0, i32 6) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAMc" = constant %swift.protocol_conformance_descriptor { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$s17GiftUIFailureCore0A16UIDiagnosticSinkMp" to i64), i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (%swift.protocol_conformance_descriptor, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAMc", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAWP" to i64), i64 ptrtoint (ptr getelementptr inbounds (%swift.protocol_conformance_descriptor, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAMc", i32 0, i32 2) to i64)) to i32), i32 0 }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAWP" = constant [2 x ptr] [ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAMc", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAadEP7consumeyAD0ajK6ResultOAD0aJ6RecordVFTW"], align 8
@"$s17GiftUIFailureCore0A16UIDiagnosticSinkMp" = external global %swift.protocol, align 4
@"got.$s17GiftUIFailureCore0A16UIDiagnosticSinkMp" = private unnamed_addr constant ptr @"$s17GiftUIFailureCore0A16UIDiagnosticSinkMp"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV" = unnamed_addr constant { i32 } zeroinitializer, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVWV" = internal constant %swift.vwtable { ptr @__swift_memcpy17_4, ptr @__swift_noop_void_return, ptr @__swift_memcpy17_4, ptr @__swift_memcpy17_4, ptr @__swift_memcpy17_4, ptr @__swift_memcpy17_4, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVwet", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVwst", i64 17, i64 20, i32 3, i32 254 }, align 8
@.str.35.GiftUIFailureDiagnosticsLayoutProbe = private constant [36 x i8] c"GiftUIFailureDiagnosticsLayoutProbe\00"
@"$s35GiftUIFailureDiagnosticsLayoutProbeMXM" = linkonce_odr hidden constant <{ i32, i32, i32 }> <{ i32 0, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.35.GiftUIFailureDiagnosticsLayoutProbe to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeMXM", i32 0, i32 2) to i64)) to i32) }>, section "__TEXT,__constg_swiftt", align 4
@.str.32.GiftUIDiagnosticDeliveryCounters = private constant [33 x i8] c"GiftUIDiagnosticDeliveryCounters\00"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.32.GiftUIDiagnosticDeliveryCounters to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn", i32 0, i32 4) to i64)) to i32), i32 5, i32 2 }>, section "__TEXT,__constg_swiftt", align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMf" = internal constant <{ ptr, ptr, i64, ptr, i32, i32, i32, i32, i32, [4 x i8] }> <{ ptr null, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVWV", i64 512, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn", i32 0, i32 4, i32 8, i32 12, i32 16, [4 x i8] zeroinitializer }>, align 8
@"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$ss6UInt32VMn" = external global %swift.type_descriptor, align 4
@"got.$ss6UInt32VMn" = private unnamed_addr constant ptr @"$ss6UInt32VMn"
@"symbolic _____ s6UInt32V" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$ss6UInt32VMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ s6UInt32V", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@0 = private constant [9 x i8] c"accepted\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@1 = private constant [8 x i8] c"dropped\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@2 = private constant [10 x i8] c"saturated\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@3 = private constant [7 x i8] c"failed\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@"symbolic Sb" = linkonce_odr hidden constant <{ [2 x i8], i8 }> <{ [2 x i8] c"Sb", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@4 = private constant [18 x i8] c"countersSaturated\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV" to i64), i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF" to i64)) to i32), i32 0, i16 0, i16 12, i32 5, i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 6) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @0 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 7) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 9) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @1 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 10) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 12) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @2 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 13) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 15) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @3 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 16) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic Sb" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 18) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @4 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", i32 0, i32 19) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVWV" = internal constant %swift.vwtable { ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwCP", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwxx", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwcp", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwca", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwtk", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwta", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwet", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwst", i64 0, i64 0, i32 4194304, i32 0 }, align 8
@.str.25.GiftUIDiagnosticProjector = private constant [26 x i8] c"GiftUIDiagnosticProjector\00"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMI" = internal global [16 x ptr] zeroinitializer, align 8
@"symbolic x" = linkonce_odr hidden constant <{ [1 x i8], i8 }> <{ [1 x i8] c"x", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn" = constant <{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }> <{ i32 209, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.25.GiftUIDiagnosticProjector to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 4) to i64)) to i32), i32 3, i32 4, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMI" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 7) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMP" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 8) to i64)) to i32), i16 1, i16 1, i16 2, i16 0, i8 -128, i8 0, i8 0, i8 0, i32 128, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic x" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 18) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$s17GiftUIFailureCore0A16UIDiagnosticSinkMp" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", i32 0, i32 19) to i64)) to i32), i32 1) }>, section "__TEXT,__constg_swiftt", align 4
@type_layout_5_2_fa_pod = private constant { i64, i64, i32, i32 } { i64 5, i64 6, i32 1, i32 250 }, align 8
@type_layout_17_4_fe_pod = private constant { i64, i64, i32, i32 } { i64 17, i64 20, i32 3, i32 254 }, align 8
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMP" = internal constant <{ i32, i32, i32, i32 }> <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMi" to i64), i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMP" to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMr" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMP", i32 0, i32 1) to i64)) to i32), i32 1073741824, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVWV" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMP", i32 0, i32 3) to i64)) to i32) }>, align 8
@"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s17GiftUIFailureCore0A21UIDiagnosticSelectionVMn" = external global %swift.type_descriptor, align 4
@"got.$s17GiftUIFailureCore0A21UIDiagnosticSelectionVMn" = private unnamed_addr constant ptr @"$s17GiftUIFailureCore0A21UIDiagnosticSelectionVMn"
@"symbolic _____ 17GiftUIFailureCore0A21UIDiagnosticSelectionV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$s17GiftUIFailureCore0A21UIDiagnosticSelectionVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 17GiftUIFailureCore0A21UIDiagnosticSelectionV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@5 = private constant [10 x i8] c"selection\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@6 = private constant [5 x i8] c"sink\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@7 = private constant [9 x i8] c"counters\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV" to i64), i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF" to i64)) to i32), i32 0, i16 0, i16 12, i32 3, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A21UIDiagnosticSelectionV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF", i32 0, i32 6) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @5 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF", i32 0, i32 7) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic x" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF", i32 0, i32 9) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @6 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF", i32 0, i32 10) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF", i32 0, i32 12) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @7 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF", i32 0, i32 13) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVWV" = internal constant %swift.vwtable { ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVwCP", ptr @__swift_noop_void_return, ptr @__swift_memcpy392_4, ptr @__swift_memcpy392_4, ptr @__swift_memcpy392_4, ptr @__swift_memcpy392_4, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVwet", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVwst", i64 392, i64 392, i32 131075, i32 252 }, align 8
@.str.27.GiftUIFixedDiagnosticBuffer = private constant [28 x i8] c"GiftUIFixedDiagnosticBuffer\00"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.27.GiftUIFixedDiagnosticBuffer to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn", i32 0, i32 4) to i64)) to i32), i32 18, i32 2 }>, section "__TEXT,__constg_swiftt", align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMf" = internal constant <{ ptr, ptr, i64, ptr, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }> <{ ptr null, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVWV", i64 512, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn", i32 0, i32 4, i32 8, i32 32, i32 56, i32 80, i32 104, i32 128, i32 152, i32 176, i32 200, i32 224, i32 248, i32 272, i32 296, i32 320, i32 344, i32 368 }>, align 8
@"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$ss5UInt8VMn" = external global %swift.type_descriptor, align 4
@"got.$ss5UInt8VMn" = private unnamed_addr constant ptr @"$ss5UInt8VMn"
@"symbolic _____ s5UInt8V" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$ss5UInt8VMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ s5UInt8V", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@8 = private constant [6 x i8] c"count\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@9 = private constant [19 x i8] c"droppedRecordCount\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@"$s17GiftUIFailureCore0A18UIDiagnosticRecordVMn" = external global %swift.type_descriptor, align 4
@"got.$s17GiftUIFailureCore0A18UIDiagnosticRecordVMn" = private unnamed_addr constant ptr @"$s17GiftUIFailureCore0A18UIDiagnosticRecordVMn"
@"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$s17GiftUIFailureCore0A18UIDiagnosticRecordVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@10 = private constant [8 x i8] c"record0\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@11 = private constant [8 x i8] c"record1\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@12 = private constant [8 x i8] c"record2\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@13 = private constant [8 x i8] c"record3\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@14 = private constant [8 x i8] c"record4\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@15 = private constant [8 x i8] c"record5\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@16 = private constant [8 x i8] c"record6\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@17 = private constant [8 x i8] c"record7\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@18 = private constant [8 x i8] c"record8\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@19 = private constant [8 x i8] c"record9\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@20 = private constant [9 x i8] c"record10\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@21 = private constant [9 x i8] c"record11\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@22 = private constant [9 x i8] c"record12\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@23 = private constant [9 x i8] c"record13\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@24 = private constant [9 x i8] c"record14\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@25 = private constant [9 x i8] c"record15\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV" to i64), i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF" to i64)) to i32), i32 0, i16 0, i16 12, i32 18, i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s5UInt8V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 6) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @8 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 7) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 9) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @9 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 10) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 12) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @10 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 13) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 15) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @11 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 16) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 18) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @12 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 19) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 21) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @13 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 22) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 24) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @14 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 25) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 27) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @15 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 28) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 30) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @16 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 31) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 33) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @17 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 34) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 36) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @18 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 37) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 39) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @19 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 40) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 42) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @20 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 43) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 45) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @21 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 46) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 48) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @22 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 49) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 51) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @23 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 52) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 54) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @24 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 55) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 17GiftUIFailureCore0A18UIDiagnosticRecordV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 57) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @25 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", i32 0, i32 58) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$sytWV" = external global ptr, align 8
@"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 82, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.35.GiftUIFailureDiagnosticsLayoutProbe to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn", i32 0, i32 4) to i64)) to i32), i32 0, i32 0 }>, section "__TEXT,__constg_swiftt", align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMf" = internal constant <{ ptr, ptr, i64, ptr }> <{ ptr null, ptr @"$sytWV", i64 513, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn" }>, align 8
@"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbeAAO" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbeAAO", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMF" = internal constant { i32, i32, i16, i16, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 35GiftUIFailureDiagnosticsLayoutProbeAAO" to i64), i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMF" to i64)) to i32), i32 0, i16 2, i16 12, i32 0 }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc" to i64), i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAMc" to i64), i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn" to i64), i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn" to i64), i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn" to i64), i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s35GiftUIFailureDiagnosticsLayoutProbeAAOHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn" to i64), i64 ptrtoint (ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@llvm.used = appending global [82 x ptr] [ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV4sinkxvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV7project4kind6origin8severity6recordy0aB4Core0aF4KindO_AI0aB6OriginOAI0aF8SeverityOAI0aF6RecordVyXEtF", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV8countersAA0aF16DeliveryCountersVvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV9selection0aB4Core0aF9SelectionVvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV9selection4sinkACyxG0aB4Core0aF9SelectionV_xtcfC", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVHn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMF", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMa", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAHc", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAMc", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAAWP", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCountACs6UInt32V_tcfC", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCounts6UInt32Vvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCounts6UInt32Vvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV5counts5UInt8Vvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV5counts5UInt8Vvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7consumey0aB4Core0A22UIDiagnosticSinkResultOAE0aK6RecordVF", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record133_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record233_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record333_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record433_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record533_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record633_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record733_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record833_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record933_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8Vvau", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvgZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvpZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1133_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1233_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1333_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1433_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1533_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVACycfC", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVHn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMF", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMa", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVN", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVy0aB4Core0A18UIDiagnosticRecordVSgs5UInt8Vcig", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV17countersSaturatedSbvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV17countersSaturatedSbvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6faileds6UInt32Vvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6faileds6UInt32Vvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV7droppeds6UInt32Vvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV7droppeds6UInt32Vvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepted7dropped9saturated6failed17countersSaturatedACs6UInt32V_A3JSbtcfC", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepted7dropped9saturated6failed17countersSaturatedACs6UInt32V_A3JSbtcfcfA3_", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32Vvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32Vvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV9saturateds6UInt32Vvg", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV9saturateds6UInt32Vvpfi", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVACycfC", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVHn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMF", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMa", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVN", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAHc", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAAMc", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO20deliveryCountersSizes6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO22deliveryCountersStrides6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO23diagnosticProjectorSizes6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO25deliveryCountersAlignments6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO25diagnosticProjectorStrides6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO25fixedDiagnosticBufferSizes6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO27fixedDiagnosticBufferStrides6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO28diagnosticProjectorAlignments6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO29fixedDiagnosticBufferCapacitys5UInt8VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO30fixedDiagnosticBufferAlignments6UInt32VyFZ", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOHn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMF", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMa", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMn", ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAON", ptr @__swift_reflection_version], section "llvm.metadata"

@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV7droppeds6UInt32VvpMV" = alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV9saturateds6UInt32VvpMV" = alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6faileds6UInt32VvpMV" = alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV17countersSaturatedSbvpMV" = alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV9selection0aB4Core0aF9SelectionVvpMV" = alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV4sinkxvpMV" = alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV8countersAA0aF16DeliveryCountersVvpMV" = alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV5counts5UInt8VvpMV" = alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCounts6UInt32VvpMV" = alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvpZMV" = alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVy0aB4Core0A18UIDiagnosticRecordVSgs5UInt8VcipMV" = alias { i32 }, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32VvpMV"
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVN" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32, i32, i32, i32, [4 x i8] }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMf", i32 0, i32 2)
@"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVN" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMf", i32 0, i32 2)
@"$s35GiftUIFailureDiagnosticsLayoutProbeAAON" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMf", i32 0, i32 2)

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32Vvpfi"() #0 {
entry:
  ret i32 0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepteds6UInt32Vvg"(i64 %0, i64 %1, i1 %2) #0 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %0 to i32
  ret i32 %temp-coercion.coerced.sroa.0.0.extract.trunc
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #1

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV7droppeds6UInt32Vvpfi"() #0 {
entry:
  ret i32 0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV7droppeds6UInt32Vvg"(i64 %0, i64 %1, i1 %2) #0 {
entry:
  %temp-coercion.coerced.sroa.0.4.extract.shift = lshr i64 %0, 32
  %temp-coercion.coerced.sroa.0.4.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.0.4.extract.shift to i32
  ret i32 %temp-coercion.coerced.sroa.0.4.extract.trunc
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV9saturateds6UInt32Vvpfi"() #0 {
entry:
  ret i32 0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV9saturateds6UInt32Vvg"(i64 %0, i64 %1, i1 %2) #0 {
entry:
  %temp-coercion.coerced.sroa.3.8.extract.trunc = trunc i64 %1 to i32
  ret i32 %temp-coercion.coerced.sroa.3.8.extract.trunc
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6faileds6UInt32Vvpfi"() #0 {
entry:
  ret i32 0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6faileds6UInt32Vvg"(i64 %0, i64 %1, i1 %2) #0 {
entry:
  %temp-coercion.coerced.sroa.3.12.extract.shift = lshr i64 %1, 32
  %temp-coercion.coerced.sroa.3.12.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.3.12.extract.shift to i32
  ret i32 %temp-coercion.coerced.sroa.3.12.extract.trunc
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i1 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV17countersSaturatedSbvpfi"() #0 {
entry:
  ret i1 false
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i1 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV17countersSaturatedSbvg"(i64 %0, i64 %1, i1 returned %2) #0 {
entry:
  ret i1 %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i1 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVACycfC"() #0 {
entry:
  ret { i64, i64, i1 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i1 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepted7dropped9saturated6failed17countersSaturatedACs6UInt32V_A3JSbtcfcfA3_"() #0 {
entry:
  ret i1 false
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i1 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV8accepted7dropped9saturated6failed17countersSaturatedACs6UInt32V_A3JSbtcfC"(i32 %0, i32 %1, i32 %2, i32 %3, i1 %4) #0 {
entry:
  %temp-coercion.coerced.sroa.0.0.insert.ext = zext i32 %0 to i64
  %temp-coercion.coerced.sroa.0.4.insert.ext = zext i32 %1 to i64
  %temp-coercion.coerced.sroa.0.4.insert.shift = shl nuw i64 %temp-coercion.coerced.sroa.0.4.insert.ext, 32
  %temp-coercion.coerced.sroa.0.4.insert.insert = or disjoint i64 %temp-coercion.coerced.sroa.0.4.insert.shift, %temp-coercion.coerced.sroa.0.0.insert.ext
  %temp-coercion.coerced.sroa.5.8.insert.ext = zext i32 %2 to i64
  %temp-coercion.coerced.sroa.5.12.insert.ext = zext i32 %3 to i64
  %temp-coercion.coerced.sroa.5.12.insert.shift = shl nuw i64 %temp-coercion.coerced.sroa.5.12.insert.ext, 32
  %temp-coercion.coerced.sroa.5.12.insert.insert = or disjoint i64 %temp-coercion.coerced.sroa.5.12.insert.shift, %temp-coercion.coerced.sroa.5.8.insert.ext
  %5 = insertvalue { i64, i64, i1 } undef, i64 %temp-coercion.coerced.sroa.0.4.insert.insert, 0
  %6 = insertvalue { i64, i64, i1 } %5, i64 %temp-coercion.coerced.sroa.5.12.insert.insert, 1
  %7 = insertvalue { i64, i64, i1 } %6, i1 %4, 2
  ret { i64, i64, i1 } %7
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
define hidden swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6recordyy0aB4Core0aF10SinkResultOF"(i8 %0, ptr swiftself captures(none) dereferenceable(17) %1) local_unnamed_addr #2 {
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
  %.countersSaturated6 = getelementptr inbounds nuw i8, ptr %1, i64 16
  store i8 1, ptr %.countersSaturated6, align 4
  br label %8

8:                                                ; preds = %5, %7
  %9 = phi i32 [ -1, %7 ], [ %6, %5 ]
  store i32 %9, ptr %1, align 4
  br label %31

10:                                               ; preds = %entry
  %.dropped = getelementptr inbounds nuw i8, ptr %1, i64 4
  %11 = load i32, ptr %.dropped, align 4
  %.not12 = icmp eq i32 %11, -1
  br i1 %.not12, label %14, label %12

12:                                               ; preds = %10
  %13 = add nuw i32 %11, 1
  br label %15

14:                                               ; preds = %10
  %.countersSaturated4 = getelementptr inbounds nuw i8, ptr %1, i64 16
  store i8 1, ptr %.countersSaturated4, align 4
  br label %15

15:                                               ; preds = %12, %14
  %16 = phi i32 [ -1, %14 ], [ %13, %12 ]
  store i32 %16, ptr %.dropped, align 4
  br label %31

17:                                               ; preds = %entry
  %.saturated = getelementptr inbounds nuw i8, ptr %1, i64 8
  %18 = load i32, ptr %.saturated, align 4
  %.not11 = icmp eq i32 %18, -1
  br i1 %.not11, label %21, label %19

19:                                               ; preds = %17
  %20 = add nuw i32 %18, 1
  br label %22

21:                                               ; preds = %17
  %.countersSaturated2 = getelementptr inbounds nuw i8, ptr %1, i64 16
  store i8 1, ptr %.countersSaturated2, align 4
  br label %22

22:                                               ; preds = %19, %21
  %23 = phi i32 [ -1, %21 ], [ %20, %19 ]
  store i32 %23, ptr %.saturated, align 4
  br label %31

24:                                               ; preds = %entry
  %.failed = getelementptr inbounds nuw i8, ptr %1, i64 12
  %25 = load i32, ptr %.failed, align 4
  %.not = icmp eq i32 %25, -1
  br i1 %.not, label %28, label %26

26:                                               ; preds = %24
  %27 = add nuw i32 %25, 1
  br label %29

28:                                               ; preds = %24
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %1, i64 16
  store i8 1, ptr %.countersSaturated, align 4
  br label %29

29:                                               ; preds = %26, %28
  %30 = phi i32 [ -1, %28 ], [ %27, %26 ]
  store i32 %30, ptr %.failed, align 4
  br label %31

31:                                               ; preds = %8, %15, %22, %29
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i1 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV23__derived_struct_equalsySbAC_ACtFZ"(i64 %0, i64 %1, i1 %2, i64 %3, i64 %4, i1 %5) #0 {
entry:
  %or.cond = icmp eq i64 %0, %3
  %6 = icmp eq i64 %1, %4
  %or.cond3 = select i1 %or.cond, i1 %6, i1 false
  %7 = xor i1 %2, %5
  %8 = xor i1 %7, true
  %9 = select i1 %or.cond3, i1 %8, i1 false
  ret i1 %9
}

define linkonce_odr hidden swiftcc i1 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias captures(none) dereferenceable(17) %0, ptr noalias captures(none) dereferenceable(17) %1, ptr swiftself %2, ptr %Self, ptr %SelfWitnessTable) #3 {
entry:
  %3 = load <4 x i32>, ptr %0, align 4
  %4 = load <4 x i32>, ptr %1, align 4
  %5 = icmp eq <4 x i32> %3, %4
  %6 = freeze <4 x i1> %5
  %7 = bitcast <4 x i1> %6 to i4
  %8 = icmp eq i4 %7, -1
  br i1 %8, label %9, label %14

9:                                                ; preds = %entry
  %.countersSaturated5 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %10 = load i1, ptr %.countersSaturated5, align 4
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %0, i64 16
  %11 = load i1, ptr %.countersSaturated, align 4
  %12 = xor i1 %10, %11
  %13 = xor i1 %12, true
  br label %14

14:                                               ; preds = %9, %entry
  %15 = phi i1 [ false, %entry ], [ %13, %9 ]
  ret i1 %15
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define swiftcc range(i64 0, 1099511627776) i64 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV9selection0aB4Core0aF9SelectionVvg"(ptr readnone captures(none) %"GiftUIDiagnosticProjector<Sink>", ptr noalias readonly swiftself captures(none) %0) #4 {
entry:
  %1 = load i8, ptr %0, align 4
  %.selection.originMask = getelementptr inbounds nuw i8, ptr %0, i64 2
  %2 = load i16, ptr %.selection.originMask, align 2
  %.selection.minimumSeverity = getelementptr inbounds nuw i8, ptr %0, i64 4
  %3 = load i8, ptr %.selection.minimumSeverity, align 4
  %temp-coercion.coerced.sroa.5.0.insert.ext = zext i8 %3 to i64
  %temp-coercion.coerced.sroa.5.0.insert.shift = shl nuw nsw i64 %temp-coercion.coerced.sroa.5.0.insert.ext, 32
  %temp-coercion.coerced.sroa.41.0.insert.ext = zext i16 %2 to i64
  %temp-coercion.coerced.sroa.41.0.insert.shift = shl nuw nsw i64 %temp-coercion.coerced.sroa.41.0.insert.ext, 16
  %temp-coercion.coerced.sroa.0.0.insert.ext = zext i8 %1 to i64
  %temp-coercion.coerced.sroa.41.0.insert.insert = or disjoint i64 %temp-coercion.coerced.sroa.41.0.insert.shift, %temp-coercion.coerced.sroa.0.0.insert.ext
  %temp-coercion.coerced.sroa.0.0.insert.insert = or disjoint i64 %temp-coercion.coerced.sroa.41.0.insert.insert, %temp-coercion.coerced.sroa.5.0.insert.shift
  ret i64 %temp-coercion.coerced.sroa.0.0.insert.insert
}

define swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV4sinkxvg"(ptr noalias sret(%swift.opaque) %0, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>", ptr noalias swiftself %1) #3 {
entry:
  %2 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 36
  %3 = load i32, ptr %2, align 8
  %4 = sext i32 %3 to i64
  %5 = getelementptr inbounds i8, ptr %1, i64 %4
  %6 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 16
  %Sink = load ptr, ptr %6, align 8, !invariant.load !17
  %7 = getelementptr inbounds i8, ptr %Sink, i64 -8
  %Sink.valueWitnesses = load ptr, ptr %7, align 8, !invariant.load !17, !dereferenceable !18
  %8 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 16
  %InitializeWithCopy = load ptr, ptr %8, align 8, !invariant.load !17
  %9 = tail call ptr %InitializeWithCopy(ptr noalias %0, ptr noalias %5, ptr %Sink) #16
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define swiftcc { i64, i64, i1 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV8countersAA0aF16DeliveryCountersVvg"(ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>", ptr noalias readonly swiftself captures(none) %0) #4 {
entry:
  %1 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 40
  %2 = load i32, ptr %1, align 8
  %3 = sext i32 %2 to i64
  %4 = getelementptr inbounds i8, ptr %0, i64 %3
  %5 = load i64, ptr %4, align 4
  %.saturated = getelementptr inbounds nuw i8, ptr %4, i64 8
  %6 = load i64, ptr %.saturated, align 4
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %4, i64 16
  %7 = load i1, ptr %.countersSaturated, align 4
  %8 = insertvalue { i64, i64, i1 } undef, i64 %5, 0
  %9 = insertvalue { i64, i64, i1 } %8, i64 %6, 1
  %10 = insertvalue { i64, i64, i1 } %9, i1 %7, 2
  ret { i64, i64, i1 } %10
}

define swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV9selection4sinkACyxG0aB4Core0aF9SelectionV_xtcfC"(ptr noalias sret(%swift.opaque) initializes((0, 1), (2, 5)) %0, i64 %1, ptr noalias %2, ptr %Sink, ptr %Sink.GiftUIDiagnosticSink) #3 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %1 to i8
  %temp-coercion.coerced.sroa.41.0.extract.shift = lshr i64 %1, 16
  %temp-coercion.coerced.sroa.41.0.extract.trunc = trunc i64 %temp-coercion.coerced.sroa.41.0.extract.shift to i16
  %temp-coercion.coerced.sroa.5.0.extract.shift = lshr i64 %1, 32
  %temp-coercion.coerced.sroa.5.0.extract.trunc = trunc i64 %temp-coercion.coerced.sroa.5.0.extract.shift to i8
  store i8 %temp-coercion.coerced.sroa.0.0.extract.trunc, ptr %0, align 4
  %.selection.originMask = getelementptr inbounds nuw i8, ptr %0, i64 2
  store i16 %temp-coercion.coerced.sroa.41.0.extract.trunc, ptr %.selection.originMask, align 2
  %.selection.minimumSeverity = getelementptr inbounds nuw i8, ptr %0, i64 4
  store i8 %temp-coercion.coerced.sroa.5.0.extract.trunc, ptr %.selection.minimumSeverity, align 4
  %3 = tail call swiftcc %swift.metadata_response @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMa"(i64 0, ptr %Sink, ptr %Sink.GiftUIDiagnosticSink) #22
  %4 = extractvalue %swift.metadata_response %3, 0
  %5 = getelementptr inbounds nuw i8, ptr %4, i64 36
  %6 = load i32, ptr %5, align 8
  %7 = sext i32 %6 to i64
  %8 = getelementptr inbounds i8, ptr %0, i64 %7
  %9 = getelementptr inbounds i8, ptr %Sink, i64 -8
  %Sink.valueWitnesses = load ptr, ptr %9, align 8, !invariant.load !17, !dereferenceable !18
  %10 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 32
  %InitializeWithTake = load ptr, ptr %10, align 8, !invariant.load !17
  %11 = tail call ptr %InitializeWithTake(ptr noalias nonnull %8, ptr noalias %2, ptr %Sink) #16
  %12 = getelementptr inbounds nuw i8, ptr %4, i64 40
  %13 = load i32, ptr %12, align 8
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds i8, ptr %0, i64 %14
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(17) %15, i8 0, i64 17, i1 false)
  ret void
}

; Function Attrs: mustprogress nofree noinline nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMa"(i64 %0, ptr readnone %1, ptr readnone %2) #5 {
entry:
  %3 = tail call swiftcc %swift.metadata_response @__swift_instantiateGenericMetadata(i64 %0, ptr %1, ptr %2, ptr undef, ptr nonnull @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMn") #22
  ret %swift.metadata_response %3
}

define swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorV7project4kind6origin8severity6recordy0aB4Core0aF4KindO_AI0aB6OriginOAI0aF8SeverityOAI0aF6RecordVyXEtF"(i8 %0, i8 %1, i8 %2, ptr readonly captures(none) %3, ptr %4, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>", ptr swiftself %5) #3 {
entry:
  %6 = load i8, ptr %5, align 4
  %.selection.originMask = getelementptr inbounds nuw i8, ptr %5, i64 2
  %7 = load i16, ptr %.selection.originMask, align 2
  %.selection.minimumSeverity = getelementptr inbounds nuw i8, ptr %5, i64 4
  %8 = load i8, ptr %.selection.minimumSeverity, align 4
  %temp-coercion.coerced.sroa.5.0.insert.ext = zext i8 %8 to i64
  %temp-coercion.coerced.sroa.5.0.insert.shift = shl nuw nsw i64 %temp-coercion.coerced.sroa.5.0.insert.ext, 32
  %temp-coercion.coerced.sroa.43.0.insert.ext = zext i16 %7 to i64
  %temp-coercion.coerced.sroa.43.0.insert.shift = shl nuw nsw i64 %temp-coercion.coerced.sroa.43.0.insert.ext, 16
  %temp-coercion.coerced.sroa.0.0.insert.ext = zext i8 %6 to i64
  %temp-coercion.coerced.sroa.43.0.insert.insert = or disjoint i64 %temp-coercion.coerced.sroa.43.0.insert.shift, %temp-coercion.coerced.sroa.0.0.insert.ext
  %temp-coercion.coerced.sroa.0.0.insert.insert = or disjoint i64 %temp-coercion.coerced.sroa.43.0.insert.insert, %temp-coercion.coerced.sroa.5.0.insert.shift
  %9 = tail call swiftcc i1 @"$s17GiftUIFailureCore0A21UIDiagnosticSelectionV8includes4kind6origin8severitySbAA0aD4KindO_AA0aB6OriginOAA0aD8SeverityOtF"(i8 %0, i8 %1, i8 %2, i64 %temp-coercion.coerced.sroa.0.0.insert.insert)
  br i1 %9, label %10, label %28

10:                                               ; preds = %entry
  %11 = tail call swiftcc { i64, i64, i64 } %3(ptr swiftself %4)
  %12 = extractvalue { i64, i64, i64 } %11, 0
  %13 = extractvalue { i64, i64, i64 } %11, 1
  %14 = extractvalue { i64, i64, i64 } %11, 2
  %15 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 36
  %16 = load i32, ptr %15, align 8
  %17 = sext i32 %16 to i64
  %18 = getelementptr inbounds i8, ptr %5, i64 %17
  %19 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 24
  %Sink.GiftUIDiagnosticSink = load ptr, ptr %19, align 8, !invariant.load !17
  %20 = getelementptr inbounds nuw i8, ptr %Sink.GiftUIDiagnosticSink, i64 8
  %21 = load ptr, ptr %20, align 8, !invariant.load !17
  %22 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 16
  %Sink = load ptr, ptr %22, align 8, !invariant.load !17
  %23 = tail call swiftcc i8 %21(i64 %12, i64 %13, i64 %14, ptr nonnull swiftself %18, ptr %Sink, ptr %Sink.GiftUIDiagnosticSink)
  %24 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 40
  %25 = load i32, ptr %24, align 8
  %26 = sext i32 %25 to i64
  %27 = getelementptr inbounds i8, ptr %5, i64 %26
  tail call swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersV6recordyy0aB4Core0aF10SinkResultOF"(i8 %23, ptr swiftself captures(none) dereferenceable(17) %27)
  br label %28

28:                                               ; preds = %entry, %10
  ret void
}

declare swiftcc i1 @"$s17GiftUIFailureCore0A21UIDiagnosticSelectionV8includes4kind6origin8severitySbAA0aD4KindO_AA0aB6OriginOAA0aD8SeverityOtF"(i8, i8, i8, i64) local_unnamed_addr #3

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i8 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV5counts5UInt8Vvpfi"() #0 {
entry:
  ret i8 0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define swiftcc i8 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV5counts5UInt8Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(392) %0) #4 {
entry:
  %1 = load i8, ptr %0, align 4
  ret i8 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCounts6UInt32Vvpfi"() #0 {
entry:
  ret i32 0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define swiftcc i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCounts6UInt32Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(392) %0) #4 {
entry:
  %.droppedRecordCount = getelementptr inbounds nuw i8, ptr %0, i64 4
  %1 = load i32, ptr %.droppedRecordCount, align 4
  ret i32 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef nonnull ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8Vvau"() #0 {
entry:
  ret ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvpZ"
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i8 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8capacitys5UInt8VvgZ"() #0 {
entry:
  ret i8 16
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record133_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record233_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record333_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record433_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record533_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record633_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record733_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record833_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7record933_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1033_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1133_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1233_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1333_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1433_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV8record1533_481FAB364D938FDBB52660A85D053959LL0aB4Core0A18UIDiagnosticRecordVvpfi"() #0 {
entry:
  ret { i64, i64, i64 } zeroinitializer
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVACycfC"(ptr noalias writeonly sret(%T35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV) captures(none) initializes((0, 1), (4, 392)) %0) #6 {
entry:
  store i8 0, ptr %0, align 4
  %.sroa.5.0..sroa_idx157 = getelementptr inbounds nuw i8, ptr %0, i64 4
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(388) %.sroa.5.0..sroa_idx157, i8 0, i64 388, i1 false)
  ret void
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #7

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define swiftcc void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV18droppedRecordCountACs6UInt32V_tcfC"(ptr noalias writeonly sret(%T35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV) captures(none) initializes((0, 1), (4, 392)) %0, i32 %1) #6 {
entry:
  store i8 0, ptr %0, align 4
  %.sroa.5.0..sroa_idx157 = getelementptr inbounds nuw i8, ptr %0, i64 4
  store i32 %1, ptr %.sroa.5.0..sroa_idx157, align 4
  %.sroa.6.0..sroa_idx158 = getelementptr inbounds nuw i8, ptr %0, i64 8
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(384) %.sroa.6.0..sroa_idx158, i8 0, i64 384, i1 false)
  ret void
}

; Function Attrs: nounwind memory(argmem: readwrite, inaccessiblemem: write)
define swiftcc range(i8 0, 3) i8 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7consumey0aB4Core0A22UIDiagnosticSinkResultOAE0aK6RecordVF"(i64 %0, i64 %1, i64 %2, ptr swiftself captures(none) dereferenceable(392) %3) #8 {
entry:
  %4 = load i8, ptr %3, align 4
  %5 = icmp ult i8 %4, 16
  br i1 %5, label %switch.lookup, label %14

switch.lookup:                                    ; preds = %entry
  %switch.idx.cast = zext nneg i8 %4 to i64
  %switch.idx.mult = mul nuw nsw i64 %switch.idx.cast, 24
  %switch.idx.cast5 = zext nneg i8 %4 to i64
  %switch.idx.mult6 = mul nuw nsw i64 %switch.idx.cast5, 24
  %switch.idx.cast8 = zext nneg i8 %4 to i64
  %switch.idx.mult9 = mul nuw nsw i64 %switch.idx.cast8, 24
  %6 = getelementptr inbounds nuw i8, ptr %3, i64 %switch.idx.mult
  %.record0.i = getelementptr inbounds nuw i8, ptr %6, i64 8
  store i64 %0, ptr %.record0.i, align 4
  %7 = getelementptr inbounds nuw i8, ptr %3, i64 %switch.idx.mult6
  %.sroa.19.0..record0.sroa_idx.i = getelementptr inbounds nuw i8, ptr %7, i64 16
  store i64 %1, ptr %.sroa.19.0..record0.sroa_idx.i, align 4
  %8 = getelementptr inbounds nuw i8, ptr %3, i64 %switch.idx.mult9
  %.sroa.20.0..record0.sroa_idx.i = getelementptr inbounds nuw i8, ptr %8, i64 24
  store i64 %2, ptr %.sroa.20.0..record0.sroa_idx.i, align 4
  %9 = load i8, ptr %3, align 4
  %10 = tail call { i8, i1 } @llvm.uadd.with.overflow.i8(i8 %9, i8 1)
  %11 = extractvalue { i8, i1 } %10, 1
  br i1 %11, label %20, label %12, !prof !19

12:                                               ; preds = %switch.lookup
  %13 = extractvalue { i8, i1 } %10, 0
  store i8 %13, ptr %3, align 4
  br label %18

14:                                               ; preds = %entry
  %.droppedRecordCount = getelementptr inbounds nuw i8, ptr %3, i64 4
  %15 = load i32, ptr %.droppedRecordCount, align 4
  %.not = icmp eq i32 %15, -1
  br i1 %.not, label %18, label %16

16:                                               ; preds = %14
  %17 = add nuw i32 %15, 1
  store i32 %17, ptr %.droppedRecordCount, align 4
  br label %18

18:                                               ; preds = %16, %14, %12
  %19 = phi i8 [ 0, %12 ], [ 2, %14 ], [ 2, %16 ]
  ret i8 %19

20:                                               ; preds = %switch.lookup
  tail call void @llvm.trap() #23
  unreachable
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i8, i1 } @llvm.uadd.with.overflow.i8(i8, i8) #9

; Function Attrs: cold noreturn nounwind memory(inaccessiblemem: write)
declare void @llvm.trap() #10

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define swiftcc { i64, i64, i64 } @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVy0aB4Core0A18UIDiagnosticRecordVSgs5UInt8Vcig"(i8 %0, ptr noalias readonly swiftself captures(none) dereferenceable(392) %1) #4 {
entry:
  %.sroa.0.0.copyload = load i8, ptr %1, align 4
  %2 = icmp ult i8 %0, %.sroa.0.0.copyload
  %3 = icmp ult i8 %0, 16
  %or.cond = and i1 %2, %3
  br i1 %or.cond, label %switch.lookup, label %"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV12storedRecord33_481FAB364D938FDBB52660A85D053959LL2at0aB4Core0a12UIDiagnosticJ0VSgs5UInt8V_tF.exit"

switch.lookup:                                    ; preds = %entry
  %switch.idx.cast = zext nneg i8 %0 to i64
  %switch.idx.mult = mul nuw nsw i64 %switch.idx.cast, 24
  %switch.idx.cast1 = zext nneg i8 %0 to i64
  %switch.idx.mult2 = mul nuw nsw i64 %switch.idx.cast1, 24
  %switch.idx.cast4 = zext nneg i8 %0 to i64
  %switch.idx.mult5 = mul nuw nsw i64 %switch.idx.cast4, 24
  %4 = getelementptr inbounds nuw i8, ptr %1, i64 %switch.idx.mult
  %.record0.i = getelementptr inbounds nuw i8, ptr %4, i64 8
  %.sroa.0.0.copyload.i = load i64, ptr %.record0.i, align 4, !alias.scope !20
  %5 = getelementptr inbounds nuw i8, ptr %1, i64 %switch.idx.mult2
  %.sroa.4.0..record0.sroa_idx.i = getelementptr inbounds nuw i8, ptr %5, i64 16
  %.sroa.4.0.copyload.i = load i64, ptr %.sroa.4.0..record0.sroa_idx.i, align 4, !alias.scope !20
  %6 = getelementptr inbounds nuw i8, ptr %1, i64 %switch.idx.mult5
  %.sroa.5.0..record0.sroa_idx.i = getelementptr inbounds nuw i8, ptr %6, i64 24
  %.sroa.5.0.copyload.i = load i64, ptr %.sroa.5.0..record0.sroa_idx.i, align 4, !alias.scope !20
  br label %"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV12storedRecord33_481FAB364D938FDBB52660A85D053959LL2at0aB4Core0a12UIDiagnosticJ0VSgs5UInt8V_tF.exit"

"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV12storedRecord33_481FAB364D938FDBB52660A85D053959LL2at0aB4Core0a12UIDiagnosticJ0VSgs5UInt8V_tF.exit": ; preds = %switch.lookup, %entry
  %7 = phi i64 [ 4, %entry ], [ %.sroa.0.0.copyload.i, %switch.lookup ]
  %8 = phi i64 [ 0, %entry ], [ %.sroa.4.0.copyload.i, %switch.lookup ]
  %9 = phi i64 [ 0, %entry ], [ %.sroa.5.0.copyload.i, %switch.lookup ]
  %10 = insertvalue { i64, i64, i64 } undef, i64 %7, 0
  %11 = insertvalue { i64, i64, i64 } %10, i64 %8, 1
  %12 = insertvalue { i64, i64, i64 } %11, i64 %9, 2
  ret { i64, i64, i64 } %12
}

define linkonce_odr hidden swiftcc i8 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV0aB4Core0A16UIDiagnosticSinkAadEP7consumeyAD0ajK6ResultOAD0aJ6RecordVFTW"(i64 %0, i64 %1, i64 %2, ptr swiftself captures(none) dereferenceable(392) %3, ptr %Self, ptr %SelfWitnessTable) #3 {
entry:
  %4 = tail call swiftcc i8 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV7consumey0aB4Core0A22UIDiagnosticSinkResultOAE0aK6RecordVF"(i64 %0, i64 %1, i64 %2, ptr nonnull swiftself captures(none) dereferenceable(392) %3) #24
  ret i8 %4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO20deliveryCountersSizes6UInt32VyFZ"() #11 {
entry:
  ret i32 17
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO22deliveryCountersStrides6UInt32VyFZ"() #11 {
entry:
  ret i32 20
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO25deliveryCountersAlignments6UInt32VyFZ"() #11 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO23diagnosticProjectorSizes6UInt32VyFZ"() #11 {
entry:
  ret i32 417
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO25diagnosticProjectorStrides6UInt32VyFZ"() #11 {
entry:
  ret i32 420
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO28diagnosticProjectorAlignments6UInt32VyFZ"() #11 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO25fixedDiagnosticBufferSizes6UInt32VyFZ"() #11 {
entry:
  ret i32 392
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO27fixedDiagnosticBufferStrides6UInt32VyFZ"() #11 {
entry:
  ret i32 392
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO30fixedDiagnosticBufferAlignments6UInt32VyFZ"() #11 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i8 @"$s35GiftUIFailureDiagnosticsLayoutProbeAAO29fixedDiagnosticBufferCapacitys5UInt8VyFZ"() #11 {
entry:
  ret i8 16
}

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy17_4(ptr %0, ptr %1, ptr %2) #12 {
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 4 dereferenceable(17) %0, ptr noundef nonnull align 4 dereferenceable(17) %1, i64 17, i1 false)
  ret ptr %0
}

; Function Attrs: nounwind
define linkonce_odr hidden void @__swift_noop_void_return(ptr %0, ptr %1) #12 {
entry:
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %GiftUIDiagnosticDeliveryCounters) #4 {
entry:
  %0 = icmp eq i32 %numEmptyCases, 0
  br i1 %0, label %21, label %1

1:                                                ; preds = %entry
  %2 = icmp ugt i32 %numEmptyCases, 254
  br i1 %2, label %3, label %11

3:                                                ; preds = %1
  %4 = getelementptr inbounds nuw i8, ptr %value, i64 17
  %5 = load i8, ptr %4, align 1
  %6 = icmp eq i8 %5, 0
  br i1 %6, label %11, label %7

7:                                                ; preds = %3
  %8 = load i136, ptr %value, align 1
  %9 = trunc i136 %8 to i32
  %10 = add i32 %9, 254
  br label %21

11:                                               ; preds = %3, %1
  %value.countersSaturated = getelementptr inbounds nuw i8, ptr %value, i64 16
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
define internal void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %GiftUIDiagnosticDeliveryCounters) #6 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i64 17
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
  br i1 %6, label %19, label %7

7:                                                ; preds = %5
  %value.countersSaturated = getelementptr inbounds nuw i8, ptr %value, i64 16
  %8 = trunc nuw i32 %whichCase to i8
  %9 = add i8 %8, -1
  %10 = and i8 %9, 1
  %11 = and i8 %9, -2
  %12 = add nuw i8 %11, 2
  %13 = or disjoint i8 %12, %10
  store i8 %13, ptr %value.countersSaturated, align 4
  br label %19

14:                                               ; preds = %entry
  %15 = add i32 %whichCase, -255
  %16 = zext i32 %15 to i64
  store i64 %16, ptr %value, align 4
  %17 = getelementptr inbounds nuw i8, ptr %value, i64 8
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(9) %17, i8 0, i64 9, i1 false)
  br i1 %1, label %18, label %19

18:                                               ; preds = %14
  store i8 1, ptr %0, align 1
  br label %19

19:                                               ; preds = %14, %18, %7, %5
  ret void
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #13

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMa"(i64 %0) #11 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32, i32, i32, i32, [4 x i8] }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A28UIDiagnosticDeliveryCountersVMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: nounwind
define internal ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMi"(ptr %0, ptr %1, ptr %2) #12 {
entry:
  %3 = tail call ptr @swift_allocateGenericValueMetadata(ptr %0, ptr %1, ptr %2, i64 32) #16
  ret ptr %3
}

; Function Attrs: nounwind
define internal swiftcc %swift.metadata_response @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVMr"(ptr %"GiftUIDiagnosticProjector<Sink>", ptr readnone captures(none) %0, ptr readnone captures(none) %1) #12 {
entry:
  %classFields = alloca [3 x ptr], align 8
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %classFields)
  store ptr @type_layout_5_2_fa_pod, ptr %classFields, align 8
  %2 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 16
  %Sink = load ptr, ptr %2, align 8, !invariant.load !17
  %3 = tail call swiftcc %swift.metadata_response @swift_checkMetadataState(i64 319, ptr %Sink) #25
  %4 = extractvalue %swift.metadata_response %3, 0
  %5 = extractvalue %swift.metadata_response %3, 1
  %6 = icmp ult i64 %5, 64
  br i1 %6, label %dependency-satisfied, label %metadata-dependencies.cont

dependency-satisfied:                             ; preds = %entry
  %7 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 32
  %8 = getelementptr inbounds i8, ptr %4, i64 -8
  %.valueWitnesses = load ptr, ptr %8, align 8, !invariant.load !17, !dereferenceable !18
  %9 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 64
  %10 = getelementptr inbounds nuw i8, ptr %classFields, i64 8
  store ptr %9, ptr %10, align 8
  %11 = getelementptr inbounds nuw i8, ptr %classFields, i64 16
  store ptr @type_layout_17_4_fe_pod, ptr %11, align 8
  call void @swift_initStructMetadata(ptr nonnull %"GiftUIDiagnosticProjector<Sink>", i64 0, i64 3, ptr nonnull %classFields, ptr nonnull %7) #16
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %classFields)
  br label %metadata-dependencies.cont

metadata-dependencies.cont:                       ; preds = %dependency-satisfied, %entry
  %12 = phi ptr [ %4, %entry ], [ null, %dependency-satisfied ]
  %13 = phi i64 [ 63, %entry ], [ 0, %dependency-satisfied ]
  %14 = insertvalue %swift.metadata_response undef, ptr %12, 0
  %15 = insertvalue %swift.metadata_response %14, i64 %13, 1
  ret %swift.metadata_response %15
}

; Function Attrs: nounwind
define internal ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwCP"(ptr noalias initializes((0, 5)) %dest, ptr noalias %src, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #12 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 16
  %Sink = load ptr, ptr %0, align 8, !invariant.load !17
  %1 = getelementptr inbounds i8, ptr %Sink, i64 -8
  %Sink.valueWitnesses = load ptr, ptr %1, align 8, !invariant.load !17, !dereferenceable !18
  %2 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 80
  %flags = load i32, ptr %2, align 8, !invariant.load !17
  %3 = and i32 %flags, 255
  %flags.alignmentMask = zext nneg i32 %3 to i64
  %4 = xor i64 %flags.alignmentMask, -1
  %5 = add nuw nsw i64 %flags.alignmentMask, 5
  %6 = and i64 %5, %4
  %7 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 64
  %size = load i64, ptr %7, align 8, !invariant.load !17
  %8 = add i64 %size, 3
  %9 = add i64 %8, %6
  %10 = and i64 %9, -4
  %size1 = add i64 %10, 17
  %11 = and i32 %flags, 1048576
  %flags.isBitwiseTakable = icmp eq i32 %11, 0
  %12 = icmp samesign ult i32 %3, 8
  %13 = icmp ult i64 %size1, 25
  %14 = and i1 %flags.isBitwiseTakable, %13
  %15 = and i1 %12, %14
  br i1 %15, label %inlineBB, label %allocateBB

inlineBB:                                         ; preds = %entry
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 2 dereferenceable(5) %dest, ptr noundef nonnull align 2 dereferenceable(5) %src, i64 5, i1 false)
  %16 = ptrtoint ptr %dest to i64
  %17 = add i64 %16, 5
  %18 = ptrtoint ptr %src to i64
  %19 = add i64 %18, 5
  %20 = add i64 %17, %flags.alignmentMask
  %21 = and i64 %20, %4
  %22 = inttoptr i64 %21 to ptr
  %23 = add i64 %19, %flags.alignmentMask
  %24 = and i64 %23, %4
  %25 = inttoptr i64 %24 to ptr
  %26 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 16
  %InitializeWithCopy = load ptr, ptr %26, align 8, !invariant.load !17
  %27 = tail call ptr %InitializeWithCopy(ptr noalias %22, ptr noalias %25, ptr nonnull %Sink) #16
  %28 = add i64 %8, %21
  %29 = and i64 %28, -4
  %30 = inttoptr i64 %29 to ptr
  %31 = add i64 %8, %24
  %32 = and i64 %31, -4
  %33 = inttoptr i64 %32 to ptr
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 4 dereferenceable(17) %30, ptr noundef nonnull align 4 dereferenceable(17) %33, i64 17, i1 false)
  br label %41

allocateBB:                                       ; preds = %entry
  %34 = load ptr, ptr %src, align 8
  store ptr %34, ptr %dest, align 8
  %35 = add nuw nsw i64 %flags.alignmentMask, 16
  %36 = and i64 %flags.alignmentMask, 252
  %37 = xor i64 %36, 508
  %38 = and i64 %37, %35
  %39 = getelementptr inbounds nuw i8, ptr %34, i64 %38
  %40 = tail call ptr @swift_retain(ptr returned %34) #26
  br label %41

41:                                               ; preds = %allocateBB, %inlineBB
  %42 = phi ptr [ %dest, %inlineBB ], [ %39, %allocateBB ]
  ret ptr %42
}

; Function Attrs: mustprogress nounwind willreturn
declare ptr @swift_retain(ptr returned) local_unnamed_addr #14

; Function Attrs: nounwind
define internal void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwxx"(ptr noalias %object, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #12 {
entry:
  %0 = ptrtoint ptr %object to i64
  %1 = add i64 %0, 5
  %2 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 16
  %Sink = load ptr, ptr %2, align 8, !invariant.load !17
  %3 = getelementptr inbounds i8, ptr %Sink, i64 -8
  %Sink.valueWitnesses = load ptr, ptr %3, align 8, !invariant.load !17, !dereferenceable !18
  %4 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 80
  %flags = load i32, ptr %4, align 8, !invariant.load !17
  %5 = and i32 %flags, 255
  %flags.alignmentMask = zext nneg i32 %5 to i64
  %6 = add i64 %1, %flags.alignmentMask
  %7 = xor i64 %flags.alignmentMask, -1
  %8 = and i64 %6, %7
  %9 = inttoptr i64 %8 to ptr
  %10 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 8
  %Destroy = load ptr, ptr %10, align 8, !invariant.load !17
  tail call void %Destroy(ptr noalias %9, ptr %Sink) #16
  ret void
}

; Function Attrs: nounwind
define internal noundef ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwcp"(ptr noalias returned initializes((0, 5)) %dest, ptr noalias %src, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #12 {
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 2 dereferenceable(5) %dest, ptr noundef nonnull align 2 dereferenceable(5) %src, i64 5, i1 false)
  %0 = ptrtoint ptr %dest to i64
  %1 = ptrtoint ptr %src to i64
  %2 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 16
  %Sink = load ptr, ptr %2, align 8, !invariant.load !17
  %3 = getelementptr inbounds i8, ptr %Sink, i64 -8
  %Sink.valueWitnesses = load ptr, ptr %3, align 8, !invariant.load !17, !dereferenceable !18
  %4 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 80
  %flags = load i32, ptr %4, align 8, !invariant.load !17
  %5 = and i32 %flags, 255
  %flags.alignmentMask = zext nneg i32 %5 to i64
  %6 = add nuw nsw i64 %flags.alignmentMask, 5
  %7 = add i64 %6, %0
  %8 = xor i64 %flags.alignmentMask, -1
  %9 = and i64 %7, %8
  %10 = inttoptr i64 %9 to ptr
  %11 = add i64 %6, %1
  %12 = and i64 %11, %8
  %13 = inttoptr i64 %12 to ptr
  %14 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 16
  %InitializeWithCopy = load ptr, ptr %14, align 8, !invariant.load !17
  %15 = tail call ptr %InitializeWithCopy(ptr noalias %10, ptr noalias %13, ptr %Sink) #16
  %16 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 64
  %size = load i64, ptr %16, align 8, !invariant.load !17
  %17 = add i64 %size, 3
  %18 = add i64 %17, %9
  %19 = and i64 %18, -4
  %20 = inttoptr i64 %19 to ptr
  %21 = add i64 %17, %12
  %22 = and i64 %21, -4
  %23 = inttoptr i64 %22 to ptr
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 4 dereferenceable(17) %20, ptr noundef nonnull align 4 dereferenceable(17) %23, i64 17, i1 false)
  ret ptr %dest
}

; Function Attrs: nounwind
define internal noundef ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwca"(ptr returned initializes((0, 1), (2, 5)) %dest, ptr %src, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #12 {
entry:
  %0 = load i8, ptr %src, align 2
  store i8 %0, ptr %dest, align 2
  %dest.originMask = getelementptr inbounds nuw i8, ptr %dest, i64 2
  %src.originMask = getelementptr inbounds nuw i8, ptr %src, i64 2
  %1 = load i16, ptr %src.originMask, align 2
  store i16 %1, ptr %dest.originMask, align 2
  %dest.minimumSeverity = getelementptr inbounds nuw i8, ptr %dest, i64 4
  %src.minimumSeverity = getelementptr inbounds nuw i8, ptr %src, i64 4
  %2 = load i8, ptr %src.minimumSeverity, align 2
  store i8 %2, ptr %dest.minimumSeverity, align 2
  %3 = ptrtoint ptr %dest to i64
  %4 = ptrtoint ptr %src to i64
  %5 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 16
  %Sink = load ptr, ptr %5, align 8, !invariant.load !17
  %6 = getelementptr inbounds i8, ptr %Sink, i64 -8
  %Sink.valueWitnesses = load ptr, ptr %6, align 8, !invariant.load !17, !dereferenceable !18
  %7 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 80
  %flags = load i32, ptr %7, align 8, !invariant.load !17
  %8 = and i32 %flags, 255
  %flags.alignmentMask = zext nneg i32 %8 to i64
  %9 = add nuw nsw i64 %flags.alignmentMask, 5
  %10 = add i64 %9, %3
  %11 = xor i64 %flags.alignmentMask, -1
  %12 = and i64 %10, %11
  %13 = inttoptr i64 %12 to ptr
  %14 = add i64 %9, %4
  %15 = and i64 %14, %11
  %16 = inttoptr i64 %15 to ptr
  %17 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 24
  %AssignWithCopy = load ptr, ptr %17, align 8, !invariant.load !17
  %18 = tail call ptr %AssignWithCopy(ptr %13, ptr %16, ptr %Sink) #16
  %19 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 64
  %size = load i64, ptr %19, align 8, !invariant.load !17
  %20 = add i64 %size, 3
  %21 = add i64 %20, %12
  %22 = and i64 %21, -4
  %23 = inttoptr i64 %22 to ptr
  %24 = add i64 %20, %15
  %25 = and i64 %24, -4
  %26 = inttoptr i64 %25 to ptr
  %27 = load i32, ptr %26, align 4
  store i32 %27, ptr %23, align 4
  %.dropped = getelementptr inbounds nuw i8, ptr %23, i64 4
  %.dropped2 = getelementptr inbounds nuw i8, ptr %26, i64 4
  %28 = load i32, ptr %.dropped2, align 4
  store i32 %28, ptr %.dropped, align 4
  %.saturated = getelementptr inbounds nuw i8, ptr %23, i64 8
  %.saturated3 = getelementptr inbounds nuw i8, ptr %26, i64 8
  %29 = load i32, ptr %.saturated3, align 4
  store i32 %29, ptr %.saturated, align 4
  %.failed = getelementptr inbounds nuw i8, ptr %23, i64 12
  %.failed4 = getelementptr inbounds nuw i8, ptr %26, i64 12
  %30 = load i32, ptr %.failed4, align 4
  store i32 %30, ptr %.failed, align 4
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %23, i64 16
  %.countersSaturated5 = getelementptr inbounds nuw i8, ptr %26, i64 16
  %31 = load i1, ptr %.countersSaturated5, align 4
  %32 = zext i1 %31 to i8
  store i8 %32, ptr %.countersSaturated, align 4
  ret ptr %dest
}

; Function Attrs: nounwind
define internal noundef ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwtk"(ptr noalias returned initializes((0, 5)) %dest, ptr noalias %src, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #12 {
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 2 dereferenceable(5) %dest, ptr noundef nonnull align 2 dereferenceable(5) %src, i64 5, i1 false)
  %0 = ptrtoint ptr %dest to i64
  %1 = ptrtoint ptr %src to i64
  %2 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 16
  %Sink = load ptr, ptr %2, align 8, !invariant.load !17
  %3 = getelementptr inbounds i8, ptr %Sink, i64 -8
  %Sink.valueWitnesses = load ptr, ptr %3, align 8, !invariant.load !17, !dereferenceable !18
  %4 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 80
  %flags = load i32, ptr %4, align 8, !invariant.load !17
  %5 = and i32 %flags, 255
  %flags.alignmentMask = zext nneg i32 %5 to i64
  %6 = add nuw nsw i64 %flags.alignmentMask, 5
  %7 = add i64 %6, %0
  %8 = xor i64 %flags.alignmentMask, -1
  %9 = and i64 %7, %8
  %10 = inttoptr i64 %9 to ptr
  %11 = add i64 %6, %1
  %12 = and i64 %11, %8
  %13 = inttoptr i64 %12 to ptr
  %14 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 32
  %InitializeWithTake = load ptr, ptr %14, align 8, !invariant.load !17
  %15 = tail call ptr %InitializeWithTake(ptr noalias %10, ptr noalias %13, ptr %Sink) #16
  %16 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 64
  %size = load i64, ptr %16, align 8, !invariant.load !17
  %17 = add i64 %size, 3
  %18 = add i64 %17, %9
  %19 = and i64 %18, -4
  %20 = inttoptr i64 %19 to ptr
  %21 = add i64 %17, %12
  %22 = and i64 %21, -4
  %23 = inttoptr i64 %22 to ptr
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 4 dereferenceable(17) %20, ptr noundef nonnull align 4 dereferenceable(17) %23, i64 17, i1 false)
  ret ptr %dest
}

; Function Attrs: nounwind
define internal noundef ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwta"(ptr noalias returned initializes((0, 1), (2, 5)) %dest, ptr noalias %src, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #12 {
entry:
  %0 = load i8, ptr %src, align 2
  store i8 %0, ptr %dest, align 2
  %dest.originMask = getelementptr inbounds nuw i8, ptr %dest, i64 2
  %src.originMask = getelementptr inbounds nuw i8, ptr %src, i64 2
  %1 = load i16, ptr %src.originMask, align 2
  store i16 %1, ptr %dest.originMask, align 2
  %dest.minimumSeverity = getelementptr inbounds nuw i8, ptr %dest, i64 4
  %src.minimumSeverity = getelementptr inbounds nuw i8, ptr %src, i64 4
  %2 = load i8, ptr %src.minimumSeverity, align 2
  store i8 %2, ptr %dest.minimumSeverity, align 2
  %3 = ptrtoint ptr %dest to i64
  %4 = ptrtoint ptr %src to i64
  %5 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 16
  %Sink = load ptr, ptr %5, align 8, !invariant.load !17
  %6 = getelementptr inbounds i8, ptr %Sink, i64 -8
  %Sink.valueWitnesses = load ptr, ptr %6, align 8, !invariant.load !17, !dereferenceable !18
  %7 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 80
  %flags = load i32, ptr %7, align 8, !invariant.load !17
  %8 = and i32 %flags, 255
  %flags.alignmentMask = zext nneg i32 %8 to i64
  %9 = add nuw nsw i64 %flags.alignmentMask, 5
  %10 = add i64 %9, %3
  %11 = xor i64 %flags.alignmentMask, -1
  %12 = and i64 %10, %11
  %13 = inttoptr i64 %12 to ptr
  %14 = add i64 %9, %4
  %15 = and i64 %14, %11
  %16 = inttoptr i64 %15 to ptr
  %17 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 40
  %AssignWithTake = load ptr, ptr %17, align 8, !invariant.load !17
  %18 = tail call ptr %AssignWithTake(ptr noalias %13, ptr noalias %16, ptr %Sink) #16
  %19 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 64
  %size = load i64, ptr %19, align 8, !invariant.load !17
  %20 = add i64 %size, 3
  %21 = add i64 %20, %12
  %22 = and i64 %21, -4
  %23 = inttoptr i64 %22 to ptr
  %24 = add i64 %20, %15
  %25 = and i64 %24, -4
  %26 = inttoptr i64 %25 to ptr
  %27 = load i32, ptr %26, align 4
  store i32 %27, ptr %23, align 4
  %.dropped = getelementptr inbounds nuw i8, ptr %23, i64 4
  %.dropped2 = getelementptr inbounds nuw i8, ptr %26, i64 4
  %28 = load i32, ptr %.dropped2, align 4
  store i32 %28, ptr %.dropped, align 4
  %.saturated = getelementptr inbounds nuw i8, ptr %23, i64 8
  %.saturated3 = getelementptr inbounds nuw i8, ptr %26, i64 8
  %29 = load i32, ptr %.saturated3, align 4
  store i32 %29, ptr %.saturated, align 4
  %.failed = getelementptr inbounds nuw i8, ptr %23, i64 12
  %.failed4 = getelementptr inbounds nuw i8, ptr %26, i64 12
  %30 = load i32, ptr %.failed4, align 4
  store i32 %30, ptr %.failed, align 4
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %23, i64 16
  %.countersSaturated5 = getelementptr inbounds nuw i8, ptr %26, i64 16
  %31 = load i1, ptr %.countersSaturated5, align 4
  %32 = zext i1 %31 to i8
  store i8 %32, ptr %.countersSaturated, align 4
  ret ptr %dest
}

; Function Attrs: nofree nounwind memory(read)
define internal i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwet"(ptr noalias %value, i32 %numEmptyCases, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #15 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 16
  %Sink = load ptr, ptr %0, align 8, !invariant.load !17
  %1 = getelementptr inbounds i8, ptr %Sink, i64 -8
  %Sink.valueWitnesses = load ptr, ptr %1, align 8, !invariant.load !17, !dereferenceable !18
  %2 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 84
  %extraInhabitantCount = load i32, ptr %2, align 4, !invariant.load !17
  %num-extra-inhabitants = tail call i32 @llvm.umax.i32(i32 %extraInhabitantCount, i32 254)
  %3 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 80
  %flags = load i32, ptr %3, align 8, !invariant.load !17
  %4 = and i32 %flags, 255
  %flags.alignmentMask = zext nneg i32 %4 to i64
  %5 = xor i64 %flags.alignmentMask, -1
  %6 = add nuw nsw i64 %flags.alignmentMask, 5
  %7 = and i64 %6, %5
  %8 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 64
  %size = load i64, ptr %8, align 8, !invariant.load !17
  %9 = add i64 %size, 3
  %10 = add i64 %9, %7
  %11 = and i64 %10, -4
  %size1 = add i64 %11, 17
  %12 = trunc i64 %size1 to i32
  %13 = icmp eq i32 %numEmptyCases, 0
  br i1 %13, label %found_max_xi, label %14

14:                                               ; preds = %entry
  %15 = icmp ugt i32 %numEmptyCases, %num-extra-inhabitants
  br i1 %15, label %16, label %.thread

16:                                               ; preds = %14
  %17 = icmp ugt i32 %12, 3
  %18 = add i32 %numEmptyCases, 255
  %19 = sub i32 %18, %num-extra-inhabitants
  %20 = lshr i32 %19, 8
  %21 = add nuw nsw i32 %20, 1
  %num-tags-phi = select i1 %17, i32 2, i32 %21
  %22 = icmp samesign ult i32 %num-tags-phi, 2
  %23 = icmp samesign ult i32 %num-tags-phi, 256
  %24 = icmp samesign ult i32 %num-tags-phi, 65536
  %25 = select i1 %24, i32 2, i32 4
  %26 = select i1 %23, i32 1, i32 %25
  %num-tag-bytes = select i1 %22, i32 0, i32 %26
  %27 = getelementptr inbounds i8, ptr %value, i64 %size1
  switch i32 %num-tag-bytes, label %36 [
    i32 0, label %.thread
    i32 1, label %28
    i32 2, label %31
    i32 4, label %34
  ]

28:                                               ; preds = %16
  %29 = load i8, ptr %27, align 1
  %30 = zext i8 %29 to i32
  br label %37

31:                                               ; preds = %16
  %32 = load i16, ptr %27, align 1
  %33 = zext i16 %32 to i32
  br label %37

34:                                               ; preds = %16
  %35 = load i32, ptr %27, align 1
  br label %37

36:                                               ; preds = %16
  unreachable

37:                                               ; preds = %34, %31, %28
  %38 = phi i32 [ %30, %28 ], [ %33, %31 ], [ %35, %34 ]
  %39 = icmp eq i32 %38, 0
  br i1 %39, label %.thread, label %40

40:                                               ; preds = %37
  %41 = add i32 %38, -1
  %42 = shl i32 %12, 3
  %43 = shl i32 %41, %42
  %44 = select i1 %17, i32 0, i32 %43
  br i1 %17, label %48, label %45

45:                                               ; preds = %40
  %46 = load i8, ptr %value, align 4
  %47 = zext i8 %46 to i32
  br label %50

48:                                               ; preds = %40
  %49 = load i32, ptr %value, align 4
  br label %50

50:                                               ; preds = %45, %48
  %51 = phi i32 [ %47, %45 ], [ %49, %48 ]
  %52 = or i32 %51, %44
  %53 = add nuw i32 %num-extra-inhabitants, 1
  %54 = add i32 %53, %52
  br label %found_max_xi

.thread:                                          ; preds = %16, %37, %14
  %55 = ptrtoint ptr %value to i64
  %56 = add i64 %55, 5
  %57 = add i64 %56, %flags.alignmentMask
  %58 = and i64 %57, %5
  %59 = icmp ugt i32 %extraInhabitantCount, 253
  br i1 %59, label %60, label %64

60:                                               ; preds = %.thread
  %61 = inttoptr i64 %58 to ptr
  %62 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 48
  %GetEnumTagSinglePayload = load ptr, ptr %62, align 8, !invariant.load !17
  %63 = tail call i32 %GetEnumTagSinglePayload(ptr noalias %61, i32 %extraInhabitantCount, ptr nonnull %Sink) #27
  br label %found_max_xi

64:                                               ; preds = %.thread
  %65 = add i64 %9, %58
  %66 = and i64 %65, -4
  %67 = inttoptr i64 %66 to ptr
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %67, i64 16
  %68 = load i8, ptr %.countersSaturated, align 4
  %69 = icmp ult i8 %68, 2
  br i1 %69, label %found_max_xi, label %70

70:                                               ; preds = %64
  %71 = zext i8 %68 to i31
  %72 = and i31 %71, 1
  %73 = and i31 %71, 254
  %74 = add nsw i31 %73, -2
  %75 = or disjoint i31 %74, %72
  %76 = zext nneg i31 %75 to i32
  %77 = add nuw nsw i32 %76, 1
  br label %found_max_xi

found_max_xi:                                     ; preds = %70, %64, %entry, %60, %50
  %78 = phi i32 [ %54, %50 ], [ %63, %60 ], [ 0, %entry ], [ 0, %64 ], [ %77, %70 ]
  ret i32 %78
}

; Function Attrs: nounwind
define internal void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A21UIDiagnosticProjectorVwst"(ptr noalias %value, i32 %whichCase, i32 %numEmptyCases, ptr readonly captures(none) %"GiftUIDiagnosticProjector<Sink>") #12 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %"GiftUIDiagnosticProjector<Sink>", i64 16
  %Sink = load ptr, ptr %0, align 8, !invariant.load !17
  %1 = getelementptr inbounds i8, ptr %Sink, i64 -8
  %Sink.valueWitnesses = load ptr, ptr %1, align 8, !invariant.load !17, !dereferenceable !18
  %2 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 84
  %extraInhabitantCount = load i32, ptr %2, align 4, !invariant.load !17
  %num-extra-inhabitants = tail call i32 @llvm.umax.i32(i32 %extraInhabitantCount, i32 254)
  %3 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 80
  %flags = load i32, ptr %3, align 8, !invariant.load !17
  %4 = and i32 %flags, 255
  %flags.alignmentMask = zext nneg i32 %4 to i64
  %5 = xor i64 %flags.alignmentMask, -1
  %6 = add nuw nsw i64 %flags.alignmentMask, 5
  %7 = and i64 %6, %5
  %8 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 64
  %size = load i64, ptr %8, align 8, !invariant.load !17
  %9 = add i64 %size, 3
  %10 = add i64 %9, %7
  %11 = and i64 %10, -4
  %size1 = add i64 %11, 17
  %12 = trunc i64 %size1 to i32
  %13 = getelementptr inbounds i8, ptr %value, i64 %size1
  %14 = icmp ugt i32 %numEmptyCases, %num-extra-inhabitants
  br i1 %14, label %15, label %26

15:                                               ; preds = %entry
  %16 = icmp ugt i32 %12, 3
  %17 = add i32 %numEmptyCases, 255
  %18 = sub i32 %17, %num-extra-inhabitants
  %19 = lshr i32 %18, 8
  %20 = add nuw nsw i32 %19, 1
  %num-tags-phi = select i1 %16, i32 2, i32 %20
  %21 = icmp samesign ult i32 %num-tags-phi, 2
  %22 = icmp samesign ult i32 %num-tags-phi, 256
  %23 = icmp samesign ult i32 %num-tags-phi, 65536
  %24 = select i1 %23, i32 2, i32 4
  %25 = select i1 %22, i32 1, i32 %24
  %num-tag-bytes = select i1 %21, i32 0, i32 %25
  br label %26

26:                                               ; preds = %15, %entry
  %27 = phi i32 [ 0, %entry ], [ %num-tag-bytes, %15 ]
  %.not = icmp ugt i32 %whichCase, %num-extra-inhabitants
  br i1 %.not, label %59, label %28

28:                                               ; preds = %26
  switch i32 %27, label %32 [
    i32 0, label %33
    i32 1, label %29
    i32 2, label %30
    i32 4, label %31
  ]

29:                                               ; preds = %28
  store i8 0, ptr %13, align 1
  br label %33

30:                                               ; preds = %28
  store i16 0, ptr %13, align 1
  br label %33

31:                                               ; preds = %28
  store i32 0, ptr %13, align 1
  br label %33

32:                                               ; preds = %28
  unreachable

33:                                               ; preds = %28, %31, %30, %29
  %.not5 = icmp eq i32 %whichCase, 0
  br i1 %.not5, label %found_max_xi, label %34

34:                                               ; preds = %33
  %35 = ptrtoint ptr %value to i64
  %36 = add i64 %35, 5
  %37 = add i64 %36, %flags.alignmentMask
  %38 = and i64 %37, %5
  %39 = icmp ugt i32 %extraInhabitantCount, 253
  br i1 %39, label %40, label %43

40:                                               ; preds = %34
  %41 = inttoptr i64 %38 to ptr
  %42 = getelementptr inbounds nuw i8, ptr %Sink.valueWitnesses, i64 56
  %StoreEnumTagSinglePayload = load ptr, ptr %42, align 8, !invariant.load !17
  tail call void %StoreEnumTagSinglePayload(ptr noalias %41, i32 %whichCase, i32 %extraInhabitantCount, ptr nonnull %Sink) #16
  br label %found_max_xi

43:                                               ; preds = %34
  %44 = add i64 %9, %38
  %45 = and i64 %44, -4
  %46 = inttoptr i64 %45 to ptr
  %47 = icmp ult i32 %whichCase, 255
  br i1 %47, label %48, label %55

48:                                               ; preds = %43
  %.countersSaturated = getelementptr inbounds nuw i8, ptr %46, i64 16
  %49 = trunc nuw i32 %whichCase to i8
  %50 = add i8 %49, -1
  %51 = and i8 %50, 1
  %52 = and i8 %50, -2
  %53 = add nuw i8 %52, 2
  %54 = or disjoint i8 %53, %51
  store i8 %54, ptr %.countersSaturated, align 4
  br label %found_max_xi

55:                                               ; preds = %43
  %56 = add i32 %whichCase, -255
  %57 = zext i32 %56 to i64
  store i64 %57, ptr %46, align 4
  %58 = getelementptr inbounds nuw i8, ptr %46, i64 8
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(9) %58, i8 0, i64 9, i1 false)
  br label %found_max_xi

59:                                               ; preds = %26
  %60 = xor i32 %num-extra-inhabitants, -1
  %61 = add i32 %whichCase, %60
  %62 = icmp ugt i32 %12, 3
  %63 = lshr i32 %61, 8
  %64 = add nuw nsw i32 %63, 1
  %65 = select i1 %62, i32 1, i32 %64
  tail call void @llvm.memset.p0.i32(ptr noundef nonnull align 4 dereferenceable(1) %value, i8 0, i32 %12, i1 false)
  br i1 %62, label %68, label %66

66:                                               ; preds = %59
  %67 = trunc i32 %61 to i8
  store i8 %67, ptr %value, align 4
  br label %69

68:                                               ; preds = %59
  store i32 %61, ptr %value, align 4
  br label %69

69:                                               ; preds = %66, %68
  switch i32 %27, label %75 [
    i32 0, label %found_max_xi
    i32 1, label %70
    i32 2, label %72
    i32 4, label %74
  ]

70:                                               ; preds = %69
  %71 = trunc i32 %65 to i8
  store i8 %71, ptr %13, align 1
  br label %found_max_xi

72:                                               ; preds = %69
  %73 = trunc i32 %65 to i16
  store i16 %73, ptr %13, align 1
  br label %found_max_xi

74:                                               ; preds = %69
  store i32 %65, ptr %13, align 1
  br label %found_max_xi

75:                                               ; preds = %69
  unreachable

found_max_xi:                                     ; preds = %55, %70, %72, %74, %69, %48, %40, %33
  ret void
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i32(ptr writeonly captures(none), i8, i32, i1 immarg) #13

; Function Attrs: nounwind
declare ptr @swift_allocateGenericValueMetadata(ptr, ptr, ptr, i64) local_unnamed_addr #16

; Function Attrs: mustprogress nofree nounwind willreturn memory(read)
declare swiftcc %swift.metadata_response @swift_checkMetadataState(i64, ptr) local_unnamed_addr #17

; Function Attrs: nounwind
declare void @swift_initStructMetadata(ptr, i64, i64, ptr, ptr) local_unnamed_addr #16

; Function Attrs: mustprogress nounwind willreturn
define internal nonnull ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVwCP"(ptr noalias writeonly captures(none) initializes((0, 8)) %dest, ptr noalias readonly captures(none) %src, ptr readnone captures(none) %GiftUIFixedDiagnosticBuffer) #18 {
entry:
  %0 = load ptr, ptr %src, align 8
  store ptr %0, ptr %dest, align 8
  %1 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %2 = tail call ptr @swift_retain(ptr returned %0) #26
  ret ptr %1
}

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy392_4(ptr %0, ptr %1, ptr %2) #12 {
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 4 dereferenceable(392) %0, ptr noundef nonnull align 4 dereferenceable(392) %1, i64 392, i1 false)
  ret ptr %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %GiftUIFixedDiagnosticBuffer) #4 {
entry:
  %0 = icmp eq i32 %numEmptyCases, 0
  br i1 %0, label %17, label %1

1:                                                ; preds = %entry
  %2 = icmp ugt i32 %numEmptyCases, 252
  br i1 %2, label %3, label %11

3:                                                ; preds = %1
  %4 = getelementptr inbounds nuw i8, ptr %value, i64 392
  %5 = load i8, ptr %4, align 1
  %6 = icmp eq i8 %5, 0
  br i1 %6, label %11, label %7

7:                                                ; preds = %3
  %8 = load i3136, ptr %value, align 1
  %9 = trunc i3136 %8 to i32
  %10 = add i32 %9, 252
  br label %17

11:                                               ; preds = %3, %1
  %value.record0 = getelementptr inbounds nuw i8, ptr %value, i64 8
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
define internal void @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %GiftUIFixedDiagnosticBuffer) #6 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i64 392
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
  br i1 %6, label %15, label %7

7:                                                ; preds = %5
  %value.record0 = getelementptr inbounds nuw i8, ptr %value, i64 8
  %8 = trunc nuw i32 %whichCase to i8
  %9 = add nuw i8 %8, 3
  store i8 %9, ptr %value.record0, align 4
  br label %15

10:                                               ; preds = %entry
  %11 = add i32 %whichCase, -253
  %12 = zext i32 %11 to i64
  store i64 %12, ptr %value, align 4
  %13 = getelementptr inbounds nuw i8, ptr %value, i64 8
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(384) %13, i8 0, i64 384, i1 false)
  br i1 %1, label %14, label %15

14:                                               ; preds = %10
  store i8 1, ptr %0, align 4
  br label %15

15:                                               ; preds = %10, %14, %7, %5
  ret void
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMa"(i64 %0) #11 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferVMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMa"(i64 %0) #11 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr }>, ptr @"$s35GiftUIFailureDiagnosticsLayoutProbeAAOMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: mustprogress nofree noinline nounwind willreturn memory(read)
define linkonce_odr hidden swiftcc %swift.metadata_response @__swift_instantiateGenericMetadata(i64 %0, ptr %1, ptr %2, ptr %3, ptr %4) local_unnamed_addr #19 {
entry:
  %generic.arguments = alloca [3 x ptr], align 8
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %generic.arguments)
  store ptr %1, ptr %generic.arguments, align 8
  %5 = getelementptr inbounds nuw i8, ptr %generic.arguments, i64 8
  store ptr %2, ptr %5, align 8
  %6 = getelementptr inbounds nuw i8, ptr %generic.arguments, i64 16
  store ptr %3, ptr %6, align 8
  %7 = call swiftcc %swift.metadata_response @swift_getGenericMetadata(i64 %0, ptr nonnull %generic.arguments, ptr %4) #27
  ret %swift.metadata_response %7
}

; Function Attrs: nofree nounwind memory(read)
declare swiftcc %swift.metadata_response @swift_getGenericMetadata(i64, ptr, ptr) local_unnamed_addr #20

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.umax.i32(i32, i32) #21

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #3 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #4 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #5 = { mustprogress nofree noinline nosync nounwind willreturn memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #6 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #7 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #8 = { nounwind memory(argmem: readwrite, inaccessiblemem: write) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #9 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #10 = { cold noreturn nounwind memory(inaccessiblemem: write) }
attributes #11 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #12 = { nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #13 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #14 = { mustprogress nounwind willreturn }
attributes #15 = { nofree nounwind memory(read) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #16 = { nounwind }
attributes #17 = { mustprogress nofree nounwind willreturn memory(read) }
attributes #18 = { mustprogress nounwind willreturn "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #19 = { mustprogress nofree noinline nounwind willreturn memory(read) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #20 = { nofree nounwind memory(read) }
attributes #21 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #22 = { nounwind memory(none) }
attributes #23 = { nomerge }
attributes #24 = { noinline }
attributes #25 = { nounwind willreturn memory(read) }
attributes #26 = { nounwind willreturn }
attributes #27 = { nounwind memory(read) }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8, !9, !10, !11}
!swift.module.flags = !{!12}
!llvm.linker.options = !{!13, !14, !15, !16}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 1, !"Objective-C Version", i32 2}
!2 = !{i32 1, !"Objective-C Image Info Version", i32 0}
!3 = !{i32 1, !"Objective-C Image Info Section", !"__DATA,__objc_imageinfo,regular,no_dead_strip"}
!4 = !{i32 4, !"Objective-C Garbage Collection", i32 100927232}
!5 = !{i32 1, !"Objective-C Class Properties", i32 64}
!6 = !{i32 1, !"Objective-C Enforce ClassRO Pointer Signing", i8 0}
!7 = !{i32 1, !"wchar_size", i32 4}
!8 = !{i32 8, !"PIC Level", i32 2}
!9 = !{i32 7, !"uwtable", i32 1}
!10 = !{i32 7, !"frame-pointer", i32 1}
!11 = !{i32 1, !"Swift Version", i32 7}
!12 = !{!"standard-library", i1 false}
!13 = !{!"-lswift_Concurrency"}
!14 = !{!"-lswiftCore"}
!15 = !{!"-lswift_StringProcessing"}
!16 = !{!"-lobjc"}
!17 = !{}
!18 = !{i64 96}
!19 = !{!"branch_weights", !"expected", i32 1, i32 2000}
!20 = !{!21}
!21 = distinct !{!21, !22, !"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV12storedRecord33_481FAB364D938FDBB52660A85D053959LL2at0aB4Core0a12UIDiagnosticJ0VSgs5UInt8V_tF: argument 0"}
!22 = distinct !{!22, !"$s35GiftUIFailureDiagnosticsLayoutProbe0A23UIFixedDiagnosticBufferV12storedRecord33_481FAB364D938FDBB52660A85D053959LL2at0aB4Core0a12UIDiagnosticJ0VSgs5UInt8V_tF"}
