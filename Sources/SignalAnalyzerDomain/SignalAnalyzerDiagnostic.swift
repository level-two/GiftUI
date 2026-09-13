private struct SignalAnalyzerDiagnosticStorage: Equatable, Sendable {
    var word00: UInt32 = 0
    var word01: UInt32 = 0
    var word02: UInt32 = 0
    var word03: UInt32 = 0
    var word04: UInt32 = 0
    var word05: UInt32 = 0
    var word06: UInt32 = 0
    var word07: UInt32 = 0
    var word08: UInt32 = 0
    var word09: UInt32 = 0
    var word10: UInt32 = 0
    var word11: UInt32 = 0
    var word12: UInt32 = 0
    var word13: UInt32 = 0
    var word14: UInt32 = 0
    var word15: UInt32 = 0
    var word16: UInt32 = 0
    var word17: UInt32 = 0
    var word18: UInt32 = 0
    var word19: UInt32 = 0
    var word20: UInt32 = 0
    var word21: UInt32 = 0
    var word22: UInt32 = 0
    var word23: UInt32 = 0
}

package struct SignalAnalyzerDiagnostic: Equatable, Sendable {
    package static let maximumUTF8ByteCount: UInt16 = 96

    private var storage: SignalAnalyzerDiagnosticStorage
    private var count: UInt16

    package var utf8ByteCount: UInt16 {
        count
    }

    package init?<Source: Collection>(exactUTF8 source: Source)
    where Source.Element == UInt8 {
        switch Self.truncating(utf8: source) {
        case .exact(let diagnostic):
            self = diagnostic
        case .truncated, .invalidUTF8:
            return nil
        }
    }

    package static func truncating<Source: Collection>(
        utf8 source: Source
    ) -> SignalAnalyzerDiagnosticConstruction where Source.Element == UInt8 {
        var admitted = SignalAnalyzerDiagnosticStorage()
        var admittedCount = 0
        var truncated = false
        var index = source.startIndex

        while index != source.endIndex {
            let first = source[index]
            source.formIndex(after: &index)
            let scalarLength: Int
            switch first {
            case 0x00 ... 0x7F:
                scalarLength = 1
            case 0xC2 ... 0xDF:
                scalarLength = 2
            case 0xE0 ... 0xEF:
                scalarLength = 3
            case 0xF0 ... 0xF4:
                scalarLength = 4
            default:
                return .invalidUTF8
            }

            var second: UInt8 = 0
            var third: UInt8 = 0
            var fourth: UInt8 = 0
            if scalarLength > 1 {
                guard index != source.endIndex else {
                    return .invalidUTF8
                }
                second = source[index]
                source.formIndex(after: &index)
                guard Self.isContinuation(second) else {
                    return .invalidUTF8
                }
            }
            if scalarLength > 2 {
                guard index != source.endIndex else {
                    return .invalidUTF8
                }
                third = source[index]
                source.formIndex(after: &index)
                guard Self.isContinuation(third) else {
                    return .invalidUTF8
                }
            }
            if scalarLength > 3 {
                guard index != source.endIndex else {
                    return .invalidUTF8
                }
                fourth = source[index]
                source.formIndex(after: &index)
                guard Self.isContinuation(fourth) else {
                    return .invalidUTF8
                }
            }

            guard Self.isValidLeadingSequence(first: first, second: second) else {
                return .invalidUTF8
            }

            if !truncated,
                admittedCount + scalarLength <= Int(Self.maximumUTF8ByteCount)
            {
                withUnsafeMutableBytes(of: &admitted) { rawBytes in
                    let bytes = rawBytes.bindMemory(to: UInt8.self)
                    bytes[admittedCount] = first
                    if scalarLength > 1 { bytes[admittedCount + 1] = second }
                    if scalarLength > 2 { bytes[admittedCount + 2] = third }
                    if scalarLength > 3 { bytes[admittedCount + 3] = fourth }
                }
                admittedCount += scalarLength
            } else {
                truncated = true
            }
        }

        let diagnostic = SignalAnalyzerDiagnostic(
            storage: admitted,
            count: UInt16(admittedCount)
        )
        return truncated ? .truncated(diagnostic) : .exact(diagnostic)
    }

    package func withUTF8<Result>(
        _ body: (UnsafeBufferPointer<UInt8>) throws -> Result
    ) rethrows -> Result {
        try withUnsafeBytes(of: storage) { rawBytes in
            let bytes = rawBytes.bindMemory(to: UInt8.self)
            return try body(
                UnsafeBufferPointer(start: bytes.baseAddress, count: Int(count))
            )
        }
    }

    private init(storage: SignalAnalyzerDiagnosticStorage, count: UInt16) {
        self.storage = storage
        self.count = count
    }

    private static func isContinuation(_ byte: UInt8) -> Bool {
        byte >= 0x80 && byte <= 0xBF
    }

    private static func isValidLeadingSequence(first: UInt8, second: UInt8) -> Bool {
        switch first {
        case 0x00 ... 0x7F, 0xC2 ... 0xDF:
            true
        case 0xE0:
            second >= 0xA0
        case 0xED:
            second <= 0x9F
        case 0xE1 ... 0xEC, 0xEE ... 0xEF:
            true
        case 0xF0:
            second >= 0x90
        case 0xF4:
            second <= 0x8F
        case 0xF1 ... 0xF3:
            true
        default:
            false
        }
    }
}

package enum SignalAnalyzerDiagnosticConstruction: Equatable, Sendable {
    case exact(SignalAnalyzerDiagnostic)
    case truncated(SignalAnalyzerDiagnostic)
    case invalidUTF8
}
