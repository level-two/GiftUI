import Foundation
import SwiftParser
import SwiftSyntax
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

    func testCheckedStateHelpersSelectOriginalWrappersInLexicalOrder() {
        let source = checkedSource(names: ["first", "second"])
        let (expanded, diagnostics) = expandChecked(source)
        XCTAssertTrue(diagnostics.isEmpty)
        XCTAssertTrue(
            expanded.contains(
                "visitor.visit(&self._giftUIStateStorage_first, declarationOrdinal: 0)"))
        XCTAssertTrue(
            expanded.contains(
                "visitor.visit(&self._giftUIStateStorage_second, declarationOrdinal: 1)"))
    }

    func testNestedCheckedStateHelpersStayInTheirOwningNominal() {
        let nested = checkedSource(names: ["inner"]).replacingOccurrences(
            of: "struct Root", with: "struct Nested")
        let source = checkedSource(names: ["outer"], extra: nested)
        let (expanded, diagnostics) = expandChecked(source)
        XCTAssertTrue(diagnostics.isEmpty)
        XCTAssertTrue(
            expanded.contains(
                "visitor.visit(&self._giftUIStateStorage_outer, declarationOrdinal: 0)"))
        XCTAssertTrue(
            expanded.contains(
                "visitor.visit(&self._giftUIStateStorage_inner, declarationOrdinal: 0)"))
    }

    func testReservedStateHelperLookalikesAreDiagnosedWithoutFallback() {
        let valid = checkedSource(names: ["first", "second"])
        let key = ObservableStateHostMacro.checkedStateHelpers(name: "first", schema: "Schema")[1]
            .description
        let storage = ObservableStateHostMacro.checkedStateHelpers(name: "first", schema: "Schema")[
            0
        ].description
        let variants = [
            valid.replacingOccurrences(of: "yield _first", with: "yield _second"),
            valid.replacingOccurrences(of: "yield &_first", with: "yield &_second"),
            valid.replacingOccurrences(
                of: "try _first._giftUIKey()", with: "try _second._giftUIKey()"),
            valid.replacingOccurrences(
                of: storage, with: storage.replacingOccurrences(of: "Schema", with: "OtherSchema")),
            valid.replacingOccurrences(of: key, with: ""),
            valid.replacingOccurrences(of: key, with: key + key),
            valid.replacingOccurrences(of: "_read { yield _first }", with: "get { _first }"),
            valid.replacingOccurrences(
                of: "_modify { yield &_first }", with: "set { _first = newValue }"),
            valid.replacingOccurrences(
                of: "try _first._giftUIKey()", with: "try makeUncheckedKey()"),
            valid.replacingOccurrences(
                of: "internal borrowing func _giftUIStateKey_first()",
                with: "internal borrowing func _giftUIStateKey_first<T>()"),
            valid.replacingOccurrences(
                of: "struct Root: View {",
                with: "struct Root: View { var _giftUIStateKey_orphan: Int { 0 }"),
        ]
        for source in variants {
            XCTAssertNotEqual(source, valid)
            let (expanded, diagnostics) = expandChecked(source)
            XCTAssertEqual(
                diagnostics,
                [
                    "reserved State helpers must exactly yield and check their original concrete-schema wrapper"
                ])
            XCTAssertFalse(expanded.contains("func _giftUIVisitObservableStateDeclarations"))
        }
    }

    func testLowererRejectsReservedInputCollisionsIncludingEscapedNames() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let schema = directory.appendingPathComponent("schema.json")
        try #"{"module":"SchemaModule","domain":"ReadDomain","imports":[],"models":[],"calls":[]}"#
            .write(to: schema, atomically: true, encoding: .utf8)
        for member in [
            "var _giftUIStateStorage_model: Int", "func `_giftUIStateKey_model`() {}",
            "typealias _giftUIStateKey_model = Int",
        ] {
            let source = directory.appendingPathComponent("source.swift")
            try
                "import GiftUI\nstruct Root: View { \(member)\nvar body: some View { EmptyView() } }"
                .write(to: source, atomically: true, encoding: .utf8)
            XCTAssertThrowsError(
                try lowerGiftUISource(arguments: [
                    "--lower-source", schema.path, source.path,
                    directory.appendingPathComponent("Schema.swift").path,
                    directory.appendingPathComponent("Presentation.swift").path,
                ])
            ) { error in
                XCTAssertTrue(
                    String(describing: error).contains("reserved generated State helper name"))
            }
        }
    }

    private func checkedSource(names: [String], extra: String = "") -> String {
        let fields = names.map {
            "@State<Schema>(seed: Seed()) private var \($0): _GiftUIModelKey<Schema>?"
        }
        let helpers = names.flatMap {
            ObservableStateHostMacro.checkedStateHelpers(name: $0, schema: "Schema")
        }
        .map(\.description)
        return "@ObservableStateHost struct Root: View {\n"
            + (fields + helpers + [extra]).joined(separator: "\n") + "\n}"
    }

    private func expandChecked(_ text: String) -> (String, [String]) {
        let source = Parser.parse(source: text)
        let context = BasicMacroExpansionContext()
        let expanded = source.expand(
            macroSpecs: macroSpecs,
            contextGenerator: {
                BasicMacroExpansionContext(
                    sharingWith: context, lexicalContext: $0.allMacroLexicalContexts())
            },
            indentationWidth: .spaces(4))
        return (expanded.description, context.diagnostics.map(\.message))
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
