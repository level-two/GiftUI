# P07 CycleScene ABI correction: isolated probe preparation

Status: compiler-free preparation PASS; independent source, applicability and
launch-readiness review pending. No compiler or P07 invocation ran for this packet.

The source correction is commit `c5e3996689d17ef6d9cce6dd86317258355b9ea4`:
`Tests/ContractFixtures/SPEC013/RuntimeDerived/Cycle.swift:28` now declares
`@usableFromInline package let show: Bool`. This is the exact field referenced
by the generated inlinable evaluator that stopped campaign11. Source construction
and validation preparation are separate committed steps.

SPEC-013 and SPEC-015 remain implementing, their plans active, and P08 remains
open. This maintenance validates the runtime-derived analyzer/counter stack
required by ITERATION-003 IT-AC-008, continuing the reference-application and
Static/Dynamic stack requirement of ITERATION-001. Authority remains the approved
RFC-014 amendments, accepted ADR-036/039, SPEC-013/015, and active owner plans.
The implementation-executor skill applies. No contract, architecture, lifecycle,
resource bound or deferred scope is changed.

## Scope and retained evidence applicability

This is one focused macOS Static P07 invocation, one source candidate, zero
retries and zero automatic repairs. Campaign11 is terminal STOP at P07 with
80/80 historical qualifying ABI control receipts. It must never be resumed,
repaired or retried. Those controls are historical evidence only.

The proposed retained dependency is exactly campaign11
`result.json.producer_receipts[0]`: P02 macOS Static, source commit
`496c3bdb960d3df2570fa9d44700213d57efc0d3`, execution `checks=120 failures=0`.
`recipe.json` pins the original receipt/copy, campaign result and commands bytes.
The current P02 input/artifact/compiler/macro identities authenticate unchanged;
the sole mismatch against campaign11's 541-input freeze is the corrected
Cycle.swift. `source-freeze.json` changes only that digest; `source-inventory.json`
also seals complete SPEC013 RuntimeDerived Swift discovery. This is a proposed
focused applicability argument for independent review, not qualification of the
retained 80 controls or permission to release downstream stages.

The exact maintained driver and campaign11 P07 argv are preserved:

```sh
python3 scripts/contracts/check-spec-013-runtime-cycle.py --profile macos-static --giftui-build /Users/eugene/work/GiftUI/.build/contracts/spec-006-rfc-014-swift64/8e72c5a1adf5f02b-i9ayjitl/macos-static
```

Do not invoke that command directly. The reviewed wrapper below is the sole
launch route. It supplies `PYTHONDONTWRITEBYTECODE=1`, authenticates packet Git
objects with external review pins before loading mutable packet code, and checks
HEAD, exact packet inventory, the complete input freeze/discovery membership,
resolved compiler/tool identity, original P02 provenance and every retained
artifact before and after the sole subprocess. The wrapper acquires the same permanent `.build/validation.lock` flock inode
used by the repository Ruby lock. It never accepts an environment ownership
flag, inherits the lock into the child, and keeps it until collection finishes. The fresh receipt root is permanently
consumed at `.build/contracts/p08-p07-cyclescene-correction-probe1`; any existing
root rejects. Never delete it to enable another attempt.

The driver keeps its own original random output behavior. Under the repository
lock the wrapper snapshots the original output parent and its directory inode
identities, requires exactly one new directory and no replaced old directory,
and joins that new profile path to raw stdout/stderr. Missing or ambiguous output
is STOP. Driver bytes, arguments and compiler recipe are unmodified; no runpy,
tempfile interception, generated-source edits or alternate lowering is used.

Other profiles are omitted: the observed failure is the Static gate and this
focused retained-core applicability argument is profile-specific. A four-profile
campaign or wider evidence reuse requires its own reviewed scope. An isolated
P07 PASS does not release schema4, activation, counter384 or any campaign stage;
complete retained-evidence applicability would need separate review, otherwise
a separately authorized fresh full campaign is required. P08/current-callee,
safety, cold, resources and conformance remain open.

## Compiler-free checks and independent launch gate

Run from repository root:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result/p07-cyclescene-correction-probe1-preparation/test_static.py
```

Six tests authenticate the real context/fresh receipt-root absence and exercise
source, recipe, budget, producer index/copy, core artifact/commands and driver
mutations, discovered-file additions/symlinks, external Git object pins and
mutable packet substitution. Temporary file mutations never alter real sources.
No test invokes the runner or compiler. `static-validation.json` records the
compiler-free preparation result. This is static behavior evidence only.

Before compiler use, an independent reviewer must review the source correction,
focused retained P02 applicability, packet and launch route, then provide exact
full commit, repository tree and packet tree object IDs. These values must come
from that completed review, not a mutable manifest or a launch-time HEAD query.
After approval, substitute those three reviewed pins in this one-shot command:

```sh
git --no-replace-objects show REVIEWED_COMMIT:Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result/p07-cyclescene-correction-probe1-preparation/reviewed-launch.py | PYTHONDONTWRITEBYTECODE=1 python3 - REVIEWED_COMMIT REVIEWED_TREE REVIEWED_PACKET_TREE
```

No launch pins or completed readiness review are asserted by this preparation.
A failed authentication stops before compiler launch. Once the output marker is
created, every failure is terminal for this probe; no runner retry/repair path
exists. Source changes or a fresh probe require a separate reviewed decision.

## Terminal collection and archive plan

The one-shot wrapper preserves `launch.json`, separate raw `stdout`/`stderr` and
`terminal.json`, with exit, times, reviewed commit, command, environment digest,
working-tree states, before/after directory identities, log digests and all new
P07 file digests. On driver success it binds the original `result.json` to P07,
macOS Static, reviewed HEAD, exact retained-core digest and all check outcomes.
Driver failure remains STOP with dependents unrun. No error log is rewritten.

After any invocation, archive those files plus the observed P07 `commands.txt`,
all raw `.log` files, generated Cycle source/schema/table, logical transcripts,
storage regions and original result receipt if produced, into a new sibling
`p07-cyclescene-correction-probe1-result/` directory. Preserve paths, SHA-256 and
byte counts in its manifest; retain modules/objects/cache in their existing
`.build` paths with hashes rather than duplicating binaries. If output binding
fails, archive the before/after inventory and all newly observed directory paths
without claiming a uniquely authenticated result. Record independent terminal
review and remaining gates. Preserve campaign11 and all historical evidence.
Commit only that result archive at the later authorized collection step.
