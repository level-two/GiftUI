import GiftUI

public struct ADS7846CalibrationSamples: Equatable, Sendable {
    public let topLeft: ADS7846RawSample
    public let topRight: ADS7846RawSample
    public let bottomLeft: ADS7846RawSample
    public let bottomRight: ADS7846RawSample
    public let center: ADS7846RawSample

    public init(
        topLeft: ADS7846RawSample,
        topRight: ADS7846RawSample,
        bottomLeft: ADS7846RawSample,
        bottomRight: ADS7846RawSample,
        center: ADS7846RawSample
    ) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
        self.center = center
    }
}

public enum ADS7846CalibrationError: Error, Equatable, Sendable {
    case insufficientHorizontalSpan(minimum: Int, actual: Int)
    case insufficientVerticalSpan(minimum: Int, actual: Int)
    case inconsistentCenter
}

public struct ADS7846Calibration: Equatable, Sendable {
    public let rawXAtLeft: Int
    public let rawXAtRight: Int
    public let rawYAtTop: Int
    public let rawYAtBottom: Int

    public init(
        samples: ADS7846CalibrationSamples,
        minimumSpan: Int = 256
    ) throws(ADS7846CalibrationError) {
        let rawXAtLeft = Self.average(
            Int(samples.topLeft.x),
            Int(samples.bottomLeft.x)
        )
        let rawXAtRight = Self.average(
            Int(samples.topRight.x),
            Int(samples.bottomRight.x)
        )
        let rawYAtTop = Self.average(
            Int(samples.topLeft.y),
            Int(samples.topRight.y)
        )
        let rawYAtBottom = Self.average(
            Int(samples.bottomLeft.y),
            Int(samples.bottomRight.y)
        )

        let horizontalSpan = Self.magnitude(rawXAtRight - rawXAtLeft)
        guard horizontalSpan >= minimumSpan else {
            throw .insufficientHorizontalSpan(
                minimum: minimumSpan,
                actual: horizontalSpan
            )
        }
        let verticalSpan = Self.magnitude(rawYAtBottom - rawYAtTop)
        guard verticalSpan >= minimumSpan else {
            throw .insufficientVerticalSpan(
                minimum: minimumSpan,
                actual: verticalSpan
            )
        }

        let expectedCenterX = Self.average(rawXAtLeft, rawXAtRight)
        let expectedCenterY = Self.average(rawYAtTop, rawYAtBottom)
        guard Self.magnitude(Int(samples.center.x) - expectedCenterX)
                <= horizontalSpan / 4,
              Self.magnitude(Int(samples.center.y) - expectedCenterY)
                <= verticalSpan / 4 else {
            throw .inconsistentCenter
        }

        self.rawXAtLeft = rawXAtLeft
        self.rawXAtRight = rawXAtRight
        self.rawYAtTop = rawYAtTop
        self.rawYAtBottom = rawYAtBottom
    }

    public func map(
        _ sample: ADS7846RawSample,
        to size: Size
    ) -> Point? {
        guard size.width > 0, size.height > 0 else { return nil }
        return Point(
            x: Self.mapAxis(
                Int(sample.x),
                near: rawXAtLeft,
                far: rawXAtRight,
                extent: size.width
            ),
            y: Self.mapAxis(
                Int(sample.y),
                near: rawYAtTop,
                far: rawYAtBottom,
                extent: size.height
            )
        )
    }

    private static func average(_ first: Int, _ second: Int) -> Int {
        (first + second) / 2
    }

    private static func magnitude(_ value: Int) -> Int {
        value < 0 ? -value : value
    }

    private static func mapAxis(
        _ value: Int,
        near: Int,
        far: Int,
        extent: Int
    ) -> Int {
        let mapped = (value - near) * (extent - 1) / (far - near)
        if mapped < 0 { return 0 }
        if mapped >= extent { return extent - 1 }
        return mapped
    }
}
