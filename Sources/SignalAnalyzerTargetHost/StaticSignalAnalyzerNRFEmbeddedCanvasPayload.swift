#if GIFTUI_NRF_EMBEDDED
    /// Five exact 32-byte inline capture slots. The trace fields match the
    /// generated Canvas manifest offsets 0, 8, 16, and 24.
    package enum StaticSignalAnalyzerNRFEmbeddedCanvasPayload {
        package static let regionByteCount = 160
        package static let recordByteCount = 32

        package struct TraceCapture {
            package let modelToken: UInt64
            package let channelRawValue: Int64
            package let lowerMilliseconds: Int64
            package let upperMilliseconds: Int64
        }

        package static func stageTrace(
            _ capture: TraceCapture, at index: UInt16,
            in region: UnsafeMutableRawBufferPointer
        ) -> Bool {
            guard region.count == regionByteCount,
                index > 0, index < 5,
                capture.modelToken != 0,
                (1 ... 4).contains(capture.channelRawValue),
                capture.lowerMilliseconds >= 0,
                capture.lowerMilliseconds < capture.upperMilliseconds
            else { return false }
            let offset = Int(index) * recordByteCount
            var byte = offset
            while byte < offset + recordByteCount {
                guard region[byte] == 0 else { return false }
                byte += 1
            }
            put(capture.modelToken, in: region, at: offset)
            put(UInt64(bitPattern: capture.channelRawValue), in: region, at: offset + 8)
            put(UInt64(bitPattern: capture.lowerMilliseconds), in: region, at: offset + 16)
            put(UInt64(bitPattern: capture.upperMilliseconds), in: region, at: offset + 24)
            return true
        }

        package static func trace(
            at index: UInt16, in region: UnsafeMutableRawBufferPointer
        ) -> TraceCapture? {
            guard region.count == regionByteCount, index > 0, index < 5 else {
                return nil
            }
            let offset = Int(index) * recordByteCount
            let capture = TraceCapture(
                modelToken: get(from: region, at: offset),
                channelRawValue: Int64(bitPattern: get(from: region, at: offset + 8)),
                lowerMilliseconds: Int64(bitPattern: get(from: region, at: offset + 16)),
                upperMilliseconds: Int64(bitPattern: get(from: region, at: offset + 24))
            )
            guard capture.modelToken != 0,
                (1 ... 4).contains(capture.channelRawValue),
                capture.lowerMilliseconds >= 0,
                capture.lowerMilliseconds < capture.upperMilliseconds
            else { return nil }
            return capture
        }

        package static func release(
            at index: UInt16, in region: UnsafeMutableRawBufferPointer
        ) -> Bool {
            guard region.count == regionByteCount, index < 5 else { return false }
            let offset = Int(index) * recordByteCount
            var byte = offset
            while byte < offset + recordByteCount {
                region[byte] = 0
                byte += 1
            }
            return true
        }

        package static func isEmpty(_ region: UnsafeMutableRawBufferPointer) -> Bool {
            guard region.count == regionByteCount else { return false }
            for byte in region where byte != 0 { return false }
            return true
        }

        private static func put(
            _ value: UInt64, in region: UnsafeMutableRawBufferPointer, at offset: Int
        ) {
            var byte = 0
            while byte < 8 {
                region[offset + byte] = UInt8(truncatingIfNeeded: value >> (byte * 8))
                byte += 1
            }
        }

        private static func get(
            from region: UnsafeMutableRawBufferPointer, at offset: Int
        ) -> UInt64 {
            var result: UInt64 = 0
            var byte = 0
            while byte < 8 {
                result |= UInt64(region[offset + byte]) << (byte * 8)
                byte += 1
            }
            return result
        }
    }
#endif
