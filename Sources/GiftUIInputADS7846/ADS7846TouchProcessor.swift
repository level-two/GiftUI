import GiftUI

public struct ADS7846PressureThreshold: Equatable, Sendable {
    public let minimumZ1: Int
    public let maximumResistance: Int

    public init(minimumZ1: Int = 100, maximumResistance: Int = 4_000) {
        self.minimumZ1 = minimumZ1
        self.maximumResistance = maximumResistance
    }

    public func accepts(_ sample: ADS7846RawSample) -> Bool {
        let z1 = Int(sample.z1)
        let z2 = Int(sample.z2)
        guard z1 >= minimumZ1, z2 > z1 else { return false }
        let resistance = Int(sample.x) * (z2 - z1) / z1
        return resistance <= maximumResistance
    }
}

public enum ADS7846Orientation: Int, Equatable, Sendable {
    case degrees0 = 0
    case degrees90 = 90
    case degrees180 = 180
    case degrees270 = 270

    public func logicalSize(for physicalSize: Size) -> Size {
        switch self {
        case .degrees0, .degrees180:
            physicalSize
        case .degrees90, .degrees270:
            Size(width: physicalSize.height, height: physicalSize.width)
        }
    }

    fileprivate func logicalPoint(
        forPhysicalPoint point: Point,
        physicalSize: Size
    ) -> Point {
        switch self {
        case .degrees0:
            point
        case .degrees90:
            Point(x: point.y, y: physicalSize.width - 1 - point.x)
        case .degrees180:
            Point(
                x: physicalSize.width - 1 - point.x,
                y: physicalSize.height - 1 - point.y
            )
        case .degrees270:
            Point(x: physicalSize.height - 1 - point.y, y: point.x)
        }
    }
}

public struct ADS7846TouchProcessor: Sendable {
    public let calibration: ADS7846Calibration
    public let physicalSize: Size
    public let orientation: ADS7846Orientation
    public let pressureThreshold: ADS7846PressureThreshold

    private var lastPoint: Point?

    public init(
        calibration: ADS7846Calibration,
        physicalSize: Size,
        orientation: ADS7846Orientation = .degrees0,
        pressureThreshold: ADS7846PressureThreshold = .init()
    ) {
        self.calibration = calibration
        self.physicalSize = physicalSize
        self.orientation = orientation
        self.pressureThreshold = pressureThreshold
    }

    public mutating func process(
        penIsDown: Bool,
        first: ADS7846RawSample? = nil,
        second: ADS7846RawSample? = nil,
        third: ADS7846RawSample? = nil
    ) -> InputEvent? {
        guard penIsDown else {
            guard let point = lastPoint else { return nil }
            lastPoint = nil
            return .pointerUp(point)
        }

        guard let first, let second, let third,
              pressureThreshold.accepts(first),
              pressureThreshold.accepts(second),
              pressureThreshold.accepts(third) else {
            return nil
        }
        let filtered = ADS7846RawSample.median(first, second, third)
        guard let physicalPoint = calibration.map(filtered, to: physicalSize)
        else { return nil }
        let logicalPoint = orientation.logicalPoint(
            forPhysicalPoint: physicalPoint,
            physicalSize: physicalSize
        )

        guard let previousPoint = lastPoint else {
            lastPoint = logicalPoint
            return .pointerDown(logicalPoint)
        }
        guard previousPoint != logicalPoint else { return nil }
        lastPoint = logicalPoint
        return .pointerMove(logicalPoint)
    }
}
