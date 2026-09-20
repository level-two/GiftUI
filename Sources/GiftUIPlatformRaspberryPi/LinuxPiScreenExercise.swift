#if os(Linux)
    import Glibc
    import GiftUI
    import GiftUIDisplayCore
    import GiftUISurfaceCore

    package struct LinuxPiScreenExerciseReport: Equatable, Sendable {
        package let payloads: UInt16
        package let regions: UInt16
        package let bytes: UInt32
        package let contactEvents: UInt16
    }

    package enum LinuxPiScreenExerciseError: UInt8, Error, Equatable, Sendable {
        case invalidGeometry = 0
        case targetConstruction = 1
        case reservation = 2
        case writer = 3
        case payload = 4
        case frameCompletion = 5
        case countOverflow = 6
    }

    package enum LinuxPiScreenExercise {
        package static func run(
            framebuffer: LinuxPiScreenFramebuffer,
            touch: LinuxPiScreenTouchDevice,
            pollIterations: UInt16 = 200
        ) throws -> LinuxPiScreenExerciseReport {
            guard
                let descriptor = RasterSurfaceDescriptor(
                    bounds: Rect(
                        origin: Point(x: 0, y: 0),
                        size: Size(width: 240, height: 240)!
                    )!,
                    encoding: .rgb565BigEndian,
                    bytesPerRow: 480,
                    realization: .tiled,
                    regionWidth: 240,
                    regionHeight: 16
                )
            else { throw LinuxPiScreenExerciseError.invalidGeometry }
            guard
                var target = PiScreenDisplayTarget(
                    sink: framebuffer,
                    layout: framebuffer.layout,
                    payloadCapacityBytes: 7_680,
                    regionCapacity: 16
                )
            else { throw LinuxPiScreenExerciseError.targetConstruction }
            guard
                case .reserved(let reservation) = target.reserveFrame(
                    descriptor: descriptor,
                    payloadCapacityBytes: 7_680,
                    regionCapacity: 16
                )
            else { throw LinuxPiScreenExerciseError.reservation }

            var payloads: UInt16 = 0
            var regions: UInt16 = 0
            var bytes: UInt32 = 0
            for tileY in stride(from: Int32(0), to: 240, by: 16) {
                let wrote = target.withWriter(for: reservation) { writer in
                    for row in tileY ..< tileY + 16 {
                        guard
                            writer.beginRegion(
                                origin: Point(x: 0, y: row),
                                pixelCount: 240,
                                encoding: .rgb565BigEndian
                            )
                        else { return false }
                        for column in Int32(0) ..< 240 {
                            let pixel = color(column: column, row: row)
                            guard writer.write(byte: UInt8(pixel >> 8)),
                                writer.write(byte: UInt8(pixel & 0xFF))
                            else { return false }
                        }
                        guard writer.endRegion() else { return false }
                    }
                    return writer.finish()
                }
                guard wrote == true else {
                    target.cancelFrame(reservation)
                    throw LinuxPiScreenExerciseError.writer
                }
                guard target.submitPayload(reservation) == .completed else {
                    target.cancelFrame(reservation)
                    throw LinuxPiScreenExerciseError.payload
                }
                guard let nextPayloads = adding(payloads, 1),
                    let nextRegions = adding(regions, 16),
                    let nextBytes = adding(bytes, 7_680)
                else {
                    target.cancelFrame(reservation)
                    throw LinuxPiScreenExerciseError.countOverflow
                }
                payloads = nextPayloads
                regions = nextRegions
                bytes = nextBytes
            }
            guard target.finishFrame(reservation) == .completed else {
                throw LinuxPiScreenExerciseError.frameCompletion
            }

            var contactEvents: UInt16 = 0
            for _ in 0 ..< pollIterations {
                for _ in try touch.poll() {
                    guard let next = adding(contactEvents, 1) else {
                        throw LinuxPiScreenExerciseError.countOverflow
                    }
                    contactEvents = next
                }
                _ = Glibc.usleep(10_000)
            }
            return LinuxPiScreenExerciseReport(
                payloads: payloads,
                regions: regions,
                bytes: bytes,
                contactEvents: contactEvents
            )
        }

        private static func color(column: Int32, row: Int32) -> UInt16 {
            let red = UInt16(column * 31 / 239)
            let green = UInt16(row * 63 / 239)
            let blue = UInt16((column + row) * 31 / 478)
            return red << 11 | green << 5 | blue
        }

        private static func adding(_ value: UInt16, _ amount: UInt16) -> UInt16? {
            let result = value.addingReportingOverflow(amount)
            return result.overflow ? nil : result.partialValue
        }

        private static func adding(_ value: UInt32, _ amount: UInt32) -> UInt32? {
            let result = value.addingReportingOverflow(amount)
            return result.overflow ? nil : result.partialValue
        }
    }
#endif
