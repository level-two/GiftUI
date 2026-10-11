@main struct BackingNegativeMain {
    static func main() {
        var escaped = rejectDestroyedLocalProfile(seed: UInt8(truncatingIfNeeded: CommandLine.arguments.count) | 1)
        precondition(escaped.runOpportunity())
        escaped.quiesce()
    }
}
