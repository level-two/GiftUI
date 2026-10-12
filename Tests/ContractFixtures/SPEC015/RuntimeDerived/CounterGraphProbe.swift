import GiftUIHostConfiguration

// Malformed views are confined to this negative fixture, never accepted by a
// production assembly initializer. Every mutation starts from the actual table.
private struct CounterInvalidGraph: HostComponentGraphView {
    let mode: UInt8
    var count: UInt8 { mode == 0 ? 17 : mode == 7 ? 19 : 18 }
    func record(at index: UInt8) -> HostComponentRecord? {
        let base = CounterHostGraph()
        if mode == 1 && index == 17 { return base.record(at: 16) }
        if mode == 2 && index == 1 { return base.record(at: 2) }
        if mode == 3 && index == 10 { return nil }
        guard let original = base.record(at: index) else { return nil }
        if index == 0 {
            if mode == 4 { return .init(role: original.role, dependencies: .init(rawValue: 1)) }
            if mode == 5 { return .init(role: original.role, dependencies: .init(rawValue: 2)) }
            if mode == 6 { return .init(role: original.role, dependencies: .init(rawValue: 1 << 31)) }
        }
        return original
    }
}
package func p08CounterGraph() -> Int {
    precondition(HostComponentGraphValidation.validate(CounterHostGraph()) == nil)
    precondition(CounterHostGraph().record(at: 18) == nil)
    for mode: UInt8 in 0...7 { precondition(HostComponentGraphValidation.validate(CounterInvalidGraph(mode: mode)) != nil) }
    return 10
}
