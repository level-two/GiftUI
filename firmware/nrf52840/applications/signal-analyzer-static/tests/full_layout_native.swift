// Execute the firmware's exact amalgamated Swift source on a native host.
// This checks the production diagnostic semantic-to-layout path without a board.
@main
struct FullLayoutNativeCheck {
    static func main() {
        let profile = UnsafeMutableRawPointer.allocate(byteCount: 39_696, alignment: 8)
        let capture = UnsafeMutableRawPointer.allocate(byteCount: 115_392, alignment: 8)
        let raster = UnsafeMutableRawPointer.allocate(byteCount: 3_840, alignment: 8)
        let coverage = UnsafeMutableRawPointer.allocate(byteCount: 240, alignment: 8)
        defer {
            profile.deallocate()
            capture.deallocate()
            raster.deallocate()
            coverage.deallocate()
        }
        profile.initializeMemory(as: UInt8.self, repeating: 0, count: 39_696)
        capture.initializeMemory(as: UInt8.self, repeating: 0, count: 115_392)
        raster.initializeMemory(as: UInt8.self, repeating: 0, count: 3_840)
        coverage.initializeMemory(as: UInt8.self, repeating: 0, count: 240)
        precondition(
            giftUISignalAnalyzerTopologyValid(profile, 39_696, capture, 115_392) == 1,
            "diagnostic semantic topology failed"
        )
        precondition(
            giftUISignalAnalyzerFullLayoutValid(profile, 39_696) == 1,
            "full diagnostic layout failed"
        )
        precondition(
            giftUISignalAnalyzerDrawingStorageValid(profile, 39_696) == 1,
            "fixed Drawing workspace failed"
        )
        precondition(
            giftUISignalAnalyzerCanvasPayloadValid(profile, 39_696) == 1,
            "bounded Canvas payload failed"
        )
        precondition(
            giftUISignalAnalyzerFullCanvasValid(profile, 39_696, capture, 115_392) == 1,
            "five Canvas derivation failed"
        )
        precondition(
            giftUISignalAnalyzerTileValid(raster, 3_840, coverage, 240) == 1,
            "fixed RGB565 tile failed"
        )
        print("nRF layout and Drawing storage: passed")
    }
}
