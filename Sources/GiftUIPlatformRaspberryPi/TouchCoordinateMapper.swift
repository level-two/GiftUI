import GiftUI
import GiftUIPlatformLinux

public struct TouchAxisRange: Equatable, Sendable {
    public var minimum: Int
    public var maximum: Int

    public init(minimum: Int, maximum: Int) {
        precondition(maximum > minimum, "Touch axis maximum must exceed minimum")
        self.minimum = minimum
        self.maximum = maximum
    }
}

public struct TouchCoordinateMapper: Sendable {
    public let xRange: TouchAxisRange
    public let yRange: TouchAxisRange
    public let physicalSize: Size
    public let logicalSize: Size
    public let rotation: DisplayRotation
    public let swapXY: Bool
    public let invertX: Bool
    public let invertY: Bool

    public init(
        xRange: TouchAxisRange,
        yRange: TouchAxisRange,
        physicalSize: Size,
        logicalSize: Size,
        rotation: DisplayRotation = .degrees0,
        swapXY: Bool = false,
        invertX: Bool = false,
        invertY: Bool = false
    ) {
        precondition(
            physicalSize.width > 0 && physicalSize.height > 0,
            "Physical touch dimensions must be positive"
        )
        precondition(
            logicalSize.width > 0 && logicalSize.height > 0,
            "Logical touch dimensions must be positive"
        )
        self.xRange = xRange
        self.yRange = yRange
        self.physicalSize = physicalSize
        self.logicalSize = logicalSize
        self.rotation = rotation
        self.swapXY = swapXY
        self.invertX = invertX
        self.invertY = invertY
    }

    public func point(rawX: Int, rawY: Int) -> Point? {
        let physicalX: Int
        let physicalY: Int
        if swapXY {
            physicalX = Self.scale(
                rawY,
                range: yRange,
                extent: physicalSize.width,
                inverted: invertX
            )
            physicalY = Self.scale(
                rawX,
                range: xRange,
                extent: physicalSize.height,
                inverted: invertY
            )
        } else {
            physicalX = Self.scale(
                rawX,
                range: xRange,
                extent: physicalSize.width,
                inverted: invertX
            )
            physicalY = Self.scale(
                rawY,
                range: yRange,
                extent: physicalSize.height,
                inverted: invertY
            )
        }

        let rotatedWidth = rotation == .degrees90 || rotation == .degrees270
            ? logicalSize.height
            : logicalSize.width
        let rotatedHeight = rotation == .degrees90 || rotation == .degrees270
            ? logicalSize.width
            : logicalSize.height

        let contentWidth: Int
        let contentHeight: Int
        if physicalSize.width * rotatedHeight <= physicalSize.height * rotatedWidth {
            contentWidth = physicalSize.width
            contentHeight = physicalSize.width * rotatedHeight / rotatedWidth
        } else {
            contentHeight = physicalSize.height
            contentWidth = physicalSize.height * rotatedWidth / rotatedHeight
        }
        let originX = (physicalSize.width - contentWidth) / 2
        let originY = (physicalSize.height - contentHeight) / 2
        guard
            physicalX >= originX,
            physicalX < originX + contentWidth,
            physicalY >= originY,
            physicalY < originY + contentHeight
        else {
            return nil
        }

        let rotatedX = (physicalX - originX) * rotatedWidth / contentWidth
        let rotatedY = (physicalY - originY) * rotatedHeight / contentHeight
        switch rotation {
        case .degrees0:
            return Point(x: rotatedX, y: rotatedY)
        case .degrees90:
            return Point(
                x: rotatedY,
                y: logicalSize.height - 1 - rotatedX
            )
        case .degrees180:
            return Point(
                x: logicalSize.width - 1 - rotatedX,
                y: logicalSize.height - 1 - rotatedY
            )
        case .degrees270:
            return Point(
                x: logicalSize.width - 1 - rotatedY,
                y: rotatedX
            )
        }
    }

    private static func scale(
        _ value: Int,
        range: TouchAxisRange,
        extent: Int,
        inverted: Bool
    ) -> Int {
        let clamped = min(max(value, range.minimum), range.maximum)
        let numerator = Int64(clamped - range.minimum) * Int64(extent - 1)
        let denominator = Int64(range.maximum - range.minimum)
        let scaled = Int(numerator / denominator)
        return inverted ? extent - 1 - scaled : scaled
    }
}
