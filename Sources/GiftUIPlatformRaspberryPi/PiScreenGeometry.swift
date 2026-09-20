import GiftUI

package struct PiScreenFramebufferLayout: Equatable, Sendable {
    package let width: UInt16
    package let height: UInt16
    package let bitsPerPixel: UInt8
    package let bytesPerRow: UInt32
    package let mappedBytes: UInt32

    package init?(
        width: UInt16,
        height: UInt16,
        bitsPerPixel: UInt8,
        bytesPerRow: UInt32,
        mappedBytes: UInt32
    ) {
        guard width > 0, height > 0, bitsPerPixel == 16 else { return nil }
        let minimumRow = UInt32(width).multipliedReportingOverflow(by: 2)
        guard !minimumRow.overflow, bytesPerRow >= minimumRow.partialValue else { return nil }
        let required = bytesPerRow.multipliedReportingOverflow(by: UInt32(height))
        guard !required.overflow, mappedBytes >= required.partialValue else { return nil }
        self.width = width
        self.height = height
        self.bitsPerPixel = bitsPerPixel
        self.bytesPerRow = bytesPerRow
        self.mappedBytes = mappedBytes
    }
}

package struct PiScreenTouchCalibration: Equatable, Sendable {
    package let minimumX: Int32
    package let maximumX: Int32
    package let minimumY: Int32
    package let maximumY: Int32
    package let swapXY: Bool
    package let invertX: Bool
    package let invertY: Bool

    package init?(
        minimumX: Int32,
        maximumX: Int32,
        minimumY: Int32,
        maximumY: Int32,
        swapXY: Bool = false,
        invertX: Bool = false,
        invertY: Bool = false
    ) {
        guard maximumX > minimumX, maximumY > minimumY else { return nil }
        self.minimumX = minimumX
        self.maximumX = maximumX
        self.minimumY = minimumY
        self.maximumY = maximumY
        self.swapXY = swapXY
        self.invertX = invertX
        self.invertY = invertY
    }
}

package struct PiScreenAspectFitTransform: Equatable, Sendable {
    package let physicalWidth: Int32
    package let physicalHeight: Int32
    package let logicalWidth: Int32
    package let logicalHeight: Int32
    package let contentOriginX: Int32
    package let contentOriginY: Int32
    package let contentWidth: Int32
    package let contentHeight: Int32

    package init?(
        physicalWidth: Int32,
        physicalHeight: Int32,
        logicalWidth: Int32,
        logicalHeight: Int32
    ) {
        guard physicalWidth > 0, physicalHeight > 0, logicalWidth > 0, logicalHeight > 0
        else { return nil }
        let widthLimited =
            Int64(physicalWidth) * Int64(logicalHeight)
            <= Int64(physicalHeight) * Int64(logicalWidth)
        let contentWidth: Int32
        let contentHeight: Int32
        if widthLimited {
            contentWidth = physicalWidth
            contentHeight = Int32(
                Int64(physicalWidth) * Int64(logicalHeight) / Int64(logicalWidth)
            )
        } else {
            contentHeight = physicalHeight
            contentWidth = Int32(
                Int64(physicalHeight) * Int64(logicalWidth) / Int64(logicalHeight)
            )
        }
        guard contentWidth > 0, contentHeight > 0 else { return nil }
        self.physicalWidth = physicalWidth
        self.physicalHeight = physicalHeight
        self.logicalWidth = logicalWidth
        self.logicalHeight = logicalHeight
        self.contentOriginX = (physicalWidth - contentWidth) / 2
        self.contentOriginY = (physicalHeight - contentHeight) / 2
        self.contentWidth = contentWidth
        self.contentHeight = contentHeight
    }

    package func logicalPoint(
        rawX: Int32,
        rawY: Int32,
        calibration: PiScreenTouchCalibration
    ) -> Point? {
        let calibratedX = Self.scaled(
            calibration.swapXY ? rawY : rawX,
            minimum: calibration.swapXY ? calibration.minimumY : calibration.minimumX,
            maximum: calibration.swapXY ? calibration.maximumY : calibration.maximumX,
            extent: physicalWidth,
            inverted: calibration.invertX
        )
        let calibratedY = Self.scaled(
            calibration.swapXY ? rawX : rawY,
            minimum: calibration.swapXY ? calibration.minimumX : calibration.minimumY,
            maximum: calibration.swapXY ? calibration.maximumX : calibration.maximumY,
            extent: physicalHeight,
            inverted: calibration.invertY
        )
        guard calibratedX >= contentOriginX,
            calibratedX < contentOriginX + contentWidth,
            calibratedY >= contentOriginY,
            calibratedY < contentOriginY + contentHeight
        else { return nil }
        return Point(
            x: (calibratedX - contentOriginX) * logicalWidth / contentWidth,
            y: (calibratedY - contentOriginY) * logicalHeight / contentHeight
        )
    }

    package func physicalBounds(origin: Point, pixelCount: UInt16) -> Rect? {
        guard origin.x >= 0, origin.y >= 0, origin.x < logicalWidth,
            origin.y < logicalHeight, pixelCount > 0,
            Int64(origin.x) + Int64(pixelCount) <= Int64(logicalWidth)
        else { return nil }
        let startX =
            contentOriginX
            + Self.lowerBoundary(
                origin.x, destination: contentWidth, source: logicalWidth)
        let endX =
            contentOriginX
            + Self.upperBoundary(
                origin.x + Int32(pixelCount), destination: contentWidth, source: logicalWidth)
        let startY =
            contentOriginY
            + Self.lowerBoundary(
                origin.y, destination: contentHeight, source: logicalHeight)
        let endY =
            contentOriginY
            + Self.upperBoundary(
                origin.y + 1, destination: contentHeight, source: logicalHeight)
        guard let size = Size(width: endX - startX, height: endY - startY) else { return nil }
        return Rect(origin: Point(x: startX, y: startY), size: size)
    }

    private static func scaled(
        _ value: Int32,
        minimum: Int32,
        maximum: Int32,
        extent: Int32,
        inverted: Bool
    ) -> Int32 {
        let clamped = min(max(value, minimum), maximum)
        let scaled = Int32(
            Int64(clamped - minimum) * Int64(extent - 1) / Int64(maximum - minimum)
        )
        return inverted ? extent - 1 - scaled : scaled
    }

    private static func lowerBoundary(
        _ value: Int32,
        destination: Int32,
        source: Int32
    ) -> Int32 {
        Int32(Int64(value) * Int64(destination) / Int64(source))
    }

    private static func upperBoundary(
        _ value: Int32,
        destination: Int32,
        source: Int32
    ) -> Int32 {
        Int32(
            (Int64(value) * Int64(destination) + Int64(source) - 1) / Int64(source)
        )
    }
}

package struct PiScreenContactEvent: Equatable, Sendable {
    package let phase: PointerPhase
    package let point: Point
}

package struct PiScreenContactDecoder: Sendable {
    private var activePoint: Point?

    package init() {}

    package mutating func update(point: Point?, touching: Bool) -> PiScreenContactEvent? {
        switch (activePoint, touching, point) {
        case (nil, true, .some(let point)):
            activePoint = point
            return PiScreenContactEvent(phase: .down, point: point)
        case (.some, true, .some(let point)):
            activePoint = point
            return PiScreenContactEvent(phase: .move, point: point)
        case (.some(let previous), false, _), (.some(let previous), true, nil):
            activePoint = nil
            return PiScreenContactEvent(phase: .up, point: previous)
        case (nil, false, _), (nil, true, nil):
            return nil
        }
    }
}
