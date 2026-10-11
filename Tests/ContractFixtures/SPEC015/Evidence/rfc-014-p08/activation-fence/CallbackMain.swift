import GiftUIObservableState
import GiftUISemanticCore
@main struct CallbackNegativeMain {
    static func main() {
        var models = ObservableModelOwnerNamespace()
        var semantic = SemanticRecordOwnerNamespace()
        do {
            var profile = StaticCycleProfileStorage(modelOwner: try models.issue(), semanticOwner: try semantic.issue())
            print(profile.rejectActiveAfterCallbacks())
        } catch { preconditionFailure("namespace setup") }
    }
}
