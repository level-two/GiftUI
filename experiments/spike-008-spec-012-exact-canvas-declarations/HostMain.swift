@main
struct HostMain {
    static func main() {
        let result = spike008SwiftRun(7)
        let expected: UInt32 = 1_350_566_773
        print("result\t\(result)")
        print("expected\t\(expected)")
        print("status\t\(result == expected ? "pass" : "fail")")
    }
}
