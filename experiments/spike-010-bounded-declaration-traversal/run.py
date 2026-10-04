"""Disposable actual-body snapshot lowering; stop at real compiler restrictions."""
from pathlib import Path
import hashlib
import json
import os
import re
import shlex
import shutil
import subprocess

root = Path.cwd()
spike = root / "experiments/spike-010-bounded-declaration-traversal"
out = root / ".build/nrf52840/spike-010-bounded-declaration-traversal"
out.mkdir(parents=True, exist_ok=True)
evidence = spike / "evidence"
evidence.mkdir(exist_ok=True)
record = {"revision": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(), "inputs": {}}

def read(path):
    record["inputs"][str(path.relative_to(root))] = hashlib.sha256(path.read_bytes()).hexdigest()
    return path.read_text()

presentation = root / "Sources/SignalAnalyzerPresentation"
view = read(presentation / "SignalAnalyzerView.swift")
assert view.count("@ObservableStateHost") == 1
assert view.count("@State private var viewModel") == 1
view = view.replace("@ObservableStateHost\n", "").replace("@State private var viewModel", "private var viewModel")
view = view.replace("_viewModel = State(wrappedValue: viewModel)", "self.viewModel = viewModel")
values = read(presentation / "SignalAnalyzerPresentationValues.swift").split("package enum SignalAnalyzerPresentationFact:")[0]
source = "\n".join([read(spike / "Support.swift"), values,
    read(presentation / "SignalAnalyzerDiagnostic+BoundedText.swift"),
    read(presentation / "SignalAnalyzerWaveformGeometry.swift"), view])
candidate = out / "LoweredBody.swift"
candidate.write_text(source)
record["lowered_source_sha256"] = hashlib.sha256(source.encode()).hexdigest()
read(spike / "NativeMain.swift")
read(spike / "run.py")
owners = root / ".build/contract-generated/spec-001/nrf-native-owners"
objects = (owners / "owner-objects.txt").read_text().splitlines()
record["native_owner_objects"] = {str(Path(p).relative_to(root)): hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in objects}
native = ["swiftc", "-I", str(owners / "modules"), "-parse-as-library", "-Osize", "-package-name", "GiftUI",
          "-DGIFTUI_NRF_EMBEDDED", "-DGIFTUI_REFERENCE_BITMAP_ONLY", str(candidate), str(spike / "NativeMain.swift"),
          *objects, "-o", str(out / "native")]
environment = dict(os.environ, CLANG_MODULE_CACHE_PATH=str(out / "native-cache"))
compiled = subprocess.run(native, capture_output=True, text=True, env=environment)
record["native_compile"] = {"command": native, "exit_code": compiled.returncode, "diagnostics": compiled.stdout + compiled.stderr}
if compiled.returncode == 0:
    ran = subprocess.run([str(out / "native")], capture_output=True, text=True)
    record["native_run"] = {"exit_code": ran.returncode, "output": ran.stdout + ran.stderr}

cache = root / ".build/nrf52840/signal-analyzer-static/CMakeCache.txt"
cmake = dict(re.findall(r"^([^#/:]+):[^=]+=(.*)$", cache.read_text(), re.M))
commands = subprocess.check_output([cmake["CMAKE_MAKE_PROGRAM"], "-C", str(cache.parent), "-t", "commands"], text=True)
command = shlex.split(next(line for line in commands.splitlines() if line.endswith("/SignalAnalyzerStatic.swift")))
for option in ("-output-file-map", "-emit-module-path"):
    index = command.index(option)
    del command[index:index + 2]
command = command[:-1] + ["-emit-module-path", str(out / "SignalAnalyzerTargetHost.swiftmodule"),
                         "-o", str(out / "LoweredBody.o"), str(candidate),
                         "-module-cache-path", str(out / "clang-cache"), "-Xllvm", "-stack-size-section"]
compiled = subprocess.run(command, capture_output=True, text=True,
                          env=dict(os.environ, CLANG_MODULE_CACHE_PATH=str(out / "clang-cache")))
record["embedded_compile"] = {"command": command, "exit_code": compiled.returncode,
                              "diagnostics": compiled.stdout + compiled.stderr}
record["paired_compiler"] = subprocess.check_output([command[0], "--version"], text=True)
if compiled.returncode == 0:
    record["embedded_object_sha256"] = hashlib.sha256((out / "LoweredBody.o").read_bytes()).hexdigest()
    app = root / "firmware/nrf52840/applications/signal-analyzer-static"
    copied = out / "application"
    shutil.copytree(app, copied, dirs_exist_ok=True)
    cmake = read(app / "CMakeLists.txt").replace('${CMAKE_CURRENT_SOURCE_DIR}/../../../..', str(root))
    cmake = cmake.replace('    "${CMAKE_CURRENT_SOURCE_DIR}/src/StaticPreset.swift"',
                          f'    "{candidate}"\n    "${{CMAKE_CURRENT_SOURCE_DIR}}/src/StaticPreset.swift"')
    (copied / "CMakeLists.txt").write_text(cmake)
    main = read(app / "src/main.c")
    main = main.replace("int main(void)", "extern uint32_t giftui_spike010_derive(uint32_t, uint32_t, uint32_t, uint32_t, uint16_t, uint16_t);\n\nint main(void)")
    main = main.replace("    struct giftui_static_host_storage regions;", "    if (giftui_spike010_derive(0, 1, 0, 0, 64, 512) != 92u) { return 1; }\n    struct giftui_static_host_storage regions;")
    (copied / "src/main.c").write_text(main)
(evidence / "result.json").write_text(json.dumps(record, indent=2) + "\n")
print(json.dumps({key: value for key, value in record.items() if key in ("native_compile", "native_run", "embedded_compile")}, indent=2))
assert record["native_compile"]["exit_code"] == 0 and record["native_run"]["exit_code"] == 0
assert record["embedded_compile"]["exit_code"] == 0
