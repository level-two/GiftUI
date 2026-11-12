#!/usr/bin/env python3
"""Serve a local, source-based public Swift interface browser (no package build)."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import unquote, urlsplit
import webbrowser

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "scripts" / "api-browser"
BUILD = ROOT / ".build" / "api-browser"


def run(command):
    return subprocess.run(command, cwd=ROOT, check=True, capture_output=True, text=True, timeout=180)


def prepare_extractor():
    swift = os.environ.get("GIFTUI_SWIFT_EXECUTABLE", "swift")
    executable = shutil.which(swift)
    if not executable:
        raise RuntimeError("Swift is required. Select an installed toolchain or set GIFTUI_SWIFT_EXECUTABLE.")
    info = json.loads(run([executable, "-print-target-info"]).stdout)
    host = Path(info["paths"]["runtimeResourcePath"]) / "host"
    compiler = host.parent.parent.parent / "bin" / "swiftc"
    if not compiler.is_file() or not (host / "SwiftParser.swiftmodule").exists():
        raise RuntimeError(f"This toolchain does not bundle SwiftParser/SwiftSyntax at {host}.")
    BUILD.mkdir(parents=True, exist_ok=True)
    source = ASSETS / "ExtractInterfaces.swift"
    fingerprint = hashlib.sha256(source.read_bytes() + str(host).encode() + info["compilerVersion"].encode()).hexdigest()
    binary = BUILD / "extract-interfaces"
    stamp = BUILD / "extractor.sha256"
    if not binary.exists() or not stamp.exists() or stamp.read_text() != fingerprint:
        print("Preparing Swift interface reader…", flush=True)
        temporary = BUILD / f"extract-interfaces-{os.getpid()}"
        try:
            run([str(compiler), str(source), "-swift-version", "6", "-I", str(host), "-L", str(host),
                 "-lSwiftParser", "-lSwiftSyntax", "-Xlinker", "-rpath", "-Xlinker", str(host),
                 "-module-cache-path", str(BUILD / "module-cache"), "-o", str(temporary)])
            temporary.replace(binary)
            stamp.write_text(fingerprint)
        finally:
            temporary.unlink(missing_ok=True)
    return binary


def count_symbols(symbols, include_package=True):
    return sum(1 + count_symbols(symbol["members"], include_package) for symbol in symbols
               if include_package or symbol["access"] == "public")


class Interfaces:
    def __init__(self, extractor):
        self.extractor = extractor
        self.lock = threading.Lock()
        self.fingerprint = None
        self.modules = {}

    def load(self):
        with self.lock:
            fingerprint = tuple((str(p), p.stat().st_mtime_ns, p.stat().st_size)
                                for p in sorted([*(ROOT / "Sources").rglob("*.swift"),
                                                 *ROOT.glob("Package.swift")]))
            if fingerprint != self.fingerprint:
                modules = json.loads(run([str(self.extractor), str(ROOT)]).stdout)
                self.modules = {m["name"]: m for m in modules}
                self.fingerprint = fingerprint
            return self.modules


def handler_for(interfaces):
    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            path = unquote(urlsplit(self.path).path)
            assets = {"/": ("index.html", "text/html"), "/app.js": ("app.js", "text/javascript"),
                      "/style.css": ("style.css", "text/css")}
            try:
                if path in assets:
                    filename, content_type = assets[path]
                    self.respond(200, (ASSETS / filename).read_bytes(), content_type)
                elif path == "/api/modules":
                    modules = interfaces.load()
                    self.respond_json(200, [{"name": m["name"], "files": m["files"],
                                             "count": count_symbols(m["symbols"], False),
                                             "packageCount": count_symbols(m["symbols"])} for m in modules.values()])
                elif path.startswith("/api/modules/"):
                    module = interfaces.load().get(path.removeprefix("/api/modules/"))
                    self.respond_json(200 if module else 404, module or {"error": "Module not found"})
                elif path == "/favicon.ico":
                    self.respond(204, b"", "image/x-icon")
                else:
                    self.respond_json(404, {"error": "Not found"})
            except (OSError, ValueError, subprocess.SubprocessError, RuntimeError) as error:
                print(f"Interface request failed: {error}", file=sys.stderr)
                self.respond_json(500, {"error": "Could not refresh interfaces. See the server terminal for details."})

        def respond_json(self, status, value):
            self.respond(status, json.dumps(value).encode(), "application/json")

        def respond(self, status, data, content_type):
            self.send_response(status)
            self.send_header("Content-Type", content_type + "; charset=utf-8")
            self.send_header("Content-Length", str(len(data)))
            self.send_header("Cache-Control", "no-store")
            self.send_header("X-Content-Type-Options", "nosniff")
            self.send_header("Content-Security-Policy", "default-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'; frame-ancestors 'none'")
            self.end_headers()
            self.wfile.write(data)

        def log_message(self, format, *args):
            if args and str(args[1]) not in {"200", "304"}:
                super().log_message(format, *args)

    return Handler


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8765, help="Local port (default: 8765; 0 chooses an available port)")
    parser.add_argument("--open", action="store_true", help="Open the browser when ready")
    parser.add_argument("--check", action="store_true", help="Extract interfaces and report counts without starting a server")
    args = parser.parse_args()
    if not 0 <= args.port <= 65535:
        parser.error("--port must be between 0 and 65535")
    try:
        interfaces = Interfaces(prepare_extractor())
        modules = interfaces.load()
        print(f"Read {len(modules)} modules · {sum(count_symbols(m['symbols']) for m in modules.values())} public/package declarations", flush=True)
        for module in modules.values():
            for warning in module["warnings"]:
                print(f"warning: {warning}", file=sys.stderr)
        if args.check:
            return 0
        with ThreadingHTTPServer(("127.0.0.1", args.port), handler_for(interfaces)) as server:
            url = f"http://127.0.0.1:{server.server_port}"
            print(f"GiftUI interfaces: {url}\nPress Ctrl+C to stop. Refresh the page to read source changes.", flush=True)
            if args.open:
                webbrowser.open(url)
            try:
                server.serve_forever()
            except KeyboardInterrupt:
                print("\nStopped.")
        return 0
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"error: {error}", file=sys.stderr)
        if isinstance(error, subprocess.CalledProcessError):
            print(error.stderr, file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
