import GiftUI
import GiftUICapabilities
import GiftUISurfaceCore
import Testing

@testable import GiftUIRasterCore

struct EncodingBoundary: Sendable {
    let channel: UInt8
    let rgb565High: UInt8
    let rgb565Low: UInt8
}

private let encodingBoundaries = [
    EncodingBoundary(channel: 0, rgb565High: 0x00, rgb565Low: 0x00),
    EncodingBoundary(channel: 1, rgb565High: 0x00, rgb565Low: 0x00),
    EncodingBoundary(channel: 127, rgb565High: 0x7B, rgb565Low: 0xEF),
    EncodingBoundary(channel: 128, rgb565High: 0x84, rgb565Low: 0x10),
    EncodingBoundary(channel: 254, rgb565High: 0xFF, rgb565Low: 0xFF),
    EncodingBoundary(channel: 255, rgb565High: 0xFF, rgb565Low: 0xFF),
]

@Test(arguments: encodingBoundaries)
func canonicalEncodingMatchesEveryRequiredChannelBoundary(
    _ boundary: EncodingBoundary
) {
    let color = Color(
        red: boundary.channel,
        green: boundary.channel,
        blue: boundary.channel
    )
    let rgba = CanonicalEncodedPixel(color: color, encoding: .rgba8888)
    let rgb565 = CanonicalEncodedPixel(
        color: color,
        encoding: .rgb565BigEndian
    )

    #expect(rgba.byteCount == 4)
    #expect(rgba.byte0 == boundary.channel)
    #expect(rgba.byte1 == boundary.channel)
    #expect(rgba.byte2 == boundary.channel)
    #expect(rgba.byte3 == 255)
    #expect(rgb565.byteCount == 2)
    #expect(rgb565.byte0 == boundary.rgb565High)
    #expect(rgb565.byte1 == boundary.rgb565Low)
    #expect(rgb565.byte2 == 0)
    #expect(rgb565.byte3 == 0)
}

@Test
func rgb565UsesBigEndianCanonicalChannelPacking() {
    let red = CanonicalEncodedPixel(color: .red, encoding: .rgb565BigEndian)
    let green = CanonicalEncodedPixel(color: .green, encoding: .rgb565BigEndian)
    let blue = CanonicalEncodedPixel(color: .blue, encoding: .rgb565BigEndian)

    #expect((red.byte0, red.byte1) == (0xF8, 0x00))
    #expect((green.byte0, green.byte1) == (0x07, 0xE0))
    #expect((blue.byte0, blue.byte1) == (0x00, 0x1F))
}
