import GiftUI
import GiftUIDrawing
import GiftUIRenderCore

/// One transient Canvas path in the caller-owned 3,280-byte profile region.
/// Counts live in this scoped value; no path point or subpath escapes the borrow.
package struct StaticSignalAnalyzerNRFLivePathStorage: LivePathStorage {
    package let maximumPointCount: UInt16 = 202
    package let maximumSubpathCount: UInt16 = 12
    package private(set) var pointCount: UInt16 = 0
    package private(set) var subpathCount: UInt16 = 0

    private let region: UnsafeMutableRawBufferPointer
    private static let pointStride = 8
    private static let subpathStride = 4
    private static let subpathOffset = 202 * pointStride
    package static let regionByteCount = 3_280

    package init?(region: UnsafeMutableRawBufferPointer) {
        guard region.count == Self.regionByteCount else { return nil }
        self.region = region
        region.initializeMemory(as: UInt8.self, repeating: 0)
    }

    package func point(at index: UInt16) -> Point? {
        guard index < pointCount else { return nil }
        let offset = Int(index) * Self.pointStride
        return Point(x: signed32(at: offset), y: signed32(at: offset + 4))
    }

    package func subpath(at index: UInt16) -> SubpathRange? {
        guard index < subpathCount else { return nil }
        let offset = Self.subpathOffset + Int(index) * Self.subpathStride
        return SubpathRange(
            firstPoint: word(at: offset),
            pointCount: word(at: offset + 2))
    }

    package mutating func startFirstSubpath(at point: Point) -> Bool {
        guard pointCount == 0, subpathCount == 0 else { return false }
        write(point, at: 0)
        write(UInt16(0), at: Self.subpathOffset)
        write(UInt16(1), at: Self.subpathOffset + 2)
        pointCount = 1
        subpathCount = 1
        return true
    }

    package mutating func replaceCurrentSubpathStart(with point: Point) -> Bool {
        guard subpathCount > 0, pointCount > 0,
            let current = subpath(at: subpathCount - 1),
            current.pointCount == 1,
            current.firstPoint == pointCount - 1
        else { return false }
        write(point, at: Int(current.firstPoint) * Self.pointStride)
        return true
    }

    package mutating func startNextSubpath(at point: Point) -> Bool {
        guard subpathCount > 0, subpathCount < maximumSubpathCount,
            pointCount < maximumPointCount,
            let current = subpath(at: subpathCount - 1),
            !current.firstPoint.addingReportingOverflow(current.pointCount).overflow,
            current.firstPoint.addingReportingOverflow(current.pointCount).partialValue
                == pointCount,
            current.pointCount > 1
        else { return false }
        write(point, at: Int(pointCount) * Self.pointStride)
        let offset = Self.subpathOffset + Int(subpathCount) * Self.subpathStride
        write(pointCount, at: offset)
        write(UInt16(1), at: offset + 2)
        pointCount += 1
        subpathCount += 1
        return true
    }

    package mutating func appendLine(to point: Point) -> Bool {
        guard subpathCount > 0, pointCount < maximumPointCount,
            let current = subpath(at: subpathCount - 1),
            !current.firstPoint.addingReportingOverflow(current.pointCount).overflow,
            current.firstPoint.addingReportingOverflow(current.pointCount).partialValue
                == pointCount,
            current.pointCount < UInt16.max
        else { return false }
        write(point, at: Int(pointCount) * Self.pointStride)
        let offset = Self.subpathOffset + Int(subpathCount - 1) * Self.subpathStride
        write(current.pointCount + 1, at: offset + 2)
        pointCount += 1
        return true
    }

    package mutating func reset() {
        region.initializeMemory(as: UInt8.self, repeating: 0)
        pointCount = 0
        subpathCount = 0
    }

    private func word(at offset: Int) -> UInt16 {
        UInt16(region[offset]) | (UInt16(region[offset + 1]) << 8)
    }

    private func signed32(at offset: Int) -> GeometryScalar {
        let value =
            UInt32(region[offset])
            | (UInt32(region[offset + 1]) << 8)
            | (UInt32(region[offset + 2]) << 16)
            | (UInt32(region[offset + 3]) << 24)
        return Int32(bitPattern: value)
    }

    private func write(_ point: Point, at offset: Int) {
        write(UInt32(bitPattern: point.x), at: offset)
        write(UInt32(bitPattern: point.y), at: offset + 4)
    }

    private func write(_ value: UInt16, at offset: Int) {
        region[offset] = UInt8(truncatingIfNeeded: value)
        region[offset + 1] = UInt8(truncatingIfNeeded: value >> 8)
    }

    private func write(_ value: UInt32, at offset: Int) {
        region[offset] = UInt8(truncatingIfNeeded: value)
        region[offset + 1] = UInt8(truncatingIfNeeded: value >> 8)
        region[offset + 2] = UInt8(truncatingIfNeeded: value >> 16)
        region[offset + 3] = UInt8(truncatingIfNeeded: value >> 24)
    }
}
