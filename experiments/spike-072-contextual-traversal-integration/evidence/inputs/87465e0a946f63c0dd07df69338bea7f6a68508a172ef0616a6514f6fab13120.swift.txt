import GiftUI
import GiftUISemanticCore
import GiftUIRenderCore
import GiftUITextResources
import GiftUILayout
import GiftUIExecution
import GiftUIDrawing
import Darwin
@main struct Main {
    static func main() {
        withUnsafeTemporaryAllocation(of:Entry.self,capacity:2) { storage in
            storage.initialize(repeating:Entry())
            defer { storage.deinitialize() }
            let result=runChecks(storage)
            print("SPIKE-072 checks: \(result.count), failures: \(result.failures)")
            fflush(nil)
            precondition(result.failures==0)
        }
    }
}
