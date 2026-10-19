# Separate P08 retained applicability and downstream continuation 1

Status: compiler-free preparation; independent applicability and launch-readiness
review pending. No compiler, schema4 or counter invocation has run for this packet.
This packet cannot resume, repair, retry or relabel campaign11.

The independent readiness review blocked preparation `21d35968` because `-B`
does not stop cache reads and ambient `PYTHONPATH` could replace an import before
pin authentication. This revision adds the isolated absolute-interpreter launch,
null cache namespace, actual Python runtime freeze and executable adversarial
checks below. Independent readiness review of this revision remains pending.

The implementation-executor skill applies. SPEC-013 and SPEC-015 remain
implementing with active owner plans; P08/R07/T8.1 remain open. Approved RFC-014
amendments, accepted ADR-036/039 and the approved Specifications supply authority.
The focused retained-evidence qualification follows the active P08 plan's
bounded continuation scope. ITERATION-003 IT-AC-008 requires the actual analyzer
and counter stack validation, continuing ITERATION-001's reference application
and Static/Dynamic stack validation requirement. No architecture, contract,
resource bound, lifecycle state or deferred scope changes here.

## Evidence and applicability argument

Campaign11 archive `101ced00` remains terminal STOP at P07, with 80/80 qualifying
ABI controls, eight P02/P04 producers across four profiles, macro regression
`executions=19 failures=0 skips=0`, zero repairs and zero retries. Its command
records, negative classifications, first-stage stdout/stderr, prelaunch audits,
transitive positive modules, macro outputs, producer receipt copies and every
producer artifact are retained without reinterpretation. Its private-init
omission and strict-cold ineligibility remain explicit limitations.

The corrected isolated P07 archive `c50d0c8c` remains an isolated PASS with no
dependent release: 33 checks and `P07 values assertions=5904 failures=0`, one
source candidate and zero repairs/retries. Both archives are authenticated
against full Git commit IDs in `recipe.json`, their actual Git objects and every
archived file. Current retained `.build` originals and archive copies are frozen
separately. The current P07 terminal, all files including cache, result receipt,
compiler and exact core-receipt operand/hash join are rechecked.

`source-differences.json` enumerates every committed path between campaign11's
source baseline and the full `comparison_head` (the P07 archive commit), plus the complete diffs and hashes of the
five existing dirty files. The sole difference in the 541 frozen invocation
inputs is `Tests/ContractFixtures/SPEC013/RuntimeDerived/Cycle.swift`: correction
`c5e39966` adds `@usableFromInline` to `CycleScene.show`. The changed field is
consumed by the isolated P07 generated evaluator. It is absent from P02/P04,
macro regression, and Analyzer ABI-control compilation operands. Those retained
producers and controls therefore retain their exact source/tool/recipe/artifact
identities. Current source discovery is also frozen, rejecting additions or
aliases that could alter a driver's collected inputs. The two dirty target-host
Sources files are sealed by discovery but are absent from compilation inputs;
the other three dirty files and scripts/contracts pycache are outside the finite
invocation operands. No exclusion grants authority to consume changed bytes.

`source-freeze.json`, `source-inventory.json`, `tools.json`,
`retained-files.json` and `retained-trees.json` seal finite file names, bytes,
complete directory membership and link identities. The 64 finite roots contain 70,869 entries. The full macOS and ARMv6
SDKs, compiler executables/frontends, compiler Swift and Clang resources,
SwiftSyntax/macro import search directories, producer and control roots are
included. Compiler/SDK/target/optimization/lifetime flags remain the exact
retained commands used by the maintained downstream drivers. Additional `.o`
or `.swiftmodule` files in any retained import directory fail authentication.
No wildcard authorizes new evidence or input files; traversal only checks exact
membership against the finite manifests.

This is a proposed applicability argument for independent review. Historical
passes alone do not qualify the new packet or release a launch.

## Exactly one sequential continuation after independent review

The maintained recipes are fixed:

```text
python3 scripts/contracts/check-spec-015-schema4.py --runtime-build /Users/eugene/work/GiftUI/.build/contracts/spec-013-runtime-cycle/tmpb3zdakko/macos-static --activation-join
python3 scripts/contracts/check-spec-015-counter.py --profile macos-static --runtime-build /Users/eugene/work/GiftUI/.build/contracts/spec-013-runtime-cycle/tmpb3zdakko/macos-static --host-build NEW_QUALIFIED_SCHEMA4_ROOT --collect-failures
```

Do not invoke these directly. `run.py` launches schema4 exactly once, then only
releases counter384 after a complete passing schema4 receipt with activation,
copy, callback, constant-callback, backing and execute joins. Runtime-build
receipt/hash/profile joins must match the corrected isolated P07. Counter must
report `collection_complete=true`, `passed=true`, `fresh_focused=false`, exactly
384 unique passing labels, and the exact P07 and newly qualified schema4 operand
and receipt joins. No selectors, resume, legacy imports or focused run are used.
The counter's maintained `--collect-failures` behavior collects its original
finite gate; a failing stage never releases a later subprocess or retry.

Before and after each subprocess, the runner reauthenticates the reviewed HEAD,
repository tree, packet tree and every packet byte, the complete retained
applicability context, and the permanent `.build/validation.lock` inode while
holding its exclusive flock. The schema4 output receives a complete immutable
snapshot before counter launch and is checked again after counter. The lock is
inherited into each maintained driver. No environment assertion can claim lock
ownership. A fixed minimal environment and PATH are recorded in `recipe.json`;
The downstream process uses the absolute frozen Xcode Python executable via
`Popen(executable=...)`, preserving both original argv recipes. The actual
Xcode interpreter, its complete Python 3.9 framework runtime and Ruby executable
identities are sealed; `/usr/bin/python3` alone is insufficient.
`PYTHONPYCACHEPREFIX=/dev/null` prevents reading substituted local `.pyc` files;
`PYTHONDONTWRITEBYTECODE=1` prevents cache writes. Exact Python-source membership discovery in `scripts/contracts`
rejects added startup/import source files while leaving existing
`__pycache__` outside the consumed cache namespace.

The permanently consumed marker is
`.build/contracts/p08-retained-evidence-dependent-continuation1`. Any existing
marker rejects; never remove it to permit another attempt. Under the repository
lock, the runner snapshots `.build/contracts`, requires exactly one new driver
root with the expected prefix and unchanged existing root inode identities,
and binds its name to raw stdout/stderr. Both drivers keep their maintained
fresh-root behavior. Missing/ambiguous roots or first material failure are STOP,
with zero automatic repairs, zero retries and no remaining dependent launch.

## Compiler-free verification and external review gate

Run from the repository root:

```sh
/usr/bin/env -i HOME=/Users/eugene TMPDIR=/private/tmp PATH=/usr/bin:/bin:/usr/sbin:/sbin /Applications/Xcode.app/Contents/Developer/usr/bin/python3 -I -S -B -X pycache_prefix=/dev/null Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result/retained-evidence-dependent-continuation1-preparation/test_static.py
```

Eleven tests include real full-context authentication and actual temporary
filesystem attacks: changed source/artifact/receipt, traversal, raw first-stage
log and audit drift, additional object/module/cache entries, link and directory
identity changes, absent activation joins, changed dependency hashes/operands,
383/duplicate/failed counter labels, aggregate/focused flags, valid timestamp/size-matching
substituted bytecode for `p08_check_collection` and `p08_layout_facts`, ambient
`PYTHONPATH` substitution of `pathlib`, real interpreter/startup identity, invalid external
Git pins, substituted packet code and extra packet members. No test calls a
compiler, downstream driver or the actual continuation runner. The bootstrap
fixture executes only a harmless Git-pinned marker writer in a temporary repository. `static-validation.json` and the raw
static-test stdout/stderr record these preparation checks.

An independent reviewer must assess complete applicability, exact source
differences and the sequential launch route, then issue full reviewed commit,
repository tree and packet tree IDs. The bootstrap is read from the reviewed Git
object and authenticates all objects and packet bytes before loading packet
code. The verifier and runner execute directly from authenticated Git bytes;
the readiness import is supplied from those same bytes. After that review only, the sole permitted launch form is:

```sh
git --no-replace-objects show REVIEWED_COMMIT:Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result/retained-evidence-dependent-continuation1-preparation/reviewed-launch.py | /usr/bin/env -i HOME=/Users/eugene TMPDIR=/private/tmp PATH=/usr/bin:/bin:/usr/sbin:/sbin /Applications/Xcode.app/Contents/Developer/usr/bin/python3 -I -S -B -X pycache_prefix=/dev/null - REVIEWED_COMMIT REVIEWED_REPOSITORY_TREE REVIEWED_PACKET_TREE
```

The absolute interpreter starts with `env -i`, `-I`, `-S`, `-B` and the CLI
cache prefix before any packet import. The bootstrap rejects startup without
those flags before importing `pathlib`; ambient Python paths, site hooks and
local bytecode cannot supply that import.

The three pins must come from the completed independent review, never a mutable
manifest, an abbreviated object ID or launch-time discovery. No reviewed pins
or launch clearance are asserted in this preparation.

## Terminal retention and remaining work

The runner retains `launch.json`, stage stdout/stderr and `terminal.json` with
exit codes, times, exact argv, working-tree observations, before/after directory
identities, raw log hashes and complete observed new-root manifests even when
qualification fails. Actual receipts and every generated artifact remain in
the fresh driver roots. After an authorized invocation, archive all raw logs,
receipts, source/workload/control outputs and the wrapper reports in a new
sibling result directory, with original paths, byte counts and SHA-256; retain
binary originals with complete identities. Independent result review remains
required. Never overwrite historical evidence.

Even a separate packet PASS qualifies only this retained applicability and the
macOS Static schema4 activation/counter384 gates. It cannot turn campaign11 into
a PASS, close P08, or establish other-profile counter, actual current-callee,
full safety, cold, resource, connected-hardware or conformance acceptance. No
valuable new out-of-scope design decision was discovered; existing deferred
items and their gates remain unchanged.
