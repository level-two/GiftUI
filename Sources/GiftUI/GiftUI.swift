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
              GeometryArithmetic.add(origin.y, size.height) != nil else {
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
        point.x >= minX && point.x < maxX &&
            point.y >= minY && point.y < maxY
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
