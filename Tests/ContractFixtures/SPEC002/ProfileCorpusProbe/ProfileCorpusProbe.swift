public enum GiftUIFoundationProfileCorpusProbe {
    public static func checksum() -> UInt32 {
        // corpus-case: public-values
        guard publicValuesCase() == 1,
              // corpus-case: construction-rejection
              constructionRejectionCase() == 2,
              // corpus-case: checked-arithmetic
              checkedArithmeticCase() == 3,
              // corpus-case: rectangle-behavior
              rectangleBehaviorCase() == 4,
              // corpus-case: pointer-phases
              pointerPhasesCase() == 5,
              // corpus-case: raw-wrappers
              rawWrappersCase() == 6,
              // corpus-case: normalized-events
              normalizedEventsCase() == 7 else {
            return 0
        }
        return 28
    }

    private static func publicValuesCase() -> UInt32 {
        let first = Point(x: .min, y: .max)
        let copy = first
        guard copy == first,
              copy.x == GeometryScalar.min,
              copy.y == GeometryScalar.max else {
            return 0
        }
        return 1
    }

    private static func constructionRejectionCase() -> UInt32 {
        guard let zero = Size(width: 0, height: 0),
              zero.width == 0,
              zero.height == 0,
              Size(width: -1, height: 0) == nil,
              Size(width: 0, height: -1) == nil,
              let proposal = ProposedSize(width: nil, height: 42),
              proposal.width == nil,
              proposal.height == 42,
              ProposedSize(width: -1, height: nil) == nil,
              ProposedSize(width: nil, height: -1) == nil else {
            return 0
        }
        return 2
    }

    private static func checkedArithmeticCase() -> UInt32 {
        guard GeometryArithmetic.add(20, 22) == 42,
              GeometryArithmetic.add(.max, 1) == nil,
              GeometryArithmetic.add(.min, -1) == nil,
              GeometryArithmetic.subtract(20, -22) == 42,
              GeometryArithmetic.subtract(.min, 1) == nil,
              GeometryArithmetic.subtract(.max, -1) == nil,
              GeometryArithmetic.multiply(6, 7) == 42,
              GeometryArithmetic.multiply(.max, 2) == nil,
              GeometryArithmetic.multiply(.min, -1) == nil else {
            return 0
        }
        return 3
    }

    private static func rectangleBehaviorCase() -> UInt32 {
        guard let unit = Size(width: 1, height: 1),
              let lower = Rect(origin: .init(x: .min, y: .min), size: unit),
              lower.maxX == .min + 1,
              lower.maxY == .min + 1,
              lower.contains(.init(x: .min, y: .min)),
              !lower.contains(.init(x: .min + 1, y: .min)),
              !lower.contains(.init(x: .min, y: .min + 1)),
              let empty = Size(width: 0, height: 0),
              let emptyRect = Rect(origin: .init(x: 0, y: 0), size: empty),
              !emptyRect.contains(.init(x: 0, y: 0)),
              Rect(origin: .init(x: .max, y: 0), size: unit) == nil,
              Rect(origin: .init(x: 0, y: .max), size: unit) == nil else {
            return 0
        }
        return 4
    }

    private static func pointerPhasesCase() -> UInt32 {
        guard PointerPhase.down.rawValue == 0,
              PointerPhase.move.rawValue == 1,
              PointerPhase.up.rawValue == 2 else {
            return 0
        }
        return 5
    }

    private static func rawWrappersCase() -> UInt32 {
        guard InputSourceID(rawValue: .min).rawValue == UInt16.min,
              InputSourceID(rawValue: .max).rawValue == UInt16.max,
              PointerSequenceID(rawValue: .min).rawValue == UInt32.min,
              PointerSequenceID(rawValue: .max).rawValue == UInt32.max,
              InputOrdinal(rawValue: .min).rawValue == UInt32.min,
              InputOrdinal(rawValue: .max).rawValue == UInt32.max,
              PresentationRevision(rawValue: .min).rawValue == UInt32.min,
              PresentationRevision(rawValue: .max).rawValue == UInt32.max else {
            return 0
        }
        return 6
    }

    private static func normalizedEventsCase() -> UInt32 {
        let minimum = NormalizedPointerEvent(
            phase: .down,
            position: .init(x: .min, y: .min),
            source: .init(rawValue: .min),
            sequence: .init(rawValue: .min),
            ordinal: .init(rawValue: .min),
            presentationRevision: .init(rawValue: .min)
        )
        let maximum = NormalizedPointerEvent(
            phase: .up,
            position: .init(x: .max, y: .max),
            source: .init(rawValue: .max),
            sequence: .init(rawValue: .max),
            ordinal: .init(rawValue: .max),
            presentationRevision: .init(rawValue: .max)
        )
        let moving = NormalizedPointerEvent(
            phase: .move,
            position: .init(x: 0, y: 0),
            source: .init(rawValue: 1),
            sequence: .init(rawValue: 1),
            ordinal: .init(rawValue: 1),
            presentationRevision: .init(rawValue: 1)
        )
        guard minimum.phase == .down,
              minimum.position.x == .min,
              minimum.source.rawValue == .min,
              minimum.sequence.rawValue == .min,
              minimum.ordinal.rawValue == .min,
              minimum.presentationRevision.rawValue == .min,
              maximum.phase == .up,
              maximum.position.x == .max,
              maximum.source.rawValue == .max,
              maximum.sequence.rawValue == .max,
              maximum.ordinal.rawValue == .max,
              maximum.presentationRevision.rawValue == .max,
              moving.phase == .move,
              moving.position == Point(x: 0, y: 0) else {
            return 0
        }
        return 7
    }
}
