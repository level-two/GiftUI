@_silgen_name("spike002_print_paths")
func printPaths()

@main
struct Spike002HostMain {
    static func main() {
        let digest = spike002CandidateRun(0x5a17c3e1)
        printPaths()
        print("DIGEST\t\(digest)")
    }
}
