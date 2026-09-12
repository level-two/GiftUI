import GiftUIRuntimeStaticProbe

@_cdecl("giftui_spec013_static_profile_probe")
public func giftUISPEC013StaticProfileProbe() -> UInt32 {
    spec013StaticProfileLayoutChecksum() &+ spec013StaticBindingProbe()
}
