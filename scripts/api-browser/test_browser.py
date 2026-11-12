#!/usr/bin/env python3
"""Behavior checks for source visibility, extraction, refresh, and HTTP routing."""

import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location("api_browser", Path(__file__).resolve().parents[1] / "api-browser.py")
browser = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(browser)


def flatten(symbols):
    return [item for symbol in symbols for item in [symbol, *flatten(symbol["members"])]]


class ExtractionTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.extractor = browser.prepare_extractor()

    def extract(self, files):
        with tempfile.TemporaryDirectory(prefix="giftui-api-test-") as temporary:
            root = Path(temporary)
            for name, source in files.items():
                file = root / "Sources" / "Sample" / name
                file.parent.mkdir(parents=True, exist_ok=True)
                file.write_text(source)
            return json.loads(subprocess.check_output([str(self.extractor), str(root)], text=True))[0]

    def test_visibility_respects_enclosing_types_protocol_requirements_and_enum_cases(self):
        module = self.extract({"Types.swift": """
            public protocol Contract {
                associatedtype Value
                var value: Value { get }
                func run()
            }
            public enum Choice { case first, second(Int) }
            public struct Visible {
                public private(set) var count: Int = 0
                private var secret: String
                var internalOnly: Int
                package func packageMember() {}
                public struct Nested { public func nestedAPI() {} }
            }
            internal struct Hidden { public func hiddenAPI() {} }
            package struct PackageType { public func effectivePackageAPI() {} }
            @_spi(Testing) public struct SPIType {}
            """})
        symbols = flatten(module["symbols"])
        names = {s["name"] for s in symbols}
        self.assertTrue({"Contract", "Value", "value", "run", "first, second", "Nested", "nestedAPI"} <= names)
        self.assertTrue({"Hidden", "hiddenAPI", "secret", "internalOnly", "SPIType"}.isdisjoint(names))
        by_name = {s["name"]: s for s in symbols}
        self.assertEqual(by_name["packageMember"]["access"], "package")
        self.assertEqual(by_name["effectivePackageAPI"]["access"], "package")
        self.assertIn("private(set)", by_name["count"]["signature"])

    def test_extensions_resolve_visibility_across_files_and_keep_constraints(self):
        module = self.extract({
            "A.swift": """
                extension Hidden { public func leak() {} }
                public extension Box where Value: Equatable {
                    func compare(_ other: Value) -> Bool { false }
                    private func helper() {}
                }
                """,
            "B.swift": "internal struct Hidden {}\npublic struct Box<Value> {}",
        })
        names = {s["name"] for s in flatten(module["symbols"])}
        self.assertIn("compare", names)
        self.assertTrue({"leak", "helper"}.isdisjoint(names))
        extension = next(s for s in module["symbols"] if s["kind"] == "extension")
        self.assertIn("where Value: Equatable", extension["signature"])

    def test_signatures_strip_implementations_and_keep_defaults_docs_and_conditional_branches(self):
        module = self.extract({"Surface.swift": '''
            /// A documented surface with <script>ordinary text</script>.
            public struct Surface {
                public func transform<T>(
                    _ value: T, label: String = "{default}"
                ) async throws -> T where T: Sendable {
                    func localImplementation() {}
                    return value
                }
                public var title: String { get { "implementationSecret" } set {} }
                public subscript(index: Int) -> String { "subscriptSecret" }
            }
            #if os(Linux)
            public typealias PlatformValue = Int
            #elseif DEBUG
            public typealias PlatformValue = String
            #else
            public typealias PlatformValue = Bool
            #endif
            '''})
        self.assertFalse(module["warnings"])
        symbols = flatten(module["symbols"])
        text = json.dumps(symbols)
        for hidden in ["localImplementation", "implementationSecret", "subscriptSecret", "return value"]:
            self.assertNotIn(hidden, text)
        method = next(s for s in symbols if s["name"] == "transform")
        self.assertIn('label: String = "{default}"', method["signature"])
        self.assertIn("async throws -> T where T: Sendable", method["signature"])
        self.assertIn("<script>", symbols[0]["documentation"])
        aliases = [s for s in symbols if s["name"] == "PlatformValue"]
        self.assertEqual(len(aliases), 3)
        self.assertEqual(aliases[0]["conditions"], ["os(Linux)"])
        self.assertEqual(aliases[2]["conditions"], ["!(os(Linux)) && !(DEBUG)"])

    def test_parser_recovery_is_reported(self):
        module = self.extract({"Broken.swift": "public struct Broken { public func broken("})
        self.assertTrue(module["warnings"])

    def test_manifest_exclusions_do_not_appear_in_the_module_interface(self):
        with tempfile.TemporaryDirectory(prefix="giftui-api-exclusions-") as temporary:
            root = Path(temporary)
            source = root / "Sources" / "Sample"
            source.mkdir(parents=True)
            (source / "Included.swift").write_text("public struct Included {}")
            (source / "Excluded.swift").write_text("public struct Excluded {}")
            (root / "Package.swift").write_text('let target = .target(name: "Sample", exclude: ["Excluded.swift"])')
            modules = json.loads(subprocess.check_output([str(self.extractor), str(root)], text=True))
            self.assertEqual([s["name"] for s in modules[0]["symbols"]], ["Included"])

    def test_refresh_reads_edits_and_removed_files(self):
        with tempfile.TemporaryDirectory(prefix="giftui-api-refresh-") as temporary:
            root = Path(temporary)
            source = root / "Sources" / "Sample" / "API.swift"
            source.parent.mkdir(parents=True)
            source.write_text("public struct Before {}")
            with patch.object(browser, "ROOT", root):
                interfaces = browser.Interfaces(self.extractor)
                self.assertEqual(interfaces.load()["Sample"]["symbols"][0]["name"], "Before")
                source.write_text("public struct After {}")
                self.assertEqual(interfaces.load()["Sample"]["symbols"][0]["name"], "After")
                source.unlink()
                self.assertEqual(interfaces.load()["Sample"]["symbols"], [])


class RoutingTests(unittest.TestCase):
    def request(self, path):
        class Interfaces:
            def load(self):
                return {"Sample": {"name": "Sample", "files": 1, "symbols": []}}

        handler = object.__new__(browser.handler_for(Interfaces()))
        handler.path = path
        responses = []
        handler.respond = lambda *args: responses.append(args)
        handler.do_GET()
        return responses[0]

    def test_only_explicit_assets_and_api_routes_are_served(self):
        self.assertEqual(self.request("/")[0], 200)
        self.assertEqual(self.request("/app.js")[2], "text/javascript")
        self.assertEqual(self.request("/api/modules/Sample")[0], 200)
        for path in ["/api/modules/Unknown", "/../../Package.swift", "/%2e%2e/Package.swift", "/.git/config"]:
            self.assertEqual(self.request(path)[0], 404)


if __name__ == "__main__":
    unittest.main()
