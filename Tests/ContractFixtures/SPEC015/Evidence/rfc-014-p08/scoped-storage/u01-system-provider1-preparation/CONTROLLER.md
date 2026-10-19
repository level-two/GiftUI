# U01 system-provider I-only controller — preparation, no launch

Independent preparation review `61466053` passed the inventory/request and required
cache-schema qualification or a closed gate. [IDENTITY-DESIGN.md](IDENTITY-DESIGN.md)
and [gate-policy.json](gate-policy.json) freeze the latter: no applicable cache
UUID-field schema is authenticated, no field offset/parser is invented, and both
S body/data commands are always skipped. This is a concrete one-child realization
of the three-command ceiling. Old B is untouched. Independent Strong readiness
review of final bytes/pins is required; this packet grants no launch clearance.

## External pins and isolated startup

[reviewed-launch.py](reviewed-launch.py) must be obtained from the final reviewed
Git blob and authenticated against an independently supplied SHA-256 **before**
being used as source. Pass those verified bytes as the literal `-c` program to
`/Applications/Xcode.app/Contents/Developer/usr/bin/python3` with
`-I -S -B -X pycache_prefix=/dev/null`, followed by one external JSON argument.
Do not execute the mutable workspace file or derive pins from current HEAD at
launch. Launch with an empty inherited environment and exactly the pinned prior
loader policy's bootstrap dictionary (HOME/USER/LOGNAME, restricted system PATH,
TMPDIR, LC_CTYPE and both explicit system-only DYLD fallbacks). No shell
interpolation, startup/site initialization, repository import or Python cache
write is needed. The exact optional interpreter-added CF encoding is checked.

The external argument must supply full final `commit`, `repository_tree`,
`packet_tree` identities and a `files` map of SHA-256 for these nine files:

- `reviewed-launch.py`, `controller.py`, `identity-verifier.py`;
- `request.json`, `inventory.json`, `controller-inputs.json`;
- `loader-policy.json`, `gate-policy.json`, `controller-accounting.json`.

These values must come after independent readiness review. No self-generated
launch pin record is supplied here. The bootstrap authenticates Git object
hashes, final HEAD/tree joins, all packet blobs and exact workspace membership.
It loads only authenticated controller source from Git bytes; the controller
loads the authenticated verifier similarly. Fixed read-only Git children use
restricted complete environments, reject config includes, disable external
helpers/replacements/lazy fetch, and share the remaining aggregate deadline.

## Inputs, loader trust and identity verifier

[controller-inputs.json](controller-inputs.json) freezes **203 direct files**,
including all15 cache-family members, report/negative artifact/log, linked evidence,
exact counter/link objects, tool/manual, source42 and preservation state. It also
pins the previous complete loader-policy/roots/aliases manifests by hash; the
local environment policy also has a direct external SHA-256 pin and must equal
the prior policy. These
are read as data, not imported or executed. Exact complete trees remain **8,720
entries /72 aliases** under the Python3.9 framework, adjacent Xcode toolchain
library root and conservative decoder library root. Installed Apple `/usr/lib`
and `/System/Library` loader/runtime remain explicit trusted OS boundaries.
No hermetic OS or ordinary historical-process qualification is claimed.

Initial and pre-command authentication checks packet/HEAD, every direct file's
bytes/alias and stat stability across hashing, full loader trees/aliases, absent
paths, exact15 cache membership, source/dirty/cache hashes, and both consumed
marker identities. Every child receives the complete reviewed request environment,
including `/usr/lib` and `/System/Library/Frameworks` fallback paths; no provider
override is permitted. The preserved old markers are checked, never written.

[identity-verifier.py](identity-verifier.py) compares the report's exact selected
fields and supplemental path/arm64e UUIDs, current/report OS build, and retained
strong linked system-provider imports. It does not decode a cache header, infer
a field from UUID literal bytes, or parse an undocumented dyld_info output grammar.
These authenticated input joins are explicitly distinct from ordinary-counter
loaded-image proof. Even nonempty successful I output cannot authorize S.

## Permanent consumption, timing, caps and receipts

After external packet authentication, [controller.py](controller.py) atomically
creates `.build/contracts/p08-u01-system-provider-static1`, refusing duplicates
or resume. It writes/fsyncs the permanent consumption record and directory
identity before the first dyld_info child. The output remains absent during this
preparation. One new proposed bootstrap/attempt is unused; both historical
attempts stay1/1 consumed. No old marker or budget is reused.

The monotonic **240-second aggregate deadline starts at bootstrap entry** and
includes Git/bootstrap authentication, repeated full input/loader hashing,
identity joins and gate handling. A real-time alarm enforces the same deadline.
The one exact I command has **60 seconds**, bounded by aggregate time remaining.
It runs in its own process group, stdin closed, with raw stdout/stderr streamed
to fresh durable files. Its combined raw limit is **16MiB**. At most one dyld_info
child is spawned; the two exact S commands receive skipped receipts.

The total retained **raw output plus receipts is capped at320MiB**. Raw writes
reserve1MiB for receipts; JSON receipts enforce both the shared cap and their
1MiB reserve, at most24 receipts and64KiB each. Any cap stops capture and kills
the owned group; no truncated evidence can pass capture. The much smaller I raw
ceiling still applies. Actual process wait status, raw-prefix size/hash,
observed/retained bytes, cap/timeout/truncation, argv/environment, authentication,
claim/start, gate and terminal/skipped receipts are written with exclusive
creation, flush/fsync and directory fsync. The terminal reports retained raw and
receipt bytes before its own bounded write; every write enforces the total cap.

On timeout, signal, nonzero exit, missing/empty output, drift or exception, stop
with no alternate tool/command, repair/retry or new acquisition. After work stops,
a finite two-second reap and receipt persistence may finish; no child work,
authentication, provider gate continuation or deadline reset follows. Signals
are blocked only during actual-exit/raw receipt persistence. Host hard kill,
filesystem failure or receipt failure can leave partial evidence; permanent
consumption forbids resume and no missing actual exit may be invented.

After successful nonempty I capture, the controller writes
`STOP_cache_schema_unestablished` and both S skipped receipts. It returns STOP,
never U01/provider/full-callee/strict-cold PASS. Any later schema/S evidence needs
separate reviewable preparation; no live pause, revised gate reload or S release
exists in this controller.

## Preparation verification and handoff

[prepare-controller.py](prepare-controller.py) only reads/hashes existing inputs
and writes the context JSON. Its execution does not import/execute the controller,
bootstrap or verifier. Their source was inspected and parsed as AST only; the separate
[preparation inspection](controller-preparation-inspection.json) records exact
input/loader/preservation checks. No
behavioral test or execution is claimed. Input/hash/navigation checks are evidence
preparation, with no decoder/help/controller/runtime/compiler/build/test launch.

Independent Strong readiness review should authenticate final external pin shape,
bootstrap trust, all203 files/15 cache members, complete loader trees/aliases,
marker ownership, deadlines, raw+receipt caps, actual exits, and unconditional S
closure. Five dirty files/cache and both consumed marker identities remain
unchanged. R01–R04 and ordinary loaded identity remain open; strict cold stays
false, and P08/R07/T8.1 remain open. No actual contract/scope choice arose.
