import Foundation
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import GiftUIMacros

final class ObservableStateHostMacroTests: XCTestCase {
    private let macroSpecs = [
        "ObservableStateHost": MacroSpec(
            type: ObservableStateHostMacro.self,
            conformances: ["_GiftUIObservableStateHost"]
        )
    ]

    func testZeroStateExpansionIsDeterministic() throws {
        try assertFixture("zero")
    }

    func testDirectStatesExpandOnceInLexicalOrder() throws {
        try assertFixture("several")
    }

    func testPortableProfileExpansionIsDeterministic() throws {
        try assertFixture("portable-profile")
    }

    func testPrivateHostUsesAccessibleProtocolWitnesses() throws {
        try assertFixture("private")
    }

    func testInheritedStateIsNotEnumeratedByDerivedHost() throws {
        try assertFixture("inherited")
    }

    func testMalformedStateDeclarationIsDiagnosed() throws {
        try assertFixture(
            "malformed",
            diagnostics: [
                DiagnosticSpec(
                    message: "@State must decorate one direct stored property",
                    line: 3,
                    column: 5
                )
            ]
        )
    }

    func testDeclarationLimitAcceptsUInt16MaxAndRejectsTheOverflowShape() {
        XCTAssertFalse(ObservableStateHostMacro.exceedsDeclarationLimit(Int(UInt16.max)))
        XCTAssertTrue(ObservableStateHostMacro.exceedsDeclarationLimit(Int(UInt16.max) + 1))
    }

    private func assertFixture(
        _ id: String,
        diagnostics: [DiagnosticSpec] = [],
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("ContractFixtures/SPEC010/MacroExpansion")
        let source = try String(
            contentsOf: root.appendingPathComponent("Sources/\(id).swift"),
            encoding: .utf8
        )
        let expected = try String(
            contentsOf: root.appendingPathComponent("Expected/\(id).swift"),
            encoding: .utf8
        )

        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: diagnostics,
            macroSpecs: macroSpecs,
            file: file,
            line: line
        )
    }
}
