import GiftUI
import GiftUILayout
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFEmbeddedLayoutScopeCodecMatchesHostBytes() {
    let target = StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.self
    let host = StaticSignalAnalyzerNRFLayoutScopeCodec.self
    var targetBytes = [UInt8](repeating: 0, count: target.regionByteCount)
    var hostBytes = [UInt8](repeating: 0, count: host.regionByteCount)
    targetBytes.withUnsafeMutableBytes { targetRegion in
        hostBytes.withUnsafeMutableBytes { hostRegion in
            let measurement = LayoutMeasurement(
                idealSize: Size(width: 280, height: 120)!,
                resolvedSize: Size(width: 240, height: 100)!
            )
            let targetStaged = target.stage(
                identity: 0xBF7C, idealWidth: 280, idealHeight: 120,
                width: 240, height: 100, at: 0, in: targetRegion
            )
            let hostStaged = host.stage(
                identity: 0xBF7C, measurement: measurement, at: 0,
                in: hostRegion
            )
            #expect(targetStaged && hostStaged)
            #expect([UInt8](targetRegion) == [UInt8](hostRegion))
            let revised = LayoutMeasurement(
                idealSize: Size(width: 260, height: 110)!,
                resolvedSize: measurement.resolvedSize
            )
            #expect(
                target.replaceMeasurement(
                    identity: 0xBF7C, idealWidth: 260, idealHeight: 110,
                    width: 240, height: 100, at: 0, in: targetRegion
                )
            )
            #expect(
                host.replaceMeasurement(
                    revised, for: 0xBF7C, at: 0, in: hostRegion
                )
            )
            #expect([UInt8](targetRegion) == [UInt8](hostRegion))
            let placement = LayoutPlacement(
                bounds: Rect(
                    origin: Point(x: -20, y: 60),
                    size: measurement.resolvedSize
                )!,
                clip: Rect(
                    origin: Point(x: 0, y: 60),
                    size: Size(width: 180, height: 100)!
                )!
            )
            let targetPlaced = target.place(
                identity: 0xBF7C, originX: -20, originY: 60,
                width: 240, height: 100,
                clipX: 0, clipY: 60, clipWidth: 180, clipHeight: 100,
                at: 0, in: targetRegion
            )
            let hostPlaced = host.place(
                placement, for: 0xBF7C, at: 0, in: hostRegion
            )
            #expect(targetPlaced && hostPlaced)
            #expect([UInt8](targetRegion) == [UInt8](hostRegion))
            #expect(target.read(at: 0, in: targetRegion)?.originX == -20)
            #expect(target.read(at: 0, in: targetRegion)?.clipWidth == 180)
            let wrongSize = target.place(
                identity: 0xBF7C, originX: 0, originY: 0,
                width: 479, height: 320,
                clipX: 0, clipY: 0, clipWidth: 479, clipHeight: 320,
                at: 0, in: targetRegion
            )
            #expect(!wrongSize)
            #expect(
                !target.replaceMeasurement(
                    identity: 0xBF7C, idealWidth: 1, idealHeight: 1,
                    width: 1, height: 1, at: 0, in: targetRegion
                )
            )
            targetRegion[24] = 1
            #expect(target.read(at: 0, in: targetRegion) == nil)
        }
    }
}
