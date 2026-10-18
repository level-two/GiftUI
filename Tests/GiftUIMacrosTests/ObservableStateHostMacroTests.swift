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

    func testOrdinaryPrivateStateWitnessesAreNotSerializedAtAnyHostAccess() {
        for access in ["private", "fileprivate", "", "package", "public"] {
            let source = """
                @ObservableStateHost
                \(access) struct Root<D: ReadDomain>: View {
                    typealias Domain = D
                    @State<Schema>(seed: Seed()) private var model: _GiftUIModelKey<Schema>?
                    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
                        throws(_GiftUIAccessFailure) -> EmptyView<D> { EmptyView<D>() }
                }
                """
            assertWitnessSerialization(source, expected: false)
            let (expanded, _) = expandChecked(source)
            XCTAssertTrue(expanded.contains("visitor.visit(&_model, declarationOrdinal: 0)"))
        }
        let source = """
            @ObservableStateHost
            @usableFromInline package struct Root<D: ReadDomain>: View {
                @usableFromInline package typealias Domain = D
                @State<Schema>(seed: Seed()) private var model: _GiftUIModelKey<Schema>?
                package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
                    throws(_GiftUIAccessFailure) -> EmptyView<D> { EmptyView<D>() }
            }
            """
        assertWitnessSerialization(source, expected: false)
        assertWitnessSerialization("private struct Outer { \(source) }", expected: false)
    }

    func testCompleteFiniteShapeSelectsSerializedWitnesses() {
        let source = serializedSource()
        assertWitnessSerialization(source, expected: true)
        assertWitnessSerialization(
            "@usableFromInline package struct Outer { \(source) }", expected: true)
        assertWitnessSerialization("public struct Outer { \(source) }", expected: true)
    }

    func testIncompleteABIDependenciesDoNotSelectSerialization() {
        let source = serializedSource()
        let variants = [
            source.replacingOccurrences(
                of: "@usableFromInline package struct Root", with: "package struct Root"),
            source.replacingOccurrences(
                of: "package struct Root", with: "private struct Root"),
            source.replacingOccurrences(
                of: "package struct Root", with: "fileprivate struct Root"),
            source.replacingOccurrences(
                of: "@usableFromInline package typealias Domain", with: "package typealias Domain"),
            source.replacingOccurrences(
                of: "typealias Domain = D", with: "typealias Domain = Other"),
            source.replacingOccurrences(
                of: "typealias Domain = D", with: "typealias Domain<T> = D"),
            source.replacingOccurrences(
                of: "@inlinable package func _giftUIEvaluate", with: "package func _giftUIEvaluate"),
            source.replacingOccurrences(
                of: "package func _giftUIEvaluate", with: "private func _giftUIEvaluate"),
            source.replacingOccurrences(
                of: "package func _giftUIEvaluate", with: "package static func _giftUIEvaluate"),
            source.replacingOccurrences(
                of: "_giftUIEvaluate(read:", with: "_giftUIEvaluate<T>(read:"),
            source.replacingOccurrences(of: "read: borrowing", with: "context: borrowing"),
            source.replacingOccurrences(of: "read: borrowing", with: "read: consuming"),
            source.replacingOccurrences(
                of: "_GiftUIFrameRead<D>)", with: "_GiftUIFrameRead<D>, extra: Int = 0)"),
            source.replacingOccurrences(
                of: "throws(_GiftUIAccessFailure) -> some",
                with: "async throws(_GiftUIAccessFailure) -> some"),
            source.replacingOccurrences(
                of: "throws(_GiftUIAccessFailure) -> some", with: "throws(OtherFailure) -> some"),
            source.replacingOccurrences(of: "-> some View<D>", with: "-> EmptyView<D>"),
            source.replacingOccurrences(
                of: "-> some View<D> {", with: "-> some View<D> where D: OtherDomain {"),
        ]
        for variant in variants {
            XCTAssertNotEqual(variant, source)
            assertWitnessSerialization(variant, expected: false)
        }
    }

    func testUnsupportedGenericHeadersDoNotSelectSerialization() {
        let source = serializedSource()
        for header in [
            "Root<D: ReadDomain, T>", "Root<each D: ReadDomain>", "Root<D>",
            "Root<T: ReadDomain>", "Root<D: Other.ReadDomain>",
            "Root<D: ReadDomain<Other>>", "Root<D: ReadDomain & OtherDomain>",
            "Root<D: ReadDomain> where D: OtherDomain",
        ] {
            let variant = source.replacingOccurrences(of: "Root<D: ReadDomain>", with: header)
            XCTAssertNotEqual(variant, source)
            assertWitnessSerialization(variant, expected: false)
        }
    }

    func testUnprovableEnclosingContextsDoNotSelectSerialization() {
        let source = serializedSource()
        for prefix in [
            "private struct Outer", "fileprivate struct Outer", "struct Outer",
            "@usableFromInline package struct Outer<T>", "extension Outer",
            "func local()", "let local =", "private struct Root",
        ] {
            assertWitnessSerialization("\(prefix) { \(source) }", expected: false)
        }
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
        let configuration = try JSONDecoder().decode(
            Configuration.self,
            from: Data(contentsOf: fixture.appendingPathComponent("Counter.schema.json")))
        let tableInventory = Inventory(viewMode: .sourceAccurate)
        XCTAssertThrowsError(
            try canvasWitnessTable(
                configuration: configuration, inventory: tableInventory,
                presentationModule: "P08CounterPresentation"))
        tableInventory.canvases = ["CounterCanvas"]
        XCTAssertThrowsError(
            try canvasWitnessTable(
                configuration: configuration, inventory: tableInventory,
                presentationModule: "invalid-module"))
        tableInventory.canvases = Set((0 ... Int(UInt16.max)).map { "Canvas\($0)" })
        XCTAssertThrowsError(
            try canvasWitnessTable(
                configuration: configuration, inventory: tableInventory,
                presentationModule: "P08CounterPresentation"))
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
            let table = output.appendingPathComponent(name + "-table.swift")
            try lowerGiftUISource(arguments: [
                "--lower-source",
                fixture.appendingPathComponent("Counter.schema.json").path, authored.path,
                output.appendingPathComponent(name + "-schema.swift").path, presentation.path,
                table.path, "P08CounterPresentation",
            ])
            let tableBytes = try String(contentsOf: table, encoding: .utf8)
            let tableSyntax = Parser.parse(source: tableBytes)
            XCTAssertFalse(tableSyntax.hasError, name)
            XCTAssertTrue(ParseDiagnosticsGenerator.diagnostics(for: tableSyntax).isEmpty, name)
            let values = try XCTUnwrap(
                tableSyntax.statements.compactMap {
                    $0.item.as(EnumDeclSyntax.self)
                }.first { $0.name.text == configuration.module + "CanvasValues" })
            XCTAssertTrue(
                values.attributes.contains {
                    $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription
                        == "usableFromInline"
                }, name)
            let tableType = try XCTUnwrap(
                tableSyntax.statements.compactMap {
                    $0.item.as(StructDeclSyntax.self)
                }.first { $0.name.text == configuration.module + "CanvasTable" })
            XCTAssertTrue(
                tableType.attributes.contains {
                    $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription
                        == "usableFromInline"
                }, name)
            let aliases = tableType.memberBlock.members.compactMap {
                $0.decl.as(TypeAliasDeclSyntax.self)
            }
            XCTAssertEqual(aliases.map(\.name.text).sorted(), ["CaptureStorage", "Domain"])
            XCTAssertTrue(
                aliases.allSatisfy { alias in
                    alias.attributes.contains {
                        $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription
                            == "usableFromInline"
                    }
                }, name)
            let functions = tableType.memberBlock.members.compactMap {
                $0.decl.as(FunctionDeclSyntax.self)
            }
            XCTAssertEqual(
                functions.map(\.name.text).sorted(),
                ["captureByteCount", "caseID", "invoke", "payload"])
            XCTAssertTrue(
                functions.allSatisfy { function in
                    function.attributes.contains {
                        $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "inlinable"
                    }
                }, name)
            let initializer = try XCTUnwrap(
                tableType.memberBlock.members.compactMap {
                    $0.decl.as(InitializerDeclSyntax.self)
                }.first)
            XCTAssertTrue(
                initializer.attributes.contains {
                    $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "inlinable"
                }, name)
            let count = try XCTUnwrap(
                tableType.memberBlock.members.compactMap {
                    $0.decl.as(VariableDeclSyntax.self)
                }.first { $0.bindings.first?.pattern.trimmedDescription == "callableCaseCount" })
            XCTAssertTrue(
                count.attributes.contains {
                    $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "inlinable"
                }, name)
            XCTAssertTrue(tableBytes.contains("borrowing CaptureStorage"), name)
            XCTAssertTrue(tableBytes.contains("read: borrowing _GiftUIFrameRead<D>"), name)
            // Read exact emitter bytes. No formatting, joining or output repair.
            let emitted = try String(contentsOf: presentation, encoding: .utf8)
            let parsed = Parser.parse(source: emitted)
            let diagnostics = ParseDiagnosticsGenerator.diagnostics(for: parsed)
            XCTAssertFalse(parsed.hasError, "\(name): \(diagnostics.map(\.message))")
            XCTAssertTrue(diagnostics.isEmpty, name)
            let (expanded, expansionDiagnostics) = expandChecked(emitted)
            XCTAssertTrue(expansionDiagnostics.isEmpty, name)
            try expanded.write(
                to: output.appendingPathComponent(name + "-expanded.swift"), atomically: true,
                encoding: .utf8)
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
                let expandedNominal = try XCTUnwrap(
                    Parser.parse(source: expanded).statements.compactMap {
                        $0.item.as(StructDeclSyntax.self)
                    }.first { $0.name.text == owner })
                assertSerializedWitnesses(in: Syntax(expandedNominal), expected: true)
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

    private func serializedSource() -> String {
        checkedSource(
            names: ["model"],
            extra: """
                @usableFromInline package typealias Domain = D
                @inlinable package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
                    throws(_GiftUIAccessFailure) -> some View<D> { EmptyView<D>() }
                """
        ).replacingOccurrences(
            of: "@ObservableStateHost struct Root: View",
            with: "@ObservableStateHost @usableFromInline package struct Root<D: ReadDomain>: View")
    }

    private func assertWitnessSerialization(
        _ source: String, expected: Bool, file: StaticString = #filePath, line: UInt = #line
    ) {
        let (expanded, diagnostics) = expandChecked(source)
        XCTAssertTrue(diagnostics.isEmpty, "\(diagnostics): \(source)", file: file, line: line)
        assertSerializedWitnesses(
            in: Syntax(Parser.parse(source: expanded)), expected: expected, file: file, line: line)
    }

    private func assertSerializedWitnesses(
        in source: Syntax, expected: Bool, file: StaticString = #filePath, line: UInt = #line
    ) {
        func witnesses(_ node: Syntax) -> [FunctionDeclSyntax] {
            if let function = node.as(FunctionDeclSyntax.self),
                ["_giftUIVisitObservableStateDeclarations", "_giftUITraverse"].contains(
                    function.name.text)
            {
                return [function]
            }
            return node.children(viewMode: .sourceAccurate).flatMap { witnesses($0) }
        }
        let functions = witnesses(source)
        XCTAssertEqual(functions.count, 2, source.description, file: file, line: line)
        for function in functions {
            let attributes = function.attributes.compactMap { $0.as(AttributeSyntax.self) }
            XCTAssertEqual(
                attributes.contains { $0.attributeName.trimmedDescription == "inlinable" },
                expected,
                function.description, file: file, line: line)
            XCTAssertEqual(
                attributes.contains { $0.attributeName.trimmedDescription == "inline" }, expected,
                function.description, file: file, line: line)
        }
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
