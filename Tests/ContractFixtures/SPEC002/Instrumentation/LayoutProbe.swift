public enum GiftUIFoundationLayoutProbe {
    @inline(never) public static func geometryScalarSize() -> UInt32 { UInt32(MemoryLayout<GeometryScalar>.size) }
    @inline(never) public static func geometryScalarStride() -> UInt32 { UInt32(MemoryLayout<GeometryScalar>.stride) }
    @inline(never) public static func geometryScalarAlignment() -> UInt32 { UInt32(MemoryLayout<GeometryScalar>.alignment) }

    @inline(never) public static func pointSize() -> UInt32 { UInt32(MemoryLayout<Point>.size) }
    @inline(never) public static func pointStride() -> UInt32 { UInt32(MemoryLayout<Point>.stride) }
    @inline(never) public static func pointAlignment() -> UInt32 { UInt32(MemoryLayout<Point>.alignment) }

    @inline(never) public static func sizeSize() -> UInt32 { UInt32(MemoryLayout<Size>.size) }
    @inline(never) public static func sizeStride() -> UInt32 { UInt32(MemoryLayout<Size>.stride) }
    @inline(never) public static func sizeAlignment() -> UInt32 { UInt32(MemoryLayout<Size>.alignment) }

    @inline(never) public static func rectSize() -> UInt32 { UInt32(MemoryLayout<Rect>.size) }
    @inline(never) public static func rectStride() -> UInt32 { UInt32(MemoryLayout<Rect>.stride) }
    @inline(never) public static func rectAlignment() -> UInt32 { UInt32(MemoryLayout<Rect>.alignment) }

    @inline(never) public static func proposedByteSize() -> UInt32 { UInt32(MemoryLayout<ProposedSize>.size) }
    @inline(never) public static func proposedStride() -> UInt32 { UInt32(MemoryLayout<ProposedSize>.stride) }
    @inline(never) public static func proposedAlignment() -> UInt32 { UInt32(MemoryLayout<ProposedSize>.alignment) }

    @inline(never) public static func pointerPhaseSize() -> UInt32 { UInt32(MemoryLayout<PointerPhase>.size) }
    @inline(never) public static func pointerPhaseStride() -> UInt32 { UInt32(MemoryLayout<PointerPhase>.stride) }
    @inline(never) public static func pointerPhaseAlignment() -> UInt32 { UInt32(MemoryLayout<PointerPhase>.alignment) }

    @inline(never) public static func inputSourceIDSize() -> UInt32 { UInt32(MemoryLayout<InputSourceID>.size) }
    @inline(never) public static func inputSourceIDStride() -> UInt32 { UInt32(MemoryLayout<InputSourceID>.stride) }
    @inline(never) public static func inputSourceIDAlignment() -> UInt32 { UInt32(MemoryLayout<InputSourceID>.alignment) }

    @inline(never) public static func pointerSequenceIDSize() -> UInt32 { UInt32(MemoryLayout<PointerSequenceID>.size) }
    @inline(never) public static func pointerSequenceIDStride() -> UInt32 { UInt32(MemoryLayout<PointerSequenceID>.stride) }
    @inline(never) public static func pointerSequenceIDAlignment() -> UInt32 { UInt32(MemoryLayout<PointerSequenceID>.alignment) }

    @inline(never) public static func inputOrdinalSize() -> UInt32 { UInt32(MemoryLayout<InputOrdinal>.size) }
    @inline(never) public static func inputOrdinalStride() -> UInt32 { UInt32(MemoryLayout<InputOrdinal>.stride) }
    @inline(never) public static func inputOrdinalAlignment() -> UInt32 { UInt32(MemoryLayout<InputOrdinal>.alignment) }

    @inline(never) public static func presentationRevisionSize() -> UInt32 { UInt32(MemoryLayout<PresentationRevision>.size) }
    @inline(never) public static func presentationRevisionStride() -> UInt32 { UInt32(MemoryLayout<PresentationRevision>.stride) }
    @inline(never) public static func presentationRevisionAlignment() -> UInt32 { UInt32(MemoryLayout<PresentationRevision>.alignment) }

    @inline(never) public static func normalizedPointerEventSize() -> UInt32 { UInt32(MemoryLayout<NormalizedPointerEvent>.size) }
    @inline(never) public static func normalizedPointerEventStride() -> UInt32 { UInt32(MemoryLayout<NormalizedPointerEvent>.stride) }
    @inline(never) public static func normalizedPointerEventAlignment() -> UInt32 { UInt32(MemoryLayout<NormalizedPointerEvent>.alignment) }
}
