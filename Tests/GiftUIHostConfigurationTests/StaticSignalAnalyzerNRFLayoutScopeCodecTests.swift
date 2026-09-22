import GiftUI
import GiftUILayout
import Testing

@testable import SignalAnalyzerTargetHost

@Test func staticNRFLayoutScopeCodecUsesExactCheckedThirtyTwoByteRecords() {
    let codec = StaticSignalAnalyzerNRFLayoutScopeCodec.self
    #expect(codec.recordByteCount == 32)
    #expect(codec.maximumScopes == 98)
    #expect(codec.regionByteCount == 3_136)

    var storage = [UInt8](repeating: 0, count: codec.regionByteCount)
    storage.withUnsafeMutableBytes { region in
        let initial = LayoutMeasurement(
            idealSize: Size(width: 280, height: 120)!,
            resolvedSize: Size(width: 240, height: 100)!
        )
        let resolved = LayoutMeasurement(
            idealSize: Size(width: 300, height: 120)!,
            resolvedSize: Size(width: 200, height: 100)!
        )
        let placement = LayoutPlacement(
            bounds: Rect(
                origin: Point(x: -20, y: 60),
                size: resolved.resolvedSize
            )!,
            clip: Rect(
                origin: Point(x: 0, y: 60),
                size: Size(width: 180, height: 100)!
            )!
        )
        #expect(codec.stage(identity: 0xBF7C, measurement: initial, at: 0, in: region))
        #expect(codec.read(at: 0, in: region)?.measurement == initial)
        #expect(codec.read(at: 0, in: region)?.placement == nil)
        #expect(
            codec.replaceMeasurement(resolved, for: 0xBF7C, at: 0, in: region)
        )
        #expect(codec.place(placement, for: 0xBF7C, at: 0, in: region))
        #expect(
            codec.read(at: 0, in: region)
                == StaticSignalAnalyzerNRFLayoutScopeRecord(
                    identity: 0xBF7C,
                    measurement: resolved,
                    placement: placement
                )
        )
        #expect(!codec.place(placement, for: 0xBF7C, at: 0, in: region))
        #expect(!codec.replaceMeasurement(initial, for: 0xBF7C, at: 0, in: region))
        #expect(!codec.stage(identity: 0xBF7C, measurement: initial, at: 0, in: region))

        #expect(codec.stage(identity: 0x1111, measurement: initial, at: 97, in: region))
        #expect(codec.read(at: 97, in: region)?.identity == 0x1111)
        #expect(!codec.stage(identity: 1, measurement: initial, at: 98, in: region))
        #expect(codec.read(at: 98, in: region) == nil)
        region[24] = 1
        #expect(codec.read(at: 0, in: region) == nil)
        region[32] = 1
        #expect(!codec.stage(identity: 2, measurement: initial, at: 1, in: region))
    }
}

@Test func staticNRFLayoutScopeCodecRejectsUnrepresentableAndMismatchedGeometry() {
    let codec = StaticSignalAnalyzerNRFLayoutScopeCodec.self
    var storage = [UInt8](repeating: 0, count: codec.regionByteCount)
    storage.withUnsafeMutableBytes { region in
        let tooWide = LayoutMeasurement(
            idealSize: Size(width: 32_768, height: 1)!,
            resolvedSize: Size(width: 1, height: 1)!
        )
        let valid = LayoutMeasurement(
            idealSize: Size(width: 480, height: 320)!,
            resolvedSize: Size(width: 480, height: 320)!
        )
        #expect(!codec.stage(identity: 1, measurement: tooWide, at: 0, in: region))
        #expect(!codec.stage(identity: 0, measurement: valid, at: 0, in: region))
        #expect(codec.stage(identity: 1, measurement: valid, at: 0, in: region))
        region[12] = 1
        #expect(codec.read(at: 0, in: region) == nil)
        region[12] = 0
        #expect(!codec.replaceMeasurement(tooWide, for: 1, at: 0, in: region))
        #expect(codec.read(at: 0, in: region)?.measurement == valid)
        let wrongSize = LayoutPlacement(
            bounds: Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: 479, height: 320)!
            )!,
            clip: Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: 479, height: 320)!
            )!
        )
        #expect(!codec.place(wrongSize, for: 1, at: 0, in: region))
        let farOrigin = LayoutPlacement(
            bounds: Rect(
                origin: Point(x: 32_768, y: 0),
                size: valid.resolvedSize
            )!,
            clip: Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: 480, height: 320)!
            )!
        )
        #expect(!codec.place(farOrigin, for: 1, at: 0, in: region))
        #expect(codec.read(at: 0, in: region)?.placement == nil)
    }
    var undersized = [UInt8](repeating: 0, count: codec.regionByteCount - 1)
    undersized.withUnsafeMutableBytes { region in
        let valid = LayoutMeasurement(
            idealSize: Size(width: 1, height: 1)!,
            resolvedSize: Size(width: 1, height: 1)!
        )
        #expect(!codec.stage(identity: 1, measurement: valid, at: 0, in: region))
    }
}
