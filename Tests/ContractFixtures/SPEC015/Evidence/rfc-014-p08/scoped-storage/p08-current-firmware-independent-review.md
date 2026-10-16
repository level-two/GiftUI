# P08 current firmware — independent bounded resource review

**Package PASS; actual main-stack fit FAIL / STOP confirmed.** Reviewed commit
`d5829a13`, build revision `f042252f39a167c97c2c30d9fe5ed4b1a5f30029`, maintained
counter source `51cfc960` / SOURCE review `ee10d2f1`. The
[current result](p08-current-firmware-resource-result.md) supports its stated
boundary. No blocking package correctness finding remains. This is an evidence
review, not the independent P08 exit or full Specification conformance review.

SPEC-015 remains implementing; its conformance report remains collecting.
Accepted ADR-035/036/038/039 and SPEC-015 S15.1/S15.2, particularly HC-SO-003,
require actual scoped ownership and measured fit. ITERATION-003 I3-04/I3-05 own
this counter/stack work, preserving ITERATION-001's reference application and
four-configuration validation obligations; full RFC-015 delivery remains I4-07.
No status, scope, contract, resource limit or repair allowance changes here.

## Artifact identity and reproducibility

Independent read-only checks establish:

- The [original manifest](linked-firmware-current/manifest.json), all **65**
  archived members and archive size/hash match. The immutable packet remains
  881,600 bytes, SHA256 `8db18ea94b5c9b1ad41b64759617cd7cb75c4bd5e57e9c7014a36cb56d7f1fdc`.
  Current and archived ELF both hash to
  `e649c5d26a676140b473e8fa1de5b075a479d8282a7f6d69e0034fb215884c38`.
- All **227** `current-source-handoff.json` source hashes match maintained files;
  compiler bytes match the recorded `79ae5c26…` identity. The archived collection
  has **227/227** passing checks, `collection_complete=true`, `passed=true`, no
  focused/prior-collection substitution and no target execution. Its two
  `CounterScopedStorage.swift` predecessor qualifications retain
  `compiled=false` / `original_manifest_current=false`. They qualify excluded
  source applicability, not a fresh full-source predecessor pass.
- The pristine build wrapper exits zero at the recorded build revision. Its
  log and compile commands show all **24** source owners freshly compiled,
  including the 42-source counter owner with actual firmware flags. The counter
  receipt's objects are identity inputs, not substituted firmware objects.
- All **37** selected complete disassembly bodies regenerate byte-for-byte from
  the existing ELF using their archived `argv`. Their symbol-table indices,
  names, STT_FUNC types, values and sizes independently match raw ELF entries.
  The misleading nearest objdump labels do not determine function identity.
- Raw ELF decoding reproduces all **13** selected direct BL sites and all **4**
  little-endian literal plus Thumb PC+4 callback targets. All **160** layout roots'
  **185** recorded body proofs match ELF bytes. The layout and C reservation
  report charges four 34,720-byte slots (**138,880**), with metadata extent
  **16,584** inside one donor and zero additional retained metadata.

The already completed normal doctor receipt was outside the original packet.
It is now preserved separately with its [manifest](linked-firmware-current-doctor/manifest.json)
and [archive](linked-firmware-current-doctor/doctor-receipt.tar.xz), SHA256
`33b8c74710a8a7dbdbbaf37de0b02e6da846b3f78b0a2a290a724baddf4660b7`.
Invocation/result pin the same build revision and exit zero immediately before
the pristine build. Output records Swift 6.4, `nrf52840dk/nrf52840`, Zephyr 4.3.0
and SDK 0.17.4. This preserves prior evidence; no new doctor or probe ran.

The archived ELF program headers independently reproduce registered PT_LOAD
accounting **RAM 170,620 / 196,608**, **flash 403,400 / 1,048,576**, below the
917,504 flash warning. Zephyr's log displays RAM 170,624 because its extent
includes four alignment bytes; this does not change either pass. ELF/header and
attributes support ARMv7E-M, Thumb-2, VFPv4-D16 and VFP-register hard-float ABI.
RAM already charges configured stacks; adding the measured stack again would
double count its reservation. Passing that reservation check does not prove fit.

These checks can be repeated by reading archive members, hashing their bytes,
parsing ELF section/symbol/program tables and replaying selected objdump `argv`.
Rebuilding still requires the pinned toolchain, source revision and qualified
dependency receipts; this review did not recreate a build environment.

## Required simultaneous path and sufficient rejection

The source's normal two-host route initializes backing, supplies the first host
with `early=0`, no injected candidate failure, and performs reconstruction only
after that host returns. Root/model and semantic lifetime callbacks enclose
`withStorage`; its fourteen original bank loans enclose the consuming session
body. That body calls the session/caller, constructor and actual nRF preset
factory before destination assignment, host use and teardown.

The twelve linked entry reservations are:

`72 + 144 + 1,536 + 520 + 1,232 + 520 + 1,056 + 3,856 + 336 + 5,960 + 9,968 + 3,360 = 28,560`.

Their prologues, call sites and later epilogues support simultaneous reservation.
The resolved model/semantic/scoped forwarders connect the claimed callbacks.
The semantic lender's internal helper is preserved but uncharged. `withStorage`
calls the actual first byte lender with the resolved callback; no invented direct
edge to the consuming body is needed. The original lenders and their forwarders
remain additional enclosing costs, rather than alternative paths added together.

SP reassignment does not reclaim the counted frames. Prepared/root/semantic
bodies subtract further 112/96/96-byte areas before their nested calls;
`withStorage` derives its later SP by subtracting 296 and rounding downward.
Outgoing reservations and alignment are also omitted additional costs. The
selected epilogues restore fixed reservations after the nested work.

Thus **28,560 > 27,648 by 912** is a sufficient actual-image rejection. Namespace,
plan and join helpers have returned and are excluded; alternative callbacks,
later live/stale/cleanup phases are not summed. Outer/corpus/custody, further
original lenders, deeper factory callees and IRQ remain uncharged. The 912 is
neither a complete gap nor a justified stack increase. This finite review stops
at that rejection; it does not claim exhaustive CFG closure, a complete peak or
whole-RAM impossibility.

The config confirms main 27,648, ISR 2,048, FPU/hard-float and MPU guard, disabled
heap arenas and no multithreading. The preserved allocator bodies also support
the limited claim: `swift_allocObject` reaches `posix_memalign`, whose body returns
ENOMEM/12 without allocating. Allocator presence proves neither reachable
allocation nor rooted zero heap. Complete rooted reachability and feasible
exception/FPU overlap remain open.

## Remaining gates and decision boundary

P08/R07/T8.1, HC-RD-003 and all nine full SO criteria remain open. Required work
still includes passing nRF stack fit; complete applicable current-source
four-route evidence and refreshed early Pi evidence; full construction/live/
action/failure/destructor/cleanup, IRQ and allocation accounting; matched Dynamic
allocation/overhead; and independent P08 exit with the exact I4-07 residual.
Native focused 384-check omissions per profile remain explicit. P09 analyzer
migration, P10 integrated conformance, P11 complete workloads/resources/connected
dispositions and P12 cutover retain their existing boundaries. No hardware or
timing acceptance follows from cross-compilation or a passing link.

The current result's recommendation is supported: conduct one concrete,
compatible internal design review against these measured simultaneous lender,
control, constructor and destination costs. This creates no source execution
allowance; historical correction budgets stay closed. A new source candidate
needs its separately explicit bounded allowance. A remedy changing resource
ceilings first needs complete phase/IRQ and reconciled whole-RAM evidence plus
the required reviewed contract/resource decision. Neither +912 nor unused RAM
is that evidence or authority.

Only documentation, prior-receipt preservation and read-only artifact inspection
occurred. No new compiler, build, link, test campaign, target execution, hardware
or source optimization ran. Existing `scripts/contracts/__pycache__/` was
preserved. `scripts/validate-governance.rb`, `git diff --check`, all 392 local
links in the five affected evidence/navigation documents, and the supplementary
doctor archive/member hashes pass.
