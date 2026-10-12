#if !hasFeature(Embedded)
import GiftUI
import GiftUIReferenceTextResources
import GiftUITextResources

// Independent reference projection from authored strings, authoritative font
// metrics/bitmap bits and expected source layout. No runtime geometry, stream,
// coverage algorithm or emitted pixel supplies the expected result.
func counterCheckPixels(_ control: borrowing CounterControl, value: UInt8) -> Int {
    var ink: InlineArray<12000, Bool> = .init(repeating: false)
    let metrics = GiftUIReferenceTextMetricsView()
    let raster = GiftUIReferenceTextRasterView()
    let instance = metrics.instance(at: 0)!.id
    let ids: InlineArray<22, UInt16> = [3,43,49,42,48,31,46,56 + UInt16(value),9,42,29,46,31,41,31,42,48,18,31,47,31,48]
    let lengths: InlineArray<4, Int> = [7,1,9,5]
    let digitWidth: GeometryScalar = value == 1 ? 7 : value == 7 ? 9 : 10
    let starts: InlineArray<4, GeometryScalar> = [7,(74 - digitWidth) / 2,0,16]
    var ordinal = 0
    for line in 0..<4 {
        var baselineX = starts[line]
        let baselineY: GeometryScalar = 16 + GeometryScalar(line) * 24
        for _ in 0..<lengths[line] {
            let id = GlyphID(rawValue: ids[ordinal])
            let glyph = metrics.metrics(for: id, in: instance)!
            let record = raster.record(for: id, realization: .init(rawValue: 0))!
            let accessed = raster.withPayload(for: record, realization: .init(rawValue: 0)) { bytes in
                for row in 0..<Int(record.pixelHeight) {
                    for column in 0..<Int(record.pixelWidth) {
                        let bit = bytes[row * Int(record.rowByteCount) + column / 8] & UInt8(0x80 >> (column % 8))
                        guard bit != 0 else { continue }
                        let x = Int(baselineX + glyph.offsetX) + column
                        let y = Int(baselineY + glyph.offsetY) + row
                        if x >= 0 && x < 100 && y >= 0 && y < 120 { ink[y * 100 + x] = true }
                    }
                }
                return true
            }
            precondition(accessed == true)
            baselineX += glyph.advanceX; ordinal += 1
        }
    }
    // SPEC012 binary coverage samples centers(x+.5,y+.5), including the
    // width-one segment's boundary. Horizontal y104 covers rows103/104,
    // x17..<17+4value; radius.5 round caps add no diagonal pixel center.
    if value > 0 {
        for row in 103...104 {
            for column in 17..<(17 + 4 * Int(value)) { ink[row * 100 + column] = true }
        }
    }
    // The existing root background clears previous glyphs/stroke. Unpainted
    // surface outside the74x112 root retains its canonical opaque black seed.
    for pixel in 0..<12000 {
        let expected: UInt8 = ink[pixel] ? 255 : 0
        for channel in 0..<4 {
            let byte = channel == 3 ? 255 : expected
            let offset = pixel * 4 + channel
            let surface = control.backend.surface[offset]
            let payload = control.backend.payload[offset]
            precondition(surface == byte && payload == byte)
        }
    }
    let active = control.backend.active
    let bytes = control.backend.submittedBytes
    let rows = control.backend.submittedRows
    precondition(!active && bytes == 48000 && rows == 120)
    let health = control.backend.health
    let observedHealth = control.backend.endpointHealthObservation
    let constructed = control.backend.constructedEndpoints
    precondition(health == observedHealth && health.operationalCount == 1 && constructed == 1)
    let projectionControls = control.backend.projectionControls
    let envelopeRejections = control.backend.envelopeRejections
    precondition(projectionControls == 5 && envelopeRejections > 0)
    return 48030
}
#endif
