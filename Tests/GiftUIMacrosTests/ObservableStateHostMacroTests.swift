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

    func testCompleteFiniteZeroStateShapeHasNoStateBackingVisits() {
        let source = serializedSource(names: [])
        assertWitnessSerialization(source, expected: true, hasNoState: true)
    }

    func testOrdinaryZeroStateWitnessesAreNotSerializedAtAnyHostAccess() {
        for access in ["private", "fileprivate", "", "package", "public"] {
            assertWitnessSerialization(
                "@ObservableStateHost \(access) struct Root: View {}",
                expected: false, hasNoState: true)
            assertWitnessSerialization(
                """
                @ObservableStateHost
                \(access) struct Root<D: ReadDomain>: View {
                    typealias Domain = D
                    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
                        throws(_GiftUIAccessFailure) -> EmptyView<D> { EmptyView<D>() }
                }
                """, expected: false, hasNoState: true)
        }
        assertWitnessSerialization(
            checkedSource(
                names: [],
                header:
                    "@ObservableStateHost @usableFromInline package struct Root<D: ReadDomain>: View"
            ), expected: false, hasNoState: true)
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
        for names in [["model"], []] {
            let source = serializedSource(names: names)
            assertWitnessSerialization(source, expected: true, hasNoState: names.isEmpty)
            assertWitnessSerialization(
                "@usableFromInline package struct Outer { \(source) }",
                expected: true, hasNoState: names.isEmpty)
            assertWitnessSerialization(
                "public struct Outer { \(source) }", expected: true, hasNoState: names.isEmpty)
        }
    }

    func testIncompleteABIDependenciesDoNotSelectSerialization() {
        for names in [["model"], []] {
            let source = serializedSource(names: names)
            let replacements = [
                ("@usableFromInline package struct Root", "package struct Root"),
                ("package struct Root", "private struct Root"),
                ("package struct Root", "fileprivate struct Root"),
                ("@usableFromInline package typealias Domain", "package typealias Domain"),
                ("typealias Domain = D", "typealias Domain = Other"),
                ("typealias Domain = D", "typealias Domain<T> = D"),
                ("@inlinable package func _giftUIEvaluate", "package func _giftUIEvaluate"),
                ("package func _giftUIEvaluate", "private func _giftUIEvaluate"),
                ("package func _giftUIEvaluate", "package static func _giftUIEvaluate"),
                ("_giftUIEvaluate(read:", "_giftUIEvaluate<T>(read:"),
                ("read: borrowing", "context: borrowing"),
                ("read: borrowing", "read: consuming"),
                ("_GiftUIFrameRead<D>)", "_GiftUIFrameRead<D>, extra: Int = 0)"),
                (
                    "throws(_GiftUIAccessFailure) -> some",
                    "async throws(_GiftUIAccessFailure) -> some"
                ),
                ("throws(_GiftUIAccessFailure) -> some", "throws(OtherFailure) -> some"),
                ("-> some View<D>", "-> EmptyView<D>"),
                ("-> some View<D> {", "-> some View<D> where D: OtherDomain {"),
            ]
            for (original, replacement) in replacements {
                let variant = replacingExactlyOnce(
                    source, original: original, replacement: replacement)
                assertWitnessSerialization(variant, expected: false, hasNoState: names.isEmpty)
            }
        }
    }

    func testUnsupportedGenericHeadersDoNotSelectSerialization() {
        for names in [["model"], []] {
            let source = serializedSource(names: names)
            for header in [
                "Root<D: ReadDomain, T>", "Root<each D: ReadDomain>", "Root<D>",
                "Root<T: ReadDomain>", "Root<D: Other.ReadDomain>",
                "Root<D: ReadDomain<Other>>", "Root<D: ReadDomain & OtherDomain>",
                "Root<D: ReadDomain> where D: OtherDomain",
            ] {
                let variant = replacingExactlyOnce(
                    source, original: "Root<D: ReadDomain>", replacement: header)
                assertWitnessSerialization(variant, expected: false, hasNoState: names.isEmpty)
            }
        }
    }

    func testUnprovableEnclosingContextsDoNotSelectSerialization() {
        for names in [["model"], []] {
            let source = serializedSource(names: names)
            for prefix in [
                "private struct Outer", "fileprivate struct Outer", "struct Outer",
                "@usableFromInline package struct Outer<T>", "extension Outer",
                "func local()", "let local =", "private struct Root",
            ] {
                assertWitnessSerialization(
                    "\(prefix) { \(source) }", expected: false, hasNoState: names.isEmpty)
            }
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
        func initializers(in node: Syntax) -> [InitializerDeclSyntax] {
            if let initializer = node.as(InitializerDeclSyntax.self) { return [initializer] }
            return node.children(viewMode: .sourceAccurate).flatMap { initializers(in: $0) }
        }
        func tokens(_ node: some SyntaxProtocol) -> [String] {
            node.tokens(viewMode: .sourceAccurate).map(\.text)
        }
        // These isolate annotation eligibility, not semantic acceptance of new
        // initializer syntax. Existing lowering diagnostics remain authoritative.
        let constructorCases: [(String, [Bool])] = [
            ("package struct Root: View { package init() {} }", [true]),
            ("internal struct Root: View { internal init() {} }", [true]),
            ("struct Root: View { init() {} }", [true]),
            ("public struct Root: View { internal init() {} }", [true]),
            ("public struct Root: View { package init() {} }", [true]),
            ("public struct Root: View { public init() {} }", [false]),
            ("private struct Root: View { init() {} }", [false]),
            ("fileprivate struct Root: View { init() {} }", [false]),
            ("struct Root: View { private init() {} }", [false]),
            ("struct Root: View { fileprivate init() {} }", [false]),
            ("struct Root: View { init(_ value: Int) {}; init() {} }", [false, true]),
            ("struct Root: View { init(_ value: Int? = nil) {} }", [false]),
            ("struct Root: View { init?() {} }", [false]),
            ("struct Root: View { init!() {} }", [false]),
            ("struct Root: View { init() throws {} }", [false]),
            ("struct Root: View { init() throws(Failure) {} }", [false]),
            ("struct Root: View { init() async {} }", [false]),
            ("struct Root: View { init<T>() where T: Equatable {} }", [false]),
            ("struct Root<T>: View { init() {} }", [false]),
            ("struct Root: View { @usableFromInline init() {} }", [false]),
            ("struct Root: View { @inlinable init() {} }", [false]),
            ("struct Root: View { @available(*, deprecated) init() {} }", [true]),
            ("struct Root: View { @inline(__always) init() {} }", [false]),
            ("struct Root: View { nonisolated init() {} }", [false]),
            ("struct Root: View { struct Helper { init() {} } }", [false]),
            ("struct Outer { struct Root: View { init() {} } }", [false]),
            ("func local() { struct Root: View { init() {} } }", [false]),
            ("struct Root: View {}; extension Root { init() {} }", [false]),
            ("#if DEBUG\nstruct Root: View { init() {} }\n#endif", [false]),
            (
                "struct Outer: View { struct Leaf { init() {} } }; "
                    + "struct Leaf: View { init() {} }", [false, true]
            ),
        ]
        for (input, expected) in constructorCases {
            let syntax = Parser.parse(source: input)
            XCTAssertFalse(syntax.hasError, input)
            let inventory = Inventory(viewMode: .sourceAccurate)
            inventory.walk(syntax)
            let lowerer = Lowerer(
                configuration: configuration, inventory: inventory, source: syntax,
                file: "constructor-eligibility.swift")
            let before = initializers(in: Syntax(syntax))
            XCTAssertEqual(
                before.map { lowerer.qualifiesOrdinaryViewInitializer($0) }, expected, input)
            let after = initializers(in: lowerer.rewrite(syntax))
            XCTAssertEqual(after.count, before.count, input)
            for (index, initializer) in after.enumerated() {
                let names = initializer.attributes.compactMap {
                    $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription
                }
                let originalNames = before[index].attributes.compactMap {
                    $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription
                }
                XCTAssertEqual(
                    names, originalNames + (expected[index] ? ["usableFromInline"] : []), input)
                var restored = initializer
                restored.attributes = before[index].attributes
                XCTAssertEqual(tokens(restored), tokens(before[index]), input)
            }
        }
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
            let canvas = try XCTUnwrap(
                parsed.statements.compactMap { $0.item.as(StructDeclSyntax.self) }
                    .first { $0.name.text == "CounterCanvas" })
            let canvasConstructor = try XCTUnwrap(
                canvas.memberBlock.members.compactMap { $0.decl.as(InitializerDeclSyntax.self) }
                    .first)
            XCTAssertEqual(
                canvasConstructor.attributes.compactMap {
                    $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription
                }, ["inlinable"], name)
            let nominals = parsed.statements.compactMap { $0.item.as(StructDeclSyntax.self) }
            for (owner, states) in expected {
                let nominal = try XCTUnwrap(nominals.first { $0.name.text == owner })
                let constructors = nominal.memberBlock.members.compactMap {
                    $0.decl.as(InitializerDeclSyntax.self)
                }
                XCTAssertEqual(constructors.count, 1, owner)
                for constructor in constructors {
                    XCTAssertEqual(
                        constructor.attributes.compactMap {
                            $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription
                        }, ["usableFromInline"], owner)
                    var ordinary = constructor
                    ordinary.attributes = []
                    XCTAssertEqual(
                        tokens(ordinary), tokens(DeclSyntax(stringLiteral: "package init() {}")),
                        owner)
                }
                let privateState = nominal.memberBlock.members.compactMap {
                    $0.decl.as(VariableDeclSyntax.self)
                }.filter { variable in
                    variable.attributes.contains {
                        $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?
                            .name.text == "State"
                    }
                }
                XCTAssertEqual(privateState.count, states.count, owner)
                XCTAssertTrue(
                    privateState.allSatisfy {
                        $0.modifiers.map(\.name.text) == ["private"]
                            && !$0.attributes.contains {
                                $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription
                                    == "usableFromInline"
                            }
                    }, owner)
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

    private func checkedSource(
        names: [String], extra: String = "",
        header: String = "@ObservableStateHost struct Root: View"
    ) -> String {
        let fields = names.map {
            "@State<Schema>(seed: Seed()) private var \($0): _GiftUIModelKey<Schema>?"
        }
        let helpers = names.flatMap {
            ObservableStateHostMacro.checkedStateHelpers(name: $0, schema: "Schema")
        }
        .map(\.description)
        return header + " {\n"
            + (fields + helpers + [extra]).joined(separator: "\n") + "\n}"
    }

    private func serializedSource(names: [String] = ["model"]) -> String {
        checkedSource(
            names: names,
            extra: """
                @usableFromInline package typealias Domain = D
                @inlinable package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
                    throws(_GiftUIAccessFailure) -> some View<D> { EmptyView<D>() }
                """,
            header: "@ObservableStateHost @usableFromInline package struct Root<D: ReadDomain>: View")
    }

    private func replacingExactlyOnce(
        _ source: String, original: String, replacement: String,
        file: StaticString = #filePath, line: UInt = #line
    ) -> String {
        XCTAssertEqual(source.components(separatedBy: original).count, 2, original, file: file, line: line)
        let variant = source.replacingOccurrences(of: original, with: replacement)
        XCTAssertNotEqual(
            Parser.parse(source: source).tokens(viewMode: .sourceAccurate).map(\.text),
            Parser.parse(source: variant).tokens(viewMode: .sourceAccurate).map(\.text),
            original, file: file, line: line)
        return variant
    }

    private func assertNoStateBacking(
        _ source: String, file: StaticString = #filePath, line: UInt = #line
    ) {
        let tokens = Parser.parse(source: source).tokens(viewMode: .sourceAccurate).map(\.text)
        XCTAssertFalse(
            tokens.contains {
                $0 == "State" || $0 == "_model" || $0.hasPrefix("_giftUIStateStorage_")
                    || $0.hasPrefix("_giftUIStateKey_")
            }, source, file: file, line: line)
    }

    private func assertWitnessSerialization(
        _ source: String, expected: Bool, hasNoState: Bool = false,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        let (expanded, diagnostics) = expandChecked(source)
        XCTAssertTrue(diagnostics.isEmpty, "\(diagnostics): \(source)", file: file, line: line)
        if hasNoState {
            assertNoStateBacking(source, file: file, line: line)
            assertNoStateBacking(expanded, file: file, line: line)
            XCTAssertFalse(expanded.contains("visitor.visit("), expanded, file: file, line: line)
        }
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
