import GiftUIRuntimeCore

package enum RuntimeProfileValueLayoutProbe {
    @inline(__always)
    private static func size<T>(of type: T.Type) -> UInt64 {
        UInt64(MemoryLayout<T>.size)
    }

    @inline(never) package static func limitsSize() -> UInt64 { size(of: RuntimeProfileLimits.self) }
    @inline(never) package static func capacitiesSize() -> UInt64 { size(of: RuntimeStorageCapacities.self) }
    @inline(never) package static func byteCountsSize() -> UInt64 { size(of: RuntimeStorageByteCounts.self) }
    @inline(never) package static func auditSize() -> UInt64 { size(of: RuntimeStorageAudit.self) }
    @inline(never) package static func ownerFailureSize() -> UInt64 { size(of: RuntimeOwnerFailure.self) }
}
