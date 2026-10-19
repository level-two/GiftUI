"""External-pin bootstrap; invoke only as the independently verified Git blob."""
import time
STARTED = time.monotonic()
import os
import sys
import signal

def deadline_signal(signum, frame):
    raise SystemExit("aggregate bootstrap deadline exceeded")

signal.signal(signal.SIGALRM, deadline_signal)
signal.setitimer(signal.ITIMER_REAL, max(0.001, 360 - (time.monotonic() - STARTED)))
EXPECTED_ENV = {
    "HOME": "/Users/eugene", "USER": "eugene", "LOGNAME": "eugene",
    "PATH": "/usr/bin:/bin:/usr/sbin:/sbin", "TMPDIR": "/private/tmp", "LC_CTYPE": "C.UTF-8",
    "DYLD_FALLBACK_LIBRARY_PATH": "/usr/lib",
    "DYLD_FALLBACK_FRAMEWORK_PATH": "/System/Library/Frameworks",
}
actual = dict(os.environ)
if "__CF_USER_TEXT_ENCODING" in actual:
    if actual.pop("__CF_USER_TEXT_ENCODING") != "0x1F5:0x7:0x3D":
        raise SystemExit("unexpected interpreter-added encoding")
if actual != EXPECTED_ENV:
    raise SystemExit("complete env-i bootstrap dictionary required")
if not (sys.flags.isolated and sys.flags.no_site and sys.flags.dont_write_bytecode and sys.pycache_prefix == "/dev/null"):
    raise SystemExit("isolated -I -S -B -X pycache_prefix=/dev/null startup required")
if sys.executable != "/Applications/Xcode.app/Contents/Developer/usr/bin/python3":
    raise SystemExit("absolute pinned Xcode interpreter required")

import hashlib
import json
import pathlib
import re
import subprocess
import types

ROOT = pathlib.Path("/Users/eugene/work/GiftUI")
RELATIVE = "Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-u01-residual1-preparation"
PACKET = ROOT / RELATIVE
REQUIRED = {"reviewed-launch.py", "controller.py", "request.json", "controller-inputs.json",
            "loader-policy.json", "loader-roots.json", "loader-aliases.json", "gate-policy.json", "controller-accounting.json"}
if len(sys.argv) != 2:
    raise SystemExit("one external final-pin JSON argument required")
pins = json.loads(sys.argv[1])
if set(pins) != {"commit", "repository_tree", "packet_tree", "files"} or set(pins["files"]) != REQUIRED:
    raise SystemExit("complete external final commit/tree/request/input/environment/controller pins required")
if not all(re.fullmatch("[0-9a-f]{40}", pins[k]) for k in ("commit", "repository_tree", "packet_tree")):
    raise SystemExit("full external Git identities required")
if not all(re.fullmatch("[0-9a-f]{64}", v) for v in pins["files"].values()):
    raise SystemExit("full external SHA-256 identities required")

def remaining():
    value = 360 - (time.monotonic() - STARTED)
    if value <= 0:
        raise SystemExit("aggregate authentication deadline exceeded")
    return value

def git(*args):
    if not args or args[0] not in ("cat-file", "rev-parse", "ls-tree"):
        raise SystemExit("read-only fixed Git builtin required")
    env = EXPECTED_ENV | {"GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_SYSTEM": "/dev/null",
        "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_TERMINAL_PROMPT": "0", "GIT_NO_LAZY_FETCH": "1", "GIT_ALLOW_PROTOCOL": ""}
    prefix = ["/usr/bin/git", "--no-replace-objects", "--no-pager", "--no-optional-locks",
        "-c", "core.fsmonitor=false", "-c", "core.hooksPath=/dev/null", "-c", "diff.external=",
        "-c", "credential.helper=", "-c", "core.sshCommand=/usr/bin/false", "-c", "submodule.recurse=false"]
    configuration = subprocess.check_output([*prefix, "config", "--no-includes", "--null", "--list"],
        cwd=ROOT, env=env, stdin=subprocess.DEVNULL, timeout=remaining())
    for entry in configuration.split(b"\0"):
        key = entry.split(b"\n", 1)[0].lower()
        if key == b"include.path" or key.startswith(b"includeif."):
            raise SystemExit("Git config includes forbidden")
    output = subprocess.check_output([*prefix, *args], cwd=ROOT, env=env,
        stdin=subprocess.DEVNULL, timeout=remaining())
    if len(output) > 8 * 1024**2:
        raise SystemExit("Git authentication record too large")
    return output

def git_object(kind, oid):
    if not re.fullmatch("[0-9a-f]{40}", oid):
        raise SystemExit("finite full object identity required")
    data = git("cat-file", kind, oid)
    if hashlib.sha1(kind.encode() + b" " + str(len(data)).encode() + b"\0" + data).hexdigest() != oid:
        raise SystemExit("Git object bytes mismatch")
    return data

for kind, key in (("commit", "commit"), ("tree", "repository_tree"), ("tree", "packet_tree")):
    git_object(kind, pins[key])
if git("rev-parse", "HEAD").decode().strip() != pins["commit"]:
    raise SystemExit("final reviewed HEAD drift")
if git("rev-parse", pins["commit"] + "^{tree}").decode().strip() != pins["repository_tree"]:
    raise SystemExit("repository tree pin mismatch")
if git("rev-parse", pins["commit"] + ":" + RELATIVE).decode().strip() != pins["packet_tree"]:
    raise SystemExit("packet tree pin mismatch")
packet_bytes = {}
for record in git("ls-tree", "-rz", pins["packet_tree"]).split(b"\0"):
    if record:
        header, filename = record.split(b"\t", 1)
        mode, kind, oid = header.split()
        if mode not in (b"100644", b"100755") or kind != b"blob":
            raise SystemExit("packet must contain ordinary Git blobs only")
        packet_bytes[filename.decode()] = git_object("blob", oid.decode())
for filename, expected in pins["files"].items():
    if hashlib.sha256(packet_bytes[filename]).hexdigest() != expected:
        raise SystemExit("external file pin mismatch: " + filename)
if PACKET.resolve() != PACKET or {p.name for p in PACKET.iterdir()} != set(packet_bytes):
    raise SystemExit("packet membership/alias drift")
for filename, data in packet_bytes.items():
    path = PACKET / filename
    if path.is_symlink() or not path.is_file() or path.read_bytes() != data:
        raise SystemExit("packet bytes drift: " + filename)
controller = types.ModuleType("u01_reviewed_controller")
controller.__dict__["__file__"] = str(PACKET / "controller.py")
exec(compile(packet_bytes["controller.py"], "<externally pinned controller Git blob>", "exec"), controller.__dict__)
raise SystemExit(controller.main(pins, STARTED, packet_bytes, git))
