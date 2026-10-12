; ModuleID = '/Users/eugene/work/GiftUI/.build/contract-reports/spec-002/rfc-014/.tmp-macos-dynamic-81195/build/foundation-layout.ll'
source_filename = "/Users/eugene/work/GiftUI/.build/contract-reports/spec-002/rfc-014/.tmp-macos-dynamic-81195/build/foundation-layout.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%swift.protocol = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i32, i32, i32, i32, i32, i32 }
%swift.method_descriptor = type { i32, i32 }
%swift.protocol_requirement = type { i32, i32 }
%swift.type_descriptor = type opaque
%swift.vwtable = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i32, i32 }
%swift.enum_vwtable = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i32, i32, ptr, ptr, ptr }
%swift.type_metadata_record = type { i32 }
%swift.type = type { i64 }
%Ts6HasherV = type <{ %Ts6HasherV5_CoreV }>
%Ts6HasherV5_CoreV = type <{ %Ts6HasherV11_TailBufferV, %Ts6HasherV6_StateV }>
%Ts6HasherV11_TailBufferV = type <{ %Ts6UInt64V }>
%Ts6UInt64V = type <{ i64 }>
%Ts6HasherV6_StateV = type <{ %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V }>
%T27GiftUIFoundationLayoutProbe12PointerPhaseOSg = type <{ [1 x i8] }>
%Ts5UInt8V = type <{ i8 }>
%swift.metadata_response = type { ptr, i64 }

@"$sSQMp" = external global %swift.protocol, align 4
@"got.$sSQMp" = private unnamed_addr constant ptr @"$sSQMp"
@"$sSQ2eeoiySbx_xtFZTq" = external global %swift.method_descriptor, align 4
@"got.$sSQ2eeoiySbx_xtFZTq" = private unnamed_addr constant ptr @"$sSQ2eeoiySbx_xtFZTq"
@"$s27GiftUIFoundationLayoutProbe5PointVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 1, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAASQ2eeoiySbx_xtFZTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc", i32 0, i32 6) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe5PointVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 8
@"associated conformance 27GiftUIFoundationLayoutProbe5PointVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAASQWb" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe5PointVSHAASQ", i32 0, i32 2) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$sSHMp" = external global %swift.protocol, align 4
@"got.$sSHMp" = private unnamed_addr constant ptr @"$sSHMp"
@"$sSHSQTb" = external global %swift.protocol_requirement, align 4
@"got.$sSHSQTb" = private unnamed_addr constant ptr @"$sSHSQTb"
@"$sSH9hashValueSivgTq" = external global %swift.method_descriptor, align 4
@"got.$sSH9hashValueSivgTq" = private unnamed_addr constant ptr @"$sSH9hashValueSivgTq"
@"$sSH4hash4intoys6HasherVz_tFTq" = external global %swift.method_descriptor, align 4
@"got.$sSH4hash4intoys6HasherVz_tFTq" = private unnamed_addr constant ptr @"$sSH4hash4intoys6HasherVz_tFTq"
@"$sSH13_rawHashValue4seedS2i_tFTq" = external global %swift.method_descriptor, align 4
@"got.$sSH13_rawHashValue4seedS2i_tFTq" = private unnamed_addr constant ptr @"$sSH13_rawHashValue4seedS2i_tFTq"
@"$s27GiftUIFoundationLayoutProbe5PointVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 4, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHSQTb" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe5PointVSHAASQ", i64 1) to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 6) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 7) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH9hashValueSivgTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 8) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 9) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH4hash4intoys6HasherVz_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 10) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 11) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH13_rawHashValue4seedS2i_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 12) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 16) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 1, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAASQ2eeoiySbx_xtFZTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc", i32 0, i32 6) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4SizeVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 8
@"associated conformance 27GiftUIFoundationLayoutProbe4SizeVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASQWb" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe4SizeVSHAASQ", i32 0, i32 2) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 4, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHSQTb" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe4SizeVSHAASQ", i64 1) to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 6) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 7) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASH9hashValueSivgTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 8) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 9) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASH4hash4intoys6HasherVz_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 10) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 11) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASH13_rawHashValue4seedS2i_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 12) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 16) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4RectVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 1, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAASQ2eeoiySbx_xtFZTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc", i32 0, i32 6) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4RectVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 8
@"associated conformance 27GiftUIFoundationLayoutProbe4RectVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAASQWb" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe4RectVSHAASQ", i32 0, i32 2) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe4RectVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 4, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHSQTb" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe4RectVSHAASQ", i64 1) to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 6) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 7) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAASH9hashValueSivgTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 8) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 9) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAASH4hash4intoys6HasherVz_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 10) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 11) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAASH13_rawHashValue4seedS2i_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 12) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 16) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 1, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAASQ2eeoiySbx_xtFZTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc", i32 0, i32 6) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 8
@"associated conformance 27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASQWb" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASQ", i32 0, i32 2) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 4, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHSQTb" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASQ", i64 1) to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 6) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 7) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASH9hashValueSivgTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 8) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 9) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASH4hash4intoys6HasherVz_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 10) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 11) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASH13_rawHashValue4seedS2i_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 12) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 16) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 8
@"associated conformance 27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASQWb" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASQ", i32 0, i32 2) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 4, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHSQTb" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASQ", i64 1) to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 6) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 7) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASH9hashValueSivgTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 8) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 9) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASH4hash4intoys6HasherVz_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 10) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 11) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASH13_rawHashValue4seedS2i_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 12) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 16) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$ss5UInt8VMn" = external global %swift.type_descriptor, align 4
@"got.$ss5UInt8VMn" = private unnamed_addr constant ptr @"$ss5UInt8VMn"
@"symbolic _____ s5UInt8V" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$ss5UInt8VMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ s5UInt8V", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"symbolic _____ 27GiftUIFoundationLayoutProbe12PointerPhaseO" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12PointerPhaseO", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"symbolic $sSY" = linkonce_odr hidden constant <{ [4 x i8], i8 }> <{ [4 x i8] c"$sSY", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@0 = private constant [9 x i8] c"RawValue\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMA" = internal constant { i32, i32, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12PointerPhaseO" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMA" to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic $sSY" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMA", i32 0, i32 1) to i64)) to i32), i32 1, i32 8, i32 trunc (i64 sub (i64 ptrtoint (ptr @0 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMA", i32 0, i32 4) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s5UInt8V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMA", i32 0, i32 5) to i64)) to i32) }, section "__TEXT,__swift5_assocty, regular", no_sanitize_address, align 4
@"$sSYMp" = external global %swift.protocol, align 4
@"got.$sSYMp" = private unnamed_addr constant ptr @"$sSYMp"
@"$s8RawValueSYTl" = external global %swift.protocol_requirement, align 4
@"got.$s8RawValueSYTl" = private unnamed_addr constant ptr @"$s8RawValueSYTl"
@"$sSY8rawValuexSg03RawB0Qz_tcfCTq" = external global %swift.method_descriptor, align 4
@"got.$sSY8rawValuexSg03RawB0Qz_tcfCTq" = private unnamed_addr constant ptr @"$sSY8rawValuexSg03RawB0Qz_tcfCTq"
@"$sSY8rawValue03RawB0QzvgTq" = external global %swift.method_descriptor, align 4
@"got.$sSY8rawValue03RawB0QzvgTq" = private unnamed_addr constant ptr @"$sSY8rawValue03RawB0QzvgTq"
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSYMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 3, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$s8RawValueSYTl" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr getelementptr inbounds (i8, ptr @"symbolic _____ s5UInt8V", i64 1) to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 6) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSY8rawValuexSg03RawB0Qz_tcfCTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 7) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAASY8rawValuexSg03RawH0Qz_tcfCTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 8) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSY8rawValue03RawB0QzvgTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 9) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAASY8rawValue03RawH0QzvgTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 10) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 14) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 1, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAASQ2eeoiySbx_xtFZTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc", i32 0, i32 6) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 1, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAASQ2eeoiySbx_xtFZTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc", i32 0, i32 6) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 8
@"associated conformance 27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASQWb" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASQ", i32 0, i32 2) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 4, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHSQTb" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASQ", i64 1) to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 6) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 7) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASH9hashValueSivgTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 8) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 9) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASH4hash4intoys6HasherVz_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 10) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 11) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASH13_rawHashValue4seedS2i_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 12) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 16) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 1, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAASQ2eeoiySbx_xtFZTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc", i32 0, i32 6) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 8
@"associated conformance 27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASQWb" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASQ", i32 0, i32 2) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 4, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHSQTb" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASQ", i64 1) to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 6) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 7) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH9hashValueSivgTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 8) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 9) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH4hash4intoys6HasherVz_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 10) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 11) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH13_rawHashValue4seedS2i_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 12) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 16) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 1, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAASQ2eeoiySbx_xtFZTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc", i32 0, i32 6) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 8
@"associated conformance 27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASQWb" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASQ", i32 0, i32 2) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 4, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHSQTb" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASQ", i64 1) to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 6) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 7) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH9hashValueSivgTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 8) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 9) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH4hash4intoys6HasherVz_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 10) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 11) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH13_rawHashValue4seedS2i_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 12) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 16) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 1, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAASQ2eeoiySbx_xtFZTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc", i32 0, i32 6) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 8
@"associated conformance 27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASQWb" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASQ", i32 0, i32 2) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 4, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSHSQTb" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASQ", i64 1) to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 6) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 7) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASH9hashValueSivgTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 8) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 9) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASH4hash4intoys6HasherVz_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 10) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 11) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASH13_rawHashValue4seedS2i_tFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 12) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 16) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQMp" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 1, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAASQ2eeoiySbx_xtFZTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc", i32 0, i32 6) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV" = unnamed_addr constant { i32 } zeroinitializer, align 4
@"$s27GiftUIFoundationLayoutProbe5PointVWV" = internal constant %swift.vwtable { ptr @__swift_memcpy8_4, ptr @__swift_noop_void_return, ptr @__swift_memcpy8_4, ptr @__swift_memcpy8_4, ptr @__swift_memcpy8_4, ptr @__swift_memcpy8_4, ptr @"$s27GiftUIFoundationLayoutProbe5PointVwet", ptr @"$s27GiftUIFoundationLayoutProbe5PointVwst", i64 8, i64 8, i32 3, i32 0 }, align 8
@.str.27.GiftUIFoundationLayoutProbe = private constant [28 x i8] c"GiftUIFoundationLayoutProbe\00"
@"$s27GiftUIFoundationLayoutProbeMXM" = linkonce_odr hidden constant <{ i32, i32, i32 }> <{ i32 0, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.27.GiftUIFoundationLayoutProbe to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbeMXM", i32 0, i32 2) to i64)) to i32) }>, section "__TEXT,__constg_swiftt", align 4
@.str.5.Point = private constant [6 x i8] c"Point\00"
@"$s27GiftUIFoundationLayoutProbe5PointVMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.5.Point to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn", i32 0, i32 4) to i64)) to i32), i32 2, i32 2 }>, section "__TEXT,__constg_swiftt", align 4
@"$s27GiftUIFoundationLayoutProbe5PointVMf" = internal constant <{ ptr, ptr, i64, ptr, i32, i32 }> <{ ptr null, ptr @"$s27GiftUIFoundationLayoutProbe5PointVWV", i64 512, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn", i32 0, i32 4 }>, align 8
@"symbolic _____ 27GiftUIFoundationLayoutProbe5PointV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe5PointV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$ss5Int32VMn" = external global %swift.type_descriptor, align 4
@"got.$ss5Int32VMn" = private unnamed_addr constant ptr @"$ss5Int32VMn"
@"symbolic _____ s5Int32V" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$ss5Int32VMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ s5Int32V", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@1 = private constant [2 x i8] c"x\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@2 = private constant [2 x i8] c"y\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@"$s27GiftUIFoundationLayoutProbe5PointVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe5PointV" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVMF" to i64)) to i32), i32 0, i16 0, i16 12, i32 2, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s5Int32V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMF", i32 0, i32 6) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @1 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMF", i32 0, i32 7) to i64)) to i32), i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s5Int32V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMF", i32 0, i32 9) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @2 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMF", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4SizeVWV" = internal constant %swift.vwtable { ptr @__swift_memcpy8_4, ptr @__swift_noop_void_return, ptr @__swift_memcpy8_4, ptr @__swift_memcpy8_4, ptr @__swift_memcpy8_4, ptr @__swift_memcpy8_4, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVwet", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVwst", i64 8, i64 8, i32 3, i32 0 }, align 8
@.str.4.Size = private constant [5 x i8] c"Size\00"
@"$s27GiftUIFoundationLayoutProbe4SizeVMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.4.Size to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn", i32 0, i32 4) to i64)) to i32), i32 2, i32 2 }>, section "__TEXT,__constg_swiftt", align 4
@"$s27GiftUIFoundationLayoutProbe4SizeVMf" = internal constant <{ ptr, ptr, i64, ptr, i32, i32 }> <{ ptr null, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVWV", i64 512, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn", i32 0, i32 4 }>, align 8
@"symbolic _____ 27GiftUIFoundationLayoutProbe4SizeV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe4SizeV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@3 = private constant [6 x i8] c"width\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@4 = private constant [7 x i8] c"height\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@"$s27GiftUIFoundationLayoutProbe4SizeVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe4SizeV" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMF" to i64)) to i32), i32 0, i16 0, i16 12, i32 2, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s5Int32V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMF", i32 0, i32 6) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @3 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMF", i32 0, i32 7) to i64)) to i32), i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s5Int32V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMF", i32 0, i32 9) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @4 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMF", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4RectVWV" = internal constant %swift.vwtable { ptr @__swift_memcpy16_4, ptr @__swift_noop_void_return, ptr @__swift_memcpy16_4, ptr @__swift_memcpy16_4, ptr @__swift_memcpy16_4, ptr @__swift_memcpy16_4, ptr @"$s27GiftUIFoundationLayoutProbe4RectVwet", ptr @"$s27GiftUIFoundationLayoutProbe4RectVwst", i64 16, i64 16, i32 3, i32 0 }, align 8
@.str.4.Rect = private constant [5 x i8] c"Rect\00"
@"$s27GiftUIFoundationLayoutProbe4RectVMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.4.Rect to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn", i32 0, i32 4) to i64)) to i32), i32 2, i32 2 }>, section "__TEXT,__constg_swiftt", align 4
@"$s27GiftUIFoundationLayoutProbe4RectVMf" = internal constant <{ ptr, ptr, i64, ptr, i32, i32 }> <{ ptr null, ptr @"$s27GiftUIFoundationLayoutProbe4RectVWV", i64 512, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn", i32 0, i32 8 }>, align 8
@"symbolic _____ 27GiftUIFoundationLayoutProbe4RectV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe4RectV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@5 = private constant [7 x i8] c"origin\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@6 = private constant [5 x i8] c"size\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@"$s27GiftUIFoundationLayoutProbe4RectVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe4RectV" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVMF" to i64)) to i32), i32 0, i16 0, i16 12, i32 2, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe5PointV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMF", i32 0, i32 6) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @5 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMF", i32 0, i32 7) to i64)) to i32), i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe4SizeV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMF", i32 0, i32 9) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @6 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMF", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVWV" = internal constant %swift.vwtable { ptr @__swift_memcpy13_4, ptr @__swift_noop_void_return, ptr @__swift_memcpy13_4, ptr @__swift_memcpy13_4, ptr @__swift_memcpy13_4, ptr @__swift_memcpy13_4, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVwet", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVwst", i64 13, i64 16, i32 3, i32 0 }, align 8
@.str.12.ProposedSize = private constant [13 x i8] c"ProposedSize\00"
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.12.ProposedSize to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn", i32 0, i32 4) to i64)) to i32), i32 2, i32 2 }>, section "__TEXT,__constg_swiftt", align 4
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMf" = internal constant <{ ptr, ptr, i64, ptr, i32, i32 }> <{ ptr null, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVWV", i64 512, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn", i32 0, i32 8 }>, align 8
@"symbolic _____ 27GiftUIFoundationLayoutProbe12ProposedSizeV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12ProposedSizeV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"symbolic _____Sg s5Int32V" = linkonce_odr hidden constant <{ i8, i32, [2 x i8], i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$ss5Int32VMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, [2 x i8], i8 }>, ptr @"symbolic _____Sg s5Int32V", i32 0, i32 1) to i64)) to i32), [2 x i8] c"Sg", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12ProposedSizeV" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF" to i64)) to i32), i32 0, i16 0, i16 12, i32 2, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____Sg s5Int32V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF", i32 0, i32 6) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @3 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF", i32 0, i32 7) to i64)) to i32), i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____Sg s5Int32V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF", i32 0, i32 9) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @4 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF", i32 0, i32 10) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$sytWV" = external global ptr, align 8
@.str.18.GeometryArithmetic = private constant [19 x i8] c"GeometryArithmetic\00"
@"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 82, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.18.GeometryArithmetic to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn", i32 0, i32 4) to i64)) to i32), i32 0, i32 0 }>, section "__TEXT,__constg_swiftt", align 4
@"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMf" = internal constant <{ ptr, ptr, i64, ptr }> <{ ptr null, ptr @"$sytWV", i64 513, ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn" }>, align 8
@"symbolic _____ 27GiftUIFoundationLayoutProbe18GeometryArithmeticO" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe18GeometryArithmeticO", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMF" = internal constant { i32, i32, i16, i16, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe18GeometryArithmeticO" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMF" to i64)) to i32), i32 0, i16 2, i16 12, i32 0 }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOWV" = internal constant %swift.enum_vwtable { ptr @__swift_memcpy1_1, ptr @__swift_noop_void_return, ptr @__swift_memcpy1_1, ptr @__swift_memcpy1_1, ptr @__swift_memcpy1_1, ptr @__swift_memcpy1_1, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwet", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwst", i64 1, i64 1, i32 2097152, i32 253, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwug", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwup", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwui" }, align 8
@.str.12.PointerPhase = private constant [13 x i8] c"PointerPhase\00"
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 82, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.12.PointerPhase to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn", i32 0, i32 4) to i64)) to i32), i32 0, i32 3 }>, section "__TEXT,__constg_swiftt", align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMf" = internal constant <{ ptr, ptr, i64, ptr }> <{ ptr null, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOWV", i64 513, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn" }>, align 8
@7 = private constant [5 x i8] c"down\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@8 = private constant [5 x i8] c"move\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@9 = private constant [3 x i8] c"up\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12PointerPhaseO" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMF" to i64)) to i32), i32 0, i16 2, i16 12, i32 3, i32 0, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @7 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMF", i32 0, i32 7) to i64)) to i32), i32 0, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @8 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMF", i32 0, i32 10) to i64)) to i32), i32 0, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @9 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMF", i32 0, i32 13) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$sBi16_WV" = external global ptr, align 8
@.str.13.InputSourceID = private constant [14 x i8] c"InputSourceID\00"
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.13.InputSourceID to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn", i32 0, i32 4) to i64)) to i32), i32 1, i32 2 }>, section "__TEXT,__constg_swiftt", align 4
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMf" = internal constant <{ ptr, ptr, i64, ptr, i32, [4 x i8] }> <{ ptr null, ptr @"$sBi16_WV", i64 512, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn", i32 0, [4 x i8] zeroinitializer }>, align 8
@"symbolic _____ 27GiftUIFoundationLayoutProbe13InputSourceIDV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe13InputSourceIDV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$ss6UInt16VMn" = external global %swift.type_descriptor, align 4
@"got.$ss6UInt16VMn" = private unnamed_addr constant ptr @"$ss6UInt16VMn"
@"symbolic _____ s6UInt16V" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$ss6UInt16VMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ s6UInt16V", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@10 = private constant [9 x i8] c"rawValue\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe13InputSourceIDV" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMF" to i64)) to i32), i32 0, i16 0, i16 12, i32 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s6UInt16V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMF", i32 0, i32 6) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @10 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMF", i32 0, i32 7) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$sBi32_WV" = external global ptr, align 8
@.str.17.PointerSequenceID = private constant [18 x i8] c"PointerSequenceID\00"
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.17.PointerSequenceID to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn", i32 0, i32 4) to i64)) to i32), i32 1, i32 2 }>, section "__TEXT,__constg_swiftt", align 4
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMf" = internal constant <{ ptr, ptr, i64, ptr, i32, [4 x i8] }> <{ ptr null, ptr @"$sBi32_WV", i64 512, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn", i32 0, [4 x i8] zeroinitializer }>, align 8
@"symbolic _____ 27GiftUIFoundationLayoutProbe17PointerSequenceIDV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe17PointerSequenceIDV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$ss6UInt32VMn" = external global %swift.type_descriptor, align 4
@"got.$ss6UInt32VMn" = private unnamed_addr constant ptr @"$ss6UInt32VMn"
@"symbolic _____ s6UInt32V" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$ss6UInt32VMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ s6UInt32V", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe17PointerSequenceIDV" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMF" to i64)) to i32), i32 0, i16 0, i16 12, i32 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMF", i32 0, i32 6) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @10 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMF", i32 0, i32 7) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@.str.12.InputOrdinal = private constant [13 x i8] c"InputOrdinal\00"
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.12.InputOrdinal to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn", i32 0, i32 4) to i64)) to i32), i32 1, i32 2 }>, section "__TEXT,__constg_swiftt", align 4
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMf" = internal constant <{ ptr, ptr, i64, ptr, i32, [4 x i8] }> <{ ptr null, ptr @"$sBi32_WV", i64 512, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn", i32 0, [4 x i8] zeroinitializer }>, align 8
@"symbolic _____ 27GiftUIFoundationLayoutProbe12InputOrdinalV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12InputOrdinalV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12InputOrdinalV" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMF" to i64)) to i32), i32 0, i16 0, i16 12, i32 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMF", i32 0, i32 6) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @10 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMF", i32 0, i32 7) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@.str.20.PresentationRevision = private constant [21 x i8] c"PresentationRevision\00"
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.20.PresentationRevision to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn", i32 0, i32 4) to i64)) to i32), i32 1, i32 2 }>, section "__TEXT,__constg_swiftt", align 4
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMf" = internal constant <{ ptr, ptr, i64, ptr, i32, [4 x i8] }> <{ ptr null, ptr @"$sBi32_WV", i64 512, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn", i32 0, [4 x i8] zeroinitializer }>, align 8
@"symbolic _____ 27GiftUIFoundationLayoutProbe20PresentationRevisionV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe20PresentationRevisionV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe20PresentationRevisionV" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMF" to i64)) to i32), i32 0, i16 0, i16 12, i32 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMF", i32 0, i32 6) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @10 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMF", i32 0, i32 7) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVWV" = internal constant %swift.vwtable { ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVwCP", ptr @__swift_noop_void_return, ptr @__swift_memcpy28_4, ptr @__swift_memcpy28_4, ptr @__swift_memcpy28_4, ptr @__swift_memcpy28_4, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVwet", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVwst", i64 28, i64 28, i32 131075, i32 253 }, align 8
@.str.22.NormalizedPointerEvent = private constant [23 x i8] c"NormalizedPointerEvent\00"
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.22.NormalizedPointerEvent to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn", i32 0, i32 4) to i64)) to i32), i32 6, i32 2 }>, section "__TEXT,__constg_swiftt", align 4
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMf" = internal constant <{ ptr, ptr, i64, ptr, i32, i32, i32, i32, i32, i32 }> <{ ptr null, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVWV", i64 512, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn", i32 0, i32 4, i32 12, i32 16, i32 20, i32 24 }>, align 8
@"symbolic _____ 27GiftUIFoundationLayoutProbe22NormalizedPointerEventV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe22NormalizedPointerEventV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@11 = private constant [6 x i8] c"phase\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@12 = private constant [9 x i8] c"position\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@13 = private constant [7 x i8] c"source\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@14 = private constant [9 x i8] c"sequence\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@15 = private constant [8 x i8] c"ordinal\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@16 = private constant [21 x i8] c"presentationRevision\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe22NormalizedPointerEventV" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF" to i64)) to i32), i32 0, i16 0, i16 12, i32 6, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12PointerPhaseO" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 6) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @11 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 7) to i64)) to i32), i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe5PointV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 9) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @12 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 10) to i64)) to i32), i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe13InputSourceIDV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 12) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @13 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 13) to i64)) to i32), i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe17PointerSequenceIDV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 15) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @14 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 16) to i64)) to i32), i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12InputOrdinalV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 18) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @15 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 19) to i64)) to i32), i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe20PresentationRevisionV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 21) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @16 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 22) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbeAAOMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 82, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbeAAOMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.27.GiftUIFoundationLayoutProbe to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbeAAOMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeAAOMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbeAAOMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeAAOMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbeAAOMn", i32 0, i32 4) to i64)) to i32), i32 0, i32 0 }>, section "__TEXT,__constg_swiftt", align 4
@"$s27GiftUIFoundationLayoutProbeAAOMf" = internal constant <{ ptr, ptr, i64, ptr }> <{ ptr null, ptr @"$sytWV", i64 513, ptr @"$s27GiftUIFoundationLayoutProbeAAOMn" }>, align 8
@"symbolic _____ 27GiftUIFoundationLayoutProbeAAO" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeAAOMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbeAAO", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbeAAOMF" = internal constant { i32, i32, i16, i16, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbeAAO" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeAAOMF" to i64)) to i32), i32 0, i16 2, i16 12, i32 0 }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe5PointVSQAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe5PointVSHAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4SizeVSQAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4SizeVSHAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4RectVSQAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4RectVSHAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe5PointVHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4SizeVHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4RectVHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbeAAOHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeAAOMn" to i64), i64 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeAAOHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@llvm.used = appending global [198 x ptr] [ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV8rawValueACs6UInt32V_tcfC", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV8rawValues6UInt32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVHn", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMF", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMa", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVN", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseO8rawValueACSgs5UInt8V_tcfC", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseO8rawValues5UInt8Vvg", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOHn", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMF", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMa", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseON", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAHc", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMA", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV5width6heightACSgs5Int32VSg_AItcfC", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV5widths5Int32VSgvg", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV6heights5Int32VSgvg", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVHn", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMa", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVN", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV8rawValueACs6UInt16V_tcfC", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV8rawValues6UInt16Vvg", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVHn", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMF", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMa", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVN", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV8rawValueACs6UInt32V_tcfC", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV8rawValues6UInt32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVHn", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMF", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMa", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVN", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticO3addys5Int32VSgAF_AFtFZ", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticO8multiplyys5Int32VSgAF_AFtFZ", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticO8subtractys5Int32VSgAF_AFtFZ", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOHn", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMF", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMa", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticON", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV8rawValueACs6UInt32V_tcfC", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV8rawValues6UInt32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVHn", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMF", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMa", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVN", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV20presentationRevisionAA012PresentationI0Vvg", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV5phase8position6source8sequence7ordinal20presentationRevisionAcA0F5PhaseO_AA5PointVAA13InputSourceIDVAA0f8SequenceS0VAA0Q7OrdinalVAA012PresentationN0VtcfC", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV5phaseAA0F5PhaseOvg", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV6sourceAA13InputSourceIDVvg", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV7ordinalAA12InputOrdinalVvg", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV8positionAA5PointVvg", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV8sequenceAA0F10SequenceIDVvg", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVHn", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMa", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVN", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe4RectV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe4RectV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe4RectV4maxXs5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe4RectV4maxYs5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe4RectV4minXs5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe4RectV4minYs5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe4RectV4sizeAA4SizeVvg", ptr @"$s27GiftUIFoundationLayoutProbe4RectV6origin4sizeACSgAA5PointV_AA4SizeVtcfC", ptr @"$s27GiftUIFoundationLayoutProbe4RectV6originAA5PointVvg", ptr @"$s27GiftUIFoundationLayoutProbe4RectV8containsySbAA5PointVF", ptr @"$s27GiftUIFoundationLayoutProbe4RectV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe4RectVHn", ptr @"$s27GiftUIFoundationLayoutProbe4RectVMF", ptr @"$s27GiftUIFoundationLayoutProbe4RectVMa", ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn", ptr @"$s27GiftUIFoundationLayoutProbe4RectVN", ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe4SizeV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe4SizeV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe4SizeV5width6heightACSgs5Int32V_AHtcfC", ptr @"$s27GiftUIFoundationLayoutProbe4SizeV5widths5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe4SizeV6heights5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe4SizeV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVHn", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMF", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMa", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVN", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe5PointV1x1yACs5Int32V_AGtcfC", ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV", ptr @"$s27GiftUIFoundationLayoutProbe5PointV1ys5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe5PointV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe5PointV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe5PointV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe5PointVHn", ptr @"$s27GiftUIFoundationLayoutProbe5PointVMF", ptr @"$s27GiftUIFoundationLayoutProbe5PointVMa", ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn", ptr @"$s27GiftUIFoundationLayoutProbe5PointVN", ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbeAAO10rectStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO10sizeStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO11pointStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO13rectAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO13sizeAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO14pointAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO14proposedStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO16inputOrdinalSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO16pointerPhaseSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO16proposedByteSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO17inputSourceIDSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO17proposedAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO18geometryScalarSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO18inputOrdinalStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO18pointerPhaseStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO19inputSourceIDStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO20geometryScalarStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO21inputOrdinalAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO21pointerPhaseAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO21pointerSequenceIDSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO22inputSourceIDAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO23geometryScalarAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO23pointerSequenceIDStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO24presentationRevisionSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO26normalizedPointerEventSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO26pointerSequenceIDAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO26presentationRevisionStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO28normalizedPointerEventStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO29presentationRevisionAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO31normalizedPointerEventAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO8rectSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO8sizeSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO9pointSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAOHn", ptr @"$s27GiftUIFoundationLayoutProbeAAOMF", ptr @"$s27GiftUIFoundationLayoutProbeAAOMa", ptr @"$s27GiftUIFoundationLayoutProbeAAOMn", ptr @"$s27GiftUIFoundationLayoutProbeAAON", ptr @__swift_reflection_version], section "llvm.metadata"

@"$s27GiftUIFoundationLayoutProbe5PointV1ys5Int32VvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe5PointV9hashValueSivpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4SizeV5widths5Int32VvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4SizeV6heights5Int32VvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4SizeV9hashValueSivpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4RectV6originAA5PointVvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4RectV4sizeAA4SizeVvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4RectV4minXs5Int32VvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4RectV4minYs5Int32VvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4RectV4maxXs5Int32VvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4RectV4maxYs5Int32VvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4RectV9hashValueSivpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeV5widths5Int32VSgvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeV6heights5Int32VSgvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeV9hashValueSivpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseO8rawValues5UInt8VvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDV8rawValues6UInt16VvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDV9hashValueSivpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV8rawValues6UInt32VvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV9hashValueSivpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalV8rawValues6UInt32VvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalV9hashValueSivpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV8rawValues6UInt32VvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV9hashValueSivpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV5phaseAA0F5PhaseOvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV8positionAA5PointVvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV6sourceAA13InputSourceIDVvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV8sequenceAA0F10SequenceIDVvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV7ordinalAA12InputOrdinalVvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV20presentationRevisionAA012PresentationI0VvpMV" = alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe5PointVN" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe4SizeVN" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe4RectVN" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVN" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticON" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr }>, ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseON" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr }>, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVN" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, [4 x i8] }>, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVN" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, [4 x i8] }>, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVN" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, [4 x i8] }>, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVN" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, [4 x i8] }>, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVN" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbeAAON" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr }>, ptr @"$s27GiftUIFoundationLayoutProbeAAOMf", i32 0, i32 2)

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #0

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #0

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i64 @"$s27GiftUIFoundationLayoutProbe5PointV1x1yACs5Int32V_AGtcfC"(i32 %0, i32 %1) #1 {
entry:
  %temp-coercion.coerced.sroa.4.0.insert.ext = zext i32 %1 to i64
  %temp-coercion.coerced.sroa.4.0.insert.shift = shl nuw i64 %temp-coercion.coerced.sroa.4.0.insert.ext, 32
  %temp-coercion.coerced.sroa.0.0.insert.ext = zext i32 %0 to i64
  %temp-coercion.coerced.sroa.0.0.insert.insert = or disjoint i64 %temp-coercion.coerced.sroa.4.0.insert.shift, %temp-coercion.coerced.sroa.0.0.insert.ext
  ret i64 %temp-coercion.coerced.sroa.0.0.insert.insert
}

declare swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32, ptr swiftself captures(none) dereferenceable(72)) local_unnamed_addr #2

declare swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias sret(%Ts6HasherV) captures(none), i64) local_unnamed_addr #2

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #3

declare swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr swiftself captures(none) dereferenceable(72)) local_unnamed_addr #2

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4SizeV5widths5Int32Vvg"(i64 %0) #1 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %0 to i32
  ret i32 %temp-coercion.coerced.sroa.0.0.extract.trunc
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4SizeV6heights5Int32Vvg"(i64 %0) #1 {
entry:
  %temp-coercion.coerced.sroa.3.0.extract.shift = lshr i64 %0, 32
  %temp-coercion.coerced.sroa.3.0.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.3.0.extract.shift to i32
  ret i32 %temp-coercion.coerced.sroa.3.0.extract.trunc
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i8 } @"$s27GiftUIFoundationLayoutProbe4SizeV5width6heightACSgs5Int32V_AHtcfC"(i32 %0, i32 %1) #1 {
entry:
  %2 = icmp slt i32 %0, 0
  %3 = icmp slt i32 %1, 0
  %or.cond.not = select i1 %2, i1 true, i1 %3
  %4 = zext i32 %0 to i64
  %5 = zext i32 %1 to i64
  %6 = shl nuw i64 %5, 32
  %7 = or disjoint i64 %6, %4
  %8 = select i1 %or.cond.not, i64 0, i64 %7
  %9 = zext i1 %or.cond.not to i8
  %10 = insertvalue { i64, i8 } undef, i64 %8, 0
  %11 = insertvalue { i64, i8 } %10, i8 %9, 1
  ret { i64, i8 } %11
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i1 @"$s27GiftUIFoundationLayoutProbe4SizeV23__derived_struct_equalsySbAC_ACtFZ"(i64 %0, i64 %1) #1 {
entry:
  %2 = icmp eq i64 %0, %1
  ret i1 %2
}

define swiftcc void @"$s27GiftUIFoundationLayoutProbe4SizeV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i64 %1) #2 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %1 to i32
  %temp-coercion.coerced.sroa.4.0.extract.shift = lshr i64 %1, 32
  %temp-coercion.coerced.sroa.4.0.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.4.0.extract.shift to i32
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.0.0.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.4.0.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  ret void
}

define swiftcc i64 @"$s27GiftUIFoundationLayoutProbe4SizeV9hashValueSivg"(i64 %0) #2 {
  %2 = tail call swiftcc i64 @"$s27GiftUIFoundationLayoutProbe5PointV9hashValueSivgTm"(i64 %0) #2
  ret i64 %2
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe5PointV9hashValueSivgTm"(i64 %0) #2 {
entry:
  %1 = alloca %Ts6HasherV, align 8
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %0 to i32
  %temp-coercion.coerced.sroa.4.0.extract.shift = lshr i64 %0, 32
  %temp-coercion.coerced.sroa.4.0.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.4.0.extract.shift to i32
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %1)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %1, i64 0)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.0.0.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.4.0.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  %2 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %1)
  ret i64 %2
}

define private swiftcc i1 @17(ptr noalias captures(none) dereferenceable(8) %0, ptr noalias captures(none) dereferenceable(8) %1, ptr swiftself %2, ptr %Self, ptr %SelfWitnessTable) #2 {
entry:
  %3 = load i32, ptr %0, align 4
  %4 = load i32, ptr %1, align 4
  %5 = icmp eq i32 %3, %4
  br i1 %5, label %6, label %10

6:                                                ; preds = %entry
  %.height2 = getelementptr inbounds nuw i8, ptr %1, i64 4
  %7 = load i32, ptr %.height2, align 4
  %.height = getelementptr inbounds nuw i8, ptr %0, i64 4
  %8 = load i32, ptr %.height, align 4
  %9 = icmp eq i32 %8, %7
  br label %10

10:                                               ; preds = %entry, %6
  %11 = phi i1 [ %9, %6 ], [ false, %entry ]
  ret i1 %11
}

define private swiftcc i64 @18(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %Self, ptr %SelfWitnessTable) #2 {
  %2 = tail call swiftcc i64 @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH9hashValueSivgTWTm"(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %Self, ptr %SelfWitnessTable) #2
  ret i64 %2
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH9hashValueSivgTWTm"(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %1, ptr %2) #2 {
entry:
  %3 = alloca %Ts6HasherV, align 8
  %4 = load i32, ptr %0, align 4
  %.y = getelementptr inbounds nuw i8, ptr %0, i64 4
  %5 = load i32, ptr %.y, align 4
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %3)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %3, i64 0) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %4, ptr nonnull swiftself captures(none) dereferenceable(72) %3) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %5, ptr nonnull swiftself captures(none) dereferenceable(72) %3) #17
  %6 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %3) #17
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %3)
  ret i64 %6
}

define private swiftcc void @19(ptr captures(none) dereferenceable(72) %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %Self, ptr %SelfWitnessTable) #2 {
entry:
  %2 = load i32, ptr %1, align 4
  %.height = getelementptr inbounds nuw i8, ptr %1, i64 4
  %3 = load i32, ptr %.height, align 4
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  ret void
}

define private swiftcc i64 @20(i64 %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %Self, ptr %SelfWitnessTable) #2 {
  %3 = tail call swiftcc i64 @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH13_rawHashValue4seedS2i_tFTWTm"(i64 %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %Self, ptr %SelfWitnessTable) #2
  ret i64 %3
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH13_rawHashValue4seedS2i_tFTWTm"(i64 %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #2 {
entry:
  %4 = alloca %Ts6HasherV, align 8
  %5 = load i32, ptr %1, align 4
  %.y = getelementptr inbounds nuw i8, ptr %1, i64 4
  %6 = load i32, ptr %.y, align 4
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %4)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %4, i64 %0) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %5, ptr nonnull swiftself captures(none) dereferenceable(72) %4) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %6, ptr nonnull swiftself captures(none) dereferenceable(72) %4) #17
  %7 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %4) #17
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %4)
  ret i64 %7
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i64 @"$s27GiftUIFoundationLayoutProbe4RectV6originAA5PointVvg"(i64 returned %0, i64 %1) #1 {
entry:
  ret i64 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i64 @"$s27GiftUIFoundationLayoutProbe4RectV4sizeAA4SizeVvg"(i64 %0, i64 returned %1) #1 {
entry:
  ret i64 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i8 } @"$s27GiftUIFoundationLayoutProbe4RectV6origin4sizeACSgAA5PointV_AA4SizeVtcfC"(i64 %0, i64 %1) #1 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %0 to i32
  %temp-coercion.coerced1.sroa.0.0.extract.trunc = trunc i64 %1 to i32
  %2 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %temp-coercion.coerced.sroa.0.0.extract.trunc, i32 %temp-coercion.coerced1.sroa.0.0.extract.trunc)
  %3 = extractvalue { i32, i1 } %2, 1
  br i1 %3, label %8, label %4

4:                                                ; preds = %entry
  %temp-coercion.coerced1.sroa.4.0.extract.shift = lshr i64 %1, 32
  %temp-coercion.coerced1.sroa.4.0.extract.trunc = trunc nuw i64 %temp-coercion.coerced1.sroa.4.0.extract.shift to i32
  %temp-coercion.coerced.sroa.4.0.extract.shift = lshr i64 %0, 32
  %temp-coercion.coerced.sroa.4.0.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.4.0.extract.shift to i32
  %5 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %temp-coercion.coerced.sroa.4.0.extract.trunc, i32 %temp-coercion.coerced1.sroa.4.0.extract.trunc)
  %6 = extractvalue { i32, i1 } %5, 1
  br i1 %6, label %8, label %7

7:                                                ; preds = %4
  br label %8

8:                                                ; preds = %entry, %4, %7
  %9 = phi i64 [ %0, %7 ], [ 0, %4 ], [ 0, %entry ]
  %10 = phi i64 [ %1, %7 ], [ 0, %4 ], [ 0, %entry ]
  %11 = phi i8 [ 0, %7 ], [ 1, %4 ], [ 1, %entry ]
  %12 = insertvalue { i64, i64, i8 } undef, i64 %9, 0
  %13 = insertvalue { i64, i64, i8 } %12, i64 %10, 1
  %14 = insertvalue { i64, i64, i8 } %13, i8 %11, 2
  ret { i64, i64, i8 } %14
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32) #4

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc range(i64 0, 4294967297) i64 @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticO3addys5Int32VSgAF_AFtFZ"(i32 %0, i32 %1) #1 {
entry:
  %2 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %0, i32 %1)
  %3 = extractvalue { i32, i1 } %2, 0
  %4 = extractvalue { i32, i1 } %2, 1
  %5 = zext i32 %3 to i64
  %temp-coercion.coerced.sroa.0.0.insert.insert = select i1 %4, i64 4294967296, i64 %5
  ret i64 %temp-coercion.coerced.sroa.0.0.insert.insert
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4RectV4minXs5Int32Vvg"(i64 %0, i64 %1) #1 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %0 to i32
  ret i32 %temp-coercion.coerced.sroa.0.0.extract.trunc
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4RectV4minYs5Int32Vvg"(i64 %0, i64 %1) #1 {
entry:
  %temp-coercion.coerced.sroa.0.4.extract.shift = lshr i64 %0, 32
  %temp-coercion.coerced.sroa.0.4.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.0.4.extract.shift to i32
  ret i32 %temp-coercion.coerced.sroa.0.4.extract.trunc
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4RectV4maxXs5Int32Vvg"(i64 %0, i64 %1) #1 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %0 to i32
  %temp-coercion.coerced.sroa.4.8.extract.trunc = trunc i64 %1 to i32
  %2 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %temp-coercion.coerced.sroa.0.0.extract.trunc, i32 %temp-coercion.coerced.sroa.4.8.extract.trunc)
  %3 = extractvalue { i32, i1 } %2, 0
  %4 = extractvalue { i32, i1 } %2, 1
  %. = select i1 %4, i32 %temp-coercion.coerced.sroa.0.0.extract.trunc, i32 %3
  ret i32 %.
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4RectV4maxYs5Int32Vvg"(i64 %0, i64 %1) #1 {
entry:
  %temp-coercion.coerced.sroa.0.4.extract.shift = lshr i64 %0, 32
  %temp-coercion.coerced.sroa.0.4.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.0.4.extract.shift to i32
  %temp-coercion.coerced.sroa.4.12.extract.shift = lshr i64 %1, 32
  %temp-coercion.coerced.sroa.4.12.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.4.12.extract.shift to i32
  %2 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %temp-coercion.coerced.sroa.0.4.extract.trunc, i32 %temp-coercion.coerced.sroa.4.12.extract.trunc)
  %3 = extractvalue { i32, i1 } %2, 0
  %4 = extractvalue { i32, i1 } %2, 1
  %. = select i1 %4, i32 %temp-coercion.coerced.sroa.0.4.extract.trunc, i32 %3
  ret i32 %.
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i1 @"$s27GiftUIFoundationLayoutProbe4RectV8containsySbAA5PointVF"(i64 %0, i64 %1, i64 %2) #1 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %0 to i32
  %temp-coercion.coerced.sroa.4.0.extract.shift = lshr i64 %0, 32
  %temp-coercion.coerced.sroa.4.0.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.4.0.extract.shift to i32
  %temp-coercion.coerced1.sroa.0.0.extract.trunc = trunc i64 %1 to i32
  %temp-coercion.coerced1.sroa.0.4.extract.shift = lshr i64 %1, 32
  %temp-coercion.coerced1.sroa.0.4.extract.trunc = trunc nuw i64 %temp-coercion.coerced1.sroa.0.4.extract.shift to i32
  %temp-coercion.coerced1.sroa.5.12.extract.shift = lshr i64 %2, 32
  %temp-coercion.coerced1.sroa.5.12.extract.trunc = trunc nuw i64 %temp-coercion.coerced1.sroa.5.12.extract.shift to i32
  %.not = icmp slt i32 %temp-coercion.coerced.sroa.0.0.extract.trunc, %temp-coercion.coerced1.sroa.0.0.extract.trunc
  br i1 %.not, label %14, label %3

3:                                                ; preds = %entry
  %temp-coercion.coerced1.sroa.5.8.extract.trunc = trunc i64 %2 to i32
  %4 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %temp-coercion.coerced1.sroa.0.0.extract.trunc, i32 %temp-coercion.coerced1.sroa.5.8.extract.trunc)
  %5 = extractvalue { i32, i1 } %4, 0
  %6 = extractvalue { i32, i1 } %4, 1
  %. = select i1 %6, i32 %temp-coercion.coerced1.sroa.0.0.extract.trunc, i32 %5
  %7 = icmp sgt i32 %., %temp-coercion.coerced.sroa.0.0.extract.trunc
  %8 = icmp sge i32 %temp-coercion.coerced.sroa.4.0.extract.trunc, %temp-coercion.coerced1.sroa.0.4.extract.trunc
  %or.cond = select i1 %7, i1 %8, i1 false
  br i1 %or.cond, label %9, label %14

9:                                                ; preds = %3
  %10 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %temp-coercion.coerced1.sroa.0.4.extract.trunc, i32 %temp-coercion.coerced1.sroa.5.12.extract.trunc)
  %11 = extractvalue { i32, i1 } %10, 0
  %12 = extractvalue { i32, i1 } %10, 1
  %.2 = select i1 %12, i32 %temp-coercion.coerced1.sroa.0.4.extract.trunc, i32 %11
  %13 = icmp sgt i32 %.2, %temp-coercion.coerced.sroa.4.0.extract.trunc
  br label %14

14:                                               ; preds = %entry, %3, %9
  %15 = phi i1 [ %13, %9 ], [ false, %3 ], [ false, %entry ]
  ret i1 %15
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i1 @"$s27GiftUIFoundationLayoutProbe4RectV23__derived_struct_equalsySbAC_ACtFZ"(i64 %0, i64 %1, i64 %2, i64 %3) #1 {
entry:
  %or.cond = icmp eq i64 %0, %2
  %or.cond2 = icmp eq i64 %1, %3
  %spec.select = select i1 %or.cond, i1 %or.cond2, i1 false
  ret i1 %spec.select
}

define swiftcc void @"$s27GiftUIFoundationLayoutProbe4RectV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i64 %1, i64 %2) #2 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %1 to i32
  %temp-coercion.coerced.sroa.0.4.extract.shift = lshr i64 %1, 32
  %temp-coercion.coerced.sroa.0.4.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.0.4.extract.shift to i32
  %temp-coercion.coerced.sroa.5.8.extract.trunc = trunc i64 %2 to i32
  %temp-coercion.coerced.sroa.5.12.extract.shift = lshr i64 %2, 32
  %temp-coercion.coerced.sroa.5.12.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.5.12.extract.shift to i32
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.0.0.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.0.4.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.5.8.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.5.12.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  ret void
}

define swiftcc i64 @"$s27GiftUIFoundationLayoutProbe4RectV9hashValueSivg"(i64 %0, i64 %1) #2 {
entry:
  %2 = alloca %Ts6HasherV, align 8
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %0 to i32
  %temp-coercion.coerced.sroa.0.4.extract.shift = lshr i64 %0, 32
  %temp-coercion.coerced.sroa.0.4.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.0.4.extract.shift to i32
  %temp-coercion.coerced.sroa.5.8.extract.trunc = trunc i64 %1 to i32
  %temp-coercion.coerced.sroa.5.12.extract.shift = lshr i64 %1, 32
  %temp-coercion.coerced.sroa.5.12.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.5.12.extract.shift to i32
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %2)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %2, i64 0)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.0.0.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.0.4.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.5.8.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.5.12.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  %3 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %2)
  ret i64 %3
}

define linkonce_odr hidden swiftcc i1 @"$s27GiftUIFoundationLayoutProbe4RectVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias captures(none) dereferenceable(16) %0, ptr noalias captures(none) dereferenceable(16) %1, ptr swiftself %2, ptr %Self, ptr %SelfWitnessTable) #2 {
entry:
  %3 = load i32, ptr %0, align 4
  %.origin.y = getelementptr inbounds nuw i8, ptr %0, i64 4
  %4 = load i32, ptr %.origin.y, align 4
  %5 = load i32, ptr %1, align 4
  %.origin1.y = getelementptr inbounds nuw i8, ptr %1, i64 4
  %6 = load i32, ptr %.origin1.y, align 4
  %7 = icmp eq i32 %3, %5
  %8 = icmp eq i32 %4, %6
  %or.cond = select i1 %7, i1 %8, i1 false
  br i1 %or.cond, label %9, label %16

9:                                                ; preds = %entry
  %.size2.height = getelementptr inbounds nuw i8, ptr %1, i64 12
  %10 = load i32, ptr %.size2.height, align 4
  %.size2 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %11 = load i32, ptr %.size2, align 4
  %.size.height = getelementptr inbounds nuw i8, ptr %0, i64 12
  %12 = load i32, ptr %.size.height, align 4
  %.size = getelementptr inbounds nuw i8, ptr %0, i64 8
  %13 = load i32, ptr %.size, align 4
  %14 = icmp eq i32 %13, %11
  %15 = icmp eq i32 %12, %10
  %or.cond3 = select i1 %14, i1 %15, i1 false
  br label %16

16:                                               ; preds = %9, %entry
  %17 = phi i1 [ false, %entry ], [ %or.cond3, %9 ]
  ret i1 %17
}

define linkonce_odr hidden swiftcc i64 @"$s27GiftUIFoundationLayoutProbe4RectVSHAASH9hashValueSivgTW"(ptr noalias swiftself captures(none) dereferenceable(16) %0, ptr %Self, ptr %SelfWitnessTable) #2 {
entry:
  %1 = alloca %Ts6HasherV, align 8
  %2 = load i32, ptr %0, align 4
  %.origin.y = getelementptr inbounds nuw i8, ptr %0, i64 4
  %3 = load i32, ptr %.origin.y, align 4
  %.size = getelementptr inbounds nuw i8, ptr %0, i64 8
  %4 = load i32, ptr %.size, align 4
  %.size.height = getelementptr inbounds nuw i8, ptr %0, i64 12
  %5 = load i32, ptr %.size.height, align 4
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %1)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %1, i64 0) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %1) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %1) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %4, ptr nonnull swiftself captures(none) dereferenceable(72) %1) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %5, ptr nonnull swiftself captures(none) dereferenceable(72) %1) #17
  %6 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %1) #17
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %1)
  ret i64 %6
}

define linkonce_odr hidden swiftcc void @"$s27GiftUIFoundationLayoutProbe4RectVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias swiftself captures(none) dereferenceable(16) %1, ptr %Self, ptr %SelfWitnessTable) #2 {
entry:
  %2 = load i32, ptr %1, align 4
  %.origin.y = getelementptr inbounds nuw i8, ptr %1, i64 4
  %3 = load i32, ptr %.origin.y, align 4
  %.size = getelementptr inbounds nuw i8, ptr %1, i64 8
  %4 = load i32, ptr %.size, align 4
  %.size.height = getelementptr inbounds nuw i8, ptr %1, i64 12
  %5 = load i32, ptr %.size.height, align 4
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %4, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %5, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  ret void
}

define linkonce_odr hidden swiftcc i64 @"$s27GiftUIFoundationLayoutProbe4RectVSHAASH13_rawHashValue4seedS2i_tFTW"(i64 %0, ptr noalias swiftself captures(none) dereferenceable(16) %1, ptr %Self, ptr %SelfWitnessTable) #2 {
entry:
  %2 = alloca %Ts6HasherV, align 8
  %3 = load i32, ptr %1, align 4
  %.origin.y = getelementptr inbounds nuw i8, ptr %1, i64 4
  %4 = load i32, ptr %.origin.y, align 4
  %.size = getelementptr inbounds nuw i8, ptr %1, i64 8
  %5 = load i32, ptr %.size, align 4
  %.size.height = getelementptr inbounds nuw i8, ptr %1, i64 12
  %6 = load i32, ptr %.size.height, align 4
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %2)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %2, i64 %0) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %4, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %5, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %6, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  %7 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %2)
  ret i64 %7
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc range(i64 0, 1099511627776) i64 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV5widths5Int32VSgvg"(i64 %0, i64 %1) #1 {
entry:
  %temp-coercion.coerced1.sroa.0.0.insert.insert = and i64 %0, 1099511627775
  ret i64 %temp-coercion.coerced1.sroa.0.0.insert.insert
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc range(i64 0, 1099511627776) i64 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV6heights5Int32VSgvg"(i64 %0, i64 %1) #1 {
entry:
  %temp-coercion.coerced1.sroa.0.0.insert.insert = and i64 %1, 1099511627775
  ret i64 %temp-coercion.coerced1.sroa.0.0.insert.insert
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64 } @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV5width6heightACSgs5Int32VSg_AItcfC"(i64 %0, i64 %1) #1 {
entry:
  %2 = and i64 %0, 1095216660480
  %3 = icmp eq i64 %2, 4294967296
  %4 = and i64 %0, 2147483648
  %.not = icmp eq i64 %4, 0
  %or.cond = or i1 %3, %.not
  br i1 %or.cond, label %5, label %12

5:                                                ; preds = %entry
  %6 = and i64 %1, 1095216660480
  %7 = icmp eq i64 %6, 4294967296
  %8 = and i64 %1, 2147483648
  %.not3 = icmp eq i64 %8, 0
  %or.cond4 = or i1 %7, %.not3
  br i1 %or.cond4, label %9, label %12

9:                                                ; preds = %5
  %10 = and i64 %0, 1099511627775
  %11 = and i64 %1, 1099511627775
  br label %12

12:                                               ; preds = %5, %entry, %9
  %13 = phi i64 [ %10, %9 ], [ 0, %entry ], [ 0, %5 ]
  %temp-coercion.coerced2.sroa.4.13.insert.insert = phi i64 [ %11, %9 ], [ 1099511627776, %entry ], [ 1099511627776, %5 ]
  %14 = insertvalue { i64, i64 } undef, i64 %13, 0
  %15 = insertvalue { i64, i64 } %14, i64 %temp-coercion.coerced2.sroa.4.13.insert.insert, 1
  ret { i64, i64 } %15
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i1 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV23__derived_struct_equalsySbAC_ACtFZ"(i64 %0, i64 %1, i64 %2, i64 %3) #1 {
entry:
  %temp-coercion.coerced.sroa.5.8.extract.trunc = trunc i64 %1 to i32
  %temp-coercion.coerced1.sroa.0.4.extract.shift = lshr i64 %2, 32
  %temp-coercion.coerced1.sroa.0.4.extract.trunc = trunc i64 %temp-coercion.coerced1.sroa.0.4.extract.shift to i8
  %temp-coercion.coerced1.sroa.5.8.extract.trunc = trunc i64 %3 to i32
  %temp-coercion.coerced1.sroa.5.12.extract.shift = lshr i64 %3, 32
  %temp-coercion.coerced1.sroa.5.12.extract.trunc = trunc i64 %temp-coercion.coerced1.sroa.5.12.extract.shift to i8
  %4 = and i64 %0, 1095216660480
  %5 = icmp eq i64 %4, 4294967296
  br i1 %5, label %9, label %6

6:                                                ; preds = %entry
  %temp-coercion.coerced1.sroa.0.0.extract.trunc = trunc i64 %2 to i32
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %0 to i32
  %7 = icmp ne i8 %temp-coercion.coerced1.sroa.0.4.extract.trunc, 1
  %8 = icmp eq i32 %temp-coercion.coerced.sroa.0.0.extract.trunc, %temp-coercion.coerced1.sroa.0.0.extract.trunc
  %or.cond = select i1 %7, i1 %8, i1 false
  br i1 %or.cond, label %11, label %20

9:                                                ; preds = %entry
  %10 = icmp eq i8 %temp-coercion.coerced1.sroa.0.4.extract.trunc, 1
  br i1 %10, label %11, label %20

11:                                               ; preds = %6, %9
  %12 = and i64 %1, 1095216660480
  %13 = icmp eq i64 %12, 4294967296
  br i1 %13, label %17, label %14

14:                                               ; preds = %11
  %15 = icmp ne i8 %temp-coercion.coerced1.sroa.5.12.extract.trunc, 1
  %16 = icmp eq i32 %temp-coercion.coerced.sroa.5.8.extract.trunc, %temp-coercion.coerced1.sroa.5.8.extract.trunc
  %or.cond2 = select i1 %15, i1 %16, i1 false
  br i1 %or.cond2, label %20, label %19

17:                                               ; preds = %11
  %18 = icmp eq i8 %temp-coercion.coerced1.sroa.5.12.extract.trunc, 1
  br i1 %18, label %20, label %19

19:                                               ; preds = %17, %14
  br label %20

20:                                               ; preds = %14, %6, %9, %17, %19
  %21 = phi i1 [ false, %19 ], [ true, %17 ], [ false, %9 ], [ false, %6 ], [ true, %14 ]
  ret i1 %21
}

define swiftcc void @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i64 %1, i64 %2) #2 {
entry:
  %temp-coercion.coerced.sroa.5.8.extract.trunc = trunc i64 %2 to i32
  %3 = and i64 %1, 1095216660480
  %4 = icmp eq i64 %3, 4294967296
  br i1 %4, label %5, label %6

5:                                                ; preds = %entry
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  br label %7

6:                                                ; preds = %entry
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %1 to i32
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.0.0.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  br label %7

7:                                                ; preds = %5, %6
  %8 = and i64 %2, 1095216660480
  %9 = icmp eq i64 %8, 4294967296
  br i1 %9, label %10, label %11

10:                                               ; preds = %7
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  br label %12

11:                                               ; preds = %7
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.5.8.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  br label %12

12:                                               ; preds = %10, %11
  ret void
}

declare swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8, ptr swiftself captures(none) dereferenceable(72)) local_unnamed_addr #2

define swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV9hashValueSivg"(i64 %0, i64 %1) #2 {
entry:
  %2 = alloca %Ts6HasherV, align 8
  %temp-coercion.coerced.sroa.5.8.extract.trunc = trunc i64 %1 to i32
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %2)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %2, i64 0)
  %3 = and i64 %0, 1095216660480
  %4 = icmp eq i64 %3, 4294967296
  br i1 %4, label %5, label %6

5:                                                ; preds = %entry
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  br label %7

6:                                                ; preds = %entry
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %0 to i32
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.0.0.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  br label %7

7:                                                ; preds = %5, %6
  %8 = and i64 %1, 1095216660480
  %9 = icmp eq i64 %8, 4294967296
  br i1 %9, label %10, label %11

10:                                               ; preds = %7
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  br label %12

11:                                               ; preds = %7
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %temp-coercion.coerced.sroa.5.8.extract.trunc, ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  br label %12

12:                                               ; preds = %10, %11
  %13 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %2)
  ret i64 %13
}

define linkonce_odr hidden swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias captures(none) dereferenceable(13) %0, ptr noalias captures(none) dereferenceable(13) %1, ptr swiftself %2, ptr %Self, ptr %SelfWitnessTable) #2 {
entry:
  %3 = getelementptr inbounds nuw i8, ptr %0, i64 4
  %4 = load i8, ptr %3, align 4
  %.height = getelementptr inbounds nuw i8, ptr %0, i64 8
  %5 = load i32, ptr %.height, align 4
  %6 = getelementptr inbounds nuw i8, ptr %0, i64 12
  %7 = load i8, ptr %6, align 4
  %8 = getelementptr inbounds nuw i8, ptr %1, i64 4
  %9 = load i8, ptr %8, align 4
  %.height2 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %10 = load i32, ptr %.height2, align 4
  %11 = getelementptr inbounds nuw i8, ptr %1, i64 12
  %12 = load i8, ptr %11, align 4
  %13 = icmp eq i8 %4, 1
  br i1 %13, label %19, label %14

14:                                               ; preds = %entry
  %15 = load i32, ptr %1, align 4
  %16 = load i32, ptr %0, align 4
  %17 = icmp ne i8 %9, 1
  %18 = icmp eq i32 %16, %15
  %or.cond = select i1 %17, i1 %18, i1 false
  br i1 %or.cond, label %21, label %28

19:                                               ; preds = %entry
  %20 = icmp eq i8 %9, 1
  br i1 %20, label %21, label %28

21:                                               ; preds = %14, %19
  %22 = icmp eq i8 %7, 1
  br i1 %22, label %26, label %23

23:                                               ; preds = %21
  %24 = icmp ne i8 %12, 1
  %25 = icmp eq i32 %5, %10
  %or.cond3 = select i1 %24, i1 %25, i1 false
  br i1 %or.cond3, label %28, label %30

26:                                               ; preds = %21
  %27 = icmp eq i8 %12, 1
  br i1 %27, label %28, label %30

28:                                               ; preds = %23, %19, %14, %26, %30
  %29 = phi i1 [ false, %30 ], [ true, %26 ], [ false, %14 ], [ false, %19 ], [ true, %23 ]
  ret i1 %29

30:                                               ; preds = %26, %23
  br label %28
}

define linkonce_odr hidden swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASH9hashValueSivgTW"(ptr noalias swiftself captures(none) dereferenceable(13) %0, ptr %Self, ptr %SelfWitnessTable) #2 {
entry:
  %1 = load i32, ptr %0, align 4
  %2 = getelementptr inbounds nuw i8, ptr %0, i64 4
  %3 = load i8, ptr %2, align 4
  %.height = getelementptr inbounds nuw i8, ptr %0, i64 8
  %4 = load i32, ptr %.height, align 4
  %5 = getelementptr inbounds nuw i8, ptr %0, i64 12
  %6 = load i8, ptr %5, align 4
  %temp-coercion.coerced.sroa.0.0.insert.ext = zext i32 %1 to i64
  %temp-coercion.coerced.sroa.0.4.insert.ext = zext i8 %3 to i64
  %temp-coercion.coerced.sroa.0.4.insert.shift = shl nuw nsw i64 %temp-coercion.coerced.sroa.0.4.insert.ext, 32
  %temp-coercion.coerced.sroa.0.4.insert.insert = or disjoint i64 %temp-coercion.coerced.sroa.0.4.insert.shift, %temp-coercion.coerced.sroa.0.0.insert.ext
  %temp-coercion.coerced.sroa.5.8.insert.ext = zext i32 %4 to i64
  %temp-coercion.coerced.sroa.5.12.insert.ext = zext i8 %6 to i64
  %temp-coercion.coerced.sroa.5.12.insert.shift = shl nuw nsw i64 %temp-coercion.coerced.sroa.5.12.insert.ext, 32
  %temp-coercion.coerced.sroa.5.12.insert.insert = or disjoint i64 %temp-coercion.coerced.sroa.5.12.insert.shift, %temp-coercion.coerced.sroa.5.8.insert.ext
  %7 = tail call swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV9hashValueSivg"(i64 %temp-coercion.coerced.sroa.0.4.insert.insert, i64 %temp-coercion.coerced.sroa.5.12.insert.insert) #17
  ret i64 %7
}

define linkonce_odr hidden swiftcc void @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias swiftself captures(none) dereferenceable(13) %1, ptr %Self, ptr %SelfWitnessTable) #2 {
entry:
  %2 = getelementptr inbounds nuw i8, ptr %1, i64 4
  %3 = load i8, ptr %2, align 4
  %.height = getelementptr inbounds nuw i8, ptr %1, i64 8
  %4 = load i32, ptr %.height, align 4
  %5 = getelementptr inbounds nuw i8, ptr %1, i64 12
  %6 = load i8, ptr %5, align 4
  %7 = icmp eq i8 %3, 1
  br i1 %7, label %8, label %9

8:                                                ; preds = %entry
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  br label %11

9:                                                ; preds = %entry
  %10 = load i32, ptr %1, align 4
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %10, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  br label %11

11:                                               ; preds = %8, %9
  %12 = icmp eq i8 %6, 1
  br i1 %12, label %13, label %14

13:                                               ; preds = %11
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  br label %15

14:                                               ; preds = %11
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %4, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  br label %15

15:                                               ; preds = %13, %14
  ret void
}

define linkonce_odr hidden swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASH13_rawHashValue4seedS2i_tFTW"(i64 %0, ptr noalias swiftself captures(none) dereferenceable(13) %1, ptr %Self, ptr %SelfWitnessTable) #2 {
entry:
  %2 = alloca %Ts6HasherV, align 8
  %3 = load i32, ptr %1, align 4
  %4 = getelementptr inbounds nuw i8, ptr %1, i64 4
  %5 = load i8, ptr %4, align 4
  %.height = getelementptr inbounds nuw i8, ptr %1, i64 8
  %6 = load i32, ptr %.height, align 4
  %7 = getelementptr inbounds nuw i8, ptr %1, i64 12
  %8 = load i8, ptr %7, align 4
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %2)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %2, i64 %0) #17
  %9 = icmp eq i8 %5, 1
  br i1 %9, label %10, label %11

10:                                               ; preds = %entry
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  br label %12

11:                                               ; preds = %entry
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  br label %12

12:                                               ; preds = %10, %11
  %13 = icmp eq i8 %8, 1
  br i1 %13, label %14, label %15

14:                                               ; preds = %12
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  br label %16

15:                                               ; preds = %12
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %6, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  br label %16

16:                                               ; preds = %14, %15
  %17 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %2)
  ret i64 %17
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc range(i64 0, 4294967297) i64 @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticO8subtractys5Int32VSgAF_AFtFZ"(i32 %0, i32 %1) #1 {
entry:
  %2 = tail call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 %0, i32 %1)
  %3 = extractvalue { i32, i1 } %2, 0
  %4 = extractvalue { i32, i1 } %2, 1
  %5 = zext i32 %3 to i64
  %temp-coercion.coerced.sroa.0.0.insert.insert = select i1 %4, i64 4294967296, i64 %5
  ret i64 %temp-coercion.coerced.sroa.0.0.insert.insert
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.ssub.with.overflow.i32(i32, i32) #4

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc range(i64 0, 4294967297) i64 @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticO8multiplyys5Int32VSgAF_AFtFZ"(i32 %0, i32 %1) #1 {
entry:
  %2 = tail call { i32, i1 } @llvm.smul.with.overflow.i32(i32 %0, i32 %1)
  %3 = extractvalue { i32, i1 } %2, 0
  %4 = extractvalue { i32, i1 } %2, 1
  %5 = zext i32 %3 to i64
  %temp-coercion.coerced.sroa.0.0.insert.insert = select i1 %4, i64 4294967296, i64 %5
  ret i64 %temp-coercion.coerced.sroa.0.0.insert.insert
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.smul.with.overflow.i32(i32, i32) #4

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc range(i8 0, 4) i8 @"$s27GiftUIFoundationLayoutProbe12PointerPhaseO8rawValueACSgs5UInt8V_tcfC"(i8 %0) #1 {
entry:
  %. = tail call i8 @llvm.umin.i8(i8 %0, i8 3)
  ret i8 %.
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i8 @"$s27GiftUIFoundationLayoutProbe12PointerPhaseO8rawValues5UInt8Vvg"(i8 returned %0) #1 {
entry:
  ret i8 %0
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASH9hashValueSivgTW"(ptr noalias readonly swiftself captures(none) dereferenceable(1) %0, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #2 {
entry:
  %1 = alloca %Ts6HasherV, align 8
  %2 = load i8, ptr %0, align 1
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %1)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %1, i64 0) #17
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %1) #17
  %3 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %1) #17
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %1)
  ret i64 %3
}

define internal swiftcc void @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias readonly swiftself captures(none) dereferenceable(1) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #2 {
entry:
  %2 = load i8, ptr %1, align 1
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  ret void
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASH13_rawHashValue4seedS2i_tFTW"(i64 %0, ptr noalias readonly swiftself captures(none) dereferenceable(1) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #2 {
entry:
  %2 = alloca %Ts6HasherV, align 8
  %3 = load i8, ptr %1, align 1
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %2)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %2, i64 %0) #17
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  %4 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %2)
  ret i64 %4
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
define internal swiftcc void @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAASY8rawValuexSg03RawH0Qz_tcfCTW"(ptr noalias writeonly sret(%T27GiftUIFoundationLayoutProbe12PointerPhaseOSg) captures(none) initializes((0, 1)) %0, ptr noalias readonly captures(none) dereferenceable(1) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #5 {
entry:
  %3 = load i8, ptr %1, align 1
  %. = tail call i8 @llvm.umin.i8(i8 %3, i8 3)
  store i8 %., ptr %0, align 1
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
define internal swiftcc void @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAASY8rawValue03RawH0QzvgTW"(ptr noalias writeonly sret(%Ts5UInt8V) captures(none) initializes((0, 1)) %0, ptr noalias readonly swiftself captures(none) dereferenceable(1) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #5 {
entry:
  %2 = load i8, ptr %1, align 1
  store i8 %2, ptr %0, align 1
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(1) %0, ptr noalias readonly captures(none) dereferenceable(1) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #6 {
entry:
  %3 = load i8, ptr %0, align 1
  %4 = load i8, ptr %1, align 1
  %5 = icmp eq i8 %3, %4
  ret i1 %5
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i16 @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV8rawValues6UInt16Vvg"(i16 returned %0) #1 {
entry:
  ret i16 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i16 @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV8rawValueACs6UInt16V_tcfC"(i16 returned %0) #1 {
entry:
  ret i16 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i1 @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV23__derived_struct_equalsySbAC_ACtFZ"(i16 %0, i16 %1) #1 {
entry:
  %2 = icmp eq i16 %0, %1
  ret i1 %2
}

define swiftcc void @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i16 %1) #2 {
entry:
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt16VF"(i16 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  ret void
}

declare swiftcc void @"$ss6HasherV8_combineyys6UInt16VF"(i16, ptr swiftself captures(none) dereferenceable(72)) local_unnamed_addr #2

define swiftcc i64 @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV9hashValueSivg"(i16 %0) #2 {
entry:
  %1 = alloca %Ts6HasherV, align 8
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %1)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %1, i64 0)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt16VF"(i16 %0, ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  %2 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %1)
  ret i64 %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal swiftcc i1 @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(2) %0, ptr noalias readonly captures(none) dereferenceable(2) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #6 {
entry:
  %3 = load i16, ptr %0, align 2
  %4 = load i16, ptr %1, align 2
  %5 = icmp eq i16 %3, %4
  ret i1 %5
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASH9hashValueSivgTW"(ptr noalias readonly swiftself captures(none) dereferenceable(2) %0, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #2 {
entry:
  %1 = alloca %Ts6HasherV, align 8
  %2 = load i16, ptr %0, align 2
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %1)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %1, i64 0) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt16VF"(i16 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %1) #17
  %3 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %1) #17
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %1)
  ret i64 %3
}

define internal swiftcc void @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias readonly swiftself captures(none) dereferenceable(2) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #2 {
entry:
  %2 = load i16, ptr %1, align 2
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt16VF"(i16 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  ret void
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASH13_rawHashValue4seedS2i_tFTW"(i64 %0, ptr noalias readonly swiftself captures(none) dereferenceable(2) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #2 {
entry:
  %2 = alloca %Ts6HasherV, align 8
  %3 = load i16, ptr %1, align 2
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %2)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %2, i64 %0) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt16VF"(i16 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  %4 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %2) #17
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %2)
  ret i64 %4
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV8rawValues6UInt32Vvg"(i32 returned %0) #1 {
entry:
  ret i32 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV8rawValueACs6UInt32V_tcfC"(i32 returned %0) #1 {
entry:
  ret i32 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV8rawValues6UInt32Vvg"(i32 returned %0) #1 {
entry:
  ret i32 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV8rawValueACs6UInt32V_tcfC"(i32 returned %0) #1 {
entry:
  ret i32 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) #1 {
entry:
  %2 = icmp eq i32 %0, %1
  ret i1 %2
}

define swiftcc void @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) #2 {
entry:
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  ret void
}

define swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV9hashValueSivg"(i32 %0) #2 {
  %2 = tail call swiftcc i64 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV9hashValueSivgTm"(i32 %0) #2
  ret i64 %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(4) %0, ptr noalias readonly captures(none) dereferenceable(4) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #6 {
entry:
  %3 = load i32, ptr %0, align 4
  %4 = load i32, ptr %1, align 4
  %5 = icmp eq i32 %3, %4
  ret i1 %5
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH9hashValueSivgTW"(ptr noalias readonly swiftself captures(none) dereferenceable(4) %0, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #2 {
  %2 = tail call swiftcc i64 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH9hashValueSivgTWTm"(ptr noalias readonly swiftself captures(none) dereferenceable(4) %0, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #2
  ret i64 %2
}

define internal swiftcc void @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #2 {
entry:
  %2 = load i32, ptr %1, align 4
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #17
  ret void
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH13_rawHashValue4seedS2i_tFTW"(i64 %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #2 {
  %3 = tail call swiftcc i64 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH13_rawHashValue4seedS2i_tFTWTm"(i64 %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #2
  ret i64 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV8rawValues6UInt32Vvg"(i32 returned %0) #1 {
entry:
  ret i32 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV8rawValueACs6UInt32V_tcfC"(i32 returned %0) #1 {
entry:
  ret i32 %0
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV9hashValueSivgTm"(i32 %0) #2 {
entry:
  %1 = alloca %Ts6HasherV, align 8
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %1)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %1, i64 0)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %0, ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  %2 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %1)
  ret i64 %2
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH9hashValueSivgTWTm"(ptr noalias readonly swiftself captures(none) dereferenceable(4) %0, ptr readnone captures(none) %1, ptr readnone captures(none) %2) #2 {
entry:
  %3 = alloca %Ts6HasherV, align 8
  %4 = load i32, ptr %0, align 4
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %3)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %3, i64 0) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %4, ptr nonnull swiftself captures(none) dereferenceable(72) %3) #17
  %5 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %3) #17
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %3)
  ret i64 %5
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH13_rawHashValue4seedS2i_tFTWTm"(i64 %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #2 {
entry:
  %4 = alloca %Ts6HasherV, align 8
  %5 = load i32, ptr %1, align 4
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %4)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %4, i64 %0) #17
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %5, ptr nonnull swiftself captures(none) dereferenceable(72) %4) #17
  %6 = call swiftcc i64 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %4) #17
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %4)
  ret i64 %6
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i8 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV5phaseAA0F5PhaseOvg"(i64 %0, i64 %1, i64 %2, i32 %3) #1 {
entry:
  %temp-coercion.coerced.sroa.0.0.extract.trunc = trunc i64 %0 to i8
  ret i8 %temp-coercion.coerced.sroa.0.0.extract.trunc
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i64 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV8positionAA5PointVvg"(i64 %0, i64 %1, i64 %2, i32 %3) #1 {
entry:
  %temp-coercion.coerced1.sroa.0.0.insert.insert = tail call i64 @llvm.fshl.i64(i64 %1, i64 %0, i64 32)
  ret i64 %temp-coercion.coerced1.sroa.0.0.insert.insert
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i16 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV6sourceAA13InputSourceIDVvg"(i64 %0, i64 %1, i64 %2, i32 %3) #1 {
entry:
  %temp-coercion.coerced.sroa.3.12.extract.shift = lshr i64 %1, 32
  %temp-coercion.coerced.sroa.3.12.extract.trunc = trunc i64 %temp-coercion.coerced.sroa.3.12.extract.shift to i16
  ret i16 %temp-coercion.coerced.sroa.3.12.extract.trunc
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV8sequenceAA0F10SequenceIDVvg"(i64 %0, i64 %1, i64 %2, i32 %3) #1 {
entry:
  %temp-coercion.coerced.sroa.4.16.extract.trunc = trunc i64 %2 to i32
  ret i32 %temp-coercion.coerced.sroa.4.16.extract.trunc
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV7ordinalAA12InputOrdinalVvg"(i64 %0, i64 %1, i64 %2, i32 %3) #1 {
entry:
  %temp-coercion.coerced.sroa.4.20.extract.shift = lshr i64 %2, 32
  %temp-coercion.coerced.sroa.4.20.extract.trunc = trunc nuw i64 %temp-coercion.coerced.sroa.4.20.extract.shift to i32
  ret i32 %temp-coercion.coerced.sroa.4.20.extract.trunc
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV20presentationRevisionAA012PresentationI0Vvg"(i64 %0, i64 %1, i64 %2, i32 returned %3) #1 {
entry:
  ret i32 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc { i64, i64, i64, i32 } @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV5phase8position6source8sequence7ordinal20presentationRevisionAcA0F5PhaseO_AA5PointVAA13InputSourceIDVAA0f8SequenceS0VAA0Q7OrdinalVAA012PresentationN0VtcfC"(i8 %0, i64 %1, i16 %2, i32 %3, i32 %4, i32 %5) #1 {
entry:
  %.sroa.0.0.insert.ext = zext i8 %0 to i64
  %.sroa.0.4.insert.ext = shl i64 %1, 32
  %.sroa.0.4.insert.insert = or disjoint i64 %.sroa.0.4.insert.ext, %.sroa.0.0.insert.ext
  %.sroa.5.12.insert.ext = zext i16 %2 to i64
  %.sroa.5.12.insert.insert = tail call i64 @llvm.fshl.i64(i64 %.sroa.5.12.insert.ext, i64 %1, i64 32)
  %.sroa.8.16.insert.ext = zext i32 %3 to i64
  %.sroa.8.20.insert.ext = zext i32 %4 to i64
  %.sroa.8.20.insert.shift = shl nuw i64 %.sroa.8.20.insert.ext, 32
  %.sroa.8.20.insert.insert = or disjoint i64 %.sroa.8.20.insert.shift, %.sroa.8.16.insert.ext
  %6 = insertvalue { i64, i64, i64, i32 } undef, i64 %.sroa.0.4.insert.insert, 0
  %7 = insertvalue { i64, i64, i64, i32 } %6, i64 %.sroa.5.12.insert.insert, 1
  %8 = insertvalue { i64, i64, i64, i32 } %7, i64 %.sroa.8.20.insert.insert, 2
  %9 = insertvalue { i64, i64, i64, i32 } %8, i32 %5, 3
  ret { i64, i64, i64, i32 } %9
}

define swiftcc i1 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV23__derived_struct_equalsySbAC_ACtFZ"(i64 %0, i64 %1, i64 %2, i32 %3, i64 %4, i64 %5, i64 %6, i32 %7) #2 {
entry:
  %temp-coercion.coerced2.sroa.0.4.insert.insert = and i64 %0, -4294967041
  %temp-coercion.coerced2.sroa.5.12.insert.insert = and i64 %1, 281474976710655
  %temp-coercion.coerced3.sroa.0.4.insert.insert = and i64 %4, -4294967041
  %temp-coercion.coerced3.sroa.5.12.insert.insert = and i64 %5, 281474976710655
  %8 = tail call swiftcc i1 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV23__derived_struct_equalsySbAC_ACtFZTf4nnd_n"(i64 %temp-coercion.coerced2.sroa.0.4.insert.insert, i64 %temp-coercion.coerced2.sroa.5.12.insert.insert, i64 %2, i32 %3, i64 %temp-coercion.coerced3.sroa.0.4.insert.insert, i64 %temp-coercion.coerced3.sroa.5.12.insert.insert, i64 %6, i32 %7) #17
  ret i1 %8
}

define internal swiftcc i1 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(28) %0, ptr noalias readonly captures(none) dereferenceable(28) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #2 {
entry:
  %3 = load i8, ptr %0, align 4
  %.position = getelementptr inbounds nuw i8, ptr %0, i64 4
  %4 = load i32, ptr %.position, align 4
  %.position.y = getelementptr inbounds nuw i8, ptr %0, i64 8
  %5 = load i32, ptr %.position.y, align 4
  %.source = getelementptr inbounds nuw i8, ptr %0, i64 12
  %6 = load i16, ptr %.source, align 4
  %.sequence = getelementptr inbounds nuw i8, ptr %0, i64 16
  %7 = load i64, ptr %.sequence, align 4
  %.presentationRevision = getelementptr inbounds nuw i8, ptr %0, i64 24
  %8 = load i32, ptr %.presentationRevision, align 4
  %9 = load i8, ptr %1, align 4
  %.position2 = getelementptr inbounds nuw i8, ptr %1, i64 4
  %10 = load i32, ptr %.position2, align 4
  %.position2.y = getelementptr inbounds nuw i8, ptr %1, i64 8
  %11 = load i32, ptr %.position2.y, align 4
  %.source3 = getelementptr inbounds nuw i8, ptr %1, i64 12
  %12 = load i16, ptr %.source3, align 4
  %.sequence4 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %13 = load i64, ptr %.sequence4, align 4
  %.presentationRevision6 = getelementptr inbounds nuw i8, ptr %1, i64 24
  %14 = load i32, ptr %.presentationRevision6, align 4
  %temp-coercion.coerced.sroa.0.0.insert.ext = zext i8 %3 to i64
  %temp-coercion.coerced.sroa.0.4.insert.ext = zext i32 %4 to i64
  %temp-coercion.coerced.sroa.0.4.insert.shift = shl nuw i64 %temp-coercion.coerced.sroa.0.4.insert.ext, 32
  %temp-coercion.coerced.sroa.0.4.insert.insert = or disjoint i64 %temp-coercion.coerced.sroa.0.4.insert.shift, %temp-coercion.coerced.sroa.0.0.insert.ext
  %temp-coercion.coerced.sroa.5.8.insert.ext = zext i32 %5 to i64
  %temp-coercion.coerced.sroa.5.12.insert.ext = zext i16 %6 to i64
  %temp-coercion.coerced.sroa.5.12.insert.shift = shl nuw nsw i64 %temp-coercion.coerced.sroa.5.12.insert.ext, 32
  %temp-coercion.coerced.sroa.5.12.insert.insert = or disjoint i64 %temp-coercion.coerced.sroa.5.12.insert.shift, %temp-coercion.coerced.sroa.5.8.insert.ext
  %temp-coercion.coerced7.sroa.0.0.insert.ext = zext i8 %9 to i64
  %temp-coercion.coerced7.sroa.0.4.insert.ext = zext i32 %10 to i64
  %temp-coercion.coerced7.sroa.0.4.insert.shift = shl nuw i64 %temp-coercion.coerced7.sroa.0.4.insert.ext, 32
  %temp-coercion.coerced7.sroa.0.4.insert.insert = or disjoint i64 %temp-coercion.coerced7.sroa.0.4.insert.shift, %temp-coercion.coerced7.sroa.0.0.insert.ext
  %temp-coercion.coerced7.sroa.5.8.insert.ext = zext i32 %11 to i64
  %temp-coercion.coerced7.sroa.5.12.insert.ext = zext i16 %12 to i64
  %temp-coercion.coerced7.sroa.5.12.insert.shift = shl nuw nsw i64 %temp-coercion.coerced7.sroa.5.12.insert.ext, 32
  %temp-coercion.coerced7.sroa.5.12.insert.insert = or disjoint i64 %temp-coercion.coerced7.sroa.5.12.insert.shift, %temp-coercion.coerced7.sroa.5.8.insert.ext
  %15 = tail call swiftcc i1 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV23__derived_struct_equalsySbAC_ACtFZTf4nnd_n"(i64 %temp-coercion.coerced.sroa.0.4.insert.insert, i64 %temp-coercion.coerced.sroa.5.12.insert.insert, i64 %7, i32 %8, i64 %temp-coercion.coerced7.sroa.0.4.insert.insert, i64 %temp-coercion.coerced7.sroa.5.12.insert.insert, i64 %13, i32 %14) #17
  ret i1 %15
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO18geometryScalarSizes6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO20geometryScalarStrides6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO23geometryScalarAlignments6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO9pointSizes6UInt32VyFZ"() #7 {
entry:
  ret i32 8
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO11pointStrides6UInt32VyFZ"() #7 {
entry:
  ret i32 8
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO14pointAlignments6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO8sizeSizes6UInt32VyFZ"() #7 {
entry:
  ret i32 8
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO10sizeStrides6UInt32VyFZ"() #7 {
entry:
  ret i32 8
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO13sizeAlignments6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO8rectSizes6UInt32VyFZ"() #7 {
entry:
  ret i32 16
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO10rectStrides6UInt32VyFZ"() #7 {
entry:
  ret i32 16
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO13rectAlignments6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO16proposedByteSizes6UInt32VyFZ"() #7 {
entry:
  ret i32 13
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO14proposedStrides6UInt32VyFZ"() #7 {
entry:
  ret i32 16
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO17proposedAlignments6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO16pointerPhaseSizes6UInt32VyFZ"() #7 {
entry:
  ret i32 1
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO18pointerPhaseStrides6UInt32VyFZ"() #7 {
entry:
  ret i32 1
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO21pointerPhaseAlignments6UInt32VyFZ"() #7 {
entry:
  ret i32 1
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO17inputSourceIDSizes6UInt32VyFZ"() #7 {
entry:
  ret i32 2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO19inputSourceIDStrides6UInt32VyFZ"() #7 {
entry:
  ret i32 2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO22inputSourceIDAlignments6UInt32VyFZ"() #7 {
entry:
  ret i32 2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO21pointerSequenceIDSizes6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO23pointerSequenceIDStrides6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO26pointerSequenceIDAlignments6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO16inputOrdinalSizes6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO18inputOrdinalStrides6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO21inputOrdinalAlignments6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO24presentationRevisionSizes6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO26presentationRevisionStrides6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO29presentationRevisionAlignments6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO26normalizedPointerEventSizes6UInt32VyFZ"() #7 {
entry:
  ret i32 28
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO28normalizedPointerEventStrides6UInt32VyFZ"() #7 {
entry:
  ret i32 28
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO31normalizedPointerEventAlignments6UInt32VyFZ"() #7 {
entry:
  ret i32 4
}

define linkonce_odr hidden swiftcc i1 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV23__derived_struct_equalsySbAC_ACtFZTf4nnd_n"(i64 %0, i64 %1, i64 %2, i32 %3, i64 %4, i64 %5, i64 %6, i32 %7) local_unnamed_addr #2 {
entry:
  %temp-coercion.coerced.sroa.5.8.extract.trunc = trunc i64 %1 to i32
  %temp-coercion.coerced.sroa.5.12.extract.shift = lshr i64 %1, 32
  %temp-coercion.coerced.sroa.5.12.extract.trunc = trunc i64 %temp-coercion.coerced.sroa.5.12.extract.shift to i16
  %temp-coercion.coerced1.sroa.5.8.extract.trunc = trunc i64 %5 to i32
  %temp-coercion.coerced1.sroa.5.12.extract.shift = lshr i64 %5, 32
  %temp-coercion.coerced1.sroa.5.12.extract.trunc = trunc i64 %temp-coercion.coerced1.sroa.5.12.extract.shift to i16
  %8 = xor i64 %4, %0
  %9 = and i64 %8, -4294967041
  %or.cond = icmp eq i64 %9, 0
  %10 = icmp eq i32 %temp-coercion.coerced.sroa.5.8.extract.trunc, %temp-coercion.coerced1.sroa.5.8.extract.trunc
  %or.cond2 = select i1 %or.cond, i1 %10, i1 false
  %11 = icmp eq i16 %temp-coercion.coerced.sroa.5.12.extract.trunc, %temp-coercion.coerced1.sroa.5.12.extract.trunc
  %or.cond3 = select i1 %or.cond2, i1 %11, i1 false
  %12 = icmp eq i64 %2, %6
  %or.cond5 = select i1 %or.cond3, i1 %12, i1 false
  %13 = icmp eq i32 %3, %7
  %spec.select = select i1 %or.cond5, i1 %13, i1 false
  ret i1 %spec.select
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAASQWb"(ptr readnone captures(none) %Point, ptr readnone captures(none) %Point1, ptr readnone captures(none) %Point.Hashable) #8 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe5PointVACSQAAWl"() #18
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe5PointVACSQAAWl"() local_unnamed_addr #9 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe5PointVACSQAAWL", align 8
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMf", i64 16), ptr undef) #19
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe5PointVACSQAAWL" release, align 8
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nounwind memory(read)
declare ptr @swift_getWitnessTable(ptr, ptr, ptr) local_unnamed_addr #10

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASQWb"(ptr readnone captures(none) %Size, ptr readnone captures(none) %Size1, ptr readnone captures(none) %Size.Hashable) #8 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe4SizeVACSQAAWl"() #18
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe4SizeVACSQAAWl"() local_unnamed_addr #9 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVACSQAAWL", align 8
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMf", i64 16), ptr undef) #19
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVACSQAAWL" release, align 8
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAASQWb"(ptr readnone captures(none) %Rect, ptr readnone captures(none) %Rect1, ptr readnone captures(none) %Rect.Hashable) #8 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe4RectVACSQAAWl"() #18
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe4RectVACSQAAWl"() local_unnamed_addr #9 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe4RectVACSQAAWL", align 8
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMf", i64 16), ptr undef) #19
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe4RectVACSQAAWL" release, align 8
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASQWb"(ptr readnone captures(none) %ProposedSize, ptr readnone captures(none) %ProposedSize1, ptr readnone captures(none) %ProposedSize.Hashable) #8 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVACSQAAWl"() #18
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVACSQAAWl"() local_unnamed_addr #9 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVACSQAAWL", align 8
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMf", i64 16), ptr undef) #19
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVACSQAAWL" release, align 8
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASQWb"(ptr readnone captures(none) %PointerPhase, ptr readnone captures(none) %PointerPhase1, ptr readnone captures(none) %PointerPhase.Hashable) #8 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOACSQAAWl"() #18
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOACSQAAWl"() local_unnamed_addr #9 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOACSQAAWL", align 8
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMf", i64 16), ptr undef) #19
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOACSQAAWL" release, align 8
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASQWb"(ptr readnone captures(none) %InputSourceID, ptr readnone captures(none) %InputSourceID1, ptr readnone captures(none) %InputSourceID.Hashable) #8 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVACSQAAWl"() #18
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVACSQAAWl"() local_unnamed_addr #9 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVACSQAAWL", align 8
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMf", i64 16), ptr undef) #19
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVACSQAAWL" release, align 8
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASQWb"(ptr readnone captures(none) %PointerSequenceID, ptr readnone captures(none) %PointerSequenceID1, ptr readnone captures(none) %PointerSequenceID.Hashable) #8 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVACSQAAWl"() #18
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVACSQAAWl"() local_unnamed_addr #9 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVACSQAAWL", align 8
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMf", i64 16), ptr undef) #19
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVACSQAAWL" release, align 8
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASQWb"(ptr readnone captures(none) %InputOrdinal, ptr readnone captures(none) %InputOrdinal1, ptr readnone captures(none) %InputOrdinal.Hashable) #8 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVACSQAAWl"() #18
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVACSQAAWl"() local_unnamed_addr #9 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVACSQAAWL", align 8
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMf", i64 16), ptr undef) #19
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVACSQAAWL" release, align 8
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASQWb"(ptr readnone captures(none) %PresentationRevision, ptr readnone captures(none) %PresentationRevision1, ptr readnone captures(none) %PresentationRevision.Hashable) #8 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVACSQAAWl"() #18
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVACSQAAWl"() local_unnamed_addr #9 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVACSQAAWL", align 8
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMf", i64 16), ptr undef) #19
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVACSQAAWL" release, align 8
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy8_4(ptr %0, ptr %1, ptr %2) #11 {
entry:
  %3 = load i64, ptr %1, align 4
  store i64 %3, ptr %0, align 4
  ret ptr %0
}

; Function Attrs: nounwind
define linkonce_odr hidden void @__swift_noop_void_return(ptr %0, ptr %1) #11 {
entry:
  ret void
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe5PointVMa"(i64 %0) #7 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s27GiftUIFoundationLayoutProbe4SizeVwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %Size) #6 {
entry:
  %0 = icmp eq i32 %numEmptyCases, 0
  br i1 %0, label %9, label %1

1:                                                ; preds = %entry
  %2 = getelementptr inbounds nuw i8, ptr %value, i64 8
  %3 = load i8, ptr %2, align 1
  %4 = icmp eq i8 %3, 0
  br i1 %4, label %9, label %5

5:                                                ; preds = %1
  %6 = load i64, ptr %value, align 1
  %7 = trunc i64 %6 to i32
  %8 = add i32 %7, 1
  br label %9

9:                                                ; preds = %entry, %1, %5
  %10 = phi i32 [ %8, %5 ], [ 0, %1 ], [ 0, %entry ]
  ret i32 %10
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define internal void @"$s27GiftUIFoundationLayoutProbe4SizeVwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %Size) #12 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i64 8
  %.not = icmp eq i32 %numEmptyCases, 0
  %1 = icmp eq i32 %whichCase, 0
  br i1 %1, label %2, label %3

2:                                                ; preds = %entry
  br i1 %.not, label %6, label %.sink.split

3:                                                ; preds = %entry
  %4 = add i32 %whichCase, -1
  %5 = zext i32 %4 to i64
  store i64 %5, ptr %value, align 4
  br i1 %.not, label %6, label %.sink.split

.sink.split:                                      ; preds = %3, %2
  %.sink = phi i8 [ 0, %2 ], [ 1, %3 ]
  store i8 %.sink, ptr %0, align 4
  br label %6

6:                                                ; preds = %.sink.split, %3, %2
  ret void
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe4SizeVMa"(i64 %0) #7 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy16_4(ptr %0, ptr %1, ptr %2) #11 {
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 4 dereferenceable(16) %0, ptr noundef nonnull align 4 dereferenceable(16) %1, i64 16, i1 false)
  ret ptr %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s27GiftUIFoundationLayoutProbe4RectVwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %Rect) #6 {
entry:
  %0 = icmp eq i32 %numEmptyCases, 0
  br i1 %0, label %9, label %1

1:                                                ; preds = %entry
  %2 = getelementptr inbounds nuw i8, ptr %value, i64 16
  %3 = load i8, ptr %2, align 1
  %4 = icmp eq i8 %3, 0
  br i1 %4, label %9, label %5

5:                                                ; preds = %1
  %6 = load i128, ptr %value, align 1
  %7 = trunc i128 %6 to i32
  %8 = add i32 %7, 1
  br label %9

9:                                                ; preds = %entry, %1, %5
  %10 = phi i32 [ %8, %5 ], [ 0, %1 ], [ 0, %entry ]
  ret i32 %10
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define internal void @"$s27GiftUIFoundationLayoutProbe4RectVwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %Rect) #12 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i64 16
  %.not = icmp eq i32 %numEmptyCases, 0
  %1 = icmp eq i32 %whichCase, 0
  br i1 %1, label %2, label %3

2:                                                ; preds = %entry
  br i1 %.not, label %6, label %.sink.split

3:                                                ; preds = %entry
  %4 = add i32 %whichCase, -1
  %5 = zext i32 %4 to i128
  store i128 %5, ptr %value, align 4
  br i1 %.not, label %6, label %.sink.split

.sink.split:                                      ; preds = %3, %2
  %.sink = phi i8 [ 0, %2 ], [ 1, %3 ]
  store i8 %.sink, ptr %0, align 4
  br label %6

6:                                                ; preds = %.sink.split, %3, %2
  ret void
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe4RectVMa"(i64 %0) #7 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy13_4(ptr %0, ptr %1, ptr %2) #11 {
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 4 dereferenceable(13) %0, ptr noundef nonnull align 4 dereferenceable(13) %1, i64 13, i1 false)
  ret ptr %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %ProposedSize) #6 {
entry:
  %0 = icmp eq i32 %numEmptyCases, 0
  br i1 %0, label %9, label %1

1:                                                ; preds = %entry
  %2 = getelementptr inbounds nuw i8, ptr %value, i64 13
  %3 = load i8, ptr %2, align 1
  %4 = icmp eq i8 %3, 0
  br i1 %4, label %9, label %5

5:                                                ; preds = %1
  %6 = load i104, ptr %value, align 1
  %7 = trunc i104 %6 to i32
  %8 = add i32 %7, 1
  br label %9

9:                                                ; preds = %entry, %1, %5
  %10 = phi i32 [ %8, %5 ], [ 0, %1 ], [ 0, %entry ]
  ret i32 %10
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define internal void @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %ProposedSize) #12 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i64 13
  %.not = icmp eq i32 %numEmptyCases, 0
  %1 = icmp eq i32 %whichCase, 0
  br i1 %1, label %2, label %3

2:                                                ; preds = %entry
  br i1 %.not, label %6, label %.sink.split

3:                                                ; preds = %entry
  %4 = add i32 %whichCase, -1
  %5 = zext i32 %4 to i104
  store i104 %5, ptr %value, align 4
  br i1 %.not, label %6, label %.sink.split

.sink.split:                                      ; preds = %3, %2
  %.sink = phi i8 [ 0, %2 ], [ 1, %3 ]
  store i8 %.sink, ptr %0, align 1
  br label %6

6:                                                ; preds = %.sink.split, %3, %2
  ret void
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMa"(i64 %0) #7 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMa"(i64 %0) #7 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr }>, ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy1_1(ptr %0, ptr %1, ptr %2) #11 {
entry:
  %3 = load i8, ptr %1, align 1
  store i8 %3, ptr %0, align 1
  ret ptr %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %PointerPhase) #6 {
entry:
  %0 = icmp eq i32 %numEmptyCases, 0
  br i1 %0, label %34, label %1

1:                                                ; preds = %entry
  %2 = icmp ugt i32 %numEmptyCases, 253
  br i1 %2, label %3, label %28

3:                                                ; preds = %1
  %4 = add i32 %numEmptyCases, 2
  %5 = icmp ult i32 %4, 65280
  %6 = icmp ult i32 %4, 16776960
  %7 = select i1 %6, i32 2, i32 4
  %8 = select i1 %5, i32 1, i32 %7
  %9 = getelementptr inbounds nuw i8, ptr %value, i64 1
  switch i32 %8, label %18 [
    i32 4, label %16
    i32 1, label %10
    i32 2, label %13
  ]

10:                                               ; preds = %3
  %11 = load i8, ptr %9, align 1
  %12 = zext i8 %11 to i32
  br label %19

13:                                               ; preds = %3
  %14 = load i16, ptr %9, align 1
  %15 = zext i16 %14 to i32
  br label %19

16:                                               ; preds = %3
  %17 = load i32, ptr %9, align 1
  br label %19

18:                                               ; preds = %3
  unreachable

19:                                               ; preds = %16, %13, %10
  %20 = phi i32 [ %12, %10 ], [ %15, %13 ], [ %17, %16 ]
  %21 = icmp eq i32 %20, 0
  br i1 %21, label %28, label %22

22:                                               ; preds = %19
  %23 = shl i32 %20, 8
  %24 = load i8, ptr %value, align 1
  %25 = zext i8 %24 to i32
  %26 = add i32 %23, -3
  %27 = add i32 %26, %25
  br label %34

28:                                               ; preds = %19, %1
  %29 = load i8, ptr %value, align 1
  %30 = zext i8 %29 to i32
  %31 = add nsw i32 %30, -3
  %32 = icmp ult i8 %29, 3
  %33 = select i1 %32, i32 -1, i32 %31
  br label %34

34:                                               ; preds = %entry, %28, %22
  %35 = phi i32 [ %33, %28 ], [ %27, %22 ], [ -1, %entry ]
  %36 = add i32 %35, 1
  ret i32 %36
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define internal void @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %PointerPhase) #12 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i64 1
  %1 = icmp ugt i32 %numEmptyCases, 253
  br i1 %1, label %2, label %8

2:                                                ; preds = %entry
  %3 = add i32 %numEmptyCases, 2
  %4 = icmp ult i32 %3, 65280
  %5 = icmp ult i32 %3, 16776960
  %6 = select i1 %5, i32 2, i32 4
  %7 = select i1 %4, i32 1, i32 %6
  br label %8

8:                                                ; preds = %2, %entry
  %9 = phi i32 [ 0, %entry ], [ %7, %2 ]
  %10 = icmp ult i32 %whichCase, 254
  br i1 %10, label %11, label %21

11:                                               ; preds = %8
  switch i32 %9, label %15 [
    i32 0, label %16
    i32 1, label %12
    i32 2, label %13
    i32 4, label %14
  ]

12:                                               ; preds = %11
  store i8 0, ptr %0, align 1
  br label %16

13:                                               ; preds = %11
  store i16 0, ptr %0, align 1
  br label %16

14:                                               ; preds = %11
  store i32 0, ptr %0, align 1
  br label %16

15:                                               ; preds = %11
  unreachable

16:                                               ; preds = %11, %14, %13, %12
  %17 = icmp eq i32 %whichCase, 0
  br i1 %17, label %32, label %18

18:                                               ; preds = %16
  %19 = trunc nuw i32 %whichCase to i8
  %20 = add nuw i8 %19, 2
  store i8 %20, ptr %value, align 1
  br label %32

21:                                               ; preds = %8
  %22 = add i32 %whichCase, -254
  %23 = lshr i32 %22, 8
  %24 = add nuw nsw i32 %23, 1
  %25 = trunc i32 %22 to i8
  store i8 %25, ptr %value, align 1
  switch i32 %9, label %31 [
    i32 0, label %32
    i32 1, label %26
    i32 2, label %28
    i32 4, label %30
  ]

26:                                               ; preds = %21
  %27 = trunc i32 %24 to i8
  store i8 %27, ptr %0, align 1
  br label %32

28:                                               ; preds = %21
  %29 = trunc i32 %24 to i16
  store i16 %29, ptr %0, align 1
  br label %32

30:                                               ; preds = %21
  store i32 %24, ptr %0, align 1
  br label %32

31:                                               ; preds = %21
  unreachable

32:                                               ; preds = %26, %28, %30, %21, %18, %16
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal range(i32 0, 256) i32 @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwug"(ptr noalias readonly captures(none) %value, ptr readnone captures(none) %PointerPhase) #6 {
entry:
  %0 = load i8, ptr %value, align 1
  %1 = zext i8 %0 to i32
  ret i32 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define internal void @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwup"(ptr noalias readnone captures(none) %value, ptr readnone captures(none) %PointerPhase) #1 {
entry:
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define internal void @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwui"(ptr noalias writeonly captures(none) initializes((0, 1)) %value, i32 %tag, ptr readnone captures(none) %PointerPhase) #12 {
entry:
  %0 = trunc i32 %tag to i8
  store i8 %0, ptr %value, align 1
  ret void
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMa"(i64 %0) #7 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr }>, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMa"(i64 %0) #7 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, [4 x i8] }>, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMa"(i64 %0) #7 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, [4 x i8] }>, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMa"(i64 %0) #7 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, [4 x i8] }>, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMa"(i64 %0) #7 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, [4 x i8] }>, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: mustprogress nounwind willreturn
define internal nonnull ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVwCP"(ptr noalias writeonly captures(none) initializes((0, 8)) %dest, ptr noalias readonly captures(none) %src, ptr readnone captures(none) %NormalizedPointerEvent) #13 {
entry:
  %0 = load ptr, ptr %src, align 8
  store ptr %0, ptr %dest, align 8
  %1 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %2 = tail call ptr @swift_retain(ptr returned %0) #20
  ret ptr %1
}

; Function Attrs: mustprogress nounwind willreturn
declare ptr @swift_retain(ptr returned) local_unnamed_addr #14

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy28_4(ptr %0, ptr %1, ptr %2) #11 {
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 4 dereferenceable(28) %0, ptr noundef nonnull align 4 dereferenceable(28) %1, i64 28, i1 false)
  ret ptr %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %NormalizedPointerEvent) #6 {
entry:
  %0 = icmp eq i32 %numEmptyCases, 0
  br i1 %0, label %17, label %1

1:                                                ; preds = %entry
  %2 = icmp ugt i32 %numEmptyCases, 253
  br i1 %2, label %3, label %11

3:                                                ; preds = %1
  %4 = getelementptr inbounds nuw i8, ptr %value, i64 28
  %5 = load i8, ptr %4, align 1
  %6 = icmp eq i8 %5, 0
  br i1 %6, label %11, label %7

7:                                                ; preds = %3
  %8 = load i224, ptr %value, align 1
  %9 = trunc i224 %8 to i32
  %10 = add i32 %9, 253
  br label %17

11:                                               ; preds = %3, %1
  %12 = load i8, ptr %value, align 4
  %13 = zext i8 %12 to i32
  %14 = add nsw i32 %13, -3
  %15 = icmp ult i8 %12, 3
  %16 = select i1 %15, i32 -1, i32 %14
  br label %17

17:                                               ; preds = %entry, %11, %7
  %18 = phi i32 [ %16, %11 ], [ %10, %7 ], [ -1, %entry ]
  %19 = add i32 %18, 1
  ret i32 %19
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define internal void @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %NormalizedPointerEvent) #12 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i64 28
  %1 = icmp ugt i32 %numEmptyCases, 253
  %2 = icmp ult i32 %whichCase, 254
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
  %8 = trunc nuw i32 %whichCase to i8
  %9 = add nuw i8 %8, 2
  store i8 %9, ptr %value, align 4
  br label %15

10:                                               ; preds = %entry
  %11 = add i32 %whichCase, -254
  %12 = zext i32 %11 to i64
  store i64 %12, ptr %value, align 4
  %13 = getelementptr inbounds nuw i8, ptr %value, i64 8
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(20) %13, i8 0, i64 20, i1 false)
  br i1 %1, label %14, label %15

14:                                               ; preds = %10
  store i8 1, ptr %0, align 4
  br label %15

15:                                               ; preds = %10, %14, %7, %5
  ret void
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #15

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMa"(i64 %0) #7 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbeAAOMa"(i64 %0) #7 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr }>, ptr @"$s27GiftUIFoundationLayoutProbeAAOMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.fshl.i64(i64, i64, i64) #16

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.umin.i8(i8, i8) #16

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe5PointV1ys5Int32Vvg"(i64 %0) #1 {
  %2 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4SizeV6heights5Int32Vvg"(i64 %0) #1
  ret i32 %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i1 @"$s27GiftUIFoundationLayoutProbe5PointV23__derived_struct_equalsySbAC_ACtFZ"(i64 %0, i64 %1) #1 {
  %3 = tail call swiftcc i1 @"$s27GiftUIFoundationLayoutProbe4SizeV23__derived_struct_equalsySbAC_ACtFZ"(i64 %0, i64 %1) #1
  ret i1 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i1 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) #1 {
  %3 = tail call swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) #1
  ret i1 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i1 @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) #1 {
  %3 = tail call swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) #1
  ret i1 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal swiftcc i1 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(4) %0, ptr noalias readonly captures(none) dereferenceable(4) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %3, ptr readnone captures(none) %4) #6 {
  %6 = tail call swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(4) %0, ptr noalias readonly captures(none) dereferenceable(4) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %3, ptr readnone captures(none) %4) #6
  ret i1 %6
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal swiftcc i1 @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(4) %0, ptr noalias readonly captures(none) dereferenceable(4) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %3, ptr readnone captures(none) %4) #6 {
  %6 = tail call swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(4) %0, ptr noalias readonly captures(none) dereferenceable(4) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %3, ptr readnone captures(none) %4) #6
  ret i1 %6
}

define linkonce_odr hidden swiftcc i64 @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH13_rawHashValue4seedS2i_tFTW"(i64 %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #2 {
  %5 = tail call swiftcc i64 @20(i64 %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #2
  ret i64 %5
}

define linkonce_odr hidden swiftcc i64 @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASH13_rawHashValue4seedS2i_tFTW"(i64 %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #2 {
  %5 = tail call swiftcc i64 @20(i64 %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #2
  ret i64 %5
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH13_rawHashValue4seedS2i_tFTW"(i64 %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #2 {
  %5 = tail call swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH13_rawHashValue4seedS2i_tFTW"(i64 %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #2
  ret i64 %5
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASH13_rawHashValue4seedS2i_tFTW"(i64 %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #2 {
  %5 = tail call swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH13_rawHashValue4seedS2i_tFTW"(i64 %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #2
  ret i64 %5
}

define linkonce_odr hidden swiftcc void @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #2 {
  tail call swiftcc void @19(ptr captures(none) dereferenceable(72) %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #2
  ret void
}

define linkonce_odr hidden swiftcc void @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #2 {
  tail call swiftcc void @19(ptr captures(none) dereferenceable(72) %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define internal void @"$s27GiftUIFoundationLayoutProbe5PointVwst"(ptr noalias writeonly captures(none) %0, i32 %1, i32 %2, ptr readnone captures(none) %3) #12 {
  tail call void @"$s27GiftUIFoundationLayoutProbe4SizeVwst"(ptr noalias writeonly captures(none) %0, i32 %1, i32 %2, ptr readnone captures(none) %3) #12
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s27GiftUIFoundationLayoutProbe5PointVwet"(ptr noalias readonly captures(none) %0, i32 %1, ptr readnone captures(none) %2) #6 {
  %4 = tail call i32 @"$s27GiftUIFoundationLayoutProbe4SizeVwet"(ptr noalias readonly captures(none) %0, i32 %1, ptr readnone captures(none) %2) #6
  ret i32 %4
}

define swiftcc void @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) #2 {
  tail call swiftcc void @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) #2
  ret void
}

define swiftcc void @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) #2 {
  tail call swiftcc void @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) #2
  ret void
}

define internal swiftcc void @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #2 {
  tail call swiftcc void @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #2
  ret void
}

define internal swiftcc void @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #2 {
  tail call swiftcc void @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define swiftcc i32 @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32Vvg"(i64 %0) #1 {
  %2 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4SizeV5widths5Int32Vvg"(i64 %0) #1
  ret i32 %2
}

define linkonce_odr hidden swiftcc i1 @"$s27GiftUIFoundationLayoutProbe5PointVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias captures(none) dereferenceable(8) %0, ptr noalias captures(none) dereferenceable(8) %1, ptr swiftself %2, ptr %3, ptr %4) #2 {
  %6 = tail call swiftcc i1 @17(ptr noalias captures(none) dereferenceable(8) %0, ptr noalias captures(none) dereferenceable(8) %1, ptr swiftself %2, ptr %3, ptr %4) #2
  ret i1 %6
}

define linkonce_odr hidden swiftcc i1 @"$s27GiftUIFoundationLayoutProbe4SizeVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias captures(none) dereferenceable(8) %0, ptr noalias captures(none) dereferenceable(8) %1, ptr swiftself %2, ptr %3, ptr %4) #2 {
  %6 = tail call swiftcc i1 @17(ptr noalias captures(none) dereferenceable(8) %0, ptr noalias captures(none) dereferenceable(8) %1, ptr swiftself %2, ptr %3, ptr %4) #2
  ret i1 %6
}

define linkonce_odr hidden swiftcc i64 @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH9hashValueSivgTW"(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %1, ptr %2) #2 {
  %4 = tail call swiftcc i64 @18(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %1, ptr %2) #2
  ret i64 %4
}

define linkonce_odr hidden swiftcc i64 @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASH9hashValueSivgTW"(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %1, ptr %2) #2 {
  %4 = tail call swiftcc i64 @18(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %1, ptr %2) #2
  ret i64 %4
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH9hashValueSivgTW"(ptr noalias readonly swiftself captures(none) dereferenceable(4) %0, ptr readnone captures(none) %1, ptr readnone captures(none) %2) #2 {
  %4 = tail call swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH9hashValueSivgTW"(ptr noalias readonly swiftself captures(none) dereferenceable(4) %0, ptr readnone captures(none) %1, ptr readnone captures(none) %2) #2
  ret i64 %4
}

define internal swiftcc i64 @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASH9hashValueSivgTW"(ptr noalias readonly swiftself captures(none) dereferenceable(4) %0, ptr readnone captures(none) %1, ptr readnone captures(none) %2) #2 {
  %4 = tail call swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH9hashValueSivgTW"(ptr noalias readonly swiftself captures(none) dereferenceable(4) %0, ptr readnone captures(none) %1, ptr readnone captures(none) %2) #2
  ret i64 %4
}

define swiftcc void @"$s27GiftUIFoundationLayoutProbe5PointV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i64 %1) #2 {
  tail call swiftcc void @"$s27GiftUIFoundationLayoutProbe4SizeV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i64 %1) #2
  ret void
}

define swiftcc i64 @"$s27GiftUIFoundationLayoutProbe5PointV9hashValueSivg"(i64 %0) #2 {
  %2 = tail call swiftcc i64 @"$s27GiftUIFoundationLayoutProbe4SizeV9hashValueSivg"(i64 %0) #2
  ret i64 %2
}

define swiftcc i64 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV9hashValueSivg"(i32 %0) #2 {
  %2 = tail call swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV9hashValueSivg"(i32 %0) #2
  ret i64 %2
}

define swiftcc i64 @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV9hashValueSivg"(i32 %0) #2 {
  %2 = tail call swiftcc i64 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV9hashValueSivg"(i32 %0) #2
  ret i64 %2
}

attributes #0 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #2 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #3 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #5 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #6 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #7 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #8 = { nofree nosync nounwind memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #9 = { nofree noinline nosync nounwind memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #10 = { nofree nounwind memory(read) }
attributes #11 = { nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #12 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #13 = { mustprogress nounwind willreturn "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #14 = { mustprogress nounwind willreturn }
attributes #15 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #16 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #17 = { noinline }
attributes #18 = { nounwind memory(none) }
attributes #19 = { nounwind memory(read) }
attributes #20 = { nounwind willreturn }

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
