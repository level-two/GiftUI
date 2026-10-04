#!/usr/bin/env python3
"""Reproduce the ITERATION-002 lexical inventory; not a semantic Swift check.

Run from the repository root with a fresh `swift package dump-package` JSON:
python3 docs/iterations/iteration-002-review/inventory.py /path/package.json
"""

import csv
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path.cwd()
OUTPUT = ROOT / "docs/iterations/iteration-002-review/evidence"
OUTPUT.mkdir(parents=True, exist_ok=True)
package = json.loads(Path(sys.argv[1]).read_text())
tracked = subprocess.check_output(["git", "ls-files"], text=True).splitlines()


def write_tsv(name, header, rows):
    with (OUTPUT / name).open("w", newline="") as handle:
        writer = csv.writer(handle, delimiter="\t", lineterminator="\n")
        writer.writerow(header)
        writer.writerows([["-" if value == "" else value for value in row] for row in rows])


targets = {target["name"]: target for target in package["targets"]}
edges = []
module_rows = []
source_rows = []
all_imports = {}
for name, target in sorted(targets.items()):
    for dependency in target.get("dependencies", []):
        kind = next(key for key in ("byName", "target", "product") if key in dependency)
        value = dependency[kind]
        dependency_name = value[0] if isinstance(value, list) else value
        edges.append([name, dependency_name, "external" if kind == "product" else "internal"])
    directory = target.get("path") or ("Tests/" if target["type"] == "test" else "Sources/") + name
    paths = sorted(path for path in tracked if path.startswith(directory + "/") and path.endswith(".swift"))
    total_lines = generated = guards = public = package_visible = 0
    imports = set()
    for path in paths:
        content = (ROOT / path).read_text()
        lines = len(content.splitlines())
        is_generated = "Generated/" in path or ".generated." in path or "DO NOT EDIT" in content[:1500].upper()
        file_imports = set(re.findall(r"^\s*(?:(?:public|internal|package|private|fileprivate)\s+)?(?:@\w+(?:\([^\n]*?\))?\s+)*import\s+(?:struct\s+|class\s+|func\s+|enum\s+|protocol\s+|var\s+|let\s+)?([A-Za-z0-9_]+)", content, re.M))
        file_guards = len(re.findall(r"^\s*#if\b", content, re.M))
        total_lines += lines
        generated += int(is_generated)
        guards += file_guards
        public += len(re.findall(r"^\s*public\b", content, re.M))
        package_visible += len(re.findall(r"^\s*package\b", content, re.M))
        imports.update(file_imports)
        source_rows.append([path, name, lines, int(is_generated), file_guards, ",".join(sorted(file_imports)), hashlib.sha256(content.encode()).hexdigest()])
    all_imports[name] = imports
    module_rows.append([name, target["type"], directory, len(paths), total_lines, generated, guards, public, package_visible, ",".join(sorted(imports))])

write_tsv("modules.tsv", ["module", "type", "path", "swift_files", "lines", "generated_files", "opening_if", "public_lines", "package_lines", "imports"], module_rows)
write_tsv("sources.tsv", ["path", "module", "lines", "generated", "opening_if", "imports", "sha256"], source_rows)
write_tsv("target-dependencies.tsv", ["consumer", "dependency", "kind"], sorted(edges))

cmake_path = "firmware/nrf52840/applications/signal-analyzer-static/CMakeLists.txt"
cmake = (ROOT / cmake_path).read_text()
nrf_sources = sorted(set(re.findall(r'\$\{giftui_project_root\}/(Sources/[^"\n]+\.swift)', cmake)))
# Two selected resource paths are referenced through CMake variables.
for variable in ("giftui_reference_bitmap", "giftui_reference_catalogue"):
    match = re.search(r"set\(" + variable + r'\s+"\$\{giftui_project_root\}/([^"\n]+)"\)', cmake)
    if match:
        nrf_sources.append(match[1])
nrf_sources = sorted(set(nrf_sources))
write_tsv("nrf-selected-sources.tsv", ["owner", "source", "exists", "imports"], [[path.split("/")[1], path, int((ROOT / path).exists()), ",".join(sorted(set(re.findall(r"^import ([A-Za-z0-9_]+)$", (ROOT / path).read_text(), re.M))))] for path in nrf_sources])

portfolio = []
for path in sorted((ROOT / "docs/specs").glob("spec-*.md")):
    content = path.read_text()
    spec_id = re.search(r"^id: (SPEC-\d+)$", content, re.M).group(1)
    status = re.search(r"^status: (\S+)$", content, re.M).group(1)
    acceptance = content.split("## Acceptance Criteria", 1)[-1].split("\n## ", 1)[0]
    criteria = sorted(set(re.findall(r"^- \[[ xX]\] \*\*([A-Z][A-Z0-9-]*-\d{2,3}):\*\*", acceptance, re.M)))
    portfolio.append([spec_id, status, str(path.relative_to(ROOT)), len(criteria), hashlib.sha256(content.encode()).hexdigest()])
write_tsv("specifications.tsv", ["id", "status", "path", "unique_criterion_ids", "sha256"], portfolio)

internal_edges = [(consumer, dependency) for consumer, dependency, kind in edges if kind == "internal"]
graph = {name: [dependency for consumer, dependency in internal_edges if consumer == name] for name in targets}
visited, active = set(), set()


def visit(name):
    if name in active:
        raise ValueError("cycle at " + name)
    if name in visited:
        return
    active.add(name)
    for dependency in graph[name]:
        visit(dependency)
    active.remove(name)
    visited.add(name)


for name in targets:
    visit(name)
undeclared = sorted((name, dependency) for name, imports in all_imports.items() for dependency in imports if dependency in targets and dependency not in graph[name] and dependency != name)
summary = {
    "schema_version": 1,
    "reviewed_revision": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
    "targets": len(targets),
    "internal_edges": len(internal_edges),
    "external_edges": len(edges) - len(internal_edges),
    "acyclic": True,
    "source_swift_files": sum(row[3] for row in module_rows if row[2].startswith("Sources/")),
    "source_opening_if": sum(row[6] for row in module_rows if row[2].startswith("Sources/")),
    "nrf_selected_source_files": len(nrf_sources),
    "nrf_selected_owners": len(set(path.split("/")[1] for path in nrf_sources)),
    "internal_imports_without_direct_edge": undeclared,
    "limits": "Lexical counts include conditional/inactive imports and generated code. CMake inventory does not configure/build firmware; criterion IDs are mentions, not validated acceptance coverage.",
}
(OUTPUT / "inventory-summary.json").write_text(json.dumps(summary, indent=2) + "\n")
print(json.dumps(summary, indent=2))
