# Independent production-image review — 2026-10-12

Reviewed clean1471126c, sourcee5620a35, sequential Sol6.1 High / Strong.
**Accept the focused GOT recipe correction and its linked image evidence;
reject R07 gross-stack fit. A caller-owned backing realization is permitted
within the existing contract, with compiler realization and feasibility still
unproved.** No build, compiler, linker, variant, source repair or target action
ran in this review. R07/P08/T8.1 remain open; P09–P12 untouched.

## Independently checked disposition

The maintained two-file correction matches the prior reviewed RODATA hook.
Its final20-byte span is inside ROM accounting, with12zero header bytes and
the two existing runtime Thumb addresses. It has no RAM copy or unresolved
relocation. Supported verification reports ARMv7E-M/VFP, flash297604,
RAM31616 and heap0. Preserve the recorded Swift allocation-thunk/refusal-stub
qualification; heap0 is not dynamic proof that every path avoids allocation.

The linked entry evidence establishes `main -> giftui_rfc014_counter_entry`
and direct sequential calls to graph0x20f28 and host0x1935c. Their prologues
reserve32256+52 and120832+348, each saving36bytes. The local frames are
32344 and121216, exceeding27648 individually by4696 and93568. They are not
summed as overlapping calls. Corpus4416 and click8392 are further callees,
not substitutes for these root frames. This is a definite P08 gross-fit
failure before hardware; no complete P11 peak investigation is needed to
establish it.

Source explains an actionable physical-layout issue: graph constructs one
`StaticCounterProfileStorage`; host constructs complete, partial and
nonRetryable profiles, plus a failure-loop profile. The profile embeds typed
semantic banks, Canvas backing, workspace bytes, interaction/root owners and
control/backend storage. Its host path also supplies concurrently live foreign
model/control backing for rejection tests. These logical instances and
identity/lifetime controls must remain present. Source alone does not explain
every compiler temporary or prove that splitting a function would fix it.

## Contract-supported bounded continuation

SPEC-015's schema-4 amendment requires stable host/profile-owned backing and
an exact lifetime/section/stack ledger. Its Performance Requirements explicitly
permit bounded caller-owned or inline storage and forbid Static heap allocation.
It does not require the counter's full backing aggregate to occupy a function
frame. Moving the same typed physical backing to explicitly supplied persistent
counter storage, with bounded scoped access, is a replaceable local realization.
No larger stack/heap, different corpus or architectural approval is needed.

Before editing, extend the existing production receipt with the exact field/
slot map, fixed byte counts/alignment, initialization/deinitialization order,
logical live intervals, pointer/borrow provenance, source list and finite checks.
This is implementation design under existing authority, not a human approval
gate. Then implement only that mapped realization:

- Allowed fixture files: `CounterProfileStorage.swift`, `CounterGraphProbe.swift`,
  `CounterHostProbe.swift`, `CounterRouteEntry.swift`, `CounterStorageRegions.swift`
  and `CounterStorageMeasurement.swift`; one new
  `StaticCounterEmbeddedBacking.swift` is allowed if useful (the existing
  StaticCounter source glob includes it). Allowed firmware file:
  `src/counter_main.c`, solely for explicit caller-owned backing and passing it
  into the selected private fixture root. Leave the SPI writer ABI and public
  owner contracts unchanged. No portable Sources owner edits, compiler/SDK,
  linker/GOT change, new allocator, ambient backing lookup or flattened module.
- Backing categories are the existing semantic records/paths/payloads/scalars,
  Canvas entry, layout/render/path/plan arrays, root/model/interaction storage,
  control/admission and existing tile/coverage. Account any foreign negative-
  fixture backing and initialization scratch separately. Preserve element
  counts, capacities, audit partitions, all assertions, producer/callback
  observations and the synchronous writer. Use exact typed size/alignment and
  explicit lifetime-safe scopes; no guessed arena allowance or unsafe aggregate
  bit-copy. Do not simply `initialize(to: StaticCounterProfileStorage(...))`
  into raw storage and assume the large temporary disappeared. Initialize
  physical fields/banks without constructing the same whole large value on
  the stack; the final prologues, not source intent, decide success.
- Preserve all concurrently live complete/partial/nonRetryable/failure and
  foreign instances, monotonic fresh owner identities and original operation
  order. Storage reuse is allowed only after a recorded last borrow, teardown
  and deinitialization; graph and host phases are sequential, but their physical
  aliasing must be demonstrated, never inferred from a reset flag. No static
  data race/reentrant alias, stale reference, owner reuse or shortened read
  lifetime. Persistent storage belongs to the caller and must be passed as an
  explicit construction input, not found through a global service locator.
- Fresh source receipts must include the new file and exact changed bytes.
  No weakening old receipt checks. Refresh affected counter-route inputs through
  the existing checker, and pass those fresh receipts to the supported firmware
  command; old R06 bytes cannot be relabeled current. Do not alter checker or
  image-builder semantics merely to accept mismatched inputs. If those scripts
  genuinely need an interface change, stop with the precise additional file
  and reason before widening this slice.

Expected independent outcomes: the exact corpus/assertion behavior and negative
ownership/lifetime controls remain equal; every physical bank is charged once
to its true owner with simultaneous instances and initialization scratch visible;
the final linked root/profile initialization/graph/host paths avoid both oversized
frames; ABI/GOT/heap remain valid and total RAM/flash remain within196608/
1048576. Merely moving121216bytes into BSS does not prove total feasibility;
all reserved backing, configured27648 stack and remaining live call-chain/IRQ
overlap must fit. A local frame below27648 alone is also insufficient if the
actual feasible nested chain still exceeds it.

Finite checks: formatter first; one current affected native counter validation
and one supported nRF image validation after the mapped correction and fresh
required receipts. Existing cross-route receipt refreshes are compilation
evidence, not target execution. Preserve every exit/artifact; no automatic
follow-on source rearrangement, compiler/optimization variant or repair after
a failed check. Stop for separate Strong result review on success or failure.
If the design cannot establish explicit lifetime-safe backing within existing
limits, report that exact missing evidence or contract choice before code.

Historical helper2/2+B031/1, diagnostic1/1 and initial supported-build1/1 stay
closed. This continuation is a new identified storage-realization correction,
not reuse of those allowances. No source edit is approved by this review as
already correct; no stack/heap/RAM/workload relaxation or hardware action is
authorized. The linker defect is resolved; actual counter image fit is not.
