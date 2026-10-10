// Equivalent lowered representative source forms; not a source transformer.
import GiftUI
import SignalAnalyzerDomain
import ApplicationSchema

@Builder package func badge<D: ReadDomain>(_ value: UInt32, domain: D.Type) -> some View<D> {
    Label<D>(value)
    Label<D>(3)
}
package struct CounterRoot<D: CounterReadDomain>: View {
    package typealias Domain = D
    package let key: ModelKey<CounterSchema>
    package init(_ key: ModelKey<CounterSchema>) { self.key = key }
    @Builder package func evaluate(read: borrowing FrameRead<D>) throws(AccessFailure) -> some View<D> {
        let model = try CounterRead(key, read: read)
        if model.value > 0 {
            Label<D>(UInt32(model.value))
            badge(2, domain: D.self)
        } else {
            Label<D>(0)
        }
    }
}
package struct AnalyzerChild<D: AnalyzerReadDomain>: View {
    package typealias Domain = D
    package let key: ModelKey<AnalyzerSchema>
    @Builder package func evaluate(read: borrowing FrameRead<D>) throws(AccessFailure) -> some View<D> {
        let model = try AnalyzerRead(key, read: read)
        Label<D>(UInt32(model.count))
        Label<D>(model.acquisitionState == .running ? 10 : 0)
    }
}
package struct AnalyzerRoot<D: AnalyzerReadDomain>: View {
    package typealias Domain = D
    package let key: ModelKey<AnalyzerSchema>
    package init(_ key: ModelKey<AnalyzerSchema>) { self.key = key }
    @Builder package func evaluate(read: borrowing FrameRead<D>) throws(AccessFailure) -> some View<D> {
        AnalyzerChild<D>(key: key)
        badge(1, domain: D.self)
    }
}
package struct Trace<D: AnalyzerReadDomain>: Canvas {
    package typealias Domain = D
    package let key: ModelKey<AnalyzerSchema>
    package let position: Int
    package init(_ key: ModelKey<AnalyzerSchema>, position: Int) { self.key = key; self.position = position }
    package func draw(read: borrowing FrameRead<D>) throws(AccessFailure) -> UInt32 {
        let model = try AnalyzerRead(key, read: read)
        let capture = model.capture()
        let transition = try capture.transition(at: position)
        return UInt32(transition.channelID.rawValue) * 10 + (transition.level == .high ? 1 : 0)
    }
}
