import Testing
@testable import GiftUIRuntimeDynamic

@Test
func moduleIsAvailable() {
    #expect(GiftUIRuntimeDynamicModule.name == "GiftUIRuntimeDynamic")
}
