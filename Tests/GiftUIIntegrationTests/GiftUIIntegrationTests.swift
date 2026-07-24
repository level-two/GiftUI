import GiftUI
import GiftUIBackendFramebuffer
import GiftUIRuntimeDynamic
import Testing

@Test
func modulesComposeWithoutPlatformDependencies() {
    #expect(GiftUIRuntimeDynamicModule.name.hasPrefix(GiftUIModule.name))
    #expect(GiftUIBackendFramebufferModule.name.hasPrefix(GiftUIModule.name))
}
