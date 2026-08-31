public enum GiftUIFailureDiagnosticsLayoutProbe {
    @inline(never) public static func deliveryCountersSize() -> UInt32 { UInt32(MemoryLayout<GiftUIDiagnosticDeliveryCounters>.size) }
    @inline(never) public static func deliveryCountersStride() -> UInt32 { UInt32(MemoryLayout<GiftUIDiagnosticDeliveryCounters>.stride) }
    @inline(never) public static func deliveryCountersAlignment() -> UInt32 { UInt32(MemoryLayout<GiftUIDiagnosticDeliveryCounters>.alignment) }
    @inline(never) public static func diagnosticProjectorSize() -> UInt32 { UInt32(MemoryLayout<GiftUIDiagnosticProjector<GiftUIFixedDiagnosticBuffer>>.size) }
    @inline(never) public static func diagnosticProjectorStride() -> UInt32 { UInt32(MemoryLayout<GiftUIDiagnosticProjector<GiftUIFixedDiagnosticBuffer>>.stride) }
    @inline(never) public static func diagnosticProjectorAlignment() -> UInt32 { UInt32(MemoryLayout<GiftUIDiagnosticProjector<GiftUIFixedDiagnosticBuffer>>.alignment) }
    @inline(never) public static func fixedDiagnosticBufferSize() -> UInt32 { UInt32(MemoryLayout<GiftUIFixedDiagnosticBuffer>.size) }
    @inline(never) public static func fixedDiagnosticBufferStride() -> UInt32 { UInt32(MemoryLayout<GiftUIFixedDiagnosticBuffer>.stride) }
    @inline(never) public static func fixedDiagnosticBufferAlignment() -> UInt32 { UInt32(MemoryLayout<GiftUIFixedDiagnosticBuffer>.alignment) }
    @inline(never) public static func fixedDiagnosticBufferCapacity() -> UInt8 { GiftUIFixedDiagnosticBuffer.capacity }
}
