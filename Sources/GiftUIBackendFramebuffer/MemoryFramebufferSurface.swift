public struct MemoryFramebufferSurface: FramebufferSurface, Sendable {
    public let width: Int
    public let height: Int
    public let pixelFormat: PixelFormat
    private var pixels: [UInt8]

    public var bytesPerRow: Int {
        width * pixelFormat.bytesPerPixel
    }

    public init(
        width: Int,
        height: Int,
        pixelFormat: PixelFormat = .rgba8888
    ) {
        precondition(width > 0 && height > 0, "Framebuffer dimensions must be positive")
        self.width = width
        self.height = height
        self.pixelFormat = pixelFormat
        pixels = [UInt8](
            repeating: 0,
            count: width * height * pixelFormat.bytesPerPixel
        )
    }

    public func withUnsafeBytes<R>(
        _ body: (UnsafeRawBufferPointer) throws -> R
    ) rethrows -> R {
        try pixels.withUnsafeBytes(body)
    }

    public mutating func withUnsafeMutableBytes<R>(
        _ body: (UnsafeMutableRawBufferPointer) throws -> R
    ) rethrows -> R {
        try pixels.withUnsafeMutableBytes(body)
    }
}
