public typealias GeometryScalar = Int32

public struct Point: Equatable, Hashable, Sendable {
    public let x: GeometryScalar
    public let y: GeometryScalar

    public init(x: GeometryScalar, y: GeometryScalar) {
        self.x = x
        self.y = y
    }
}

public struct Size: Equatable, Hashable, Sendable {
    public let width: GeometryScalar
    public let height: GeometryScalar

    public init?(width: GeometryScalar, height: GeometryScalar) {
        guard width >= 0, height >= 0 else {
            return nil
        }
        self.width = width
        self.height = height
    }
}

public struct Rect: Equatable, Hashable, Sendable {
    public let origin: Point
    public let size: Size

    public init?(origin: Point, size: Size) {
        guard GeometryArithmetic.add(origin.x, size.width) != nil,
            GeometryArithmetic.add(origin.y, size.height) != nil
        else {
            return nil
        }
        self.origin = origin
        self.size = size
    }

    public var minX: GeometryScalar { origin.x }
    public var minY: GeometryScalar { origin.y }

    public var maxX: GeometryScalar {
        // Construction establishes this invariant. The fallback is defensive
        // and keeps the accessor total without adding cached storage to Rect.
        GeometryArithmetic.add(origin.x, size.width) ?? origin.x
    }

    public var maxY: GeometryScalar {
        GeometryArithmetic.add(origin.y, size.height) ?? origin.y
    }

    public func contains(_ point: Point) -> Bool {
        point.x >= minX && point.x < maxX && point.y >= minY && point.y < maxY
    }
}

public struct ProposedSize: Equatable, Hashable, Sendable {
    public let width: GeometryScalar?
    public let height: GeometryScalar?

    public init?(
        width: GeometryScalar? = nil,
        height: GeometryScalar? = nil
    ) {
        if let width, width < 0 {
            return nil
        }
        if let height, height < 0 {
            return nil
        }
        self.width = width
        self.height = height
    }
}

package enum GeometryArithmetic {
    package static func add(
        _ lhs: GeometryScalar,
        _ rhs: GeometryScalar
    ) -> GeometryScalar? {
        let result = lhs.addingReportingOverflow(rhs)
        return result.overflow ? nil : result.partialValue
    }

    package static func subtract(
        _ lhs: GeometryScalar,
        _ rhs: GeometryScalar
    ) -> GeometryScalar? {
        let result = lhs.subtractingReportingOverflow(rhs)
        return result.overflow ? nil : result.partialValue
    }

    package static func multiply(
        _ lhs: GeometryScalar,
        _ rhs: GeometryScalar
    ) -> GeometryScalar? {
        let result = lhs.multipliedReportingOverflow(by: rhs)
        return result.overflow ? nil : result.partialValue
    }
}

package enum PointerPhase: UInt8, Equatable, Sendable {
    case down = 0
    case move = 1
    case up = 2
}

package struct InputSourceID: Equatable, Hashable, Sendable {
    package let rawValue: UInt16

    package init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

package struct PointerSequenceID: Equatable, Hashable, Sendable {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

package struct InputOrdinal: Equatable, Hashable, Sendable {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

package struct PresentationRevision: Equatable, Hashable, Sendable {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

package struct NormalizedPointerEvent: Equatable, Sendable {
    package let phase: PointerPhase
    package let position: Point
    package let source: InputSourceID
    package let sequence: PointerSequenceID
    package let ordinal: InputOrdinal
    package let presentationRevision: PresentationRevision

    package init(
        phase: PointerPhase,
        position: Point,
        source: InputSourceID,
        sequence: PointerSequenceID,
        ordinal: InputOrdinal,
        presentationRevision: PresentationRevision
    ) {
        self.phase = phase
        self.position = position
        self.source = source
        self.sequence = sequence
        self.ordinal = ordinal
        self.presentationRevision = presentationRevision
    }
}
