/// Task-local body evaluation context used only by the dynamic runtime.
package final class StateBindingContext: @unchecked Sendable {
    @TaskLocal package static var current: StateBindingContext?

    package let storage: any StateStorage
    private let path: String
    private var nextSlot = 0

    private init(storage: any StateStorage, path: String) {
        self.storage = storage
        self.path = path
    }

    package func nextKey() -> StateKey {
        defer { nextSlot += 1 }
        return StateKey(path: path, slot: nextSlot)
    }

    package static func with<Result>(
        storage: any StateStorage,
        path: String,
        perform: () -> Result
    ) -> Result {
        precondition(current == nil, "GiftUI body evaluation must not be reentrant")
        let context = StateBindingContext(storage: storage, path: path)
        return $current.withValue(context, operation: perform)
    }
}
