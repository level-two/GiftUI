import GiftUIRenderLowering

private let nanosecondsPerSecond: Int64 = 1_000_000_000

@_silgen_name("giftui_allocation_probe_reset")
private func resetAllocationCount()

@_silgen_name("giftui_allocation_probe_read")
private func readAllocationCount() -> UInt64

@main
private enum RenderEvidenceMain {
    static func main() {
        let clock = ContinuousClock()
        _ = clock.now
        var checksum: UInt16 = 0
        checksum &+= spec008StaticRenderProductionEntry()
        resetAllocationCount()
        for _ in 0 ..< 9 {
            checksum &+= spec008StaticRenderProductionEntry()
        }
        let allocationCount = readAllocationCount()
        print("allocation_count=\(allocationCount)")

        for sample in 0 ..< 9 {
            let started = clock.now
            checksum &+= spec008StaticRenderProductionEntry()
            let components = started.duration(to: clock.now).components
            let nanoseconds =
                components.seconds * nanosecondsPerSecond
                + components.attoseconds / nanosecondsPerSecond
            print("sample_\(sample + 1)_nanoseconds=\(nanoseconds)")
        }
        print("checksum=\(checksum)")
    }
}
