@main struct ActivationFenceMain {
    static func main() {
        let checks = investigationPositiveCaller()
        precondition(checks == 5)
        print("activation-fence: five lifecycle assertions and coordinator quiescence passed")
    }
}
