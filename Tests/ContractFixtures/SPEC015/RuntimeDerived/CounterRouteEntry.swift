import GiftUIHostConfiguration

package typealias CounterTiledPixelWrite = @convention(c) (UInt16, UInt16, UInt16, UInt16, UnsafePointer<UInt8>?, Int) -> Int32

var counterStaticHostKind: MVPHostKind {
    #if hasFeature(Embedded)
    .nrf52840Static
    #else
    .macOSStatic
    #endif
}

#if !hasFeature(Embedded)
var counterDynamicHostKind: MVPHostKind {
    #if os(Linux)
    .raspberryPiDynamic
    #else
    .macOSDynamic
    #endif
}

#endif
// One selected registered profile, with the same finite host corpus.
// Firmware supplies its existing synchronous SPI writer at this fixture C root.
#if hasFeature(Embedded)
@_cdecl("giftui_rfc014_counter_entry")
func giftuiRFC014CounterEntry(_ write: CounterTiledPixelWrite?, _ backing: UnsafeMutableRawPointer?, _ byteCount: Int) -> UInt32 {
    precondition(backing != nil && byteCount == counterEmbeddedSlotCount * counterEmbeddedSlotBytes)
    return UInt32(p08CounterRoute(write: write, backing: UnsafeMutableRawBufferPointer(start: backing, count: byteCount)))
}
#else
@_cdecl("giftui_rfc014_counter_entry")
func giftuiRFC014CounterEntry(_ write: CounterTiledPixelWrite?) -> UInt32 {
    UInt32(p08CounterRoute(write: write))
}
#endif

package func p08CounterRoute(write: CounterTiledPixelWrite? = nil, backing: UnsafeMutableRawBufferPointer? = nil) -> Int {
    #if GIFTUI_COUNTER_ROUTE_DYNAMIC
    p08CounterGraph() + p08CounterDynamicHost()
    #else
    p08CounterGraph(backing: backing) + p08CounterHost(write: write, backing: backing)
    #endif
}
