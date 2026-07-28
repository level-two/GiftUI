import GiftUI

public enum RGB565Rotation: Int, CaseIterable, Sendable {
    case degrees0 = 0
    case degrees90 = 90
    case degrees180 = 180
    case degrees270 = 270
}

public enum RGB565ConfigurationError: Error, Equatable, Sendable {
    case invalidPhysicalWidth(Int)
    case invalidPhysicalHeight(Int)
    case invalidTileHeight(Int)
}

public struct RGB565RendererConfiguration: Equatable, Sendable {
    public static let maximumPhysicalWidth = 480
    public static let maximumPhysicalHeight = 320
    public static let maximumTileHeight = 16
    public static let bytesPerPixel = 2
    public static let maximumTileBufferByteCapacity =
        maximumPhysicalWidth * maximumTileHeight * bytesPerPixel

    public let physicalWidth: Int
    public let physicalHeight: Int
    public let tileHeight: Int
    public let rotation: RGB565Rotation
    public let byteOrder: RGB565ByteOrder

    public var logicalSize: Size {
        switch rotation {
        case .degrees0, .degrees180:
            Size(width: physicalWidth, height: physicalHeight)
        case .degrees90, .degrees270:
            Size(width: physicalHeight, height: physicalWidth)
        }
    }

    public var tileBufferByteCapacity: Int {
        physicalWidth * tileHeight * Self.bytesPerPixel
    }

    public init(
        physicalWidth: Int,
        physicalHeight: Int,
        tileHeight: Int = Self.maximumTileHeight,
        rotation: RGB565Rotation = .degrees0,
        byteOrder: RGB565ByteOrder = .mostSignificantByteFirst
    ) throws(RGB565ConfigurationError) {
        guard physicalWidth > 0,
              physicalWidth <= Self.maximumPhysicalWidth else {
            throw .invalidPhysicalWidth(physicalWidth)
        }
        guard physicalHeight > 0,
              physicalHeight <= Self.maximumPhysicalHeight else {
            throw .invalidPhysicalHeight(physicalHeight)
        }
        guard tileHeight > 0,
              tileHeight <= Self.maximumTileHeight else {
            throw .invalidTileHeight(tileHeight)
        }
        self.physicalWidth = physicalWidth
        self.physicalHeight = physicalHeight
        self.tileHeight = tileHeight
        self.rotation = rotation
        self.byteOrder = byteOrder
    }
}
