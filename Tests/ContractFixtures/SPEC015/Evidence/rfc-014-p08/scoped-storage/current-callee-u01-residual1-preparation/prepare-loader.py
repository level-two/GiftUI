"""Hash applicable existing tool/Python loader roots; never launch a child."""
import hashlib
import json
import os
import pathlib

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[6]


def digest(path):
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


roots = [
    "/Applications/Xcode.app/Contents/Developer/Library/Frameworks/Python3.framework/Versions/3.9",
    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib",
    str(ROOT / ".toolchains/p08-serialization-decoder/prefix/lib"),
]
trees = {}
aliases = {}
for root_name in roots:
    root = pathlib.Path(root_name)
    entries = {}
    for directory, dirs, files in os.walk(root, followlinks=False):
        for basename in dirs + files:
            path = pathlib.Path(directory) / basename
            key = str(path.relative_to(root))
            if path.is_symlink():
                resolved = path.resolve(strict=True)
                entries[key] = {"kind": "symlink", "target": os.readlink(path)}
                system = str(resolved).startswith(("/usr/lib/", "/System/Library/"))
                assert system or any(resolved.is_relative_to(pathlib.Path(r)) for r in roots), str(path)
                aliases[str(path)] = {"target": os.readlink(path), "resolved": str(resolved),
                                      "kind": "directory" if resolved.is_dir() else "file",
                                      "system_trust": system,
                                      **({"sha256": digest(resolved), "bytes": resolved.stat().st_size} if resolved.is_file() and not system else {})}
            elif path.is_dir():
                entries[key] = {"kind": "directory"}
            else:
                assert path.is_file()
                entries[key] = {"kind": "file", "bytes": path.stat().st_size, "sha256": digest(path)}
    trees[root_name] = entries

interpreter = pathlib.Path("/Applications/Xcode.app/Contents/Developer/usr/bin/python3")
aliases[str(interpreter)] = {"target": os.readlink(interpreter), "resolved": str(interpreter.resolve(strict=True)),
                            "kind": "file", "system_trust": False, "sha256": digest(interpreter), "bytes": interpreter.stat().st_size}
environment = json.loads((HERE / "request.json").read_text())["commands"][0]["environment"]
policy = {
    "schema": 1,
    "bootstrap_environment": environment,
    "controller_environment": environment,
    "python_executable": str(interpreter),
    "python_flags": ["-I", "-S", "-B", "-X", "pycache_prefix=/dev/null"],
    "interpreter_added_environment": {"LC_CTYPE": "C.UTF-8", "__CF_USER_TEXT_ENCODING": "0x1F5:0x7:0x3D"},
    "loader_roots": roots,
    "purpose": "Complete Python framework; conservative complete adjacent Xcode toolchain library root for Apple tool dependencies; complete explicit LLVM decoder library root. No developer framework override or HOME fallback search.",
    "system_trust": {"library_fallback": "/usr/lib", "framework_fallback": "/System/Library/Frameworks", "boundary": "Installed Apple system loader and /usr/lib and /System/Library runtimes remain trusted; this is not a hermetic OS image or historical counter-runtime qualification.", "roots_present": {p: pathlib.Path(p).is_dir() for p in ("/usr/lib", "/System/Library/Frameworks")}},
}
for filename, value in (("loader-roots.json", trees), ("loader-aliases.json", aliases), ("loader-policy.json", policy)):
    path = HERE / filename
    data = (json.dumps(value, indent=2, sort_keys=True) + "\n").encode()
    if path.exists():
        assert path.read_bytes() == data, "loader inventory drift: " + filename
    else:
        path.write_bytes(data)
print(json.dumps({"roots": len(trees), "entries": sum(len(t) for t in trees.values()), "aliases": len(aliases), "children_launched": 0}, sort_keys=True))
