# P08 suite collection activity — 2026-10-14

Status: **active; harness source frozen, independent review and suite collection pending**.
Current setup correction below consumes **cycle 1/2**; grouped collected-suite
corrections retain cycle 2. The initial `d6792a06` freeze below remains historical;
the appended setup freeze supersedes its schema/readiness descriptions.
SPEC-015 remains implementing under its active plan, accepted ADR-039 and the
approved RFC-014/RFC-015 amendments. This is the ITERATION-003 finite-counter
dependency/validation path, not a contract or scope amendment.

Eugene explicitly requested: “run the whole suite, collect such low-priority
errors, correct them and run a focused subset to save time rather than stopping
at each barrier”. This authorizes collection of independent failures, grouped
routine corrections, independent Strong assessment and focused validation under
the existing P08 matrix. The new batch defaults to **at most two grouped
corrective cycles**, with a stop after two consecutive unproductive cycles;
**0/2 consumed at this source freeze**. The former 2/2 and one-candidate/run
allowances remain closed historical records; they are not the current activity's
per-error stop gates. Actual architecture/contract/resource/toolchain/scope
conflicts still require evidence and a maintainer decision. No hardware action,
capacity relaxation, P08 acceptance or implemented transition is authorized.

This harness step changes only the driver, shell forwarding and a small Python
collection helper with compiler-free tests. All Swift fixtures, compiler flags,
384 non-Embedded/202 Embedded scoped labels, five native exclusivity controls
and thirteen reuse labels per selected route remain unchanged. The existing
[exact source applicability qualification](p08-compiler-compatibility2-applicability.json)
continues to apply because CounterScopedStorage is unchanged. Parent owns current
navigation, independent review and actual registered validation; this assignment
ran no compiler, build, harness suite, formatter, image or hardware operation.

Every newly executed command journals its numeric exit, status, command identity
and log hash incrementally in `checks.json`; interrupted/running journals cannot
claim success. Failed prerequisites block dependents. Failed positive compiler
controls block their negative twins. Diagnostic mismatches collect subsequent
independent controls and do not block a valid counter link/runtime; runtime
failure does not block the independently prepared exclusivity module. The
negative native trap requires its successful positive execution. Reuse labels
require successful execution and exact single occurrences; the runtime summary
requires positive assertion count and zero failures. Completed collections return
nonzero when any check fails or is blocked, and retain all registered labels.

Focused selection uses entire families, including every positive twin. A complete
schema-1 predecessor receipt must verify all artifact/log hashes, classifier/exit
consistency, recipe identities, collector identity, compiled inputs and each
unchanged command/source/oracle identity. Changed or absent unselected checks,
unknown selectors, incomplete coverage or source drift reject reuse. Driver-only
matcher data may change; any changed family must be selected. New outputs and
receipts are separate from predecessors, and aggregate coverage keeps unchanged
failures. A subset establishes full aggregate success only with verified complete
prior coverage plus successful selected replacements. Finite structured matcher
alternatives with generated-probe error-site bounds and crash/prefix-error
rejection are supported and tested; **baseline registrations retain their old
tuple matchers**, including the known closure mismatch.

The narrow legacy import qualifies only the immutable
[compatibility2 packet](compiler-compatibility2-counter/manifest.json), manifest
SHA-256 `7f4e7a2569d5ed9263444373e46710fb45d00af2fcfbb97294229d059b19f2bb`.
It verifies all packet files, exact normalized commands, generated source hashes
and every current compiled Swift input against `cab1c415`. Its 191 accepted
observations and 192nd failed oracle retain their original provenance and inferred
exit classes/null negative numeric codes; no codes are invented and the failure
is not reclassified. All nineteen preparation commands are rebuilt because the
partial packet pins only the counter module artifact family. The remaining 192
scoped controls, native runtime and exclusivity controls then run independently.
The [historical result](p08-compiler-compatibility2-result.md) is unchanged.

Baseline collection command after independent review:

```sh
scripts/contracts/run-spec-015.sh --profile macos-dynamic --corpus rfc-014-counter --runtime-build .build/contracts/spec-013-runtime-cycle/tmpi1u8hyk5/macos-dynamic --host-build .build/contracts/p08-scoped-host-ezcy1qan --collect-failures --import-legacy-controls Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/compiler-compatibility2-counter
```

For the other registered profiles, use their matching runtime/host receipts and
`--collect-failures`, without the legacy import. Unchanged component cells remain
their verified predecessors; full P08 validation is not inferred from this one
counter cell. After baseline collection exposes the full error list and grouped
corrections are reviewed, a focused closure-family example is:

```sh
scripts/contracts/run-spec-015.sh --profile macos-dynamic --corpus rfc-014-counter --runtime-build .build/contracts/spec-013-runtime-cycle/tmpi1u8hyk5/macos-dynamic --host-build .build/contracts/p08-scoped-host-ezcy1qan --resume-from COLLECTION_BUILD --select-family so06-erasure-closure --select-family so06-closure-erasure
```

Selections are explicit/repeatable family names; `runtime` and
`so06-native-exclusivity` select their respective complete invocation groups.
Union/carrier families are `so06-union`/`so06-carrier`; erasure families are
`so06-erasure-optional`, `so06-erasure-tuple`, `so06-erasure-generic`,
`so06-erasure-closure`; simple pairs use their stem without positive/negative.
Compiled-input changes require full collection instead of focused reuse.

Frozen source identities:

| File | SHA-256 |
| --- | --- |
| `scripts/contracts/check-spec-015-counter.py` | `8c92a7a7d76e601f990ef02609e39abe914d98d80fd3ed7881ceffa3a9e39c95` |
| `scripts/contracts/p08_check_collection.py` | `a8cb742960af3929c0761d049b4ab232a6024a49393d79cb8268bf7da52862f2` |
| `scripts/contracts/test_p08_check_collection.py` | `4d451e9e15740e7ebae133e0a9eb47fd566580e5aa05b1d003f5beb5c8493f1d` |
| `scripts/contracts/run-spec-015.sh` | `b3aa66b35fc2553ea0887e1eb830abbb27ef24d1aef88f544efaf7fde1fbae08` |

Validation: `python3 scripts/contracts/test_p08_check_collection.py` passes twelve
tests; Python AST parsing, `bash -n scripts/contracts/run-spec-015.sh` and scoped
`git diff --check` pass. These are harness mechanics checks, not compiler/runtime
or P08/fit evidence. Baseline collection, grouped corrections, all remaining
registered cells, images, nine SO criteria, HC-RD-003 and P08/fit remain open.

## Bundled setup correction — B01–B03

The [independent source review](p08-suite-collection-source-review.md) at
`170f93d3` found generation/dependency omissions in legacy proof, unconditional
target compile claims and unguarded observation-oracle drift. This coherent
post-freeze setup correction **consumes cycle 1/2** of the current two-cycle
batch. Productivity is pending independent focused rereview. Historical budgets
stay closed; the two-consecutive-unproductive guard persists. Baseline collection
still follows once the harness is qualified, collecting routine failures without
per-error user stops. Their grouped correction/focused validation belongs to
cycle 2; this setup step does not invent a separate zero-repair gate.

- **B01:** Before any legacy import, all maintained compiled/preparation Swift
  inputs and lowering schema/source match `cab1c415`. All nineteen preparation
  commands match the immutable packet and must succeed. Historical runtime and
  host receipt hashes are pinned; runtime's transitive core receipt, compiler,
  macro and MacroSupport identities are exact. The driver verifies the actual
  core receipt hash and MacroSupport bytes in addition to existing compiler,
  macro and imported module/artifact checks. Preparation source checks also apply
  to actual command tokens, so an omitted inventory entry cannot evade them.
  Source/generation/dependency drift rejects this narrow import; unchanged current
  preparation is no longer treated as sufficient historical equivalence.
- **B02:** Target compile evidence and `objects.list` require every preparation
  check, the counter model and every declared object. Failed, blocked or missing
  requirements yield an unavailable statement and remove any inherited inventory.
  Partial/copied objects alone do not establish success.
- **B03:** Runtime observations now use finite helper-evaluated oracle data,
  prerequisites and evidence path bound into their identities. Reuse checks require
  exact single occurrence; summary checks require positive assertions/zero
  failures. `runtime-summary` belongs to `runtime`. Changed unselected observations
  are rejected, and an unselected old failed observation cannot upgrade from reused
  evidence. Complete focused receipts now require **schema 2**; initial schema-1
  receipts cannot qualify observation reuse. Baseline matcher tuples remain unchanged.

Commands above remain applicable. Validation:
`python3 scripts/contracts/test_p08_check_collection.py` passes **20 compiler-free
tests**, including generator/preparation/compiler/macro/dependency drift,
unavailable target inventories and the unselected runtime-observation reproduction.
Python AST parsing, `bash -n scripts/contracts/run-spec-015.sh` and
`git diff --check` pass. No actual compiler, runtime, suite, formatter, target image,
hardware operation or delegation occurred. Source fixtures/flags/registered
384/202 compiler, five native and thirteen-per-route reuse controls are unchanged.

Current setup freeze hashes (shell forwarding remains the initial hash):

| File | SHA-256 |
| --- | --- |
| `scripts/contracts/check-spec-015-counter.py` | `17a7fa14e72707c1bc29003e6b1a13ddf5134f2098f54f84dab9c5073c88428b` |
| `scripts/contracts/p08_check_collection.py` | `443af9f5abdb872a0c6f4c3efee8ec96a170f96aba941e6fa890319636942152` |
| `scripts/contracts/test_p08_check_collection.py` | `88eecedd1fbf2dc328cbb0d43da3ef9da402f670b50b90546aeee9b66e5940da` |

Independent rereview, baseline whole-suite collection, grouped suite corrections,
focused aggregate evidence and all previously open P08/fit obligations remain
pending. Source mechanics tests do not establish Swift or target conformance.

### Same-cycle rendered diagnostic parser refinement

The [focused setup rereview](p08-suite-collection-setup-rereview.md) at `6426d120`
closes B01–B03 and identifies the sole rendered-gutter parser issue. The helper
now separates located primary diagnostics from numbered Swift source excerpts
and recognizes gutter error repetitions only when they exactly match the active
primary error. Unlocated/unrecognized errors, wrong primary sites/messages,
unpaired gutter errors, crashes and invalid exits still fail the structured
oracle. No baseline tuple matcher or corpus registration changes.

The regression reads the preserved actual closure-negative log: two primary
errors/four textual `error:` occurrences. A representative positive nonzero code
tests its recorded nonzero class; it does not invent the unknown historical
numeric exit. Negative mutations and source excerpts containing diagnostic-shaped
string literals are covered. **22 compiler-free Python tests**, Python AST and
whitespace checks pass. No compiler/suite/runtime/formatter/delegation occurred.

This remains the same productive coherent pre-run **setup cycle 1/2**; cycle 2
remains for grouped collected-suite corrections. Final focused parser assessment
and baseline collection remain pending without another per-barrier approval gate.
Earlier freeze hashes remain historical; current helper/test hashes are:

| File | SHA-256 |
| --- | --- |
| `scripts/contracts/p08_check_collection.py` | `0dbd112c26d292273444a606ea882b396e57f0501fe626ed713b94421aa9c105` |
| `scripts/contracts/test_p08_check_collection.py` | `0df3e4c3b790569dc670d05ebbaa1fc9a27d4944c18a8a6946679f5950d1af3d` |

Driver/shell identities, historical budgets, two-unproductive guard, P08/fit and
all open contract/platform obligations remain unchanged.
