import ABISemantics

@main struct Main {
    static func main() {
        precondition(abiSemanticChecks() == 18)
        print("analyzer-abi semantics=18 failures=0")
    }
}
