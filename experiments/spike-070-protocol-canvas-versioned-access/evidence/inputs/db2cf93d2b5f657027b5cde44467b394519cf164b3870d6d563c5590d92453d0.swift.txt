@main enum Main {
    static func main() {
        let failures = withUnsafeTemporaryAllocation(of: Transition.self, capacity: 808) { values in
            values.initialize(repeating: Transition(tick: 0, level: 0, channel: 0))
            defer { values.deinitialize() }
            var recorder = Recorder()
            return withUnsafeMutablePointer(to: &recorder) { pointer in
                driver(UnsafeMutableRawPointer(values.baseAddress!), UnsafeMutableRawPointer(pointer))
            }
        }
        let names = ["transition-stride", "outside-frame", "coherent-fields", "indexed-helper", "foreign-key",
                     "stale-generation", "invalid-field", "stale-frame", "generated-body-leaf-witness", "deferred-draw",
                     "layout-before-draw", "repeated-canvas", "success-cleanup", "trace-canvas", "body-error",
                     "frozen-mutation", "revision", "draw-error", "failure-cleanup", "publication-dirty", "source-defaults"]
        for (index, name) in names.enumerated() {
            print("\(name) \((failures & (1 << index)) == 0 ? "PASS" : "FAIL")")
        }
        print("transition-stride \(MemoryLayout<Transition>.stride)")
        print("model-key-stride \(MemoryLayout<ModelKey>.stride)")
        print("owner-stride \(MemoryLayout<ModelOwner>.stride)")
        precondition(failures == 0, "Fixture failed")
    }
}
