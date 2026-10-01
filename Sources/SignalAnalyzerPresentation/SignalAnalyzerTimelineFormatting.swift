import SignalAnalyzerDomain

/// Shared, allocation-free timeline text for portable and Embedded hosts.
package enum SignalAnalyzerTimelineFormatting {
    package static func seconds(_ duration: Duration) -> SignalAnalyzerDiagnostic {
        let components = duration.components
        var whole = max(0, components.seconds)
        var fraction: Int64 = 0
        if duration > .zero {
            let attoseconds = max(0, components.attoseconds)
            fraction = attoseconds / 100_000_000_000_000_000
            if attoseconds % 100_000_000_000_000_000 >= 50_000_000_000_000_000 {
                fraction += 1
            }
            if fraction == 10 {
                let next = whole.addingReportingOverflow(1)
                whole = next.overflow ? .max : next.partialValue
                fraction = 0
            }
        }
        var storage = (
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0)
        )
        var count = 0
        withUnsafeMutableBytes(of: &storage) { bytes in
            repeat {
                bytes[count] = 48 + UInt8(whole % 10)
                count += 1
                whole /= 10
            } while whole > 0
            bytes[0 ..< count].reverse()
            if fraction != 0 {
                bytes[count] = 46
                bytes[count + 1] = 48 + UInt8(fraction)
                count += 2
            }
            bytes[count] = 32
            bytes[count + 1] = 115
            count += 2
        }
        return withUnsafeBytes(of: storage) { bytes in
            SignalAnalyzerDiagnostic(exactUTF8: bytes.prefix(count))!
        }
    }
}
