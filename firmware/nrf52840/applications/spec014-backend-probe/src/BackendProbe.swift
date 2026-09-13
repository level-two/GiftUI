#if GIFTUI_SPEC014_CANDIDATE
import GiftUIBackendEvidenceProbe
#endif

@_cdecl("giftui_spec014_backend_probe")
public func giftUISPEC014BackendProbe(_ seed: UInt32) -> UInt32 {
#if GIFTUI_SPEC014_CANDIDATE
    seed &+ spec014EmbeddedBackendEntry()
#else
    seed
#endif
}
