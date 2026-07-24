import Testing
@testable import GiftUI

@Test
func moduleIsAvailable() {
    #expect(GiftUIModule.name == "GiftUI")
}
