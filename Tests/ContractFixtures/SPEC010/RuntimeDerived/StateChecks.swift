@main struct StateChecks {
    static func main() throws {
        let count = try stateChecks()
        precondition(count == 15)
        print("P03 State declarations: \(count) assertions passed")
    }
}
