#if canImport(GiftUI)
import GiftUI
#endif

public enum GiftUIFoundationOperationProbe {
    @inline(never)
    public static func exercise(seed: UInt32) -> UInt32 {
        let coordinate = GeometryScalar(truncatingIfNeeded: seed)
        guard let size = Size(width: 4, height: 5),
              let proposal = ProposedSize(width: nil, height: coordinate & 7),
              let sum = GeometryArithmetic.add(coordinate, 1),
              let difference = GeometryArithmetic.subtract(sum, 1),
              let product = GeometryArithmetic.multiply(difference, 2),
              let rect = Rect(origin: Point(x: -2, y: 3), size: size) else {
            return 0
        }
        let event = NormalizedPointerEvent(
            phase: PointerPhase(rawValue: UInt8(truncatingIfNeeded: seed % 3))!,
            position: Point(x: coordinate, y: difference),
            source: InputSourceID(rawValue: UInt16(truncatingIfNeeded: seed)),
            sequence: PointerSequenceID(rawValue: seed),
            ordinal: InputOrdinal(rawValue: seed),
            presentationRevision: PresentationRevision(rawValue: seed)
        )
        let rejectionCount: UInt32 =
            Size(width: -1, height: 0) == nil &&
            ProposedSize(width: nil, height: -1) == nil &&
            GeometryArithmetic.add(.max, 1) == nil &&
            Rect(origin: Point(x: .max, y: 0), size: size) == nil ? 4 : 0
        return UInt32(bitPattern: product)
            &+ UInt32(bitPattern: rect.maxX)
            &+ UInt32(event.phase.rawValue)
            &+ UInt32(event.source.rawValue)
            &+ event.sequence.rawValue
            &+ event.ordinal.rawValue
            &+ event.presentationRevision.rawValue
            &+ UInt32(proposal.height ?? 0)
            &+ rejectionCount
    }
}
