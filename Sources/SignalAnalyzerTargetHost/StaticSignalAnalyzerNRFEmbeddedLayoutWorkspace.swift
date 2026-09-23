/// One bounded, attempt-local owner of the packed layout and text regions.
/// The region borrow must end before the enclosing profile opportunity ends.
package struct StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace {
    private let scopes: UnsafeMutableRawBufferPointer
    private let text: UnsafeMutableRawBufferPointer
    package private(set) var isActive = false
    package private(set) var scopeCount: UInt16 = 0
    private var depth: UInt16 = 0

    package init?(
        scopes: UnsafeMutableRawBufferPointer,
        text: UnsafeMutableRawBufferPointer
    ) {
        guard scopes.count == StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.regionByteCount,
            text.count == StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.regionByteCount,
            let scopeAddress = scopes.baseAddress,
            let textAddress = text.baseAddress
        else { return nil }
        let scopeStart = UInt(bitPattern: scopeAddress)
        let textStart = UInt(bitPattern: textAddress)
        let scopeEnd = scopeStart.addingReportingOverflow(UInt(scopes.count))
        let textEnd = textStart.addingReportingOverflow(UInt(text.count))
        guard !scopeEnd.overflow, !textEnd.overflow,
            scopeEnd.partialValue <= textStart || textEnd.partialValue <= scopeStart
        else { return nil }
        self.scopes = scopes
        self.text = text
    }

    package mutating func acquire() -> Bool {
        guard !isActive, scopeCount == 0, depth == 0 else { return false }
        scopes.initializeMemory(as: UInt8.self, repeating: 0)
        text.initializeMemory(as: UInt8.self, repeating: 0)
        isActive = true
        return true
    }

    package mutating func appendScope(
        identity: UInt16,
        idealWidth: Int16, idealHeight: Int16,
        width: Int16, height: Int16
    ) -> Bool {
        guard isActive, scopeCount < 98, scopeOrdinal(of: identity) == nil,
            StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.stage(
                identity: identity,
                idealWidth: idealWidth, idealHeight: idealHeight,
                width: width, height: height,
                at: scopeCount, in: scopes
            )
        else { return false }
        scopeCount += 1
        return true
    }

    package func scope(at ordinal: UInt16) -> StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec
        .Record?
    {
        guard isActive, ordinal < scopeCount else { return nil }
        return StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.read(
            at: ordinal, in: scopes
        )
    }

    package func scopeOrdinal(of identity: UInt16) -> UInt16? {
        guard isActive, identity != 0 else { return nil }
        var ordinal: UInt16 = 0
        while ordinal < scopeCount {
            if scope(at: ordinal)?.identity == identity { return ordinal }
            ordinal += 1
        }
        return nil
    }

    package mutating func replaceMeasurement(
        identity: UInt16,
        idealWidth: Int16, idealHeight: Int16,
        width: Int16, height: Int16
    ) -> Bool {
        guard let ordinal = scopeOrdinal(of: identity) else { return false }
        return StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.replaceMeasurement(
            identity: identity,
            idealWidth: idealWidth, idealHeight: idealHeight,
            width: width, height: height,
            at: ordinal, in: scopes
        )
    }

    package mutating func placeScope(
        identity: UInt16,
        originX: Int16, originY: Int16,
        width: Int16, height: Int16,
        clipX: Int16, clipY: Int16,
        clipWidth: Int16, clipHeight: Int16
    ) -> Bool {
        guard let ordinal = scopeOrdinal(of: identity) else { return false }
        return StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.place(
            identity: identity,
            originX: originX, originY: originY,
            width: width, height: height,
            clipX: clipX, clipY: clipY,
            clipWidth: clipWidth, clipHeight: clipHeight,
            at: ordinal, in: scopes
        )
    }

    package mutating func pushScope(_ identity: UInt16) -> Bool {
        guard isActive, depth < 13,
            scopeOrdinal(of: identity) != nil
        else { return false }
        let offset =
            StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.scratchOffset
            + Int(depth) * 2
        text[offset] = UInt8(truncatingIfNeeded: identity)
        text[offset + 1] = UInt8(truncatingIfNeeded: identity >> 8)
        depth += 1
        return true
    }

    package mutating func popScope() {
        guard isActive, depth > 0 else { return }
        depth -= 1
        let offset =
            StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.scratchOffset
            + Int(depth) * 2
        text[offset] = 0
        text[offset + 1] = 0
    }

    package mutating func reset() {
        scopes.initializeMemory(as: UInt8.self, repeating: 0)
        text.initializeMemory(as: UInt8.self, repeating: 0)
        scopeCount = 0
        depth = 0
        isActive = false
    }
}
