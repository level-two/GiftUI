# Independent Strong review — U01 A-only controller readiness

Reviewed 2026-10-19: environment **`e6704db4e8e941663b48aacf797959125be88145`**
and controller **`75cafff6dcd3677ebcdb5ef06e22d3b48f9f7af1`**.
**PASS for this exact A-only bootstrap/controller/environment readiness.**
The earlier B1 loader-fallback blocker is resolved. No blocking factual,
contract or scope finding remains. No controller or decoder ran during review.

## Independent authentication and control review

Read the [controller handoff](CONTROLLER.md), bootstrap/controller source,
preparation programs, request, gate/accounting and loader/context manifests.
Independent standard-library hashing, JSON/tree/alias inspection, syntax parsing
and read-only Git comparisons produced the
[inspection record](controller-independent-review-inspection.json). No reviewed
module was imported or executed.

Every existing packet file equals the reviewed Git blob. All **nine external
SHA-256 pins**, **180 direct inputs**, **six absent paths**, **8,720 complete loader
entries** in three roots and **72 aliases** match. Membership, endpoint kinds,
resolved paths, symlink targets and applicable file hashes/sizes agree. All
**42 source hashes**, **five preexisting dirty-file hashes** and cache membership/
hashes remain unchanged; the proposed output directory is absent.

- **Bootstrap trust:** isolated absolute Xcode Python receives verified Git-blob
  bootstrap bytes as literal `-c` source and external full commit/repository-tree/
  packet-tree plus nine SHA pins. It checks exact environment/startup flags,
  authenticates object hashes and tree joins, rejects packet aliases/membership
  drift and executes the authenticated controller blob in memory. Git operations
  use fixed read-only builtins with includes/helpers/replacements/lazy fetching
  disabled. The installed Apple system loader/runtime is the explicit trust
  boundary; this is not historical counter-runtime qualification.
- **Environment:** bootstrap/controller and all six request dictionaries now
  restrict library/framework fallbacks to `/usr/lib` and
  `/System/Library/Frameworks`. Only LLVM gets the frozen decoder library root.
  No ambient startup/loader settings or HOME fallbacks are admitted. The absolute
  interpreter and its resolved framework/library inputs are authenticated.
- **One-shot ownership:** atomic creation of the canonical fresh output directory
  refuses duplicate/resume launches. Exclusive, fsynced consumption/claim records
  precede every decoder. Initial/per-command checks reauthenticate packet/HEAD,
  direct sources/evidence/preservation/cache, complete loader roots and aliases.
  No existing collection marker is used for control or reset. A bootstrap failure
  before output ownership still consumes its authorized bootstrap launch; it
  provides no automatic retry merely because no decoder started.
- **Deadlines and caps:** the unchanged 360-second deadline starts in bootstrap
  and includes Git/context authentication, children, record checks and gate work;
  each child gets at most 60 seconds and a new process group. Streaming captures
  enforce A's combined **8/16/128 MiB** caps and the **512 MiB** aggregate ceiling.
  Timeout, cap, signal or capture exceptions kill the child group. A nonzero exit,
  unsupported option or missing record ends the attempt without substitution.
- **Actual outcomes:** raw stdout/stderr prefixes, observed/retained counts,
  sizes/hashes and actual `wait` exits are written before record interpretation.
  Signals are blocked only during cleanup/receipt persistence; finite reaping is
  limited to two seconds. Work cannot resume after the deadline. Hard-kill or
  filesystem failure can leave incomplete records, never an invented actual exit
  or permission to resume. Minimal output tokens cannot establish semantic PASS.
- **Closed provider gate:** only `commands[:3]` can reach `Popen`. Successful A
  collection ends **STOP_provider_proof_unestablished**; every B command receives
  an explicit skipped/null-exit record. No name/version/token, mutable gate file
  or human pause can release B. No runtime/library probe, acquisition, compiler,
  build, test or strict-cold operation is present.

## Exact clearance and remaining gates

This review clears the **one A-only orchestration bootstrap** within the already
authorized bounded P08 work: at most three pinned static decoder children, zero
repairs/retries/acquisitions and zero runtime/compiler/build/test/strict-cold
launches. No additional confirmation is required solely because the preparation
records correctly withheld authorization before review. Use the final review
commit and its externally supplied repository/packet trees, together with the
nine exact hashes in the inspection record. Obtain bootstrap bytes from that
Git blob and verify their external SHA before isolated invocation; do not run
the mutable workspace bootstrap or derive replacement pins from HEAD at launch.
Record the single bootstrap invocation even if authentication stops before
marker creation. Any drift or failure stops this allowance without retry.

This is readiness clearance, not a completed capture or U01/provider result.
B requires separately reviewed exact provider proof/preparation, final external
pins and explicit allowance. No contract/scope choice arose; any future warm-up
or heap/ownership/privacy/bound/scope relaxation goes upstream for the requested
Astra Medium decision.

The five dirty files/cache and historical collection **1/1**, repairs **0**,
retries **0**, marker **[16777234, 29640436]** remain unchanged. Accepted
ADR-039/040 and implementing SPEC-015 remain authoritative; the finite-counter
exception is preserved. R01–R04 and U02–U05 remain open. Complete callee **and**
safety PASS still precede a current strict-cold manifest with its existing
host-first baseline, silent/observed/ordinary windows, counts and zero-heap
enforcement. **P08/R07/T8.1, remaining SO, four-profile, ABI/resources,
independent exit and later conformance gates remain open.**
