@main
struct HostMain {
    static func main() {
        let result = spike008SwiftRun(7)
        print("result\t\(result)")
        print("status\t\(result == 0 ? "fail" : "pass")")
    }
}
