# Candidate 1 actual cold screen — 2026-10-17

**Counts/replay PASS; strict Static zero-heap FAIL. Candidate unaccepted and not
adopted.** The [independent failure review](p08-native-cold-static-candidate1-independent-review.md)
confirms this result and the exact restoration/design boundary; no restoration
has run. Source candidate `9c19a879` remains frozen for review; no corrective
source change or restoration occurs in this packet. **0/2 corrective cycles
used.** No full collection, image build or hardware execution follows this fail.

The mechanical run used
`.build/contracts/p08-native-cold-static-screen-candidate1-current/run/`, wrapper
`.build/contracts/p08-integrated-activity/20261017T083510766034Z-p08-native-cold-static-candidate1/`.
All four processes returned exit0. Frozen baseline, silent candidate and ordinary
host-first counts are1733216 cold/reuse; registered candidate route counts are
1735019 cold/reuse. Replay rejects no flags: foreign thread, saturation,
truncation, bad chain, I/O, allocation failure and unknown free are all zero.
These establish observation/workload integrity, not allocation conformance.

## Original eleven allocations remain

The ordinary registered candidate still contains **all11/336 requested bytes
(336 malloc usable),64 bytes retained through reuse**, on the same source action
families as the [accepted baseline counterexample](p08-native-allocation-independent-review.md).
No original action family is eliminated:

| Family | Candidate groups | Count / requested bytes | Return PCs, image-relative |
|---|---|---:|---|
| Pipeline admission resolver witness |7821–7822|2 /32|0x1385c0|
| Gesture and Interaction metadata |7823–7827|5 /208|0x6defc,0x6df18,0x710cc,0x710dc|
| Pipeline dispatch witness |8331–8332|2 /32|0x138b84|
| Runtime target dispatch metadata |8333–8334|2 /64|0xa0bf4|

Actual code still calls the generic `ExecutionGestureAdapter.down` and
`RuntimeRecordInteractionBridge.dispatch` bodies. Down obtains metadata for
CapturedAction, Optional, PointerActionCapture and PointerGestureOutcome;
Interaction's resolver obtains hit/optional metadata. Dispatch obtains
ObservableStateRootTargetAccess metadata. Admission still calls
`swift_getWitnessTable`. The added `@inlinable` bodies did not produce the needed
specialization at these actual `-Osize` call sites. This is measured codegen,
not a claim that forced inlining could never work.

The host-first silent process sees a broader **16/512-byte** action subset in
those same four families because the ordinary graph's prior warmup is absent.
Its family counts are3/80,9/336,2/32,2/64. Those totals overlap the ordinary
counterexample conceptually; they are separate process observations and must
not be added together.

## Independent cold construction failures

Silent group0 is **one16-byte requested/usable allocation retained through reuse**:

```text
malloc_type_malloc → swift_slowAlloc → SwiftTLSContext::get → swift_beginAccess
  → P08TypedBackingOwner.physicalFacts → outer.audit → p08PrepareStaticHost
  → p08InstallStaticHostPlan → original selected host
```

The return PC is0x1138ec. Instruction0x1001138e8 branches to helper0x10016a18c,
which sets the access arguments and tail-branches to `swift_beginAccess`.
This is actual selected-host physical validation before trace output. It cannot
be excused as logging or warmed away, and disabling exclusivity is forbidden.
The source's captured mutable `rows` accumulator/nested `object` helper is a
concrete structural-access investigation target. Removing this one access is
not proof that the complete path needs no dynamic accesses/TLS initialization.

Silent groups1–2 are **two actual metadata allocations,16+48=64 requested/usable
bytes**, through `TextResourceValidator.validate` from
`CounterReferenceTextInput.validate`/CounterHostAssembly validation. They are
mandatory framework resource validation, not an oracle array or print path.
Further observed metadata stacks reach reference bitmap/outline payload delivery,
semantic declaration-role expansion, host activation/teardown and native raster
fill. Their complete attributable totals are not claimed here; the explicit
counterexamples already reject zero heap. These additional owners are outside
the reviewed root/action source allowlist, beyond mere visibility forwarding.

The [Static construction/every-phase requirement](../../../../../../docs/specs/spec-013-runtime-profiles.md)
and [host validation/performance requirement](../../../../../../docs/specs/spec-015-host-configuration.md)
contain no metadata/TLS exception. The positive allocation counterexamples are
sufficient despite the observer's remaining direct-zone/VM/temp coverage gaps.

## Fixture attribution and limits

Silent cold captures1465 allocations/1738138 requested/1917712 usable bytes;
reuse captures2 allocations/136 requested/160 usable bytes. These totals include
fixture/library activity and are **not** an attributed framework allocation bound
or allocator-arena/header measurement. The two reuse events come from the
three-tuple rejected-input workload literal in CounterHostCorpus at source104,
return PC0x149134. Disassembly allocates0x44 requested bytes per occurrence;
this is the explicit immutable oracle workload input, not blanket exclusion of
anything beneath CounterHostCorpus. Its observation does not excuse the profile
allocations above. Normal successful trace output is separate from these silent
observations; no output suppression changes the acceptance contract.

The silent stream has2685 recorded events,1016 exact full-stack groups,81 maximum
frames and253 retained allocation records. None of these numbers is a complete
heap/stack/physical-fit proof. Native/Pi resource ledgers and P08 exit remain open.

## Durable evidence and next boundary

[Manifest](native-cold-static-candidate1-result/manifest.json) freezes a1.74MB
archive with all four complete groups, PC dictionaries/logs/summaries, original
run/preparation manifests, silent raw binary events and selected actual codegen.
Other large raw event streams remain unchanged at the recorded run directory
with their original hashes. No baseline/preparation/experimental source artifact
was deleted. A redundant expanded analysis serialization exhausted scratch disk;
only that agent-created derivative was removed, then compact shared dictionaries
were used. The preserved input observations are unchanged.

```sh
python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-cold-static-candidate1-result/verify.py
python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-cold-static-candidate1-result/verify.py --replay-silent .build/contracts/p08-candidate1-offline-replay-fresh
```

Both read-only verification and offline exact replay pass; neither executes the
profile. Hashes, counts, flags, original11 disposition and cold TLS/text witnesses
are checked. Source bytes, loaded runtime UUIDs and codegen remain attributable
to the frozen candidate, not a future restored source tree.

**Recommend independent failure review, then restore only candidate1's22 maintained
Swift/active-fixture/layout-collector files byte-for-byte from `93f6ecc7` (its
parent), retaining experimental commits/evidence and all external edits. Do not
restore documentation/evidence or adopt this failed candidate.** Restoration has
not been performed here.

A next scoped design must address the **complete Native cold compiler/runtime
boundary**: (1) compiler-proved exclusive borrows throughout actual construction/
work, preserving mandatory runtime enforcement where proof is unavailable; and
(2) exact specialization/concrete internal representation across host lifecycle,
text validator/generated payload access, semantic expansion and raster paths,
while preserving required generic public scopes. Rooted call-site/codegen probes
must establish those mechanisms before another broad source attempt. The precise
remaining gesture/dispatch generic calls are a plausible local forced-inlining
seam, but repairing them alone would leave independently proven cold failures.
Do not spend either correction on that partial result or blanket annotations.
This is a concrete implementation-scope/design boundary, not a zero-heap waiver,
a claim of fundamental impossibility or an automatic new repair allowance.
