import Testing
import GiftUI
@testable import GiftUIBackendRGB565

@Test
func rgb888QuantizesToCanonicalRGB565Values() {
    #expect(RGB565Pixel(.black).rawValue == 0x0000)
    #expect(RGB565Pixel(.white).rawValue == 0xffff)
    #expect(RGB565Pixel(Color(red: 255, green: 0, blue: 0)).rawValue == 0xf800)
    #expect(RGB565Pixel(Color(red: 0, green: 255, blue: 0)).rawValue == 0x07e0)
    #expect(RGB565Pixel(Color(red: 0, green: 0, blue: 255)).rawValue == 0x001f)
    #expect(
        RGB565Pixel(Color(red: 0xab, green: 0xcd, blue: 0xef, alpha: 0)).rawValue
            == 0xae7d
    )
}

@Test
func rgb565ByteOrderIsExplicit() {
    let pixel = RGB565Pixel(rawValue: 0xabcd)

    #expect(pixel.byte(at: 0, order: .mostSignificantByteFirst) == 0xab)
    #expect(pixel.byte(at: 1, order: .mostSignificantByteFirst) == 0xcd)
    #expect(pixel.byte(at: 0, order: .leastSignificantByteFirst) == 0xcd)
    #expect(pixel.byte(at: 1, order: .leastSignificantByteFirst) == 0xab)
}

@Test
func configurationBoundsTheOnlyPixelBuffer() throws {
    let maximum = try RGB565RendererConfiguration(
        physicalWidth: 480,
        physicalHeight: 320,
        tileHeight: 4
    )

    #expect(maximum.logicalSize == Size(width: 480, height: 320))
    #expect(maximum.tileBufferByteCapacity == 3_840)
    #expect(maximum.tileBufferByteCapacity == RGB565RendererConfiguration.maximumTileBufferByteCapacity)
    #expect(maximum.tileBufferByteCapacity < 480 * 320 * 2)

    let rotated = try RGB565RendererConfiguration(
        physicalWidth: 480,
        physicalHeight: 320,
        rotation: .degrees90
    )
    #expect(rotated.logicalSize == Size(width: 320, height: 480))
}

@Test
func optionalConfigurationValidationAvoidsThrownErrors() {
    let valid = RGB565RendererConfiguration(
        validatingPhysicalWidth: 480,
        physicalHeight: 320,
        tileHeight: 4
    )
    let invalid = RGB565RendererConfiguration(
        validatingPhysicalWidth: 481,
        physicalHeight: 320
    )

    #expect(valid?.tileBufferByteCapacity == 3_840)
    #expect(invalid == nil)
}

@Test(arguments: [
    (0, RGB565ConfigurationError.invalidPhysicalWidth(0)),
    (481, RGB565ConfigurationError.invalidPhysicalWidth(481)),
])
func configurationRejectsInvalidWidths(
    width: Int,
    expected: RGB565ConfigurationError
) {
    #expect(throws: expected) {
        try RGB565RendererConfiguration(physicalWidth: width, physicalHeight: 320)
    }
}

@Test(arguments: [
    (0, RGB565ConfigurationError.invalidPhysicalHeight(0)),
    (321, RGB565ConfigurationError.invalidPhysicalHeight(321)),
])
func configurationRejectsInvalidHeights(
    height: Int,
    expected: RGB565ConfigurationError
) {
    #expect(throws: expected) {
        try RGB565RendererConfiguration(physicalWidth: 480, physicalHeight: height)
    }
}

@Test(arguments: [
    (0, RGB565ConfigurationError.invalidTileHeight(0)),
    (5, RGB565ConfigurationError.invalidTileHeight(5)),
])
func configurationRejectsInvalidTileHeights(
    tileHeight: Int,
    expected: RGB565ConfigurationError
) {
    #expect(throws: expected) {
        try RGB565RendererConfiguration(
            physicalWidth: 480,
            physicalHeight: 320,
            tileHeight: tileHeight
        )
    }
}
