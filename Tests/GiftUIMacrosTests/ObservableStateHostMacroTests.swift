import Foundation
import SwiftParser
import SwiftParserDiagnostics
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

    func testActualLoweredStateOutputHasSeparatedHelperDeclarations() throws {
        let sourceRoot = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
        let repository = URL(
            fileURLWithPath:
                ProcessInfo.processInfo.environment["GIFTUI_P08_REGRESSION_ROOT"] ?? sourceRoot.path
        )
        let fixture = repository.appendingPathComponent(
            "Tests/ContractFixtures/SPEC015/RuntimeDerived")
        let original = try String(
            contentsOf: fixture.appendingPathComponent("Counter.swift"), encoding: .utf8)
        let marker = "@State private var model = CounterModel(value: 0)"
        XCTAssertEqual(original.components(separatedBy: marker).count, 2)
        let multiple = original.replacingOccurrences(
            of: marker,
            with: marker + "\n    @State private var other = CounterModel(value: 1)")
        let statefulStart = try XCTUnwrap(original.range(of: "@ObservableStateHost"))
        let child = String(original[statefulStart.lowerBound...])
            .replacingOccurrences(of: "CounterScreen", with: "ChildScreen")
        let nested =
            original.replacingOccurrences(
                of: "CounterCanvas(model: model).frame(width: 48, height: 16)",
                with: "ChildScreen()") + "\n" + child
        let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString)
        let output =
            ProcessInfo.processInfo.environment["GIFTUI_P08_REGRESSION_OUTPUT"]
            .map { URL(fileURLWithPath: $0) } ?? temporary
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        defer { if output == temporary { try? FileManager.default.removeItem(at: temporary) } }
        let cases: [(String, String, [String: [String]])] = [
            ("counter", original, ["CounterScreen": ["model"]]),
            ("multiple", multiple, ["CounterScreen": ["model", "other"]]),
            ("nested", nested, ["CounterScreen": ["model"], "ChildScreen": ["model"]]),
        ]
        for (name, input, expected) in cases {
            let authored = output.appendingPathComponent(name + "-authored.swift")
            try input.write(to: authored, atomically: true, encoding: .utf8)
            let presentation = output.appendingPathComponent(name + "-presentation.swift")
            try lowerGiftUISource(arguments: [
                "--lower-source",
                fixture.appendingPathComponent("Counter.schema.json").path, authored.path,
                output.appendingPathComponent(name + "-schema.swift").path, presentation.path,
            ])
            // Read exact emitter bytes. No formatting, joining or output repair.
            let emitted = try String(contentsOf: presentation, encoding: .utf8)
            let parsed = Parser.parse(source: emitted)
            let diagnostics = ParseDiagnosticsGenerator.diagnostics(for: parsed)
            XCTAssertFalse(parsed.hasError, "\(name): \(diagnostics.map(\.message))")
            XCTAssertTrue(diagnostics.isEmpty, name)
            let nominals = parsed.statements.compactMap { $0.item.as(StructDeclSyntax.self) }
            for (owner, states) in expected {
                let nominal = try XCTUnwrap(nominals.first { $0.name.text == owner })
                let projections = nominal.memberBlock.members.compactMap {
                    $0.decl.as(VariableDeclSyntax.self)
                }
                .flatMap {
                    $0.bindings.compactMap {
                        $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                    }
                }
                .filter { $0.hasPrefix("_giftUIStateStorage_") }
                let keys = nominal.memberBlock.members.compactMap {
                    $0.decl.as(FunctionDeclSyntax.self)?.name.text
                }
                .filter { $0.hasPrefix("_giftUIStateKey_") }
                XCTAssertEqual(
                    projections.sorted(), states.map { "_giftUIStateStorage_" + $0 }.sorted())
                XCTAssertEqual(keys.sorted(), states.map { "_giftUIStateKey_" + $0 }.sorted())
            }
        }
        let archive = repository.appendingPathComponent(
            "Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/checked-state-correction1/evidence.tar.gz"
        )
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
        process.arguments = ["-xOf", archive.path, "attempt/Counter.swift"]
        process.standardOutput = pipe
        try process.run()
        let failingBytes = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        XCTAssertEqual(process.terminationStatus, 0)
        let failing = try XCTUnwrap(String(data: failingBytes, encoding: .utf8))
        try failingBytes.write(
            to: output.appendingPathComponent("frozen-failing-presentation.swift"))
        let rejected = Parser.parse(source: failing)
        let diagnostics = ParseDiagnosticsGenerator.diagnostics(for: rejected)
        XCTAssertTrue(rejected.hasError)
        XCTAssertEqual(
            diagnostics.filter { $0.message.contains("consecutive declarations") }.count, 2)
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
