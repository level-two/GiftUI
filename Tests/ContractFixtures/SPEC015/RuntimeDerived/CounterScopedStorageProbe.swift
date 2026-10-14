// The trusted factory keeps capabilities private. This registered finite entry
// receives owned check counts only; no scoped value or physical pointer escapes.
package func p08CounterScopedStorage(backing: UnsafeMutableRawBufferPointer? = nil, write: CounterTiledPixelWrite? = nil) -> Int {
    counterExerciseScopedStorage(backing: backing, write: write)
}

#if !hasFeature(Embedded) && GIFTUI_COUNTER_NATIVE_EXCLUSIVITY
@MainActor package func p08CounterScopedExclusivity(negative: Bool) -> Int {
    counterScopedNativeExclusivity(negative: negative)
}
#endif
