@main struct ActivationSpanMain {
    static func main() {
        let checks = investigationPositiveCaller()
        precondition(checks == 5)
        print("activation-span: five lifecycle assertions and coordinator quiescence passed")
    }
}
