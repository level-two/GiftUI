@main
enum PhysicalFactsQualification {
    static func main() {
        if CommandLine.arguments.dropFirst().first == "--missing-row-fatal" {
            p08CounterPhysicalFactsMissingRowsFatal()
            preconditionFailure("expected missing-row precondition")
        }
        let checks = p08CounterPhysicalFactsQualification()
        precondition(checks > 0)
        print(
            "physical facts Static/Dynamic independent rows, five banks, 26 totals, audits, mismatch, refusal, faults, surplus, destruction PASS checks=\(checks)"
        )
    }
}
