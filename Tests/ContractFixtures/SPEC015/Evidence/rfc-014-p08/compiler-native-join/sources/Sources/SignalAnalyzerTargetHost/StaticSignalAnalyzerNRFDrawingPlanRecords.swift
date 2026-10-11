import GiftUI
import GiftUIRenderCore

package struct StaticSignalAnalyzerNRFPlanCanvasRecord: Equatable {
    package let identity: UInt16
    package let firstStroke: UInt16
    package let strokeCount: UInt16
}

package struct StaticSignalAnalyzerNRFPlanStrokeRecord: Equatable {
    package let canvas: UInt16
    package let firstPoint: UInt16
    package let firstSubpath: UInt16
    package let header: StraightLineStrokeHeader
}

/// Checked little-endian records in the audited 13,536-byte Drawing region.
/// These codecs do not own publication state or bypass stroke validation.
package enum StaticSignalAnalyzerNRFDrawingPlanRecords {
    package static let regionByteCount = 13_536
    package static let maximumCanvases = 5
    package static let maximumStrokes = 5
    package static let maximumPoints = 832
    package static let maximumSubpaths = 16
    package static let canvasOffset = 128
    package static let strokeOffset = 208
    package static let pointOffset = 528
    package static let subpathOffset = 7_184
    package static let usedEnd = 7_248

    package static func stageCanvas(
        _ record: StaticSignalAnalyzerNRFPlanCanvasRecord,
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard
            let offset = slot(
                ordinal, maximum: maximumCanvases, base: canvasOffset,
                stride: 16, region: region
            ), record.identity != 0,
            region[offset ..< offset + 16].allSatisfy({ $0 == 0 })
        else { return false }
        write(record.identity, at: offset, in: region)
        write(record.firstStroke, at: offset + 2, in: region)
        write(record.strokeCount, at: offset + 4, in: region)
        return true
    }

    package static func canvas(
        at ordinal: UInt16, in region: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFPlanCanvasRecord? {
        guard
            let offset = slot(
                ordinal, maximum: maximumCanvases, base: canvasOffset,
                stride: 16, region: region
            ), region[offset + 6 ..< offset + 16].allSatisfy({ $0 == 0 }),
            let identity = word(at: offset, in: region), identity != 0,
            let firstStroke = word(at: offset + 2, in: region),
            let strokeCount = word(at: offset + 4, in: region)
        else { return nil }
        return StaticSignalAnalyzerNRFPlanCanvasRecord(
            identity: identity, firstStroke: firstStroke, strokeCount: strokeCount
        )
    }

    package static func stageStroke(
        _ record: StaticSignalAnalyzerNRFPlanStrokeRecord,
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard
            let offset = slot(
                ordinal, maximum: maximumStrokes, base: strokeOffset,
                stride: 64, region: region
            ), record.canvas != 0, record.header.lineWidth > 0,
            region[offset ..< offset + 64].allSatisfy({ $0 == 0 })
        else { return false }
        let header = record.header
        write(record.canvas, at: offset, in: region)
        write(record.firstPoint, at: offset + 2, in: region)
        write(record.firstSubpath, at: offset + 4, in: region)
        region[offset + 6] = header.color.red
        region[offset + 7] = header.color.green
        region[offset + 8] = header.color.blue
        region[offset + 9] = header.lineCap.rawValue
        region[offset + 10] = header.lineJoin.rawValue
        write(UInt32(bitPattern: header.lineWidth), at: offset + 12, in: region)
        write(header.surfaceOrigin, at: offset + 16, in: region)
        write(header.inheritedClip.origin, at: offset + 24, in: region)
        write(
            UInt32(bitPattern: header.inheritedClip.size.width),
            at: offset + 32, in: region)
        write(
            UInt32(bitPattern: header.inheritedClip.size.height),
            at: offset + 36, in: region)
        write(header.pointCount, at: offset + 40, in: region)
        write(header.subpathCount, at: offset + 42, in: region)
        return true
    }

    package static func stroke(
        at ordinal: UInt16, in region: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFPlanStrokeRecord? {
        guard
            let offset = slot(
                ordinal, maximum: maximumStrokes, base: strokeOffset,
                stride: 64, region: region
            ), region[offset + 11] == 0,
            region[offset + 44 ..< offset + 64].allSatisfy({ $0 == 0 }),
            let canvas = word(at: offset, in: region), canvas != 0,
            let firstPoint = word(at: offset + 2, in: region),
            let firstSubpath = word(at: offset + 4, in: region),
            let cap = LineCap(rawValue: region[offset + 9]),
            let join = LineJoin(rawValue: region[offset + 10]),
            let width = signed32(at: offset + 12, in: region), width > 0,
            let origin = point(at: offset + 16, in: region),
            let clipOrigin = point(at: offset + 24, in: region),
            let clipWidth = signed32(at: offset + 32, in: region),
            let clipHeight = signed32(at: offset + 36, in: region),
            let clipSize = Size(width: clipWidth, height: clipHeight),
            let clip = Rect(origin: clipOrigin, size: clipSize),
            let pointCount = word(at: offset + 40, in: region),
            let subpathCount = word(at: offset + 42, in: region)
        else { return nil }
        let header = StraightLineStrokeHeader(
            color: Color(
                red: region[offset + 6], green: region[offset + 7],
                blue: region[offset + 8]),
            lineWidth: width, lineCap: cap, lineJoin: join,
            surfaceOrigin: origin, inheritedClip: clip,
            pointCount: pointCount, subpathCount: subpathCount
        )
        return StaticSignalAnalyzerNRFPlanStrokeRecord(
            canvas: canvas, firstPoint: firstPoint,
            firstSubpath: firstSubpath, header: header
        )
    }

    package static func stagePoint(
        _ point: Point, at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard
            let offset = slot(
                ordinal, maximum: maximumPoints, base: pointOffset,
                stride: 8, region: region
            ), !pointIsOccupied(ordinal, in: region)
        else { return false }
        write(point, at: offset, in: region)
        let byte = Int(ordinal) / 8
        region[byte] |= UInt8(1 << (ordinal % 8))
        return true
    }

    package static func point(
        at ordinal: UInt16, in region: UnsafeMutableRawBufferPointer
    ) -> Point? {
        guard
            let offset = slot(
                ordinal, maximum: maximumPoints, base: pointOffset,
                stride: 8, region: region
            ), pointIsOccupied(ordinal, in: region)
        else { return nil }
        return point(at: offset, in: region)
    }

    package static func stageSubpath(
        _ subpath: SubpathRange, at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard
            let offset = slot(
                ordinal, maximum: maximumSubpaths, base: subpathOffset,
                stride: 4, region: region
            ), region[offset ..< offset + 4].allSatisfy({ $0 == 0 })
        else { return false }
        write(subpath.firstPoint, at: offset, in: region)
        write(subpath.pointCount, at: offset + 2, in: region)
        return true
    }

    package static func subpath(
        at ordinal: UInt16, in region: UnsafeMutableRawBufferPointer
    ) -> SubpathRange? {
        guard
            let offset = slot(
                ordinal, maximum: maximumSubpaths, base: subpathOffset,
                stride: 4, region: region
            ), let first = word(at: offset, in: region),
            let count = word(at: offset + 2, in: region)
        else { return nil }
        return SubpathRange(firstPoint: first, pointCount: count)
    }

    private static func slot(
        _ ordinal: UInt16, maximum: Int, base: Int, stride: Int,
        region: UnsafeMutableRawBufferPointer
    ) -> Int? {
        guard region.count == regionByteCount, Int(ordinal) < maximum
        else { return nil }
        return base + Int(ordinal) * stride
    }

    private static func pointIsOccupied(
        _ ordinal: UInt16, in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard region.count == regionByteCount, Int(ordinal) < maximumPoints
        else { return false }
        let byte = Int(ordinal) / 8
        return region[byte] & UInt8(1 << (ordinal % 8)) != 0
    }

    private static func word(
        at offset: Int, in region: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        guard offset >= 0, offset + 1 < region.count else { return nil }
        return UInt16(region[offset]) | (UInt16(region[offset + 1]) << 8)
    }

    private static func signed32(
        at offset: Int, in region: UnsafeMutableRawBufferPointer
    ) -> Int32? {
        guard offset >= 0, offset + 3 < region.count else { return nil }
        let value =
            UInt32(region[offset])
            | (UInt32(region[offset + 1]) << 8)
            | (UInt32(region[offset + 2]) << 16)
            | (UInt32(region[offset + 3]) << 24)
        return Int32(bitPattern: value)
    }

    private static func point(
        at offset: Int, in region: UnsafeMutableRawBufferPointer
    ) -> Point? {
        guard let x = signed32(at: offset, in: region),
            let y = signed32(at: offset + 4, in: region)
        else { return nil }
        return Point(x: x, y: y)
    }

    private static func write(
        _ point: Point, at offset: Int,
        in region: UnsafeMutableRawBufferPointer
    ) {
        write(UInt32(bitPattern: point.x), at: offset, in: region)
        write(UInt32(bitPattern: point.y), at: offset + 4, in: region)
    }

    private static func write(
        _ value: UInt16, at offset: Int,
        in region: UnsafeMutableRawBufferPointer
    ) {
        region[offset] = UInt8(truncatingIfNeeded: value)
        region[offset + 1] = UInt8(truncatingIfNeeded: value >> 8)
    }

    private static func write(
        _ value: UInt32, at offset: Int,
        in region: UnsafeMutableRawBufferPointer
    ) {
        region[offset] = UInt8(truncatingIfNeeded: value)
        region[offset + 1] = UInt8(truncatingIfNeeded: value >> 8)
        region[offset + 2] = UInt8(truncatingIfNeeded: value >> 16)
        region[offset + 3] = UInt8(truncatingIfNeeded: value >> 24)
    }
}
