# Independent Native Static allocation blocker review — 2026-10-17

**Measurement premise PASS; selected Native Static zero-heap requirement FAIL.**
Reviewed `5e449895`, the [findings](p08-native-allocation-findings.md),
[compact verifier/manifest](native-allocation-attribution/manifest.json), diagnostic
observer/driver and pinned linked instructions. No broader attribution, stack
closure, workload rerun, source experiment or build occurred in this review.
P08/R07/T8.1 remain open; the accepted nRF resource proof and qualified four-route
control evidence remain separate valid results.

## Evidence and exact scope

The33-member compact archive hash and all analysis/member hashes validate;
`python3 -B native-allocation-attribution/verify.py` passes. All201 current input
hashes and all75 original raw measurement artifact hashes also match. Static image
SHA is `6c3c3c6b1d1ba5a0d57def8bb7e367484f438f15ffd0eec17afddfe22e6414f3`.
Independent reading of each Static binary event stream reproduces the selected
subset: **11 successful allocations,336 requested =336 usable bytes,112 usable
simultaneous peak,64 retained after cold and after reuse; zero new subset
allocations in reuse**, identically in all three processes. Those are observed
client storage values, not an allocator arena or complete peak/cold bound.

The positive counterexample is adequately attributed. Each retained full chain
contains the selected actual `p08CounterHost` lifecycle and admission/gesture/
Interaction/dispatch code, with no `counterTrace`, print or debugPrint frame.
The admission witness call precedes the separately identified print preparation;
its linked stub binds `swift_getWitnessTable`. The observer calls real
`malloc_type_malloc`, records only nonnull results at outer hook depth, measures
`malloc_size`, and captures the chain to the C driver without invoking Swift.
Allocation/retirement identity and replay conservation support the subset, rather
than inference from an unresolved symbol's presence.

Loaded runtime identities are the actual system images reported by dyld:
`/usr/lib/swift/libswiftCore.dylib`, UUID
`83794fb3de9b3d23ab5e2c1d5d30f134`, and `libsystem_malloc`, UUID
`d969a9073e43395193658c2db3812e9d`. A compiler-bundled runtime cannot substitute
for those bodies or justify excluding their heap use. Selected entry/results and
original object/source identities are pinned; observer allocation is not credited
as selected Swift runtime allocation merely because the observer is on the stack.

The excluded2/96 host-corpus array-metadata events are correctly outside this
narrow rejecting subset. Conversely, the preceding common graph's952 metadata/
witness events prewarm the selected host, so11/336 is already a prewarmed positive
subset. It cannot establish zero construction heap, total first-use cost or an
upper bound for an exception. The demonstrated direct-zone callback blind spot,
raw VM/temp/coroutine/cache/arena gaps may conceal additional costs; they cannot
turn these witnessed successful allocations into zero. Reuse-zero for this
subset does not satisfy a contract that includes first construction and actions.

## Exact documentary erratum

The findings table's return offset `0x1393b4` is immediately within
**`CounterPipelineOwner.dispatch(CapturedAction)`**, whose linked body starts at
`0x1001392e0`; `applyAdmittedWork` is an enclosing caller, not the immediate
symbol at that offset. The captured stack and linked body agree. The table label
is corrected separately; all11 events,336 bytes and other numbers are unchanged.
Original measurement/analysis archives remain immutable.

## Contract finding and required decision

[SPEC-013](../../../../../../docs/specs/spec-013-runtime-profiles.md#performance-requirements)
requires Static runtime construction and every later operation to allocate zero
heap. Its accepted runtime-derived amendment additionally names construction and
every later phase and requires rooted proof. [SPEC-015](../../../../../../docs/specs/spec-015-host-configuration.md#performance-requirements)
explicitly includes Static action dispatch and fact admission. Native Static is
supported; no accepted clause exempts ordinary first-use generic metadata or
witness-cache allocation. [ADR-040](../../../../../../docs/adrs/adr-040-counter-physical-sram-budget.md)
changes only counter nRF RAM/stacks and explicitly preserves heap limits. Thus the
observed actual admission/dispatch allocations violate the present requirement;
there is no diagnostic-coverage reason to defer that finding as merely unknown.

The minimal reviewable decision is to select one bounded path:

- **Keep the existing contract:** authorize a separately bounded implementation
  design/attempt to remove actual Native Static first-use runtime heap, including
  construction/admission/dispatch, then requalify. This review proposes no helper,
  warmup or implementation mechanism and renews no exhausted allowance.
- **Change the Native Static contract explicitly:** authorize preparation/review of
  a precise Native-only generic metadata/conformance first-use exception, its
  accounting/limits and acceptance evidence. It must include first actions and
  complete cold costs; a constructor-only clause or a336-byte budget is unsupported.
  Retain zero heap for the agreed remaining scope and Embedded Static guarantees.
  This requires accepted authority/Spec reconciliation before acceptance, not a
  reviewer waiver or a full resource-pass inference from warm reuse.

Neither option is approved by this report. The maintainer's decision is needed
because the current measured behavior and accepted contract conflict, not because
ordinary evidence collection needs another permission gate.

After that disposition, the remaining ledger still needs matched Dynamic actual
header/control/allocator/temporary accounting and scoped exclusions; public-hook
coverage closure; actual Native/Pi construction/live/action/failure/cleanup/
callback/recursion and library stack bounds; once-only linked/storage/host charges
and process/signal assumptions; current caller/criterion reconciliation and
independent P08 exit. Native must use its identified system-cache runtime bodies;
Pi must account for its pinned ARMv6 image and required dynamic libraries. No
unavailable library cost is zero and no nRF ceiling transfers to these hosts.
P09–P12/I4-07 residuals do not absorb required current counter correctness or fit.

Local links, whitespace and governance checks pass. Five external source/CMake/
build-script edits and existing pycache remain untouched; no source or limit was
changed and no target/connected or lifecycle completion is claimed.
