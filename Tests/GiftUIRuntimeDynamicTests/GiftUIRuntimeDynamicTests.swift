import Testing
import GiftUI
@testable import GiftUIRuntimeDynamic

@MainActor
@Test
func statePersistsAndInvalidates() {
    let runtime = DynamicRuntime()
    let key = StateKey(path: "root", slot: 0)

    #expect(runtime.state.read(key: key, initialValue: 21) == 21)
    runtime.markRendered()
    runtime.state.write(22, key: key)

    #expect(runtime.state.read(key: key, initialValue: 0) == 22)
    #expect(runtime.isInvalid)
}
