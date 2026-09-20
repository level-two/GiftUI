#if os(Linux)
    import Glibc
    import GiftUI

    package enum LinuxPiScreenDeviceError: UInt8, Error, Equatable, Sendable {
        case invalidPath = 0
        case openFailed = 1
        case metadataReadFailed = 2
        case unsupportedFramebuffer = 3
        case mappingFailed = 4
        case inputReadFailed = 5
    }

    package final class LinuxPiScreenFramebuffer: PiScreenFramebufferSink {
        package let layout: PiScreenFramebufferLayout
        private let fileDescriptor: Int32
        private let mapping: UnsafeMutableRawPointer

        package init(
            devicePath: String = "/dev/fb0",
            sysfsRoot: String = "/sys/class/graphics/fb0"
        ) throws(LinuxPiScreenDeviceError) {
            guard !devicePath.isEmpty, !sysfsRoot.isEmpty else { throw .invalidPath }
            let fileDescriptor = devicePath.withCString {
                Glibc.open($0, O_RDWR | O_CLOEXEC)
            }
            guard fileDescriptor >= 0 else { throw .openFailed }

            guard let virtualSize = Self.readText(path: "\(sysfsRoot)/virtual_size"),
                let dimensions = Self.parsePair(virtualSize),
                let bitsText = Self.readText(path: "\(sysfsRoot)/bits_per_pixel"),
                let bits = Self.parseUnsigned(bitsText),
                let strideText = Self.readText(path: "\(sysfsRoot)/stride"),
                let stride = Self.parseUnsigned(strideText),
                let width = UInt16(exactly: dimensions.0),
                let height = UInt16(exactly: dimensions.1),
                let bitsPerPixel = UInt8(exactly: bits)
            else {
                _ = Glibc.close(fileDescriptor)
                throw .metadataReadFailed
            }
            let mapped = stride.multipliedReportingOverflow(by: dimensions.1)
            guard !mapped.overflow,
                let layout = PiScreenFramebufferLayout(
                    width: width,
                    height: height,
                    bitsPerPixel: bitsPerPixel,
                    bytesPerRow: stride,
                    mappedBytes: mapped.partialValue
                )
            else {
                _ = Glibc.close(fileDescriptor)
                throw .unsupportedFramebuffer
            }
            let mapping = Glibc.mmap(
                nil,
                Int(layout.mappedBytes),
                PROT_READ | PROT_WRITE,
                MAP_SHARED,
                fileDescriptor,
                0
            )
            guard mapping != MAP_FAILED, let mapping else {
                _ = Glibc.close(fileDescriptor)
                throw .mappingFailed
            }
            self.fileDescriptor = fileDescriptor
            self.mapping = mapping
            self.layout = layout
        }

        deinit {
            _ = Glibc.munmap(mapping, Int(layout.mappedBytes))
            _ = Glibc.close(fileDescriptor)
        }

        package func presentRGB565BigEndian(
            bytes: UnsafeRawBufferPointer,
            regions: [PiScreenPayloadRegion],
            transform: PiScreenAspectFitTransform
        ) -> Bool {
            guard let source = bytes.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return regions.isEmpty
            }
            let destination = mapping.assumingMemoryBound(to: UInt8.self)
            for region in regions {
                guard
                    let physical = transform.physicalBounds(
                        origin: region.origin,
                        pixelCount: region.pixelCount
                    )
                else { return false }
                let byteCount = UInt32(region.pixelCount).multipliedReportingOverflow(by: 2)
                guard !byteCount.overflow,
                    region.byteOffset <= UInt32(bytes.count),
                    byteCount.partialValue <= UInt32(bytes.count) - region.byteOffset
                else { return false }
                for physicalY in physical.minY ..< physical.maxY {
                    let rowOffset = UInt32(physicalY).multipliedReportingOverflow(
                        by: layout.bytesPerRow
                    )
                    guard !rowOffset.overflow else { return false }
                    for physicalX in physical.minX ..< physical.maxX {
                        let relativeX = physicalX - physical.minX
                        let sourcePixel = Int32(
                            Int64(relativeX) * Int64(region.pixelCount) / Int64(physical.size.width)
                        )
                        let sourceOffset = Int(region.byteOffset) + Int(sourcePixel) * 2
                        let pixelOffset = UInt32(physicalX).multipliedReportingOverflow(by: 2)
                        guard !pixelOffset.overflow else { return false }
                        let destinationOffset = rowOffset.partialValue.addingReportingOverflow(
                            pixelOffset.partialValue
                        )
                        guard !destinationOffset.overflow,
                            destinationOffset.partialValue + 1 < layout.mappedBytes
                        else { return false }
                        destination[Int(destinationOffset.partialValue)] = source[sourceOffset + 1]
                        destination[Int(destinationOffset.partialValue) + 1] = source[sourceOffset]
                    }
                }
            }
            return true
        }

        private static func readText(path: String) -> [UInt8]? {
            let descriptor = path.withCString { Glibc.open($0, O_RDONLY | O_CLOEXEC) }
            guard descriptor >= 0 else { return nil }
            defer { _ = Glibc.close(descriptor) }
            var buffer = [UInt8](repeating: 0, count: 96)
            let count = buffer.withUnsafeMutableBytes {
                Glibc.read(descriptor, $0.baseAddress, $0.count)
            }
            guard count > 0 else { return nil }
            return Array(buffer[..<count])
        }

        private static func parsePair(_ bytes: [UInt8]) -> (UInt32, UInt32)? {
            guard let comma = bytes.firstIndex(of: 44),
                let first = parseUnsigned(Array(bytes[..<comma])),
                let second = parseUnsigned(Array(bytes[(comma + 1)...]))
            else { return nil }
            return (first, second)
        }

        private static func parseUnsigned(_ bytes: [UInt8]) -> UInt32? {
            var value: UInt32 = 0
            var sawDigit = false
            for byte in bytes {
                guard byte >= 48, byte <= 57 else {
                    if sawDigit { break }
                    continue
                }
                sawDigit = true
                let multiplied = value.multipliedReportingOverflow(by: 10)
                let added = multiplied.partialValue.addingReportingOverflow(UInt32(byte - 48))
                guard !multiplied.overflow, !added.overflow else { return nil }
                value = added.partialValue
            }
            return sawDigit ? value : nil
        }
    }

    private struct LinuxInputEvent {
        var time = timeval(tv_sec: 0, tv_usec: 0)
        var type: UInt16 = 0
        var code: UInt16 = 0
        var value: Int32 = 0
    }

    package final class LinuxPiScreenTouchDevice {
        private static let eventSynchronization: UInt16 = 0
        private static let eventKey: UInt16 = 1
        private static let eventAbsolute: UInt16 = 3
        private static let synchronizationReport: UInt16 = 0
        private static let absoluteX: UInt16 = 0
        private static let absoluteY: UInt16 = 1
        private static let buttonTouch: UInt16 = 330

        private let fileDescriptor: Int32
        private let transform: PiScreenAspectFitTransform
        private let calibration: PiScreenTouchCalibration
        private var decoder = PiScreenContactDecoder()
        private var rawX: Int32 = 0
        private var rawY: Int32 = 0
        private var touching = false
        private var changed = false

        package init(
            devicePath: String = "/dev/input/event0",
            transform: PiScreenAspectFitTransform,
            calibration: PiScreenTouchCalibration
        ) throws(LinuxPiScreenDeviceError) {
            guard !devicePath.isEmpty else { throw .invalidPath }
            let descriptor = devicePath.withCString {
                Glibc.open($0, O_RDONLY | O_NONBLOCK | O_CLOEXEC)
            }
            guard descriptor >= 0 else { throw .openFailed }
            fileDescriptor = descriptor
            self.transform = transform
            self.calibration = calibration
        }

        deinit {
            _ = Glibc.close(fileDescriptor)
        }

        package func poll() throws(LinuxPiScreenDeviceError) -> [PiScreenContactEvent] {
            var input = [LinuxInputEvent](repeating: LinuxInputEvent(), count: 32)
            let byteCount = input.withUnsafeMutableBytes {
                Glibc.read(fileDescriptor, $0.baseAddress, $0.count)
            }
            if byteCount < 0 {
                guard errno == EAGAIN || errno == EWOULDBLOCK else { throw .inputReadFailed }
                return []
            }
            guard byteCount % MemoryLayout<LinuxInputEvent>.stride == 0 else {
                throw .inputReadFailed
            }
            var result: [PiScreenContactEvent] = []
            let count = byteCount / MemoryLayout<LinuxInputEvent>.stride
            for event in input.prefix(count) {
                switch (event.type, event.code) {
                case (Self.eventAbsolute, Self.absoluteX):
                    rawX = event.value
                    changed = true
                case (Self.eventAbsolute, Self.absoluteY):
                    rawY = event.value
                    changed = true
                case (Self.eventKey, Self.buttonTouch):
                    touching = event.value != 0
                    changed = true
                case (Self.eventSynchronization, Self.synchronizationReport):
                    guard changed else { continue }
                    changed = false
                    let point = transform.logicalPoint(
                        rawX: rawX,
                        rawY: rawY,
                        calibration: calibration
                    )
                    if let emitted = decoder.update(point: point, touching: touching) {
                        result.append(emitted)
                    }
                default:
                    break
                }
            }
            return result
        }
    }
#endif
