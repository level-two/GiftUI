import GiftUI

func event(
    phase: PointerPhase,
    coordinate: GeometryScalar,
    source: UInt16,
    correlation: UInt32
) -> NormalizedPointerEvent {
    NormalizedPointerEvent(
        phase: phase,
        position: Point(x: coordinate, y: coordinate),
        source: InputSourceID(rawValue: source),
        sequence: PointerSequenceID(rawValue: correlation),
        ordinal: InputOrdinal(rawValue: correlation),
        presentationRevision: PresentationRevision(rawValue: correlation)
    )
}

_ = event(phase: .down, coordinate: .min, source: .min, correlation: .min)
_ = event(phase: .move, coordinate: 0, source: 1, correlation: 1)
_ = event(phase: .up, coordinate: .max, source: .max, correlation: .max)
