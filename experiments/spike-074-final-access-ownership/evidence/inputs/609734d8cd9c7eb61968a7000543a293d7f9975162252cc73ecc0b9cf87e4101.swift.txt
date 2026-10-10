import Driver
import HostBridge
@main struct Main {
    static func main() {
        let checks = runChecks()
        print("checks=\(checks.total) failures=\(checks.failures) mask=\(checks.failureMask)")
        print("slot=\(slotStride()) owner=\(ownerStride()) key=\(keyStride()) record=\(recordStride()) counter=\(counterStride()) canvas=\(canvasStride())")
        precondition(checks.failures == 0 && checks.total >= 40)
    }
}
