; ModuleID = '/Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/spec-002/b5140b92f857485cf83951780ae93eeda3d32336-87cad7ea9aed8edc/foundation-layout.ll'
source_filename = "/Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/spec-002/b5140b92f857485cf83951780ae93eeda3d32336-87cad7ea9aed8edc/foundation-layout.ll"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "armv6-unknown-linux-gnueabihf"

%swift.protocol = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i32, i32, i32, i32, i32, i32 }
%swift.method_descriptor = type { i32, i32 }
%swift.protocol_requirement = type { i32, i32 }
%swift.type_descriptor = type opaque
%swift.vwtable = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i32, i32, i32, i32 }
%swift.enum_vwtable = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, ptr, ptr }
%swift.type_metadata_record = type { i32 }
%swift.type = type { i32 }
%Ts6HasherV = type <{ %Ts6HasherV5_CoreV }>
%Ts6HasherV5_CoreV = type <{ %Ts6HasherV11_TailBufferV, %Ts6HasherV6_StateV }>
%Ts6HasherV11_TailBufferV = type <{ %Ts6UInt64V }>
%Ts6UInt64V = type <{ i64 }>
%Ts6HasherV6_StateV = type <{ %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V, %Ts6UInt64V }>
%T27GiftUIFoundationLayoutProbe4RectVSg = type <{ [16 x i8], [1 x i8] }>
%T27GiftUIFoundationLayoutProbe12PointerPhaseOSg = type <{ [1 x i8] }>
%Ts5UInt8V = type <{ i8 }>
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
%swift.metadata_response = type { ptr, i32 }

@"$sSQMp" = external global %swift.protocol, align 4
@"got.$sSQMp" = private unnamed_addr constant ptr @"$sSQMp"
@"$sSQ2eeoiySbx_xtFZTq" = external global %swift.method_descriptor, align 4
@"got.$sSQ2eeoiySbx_xtFZTq" = private unnamed_addr constant ptr @"$sSQ2eeoiySbx_xtFZTq"
@"$s27GiftUIFoundationLayoutProbe5PointVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 1, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAASQ2eeoiySbx_xtFZTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc", i32 0, i32 6) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc", i32 0, i32 10) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe5PointVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 4
@"associated conformance 27GiftUIFoundationLayoutProbe5PointVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAASQWb" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe5PointVSHAASQ", i32 0, i32 2) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
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
@"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 4, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHSQTb" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe5PointVSHAASQ", i32 1) to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 6) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 7) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH9hashValueSivgTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 8) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 9) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH4hash4intoys6HasherVz_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 10) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 11) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH13_rawHashValue4seedS2i_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 12) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", i32 0, i32 16) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 1, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAASQ2eeoiySbx_xtFZTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc", i32 0, i32 6) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc", i32 0, i32 10) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4SizeVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 4
@"associated conformance 27GiftUIFoundationLayoutProbe4SizeVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASQWb" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe4SizeVSHAASQ", i32 0, i32 2) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 4, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHSQTb" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe4SizeVSHAASQ", i32 1) to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 6) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 7) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASH9hashValueSivgTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 8) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 9) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASH4hash4intoys6HasherVz_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 10) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 11) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASH13_rawHashValue4seedS2i_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 12) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", i32 0, i32 16) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4RectVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 1, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAASQ2eeoiySbx_xtFZTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc", i32 0, i32 6) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc", i32 0, i32 10) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4RectVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 4
@"associated conformance 27GiftUIFoundationLayoutProbe4RectVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAASQWb" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe4RectVSHAASQ", i32 0, i32 2) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe4RectVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 4, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHSQTb" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe4RectVSHAASQ", i32 1) to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 6) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 7) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAASH9hashValueSivgTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 8) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 9) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAASH4hash4intoys6HasherVz_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 10) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 11) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAASH13_rawHashValue4seedS2i_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 12) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", i32 0, i32 16) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 1, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAASQ2eeoiySbx_xtFZTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc", i32 0, i32 6) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc", i32 0, i32 10) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 4
@"associated conformance 27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASQWb" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASQ", i32 0, i32 2) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 4, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHSQTb" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASQ", i32 1) to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 6) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 7) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASH9hashValueSivgTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 8) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 9) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASH4hash4intoys6HasherVz_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 10) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 11) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASH13_rawHashValue4seedS2i_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 12) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", i32 0, i32 16) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 4
@"associated conformance 27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASQWb" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASQ", i32 0, i32 2) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 4, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHSQTb" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASQ", i32 1) to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 6) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 7) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASH9hashValueSivgTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 8) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 9) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASH4hash4intoys6HasherVz_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 10) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 11) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASH13_rawHashValue4seedS2i_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 12) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", i32 0, i32 16) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$ss5UInt8VMn" = external global %swift.type_descriptor, align 4
@"got.$ss5UInt8VMn" = private unnamed_addr constant ptr @"$ss5UInt8VMn"
@"symbolic _____ s5UInt8V" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 sub (i32 ptrtoint (ptr @"got.$ss5UInt8VMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ s5UInt8V", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"symbolic _____ 27GiftUIFoundationLayoutProbe12PointerPhaseO" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12PointerPhaseO", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"symbolic $sSY" = linkonce_odr hidden constant <{ [4 x i8], i8 }> <{ [4 x i8] c"$sSY", i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@0 = private constant [9 x i8] c"RawValue\00", section "swift5_reflstr", no_sanitize_address
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMA" = internal constant { i32, i32, i32, i32, i32, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12PointerPhaseO" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMA" to i32)), i32 sub (i32 ptrtoint (ptr @"symbolic $sSY" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMA", i32 0, i32 1) to i32)), i32 1, i32 8, i32 sub (i32 ptrtoint (ptr @0 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMA", i32 0, i32 4) to i32)), i32 sub (i32 ptrtoint (ptr @"symbolic _____ s5UInt8V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMA", i32 0, i32 5) to i32)) }, section "swift5_assocty", no_sanitize_address, align 4
@"$sSYMp" = external global %swift.protocol, align 4
@"got.$sSYMp" = private unnamed_addr constant ptr @"$sSYMp"
@"$s8RawValueSYTl" = external global %swift.protocol_requirement, align 4
@"got.$s8RawValueSYTl" = private unnamed_addr constant ptr @"$s8RawValueSYTl"
@"$sSY8rawValuexSg03RawB0Qz_tcfCTq" = external global %swift.method_descriptor, align 4
@"got.$sSY8rawValuexSg03RawB0Qz_tcfCTq" = private unnamed_addr constant ptr @"$sSY8rawValuexSg03RawB0Qz_tcfCTq"
@"$sSY8rawValue03RawB0QzvgTq" = external global %swift.method_descriptor, align 4
@"got.$sSY8rawValue03RawB0QzvgTq" = private unnamed_addr constant ptr @"$sSY8rawValue03RawB0QzvgTq"
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSYMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 3, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$s8RawValueSYTl" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr getelementptr inbounds (i8, ptr @"symbolic _____ s5UInt8V", i32 1) to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 6) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSY8rawValuexSg03RawB0Qz_tcfCTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 7) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAASY8rawValuexSg03RawH0Qz_tcfCTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 8) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSY8rawValue03RawB0QzvgTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 9) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAASY8rawValue03RawH0QzvgTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 10) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", i32 0, i32 14) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 1, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAASQ2eeoiySbx_xtFZTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc", i32 0, i32 6) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc", i32 0, i32 10) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 1, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAASQ2eeoiySbx_xtFZTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc", i32 0, i32 6) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc", i32 0, i32 10) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 4
@"associated conformance 27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASQWb" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASQ", i32 0, i32 2) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 4, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHSQTb" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASQ", i32 1) to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 6) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 7) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASH9hashValueSivgTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 8) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 9) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASH4hash4intoys6HasherVz_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 10) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 11) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASH13_rawHashValue4seedS2i_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 12) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", i32 0, i32 16) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 1, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAASQ2eeoiySbx_xtFZTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc", i32 0, i32 6) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc", i32 0, i32 10) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 4
@"associated conformance 27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASQWb" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASQ", i32 0, i32 2) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 4, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHSQTb" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASQ", i32 1) to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 6) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 7) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH9hashValueSivgTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 8) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 9) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH4hash4intoys6HasherVz_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 10) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 11) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH13_rawHashValue4seedS2i_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 12) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", i32 0, i32 16) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 1, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAASQ2eeoiySbx_xtFZTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc", i32 0, i32 6) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc", i32 0, i32 10) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 4
@"associated conformance 27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASQWb" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASQ", i32 0, i32 2) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 4, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHSQTb" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASQ", i32 1) to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 6) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 7) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH9hashValueSivgTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 8) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 9) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH4hash4intoys6HasherVz_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 10) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 11) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH13_rawHashValue4seedS2i_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 12) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", i32 0, i32 16) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 1, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAASQ2eeoiySbx_xtFZTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc", i32 0, i32 6) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc", i32 0, i32 10) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVACSQAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 4
@"associated conformance 27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASQ" = linkonce_odr hidden constant <{ i8, i8, i32, i8 }> <{ i8 -1, i8 7, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASQWb" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i8, i32, i8 }>, ptr @"associated conformance 27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASQ", i32 0, i32 2) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 4, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSHSQTb" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr getelementptr (i8, ptr @"associated conformance 27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASQ", i32 1) to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 6) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH9hashValueSivgTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 7) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASH9hashValueSivgTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 8) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH4hash4intoys6HasherVz_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 9) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASH4hash4intoys6HasherVz_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 10) to i32)), i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSH13_rawHashValue4seedS2i_tFTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 11) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASH13_rawHashValue4seedS2i_tFTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 12) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", i32 0, i32 16) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc" = protected constant { i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQMp" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc" to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc", i32 0, i32 1) to i32)), i32 0, i32 196608, i32 1, i32 add (i32 sub (i32 ptrtoint (ptr @"got.$sSQ2eeoiySbx_xtFZTq" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc", i32 0, i32 5) to i32)), i32 1), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAASQ2eeoiySbx_xtFZTW" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc", i32 0, i32 6) to i32)), i16 0, i16 1, i32 0, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMcMK" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc", i32 0, i32 10) to i32)) }, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV" = protected unnamed_addr constant { i32 } zeroinitializer, align 4
@"$s27GiftUIFoundationLayoutProbe5PointVWV" = internal constant %swift.vwtable { ptr @__swift_memcpy8_4, ptr @__swift_noop_void_return, ptr @__swift_memcpy8_4, ptr @__swift_memcpy8_4, ptr @__swift_memcpy8_4, ptr @__swift_memcpy8_4, ptr @"$s27GiftUIFoundationLayoutProbe5PointVwet", ptr @"$s27GiftUIFoundationLayoutProbe5PointVwst", i32 8, i32 8, i32 3, i32 0 }, align 4
@.str.27.GiftUIFoundationLayoutProbe = private constant [28 x i8] c"GiftUIFoundationLayoutProbe\00"
@"$s27GiftUIFoundationLayoutProbeMXM" = linkonce_odr hidden constant <{ i32, i32, i32 }> <{ i32 0, i32 0, i32 sub (i32 ptrtoint (ptr @.str.27.GiftUIFoundationLayoutProbe to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbeMXM", i32 0, i32 2) to i32)) }>, section ".rodata", no_sanitize_address, align 4
@.str.5.Point = private constant [6 x i8] c"Point\00"
@"$s27GiftUIFoundationLayoutProbe5PointVMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.5.Point to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn", i32 0, i32 4) to i32)), i32 2, i32 2 }>, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe5PointVMf" = internal constant <{ ptr, ptr, i32, ptr, i32, i32 }> <{ ptr null, ptr @"$s27GiftUIFoundationLayoutProbe5PointVWV", i32 512, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn", i32 0, i32 4 }>, align 4
@"symbolic _____ 27GiftUIFoundationLayoutProbe5PointV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe5PointV", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$ss5Int32VMn" = external global %swift.type_descriptor, align 4
@"got.$ss5Int32VMn" = private unnamed_addr constant ptr @"$ss5Int32VMn"
@"symbolic _____ s5Int32V" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 sub (i32 ptrtoint (ptr @"got.$ss5Int32VMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ s5Int32V", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@1 = private constant [2 x i8] c"x\00", section "swift5_reflstr", no_sanitize_address
@2 = private constant [2 x i8] c"y\00", section "swift5_reflstr", no_sanitize_address
@"$s27GiftUIFoundationLayoutProbe5PointVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe5PointV" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVMF" to i32)), i32 0, i16 0, i16 12, i32 2, i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ s5Int32V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMF", i32 0, i32 6) to i32)), i32 sub (i32 ptrtoint (ptr @1 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMF", i32 0, i32 7) to i32)), i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ s5Int32V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMF", i32 0, i32 9) to i32)), i32 sub (i32 ptrtoint (ptr @2 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMF", i32 0, i32 10) to i32)) }, section "swift5_fieldmd", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4SizeVWV" = internal constant %swift.vwtable { ptr @__swift_memcpy8_4, ptr @__swift_noop_void_return, ptr @__swift_memcpy8_4, ptr @__swift_memcpy8_4, ptr @__swift_memcpy8_4, ptr @__swift_memcpy8_4, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVwet", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVwst", i32 8, i32 8, i32 3, i32 0 }, align 4
@.str.4.Size = private constant [5 x i8] c"Size\00"
@"$s27GiftUIFoundationLayoutProbe4SizeVMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.4.Size to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn", i32 0, i32 4) to i32)), i32 2, i32 2 }>, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4SizeVMf" = internal constant <{ ptr, ptr, i32, ptr, i32, i32 }> <{ ptr null, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVWV", i32 512, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn", i32 0, i32 4 }>, align 4
@"symbolic _____ 27GiftUIFoundationLayoutProbe4SizeV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe4SizeV", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@3 = private constant [6 x i8] c"width\00", section "swift5_reflstr", no_sanitize_address
@4 = private constant [7 x i8] c"height\00", section "swift5_reflstr", no_sanitize_address
@"$s27GiftUIFoundationLayoutProbe4SizeVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe4SizeV" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMF" to i32)), i32 0, i16 0, i16 12, i32 2, i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ s5Int32V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMF", i32 0, i32 6) to i32)), i32 sub (i32 ptrtoint (ptr @3 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMF", i32 0, i32 7) to i32)), i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ s5Int32V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMF", i32 0, i32 9) to i32)), i32 sub (i32 ptrtoint (ptr @4 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMF", i32 0, i32 10) to i32)) }, section "swift5_fieldmd", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4RectVWV" = internal constant %swift.vwtable { ptr @"$s27GiftUIFoundationLayoutProbe4RectVwCP", ptr @__swift_noop_void_return, ptr @__swift_memcpy16_4, ptr @__swift_memcpy16_4, ptr @__swift_memcpy16_4, ptr @__swift_memcpy16_4, ptr @"$s27GiftUIFoundationLayoutProbe4RectVwet", ptr @"$s27GiftUIFoundationLayoutProbe4RectVwst", i32 16, i32 16, i32 131075, i32 0 }, align 4
@.str.4.Rect = private constant [5 x i8] c"Rect\00"
@"$s27GiftUIFoundationLayoutProbe4RectVMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.4.Rect to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn", i32 0, i32 4) to i32)), i32 2, i32 2 }>, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4RectVMf" = internal constant <{ ptr, ptr, i32, ptr, i32, i32 }> <{ ptr null, ptr @"$s27GiftUIFoundationLayoutProbe4RectVWV", i32 512, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn", i32 0, i32 8 }>, align 4
@"symbolic _____ 27GiftUIFoundationLayoutProbe4RectV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe4RectV", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@5 = private constant [7 x i8] c"origin\00", section "swift5_reflstr", no_sanitize_address
@6 = private constant [5 x i8] c"size\00", section "swift5_reflstr", no_sanitize_address
@"$s27GiftUIFoundationLayoutProbe4RectVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe4RectV" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVMF" to i32)), i32 0, i16 0, i16 12, i32 2, i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe5PointV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMF", i32 0, i32 6) to i32)), i32 sub (i32 ptrtoint (ptr @5 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMF", i32 0, i32 7) to i32)), i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe4SizeV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMF", i32 0, i32 9) to i32)), i32 sub (i32 ptrtoint (ptr @6 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMF", i32 0, i32 10) to i32)) }, section "swift5_fieldmd", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVWV" = internal constant %swift.vwtable { ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVwCP", ptr @__swift_noop_void_return, ptr @__swift_memcpy13_4, ptr @__swift_memcpy13_4, ptr @__swift_memcpy13_4, ptr @__swift_memcpy13_4, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVwet", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVwst", i32 13, i32 16, i32 131075, i32 0 }, align 4
@.str.12.ProposedSize = private constant [13 x i8] c"ProposedSize\00"
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.12.ProposedSize to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn", i32 0, i32 4) to i32)), i32 2, i32 2 }>, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMf" = internal constant <{ ptr, ptr, i32, ptr, i32, i32 }> <{ ptr null, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVWV", i32 512, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn", i32 0, i32 8 }>, align 4
@"symbolic _____ 27GiftUIFoundationLayoutProbe12ProposedSizeV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12ProposedSizeV", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"symbolic _____Sg s5Int32V" = linkonce_odr hidden constant <{ i8, i32, [2 x i8], i8 }> <{ i8 2, i32 sub (i32 ptrtoint (ptr @"got.$ss5Int32VMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, [2 x i8], i8 }>, ptr @"symbolic _____Sg s5Int32V", i32 0, i32 1) to i32)), [2 x i8] c"Sg", i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12ProposedSizeV" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF" to i32)), i32 0, i16 0, i16 12, i32 2, i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____Sg s5Int32V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF", i32 0, i32 6) to i32)), i32 sub (i32 ptrtoint (ptr @3 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF", i32 0, i32 7) to i32)), i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____Sg s5Int32V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF", i32 0, i32 9) to i32)), i32 sub (i32 ptrtoint (ptr @4 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF", i32 0, i32 10) to i32)) }, section "swift5_fieldmd", no_sanitize_address, align 4
@"$sytWV" = external global ptr, align 4
@.str.18.GeometryArithmetic = private constant [19 x i8] c"GeometryArithmetic\00"
@"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 82, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.18.GeometryArithmetic to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn", i32 0, i32 4) to i32)), i32 0, i32 0 }>, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMf" = internal constant <{ ptr, ptr, i32, ptr }> <{ ptr null, ptr @"$sytWV", i32 513, ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn" }>, align 4
@"symbolic _____ 27GiftUIFoundationLayoutProbe18GeometryArithmeticO" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe18GeometryArithmeticO", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMF" = internal constant { i32, i32, i16, i16, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe18GeometryArithmeticO" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMF" to i32)), i32 0, i16 2, i16 12, i32 0 }, section "swift5_fieldmd", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOWV" = internal constant %swift.enum_vwtable { ptr @__swift_memcpy1_1, ptr @__swift_noop_void_return, ptr @__swift_memcpy1_1, ptr @__swift_memcpy1_1, ptr @__swift_memcpy1_1, ptr @__swift_memcpy1_1, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwet", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwst", i32 1, i32 1, i32 2097152, i32 253, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwug", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwup", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwui" }, align 4
@.str.12.PointerPhase = private constant [13 x i8] c"PointerPhase\00"
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 82, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.12.PointerPhase to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn", i32 0, i32 4) to i32)), i32 0, i32 3 }>, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMf" = internal constant <{ ptr, ptr, i32, ptr }> <{ ptr null, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOWV", i32 513, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn" }>, align 4
@7 = private constant [5 x i8] c"down\00", section "swift5_reflstr", no_sanitize_address
@8 = private constant [5 x i8] c"move\00", section "swift5_reflstr", no_sanitize_address
@9 = private constant [3 x i8] c"up\00", section "swift5_reflstr", no_sanitize_address
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12PointerPhaseO" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMF" to i32)), i32 0, i16 2, i16 12, i32 3, i32 0, i32 0, i32 sub (i32 ptrtoint (ptr @7 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMF", i32 0, i32 7) to i32)), i32 0, i32 0, i32 sub (i32 ptrtoint (ptr @8 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMF", i32 0, i32 10) to i32)), i32 0, i32 0, i32 sub (i32 ptrtoint (ptr @9 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMF", i32 0, i32 13) to i32)) }, section "swift5_fieldmd", no_sanitize_address, align 4
@"$sBi16_WV" = external global ptr, align 4
@.str.13.InputSourceID = private constant [14 x i8] c"InputSourceID\00"
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.13.InputSourceID to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn", i32 0, i32 4) to i32)), i32 1, i32 2 }>, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMf" = internal constant <{ ptr, ptr, i32, ptr, i32 }> <{ ptr null, ptr @"$sBi16_WV", i32 512, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn", i32 0 }>, align 4
@"symbolic _____ 27GiftUIFoundationLayoutProbe13InputSourceIDV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe13InputSourceIDV", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$ss6UInt16VMn" = external global %swift.type_descriptor, align 4
@"got.$ss6UInt16VMn" = private unnamed_addr constant ptr @"$ss6UInt16VMn"
@"symbolic _____ s6UInt16V" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 sub (i32 ptrtoint (ptr @"got.$ss6UInt16VMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ s6UInt16V", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@10 = private constant [9 x i8] c"rawValue\00", section "swift5_reflstr", no_sanitize_address
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe13InputSourceIDV" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMF" to i32)), i32 0, i16 0, i16 12, i32 1, i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ s6UInt16V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMF", i32 0, i32 6) to i32)), i32 sub (i32 ptrtoint (ptr @10 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMF", i32 0, i32 7) to i32)) }, section "swift5_fieldmd", no_sanitize_address, align 4
@"$sBi32_WV" = external global ptr, align 4
@.str.17.PointerSequenceID = private constant [18 x i8] c"PointerSequenceID\00"
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.17.PointerSequenceID to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn", i32 0, i32 4) to i32)), i32 1, i32 2 }>, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMf" = internal constant <{ ptr, ptr, i32, ptr, i32 }> <{ ptr null, ptr @"$sBi32_WV", i32 512, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn", i32 0 }>, align 4
@"symbolic _____ 27GiftUIFoundationLayoutProbe17PointerSequenceIDV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe17PointerSequenceIDV", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$ss6UInt32VMn" = external global %swift.type_descriptor, align 4
@"got.$ss6UInt32VMn" = private unnamed_addr constant ptr @"$ss6UInt32VMn"
@"symbolic _____ s6UInt32V" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 sub (i32 ptrtoint (ptr @"got.$ss6UInt32VMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ s6UInt32V", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe17PointerSequenceIDV" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMF" to i32)), i32 0, i16 0, i16 12, i32 1, i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMF", i32 0, i32 6) to i32)), i32 sub (i32 ptrtoint (ptr @10 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMF", i32 0, i32 7) to i32)) }, section "swift5_fieldmd", no_sanitize_address, align 4
@.str.12.InputOrdinal = private constant [13 x i8] c"InputOrdinal\00"
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.12.InputOrdinal to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn", i32 0, i32 4) to i32)), i32 1, i32 2 }>, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMf" = internal constant <{ ptr, ptr, i32, ptr, i32 }> <{ ptr null, ptr @"$sBi32_WV", i32 512, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn", i32 0 }>, align 4
@"symbolic _____ 27GiftUIFoundationLayoutProbe12InputOrdinalV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12InputOrdinalV", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12InputOrdinalV" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMF" to i32)), i32 0, i16 0, i16 12, i32 1, i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMF", i32 0, i32 6) to i32)), i32 sub (i32 ptrtoint (ptr @10 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMF", i32 0, i32 7) to i32)) }, section "swift5_fieldmd", no_sanitize_address, align 4
@.str.20.PresentationRevision = private constant [21 x i8] c"PresentationRevision\00"
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.20.PresentationRevision to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn", i32 0, i32 4) to i32)), i32 1, i32 2 }>, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMf" = internal constant <{ ptr, ptr, i32, ptr, i32 }> <{ ptr null, ptr @"$sBi32_WV", i32 512, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn", i32 0 }>, align 4
@"symbolic _____ 27GiftUIFoundationLayoutProbe20PresentationRevisionV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe20PresentationRevisionV", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe20PresentationRevisionV" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMF" to i32)), i32 0, i16 0, i16 12, i32 1, i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ s6UInt32V" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMF", i32 0, i32 6) to i32)), i32 sub (i32 ptrtoint (ptr @10 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMF", i32 0, i32 7) to i32)) }, section "swift5_fieldmd", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVWV" = internal constant %swift.vwtable { ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVwCP", ptr @__swift_noop_void_return, ptr @__swift_memcpy28_4, ptr @__swift_memcpy28_4, ptr @__swift_memcpy28_4, ptr @__swift_memcpy28_4, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVwet", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVwst", i32 28, i32 28, i32 131075, i32 253 }, align 4
@.str.22.NormalizedPointerEvent = private constant [23 x i8] c"NormalizedPointerEvent\00"
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.22.NormalizedPointerEvent to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn", i32 0, i32 4) to i32)), i32 6, i32 2 }>, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMf" = internal constant <{ ptr, ptr, i32, ptr, i32, i32, i32, i32, i32, i32 }> <{ ptr null, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVWV", i32 512, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn", i32 0, i32 4, i32 12, i32 16, i32 20, i32 24 }>, align 4
@"symbolic _____ 27GiftUIFoundationLayoutProbe22NormalizedPointerEventV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe22NormalizedPointerEventV", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@11 = private constant [6 x i8] c"phase\00", section "swift5_reflstr", no_sanitize_address
@12 = private constant [9 x i8] c"position\00", section "swift5_reflstr", no_sanitize_address
@13 = private constant [7 x i8] c"source\00", section "swift5_reflstr", no_sanitize_address
@14 = private constant [9 x i8] c"sequence\00", section "swift5_reflstr", no_sanitize_address
@15 = private constant [8 x i8] c"ordinal\00", section "swift5_reflstr", no_sanitize_address
@16 = private constant [21 x i8] c"presentationRevision\00", section "swift5_reflstr", no_sanitize_address
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe22NormalizedPointerEventV" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF" to i32)), i32 0, i16 0, i16 12, i32 6, i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12PointerPhaseO" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 6) to i32)), i32 sub (i32 ptrtoint (ptr @11 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 7) to i32)), i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe5PointV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 9) to i32)), i32 sub (i32 ptrtoint (ptr @12 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 10) to i32)), i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe13InputSourceIDV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 12) to i32)), i32 sub (i32 ptrtoint (ptr @13 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 13) to i32)), i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe17PointerSequenceIDV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 15) to i32)), i32 sub (i32 ptrtoint (ptr @14 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 16) to i32)), i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe12InputOrdinalV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 18) to i32)), i32 sub (i32 ptrtoint (ptr @15 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 19) to i32)), i32 0, i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbe20PresentationRevisionV" to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 21) to i32)), i32 sub (i32 ptrtoint (ptr @16 to i32), i32 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", i32 0, i32 22) to i32)) }, section "swift5_fieldmd", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbeAAOMn" = protected constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 82, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeMXM" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbeAAOMn", i32 0, i32 1) to i32)), i32 sub (i32 ptrtoint (ptr @.str.27.GiftUIFoundationLayoutProbe to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbeAAOMn", i32 0, i32 2) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeAAOMa" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbeAAOMn", i32 0, i32 3) to i32)), i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeAAOMF" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbeAAOMn", i32 0, i32 4) to i32)), i32 0, i32 0 }>, section ".rodata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbeAAOMf" = internal constant <{ ptr, ptr, i32, ptr }> <{ ptr null, ptr @"$sytWV", i32 513, ptr @"$s27GiftUIFoundationLayoutProbeAAOMn" }>, align 4
@"symbolic _____ 27GiftUIFoundationLayoutProbeAAO" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeAAOMn" to i32), i32 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 27GiftUIFoundationLayoutProbeAAO", i32 0, i32 1) to i32)), i8 0 }>, section "swift5_typeref", no_sanitize_address, align 2
@"$s27GiftUIFoundationLayoutProbeAAOMF" = internal constant { i32, i32, i16, i16, i32 } { i32 sub (i32 ptrtoint (ptr @"symbolic _____ 27GiftUIFoundationLayoutProbeAAO" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeAAOMF" to i32)), i32 0, i16 2, i16 12, i32 0 }, section "swift5_fieldmd", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe5PointVSQAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe5PointVSHAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4SizeVSQAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4SizeVSHAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4RectVSQAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4RectVSHAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAHc" = private constant i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAHc" to i32)), section "swift5_protocol_conformances", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe5PointVHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe5PointVHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4SizeVHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4SizeVHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe4RectVHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe4RectVHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseOHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@"$s27GiftUIFoundationLayoutProbeAAOHn" = private constant %swift.type_metadata_record { i32 sub (i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeAAOMn" to i32), i32 ptrtoint (ptr @"$s27GiftUIFoundationLayoutProbeAAOHn" to i32)) }, section "swift5_type_metadata", no_sanitize_address, align 4
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@_swift1_autolink_entries = private constant [77 x i8] c"-lswift_Concurrency\00-lswiftCore\00-lswift_StringProcessing\00-lswift_RegexParser\00", section ".swift1_autolink_entries", no_sanitize_address, align 4
@llvm.used = appending global [199 x ptr] [ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV8rawValueACs6UInt32V_tcfC", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV8rawValues6UInt32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVHn", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMF", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMa", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMn", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVN", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseO8rawValueACSgs5UInt8V_tcfC", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseO8rawValues5UInt8Vvg", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOHn", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMF", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMa", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMn", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseON", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAHc", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMA", ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAAMc", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV5width6heightACSgs5Int32VSg_AItcfC", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV5widths5Int32VSgvg", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV6heights5Int32VSgvg", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVHn", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMF", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMa", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMn", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVN", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV8rawValueACs6UInt16V_tcfC", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV8rawValues6UInt16Vvg", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVHn", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMF", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMa", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMn", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVN", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV8rawValueACs6UInt32V_tcfC", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV8rawValues6UInt32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVHn", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMF", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMa", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMn", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVN", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticO3addys5Int32VSgAF_AFtFZ", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticO8multiplyys5Int32VSgAF_AFtFZ", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticO8subtractys5Int32VSgAF_AFtFZ", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOHn", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMF", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMa", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMn", ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticON", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV8rawValueACs6UInt32V_tcfC", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV8rawValues6UInt32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVHn", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMF", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMa", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMn", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVN", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV20presentationRevisionAA012PresentationI0Vvg", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV5phase8position6source8sequence7ordinal20presentationRevisionAcA0F5PhaseO_AA5PointVAA13InputSourceIDVAA0f8SequenceS0VAA0Q7OrdinalVAA012PresentationN0VtcfC", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV5phaseAA0F5PhaseOvg", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV6sourceAA13InputSourceIDVvg", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV7ordinalAA12InputOrdinalVvg", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV8positionAA5PointVvg", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV8sequenceAA0F10SequenceIDVvg", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVHn", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMF", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMa", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMn", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVN", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe4RectV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe4RectV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe4RectV4maxXs5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe4RectV4maxYs5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe4RectV4minXs5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe4RectV4minYs5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe4RectV4sizeAA4SizeVvg", ptr @"$s27GiftUIFoundationLayoutProbe4RectV6origin4sizeACSgAA5PointV_AA4SizeVtcfC", ptr @"$s27GiftUIFoundationLayoutProbe4RectV6originAA5PointVvg", ptr @"$s27GiftUIFoundationLayoutProbe4RectV8containsySbAA5PointVF", ptr @"$s27GiftUIFoundationLayoutProbe4RectV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe4RectVHn", ptr @"$s27GiftUIFoundationLayoutProbe4RectVMF", ptr @"$s27GiftUIFoundationLayoutProbe4RectVMa", ptr @"$s27GiftUIFoundationLayoutProbe4RectVMn", ptr @"$s27GiftUIFoundationLayoutProbe4RectVN", ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe4SizeV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe4SizeV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe4SizeV5width6heightACSgs5Int32V_AHtcfC", ptr @"$s27GiftUIFoundationLayoutProbe4SizeV5widths5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe4SizeV6heights5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe4SizeV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVHn", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMF", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMa", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMn", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVN", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbe5PointV1x1yACs5Int32V_AGtcfC", ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV", ptr @"$s27GiftUIFoundationLayoutProbe5PointV1ys5Int32Vvg", ptr @"$s27GiftUIFoundationLayoutProbe5PointV23__derived_struct_equalsySbAC_ACtFZ", ptr @"$s27GiftUIFoundationLayoutProbe5PointV4hash4intoys6HasherVz_tF", ptr @"$s27GiftUIFoundationLayoutProbe5PointV9hashValueSivg", ptr @"$s27GiftUIFoundationLayoutProbe5PointVHn", ptr @"$s27GiftUIFoundationLayoutProbe5PointVMF", ptr @"$s27GiftUIFoundationLayoutProbe5PointVMa", ptr @"$s27GiftUIFoundationLayoutProbe5PointVMn", ptr @"$s27GiftUIFoundationLayoutProbe5PointVN", ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAHc", ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAAMc", ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAHc", ptr @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc", ptr @"$s27GiftUIFoundationLayoutProbeAAO10rectStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO10sizeStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO11pointStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO13rectAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO13sizeAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO14pointAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO14proposedStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO16inputOrdinalSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO16pointerPhaseSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO16proposedByteSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO17inputSourceIDSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO17proposedAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO18geometryScalarSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO18inputOrdinalStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO18pointerPhaseStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO19inputSourceIDStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO20geometryScalarStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO21inputOrdinalAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO21pointerPhaseAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO21pointerSequenceIDSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO22inputSourceIDAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO23geometryScalarAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO23pointerSequenceIDStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO24presentationRevisionSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO26normalizedPointerEventSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO26pointerSequenceIDAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO26presentationRevisionStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO28normalizedPointerEventStrides6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO29presentationRevisionAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO31normalizedPointerEventAlignments6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO8rectSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO8sizeSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAO9pointSizes6UInt32VyFZ", ptr @"$s27GiftUIFoundationLayoutProbeAAOHn", ptr @"$s27GiftUIFoundationLayoutProbeAAOMF", ptr @"$s27GiftUIFoundationLayoutProbeAAOMa", ptr @"$s27GiftUIFoundationLayoutProbeAAOMn", ptr @"$s27GiftUIFoundationLayoutProbeAAON", ptr @__swift_reflection_version, ptr @_swift1_autolink_entries], section "llvm.metadata"

@"$s27GiftUIFoundationLayoutProbe5PointV1ys5Int32VvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe5PointV9hashValueSivpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4SizeV5widths5Int32VvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4SizeV6heights5Int32VvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4SizeV9hashValueSivpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4RectV6originAA5PointVvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4RectV4sizeAA4SizeVvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4RectV4minXs5Int32VvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4RectV4minYs5Int32VvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4RectV4maxXs5Int32VvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4RectV4maxYs5Int32VvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe4RectV9hashValueSivpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeV5widths5Int32VSgvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeV6heights5Int32VSgvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeV9hashValueSivpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseO8rawValues5UInt8VvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDV8rawValues6UInt16VvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDV9hashValueSivpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV8rawValues6UInt32VvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV9hashValueSivpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalV8rawValues6UInt32VvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalV9hashValueSivpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV8rawValues6UInt32VvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV9hashValueSivpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV5phaseAA0F5PhaseOvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV8positionAA5PointVvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV6sourceAA13InputSourceIDVvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV8sequenceAA0F10SequenceIDVvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV7ordinalAA12InputOrdinalVvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV20presentationRevisionAA012PresentationI0VvpMV" = protected alias { i32 }, ptr @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32VvpMV"
@"$s27GiftUIFoundationLayoutProbe5PointVN" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe4SizeVN" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe4RectVN" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe12ProposedSizeVN" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticON" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr }>, ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe12PointerPhaseON" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr }>, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe13InputSourceIDVN" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVN" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe12InputOrdinalVN" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVN" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVN" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMf", i32 0, i32 2)
@"$s27GiftUIFoundationLayoutProbeAAON" = protected alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i32, ptr }>, ptr @"$s27GiftUIFoundationLayoutProbeAAOMf", i32 0, i32 2)

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe5PointV1xs5Int32Vvg"(i32 returned %0, i32 %1) #0 {
entry:
  ret i32 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe5PointV1ys5Int32Vvg"(i32 %0, i32 returned %1) #0 {
entry:
  ret i32 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc { i32, i32 } @"$s27GiftUIFoundationLayoutProbe5PointV1x1yACs5Int32V_AGtcfC"(i32 %0, i32 %1) #0 {
entry:
  %2 = insertvalue { i32, i32 } undef, i32 %0, 0
  %3 = insertvalue { i32, i32 } %2, i32 %1, 1
  ret { i32, i32 } %3
}

declare swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32, ptr swiftself captures(none) dereferenceable(72)) local_unnamed_addr #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #2

declare swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias sret(%Ts6HasherV) captures(none), i32) local_unnamed_addr #1

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i32(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i32, i1 immarg) #3

declare swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr swiftself captures(none) dereferenceable(72)) local_unnamed_addr #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #2

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4SizeV5widths5Int32Vvg"(i32 returned %0, i32 %1) #0 {
entry:
  ret i32 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4SizeV6heights5Int32Vvg"(i32 %0, i32 returned %1) #0 {
entry:
  ret i32 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc { i32, i32, i8 } @"$s27GiftUIFoundationLayoutProbe4SizeV5width6heightACSgs5Int32V_AHtcfC"(i32 %0, i32 %1) #0 {
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

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i1 @"$s27GiftUIFoundationLayoutProbe4SizeV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1, i32 %2, i32 %3) #0 {
entry:
  %4 = icmp eq i32 %0, %2
  %5 = icmp eq i32 %1, %3
  %spec.select = select i1 %4, i1 %5, i1 false
  ret i1 %spec.select
}

define protected swiftcc void @"$s27GiftUIFoundationLayoutProbe4SizeV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1, i32 %2) #1 {
entry:
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  ret void
}

define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4SizeV9hashValueSivg"(i32 %0, i32 %1) #1 {
  %3 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe5PointV9hashValueSivgTm"(i32 %0, i32 %1) #1
  ret i32 %3
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe5PointV9hashValueSivgTm"(i32 %0, i32 %1) #1 {
entry:
  %2 = alloca %Ts6HasherV, align 8
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %2)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %2, i32 0)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %0, ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  %3 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %2)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %2)
  ret i32 %3
}

define private swiftcc i1 @17(ptr noalias captures(none) dereferenceable(8) %0, ptr noalias captures(none) dereferenceable(8) %1, ptr swiftself %2, ptr %Self, ptr %SelfWitnessTable) #1 {
entry:
  %3 = load i32, ptr %0, align 4
  %4 = load i32, ptr %1, align 4
  %5 = icmp eq i32 %3, %4
  br i1 %5, label %6, label %10

6:                                                ; preds = %entry
  %.height2 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %7 = load i32, ptr %.height2, align 4
  %.height = getelementptr inbounds nuw i8, ptr %0, i32 4
  %8 = load i32, ptr %.height, align 4
  %9 = icmp eq i32 %8, %7
  br label %10

10:                                               ; preds = %entry, %6
  %11 = phi i1 [ %9, %6 ], [ false, %entry ]
  ret i1 %11
}

define private swiftcc i32 @18(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %Self, ptr %SelfWitnessTable) #1 {
  %2 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH9hashValueSivgTWTm"(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %Self, ptr %SelfWitnessTable) #1
  ret i32 %2
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH9hashValueSivgTWTm"(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %1, ptr %2) #1 {
entry:
  %3 = alloca %Ts6HasherV, align 8
  %4 = load i32, ptr %0, align 4
  %.y = getelementptr inbounds nuw i8, ptr %0, i32 4
  %5 = load i32, ptr %.y, align 4
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %3)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %3, i32 0) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %4, ptr nonnull swiftself captures(none) dereferenceable(72) %3) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %5, ptr nonnull swiftself captures(none) dereferenceable(72) %3) #18
  %6 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %3) #18
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %3)
  ret i32 %6
}

define private swiftcc void @19(ptr captures(none) dereferenceable(72) %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %Self, ptr %SelfWitnessTable) #1 {
entry:
  %2 = load i32, ptr %1, align 4
  %.height = getelementptr inbounds nuw i8, ptr %1, i32 4
  %3 = load i32, ptr %.height, align 4
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  ret void
}

define private swiftcc i32 @20(i32 %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %Self, ptr %SelfWitnessTable) #1 {
  %3 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH13_rawHashValue4seedS2i_tFTWTm"(i32 %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %Self, ptr %SelfWitnessTable) #1
  ret i32 %3
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH13_rawHashValue4seedS2i_tFTWTm"(i32 %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #1 {
entry:
  %4 = alloca %Ts6HasherV, align 8
  %5 = load i32, ptr %1, align 4
  %.y = getelementptr inbounds nuw i8, ptr %1, i32 4
  %6 = load i32, ptr %.y, align 4
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %4)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %4, i32 %0) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %5, ptr nonnull swiftself captures(none) dereferenceable(72) %4) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %6, ptr nonnull swiftself captures(none) dereferenceable(72) %4) #18
  %7 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %4) #18
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %4)
  ret i32 %7
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc { i32, i32 } @"$s27GiftUIFoundationLayoutProbe4RectV6originAA5PointVvg"(i32 %0, i32 %1, i32 %2, i32 %3) #0 {
entry:
  %4 = insertvalue { i32, i32 } undef, i32 %0, 0
  %5 = insertvalue { i32, i32 } %4, i32 %1, 1
  ret { i32, i32 } %5
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc { i32, i32 } @"$s27GiftUIFoundationLayoutProbe4RectV4sizeAA4SizeVvg"(i32 %0, i32 %1, i32 %2, i32 %3) #0 {
entry:
  %4 = insertvalue { i32, i32 } undef, i32 %2, 0
  %5 = insertvalue { i32, i32 } %4, i32 %3, 1
  ret { i32, i32 } %5
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s27GiftUIFoundationLayoutProbe4RectV6origin4sizeACSgAA5PointV_AA4SizeVtcfC"(ptr noalias writeonly sret(%T27GiftUIFoundationLayoutProbe4RectVSg) captures(none) initializes((0, 17)) %0, i32 %1, i32 %2, i32 %3, i32 %4) #4 {
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

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32) #5

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc { i32, i8 } @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticO3addys5Int32VSgAF_AFtFZ"(i32 %0, i32 %1) #0 {
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

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4RectV4minXs5Int32Vvg"(i32 returned %0, i32 %1, i32 %2, i32 %3) #0 {
entry:
  ret i32 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4RectV4minYs5Int32Vvg"(i32 %0, i32 returned %1, i32 %2, i32 %3) #0 {
entry:
  ret i32 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4RectV4maxXs5Int32Vvg"(i32 %0, i32 %1, i32 %2, i32 %3) #0 {
entry:
  %4 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %0, i32 %2)
  %5 = extractvalue { i32, i1 } %4, 0
  %6 = extractvalue { i32, i1 } %4, 1
  %. = select i1 %6, i32 %0, i32 %5
  ret i32 %.
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4RectV4maxYs5Int32Vvg"(i32 %0, i32 %1, i32 %2, i32 %3) #0 {
entry:
  %4 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %1, i32 %3)
  %5 = extractvalue { i32, i1 } %4, 0
  %6 = extractvalue { i32, i1 } %4, 1
  %. = select i1 %6, i32 %1, i32 %5
  ret i32 %.
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i1 @"$s27GiftUIFoundationLayoutProbe4RectV8containsySbAA5PointVF"(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5) #0 {
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

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i1 @"$s27GiftUIFoundationLayoutProbe4RectV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5, i32 %6, i32 %7) #0 {
entry:
  %8 = icmp eq i32 %0, %4
  %9 = icmp eq i32 %1, %5
  %or.cond = select i1 %8, i1 %9, i1 false
  br i1 %or.cond, label %10, label %13

10:                                               ; preds = %entry
  %11 = icmp eq i32 %2, %6
  %12 = icmp eq i32 %3, %7
  %or.cond1 = select i1 %11, i1 %12, i1 false
  br label %13

13:                                               ; preds = %10, %entry
  %14 = phi i1 [ false, %entry ], [ %or.cond1, %10 ]
  ret i1 %14
}

define protected swiftcc void @"$s27GiftUIFoundationLayoutProbe4RectV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1, i32 %2, i32 %3, i32 %4) #1 {
entry:
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %4, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  ret void
}

define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4RectV9hashValueSivg"(i32 %0, i32 %1, i32 %2, i32 %3) #1 {
entry:
  %4 = alloca %Ts6HasherV, align 8
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %4)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %4, i32 0)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %0, ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  %5 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %4)
  ret i32 %5
}

define linkonce_odr hidden swiftcc i1 @"$s27GiftUIFoundationLayoutProbe4RectVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias captures(none) dereferenceable(16) %0, ptr noalias captures(none) dereferenceable(16) %1, ptr swiftself %2, ptr %Self, ptr %SelfWitnessTable) #1 {
entry:
  %3 = load i32, ptr %0, align 4
  %.origin.y = getelementptr inbounds nuw i8, ptr %0, i32 4
  %4 = load i32, ptr %.origin.y, align 4
  %5 = load i32, ptr %1, align 4
  %.origin1.y = getelementptr inbounds nuw i8, ptr %1, i32 4
  %6 = load i32, ptr %.origin1.y, align 4
  %7 = icmp eq i32 %3, %5
  %8 = icmp eq i32 %4, %6
  %or.cond = select i1 %7, i1 %8, i1 false
  br i1 %or.cond, label %9, label %16

9:                                                ; preds = %entry
  %.size2.height = getelementptr inbounds nuw i8, ptr %1, i32 12
  %10 = load i32, ptr %.size2.height, align 4
  %.size2 = getelementptr inbounds nuw i8, ptr %1, i32 8
  %11 = load i32, ptr %.size2, align 4
  %.size.height = getelementptr inbounds nuw i8, ptr %0, i32 12
  %12 = load i32, ptr %.size.height, align 4
  %.size = getelementptr inbounds nuw i8, ptr %0, i32 8
  %13 = load i32, ptr %.size, align 4
  %14 = icmp eq i32 %13, %11
  %15 = icmp eq i32 %12, %10
  %or.cond3 = select i1 %14, i1 %15, i1 false
  br label %16

16:                                               ; preds = %9, %entry
  %17 = phi i1 [ false, %entry ], [ %or.cond3, %9 ]
  ret i1 %17
}

define linkonce_odr hidden swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4RectVSHAASH9hashValueSivgTW"(ptr noalias swiftself captures(none) dereferenceable(16) %0, ptr %Self, ptr %SelfWitnessTable) #1 {
entry:
  %1 = alloca %Ts6HasherV, align 8
  %2 = load i32, ptr %0, align 4
  %.origin.y = getelementptr inbounds nuw i8, ptr %0, i32 4
  %3 = load i32, ptr %.origin.y, align 4
  %.size = getelementptr inbounds nuw i8, ptr %0, i32 8
  %4 = load i32, ptr %.size, align 4
  %.size.height = getelementptr inbounds nuw i8, ptr %0, i32 12
  %5 = load i32, ptr %.size.height, align 4
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %1)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %1, i32 0) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %1) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %1) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %4, ptr nonnull swiftself captures(none) dereferenceable(72) %1) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %5, ptr nonnull swiftself captures(none) dereferenceable(72) %1) #18
  %6 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %1) #18
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %1)
  ret i32 %6
}

define linkonce_odr hidden swiftcc void @"$s27GiftUIFoundationLayoutProbe4RectVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias swiftself captures(none) dereferenceable(16) %1, ptr %Self, ptr %SelfWitnessTable) #1 {
entry:
  %2 = load i32, ptr %1, align 4
  %.origin.y = getelementptr inbounds nuw i8, ptr %1, i32 4
  %3 = load i32, ptr %.origin.y, align 4
  %.size = getelementptr inbounds nuw i8, ptr %1, i32 8
  %4 = load i32, ptr %.size, align 4
  %.size.height = getelementptr inbounds nuw i8, ptr %1, i32 12
  %5 = load i32, ptr %.size.height, align 4
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %4, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %5, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  ret void
}

define linkonce_odr hidden swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4RectVSHAASH13_rawHashValue4seedS2i_tFTW"(i32 %0, ptr noalias swiftself captures(none) dereferenceable(16) %1, ptr %Self, ptr %SelfWitnessTable) #1 {
entry:
  %2 = alloca %Ts6HasherV, align 8
  %3 = load i32, ptr %1, align 4
  %.origin.y = getelementptr inbounds nuw i8, ptr %1, i32 4
  %4 = load i32, ptr %.origin.y, align 4
  %.size = getelementptr inbounds nuw i8, ptr %1, i32 8
  %5 = load i32, ptr %.size, align 4
  %.size.height = getelementptr inbounds nuw i8, ptr %1, i32 12
  %6 = load i32, ptr %.size.height, align 4
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %2)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %2, i32 %0) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %4, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %5, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %6, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  %7 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %2)
  ret i32 %7
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc { i32, i8 } @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV5widths5Int32VSgvg"(i32 %0, i8 %1, i32 %2, i8 %3) #0 {
entry:
  %4 = insertvalue { i32, i8 } undef, i32 %0, 0
  %5 = insertvalue { i32, i8 } %4, i8 %1, 1
  ret { i32, i8 } %5
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc { i32, i8 } @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV6heights5Int32VSgvg"(i32 %0, i8 %1, i32 %2, i8 %3) #0 {
entry:
  %4 = insertvalue { i32, i8 } undef, i32 %2, 0
  %5 = insertvalue { i32, i8 } %4, i8 %3, 1
  ret { i32, i8 } %5
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc { i32, i32, i32, i16 } @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV5width6heightACSgs5Int32VSg_AItcfC"(i32 %0, i8 %1, i32 %2, i8 %3) #0 {
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

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i1 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i8 %1, i32 %2, i8 %3, i32 %4, i8 %5, i32 %6, i8 %7) #0 {
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

define protected swiftcc void @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1, i8 %2, i32 %3, i8 %4) #1 {
entry:
  %5 = icmp eq i8 %2, 1
  br i1 %5, label %6, label %7

6:                                                ; preds = %entry
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  br label %8

7:                                                ; preds = %entry
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  br label %8

8:                                                ; preds = %6, %7
  %9 = icmp eq i8 %4, 1
  br i1 %9, label %10, label %11

10:                                               ; preds = %8
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  br label %12

11:                                               ; preds = %8
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  br label %12

12:                                               ; preds = %10, %11
  ret void
}

declare swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8, ptr swiftself captures(none) dereferenceable(72)) local_unnamed_addr #1

define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV9hashValueSivg"(i32 %0, i8 %1, i32 %2, i8 %3) #1 {
entry:
  %4 = alloca %Ts6HasherV, align 8
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %4)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %4, i32 0)
  %5 = icmp eq i8 %1, 1
  br i1 %5, label %6, label %7

6:                                                ; preds = %entry
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  br label %8

7:                                                ; preds = %entry
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %0, ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  br label %8

8:                                                ; preds = %6, %7
  %9 = icmp eq i8 %3, 1
  br i1 %9, label %10, label %11

10:                                               ; preds = %8
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  br label %12

11:                                               ; preds = %8
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  br label %12

12:                                               ; preds = %10, %11
  %13 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %4)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %4)
  ret i32 %13
}

define linkonce_odr hidden swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias captures(none) dereferenceable(13) %0, ptr noalias captures(none) dereferenceable(13) %1, ptr swiftself %2, ptr %Self, ptr %SelfWitnessTable) #1 {
entry:
  %3 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %4 = load i8, ptr %3, align 4
  %.height = getelementptr inbounds nuw i8, ptr %0, i32 8
  %5 = load i32, ptr %.height, align 4
  %6 = getelementptr inbounds nuw i8, ptr %0, i32 12
  %7 = load i8, ptr %6, align 4
  %8 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %9 = load i8, ptr %8, align 4
  %.height2 = getelementptr inbounds nuw i8, ptr %1, i32 8
  %10 = load i32, ptr %.height2, align 4
  %11 = getelementptr inbounds nuw i8, ptr %1, i32 12
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

define linkonce_odr hidden swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASH9hashValueSivgTW"(ptr noalias swiftself captures(none) dereferenceable(13) %0, ptr %Self, ptr %SelfWitnessTable) #1 {
entry:
  %1 = load i32, ptr %0, align 4
  %2 = getelementptr inbounds nuw i8, ptr %0, i32 4
  %3 = load i8, ptr %2, align 4
  %.height = getelementptr inbounds nuw i8, ptr %0, i32 8
  %4 = load i32, ptr %.height, align 4
  %5 = getelementptr inbounds nuw i8, ptr %0, i32 12
  %6 = load i8, ptr %5, align 4
  %7 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeV9hashValueSivg"(i32 %1, i8 %3, i32 %4, i8 %6) #18
  ret i32 %7
}

define linkonce_odr hidden swiftcc void @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias swiftself captures(none) dereferenceable(13) %1, ptr %Self, ptr %SelfWitnessTable) #1 {
entry:
  %2 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %3 = load i8, ptr %2, align 4
  %.height = getelementptr inbounds nuw i8, ptr %1, i32 8
  %4 = load i32, ptr %.height, align 4
  %5 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %6 = load i8, ptr %5, align 4
  %7 = icmp eq i8 %3, 1
  br i1 %7, label %8, label %9

8:                                                ; preds = %entry
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  br label %11

9:                                                ; preds = %entry
  %10 = load i32, ptr %1, align 4
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %10, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  br label %11

11:                                               ; preds = %8, %9
  %12 = icmp eq i8 %6, 1
  br i1 %12, label %13, label %14

13:                                               ; preds = %11
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  br label %15

14:                                               ; preds = %11
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %4, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  br label %15

15:                                               ; preds = %13, %14
  ret void
}

define linkonce_odr hidden swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASH13_rawHashValue4seedS2i_tFTW"(i32 %0, ptr noalias swiftself captures(none) dereferenceable(13) %1, ptr %Self, ptr %SelfWitnessTable) #1 {
entry:
  %2 = alloca %Ts6HasherV, align 8
  %3 = load i32, ptr %1, align 4
  %4 = getelementptr inbounds nuw i8, ptr %1, i32 4
  %5 = load i8, ptr %4, align 4
  %.height = getelementptr inbounds nuw i8, ptr %1, i32 8
  %6 = load i32, ptr %.height, align 4
  %7 = getelementptr inbounds nuw i8, ptr %1, i32 12
  %8 = load i8, ptr %7, align 4
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %2)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %2, i32 %0) #18
  %9 = icmp eq i8 %5, 1
  br i1 %9, label %10, label %11

10:                                               ; preds = %entry
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  br label %12

11:                                               ; preds = %entry
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  br label %12

12:                                               ; preds = %10, %11
  %13 = icmp eq i8 %8, 1
  br i1 %13, label %14, label %15

14:                                               ; preds = %12
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 0, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  br label %16

15:                                               ; preds = %12
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 1, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %6, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  br label %16

16:                                               ; preds = %14, %15
  %17 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %2)
  ret i32 %17
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc { i32, i8 } @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticO8subtractys5Int32VSgAF_AFtFZ"(i32 %0, i32 %1) #0 {
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

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.ssub.with.overflow.i32(i32, i32) #5

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc { i32, i8 } @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticO8multiplyys5Int32VSgAF_AFtFZ"(i32 %0, i32 %1) #0 {
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

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.smul.with.overflow.i32(i32, i32) #5

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc range(i8 0, 4) i8 @"$s27GiftUIFoundationLayoutProbe12PointerPhaseO8rawValueACSgs5UInt8V_tcfC"(i8 %0) #0 {
entry:
  %. = tail call i8 @llvm.umin.i8(i8 %0, i8 3)
  ret i8 %.
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i8 @"$s27GiftUIFoundationLayoutProbe12PointerPhaseO8rawValues5UInt8Vvg"(i8 returned %0) #0 {
entry:
  ret i8 %0
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASH9hashValueSivgTW"(ptr noalias readonly swiftself captures(none) dereferenceable(1) %0, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #1 {
entry:
  %1 = alloca %Ts6HasherV, align 8
  %2 = load i8, ptr %0, align 1
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %1)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %1, i32 0) #18
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %1) #18
  %3 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %1) #18
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %1)
  ret i32 %3
}

define internal swiftcc void @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias readonly swiftself captures(none) dereferenceable(1) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #1 {
entry:
  %2 = load i8, ptr %1, align 1
  tail call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  ret void
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASH13_rawHashValue4seedS2i_tFTW"(i32 %0, ptr noalias readonly swiftself captures(none) dereferenceable(1) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #1 {
entry:
  %2 = alloca %Ts6HasherV, align 8
  %3 = load i8, ptr %1, align 1
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %2)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %2, i32 %0) #18
  call swiftcc void @"$ss6HasherV8_combineyys5UInt8VF"(i8 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  %4 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %2)
  ret i32 %4
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
define internal swiftcc void @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAASY8rawValuexSg03RawH0Qz_tcfCTW"(ptr noalias writeonly sret(%T27GiftUIFoundationLayoutProbe12PointerPhaseOSg) captures(none) initializes((0, 1)) %0, ptr noalias readonly captures(none) dereferenceable(1) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #6 {
entry:
  %3 = load i8, ptr %1, align 1
  %. = tail call i8 @llvm.umin.i8(i8 %3, i8 3)
  store i8 %., ptr %0, align 1
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
define internal swiftcc void @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSYAASY8rawValue03RawH0QzvgTW"(ptr noalias writeonly sret(%Ts5UInt8V) captures(none) initializes((0, 1)) %0, ptr noalias readonly swiftself captures(none) dereferenceable(1) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #6 {
entry:
  %2 = load i8, ptr %1, align 1
  store i8 %2, ptr %0, align 1
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(1) %0, ptr noalias readonly captures(none) dereferenceable(1) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #7 {
entry:
  %3 = load i8, ptr %0, align 1
  %4 = load i8, ptr %1, align 1
  %5 = icmp eq i8 %3, %4
  ret i1 %5
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i16 @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV8rawValues6UInt16Vvg"(i16 returned %0) #0 {
entry:
  ret i16 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i16 @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV8rawValueACs6UInt16V_tcfC"(i16 returned %0) #0 {
entry:
  ret i16 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i1 @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV23__derived_struct_equalsySbAC_ACtFZ"(i16 %0, i16 %1) #0 {
entry:
  %2 = icmp eq i16 %0, %1
  ret i1 %2
}

define protected swiftcc void @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i16 %1) #1 {
entry:
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt16VF"(i16 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  ret void
}

declare swiftcc void @"$ss6HasherV8_combineyys6UInt16VF"(i16, ptr swiftself captures(none) dereferenceable(72)) local_unnamed_addr #1

define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe13InputSourceIDV9hashValueSivg"(i16 %0) #1 {
entry:
  %1 = alloca %Ts6HasherV, align 8
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %1)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %1, i32 0)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt16VF"(i16 %0, ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  %2 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %1)
  ret i32 %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal swiftcc i1 @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(2) %0, ptr noalias readonly captures(none) dereferenceable(2) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #7 {
entry:
  %3 = load i16, ptr %0, align 2
  %4 = load i16, ptr %1, align 2
  %5 = icmp eq i16 %3, %4
  ret i1 %5
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASH9hashValueSivgTW"(ptr noalias readonly swiftself captures(none) dereferenceable(2) %0, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #1 {
entry:
  %1 = alloca %Ts6HasherV, align 8
  %2 = load i16, ptr %0, align 2
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %1)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %1, i32 0) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt16VF"(i16 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %1) #18
  %3 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %1) #18
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %1)
  ret i32 %3
}

define internal swiftcc void @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias readonly swiftself captures(none) dereferenceable(2) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #1 {
entry:
  %2 = load i16, ptr %1, align 2
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt16VF"(i16 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  ret void
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASH13_rawHashValue4seedS2i_tFTW"(i32 %0, ptr noalias readonly swiftself captures(none) dereferenceable(2) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #1 {
entry:
  %2 = alloca %Ts6HasherV, align 8
  %3 = load i16, ptr %1, align 2
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %2)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %2, i32 %0) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt16VF"(i16 %3, ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  %4 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %2) #18
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %2)
  ret i32 %4
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV8rawValues6UInt32Vvg"(i32 returned %0) #0 {
entry:
  ret i32 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV8rawValueACs6UInt32V_tcfC"(i32 returned %0) #0 {
entry:
  ret i32 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV8rawValues6UInt32Vvg"(i32 returned %0) #0 {
entry:
  ret i32 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV8rawValueACs6UInt32V_tcfC"(i32 returned %0) #0 {
entry:
  ret i32 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) #0 {
entry:
  %2 = icmp eq i32 %0, %1
  ret i1 %2
}

define protected swiftcc void @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) #1 {
entry:
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %1, ptr nonnull swiftself captures(none) dereferenceable(72) %0)
  ret void
}

define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV9hashValueSivg"(i32 %0) #1 {
  %2 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV9hashValueSivgTm"(i32 %0) #1
  ret i32 %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(4) %0, ptr noalias readonly captures(none) dereferenceable(4) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #7 {
entry:
  %3 = load i32, ptr %0, align 4
  %4 = load i32, ptr %1, align 4
  %5 = icmp eq i32 %3, %4
  ret i1 %5
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH9hashValueSivgTW"(ptr noalias readonly swiftself captures(none) dereferenceable(4) %0, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #1 {
  %2 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH9hashValueSivgTWTm"(ptr noalias readonly swiftself captures(none) dereferenceable(4) %0, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #1
  ret i32 %2
}

define internal swiftcc void @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #1 {
entry:
  %2 = load i32, ptr %1, align 4
  tail call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %2, ptr nonnull swiftself captures(none) dereferenceable(72) %0) #18
  ret void
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH13_rawHashValue4seedS2i_tFTW"(i32 %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #1 {
  %3 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH13_rawHashValue4seedS2i_tFTWTm"(i32 %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #1
  ret i32 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV8rawValues6UInt32Vvg"(i32 returned %0) #0 {
entry:
  ret i32 %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV8rawValueACs6UInt32V_tcfC"(i32 returned %0) #0 {
entry:
  ret i32 %0
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV9hashValueSivgTm"(i32 %0) #1 {
entry:
  %1 = alloca %Ts6HasherV, align 8
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %1)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %1, i32 0)
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %0, ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  %2 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %1)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %1)
  ret i32 %2
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH9hashValueSivgTWTm"(ptr noalias readonly swiftself captures(none) dereferenceable(4) %0, ptr readnone captures(none) %1, ptr readnone captures(none) %2) #1 {
entry:
  %3 = alloca %Ts6HasherV, align 8
  %4 = load i32, ptr %0, align 4
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %3)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %3, i32 0) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %4, ptr nonnull swiftself captures(none) dereferenceable(72) %3) #18
  %5 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %3) #18
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %3)
  ret i32 %5
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH13_rawHashValue4seedS2i_tFTWTm"(i32 %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #1 {
entry:
  %4 = alloca %Ts6HasherV, align 8
  %5 = load i32, ptr %1, align 4
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %4)
  call swiftcc void @"$ss6HasherV5_seedABSi_tcfC"(ptr noalias nonnull sret(%Ts6HasherV) captures(none) %4, i32 %0) #18
  call swiftcc void @"$ss6HasherV8_combineyys6UInt32VF"(i32 %5, ptr nonnull swiftself captures(none) dereferenceable(72) %4) #18
  %6 = call swiftcc i32 @"$ss6HasherV9_finalizeSiyF"(ptr nonnull swiftself captures(none) dereferenceable(72) %4) #18
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %4)
  ret i32 %6
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc i8 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV5phaseAA0F5PhaseOvg"(ptr noalias readonly swiftself captures(none) dereferenceable(28) %0) #7 {
entry:
  %1 = load i8, ptr %0, align 4
  ret i8 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc { i32, i32 } @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV8positionAA5PointVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(28) %0) #7 {
entry:
  %.position = getelementptr inbounds nuw i8, ptr %0, i32 4
  %1 = load i32, ptr %.position, align 4
  %.position.y = getelementptr inbounds nuw i8, ptr %0, i32 8
  %2 = load i32, ptr %.position.y, align 4
  %3 = insertvalue { i32, i32 } undef, i32 %1, 0
  %4 = insertvalue { i32, i32 } %3, i32 %2, 1
  ret { i32, i32 } %4
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc i16 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV6sourceAA13InputSourceIDVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(28) %0) #7 {
entry:
  %.source = getelementptr inbounds nuw i8, ptr %0, i32 12
  %1 = load i16, ptr %.source, align 4
  ret i16 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV8sequenceAA0F10SequenceIDVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(28) %0) #7 {
entry:
  %.sequence = getelementptr inbounds nuw i8, ptr %0, i32 16
  %1 = load i32, ptr %.sequence, align 4
  ret i32 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV7ordinalAA12InputOrdinalVvg"(ptr noalias readonly swiftself captures(none) dereferenceable(28) %0) #7 {
entry:
  %.ordinal = getelementptr inbounds nuw i8, ptr %0, i32 20
  %1 = load i32, ptr %.ordinal, align 4
  ret i32 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV20presentationRevisionAA012PresentationI0Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(28) %0) #7 {
entry:
  %.presentationRevision = getelementptr inbounds nuw i8, ptr %0, i32 24
  %1 = load i32, ptr %.presentationRevision, align 4
  ret i32 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define protected swiftcc void @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV5phase8position6source8sequence7ordinal20presentationRevisionAcA0F5PhaseO_AA5PointVAA13InputSourceIDVAA0f8SequenceS0VAA0Q7OrdinalVAA012PresentationN0VtcfC"(ptr noalias writeonly sret(%T27GiftUIFoundationLayoutProbe22NormalizedPointerEventV) captures(none) initializes((0, 1), (4, 14), (16, 28)) %0, i8 %1, i32 %2, i32 %3, i16 %4, i32 %5, i32 %6, i32 %7) #4 {
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

define protected swiftcc i1 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV23__derived_struct_equalsySbAC_ACtFZ"(ptr noalias captures(none) dereferenceable(28) %0, ptr noalias captures(none) dereferenceable(28) %1) #1 {
entry:
  %2 = tail call swiftcc i1 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV23__derived_struct_equalsySbAC_ACtFZTf4nnd_n"(ptr noalias nonnull captures(none) dereferenceable(28) %0, ptr noalias nonnull captures(none) dereferenceable(28) %1) #18
  ret i1 %2
}

define internal swiftcc i1 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(28) %0, ptr noalias readonly captures(none) dereferenceable(28) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %Self, ptr readnone captures(none) %SelfWitnessTable) #1 {
entry:
  %3 = alloca %T27GiftUIFoundationLayoutProbe22NormalizedPointerEventV, align 4
  %4 = alloca %T27GiftUIFoundationLayoutProbe22NormalizedPointerEventV, align 4
  call void @llvm.lifetime.start.p0(i64 28, ptr nonnull %3)
  call void @llvm.lifetime.start.p0(i64 28, ptr nonnull %4)
  call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(28) %4, ptr noundef nonnull align 4 dereferenceable(28) %0, i32 28, i1 false)
  call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(28) %3, ptr noundef nonnull align 4 dereferenceable(28) %1, i32 28, i1 false)
  %5 = call swiftcc i1 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV23__derived_struct_equalsySbAC_ACtFZTf4nnd_n"(ptr noalias nonnull captures(none) dereferenceable(28) %4, ptr noalias nonnull captures(none) dereferenceable(28) %3) #18
  call void @llvm.lifetime.end.p0(i64 28, ptr nonnull %4)
  call void @llvm.lifetime.end.p0(i64 28, ptr nonnull %3)
  ret i1 %5
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO18geometryScalarSizes6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO20geometryScalarStrides6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO23geometryScalarAlignments6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO9pointSizes6UInt32VyFZ"() #8 {
entry:
  ret i32 8
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO11pointStrides6UInt32VyFZ"() #8 {
entry:
  ret i32 8
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO14pointAlignments6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO8sizeSizes6UInt32VyFZ"() #8 {
entry:
  ret i32 8
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO10sizeStrides6UInt32VyFZ"() #8 {
entry:
  ret i32 8
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO13sizeAlignments6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO8rectSizes6UInt32VyFZ"() #8 {
entry:
  ret i32 16
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO10rectStrides6UInt32VyFZ"() #8 {
entry:
  ret i32 16
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO13rectAlignments6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO16proposedByteSizes6UInt32VyFZ"() #8 {
entry:
  ret i32 13
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO14proposedStrides6UInt32VyFZ"() #8 {
entry:
  ret i32 16
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO17proposedAlignments6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO16pointerPhaseSizes6UInt32VyFZ"() #8 {
entry:
  ret i32 1
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO18pointerPhaseStrides6UInt32VyFZ"() #8 {
entry:
  ret i32 1
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO21pointerPhaseAlignments6UInt32VyFZ"() #8 {
entry:
  ret i32 1
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO17inputSourceIDSizes6UInt32VyFZ"() #8 {
entry:
  ret i32 2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO19inputSourceIDStrides6UInt32VyFZ"() #8 {
entry:
  ret i32 2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO22inputSourceIDAlignments6UInt32VyFZ"() #8 {
entry:
  ret i32 2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO21pointerSequenceIDSizes6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO23pointerSequenceIDStrides6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO26pointerSequenceIDAlignments6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO16inputOrdinalSizes6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO18inputOrdinalStrides6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO21inputOrdinalAlignments6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO24presentationRevisionSizes6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO26presentationRevisionStrides6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO29presentationRevisionAlignments6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO26normalizedPointerEventSizes6UInt32VyFZ"() #8 {
entry:
  ret i32 28
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO28normalizedPointerEventStrides6UInt32VyFZ"() #8 {
entry:
  ret i32 28
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc noundef i32 @"$s27GiftUIFoundationLayoutProbeAAO31normalizedPointerEventAlignments6UInt32VyFZ"() #8 {
entry:
  ret i32 4
}

define linkonce_odr hidden swiftcc i1 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventV23__derived_struct_equalsySbAC_ACtFZTf4nnd_n"(ptr noalias captures(none) dereferenceable(28) %0, ptr noalias captures(none) dereferenceable(28) %1) local_unnamed_addr #1 {
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

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe5PointVSHAASQWb"(ptr readnone captures(none) %Point, ptr readnone captures(none) %Point1, ptr readnone captures(none) %Point.Hashable) #9 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe5PointVACSQAAWl"() #19
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe5PointVACSQAAWl"() local_unnamed_addr #10 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe5PointVACSQAAWL", align 4
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe5PointVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMf", i32 8), ptr undef) #20
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe5PointVACSQAAWL" release, align 4
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nounwind memory(read)
declare ptr @swift_getWitnessTable(ptr, ptr, ptr) local_unnamed_addr #11

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASQWb"(ptr readnone captures(none) %Size, ptr readnone captures(none) %Size1, ptr readnone captures(none) %Size.Hashable) #9 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe4SizeVACSQAAWl"() #19
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe4SizeVACSQAAWl"() local_unnamed_addr #10 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVACSQAAWL", align 4
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe4SizeVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMf", i32 8), ptr undef) #20
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVACSQAAWL" release, align 4
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe4RectVSHAASQWb"(ptr readnone captures(none) %Rect, ptr readnone captures(none) %Rect1, ptr readnone captures(none) %Rect.Hashable) #9 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe4RectVACSQAAWl"() #19
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe4RectVACSQAAWl"() local_unnamed_addr #10 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe4RectVACSQAAWL", align 4
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe4RectVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMf", i32 8), ptr undef) #20
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe4RectVACSQAAWL" release, align 4
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSHAASQWb"(ptr readnone captures(none) %ProposedSize, ptr readnone captures(none) %ProposedSize1, ptr readnone captures(none) %ProposedSize.Hashable) #9 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVACSQAAWl"() #19
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVACSQAAWl"() local_unnamed_addr #10 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVACSQAAWL", align 4
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMf", i32 8), ptr undef) #20
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVACSQAAWL" release, align 4
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSHAASQWb"(ptr readnone captures(none) %PointerPhase, ptr readnone captures(none) %PointerPhase1, ptr readnone captures(none) %PointerPhase.Hashable) #9 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOACSQAAWl"() #19
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOACSQAAWl"() local_unnamed_addr #10 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOACSQAAWL", align 4
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMf", i32 8), ptr undef) #20
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOACSQAAWL" release, align 4
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSHAASQWb"(ptr readnone captures(none) %InputSourceID, ptr readnone captures(none) %InputSourceID1, ptr readnone captures(none) %InputSourceID.Hashable) #9 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVACSQAAWl"() #19
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVACSQAAWl"() local_unnamed_addr #10 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVACSQAAWL", align 4
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMf", i32 8), ptr undef) #20
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVACSQAAWL" release, align 4
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASQWb"(ptr readnone captures(none) %PointerSequenceID, ptr readnone captures(none) %PointerSequenceID1, ptr readnone captures(none) %PointerSequenceID.Hashable) #9 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVACSQAAWl"() #19
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVACSQAAWl"() local_unnamed_addr #10 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVACSQAAWL", align 4
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMf", i32 8), ptr undef) #20
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVACSQAAWL" release, align 4
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASQWb"(ptr readnone captures(none) %InputOrdinal, ptr readnone captures(none) %InputOrdinal1, ptr readnone captures(none) %InputOrdinal.Hashable) #9 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVACSQAAWl"() #19
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVACSQAAWl"() local_unnamed_addr #10 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVACSQAAWL", align 4
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMf", i32 8), ptr undef) #20
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVACSQAAWL" release, align 4
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nosync nounwind memory(none)
define internal swiftcc ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASQWb"(ptr readnone captures(none) %PresentationRevision, ptr readnone captures(none) %PresentationRevision1, ptr readnone captures(none) %PresentationRevision.Hashable) #9 {
entry:
  %0 = tail call ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVACSQAAWl"() #19
  ret ptr %0
}

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVACSQAAWl"() local_unnamed_addr #10 {
entry:
  %0 = load ptr, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVACSQAAWL", align 4
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMf", i32 8), ptr undef) #20
  store atomic ptr %2, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVACSQAAWL" release, align 4
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy8_4(ptr %0, ptr %1, ptr %2) #12 {
entry:
  %3 = load i64, ptr %1, align 4
  store i64 %3, ptr %0, align 4
  ret ptr %0
}

; Function Attrs: nounwind
define linkonce_odr hidden void @__swift_noop_void_return(ptr %0, ptr %1) #12 {
entry:
  ret void
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe5PointVMa"(i32 %0) #13 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe5PointVMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s27GiftUIFoundationLayoutProbe4SizeVwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %Size) #7 {
entry:
  %0 = icmp eq i32 %numEmptyCases, 0
  br i1 %0, label %9, label %1

1:                                                ; preds = %entry
  %2 = getelementptr inbounds nuw i8, ptr %value, i32 8
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
define internal void @"$s27GiftUIFoundationLayoutProbe4SizeVwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %Size) #4 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i32 8
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
define protected swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe4SizeVMa"(i32 %0) #13 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4SizeVMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: mustprogress nounwind willreturn
declare ptr @swift_retain(ptr returned) local_unnamed_addr #14

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy16_4(ptr %0, ptr %1, ptr %2) #12 {
entry:
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(16) %0, ptr noundef nonnull align 4 dereferenceable(16) %1, i32 16, i1 false)
  ret ptr %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s27GiftUIFoundationLayoutProbe4RectVwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %Rect) #7 {
entry:
  %0 = icmp eq i32 %numEmptyCases, 0
  br i1 %0, label %9, label %1

1:                                                ; preds = %entry
  %2 = getelementptr inbounds nuw i8, ptr %value, i32 16
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
define internal void @"$s27GiftUIFoundationLayoutProbe4RectVwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %Rect) #4 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i32 16
  %.not = icmp eq i32 %numEmptyCases, 0
  %1 = icmp eq i32 %whichCase, 0
  br i1 %1, label %2, label %3

2:                                                ; preds = %entry
  br i1 %.not, label %6, label %.sink.split

3:                                                ; preds = %entry
  %4 = add i32 %whichCase, -1
  store i32 %4, ptr %value, align 4
  %5 = getelementptr inbounds nuw i8, ptr %value, i32 4
  tail call void @llvm.memset.p0.i32(ptr noundef nonnull align 4 dereferenceable(12) %5, i8 0, i32 12, i1 false)
  br i1 %.not, label %6, label %.sink.split

.sink.split:                                      ; preds = %3, %2
  %.sink = phi i8 [ 0, %2 ], [ 1, %3 ]
  store i8 %.sink, ptr %0, align 4
  br label %6

6:                                                ; preds = %.sink.split, %3, %2
  ret void
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i32(ptr writeonly captures(none), i8, i32, i1 immarg) #15

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe4RectVMa"(i32 %0) #13 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe4RectVMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: mustprogress nounwind willreturn
define internal nonnull ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVwCP"(ptr noalias writeonly captures(none) initializes((0, 4)) %dest, ptr noalias readonly captures(none) %src, ptr readnone captures(none) %ProposedSize) #16 {
entry:
  %0 = load ptr, ptr %src, align 4
  store ptr %0, ptr %dest, align 4
  %1 = getelementptr inbounds nuw i8, ptr %0, i32 8
  %2 = tail call ptr @swift_retain(ptr returned %0) #21
  ret ptr %1
}

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy13_4(ptr %0, ptr %1, ptr %2) #12 {
entry:
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(13) %0, ptr noundef nonnull align 4 dereferenceable(13) %1, i32 13, i1 false)
  ret ptr %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %ProposedSize) #7 {
entry:
  %0 = icmp eq i32 %numEmptyCases, 0
  br i1 %0, label %9, label %1

1:                                                ; preds = %entry
  %2 = getelementptr inbounds nuw i8, ptr %value, i32 13
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
define internal void @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %ProposedSize) #4 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i32 13
  %.not = icmp eq i32 %numEmptyCases, 0
  %1 = icmp eq i32 %whichCase, 0
  br i1 %1, label %2, label %3

2:                                                ; preds = %entry
  br i1 %.not, label %6, label %.sink.split

3:                                                ; preds = %entry
  %4 = add i32 %whichCase, -1
  store i32 %4, ptr %value, align 4
  %5 = getelementptr inbounds nuw i8, ptr %value, i32 4
  tail call void @llvm.memset.p0.i32(ptr noundef nonnull align 4 dereferenceable(9) %5, i8 0, i32 9, i1 false)
  br i1 %.not, label %6, label %.sink.split

.sink.split:                                      ; preds = %3, %2
  %.sink = phi i8 [ 0, %2 ], [ 1, %3 ]
  store i8 %.sink, ptr %0, align 1
  br label %6

6:                                                ; preds = %.sink.split, %3, %2
  ret void
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMa"(i32 %0) #13 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMa"(i32 %0) #13 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr }>, ptr @"$s27GiftUIFoundationLayoutProbe18GeometryArithmeticOMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy1_1(ptr %0, ptr %1, ptr %2) #12 {
entry:
  %3 = load i8, ptr %1, align 1
  store i8 %3, ptr %0, align 1
  ret ptr %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %PointerPhase) #7 {
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
  %9 = getelementptr inbounds nuw i8, ptr %value, i32 1
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
define internal void @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %PointerPhase) #4 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i32 1
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
define internal range(i32 0, 256) i32 @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwug"(ptr noalias readonly captures(none) %value, ptr readnone captures(none) %PointerPhase) #7 {
entry:
  %0 = load i8, ptr %value, align 1
  %1 = zext i8 %0 to i32
  ret i32 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define internal void @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwup"(ptr noalias readnone captures(none) %value, ptr readnone captures(none) %PointerPhase) #0 {
entry:
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define internal void @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOwui"(ptr noalias writeonly captures(none) initializes((0, 1)) %value, i32 %tag, ptr readnone captures(none) %PointerPhase) #4 {
entry:
  %0 = trunc i32 %tag to i8
  store i8 %0, ptr %value, align 1
  ret void
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMa"(i32 %0) #13 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr }>, ptr @"$s27GiftUIFoundationLayoutProbe12PointerPhaseOMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMa"(i32 %0) #13 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe13InputSourceIDVMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMa"(i32 %0) #13 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMa"(i32 %0) #13 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMa"(i32 %0) #13 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy28_4(ptr %0, ptr %1, ptr %2) #12 {
entry:
  tail call void @llvm.memcpy.p0.p0.i32(ptr noundef nonnull align 4 dereferenceable(28) %0, ptr noundef nonnull align 4 dereferenceable(28) %1, i32 28, i1 false)
  ret ptr %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %NormalizedPointerEvent) #7 {
entry:
  %0 = icmp eq i32 %numEmptyCases, 0
  br i1 %0, label %17, label %1

1:                                                ; preds = %entry
  %2 = icmp ugt i32 %numEmptyCases, 253
  br i1 %2, label %3, label %11

3:                                                ; preds = %1
  %4 = getelementptr inbounds nuw i8, ptr %value, i32 28
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
define internal void @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %NormalizedPointerEvent) #4 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i32 28
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
  br i1 %6, label %14, label %7

7:                                                ; preds = %5
  %8 = trunc nuw i32 %whichCase to i8
  %9 = add nuw i8 %8, 2
  store i8 %9, ptr %value, align 4
  br label %14

10:                                               ; preds = %entry
  %11 = add i32 %whichCase, -254
  store i32 %11, ptr %value, align 4
  %12 = getelementptr inbounds nuw i8, ptr %value, i32 4
  tail call void @llvm.memset.p0.i32(ptr noundef nonnull align 4 dereferenceable(24) %12, i8 0, i32 24, i1 false)
  br i1 %1, label %13, label %14

13:                                               ; preds = %10
  store i8 1, ptr %0, align 4
  br label %14

14:                                               ; preds = %10, %13, %7, %5
  ret void
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMa"(i32 %0) #13 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr, i32, i32, i32, i32, i32, i32 }>, ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define protected swiftcc %swift.metadata_response @"$s27GiftUIFoundationLayoutProbeAAOMa"(i32 %0) #13 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i32, ptr }>, ptr @"$s27GiftUIFoundationLayoutProbeAAOMf", i32 0, i32 2), i32 0 }
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.umin.i8(i8, i8) #17

define protected swiftcc void @"$s27GiftUIFoundationLayoutProbe5PointV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1, i32 %2) #1 {
  tail call swiftcc void @"$s27GiftUIFoundationLayoutProbe4SizeV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1, i32 %2) #1
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i1 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) #0 {
  %3 = tail call swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) #0
  ret i1 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i1 @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) #0 {
  %3 = tail call swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1) #0
  ret i1 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal swiftcc i1 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(4) %0, ptr noalias readonly captures(none) dereferenceable(4) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %3, ptr readnone captures(none) %4) #7 {
  %6 = tail call swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(4) %0, ptr noalias readonly captures(none) dereferenceable(4) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %3, ptr readnone captures(none) %4) #7
  ret i1 %6
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal swiftcc i1 @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(4) %0, ptr noalias readonly captures(none) dereferenceable(4) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %3, ptr readnone captures(none) %4) #7 {
  %6 = tail call swiftcc i1 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias readonly captures(none) dereferenceable(4) %0, ptr noalias readonly captures(none) dereferenceable(4) %1, ptr readnone swiftself captures(none) %2, ptr readnone captures(none) %3, ptr readnone captures(none) %4) #7
  ret i1 %6
}

define linkonce_odr hidden swiftcc i32 @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH13_rawHashValue4seedS2i_tFTW"(i32 %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #1 {
  %5 = tail call swiftcc i32 @20(i32 %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #1
  ret i32 %5
}

define linkonce_odr hidden swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASH13_rawHashValue4seedS2i_tFTW"(i32 %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #1 {
  %5 = tail call swiftcc i32 @20(i32 %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #1
  ret i32 %5
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH13_rawHashValue4seedS2i_tFTW"(i32 %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #1 {
  %5 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH13_rawHashValue4seedS2i_tFTW"(i32 %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #1
  ret i32 %5
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASH13_rawHashValue4seedS2i_tFTW"(i32 %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #1 {
  %5 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH13_rawHashValue4seedS2i_tFTW"(i32 %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #1
  ret i32 %5
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define protected swiftcc i1 @"$s27GiftUIFoundationLayoutProbe5PointV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1, i32 %2, i32 %3) #0 {
  %5 = tail call swiftcc i1 @"$s27GiftUIFoundationLayoutProbe4SizeV23__derived_struct_equalsySbAC_ACtFZ"(i32 %0, i32 %1, i32 %2, i32 %3) #0
  ret i1 %5
}

; Function Attrs: mustprogress nounwind willreturn
define internal nonnull ptr @"$s27GiftUIFoundationLayoutProbe4RectVwCP"(ptr noalias writeonly captures(none) initializes((0, 4)) %0, ptr noalias readonly captures(none) %1, ptr readnone captures(none) %2) #16 {
  %4 = tail call nonnull ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVwCP"(ptr noalias writeonly captures(none) initializes((0, 4)) %0, ptr noalias readonly captures(none) %1, ptr readnone captures(none) %2) #16
  ret ptr %4
}

; Function Attrs: mustprogress nounwind willreturn
define internal nonnull ptr @"$s27GiftUIFoundationLayoutProbe22NormalizedPointerEventVwCP"(ptr noalias writeonly captures(none) initializes((0, 4)) %0, ptr noalias readonly captures(none) %1, ptr readnone captures(none) %2) #16 {
  %4 = tail call nonnull ptr @"$s27GiftUIFoundationLayoutProbe12ProposedSizeVwCP"(ptr noalias writeonly captures(none) initializes((0, 4)) %0, ptr noalias readonly captures(none) %1, ptr readnone captures(none) %2) #16
  ret ptr %4
}

define linkonce_odr hidden swiftcc void @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #1 {
  tail call swiftcc void @19(ptr captures(none) dereferenceable(72) %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #1
  ret void
}

define linkonce_odr hidden swiftcc void @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #1 {
  tail call swiftcc void @19(ptr captures(none) dereferenceable(72) %0, ptr noalias swiftself captures(none) dereferenceable(8) %1, ptr %2, ptr %3) #1
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define internal void @"$s27GiftUIFoundationLayoutProbe5PointVwst"(ptr noalias writeonly captures(none) %0, i32 %1, i32 %2, ptr readnone captures(none) %3) #4 {
  tail call void @"$s27GiftUIFoundationLayoutProbe4SizeVwst"(ptr noalias writeonly captures(none) %0, i32 %1, i32 %2, ptr readnone captures(none) %3) #4
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s27GiftUIFoundationLayoutProbe5PointVwet"(ptr noalias readonly captures(none) %0, i32 %1, ptr readnone captures(none) %2) #7 {
  %4 = tail call i32 @"$s27GiftUIFoundationLayoutProbe4SizeVwet"(ptr noalias readonly captures(none) %0, i32 %1, ptr readnone captures(none) %2) #7
  ret i32 %4
}

define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe5PointV9hashValueSivg"(i32 %0, i32 %1) #1 {
  %3 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4SizeV9hashValueSivg"(i32 %0, i32 %1) #1
  ret i32 %3
}

define protected swiftcc void @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) #1 {
  tail call swiftcc void @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) #1
  ret void
}

define protected swiftcc void @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) #1 {
  tail call swiftcc void @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV4hash4intoys6HasherVz_tF"(ptr captures(none) dereferenceable(72) %0, i32 %1) #1
  ret void
}

define internal swiftcc void @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #1 {
  tail call swiftcc void @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #1
  ret void
}

define internal swiftcc void @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #1 {
  tail call swiftcc void @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH4hash4intoys6HasherVz_tFTW"(ptr captures(none) dereferenceable(72) %0, ptr noalias readonly swiftself captures(none) dereferenceable(4) %1, ptr readnone captures(none) %2, ptr readnone captures(none) %3) #1
  ret void
}

define linkonce_odr hidden swiftcc i1 @"$s27GiftUIFoundationLayoutProbe5PointVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias captures(none) dereferenceable(8) %0, ptr noalias captures(none) dereferenceable(8) %1, ptr swiftself %2, ptr %3, ptr %4) #1 {
  %6 = tail call swiftcc i1 @17(ptr noalias captures(none) dereferenceable(8) %0, ptr noalias captures(none) dereferenceable(8) %1, ptr swiftself %2, ptr %3, ptr %4) #1
  ret i1 %6
}

define linkonce_odr hidden swiftcc i1 @"$s27GiftUIFoundationLayoutProbe4SizeVSQAASQ2eeoiySbx_xtFZTW"(ptr noalias captures(none) dereferenceable(8) %0, ptr noalias captures(none) dereferenceable(8) %1, ptr swiftself %2, ptr %3, ptr %4) #1 {
  %6 = tail call swiftcc i1 @17(ptr noalias captures(none) dereferenceable(8) %0, ptr noalias captures(none) dereferenceable(8) %1, ptr swiftself %2, ptr %3, ptr %4) #1
  ret i1 %6
}

define linkonce_odr hidden swiftcc i32 @"$s27GiftUIFoundationLayoutProbe5PointVSHAASH9hashValueSivgTW"(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %1, ptr %2) #1 {
  %4 = tail call swiftcc i32 @18(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %1, ptr %2) #1
  ret i32 %4
}

define linkonce_odr hidden swiftcc i32 @"$s27GiftUIFoundationLayoutProbe4SizeVSHAASH9hashValueSivgTW"(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %1, ptr %2) #1 {
  %4 = tail call swiftcc i32 @18(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %1, ptr %2) #1
  ret i32 %4
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDVSHAASH9hashValueSivgTW"(ptr noalias readonly swiftself captures(none) dereferenceable(4) %0, ptr readnone captures(none) %1, ptr readnone captures(none) %2) #1 {
  %4 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH9hashValueSivgTW"(ptr noalias readonly swiftself captures(none) dereferenceable(4) %0, ptr readnone captures(none) %1, ptr readnone captures(none) %2) #1
  ret i32 %4
}

define internal swiftcc i32 @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionVSHAASH9hashValueSivgTW"(ptr noalias readonly swiftself captures(none) dereferenceable(4) %0, ptr readnone captures(none) %1, ptr readnone captures(none) %2) #1 {
  %4 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalVSHAASH9hashValueSivgTW"(ptr noalias readonly swiftself captures(none) dereferenceable(4) %0, ptr readnone captures(none) %1, ptr readnone captures(none) %2) #1
  ret i32 %4
}

define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe17PointerSequenceIDV9hashValueSivg"(i32 %0) #1 {
  %2 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV9hashValueSivg"(i32 %0) #1
  ret i32 %2
}

define protected swiftcc i32 @"$s27GiftUIFoundationLayoutProbe20PresentationRevisionV9hashValueSivg"(i32 %0) #1 {
  %2 = tail call swiftcc i32 @"$s27GiftUIFoundationLayoutProbe12InputOrdinalV9hashValueSivg"(i32 %0) #1
  ret i32 %2
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #1 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #2 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #5 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #6 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #7 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #8 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #9 = { nofree nosync nounwind memory(none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #10 = { nofree noinline nosync nounwind memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #11 = { nofree nounwind memory(read) }
attributes #12 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #13 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #14 = { mustprogress nounwind willreturn }
attributes #15 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #16 = { mustprogress nounwind willreturn "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="arm1136jf-s" "target-features"="+armv6,+dsp,+fp64,+strict-align,+vfp2,+vfp2sp,-aes,-d32,-fp-armv8,-fp-armv8d16,-fp-armv8d16sp,-fp-armv8sp,-fp16,-fp16fml,-fullfp16,-neon,-sha2,-thumb-mode,-vfp3,-vfp3d16,-vfp3d16sp,-vfp3sp,-vfp4,-vfp4d16,-vfp4d16sp,-vfp4sp" }
attributes #17 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #18 = { noinline }
attributes #19 = { nounwind memory(none) }
attributes #20 = { nounwind memory(read) }
attributes #21 = { nounwind willreturn }

!swift.module.flags = !{!0}
!llvm.module.flags = !{!1, !2, !3, !4, !5}
!llvm.linker.options = !{}

!0 = !{!"standard-library", i1 false}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 1, !"min_enum_size", i32 4}
!3 = !{i32 8, !"PIC Level", i32 2}
!4 = !{i32 4, !"Objective-C Garbage Collection", i32 100927232}
!5 = !{i32 1, !"Swift Version", i32 7}
