#if GIFTUI_SPEC008_CANDIDATE
import GiftUIRenderEvidenceProbe
#endif

@_cdecl("giftui_spec008_render_probe")
public func giftUISPEC008RenderProbe(_ seed: Int32) -> Int32 {
#if GIFTUI_SPEC008_CANDIDATE
    seed &+ Int32(spec008StaticRenderProductionEntry())
#else
    seed
#endif
}
