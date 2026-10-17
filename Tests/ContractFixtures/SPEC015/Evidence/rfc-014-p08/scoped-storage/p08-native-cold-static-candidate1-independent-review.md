# Independent Native cold Static candidate-1 failure review — 2026-10-17

**Counts/replay PASS; strict zero-heap FAIL; candidate unaccepted.** Reviewed
implementation `9c19a879`, result `6b98ba27` and baseline `93f6ecc7`. The
[failed screen](p08-native-cold-static-candidate1-result.md) is sound evidence of a
failed initial candidate. **Corrective cycles remain0/2.** No restoration,
source candidate, compiler/workload run, broad collection or image build occurred
in this review; the additional silent replay is offline event analysis only.

## Verified failure

The immutable28-member archive SHA
`f9e421170d185a607fed23bd766d8bd232f608e17f3cfbbdf13352abc5ced3da`
(1,735,397 bytes), member/preparation/run hashes and derived verifier results
validate. Independent offline replay of the preserved silent binary stream also
passes exact accounting/chain checks. All four process observations are exit0,
with equal cold/reuse counts: baseline-host-first, silent and ordinary host-first
1,733,216; registered ordinary1,735,019. Recorded capture/replay error flags are
zero. Successful execution/count preservation is not allocation conformance.

The registered candidate retains the original selected action families unchanged:
admission witness2/32, gesture/Interaction5/208, pipeline dispatch witness2/32,
and target-dispatch metadata2/64: **11 allocations/336 requested=usable bytes,
64 retained through reuse**. The linked admission still calls
`swift_getWitnessTable`; actual generic gesture/target-dispatch bodies still form
metadata. `@inlinable` made bodies available but did not deliver the required
specialization at these `-Osize` calls. This is no proof of impossibility.

The host-first silent process supplies independent cold counterexamples:

- Group0 allocates16 requested/usable bytes, retained through reuse, on
  `SwiftTLSContext::get → swift_beginAccess → P08TypedBackingOwner.physicalFacts →
  audit → p08PrepareStaticHost`. The frozen call at `0x1001138e8` reaches helper
  `0x10016a18c`, whose tail branch targets `swift_beginAccess`. The captured mutable
  `rows`/nested `object` helper is an investigation seam, not an established fix.
- Groups1–2 allocate16+48 bytes through actual `TextResourceValidator.validate`
  in mandatory `CounterHostAssembly` validation. Their full chains contain no
  print/counterTrace frame. These are framework costs, not the rejected-input
  oracle literal. Other observed cold profile paths remain unbounded.

The silent process's action subset is16/512 because common-graph prewarming is
absent; it is a separate observation, not extra events to add to ordinary11/336.
Likewise its1,465 cold allocations are not a fully attributed profile charge.
The two reuse literal allocations136 requested/160 usable remain explicitly
fixture-attributed without exempting all code beneath CounterHostCorpus. Hook
blind spots may hide further costs but do not erase these positive witnesses.
Current SPEC-013/015 includes cold construction/action/validation, with no TLS or
metadata exception. No accepted zero-heap result or whole-resource pass follows.

## Restoration disposition — recommended, not executed

Restore only the22 maintained candidate files byte-for-byte from `93f6ecc7`.
The exact [allowlist and before/after hashes](native-cold-static-candidate1-review/restoration-plan.json)
contains16 framework sources, four SPEC015 fixture sources, the SPEC010 layout
probe and its collector. All22 working files currently equal `9c19a879`; none
intersects the five external edits. Restoring the layout probe/collector together
returns their original representation/export-count pair coherently.

Before restoration, recheck every file against its candidate hash and preserve
all external per-file bytes/diff, untracked pycache and any newly arrived edits.
Use `git restore --source=93f6ecc7 --worktree -- <only the22 listed paths>` after
that check. Do not revert the entire implementation commit: it also contains
experimental tooling/evidence that must remain. Do not reset the tree, stash other
work, remove builds, or restore documentation/evidence. Afterward verify all22
baseline hashes, unchanged external diff/bytes, preserved commits/packets, and an
exact staged22-file restoration diff before its separate commit. Record that the
current maintained source is restored baseline and the measurements still name
their frozen candidate. Restoration and design review reset no allowance and
claim no fresh conformance; this report performs neither restoration nor adoption.

## Next bounded design is within strict-implementation authorization

A design revision for the **actual complete cold pipeline's specialization and
exclusive borrows** is within the user's strict-contract objective if it preserves
algorithms, public generic scopes, original14 loans, capacities, identity/lifetime/
cleanup and runtime enforcement where static proof is unavailable. More affected
files, larger source effort or a difficult compiler boundary alone do not create
an architectural decision or require another human permission gate.

The existing reviewed source allowlist did not include text validation, generated
resource access, semantic expansion or raster owners beyond visibility forwarding.
Therefore revise and independently review the concrete internal design/file map
before a grouped correction; do not silently treat those substantive edits as
forwarders. This is implementation-design review within the existing activity,
not approval of a new architecture or a new candidate/repair budget.

The next design should provide one finite source→emitted-call map for original
root/read/action, physical-facts exclusivity, text/package validation, resource
payload access, semantic expansion and native raster/lifecycle paths observed in
the existing cold stream. Select targeted concrete owning forms and exact body
specialization/serialization at those existing boundaries, not blanket annotations.
For `physicalFacts`, propose an equivalent static-borrow/owned-facts structure
without captured mutable accumulation where actual proof supports it; preserve
reentry/overlap rejection and all validation results. Actual emitted calls must
show the claimed effect. Repairing only the11 action events or only TLS cannot
pass the already observed complete cold boundary.

Keep the same host-first cold/reuse protocol, pinned flags/runtime, oracle counts,
ordinary attribution and public-hook/VM/temp coverage limits. Establish the actual
mechanism at the affected call sites, then use one coherent corrective cycle and
its smallest complete cold/lifetime/semantic screen. Stop broad collections/images
on failure. Remaining cycles stay explicitly accounted, not renewed by restoring
the baseline. No warmup, exception, disabled exclusivity, missing library cost,
reduced observations or silent workload alteration is a solution.

Only a real change to normative API/lifetime/ownership, capacity/identity/error
semantics, algorithm/architecture, compiler policy or resource contract requires
upstream decision. If strict conformance cannot be achieved inside those rules,
report the exact conflict rather than asserting that such a conflict already
exists. No concrete follow-up source diff is approved by this review alone.

P08/R07/T8.1 remain open. Complete allocation coverage, matched Dynamic/header/
temporary costs, Native/Pi library/stack/physical ledgers, caller/criterion mapping
and independent exit remain required; P09–P12/I4-07 allocations and existing nRF
proof stay qualified historical evidence. Governance, local links and whitespace
pass. Five external files and pycache remain untouched.
