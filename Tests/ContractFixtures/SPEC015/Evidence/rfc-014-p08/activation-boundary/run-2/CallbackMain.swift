import GiftUIObservableState
import GiftUISemanticCore
@main struct CallbackNegativeMain {
    static func main() {
        var models = ObservableModelOwnerNamespace()
        var semantic = SemanticRecordOwnerNamespace()
        do {
            var profile = StaticCycleProfileStorage(modelOwner: try models.issue(), semanticOwner: try semantic.issue())
            print(profile.rejectActiveAfterCallbacks(seed: UInt8(truncatingIfNeeded: CommandLine.arguments.count) | 1))
        } catch { preconditionFailure("namespace setup") }
    }
}
