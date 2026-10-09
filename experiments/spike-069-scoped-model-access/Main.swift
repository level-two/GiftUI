@main
struct Main {
    static func main() {
        // Test harness allocation only. Target candidate entry accepts backing
        // supplied before activation; this file is never compiled for nRF/Pi.
        let backing = UnsafeMutableRawPointer.allocate(byteCount: 5 * 404 * 16, alignment: 8)
        defer { backing.deallocate() }
        let actual = lifetimeDriver(backing)
        let labels = [
            "404-transition-value-read", "attachment-failure-preserves-old",
            "failed-candidate-release", "admission-during-freeze",
            "replacement-survives-derivation-failure", "application-retained-old-model",
            "declaration-snapshot-pinned-through-invocation", "one-shot-callable-release",
            "pool-exhaustion-preserves-installed", "stale-key-after-slot-reuse",
            "wrong-owner-context", "zero-canvas-occurrences",
            "disjoint-model-report-result", "pin-outlives-application-owner",
            "discard-releases-last-pin", "quiescent-teardown",
        ]
        for (index, label) in labels.enumerated() {
            print(label, (actual & (UInt64(1) << index)) != 0 ? "PASS" : "FAIL")
        }
        print("transition-stride", MemoryLayout<Transition>.stride)
        print("capture-owner-stride", MemoryLayout<CaptureOwner>.stride)
        print("snapshot-key-stride", MemoryLayout<SnapshotKey>.stride)
        print("canvas-work-stride", MemoryLayout<CanvasWork>.stride)
        print("snapshot-pool-stride", MemoryLayout<SnapshotPool>.stride)
        precondition(actual == 65535, "lifetime fixture failed: \(actual)")
    }
}
