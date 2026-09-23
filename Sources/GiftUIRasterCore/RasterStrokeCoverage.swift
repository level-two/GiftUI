import GiftUI
import GiftUIRenderCore
import GiftUISurfaceCore

package enum RasterStrokeResult: Equatable, Sendable {
    case completed(pixelCount: UInt32)
    case invalidGeometry
    case invalidStroke
    case arithmeticOverflow
    case replacementRefused
}

package enum RasterStrokeCoverage {
    private typealias Wide = Int128
    private typealias Magnitude = UInt128

    private static func unsignedDivmod(
        _ numerator: Magnitude, by denominator: Magnitude
    ) -> (quotient: Magnitude, remainder: Magnitude) {
        precondition(denominator > 0)
        #if GIFTUI_NRF_EMBEDDED
            if numerator < denominator { return (0, numerator) }
            var remainder = numerator
            var quotient: Magnitude = 0
            let shift =
                denominator.leadingZeroBitCount
                - numerator.leadingZeroBitCount
            var divisorBit = denominator << shift
            var quotientBit: Magnitude = 1 << shift
            while quotientBit != 0 {
                if remainder >= divisorBit {
                    remainder -= divisorBit
                    quotient |= quotientBit
                }
                divisorBit >>= 1
                quotientBit >>= 1
            }
            return (quotient, remainder)
        #else
            return (numerator / denominator, numerator % denominator)
        #endif
    }

    private static func divideWide(_ numerator: Wide, by denominator: Wide)
        -> Wide
    {
        precondition(denominator > 0)
        #if GIFTUI_NRF_EMBEDDED
            let quotient = unsignedDivmod(
                numerator.magnitude, by: Magnitude(denominator)
            ).quotient
            if numerator < 0 {
                if quotient == Magnitude(1) << 127 { return Wide.min }
                return -Wide(quotient)
            }
            return Wide(quotient)
        #else
            return numerator / denominator
        #endif
    }

    private static let bevelScale: Wide = 1 << 31
    private static let bevelScaleSquared: Magnitude = 1 << 62

    package static func rasterize<Stroke: StraightLineStrokeView>(
        _ stroke: borrowing Stroke,
        descriptor: RasterSurfaceDescriptor,
        damageBounds: Rect,
        _ replace: (Point, CanonicalEncodedPixel) -> Bool
    ) -> RasterStrokeResult {
        let header = stroke.header
        guard header.lineWidth > 0 else { return .invalidStroke }
        guard contains(descriptor.bounds, damageBounds) else {
            return .invalidGeometry
        }
        switch validate(stroke, header: header) {
        case .valid:
            break
        case .invalidStroke:
            return .invalidStroke
        case .arithmeticOverflow:
            return .arithmeticOverflow
        }
        guard
            let covered = RasterFillCoverage.intersection(
                header.inheritedClip,
                damageBounds,
                descriptor.bounds,
                descriptor.bounds
            )
        else {
            return .arithmeticOverflow
        }
        guard covered.size.width > 0, covered.size.height > 0 else {
            return .completed(pixelCount: 0)
        }

        let pixel = CanonicalEncodedPixel(
            color: header.color,
            encoding: descriptor.encoding
        )
        var replaced: UInt32 = 0
        var y = covered.minY
        while y < covered.maxY {
            var x = covered.minX
            while x < covered.maxX {
                switch covers(
                    Point(x: x, y: y),
                    stroke: stroke,
                    header: header
                ) {
                case .covered:
                    guard replace(Point(x: x, y: y), pixel) else {
                        return .replacementRefused
                    }
                    let next = replaced.addingReportingOverflow(1)
                    guard !next.overflow else {
                        return .arithmeticOverflow
                    }
                    replaced = next.partialValue
                case .notCovered:
                    break
                case .invalidStroke:
                    return .invalidStroke
                case .arithmeticOverflow:
                    return .arithmeticOverflow
                }
                x += 1
            }
            y += 1
        }
        return .completed(pixelCount: replaced)
    }

    private enum CoverageResult {
        case covered
        case notCovered
        case invalidStroke
        case arithmeticOverflow
    }

    private enum ValidationResult {
        case valid
        case invalidStroke
        case arithmeticOverflow
    }

    private static func validate<Stroke: StraightLineStrokeView>(
        _ stroke: borrowing Stroke,
        header: StraightLineStrokeHeader
    ) -> ValidationResult {
        if header.pointCount == 0 || header.subpathCount == 0 {
            return header.pointCount == 0 && header.subpathCount == 0
                ? .valid
                : .invalidStroke
        }

        var pointIndex: UInt16 = 0
        while pointIndex < header.pointCount {
            guard let point = stroke.point(at: pointIndex) else {
                return .invalidStroke
            }
            guard translated(point, by: header.surfaceOrigin) != nil else {
                return .arithmeticOverflow
            }
            pointIndex += 1
        }

        var expectedFirstPoint: UInt16 = 0
        var subpathIndex: UInt16 = 0
        while subpathIndex < header.subpathCount {
            guard let subpath = stroke.subpath(at: subpathIndex),
                subpath.firstPoint == expectedFirstPoint
            else { return .invalidStroke }
            let end = subpath.firstPoint.addingReportingOverflow(
                subpath.pointCount
            )
            guard !end.overflow, end.partialValue <= header.pointCount else {
                return .invalidStroke
            }
            expectedFirstPoint = end.partialValue
            subpathIndex += 1
        }
        return expectedFirstPoint == header.pointCount ? .valid : .invalidStroke
    }

    private static func covers<Stroke: StraightLineStrokeView>(
        _ pixel: Point,
        stroke: borrowing Stroke,
        header: StraightLineStrokeHeader
    ) -> CoverageResult {
        let centerX = (Wide(pixel.x) * 2) + 1
        let centerY = (Wide(pixel.y) * 2) + 1
        let width = Wide(header.lineWidth)
        var subpathIndex: UInt16 = 0
        while subpathIndex < header.subpathCount {
            guard let subpath = stroke.subpath(at: subpathIndex) else {
                return .invalidStroke
            }
            switch subpathCovers(
                centerX: centerX,
                centerY: centerY,
                width: width,
                cap: header.lineCap,
                join: header.lineJoin,
                subpath: subpath,
                origin: header.surfaceOrigin,
                stroke: stroke
            ) {
            case .covered:
                return .covered
            case .notCovered:
                break
            case .invalidStroke:
                return .invalidStroke
            case .arithmeticOverflow:
                return .arithmeticOverflow
            }
            subpathIndex += 1
        }
        return .notCovered
    }

    private static func subpathCovers<Stroke: StraightLineStrokeView>(
        centerX: Wide,
        centerY: Wide,
        width: Wide,
        cap: LineCap,
        join: LineJoin,
        subpath: SubpathRange,
        origin: Point,
        stroke: borrowing Stroke
    ) -> CoverageResult {
        guard subpath.pointCount > 1 else { return .notCovered }
        guard let first = stroke.point(at: subpath.firstPoint) else {
            return .invalidStroke
        }
        guard var previousPoint = translated(first, by: origin) else {
            return .arithmeticOverflow
        }

        var firstSegmentStart: Point?
        var lastSegmentStart: Point?
        var lastSegmentEnd: Point?
        let endResult = subpath.firstPoint.addingReportingOverflow(
            subpath.pointCount
        )
        guard !endResult.overflow else { return .invalidStroke }
        let end = endResult.partialValue
        var index = subpath.firstPoint + 1
        while index < end {
            guard let localPoint = stroke.point(at: index) else {
                return .invalidStroke
            }
            guard let point = translated(localPoint, by: origin) else {
                return .arithmeticOverflow
            }
            defer {
                previousPoint = point
                index += 1
            }
            guard point != previousPoint else { continue }

            if segmentCovers(
                centerX: centerX,
                centerY: centerY,
                first: previousPoint,
                second: point,
                width: width
            ) {
                return .covered
            }
            if let lastSegmentStart, let lastSegmentEnd {
                switch joinCovers(
                    centerX: centerX,
                    centerY: centerY,
                    previous: lastSegmentStart,
                    vertex: lastSegmentEnd,
                    following: point,
                    width: width,
                    join: join
                ) {
                case .covered:
                    return .covered
                case .arithmeticOverflow:
                    return .arithmeticOverflow
                case .notCovered, .invalidStroke:
                    break
                }
            }
            if firstSegmentStart == nil {
                firstSegmentStart = previousPoint
            }
            lastSegmentStart = previousPoint
            lastSegmentEnd = point
        }

        guard let firstSegmentStart, let lastSegmentEnd else {
            return .notCovered
        }
        if cap == .round,
            diskCovers(
                centerX: centerX,
                centerY: centerY,
                center: firstSegmentStart,
                width: width
            )
                || diskCovers(
                    centerX: centerX,
                    centerY: centerY,
                    center: lastSegmentEnd,
                    width: width
                )
        {
            return .covered
        }
        return .notCovered
    }

    private static func segmentCovers(
        centerX: Wide,
        centerY: Wide,
        first: Point,
        second: Point,
        width: Wide
    ) -> Bool {
        let dx = Wide(second.x) - Wide(first.x)
        let dy = Wide(second.y) - Wide(first.y)
        let lengthSquared = (dx * dx) + (dy * dy)
        let relativeX = centerX - (Wide(first.x) * 2)
        let relativeY = centerY - (Wide(first.y) * 2)
        let projection = (dx * relativeX) + (dy * relativeY)
        guard projection >= 0, projection <= (2 * lengthSquared) else {
            return false
        }
        let perpendicular = (dx * relativeY) - (dy * relativeX)
        return squareLessThanOrEqual(
            magnitude(perpendicular),
            to: magnitude(width),
            times: Magnitude(lengthSquared)
        )
    }

    private static func diskCovers(
        centerX: Wide,
        centerY: Wide,
        center: Point,
        width: Wide
    ) -> Bool {
        let dx = centerX - (Wide(center.x) * 2)
        let dy = centerY - (Wide(center.y) * 2)
        let distanceSquared = (dx * dx) + (dy * dy)
        let widthMagnitude = magnitude(width)
        return Magnitude(distanceSquared) <= widthMagnitude * widthMagnitude
    }

    private static func joinCovers(
        centerX: Wide,
        centerY: Wide,
        previous: Point,
        vertex: Point,
        following: Point,
        width: Wide,
        join: LineJoin
    ) -> CoverageResult {
        if join == .round {
            return diskCovers(
                centerX: centerX,
                centerY: centerY,
                center: vertex,
                width: width
            ) ? .covered : .notCovered
        }

        let incomingX = Wide(vertex.x) - Wide(previous.x)
        let incomingY = Wide(vertex.y) - Wide(previous.y)
        let outgoingX = Wide(following.x) - Wide(vertex.x)
        let outgoingY = Wide(following.y) - Wide(vertex.y)
        let turn = cross(
            incomingX,
            incomingY,
            outgoingX,
            outgoingY
        )
        guard turn != 0 else { return .notCovered }

        if usesBevelFallback(
            incomingX: incomingX,
            incomingY: incomingY,
            outgoingX: outgoingX,
            outgoingY: outgoingY
        ) {
            return bevelCovers(
                centerX: centerX,
                centerY: centerY,
                vertex: vertex,
                incomingX: incomingX,
                incomingY: incomingY,
                outgoingX: outgoingX,
                outgoingY: outgoingY,
                turn: turn,
                width: width
            )
        }

        let relativeX = centerX - (Wide(vertex.x) * 2)
        let relativeY = centerY - (Wide(vertex.y) * 2)
        var firstDistance = cross(
            incomingX,
            incomingY,
            relativeX,
            relativeY
        )
        var secondDistance = cross(
            outgoingX,
            outgoingY,
            relativeX,
            relativeY
        )
        if turn > 0 {
            firstDistance = -firstDistance
            secondDistance = -secondDistance
        }
        guard firstDistance >= 0, secondDistance >= 0 else {
            return .notCovered
        }
        let widthMagnitude = magnitude(width)
        let firstLength = Magnitude(
            (incomingX * incomingX) + (incomingY * incomingY)
        )
        let secondLength = Magnitude(
            (outgoingX * outgoingX) + (outgoingY * outgoingY)
        )
        return squareLessThanOrEqual(
            magnitude(firstDistance),
            to: widthMagnitude,
            times: firstLength
        )
            && squareLessThanOrEqual(
                magnitude(secondDistance),
                to: widthMagnitude,
                times: secondLength
            ) ? .covered : .notCovered
    }

    private static func usesBevelFallback(
        incomingX: Wide,
        incomingY: Wide,
        outgoingX: Wide,
        outgoingY: Wide
    ) -> Bool {
        let dot = (incomingX * outgoingX) + (incomingY * outgoingY)
        guard dot < 0 else { return false }
        let magnitude = Magnitude(-dot)
        let firstLength = Magnitude(
            (incomingX * incomingX) + (incomingY * incomingY)
        )
        let secondLength = Magnitude(
            (outgoingX * outgoingX) + (outgoingY * outgoingY)
        )
        return !fractionLessThanOrEqual(
            numerator: 50 * magnitude,
            denominator: 49 * firstLength,
            otherNumerator: 49 * secondLength,
            otherDenominator: 50 * magnitude
        )
    }

    private static func bevelCovers(
        centerX: Wide,
        centerY: Wide,
        vertex: Point,
        incomingX: Wide,
        incomingY: Wide,
        outgoingX: Wide,
        outgoingY: Wide,
        turn: Wide,
        width: Wide
    ) -> CoverageResult {
        let side: Wide = turn > 0 ? 1 : -1
        guard
            let firstCorner = offsetCorner(
                vertex: vertex,
                dx: incomingX,
                dy: incomingY,
                width: width,
                side: side
            ),
            let secondCorner = offsetCorner(
                vertex: vertex,
                dx: outgoingX,
                dy: outgoingY,
                width: width,
                side: side
            )
        else { return .arithmeticOverflow }

        let point = (
            x: divideWide(centerX * bevelScale, by: 2),
            y: divideWide(centerY * bevelScale, by: 2)
        )
        let scaledVertex = (
            x: Wide(vertex.x) * bevelScale,
            y: Wide(vertex.y) * bevelScale
        )
        return triangleContains(
            point,
            scaledVertex,
            firstCorner,
            secondCorner
        ) ? .covered : .notCovered
    }

    private static func offsetCorner(
        vertex: Point,
        dx: Wide,
        dy: Wide,
        width: Wide,
        side: Wide
    ) -> (x: Wide, y: Wide)? {
        let lengthSquared = Magnitude((dx * dx) + (dy * dy))
        let radicand = lengthSquared.multipliedReportingOverflow(
            by: bevelScaleSquared
        )
        guard !radicand.overflow else { return nil }
        let root = integerSquareRoot(radicand.partialValue)
        guard root > 0, root <= Magnitude(Wide.max >> 1) else { return nil }
        let denominator = Wide(root) * 2
        let scaleSquared = Wide(bevelScaleSquared)
        guard
            let offsetX = roundedDivide(
                side * dy * width * scaleSquared,
                by: denominator
            ),
            let offsetY = roundedDivide(
                side * -dx * width * scaleSquared,
                by: denominator
            )
        else { return nil }
        let vertexX = Wide(vertex.x) * bevelScale
        let vertexY = Wide(vertex.y) * bevelScale
        let cornerX = vertexX.addingReportingOverflow(offsetX)
        let cornerY = vertexY.addingReportingOverflow(offsetY)
        guard !cornerX.overflow, !cornerY.overflow else { return nil }
        return (cornerX.partialValue, cornerY.partialValue)
    }

    private static func roundedDivide(
        _ numerator: Wide,
        by denominator: Wide
    ) -> Wide? {
        guard denominator > 0 else { return nil }
        let half = divideWide(denominator, by: 2)
        if numerator >= 0 {
            let adjusted = numerator.addingReportingOverflow(half)
            return adjusted.overflow
                ? nil : divideWide(adjusted.partialValue, by: denominator)
        }
        let adjusted = numerator.subtractingReportingOverflow(half)
        return adjusted.overflow
            ? nil : divideWide(adjusted.partialValue, by: denominator)
    }

    private static func triangleContains(
        _ point: (x: Wide, y: Wide),
        _ first: (x: Wide, y: Wide),
        _ second: (x: Wide, y: Wide),
        _ third: (x: Wide, y: Wide)
    ) -> Bool {
        let firstCross = edgeCross(first, second, point)
        let secondCross = edgeCross(second, third, point)
        let thirdCross = edgeCross(third, first, point)
        let hasNegative = firstCross < 0 || secondCross < 0 || thirdCross < 0
        let hasPositive = firstCross > 0 || secondCross > 0 || thirdCross > 0
        return !(hasNegative && hasPositive)
    }

    private static func edgeCross(
        _ first: (x: Wide, y: Wide),
        _ second: (x: Wide, y: Wide),
        _ point: (x: Wide, y: Wide)
    ) -> Wide {
        cross(
            second.x - first.x,
            second.y - first.y,
            point.x - first.x,
            point.y - first.y
        )
    }

    private static func cross(
        _ firstX: Wide,
        _ firstY: Wide,
        _ secondX: Wide,
        _ secondY: Wide
    ) -> Wide {
        (firstX * secondY) - (firstY * secondX)
    }

    private static func magnitude(_ value: Wide) -> Magnitude {
        Magnitude(value < 0 ? -value : value)
    }

    private static func squareLessThanOrEqual(
        _ value: Magnitude,
        to factor: Magnitude,
        times otherFactor: Magnitude
    ) -> Bool {
        guard value > 0 else { return true }
        return fractionLessThanOrEqual(
            numerator: value,
            denominator: otherFactor,
            otherNumerator: factor * factor,
            otherDenominator: value
        )
    }

    private static func fractionLessThanOrEqual(
        numerator: Magnitude,
        denominator: Magnitude,
        otherNumerator: Magnitude,
        otherDenominator: Magnitude
    ) -> Bool {
        precondition(denominator > 0 && otherDenominator > 0)
        var leftNumerator = numerator
        var leftDenominator = denominator
        var rightNumerator = otherNumerator
        var rightDenominator = otherDenominator
        var reversed = false
        while true {
            let left = unsignedDivmod(leftNumerator, by: leftDenominator)
            let right = unsignedDivmod(rightNumerator, by: rightDenominator)
            let leftQuotient = left.quotient
            let rightQuotient = right.quotient
            if leftQuotient != rightQuotient {
                return reversed
                    ? leftQuotient > rightQuotient
                    : leftQuotient < rightQuotient
            }
            let leftRemainder = left.remainder
            let rightRemainder = right.remainder
            if leftRemainder == 0 || rightRemainder == 0 {
                if leftRemainder == 0 && rightRemainder == 0 {
                    return true
                }
                return reversed
                    ? leftRemainder != 0
                    : leftRemainder == 0
            }
            leftNumerator = leftDenominator
            leftDenominator = leftRemainder
            rightNumerator = rightDenominator
            rightDenominator = rightRemainder
            reversed.toggle()
        }
    }

    private static func integerSquareRoot(_ value: Magnitude) -> Magnitude {
        guard value > 1 else { return value }
        let significantBits = Magnitude.bitWidth - value.leadingZeroBitCount
        var estimate: Magnitude = 1 << ((significantBits + 1) / 2)
        while true {
            let next =
                (estimate + unsignedDivmod(value, by: estimate).quotient)
                >> 1
            if next >= estimate { return estimate }
            estimate = next
        }
    }

    private static func translated(_ point: Point, by origin: Point) -> Point? {
        let x = point.x.addingReportingOverflow(origin.x)
        let y = point.y.addingReportingOverflow(origin.y)
        guard !x.overflow, !y.overflow else { return nil }
        return Point(x: x.partialValue, y: y.partialValue)
    }

    private static func contains(_ outer: Rect, _ inner: Rect) -> Bool {
        inner.minX >= outer.minX && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX && inner.maxY <= outer.maxY
    }
}
