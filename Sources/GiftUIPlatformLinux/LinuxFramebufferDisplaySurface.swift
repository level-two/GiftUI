import CGiftUILinux
import GiftUI
import GiftUIBackendFramebuffer
import GiftUIBackendRGB565

public final class LinuxFramebufferDisplaySurface: RGB565TileDisplaySurface {
    public let logicalSize: Size
    public let devicePath: String
    public let rotation: DisplayRotation
    public let physicalWidth: Int
    public let physicalHeight: Int
    public let bitsPerPixel: Int
    public let rgb565RendererConfiguration: RGB565RendererConfiguration?

    private let device: OpaquePointer

    public init(
        devicePath: String,
        logicalSize: Size,
        rotation: DisplayRotation = .degrees0
    ) throws {
        guard logicalSize.width > 0, logicalSize.height > 0 else {
            throw LinuxPlatformError("logical display dimensions must be positive")
        }
        guard
            Int32(exactly: logicalSize.width) != nil,
            Int32(exactly: logicalSize.height) != nil
        else {
            throw LinuxPlatformError("logical display dimensions exceed Linux limits")
        }

        var openedDevice: OpaquePointer?
        var errorBuffer = [CChar](repeating: 0, count: 256)
        let result = errorBuffer.withUnsafeMutableBufferPointer { errorPointer in
            devicePath.withCString { pathPointer in
                giftui_fb_open(
                    pathPointer,
                    &openedDevice,
                    errorPointer.baseAddress,
                    errorPointer.count
                )
            }
        }
        guard result == 0, let openedDevice else {
            throw LinuxPlatformError(Self.message(from: errorBuffer))
        }

        device = openedDevice
        self.devicePath = devicePath
        self.logicalSize = logicalSize
        self.rotation = rotation
        physicalWidth = Int(giftui_fb_width(openedDevice))
        physicalHeight = Int(giftui_fb_height(openedDevice))
        bitsPerPixel = Int(giftui_fb_bits_per_pixel(openedDevice))
        rgb565RendererConfiguration = try? RGB565RendererConfiguration(
            physicalWidth: logicalSize.width,
            physicalHeight: logicalSize.height,
            tileHeight: RGB565RendererConfiguration.maximumTileHeight,
            byteOrder: .mostSignificantByteFirst
        )
    }

    deinit {
        giftui_fb_close(device)
    }

    public func present(framebuffer: MemoryFramebufferSurface) throws {
        guard
            framebuffer.width == logicalSize.width,
            framebuffer.height == logicalSize.height
        else {
            throw LinuxPlatformError(
                "framebuffer \(framebuffer.width)x\(framebuffer.height) does not match "
                    + "logical display \(logicalSize.width)x\(logicalSize.height)"
            )
        }

        var errorBuffer = [CChar](repeating: 0, count: 256)
        let result = framebuffer.withUnsafeBytes { bytes in
            errorBuffer.withUnsafeMutableBufferPointer { errorPointer in
                giftui_fb_present_rgba(
                    device,
                    bytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    Int32(framebuffer.width),
                    Int32(framebuffer.height),
                    Int32(framebuffer.bytesPerRow),
                    Int32(rotation.rawValue),
                    errorPointer.baseAddress,
                    errorPointer.count
                )
            }
        }
        guard result == 0 else {
            throw LinuxPlatformError(Self.message(from: errorBuffer))
        }
    }

    public func prepareRGB565Frame(isFullRefresh: Bool) throws {
        guard isFullRefresh else { return }

        var errorBuffer = [CChar](repeating: 0, count: 256)
        let result = errorBuffer.withUnsafeMutableBufferPointer { errorPointer in
            giftui_fb_clear(
                device,
                0,
                0,
                0,
                255,
                errorPointer.baseAddress,
                errorPointer.count
            )
        }
        guard result == 0 else {
            throw LinuxPlatformError(Self.message(from: errorBuffer))
        }
    }

    public func present(
        tile: RGB565Tile,
        bytes: UnsafeRawBufferPointer
    ) throws {
        guard let configuration = rgb565RendererConfiguration else {
            throw LinuxPlatformError(
                "logical display dimensions exceed the RGB565 tile renderer limits"
            )
        }
        guard tile.byteOrder == .mostSignificantByteFirst else {
            throw LinuxPlatformError("Linux RGB565 tiles must be most-significant-byte first")
        }

        var errorBuffer = [CChar](repeating: 0, count: 256)
        let result = errorBuffer.withUnsafeMutableBufferPointer { errorPointer in
            giftui_fb_present_rgb565_tile(
                device,
                bytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                Int32(configuration.logicalSize.width),
                Int32(configuration.logicalSize.height),
                Int32(tile.physicalX),
                Int32(tile.physicalY),
                Int32(tile.width),
                Int32(tile.height),
                Int32(tile.bytesPerRow),
                Int32(rotation.rawValue),
                errorPointer.baseAddress,
                errorPointer.count
            )
        }
        guard result == 0 else {
            throw LinuxPlatformError(Self.message(from: errorBuffer))
        }
    }

    private static func message(from buffer: [CChar]) -> String {
        buffer.withUnsafeBufferPointer { pointer in
            guard let baseAddress = pointer.baseAddress, baseAddress.pointee != 0 else {
                return "unknown Linux framebuffer error"
            }
            return String(cString: baseAddress)
        }
    }
}
