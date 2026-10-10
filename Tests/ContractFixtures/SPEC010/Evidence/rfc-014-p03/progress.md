# P03 implementation progress — 2026-10-10

Input: `0516f9d0` (P02 declaration exit passed). Owner: SPEC-010 T10.1;
criteria: OS-RD-001–004 and unchanged OS regression requirements. P03 is in progress.

## Step 1 — identities and failure vocabulary

The host-owned owner namespace and each store's allocation namespace are
noncopyable checked UInt32 cursors. Both start at zero, issue UInt32.max once,
and remain exhausted without wrapping. They are independent of structural
registration/target generations. Production construction has no seeded reset;
internal fixture constructors exercise the final boundary. Host assembly must
retain its namespace across replacement assemblies.

ObservableStateError preserves raw values 0–11 and appends the six approved
cases at 12–17. AccessFailure mapping preserves invalid phase, stale identity
and indexed bounds distinctions. The focused failure bitset grows from UInt16
to UInt32 so all 18 cases participate. Existing Runtime/application normalizers
now cover those cases and select discovery versus replacement capacity scope.
Those integrated normalizers still await the P03/P07 consumer build.

Focused native validation:

```text
scripts/contracts/check-spec-010-model-identities.py --giftui-build .build/contracts/spec-006-rfc-014/bbb06b42e2159475-9yjt1mg6/macos-static
```

The command checks pinned compiler, P02 GiftUI source and artifact hashes before
reusing that core module. It compiles the current production identity/error
files, FailureCore and the focused ObservableState failure adapter, then runs
227 assertions: exact raw values/size, access mapping, independent issuance,
maximum/exhaustion, every pair in the 18-case precedence order and the new
condition/origin/scope/containment mappings. Result: zero failures. Commands and
logs are under `.build/rfc014-p03/identity/`.

This increment is not a backing lifetime, State binding, replacement, whole-module
or four-profile exit. Those P03 checks remain open. Formatting, governance and
`git diff --check` pass. No broad P10 gate or connected operation was run.

## Step 2 — bounded ownership and concrete backing

The existing Dynamic/Static model-storage files now own fixed typed model buffers
and the bounded ownership ledger. A shared scoped adapter in GiftUIObservableState
borrows those actual buffers throughout activation; no new target or migration
conditional is introduced. Tickets are noncopyable and nonescapable; keys remain
nonowning. The [design note](../../../../../docs/implementation-designs/spec-010-stable-model-ownership.md)
records the storage proof, independent claim/registration/pin lifetimes and the
remaining callback work.

The ledger adds 46 native assertions for bounded claims, registered versus
independently retained models, installed-empty capture entitlement, two-slot/four-
claim limits, shared frame pins, discovery exclusion, stale model/claim reuse,
replacement reservation guards, refusal, discard and commit. Native stride is
188 bytes; this is metadata, not complete profile memory or a linked RAM claim.
Fifteen additional assertions exercise both real backing factories with a
noncopyable model, actual destruction counts, detached retention, scoped reads,
reassembly-stale keys, Dynamic activation reentry, and the target probe on native.

The component driver passed with each recorded P02 core input:

- macOS Static: `.build/contracts/spec-006-rfc-014/bbb06b42e2159475-9yjt1mg6/macos-static`
- macOS Dynamic: `.build/contracts/spec-006-rfc-014/bbb06b42e2159475-6qul9t82/macos-dynamic`
- ARMv6 Dynamic: `.build/raspberry-pi/contracts/spec-006-rfc-014/bbb06b42e2159475-qu406pys/raspberry-pi-armv6`
- nRF Embedded Static: `.build/nrf52840/contracts/spec-006-rfc-014/bbb06b42e2159475-qqr5z94s/nrf52840-embedded`

Invoke `scripts/contracts/check-spec-010-model-identities.py --giftui-build <path>`.
The driver verifies unchanged core sources/artifacts and compiler bytes, then
reuses the exact target/SDK/feature/optimization recipe from that core receipt.
Current component logs/commands are under `.build/rfc014-p03/ownership/<profile>`
(native), `.build/raspberry-pi/rfc014-p03/ownership/<profile>` and
`.build/nrf52840/rfc014-p03/ownership/<profile>`.
Native results: 227 identity/error + 46 ledger + 15 actual-backing assertions,
zero failures. Cross profiles compile a concrete lifetime/retain/read/release
entry point and verify CPU/VFP attributes; no target execution is claimed.
All four reject escaping a ticket and overlapping access to Static backing.

This remains a component increment. The old State/reconciler/root-adapter callers
still require migration to these stores. Real attach/detach/report callbacks,
checked mutation, candidate publication, full guarded capture replacement and
teardown remain P03 work; neither full profile modules nor the P03 exit pass
is claimed from the selected-file component build.

## Step 3 — typed State representation and authored lowering

Assignment: P03 / OS-RD-002 and its DV-RD-001/002 declaration dependency;
P02 is passed and the step-2 store is the fixed backing input. Allowed owners:
GiftUI State, GiftUIMacros, existing declaration visitors/reconciler signatures,
the focused SPEC-010 fixtures/driver and this design/evidence documentation.
C3/R3: source transformation and State ownership representation affect the
checked-access boundary. Implementation and a separate invariant review used
the current inherited Codex model; its exact model ID and reasoning setting
are not exposed in this session, so no model-tier verification or cost claim
is made. No agents were spawned. The two-unproductive-repair stop rule remains
in force; no such consecutive blocker occurred in this slice.

State's resolver/replacement closures and raw-model projection are removed.
Its exclusive cases are initial schema seed/candidate descriptor or bound
location/ordinal/registration generation/key. An initial checked read throws
invalidPhase. Binding returns/discards the initial value and does not overwrite
an already bound value. A candidate descriptor is nonowning: production binding
must still validate and transfer the host's matching ticket. This increment does
not claim that transfer has been wired.

The existing macro target generates finite owned seed types, lowers seeded and
explicit-candidate State declarations, and routes bare/self-qualified model reads
through the checked key/facade accessor. Generic State attributes participate in
the existing lexical discovery macro. No new target or migration conditional.
Independent review found that local shadowing could otherwise be rewritten as
State access; the finite lowerer now rejects it, and rejects computed State before
rewriting can hide the invalid declaration. These controls accompany effectful
and malformed-seed rejection, with no partial generated outputs.

The component suite adds 15 checks for initial read rejection, seed discard,
bound metadata, stable rebinding, candidate descriptors, fresh ignored seeds,
generic macro discovery, actual scoped backing reads and all three authored
declaration forms (seeded, candidate and nested). Its binder is explicitly a
test fixture, not the production root reconciler. Raw-reference State and
assignment through wrappedValue are compiler rejection controls. Existing
identity/ledger/backing checks remain: 303 assertions per native profile.

Validation uses the same commands as step 2 after refreshing core/lowering with
`scripts/contracts/run-spec-006.sh --profile <profile> --compiler-baseline rfc-014`.
The component driver now creates unique receipts with source, core-receipt and
artifact hashes, command logs and explicit evidence boundaries. The final
four-profile receipt locations are recorded below.

| Profile | Refreshed core receipt directory | Component receipt directory |
| --- | --- | --- |
| macOS Static | `.build/contracts/spec-006-rfc-014/fa8126ad57f71d7f-uvu301dh/macos-static` | `.build/rfc014-p03/state/tmpj1b7ntly/macos-static` |
| macOS Dynamic | `.build/contracts/spec-006-rfc-014/fa8126ad57f71d7f-o_uuzhdj/macos-dynamic` | `.build/rfc014-p03/state/tmpyijh7opx/macos-dynamic` |
| ARMv6 Dynamic | `.build/raspberry-pi/contracts/spec-006-rfc-014/fa8126ad57f71d7f-lh1h85ij/raspberry-pi-armv6` | `.build/raspberry-pi/rfc014-p03/state/tmp5xhnd5jg/raspberry-pi-armv6` |
| nRF Embedded Static | `.build/nrf52840/contracts/spec-006-rfc-014/fa8126ad57f71d7f-86ab0vco/nrf52840-embedded` | `.build/nrf52840/rfc014-p03/state/tmp72cl55q4/nrf52840-embedded` |

Each directory contains `result.json` and command logs. Both native profiles
pass 120 P02 declaration assertions and 303 P03 component assertions. All four
pass six macro goldens, the existing P02 controls and eight P03 negative controls.
Both cross profiles compile the concrete backing and State probe, with checked
ARM CPU/VFP attributes for each object; execution is native-only. Formatting,
governance and whitespace validation pass. The package dependency check passes
84 targets and 375 direct edges, acyclic. The driver verifies both core and
macro source hashes before reusing the refreshed receipt.

Production root/reconciler callbacks, candidate ticket transfer, checked mutation,
guarded capture replacement and teardown remain P03 work. The three mechanical
visitor/reconciler signature changes are not evidence of a complete profile-module
build. P03 remains in progress; P04 has not started. Full conformance, resource
and adoption gates remain P10–P12. No hardware execution, deployment or flashing.

## Step 4 — checked operation and nested discovery join (active)

Dispatch: P03 / OS-RD-001/002/004; P02 and steps 1–3 are fixed inputs.
C3/R3 because phase exclusion and disjoint mutable borrows affect memory safety.
Strong implementation: `gpt-6-astra`, reasoning `high`; separate Strong review
remains required. Allowed source: ObservableModelOwnership/Scope/Mutation and
focused RuntimeDerived fixtures/driver, plus this note. The approved SPEC-010
**Model read, ownership and mutation contract** supplies the oracle: validate
phase and identity before preflight; a failed preflight changes no bytes;
non-failing commit precedes a synchronous report; a no-op omits that report;
nested discovery occurs only after the parent read ends. No architecture or
public contract choice is delegated. The internal typed operation witness is a
replaceable realization; authored arbitrary inout callbacks remain unavailable.

Validation command is the existing identity component driver with the step-3
macOS Static core receipt first; then the other three pinned core inputs above.
Evidence remains component-only until the real root/callback migration passes.
Consecutive unproductive repair count at entry: 0 of 2. No package exit or
whole-module claim is made by this in-progress dispatch.

Step-4 implementation/check result: 322 assertions pass on each native profile
(303 prior plus 19 checked-operation/discovery assertions). Both cross profiles
compile the concrete noncopyable scalar/compound operation, verify CPU/VFP ABI
and pass existing eight negative controls. Receipts:

- macOS Static: `.build/rfc014-p03/state/tmpm2qw6_ox/macos-static/result.json`
- macOS Dynamic: `.build/rfc014-p03/state/tmpt9phwypr/macos-dynamic/result.json`
- ARMv6: `.build/raspberry-pi/rfc014-p03/state/tmpj76q4pcb/raspberry-pi-armv6/result.json`
- Embedded: `.build/nrf52840/rfc014-p03/state/tmpymfdrd_s/nrf52840-embedded/result.json`

The first compile rejected a noncopyable associated Model type. Moving the
finite operation witness onto the concrete storage model passes without changing
the pinned compiler/features. This was one productive internal repair; the
consecutive unproductive count remains 0 of 2. The witness preflights by borrowing
the model, performs a non-failing bounded commit, ends that mutable borrow, then
reports synchronously. Its writing phase rejects reentry until reporting ends.
A report failure preserves the committed bytes. The compound fixture has a
2-byte payload and scalar preflight data; it is not analyzer capture or complete
application evidence. The real root/callback, guarded replacement, teardown and
complete-layout exits remain open. Formatting passes; no broad gate was run.
