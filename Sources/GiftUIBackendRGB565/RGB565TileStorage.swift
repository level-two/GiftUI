struct RGB565TileStorage: Sendable {
    #if hasFeature(Embedded)
    private var bytes: InlineArray<15360, UInt8> = .init { _ in 0 }
    let byteCapacity = RGB565RendererConfiguration.maximumTileBufferByteCapacity
    #else
    private var bytes: [UInt8]
    let byteCapacity: Int
    #endif

    init(byteCapacity: Int) {
        precondition(
            byteCapacity > 0
                && byteCapacity <= RGB565RendererConfiguration.maximumTileBufferByteCapacity
        )
        #if !hasFeature(Embedded)
        self.byteCapacity = byteCapacity
        bytes = [UInt8](repeating: 0, count: byteCapacity)
        #endif
    }

    mutating func withUnsafeMutableBytes<R>(
        _ body: (UnsafeMutableRawBufferPointer) throws -> R
    ) rethrows -> R {
        #if hasFeature(Embedded)
        return try Swift.withUnsafeMutableBytes(of: &bytes, body)
        #else
        return try bytes.withUnsafeMutableBytes(body)
        #endif
    }

    func withUnsafeBytes<R>(
        _ body: (UnsafeRawBufferPointer) throws -> R
    ) rethrows -> R {
        #if hasFeature(Embedded)
        return try Swift.withUnsafeBytes(of: bytes, body)
        #else
        return try bytes.withUnsafeBytes(body)
        #endif
    }
}
