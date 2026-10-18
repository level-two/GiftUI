import DeclarationHost

@main struct Main {
    static func main() {
        let result = runDeclarationChecks()
        print("checks=\(result.checks) failures=\(result.failures)")
        precondition(result.checks == 120 && result.failures == 0)
    }
}
