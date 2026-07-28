public struct TextRun: Equatable, Sendable {
    package enum Storage: Sendable {
        case staticString(StaticString)
        case boundedInteger(Int, suffix: StaticString)
        #if !hasFeature(Embedded)
        case dynamicString(String)
        #endif
    }

    package let storage: Storage
    public var color: Color

    public init(_ content: StaticString, color: Color = .white) {
        storage = .staticString(content)
        self.color = color
    }

    public init(
        integer value: Int,
        suffix: StaticString = "",
        color: Color = .white
    ) {
        storage = .boundedInteger(value, suffix: suffix)
        self.color = color
    }

    #if !hasFeature(Embedded)
    package init(dynamic content: String, color: Color = .white) {
        storage = .dynamicString(content)
        self.color = color
    }

    public var content: String {
        switch storage {
        case .staticString(let content):
            return content.description
        case .boundedInteger(let value, let suffix):
            return String(value) + suffix.description
        case .dynamicString(let content):
            return content
        }
    }
    #endif

    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.color == rhs.color else { return false }
        #if hasFeature(Embedded)
        switch (lhs.storage, rhs.storage) {
        case (.staticString(let lhs), .staticString(let rhs)):
            return Self.staticStringsEqual(lhs, rhs)
        case (
            .boundedInteger(let lhsValue, let lhsSuffix),
            .boundedInteger(let rhsValue, let rhsSuffix)
        ):
            return lhsValue == rhsValue
                && Self.staticStringsEqual(lhsSuffix, rhsSuffix)
        default:
            return false
        }
        #else
        return lhs.content == rhs.content
        #endif
    }

    package var glyphCount: Int {
        switch storage {
        case .staticString(let content):
            return Self.unicodeScalarCount(of: content)
        case .boundedInteger(let value, let suffix):
            return Self.decimalCharacterCount(of: value)
                + Self.unicodeScalarCount(of: suffix)
        #if !hasFeature(Embedded)
        case .dynamicString(let content):
            return content.unicodeScalars.count
        #endif
        }
    }

    /// Visits the encoded text without constructing a heap-backed string.
    /// Static renderers can decode or match only the glyphs they support.
    public func forEachUTF8CodeUnit(_ body: (UInt8) -> Void) {
        switch storage {
        case .staticString(let content):
            Self.forEachUTF8CodeUnit(in: content, body)
        case .boundedInteger(let value, let suffix):
            Self.forEachDecimalCodeUnit(in: value, body)
            Self.forEachUTF8CodeUnit(in: suffix, body)
        #if !hasFeature(Embedded)
        case .dynamicString(let content):
            for codeUnit in content.utf8 {
                body(codeUnit)
            }
        #endif
        }
    }

    private static func forEachUTF8CodeUnit(
        in value: StaticString,
        _ body: (UInt8) -> Void
    ) {
        let bytes = UnsafeBufferPointer(
            start: value.utf8Start,
            count: value.utf8CodeUnitCount
        )
        for byte in bytes {
            body(byte)
        }
    }

    private static func forEachDecimalCodeUnit(
        in value: Int,
        _ body: (UInt8) -> Void
    ) {
        if value < 0 {
            body(45)
        }

        var magnitude = value.magnitude
        if magnitude == 0 {
            body(48)
            return
        }

        var divisor: UInt = 1
        while magnitude / divisor >= 10 {
            divisor *= 10
        }
        while divisor > 0 {
            body(UInt8(magnitude / divisor) + 48)
            magnitude %= divisor
            divisor /= 10
        }
    }

    private static func unicodeScalarCount(of value: StaticString) -> Int {
        let bytes = UnsafeBufferPointer(
            start: value.utf8Start,
            count: value.utf8CodeUnitCount
        )
        var count = 0
        for byte in bytes where byte & 0xc0 != 0x80 {
            count += 1
        }
        return count
    }

    private static func decimalCharacterCount(of value: Int) -> Int {
        if value == 0 { return 1 }
        var remaining = value
        var count = value < 0 ? 1 : 0
        while remaining != 0 {
            count += 1
            remaining /= 10
        }
        return count
    }

    private static func staticStringsEqual(
        _ lhs: StaticString,
        _ rhs: StaticString
    ) -> Bool {
        guard lhs.utf8CodeUnitCount == rhs.utf8CodeUnitCount else {
            return false
        }
        var index = 0
        while index < lhs.utf8CodeUnitCount {
            guard lhs.utf8Start[index] == rhs.utf8Start[index] else {
                return false
            }
            index += 1
        }
        return true
    }
}
