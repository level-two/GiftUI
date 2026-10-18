import Foundation
import XCTest

@main struct CheckedStateTests {
    static func main() {
        let suite = XCTestSuite(name: "P08 actual lowerer output")
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testZeroStateExpansionIsDeterministic)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testCompleteFiniteZeroStateShapeHasNoStateBackingVisits)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testOrdinaryZeroStateWitnessesAreNotSerializedAtAnyHostAccess)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testDirectStatesExpandOnceInLexicalOrder)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testPortableProfileExpansionIsDeterministic)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testPrivateHostUsesAccessibleProtocolWitnesses)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testInheritedStateIsNotEnumeratedByDerivedHost)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testMalformedStateDeclarationIsDiagnosed)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testDeclarationLimitAcceptsUInt16MaxAndRejectsTheOverflowShape)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testCheckedStateHelpersSelectOriginalWrappersInLexicalOrder)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testNestedCheckedStateHelpersStayInTheirOwningNominal)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testOrdinaryPrivateStateWitnessesAreNotSerializedAtAnyHostAccess)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testCompleteFiniteShapeSelectsSerializedWitnesses)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testIncompleteABIDependenciesDoNotSelectSerialization)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testUnsupportedGenericHeadersDoNotSelectSerialization)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testUnprovableEnclosingContextsDoNotSelectSerialization)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testReservedStateHelperLookalikesAreDiagnosedWithoutFallback)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testLowererRejectsReservedInputCollisionsIncludingEscapedNames)))
        suite.addTest(ObservableStateHostMacroTests(selector: #selector(ObservableStateHostMacroTests.testActualLoweredStateOutputHasSeparatedHelperDeclarations)))
        suite.run()
        guard let run = suite.testRun else { fatalError("XCTest did not produce a test run") }
        print("executions=\(run.executionCount) failures=\(run.totalFailureCount) skips=\(run.skipCount)")
        guard run.executionCount == 19, run.totalFailureCount == 0, run.skipCount == 0 else { exit(1) }
    }
}
