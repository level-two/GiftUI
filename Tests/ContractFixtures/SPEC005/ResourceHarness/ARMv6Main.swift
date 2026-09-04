@main
enum GiftUISPEC005ARMv6ResourceMain {
    static func main() {
        let result = giftuiSpec005ResourceProbe(0x5005)
        if result == UInt32.max {
            fatalError("SPEC-005 ARMv6 resource probe failed")
        }
    }
}
