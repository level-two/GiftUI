# Independent Native cold Static candidate design review — 2026-10-17

**DESIGN PASS: proceed with the already authorized bounded candidate and early
actual cold screen.** Reviewed `2f1beed0` /`4531257d`, the
[design](../../../../../../docs/implementation-designs/spec-015-p08-native-cold-static.md),
[compiler controls](p08-native-strict-construction-probe.md), current model/root/
Static owning source and accepted ADR-036/039 plus SPEC-013/015. No additional
human approval is needed for this internal mechanism. There is no source,
zero-heap, resource-fit or P08 completion claim; the confirmed failure remains
until actual candidate evidence replaces it.

## Contract and mechanism

The concrete fixture owner, nongeneric registration control and separately typed
identity slots are a replaceable storage realization. Accepted authority requires
stable actual typed backing, generic scope/read domains, precise lifetime unions,
checked ownership/registration and bounded costs; it does not prescribe a generic
owning constructor or private `InlineArray` representation. Keeping contiguous
`InlineArray<2, CounterOwnedModel?>` and lending its actual `MutableSpan` avoids a
tuple-contiguity or raw rebinding assumption. Two models, four claims, two pins,
two registrations, zero capture and existing capacity/error boundaries remain.
This is not a new owner protocol or a second action/coordinator algorithm.

Current owning definitions are in `StaticObservableModelStorage.swift` and
`StaticObservableRootAdapter.swift`; registration storage, report callbacks and
root scope are together in `ObservableStateRootScope.swift`. Current
`ObservableModelScope.withRead` creates generic read slots separately. The note
correctly includes all these potential cold causes rather than wrapping an
unchanged generic owner and claiming the allocation disappeared. The target
bridge owning file exists as listed. Its concrete source diff still must identify
any compiler-required forwarding file within this same mechanism.

Serialization is permissible only while retaining source access control:
`@usableFromInline` internal helpers may support serialized checked bodies;
unchecked scope/pointer/provenance construction must remain unavailable to source
clients. The synthetic `ProbeScope` has package-visible construction for its
isolated experiment; that is not permission to copy its visibility into GiftUI.
The design explicitly stops if specialization requires opening an unchecked
constructor or changing the normative generic scope contract. Fresh constructor/
owner-independent escape negatives must verify the actual implementation boundary.

The complete callback borrows must include actual model slots, ownership,
registration control, typed identity records and report backing. Descriptor
lifetime alone is insufficient. Existing Escapable results, borrowedRoot/
borrowedScope propagation, all14 loans, Optional host destination and complete
G/C/R/H/model/root/semantic/value/control/activation lifetime unions stay. Splitting
identity fields must preserve report attachment/detachment, generation exhaustion,
matching, candidate/live state and synchronous-report exclusivity. Initialize each
acquired concrete field once, unwind only the acquired prefix in reverse, preserve
first failure, release registrations/reports/pins/claims before backing, and account
padding/temporaries once. These are explicit candidate invariants, not deferred
optimization choices. No simultaneous initialized generic and concrete owner may
share a region.

## Evidence and staged gate

The compact read-only verifier passes all nine probe source/command/import/
disassembly/result hashes and recorded failure flags. Concrete pair/InlineArray
and span-to-generic-scope variants observe zero captured cold events; generic
variants still allocate. Actual loaded system Swift UUID is preserved. These
small controls use a Copyable model, omit real registration/read/action graphs
and retain observer coverage limits. They prove a plausible compiler mechanism,
not actual noncopyable CounterOwnedModel initialization/move/destruction, complete
allocation absence or Native/Pi stack fit.

The specified early screen is sufficient to decide whether to spend corrections:
compile only changed owners and the selected fixture with unchanged pinned flags;
enter actual Static host construction and first actions in a fresh process before
common-graph warmup, then identical reuse; bind code/events to loaded runtime and
source/object identities. Include actual read-slot, resolver/gesture/target/
dispatch costs and separately inspect cold common Static framework paths. An
unresolved public-hook blind spot cannot be counted as zero. A trace-free diagnostic
may screen feasibility only with exact workload/count equivalence; ordinary full
attribution remains required before acceptance. Warmup and metadata exclusions
remain forbidden.

Run relevant lifetime/Optional/copy/exclusivity, original-loan, initialization-fault,
early-return, stale generation, shutdown/report and backing-last checks around
that candidate. A cold/profile allocation or safety failure stops broad
collections/images and records the exact cause before a correction. No full suite
is required before this early screen. Later affected four-profile evidence and
strict image handoffs must use the established focused/reuse rules and fresh actual
resource proofs; current accepted nRF evidence cannot certify changed shared code.

## Boundary

One new candidate, at most two corrective cycles, is the separate authorized
activity. Probe controls consume neither application candidate nor corrective
cycles. All historical limits remain closed. The allowlist and only necessary
visibility forwarders are adequate; new algorithms, unchecked capabilities,
compiler-policy changes, reduced workload/loans or a contract/scope change stop
for the stated review/escalation, not silent expansion. No implementation mechanism
beyond this candidate is approved here.

After a passing candidate screen, remaining actual zero-heap coverage, matched
Dynamic/header/temporary accounting, Native/Pi library/stack/physical ledgers,
caller/criterion reconciliation and independent P08 exit still apply. Optional
unrelated tuning is outside this activity. This read-only design/evidence review
ran no compiler, probe/workload, build or target/hardware execution. Governance,
local links and whitespace pass; five external edits and pycache remain untouched.
