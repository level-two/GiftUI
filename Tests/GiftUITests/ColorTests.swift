import GiftUI
import Testing

@Test
func colorHasExactLayoutAndStoredChannels() {
    let color = Color(red: 17, green: 34, blue: 51)

    #expect(MemoryLayout<Color>.size == 3)
    #expect(MemoryLayout<Color>.stride == 3)
    #expect(MemoryLayout<Color>.alignment == 1)
    #expect(color.red == 17)
    #expect(color.green == 34)
    #expect(color.blue == 51)
}

@Test
func namedColorsHaveExactOpaqueRGBValues() {
    #expect(Color.black == Color(red: 0, green: 0, blue: 0))
    #expect(Color.white == Color(red: 255, green: 255, blue: 255))
    #expect(Color.red == Color(red: 255, green: 0, blue: 0))
    #expect(Color.green == Color(red: 0, green: 255, blue: 0))
    #expect(Color.blue == Color(red: 0, green: 0, blue: 255))
    #expect(Color.gray == Color(red: 128, green: 128, blue: 128))
}

@Test
func colorSupportsRequiredValueConformances() {
    let values: Set<Color> = [.black, .white, .black]
    let sendable: any Sendable = Color.gray

    #expect(values == [.black, .white])
    #expect(sendable is Color)
}
