import GiftUIFailureCore
import GiftUIFailureDiagnostics

@_silgen_name("giftui_spec003_resource_entry")
private func giftuiSpec003CEntry(_ seed: UInt32) -> UInt32

@_silgen_name("giftui_spec003_consume")
private func giftuiSpec003Consume(_ value: UInt32)

giftuiSpec003Consume(
    giftuiSpec003CEntry(41)
        &+ giftuiSpec003Health.failureCount
        &+ UInt32(giftuiSpec003DiagnosticBuffer.count)
        &+ giftuiSpec003DiagnosticCounters.accepted
)
