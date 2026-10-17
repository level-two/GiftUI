# Remaining P08 acceptance campaign — 2026-10-16

This is an evidence execution checklist for the existing finite counter, not a
new design/source allowance. The [new nRF image review](p08-current-firmware-final-fit-independent-review.md)
accepts its complete resource proof. Run the following work sequentially, freeze
receipts after each coherent result and preserve all external edits. No deployment,
flashing or connected measurement is included.

Completed Pi collection/image step: the [current result and independent review](p08-current-pi-collection-image-result.md)
records full409/409 and one supported ARMv6 hard-float early image. Step1 below is
now a preserved executable recipe, not an instruction to rerun it. Next execute
Step2's missing Native families, then Step3 allocation/stack and Step4 exit ledger.
Pi complete stack/allocation/fit remains in Step3; link success does not close it.

Completed Native missing-family step: the [independent combined coverage result](p08-current-native-combined-coverage-result.md)
qualifies all426labels/profile using384fresh selected +19matching preparation
+23retained labels. Step2 is now a preserved recipe, not a rerun instruction;
raw focused receipts stay incomplete/aggregate-false. Next is Step3's matched
allocation and Native/Pi stack/physical ledger, then Step4 caller/exit reconciliation.

Authority is [SO-01–09](../../../../../../docs/iterations/iteration-003-review/rfc-015-p08-handoff.md#ordered-bounded-tasks),
[delivery allocation](../../../../../../docs/iterations/iteration-003-review/rfc-015-delivery-allocation.md#p08-minimum-complete-dependency-path),
[P08/R07](../../../../../../docs/iterations/iteration-003-review/rfc-014-implementation-plan.md#ordered-work-packages),
SPEC-013 S13.1/S13.2 and SPEC-015 S15.1/S15.2, amended only by ADR-040.
The [focused-campaign rules](../../../../../../docs/iterations/iteration-003-review/rfc-014-implementation-plan.md#focused-testing-campaigns--maintainer-instruction-2026-10-15)
permit current focused plus exactly qualified retained evidence; they do not turn
an incomplete receipt into a complete suite. P10 owns `scripts/test.sh
all-hardware-free`; do not run that broad gate merely to finish this P08 slice.
Use the applicable Pi toolchain/build skills for the commands below.

## 1. Refresh the actual Pi route and early image

The last complete Pi receipt `.build/raspberry-pi/contracts/p08-counter-x8bt078_`
is stale in 17 recorded inputs, including compiled counter/storage/host/corpus
sources. Its old full pass/image cannot qualify the current counter. Use the
existing qualified runtime/host recipes; their noncompiled-source qualifications
must still validate, not be relabeled as fresh compilation:

```sh
scripts/contracts/run-spec-015.sh --profile raspberry-pi-armv6 --corpus rfc-014-counter --runtime-build .build/raspberry-pi/contracts/spec-013-runtime-cycle/tmpsb8yw4yu/raspberry-pi-armv6 --host-build .build/contracts/p08-scoped-host-hzs5q7za --collect-failures
scripts/raspberry-pi/doctor.sh
scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6 --counter-build <fresh-complete-Pi-counter-directory>
```

Do not add focused/legacy/resume options to the Pi refresh: all affected control
families and preparation are required. Require a complete successful receipt
(expected current inventory 409), exact target/compiler/flags/artifacts and
positive/negative classifications. The build's strict handoff rejects incomplete
or stale inputs. Preserve unstripped ELF/map/input receipt and reports under
`.build/raspberry-pi/`; inspect ARMv6 hard-float and actual LOAD/sections/rooted
allocation/stack. Dynamic storage uses the Dynamic profile even though the early
Linux executable statically links its standard library. This is compile/link
evidence only. The external `--build-system native` addition is after the counter
branch's `exit 0` and does not affect these commands.

## 2. Close the Native control omissions without repeating valid runtime work

Current Dynamic `.build/contracts/p08-counter-dyq5u3vb` and Static
`.build/contracts/p08-counter-w700p_zi` each have 42 passing checks and zero current
input-hash drift. They execute 1,736,244 /1,736,320 assertions, with all 13 reuse,
five exclusivity and two projection controls. Retain those current runtime results
while their full dependencies/compiler/flags/artifacts remain exact. Their 384
`not-run` entries per profile are still missing. Prior controls compiled changed
counter sources, so the noncompiled runtime/host qualification does not validate
them. File-hash drift alone does not establish that every probe's semantics changed.
All384 appended probe suffixes are byte-identical to the last full Native
receipts (`_hfz7w26` Dynamic / `apvcuupb` Static; baseline source `7b43e199`),
but the active Native prefix is not unchanged: the unguarded Static session
constructor, the `!hasFeature(Embedded)` Dynamic session constructor, and shared
CounterControl/CounterPipelineOwner storage/retirement changed. No per-label
semantic noninterference qualification for that changed prefix has been proved
here. Existing exact reuse rejects17 input drifts in each complete predecessor;
therefore this plan refreshes the missing families rather than asserting their
old outcomes apply. Never use these partial receipts as `--resume-from` (the verifier requires
a complete exact-input predecessor).

Run precisely their missing complete families with fresh preparation through the
existing driver. This executable command recipe selects the labels from the
frozen current receipts rather than guessing a shortened list:

```python
import json, pathlib, subprocess
for profile, prior_dir in [
    ('macos-dynamic', '.build/contracts/p08-counter-dyq5u3vb'),
    ('macos-static', '.build/contracts/p08-counter-w700p_zi'),
]:
    prior = json.loads(pathlib.Path(prior_dir, 'result.json').read_text())
    missing = [c for c in prior['checks'] if c['status'] == 'not-run']
    assert len(missing) == 384
    families = sorted({c['family'] for c in missing})
    command = ['scripts/contracts/run-spec-015.sh', '--profile', profile,
               '--corpus', 'rfc-014-counter', '--runtime-build', prior['runtime_build'],
               '--host-build', prior['host_build'], '--collect-failures', '--fresh-focused']
    for family in families:
        command += ['--select-family', family]
    subprocess.run(command, check=True)
```

The 22 missing families are union96, carrier192, four erasure families16 each,
and sixteen two-check families (host copy/backing, use-after-consume, owned return,
private construction/extraction, arbitrary factory, Optional/tuple/generic/closure
escape, Sendable, static overlap, Dynamic host backing, task and async). Preserve
positive twins and exact rejection causes. Combine the two fresh partial receipts
with the retained 42 checks in an explicitly reviewed per-label coverage ledger;
compare source/module/flag/compiler identities and every prerequisite, and account
for every registered label. Keep raw `collection_complete=false` unchanged. If
identity or applicability fails, refresh only the affected complete family and
prerequisites, broadening to the registered full profile if coverage cannot be
established. The frozen source requires no new compiler/lifetime experiment.

## 3. Matched Native allocation and complete physical/stack ledger

The [six matched observations and attribution](p08-native-allocation-findings.md)
pass collector/replay but prove an actual Native Static first-use heap allocation.
Independent review and an explicit contract-versus-implementation decision are
next. Coverage of direct-zone/VM/temp and complete Native/Pi bounds remain open;
no further matched rerun is needed for this counterexample.

SO-08 explicitly requires matched Dynamic costs and Static zero heap, not only
nRF symbol absence. Reuse the exact current Native profile `.o` files, flags and
link command from the receipts above. Replace only the generated `Main.swift`
entry in a new measurement directory (preserving every frozen original file)
with a tiny driver calling the existing C export
`uint32_t giftui_rfc014_counter_entry(void *writer)` with NULL. No application
change is needed. The export runs the selected finite route and its cleanup;
retain/check its assertion count. Keep Dynamic and Static workload/profile,
compiler/optimization, endpoint and window identical except the selected profile.

Use the established `Tests/ContractFixtures/SPEC013/Instrumentation/AllocationInterposer.c`
(begin/end/count/peak/bookkeeping/saturated exports), compiled into a measurement
library with `xcrun clang -std=c11 -Wall -Wextra -Werror -dynamiclib`, then link the
entry and original Swift objects with the pinned Swift compiler. Link and record
the dylib/rpath explicitly; preserve commands and hashes. Begin before the first
cold entry and end after cleanup, then print measurements outside the window.
Do not warm away cold allocations. A second identically measured invocation can
qualify reuse separately. First validate interception with an intentional known
allocation. The existing interposer covers malloc/calloc/realloc/free only: audit
reachable Swift/libc allocation routes (including posix_memalign, aligned_alloc,
malloc zones and temporary allocation); extend only the diagnostic wrapper or
supply explicit accounting for uncovered calls. No saturation, double counting or
untracked route may be silently treated as zero.

Report allocation count, peak requested/reserved bytes, retained/live bytes,
allocator rounding/bookkeeping, Swift array/header/control extents and temporary
peak separately from profile-owned payload. `malloc_size - requested` alone does
not measure Swift headers already included in the request. Distinguish counter
oracle/common graph allocations from selected Dynamic host storage; the common
Static graph runs in the Dynamic route too. Do not subtract an unmeasured baseline
or report the whole process as the profile's allocation. Attribute any Static
allocation before claiming zero; oracle/library allocation needs an explicit
scope/physical charge, not an exception inferred from its name.

Complete the already required native/Pi feasible-path stack and storage ledger
from their actual objects/images: construction, admission, semantic/layout/Canvas/
render, offer/finalization, action/refusal/injected failure, retirement/cleanup,
repeated sessions and actual outer caller. Include retained Optional/tail padding,
all14 loans, temporary/copy homes, bounded recursion/callback families and library
callees; validate outgoing arguments/alignment/tails at actual sites. Reuse source
rank/lifetime reasoning only where identical, not nRF byte counts or the Thumb
instruction decoder for ARMv6/arm64. Record user-stack/thread/signal assumptions
and actual applicable process stack limit; OS IRQ uses a separate kernel stack,
so do not import Cortex-M IRQ nesting into Linux/macOS. A measured high-water is
supplementary, not a complete bound. No new 27,648-byte or 262,144-byte limit applies
to these hosts merely because nRF uses it. Preserve their existing resource limits;
if no applicable limit or bound is established, report the exact unresolved item
rather than zero or fit. Include linked sections and text/resource/capability/
backend/host exclusions once. The accepted nRF proof already closes its own
stack/IRQ/RAM/flash/rooted-allocation portion; do not rebuild it for unrelated docs.

## 4. Freeze the P08 exit packet and exact residual handoff

Reconcile the existing SO-01 D01–D34 caller table/index against current adopted
symbols and hashes, with an actual per-change necessity/evidence/disposition.
Carry the final physical inventory, initialized-prefix/backing-last/Optional
retirement, pair exchange, reuse and independent semantic/action/pixel controls
into the P08-applicable nine-criterion matrix. Link all four route receipts, their
omissions/reuse qualifications, Pi/nRF early images and Native/Dynamic resources.
This is current-source reconciliation, not a new universal caller survey or scope
expansion. Refresh changed shared compatibility dependencies only where needed.

The accepted I4-07/P09 residual remains the actual legacy
Dynamic/StaticSignalAnalyzerActionDispatcher.make model/root/target/alias/owned
ActionModelTargetAccess integration and actual owned returned/copyable positive +
scoped-record rejection evidence. Retain the real shared owned dispatcher and six
operation-consumer compatibility evidence in P08. Transfer every other exact
unmet full-RFC row with source identity and owner, without marking it passed.
P09 analyzer migration, P10 broad functional gate, P11 complete two-application/
connected timing/resources and P12 cutover/conformance transitions remain their
existing packages. Current counter safety, cleanup, allocation and fit cannot be
transferred merely because evidence is difficult. Request the separate read-only
Strong P08 exit review after these concrete obligations have dispositions; that
review decides P08/R07/T8.1, not full Specification implementation or iteration exit.
