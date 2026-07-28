import GiftUI
import GiftUIBackendRGB565

public enum ILI9341DisplayError: Error, Equatable, Sendable {
    case invalidRectangle
    case invalidBytesPerRow
    case invalidBufferSize
    case gramReadUnsupported
    case transport(ILI9341TransportFault)
}

public struct ILI9341Display<Transport: ILI9341DisplayTransport> {
    public let configuration: ILI9341DisplayConfiguration
    public private(set) var transport: Transport
    public private(set) var retainedWriterFault: ILI9341DisplayError?

    public init(
        configuration: ILI9341DisplayConfiguration,
        transport: Transport
    ) {
        self.configuration = configuration
        self.transport = transport
        retainedWriterFault = nil
    }

    public mutating func initialize() throws(ILI9341DisplayError) {
        do {
            try transport.initialize(configuration: configuration)
        } catch {
            throw .transport(error)
        }
    }

    public mutating func setBlanked(
        _ blanked: Bool
    ) throws(ILI9341DisplayError) {
        do {
            try transport.setBlanked(blanked)
        } catch {
            throw .transport(error)
        }
    }

    public mutating func presentRGB565(
        rect: Rect,
        bytesPerRow: Int,
        bytes: UnsafeRawBufferPointer
    ) throws(ILI9341DisplayError) {
        let validated = try validatedTransfer(
            rect: rect,
            bytesPerRow: bytesPerRow,
            bufferCount: bytes.count
        )
        guard let clipped = validated.clipped else { return }
        let start = try checkedOffset(
            clipped: clipped,
            original: rect,
            bytesPerRow: bytesPerRow
        )
        let count = try requiredByteCount(
            width: clipped.size.width,
            height: clipped.size.height,
            bytesPerRow: bytesPerRow
        )
        guard start <= bytes.count, count <= bytes.count - start else {
            throw .invalidBufferSize
        }
        let payload = UnsafeRawBufferPointer(
            start: bytes.baseAddress?.advanced(by: start),
            count: count
        )
        do {
            try transport.writeRGB565(
                rect: clipped,
                bytesPerRow: bytesPerRow,
                bytes: payload
            )
        } catch {
            throw .transport(error)
        }
    }

    public mutating func fill(
        rect: Rect,
        pixel: RGB565Pixel
    ) throws(ILI9341DisplayError) {
        guard let clipped = try validatedClippedRect(rect) else { return }
        do {
            try transport.writeSolidRGB565(
                rect: clipped,
                pixel: pixel.rawValue
            )
        } catch {
            throw .transport(error)
        }
    }

    public mutating func readRGB565(
        rect: Rect,
        bytesPerRow: Int,
        bytes: UnsafeMutableRawBufferPointer
    ) throws(ILI9341DisplayError) {
        guard configuration.readCapabilities.gramReads else {
            throw .gramReadUnsupported
        }
        let validated = try validatedTransfer(
            rect: rect,
            bytesPerRow: bytesPerRow,
            bufferCount: bytes.count
        )
        guard let clipped = validated.clipped else { return }
        let start = try checkedOffset(
            clipped: clipped,
            original: rect,
            bytesPerRow: bytesPerRow
        )
        let count = try requiredByteCount(
            width: clipped.size.width,
            height: clipped.size.height,
            bytesPerRow: bytesPerRow
        )
        guard start <= bytes.count, count <= bytes.count - start else {
            throw .invalidBufferSize
        }
        let payload = UnsafeMutableRawBufferPointer(
            start: bytes.baseAddress?.advanced(by: start),
            count: count
        )
        do {
            try transport.readRGB565(
                rect: clipped,
                bytesPerRow: bytesPerRow,
                bytes: payload
            )
        } catch {
            throw .transport(error)
        }
    }

    public mutating func clearRetainedWriterFault() {
        retainedWriterFault = nil
    }

    private func validatedTransfer(
        rect: Rect,
        bytesPerRow: Int,
        bufferCount: Int
    ) throws(ILI9341DisplayError) -> (clipped: Rect?, requiredBytes: Int) {
        guard rect.size.width > 0, rect.size.height > 0 else {
            throw .invalidRectangle
        }
        let minimumRowBytes = try checkedMultiply(
            rect.size.width,
            ILI9341DisplayConfiguration.bytesPerPixel,
            failure: .invalidRectangle
        )
        guard bytesPerRow >= minimumRowBytes else {
            throw .invalidBytesPerRow
        }
        let required = try requiredByteCount(
            width: rect.size.width,
            height: rect.size.height,
            bytesPerRow: bytesPerRow
        )
        guard bufferCount >= required else { throw .invalidBufferSize }
        return (try validatedClippedRect(rect), required)
    }

    private func validatedClippedRect(
        _ rect: Rect
    ) throws(ILI9341DisplayError) -> Rect? {
        guard rect.size.width > 0, rect.size.height > 0 else {
            throw .invalidRectangle
        }
        let (rectMaxX, xOverflow) = rect.origin.x.addingReportingOverflow(
            rect.size.width
        )
        let (rectMaxY, yOverflow) = rect.origin.y.addingReportingOverflow(
            rect.size.height
        )
        guard !xOverflow, !yOverflow else { throw .invalidRectangle }
        let minX = max(0, rect.origin.x)
        let minY = max(0, rect.origin.y)
        let maxX = min(configuration.logicalSize.width, rectMaxX)
        let maxY = min(configuration.logicalSize.height, rectMaxY)
        guard minX < maxX, minY < maxY else { return nil }
        return Rect(
            origin: Point(x: minX, y: minY),
            size: Size(width: maxX - minX, height: maxY - minY)
        )
    }

    private func checkedOffset(
        clipped: Rect,
        original: Rect,
        bytesPerRow: Int
    ) throws(ILI9341DisplayError) -> Int {
        let rowOffset = try checkedMultiply(
            clipped.origin.y - original.origin.y,
            bytesPerRow,
            failure: .invalidBufferSize
        )
        let columnOffset = try checkedMultiply(
            clipped.origin.x - original.origin.x,
            ILI9341DisplayConfiguration.bytesPerPixel,
            failure: .invalidBufferSize
        )
        let (offset, overflow) = rowOffset.addingReportingOverflow(columnOffset)
        guard !overflow else { throw .invalidBufferSize }
        return offset
    }

    private func requiredByteCount(
        width: Int,
        height: Int,
        bytesPerRow: Int
    ) throws(ILI9341DisplayError) -> Int {
        let precedingRows = try checkedMultiply(
            height - 1,
            bytesPerRow,
            failure: .invalidBufferSize
        )
        let finalRow = try checkedMultiply(
            width,
            ILI9341DisplayConfiguration.bytesPerPixel,
            failure: .invalidBufferSize
        )
        let (count, overflow) = precedingRows.addingReportingOverflow(finalRow)
        guard !overflow else { throw .invalidBufferSize }
        return count
    }

    private func checkedMultiply(
        _ lhs: Int,
        _ rhs: Int,
        failure: ILI9341DisplayError
    ) throws(ILI9341DisplayError) -> Int {
        let (result, overflow) = lhs.multipliedReportingOverflow(by: rhs)
        guard !overflow else { throw failure }
        return result
    }
}

extension ILI9341Display: RGB565SolidRectWriter {
    public mutating func writeSolidRect(_ rect: Rect, pixel: RGB565Pixel) {
        guard retainedWriterFault == nil else { return }
        do {
            try fill(rect: rect, pixel: pixel)
        } catch {
            retainedWriterFault = error
        }
    }
}
