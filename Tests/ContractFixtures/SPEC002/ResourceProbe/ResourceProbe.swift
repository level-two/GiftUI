@inline(never)
private func mix(_ accumulator: Int32, _ value: Int32) -> Int32 {
    accumulator &* 31 &+ value
}

@_cdecl("giftui_spec002_resource_probe")
public func giftuiSpec002ResourceProbe(_ seed: Int32) -> Int32 {
#if GIFTUI_SPEC002_CANDIDATE
    var checksum = seed

    let point = Point(x: seed, y: seed &+ 1)
    checksum = mix(checksum, point.x)
    checksum = mix(checksum, point.y)

    guard let size = Size(width: 3, height: 4),
          Size(width: -1, height: 0) == nil,
          let rect = Rect(origin: point, size: size),
          let proposed = ProposedSize(width: 8, height: nil) else {
        return -1
    }
    checksum = mix(checksum, size.width)
    checksum = mix(checksum, size.height)
    checksum = mix(checksum, rect.minX)
    checksum = mix(checksum, rect.minY)
    checksum = mix(checksum, rect.maxX)
    checksum = mix(checksum, rect.maxY)
    checksum = mix(checksum, rect.contains(point) ? 1 : 0)
    checksum = mix(checksum, proposed.width ?? -1)
    checksum = mix(checksum, proposed.height ?? -1)

    checksum = mix(checksum, GeometryArithmetic.add(seed, 2) ?? -1)
    checksum = mix(checksum, GeometryArithmetic.subtract(seed, 2) ?? -1)
    checksum = mix(checksum, GeometryArithmetic.multiply(seed, 2) ?? -1)

    let phases: (PointerPhase, PointerPhase, PointerPhase) = (.down, .move, .up)
    checksum = mix(checksum, Int32(phases.0.rawValue))
    checksum = mix(checksum, Int32(phases.1.rawValue))
    checksum = mix(checksum, Int32(phases.2.rawValue))

    let source = InputSourceID(rawValue: 5)
    let sequence = PointerSequenceID(rawValue: 6)
    let ordinal = InputOrdinal(rawValue: 7)
    let revision = PresentationRevision(rawValue: 8)
    let event = NormalizedPointerEvent(
        phase: phases.1,
        position: point,
        source: source,
        sequence: sequence,
        ordinal: ordinal,
        presentationRevision: revision
    )
    checksum = mix(checksum, Int32(event.phase.rawValue))
    checksum = mix(checksum, event.position.x)
    checksum = mix(checksum, Int32(event.source.rawValue))
    checksum = mix(checksum, Int32(event.sequence.rawValue))
    checksum = mix(checksum, Int32(event.ordinal.rawValue))
    checksum = mix(checksum, Int32(event.presentationRevision.rawValue))
    return checksum
#else
    return seed
#endif
}
