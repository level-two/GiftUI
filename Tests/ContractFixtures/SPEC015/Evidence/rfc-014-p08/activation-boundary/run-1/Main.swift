@main struct ActivationBoundaryMain {
    static func main() {
        let seed = UInt8(truncatingIfNeeded: CommandLine.arguments.count) | 1
        let checks = investigationPositiveCaller(seed: seed)
        precondition(checks == 5)
        print("activation-boundary: five lifecycle assertions and coordinator quiescence passed")
    }
}
