@main struct NativeMain {
    static func main() {
        var cases = 0
        for populated in UInt32(0)...1 {
            for state in UInt32(0)...3 {
                for window in UInt32(0)...2 {
                    for diagnostic in UInt32(0)...1 {
                        if state == 3 && diagnostic == 0 { continue }
                        precondition(spike010Derive(state, window, diagnostic, populated, 64, 512) == 92)
                        precondition(spike010Derive(state, window, diagnostic, populated, 1, 512) == 0)
                        precondition(spike010Derive(state, window, diagnostic, populated, 64, 1) == 0)
                        precondition(spike010Derive(state, window, diagnostic, populated, 64, 512) == 92)
                        cases += 1
                    }
                }
            }
        }
        print("42 real-body bounded traversals; 84 contained capacity/depth refusals; 42 subsequent successes")
    }
}
