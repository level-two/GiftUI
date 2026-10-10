@main struct Main {
    static func main() {
        let result = runChecks()
        print("checks=\(result.total) failures=\(result.failures)")
        precondition(result.total == 15 && result.failures == 0)
    }
}
