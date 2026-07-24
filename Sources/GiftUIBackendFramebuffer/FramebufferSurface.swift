public protocol FramebufferSurface {
    var width: Int { get }
    var height: Int { get }
    var bytesPerRow: Int { get }

    func withUnsafeBytes<R>(
        _ body: (UnsafeRawBufferPointer) throws -> R
    ) rethrows -> R

    mutating func withUnsafeMutableBytes<R>(
        _ body: (UnsafeMutableRawBufferPointer) throws -> R
    ) rethrows -> R
}
