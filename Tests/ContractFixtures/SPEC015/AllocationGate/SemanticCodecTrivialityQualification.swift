// Compile with the actual Counter module sources. This checked marker rejects
// future owning fields without changing the production codec or its lifetimes.
extension CounterSemanticCodec: BitwiseCopyable {}

#if GIFTUI_CODEC_OWNERSHIP_NEGATIVE
private final class CodecOwnedReference {}

private struct OwningCodecControl: BitwiseCopyable {
    let owner: CodecOwnedReference
}
#endif
