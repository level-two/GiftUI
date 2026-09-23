// Execute the firmware's exact amalgamated Swift source on a native host.
// This checks the production diagnostic semantic-to-layout path without a board.
@main
struct FullLayoutNativeCheck {
    private static let accept: @convention(c) (
        UInt16, UInt16, UInt16, UInt16, UnsafePointer<UInt8>?, Int
    ) -> Int32 = { x, y, width, height, pixels, byteCount in
        x < 480 && y < 320 && width > 0 && height == 1
            && UInt32(x) + UInt32(width) <= 480
            && byteCount == Int(width) * 2 && pixels != nil ? 0 : -1
    }

    private static let refuse: @convention(c) (
        UInt16, UInt16, UInt16, UInt16, UnsafePointer<UInt8>?, Int
    ) -> Int32 = { _, _, _, _, _, _ in -1 }

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
            giftUISignalAnalyzerFullCanvasValid(
                profile, 39_696, capture, 115_392, raster, 3_840,
                coverage, 240
            ) == 1,
            "five Canvas derivation failed"
        )
        precondition(
            giftUISignalAnalyzerPresentInitial(
                profile, 39_696, capture, 115_392, raster, 3_840,
                coverage, 240, accept
            ) == 1,
            "initial Canvas offer failed"
        )
        precondition(giftUISignalAnalyzerInitialModelActive() == 1)
        precondition(
            giftUISignalAnalyzerPresentInitial(
                profile, 39_696, capture, 115_392, raster, 3_840,
                coverage, 240, accept
            ) == 0,
            "active model admitted a second initial offer"
        )
        giftUISignalAnalyzerRetireInitial()
        precondition(giftUISignalAnalyzerInitialModelActive() == 0)
        precondition(
            giftUISignalAnalyzerPresentInitial(
                profile, 39_696, capture, 115_392, raster, 3_840,
                coverage, 240, refuse
            ) == 0,
            "initial Canvas offer hid display refusal"
        )
        precondition(giftUISignalAnalyzerInitialModelActive() == 0)
        precondition(
            giftUISignalAnalyzerPresentInitial(
                profile, 39_696, capture, 115_392, raster, 3_840,
                coverage, 240, accept
            ) == 1,
            "retired model could not activate again"
        )
        giftUISignalAnalyzerRetireInitial()
        precondition(
            giftUISignalAnalyzerTileValid(raster, 3_840, coverage, 240) == 1,
            "fixed RGB565 tile failed"
        )
        print("nRF layout and Drawing storage: passed")
    }
}
