@main struct MutationChecks {
    static func main() throws {
        let checks = try mutationChecks()
        precondition(checks == 19)
        print("P03 checked mutation and discovery checks=\(checks) failures=0")
    }
}
