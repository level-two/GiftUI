# P03 implementation progress — 2026-10-10

Input: `0516f9d0` (P02 declaration exit passed). Owner: SPEC-010 T10.1;
criteria: OS-RD-001–004 and unchanged OS regression requirements. The historical
lexical visitor stop was resolved by the explicit step-8 amendment. Step 9 records
the implementation and finite exit evidence awaiting separate Strong review.

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

## Step 5 — production registration and guarded replacement join

Dispatch: P03 / OS-RD-001–004, after step 4 `12896815`. Strong
`gpt-6-astra` / `high`, C3/R3; no lower-tier assignment. Allowed files are
GiftUIObservableState ownership/root/registration adapters, the existing Dynamic
and Static root/model/target-access files, the focused driver/fixtures and
related implementation records. SPEC-010's Materialization and identity,
Replacement and amendment transaction clauses are the expected-outcome oracle.
The real attach hook must see actual candidate bytes; synchronous reports use
separate registration storage; precommit failure preserves A and postcommit
failure preserves B. Candidate publication/discard remains distinct from reads.
Root activation owns callback lifetimes and must retire callbacks before the
owning storage borrow ends. Generated schema/application adoption remains in
its named consumer packages; no topology or P04 work is authorized here.
Consecutive unproductive repair count at entry: 0 of 2. Exact focused commands
and artifact receipts will be recorded with the implementation result.

Step-5 focused result: both native profiles pass 450 assertions (324 existing
component assertions plus 63 callbacks through each actual root adapter).
ARMv6 and Embedded compile the real root callback probe and verify CPU/VFP
attributes. The final selected-component receipts are:

- macOS Static: `.build/rfc014-p03/state/tmpxpouw0f4/macos-static/result.json`
- macOS Dynamic: `.build/rfc014-p03/state/tmp22sbxjpd/macos-dynamic/result.json`
- ARMv6: `.build/raspberry-pi/rfc014-p03/state/tmpven7jeqv/raspberry-pi-armv6/result.json`
- Embedded: `.build/nrf52840/rfc014-p03/state/tmpd4qea7bo/nrf52840-embedded/result.json`

Each receipt now includes `layouts.json` and the exact compiler IR from fourteen
layout probes. On all four: ledger 188 B; model metadata record 16 B; frame-pin
field 1 B at offset 11 within that record; claim/claim-record 16 B; ticket 20 B,
alignment 4; replacement 56 B; UInt8-identity registration record 36 B and root
storage 84 B. Native read-slot/scope/sink are 24/32/24 B; ARMv6 and Embedded are
12/16/16 B. These are actual instantiated component layouts, not an analyzer
payload, final exact-path registration, full stack or linked RAM total.

The root uses actual model-owned attach/report/detach callbacks and exact
registration lifecycle validation. Tests cover precommit retention/second-
populated/capacity/attach-return/attach-report refusal, preserved A data and dirty
generation, installed-empty entitlement, final-ticket commit, stale A access,
postcommit draw/detach failure, candidate transfer/discard, removal/reinsertion,
detached retention and shutdown. Activation end invalidates remaining claims
and destroys models even if a callback drops a ticket without explicit release;
allocation and claim serial cursors remain non-reusing.

Productive compiler adjustments: typed-throws cleanup inference, an explicit
noncopyable extension constraint, and copying the original scope lifetime rather
than its temporary pointer fields. The layout probe replaced Embedded-unsupported
key paths with actual field addresses; the extractor follows its constant-return
thunk. Every adjustment either narrowed diagnostics or produced a passing check;
consecutive unproductive repair count remains 0 of 2. Formatting, governance and
whitespace checks pass. No whole-module, linked zero-heap, complete analyzer,
connected or P03 exit claim: the callback fixture contains allocation symbols,
which still require attribution, and lexical reconciler/target access plus final
exit controls remain open. No P04 work or broad test gate was run.

## Step 6 — fixed callback repair; lexical join stopped

Strong `gpt-6-astra` / `high`, C3/R3; dependencies through `e1cb8711`.
The Embedded root probe IR attributes 12-byte context allocations to the real
root `install` and `replace`, separately from the fixture's counter box. This is
an implementation defect under the existing Static contract, not permission for
heap fallback. The bounded fix replaces captured report closures with the
existing contract's fixed callback/context route and separately borrowed
nongeneric report storage. Public sink behavior and capacities remain unchanged;
private/package constructors and their owner adapters may change. GiftUI changes
require refreshed four-profile P02 core receipts before further P03 reuse.
Lexical reconciler/target access and final escape/fault controls remain in this
step. Repair counter at entry: 0 consecutive unproductive attempts of 2.

Step-6 frozen selected-component checks pass with these refreshed core receipts:

| Profile | P02 core directory | P03 component result |
| --- | --- | --- |
| macOS Static | `.build/contracts/spec-006-rfc-014/58ab1755cf57c634-0urm4i3k/macos-static` | `.build/rfc014-p03/state/tmpgqre2h5_/macos-static/result.json` |
| macOS Dynamic | `.build/contracts/spec-006-rfc-014/58ab1755cf57c634-vlc1nqjo/macos-dynamic` | `.build/rfc014-p03/state/tmp2u7h8rdh/macos-dynamic/result.json` |
| ARMv6 | `.build/raspberry-pi/contracts/spec-006-rfc-014/58ab1755cf57c634-wlpjbz9w/raspberry-pi-armv6` | `.build/raspberry-pi/rfc014-p03/state/tmp9ay63b6t/raspberry-pi-armv6/result.json` |
| Embedded | `.build/nrf52840/contracts/spec-006-rfc-014/58ab1755cf57c634-v850qxu1/nrf52840-embedded` | `.build/nrf52840/rfc014-p03/state/tmp04qis62p/nrf52840-embedded/result.json` |

Each run uses `scripts/contracts/check-spec-010-model-identities.py --giftui-build`
with the exact core directory above. Both native profiles retain 450 passing
assertions and eight expected compiler/lowering rejections. Both cross builds
compile the four probes and pass CPU/VFP ABI checks; there is no target execution.
Sixteen actual-layout measurements now separate registration record (24 B),
report route (12 B) and report store (28 B); total UInt8-identity root storage
remains 84 B on all four. Other step-5 sizes, including ticket/pin, are unchanged.

The Embedded `root-allocation-attribution.json` hashes both specialized production
`install` and `replace` IR bodies and verifies no direct allocator calls remain.
The corresponding IR is hashed too. This attributes the two prior allocations;
it is not a transitive call-graph, linked zero-heap, stack or analyzer budget proof.
The driver's exact selected files remain the evidence boundary. In particular,
mechanical fixed-sink signature updates in the legacy registration bridge and
Static registration record have not been validated as complete modules; their
old consumer/test migration is still outstanding.

The new adversarial public host fixture compiles successfully on each native
profile: a generic witness saves a visitor copy in an escaping closure. Therefore
the attempted private visitor containing backing pointers was unsafe and has
been removed, together with its untested candidate-offer and reconciler edits.
See [exact reproduction and options](lexical-visitor-blocker.md). Strong review
must determine whether a bounded owned-value adapter meets current contracts;
only a necessary contract decision goes upstream. No public visitor SPI change,
new location capacity or generated-only trust assumption was accepted.

Productive repairs: fixed C callback routing removed the two attributed production
context allocations; the adversarial compile supplied decisive lifetime evidence.
Consecutive unproductive count remains 0 of 2. Formatting, governance and whitespace
checks pass. No P04 work, broad regression gate, deployment or flashing occurred.

P03 remains incomplete: safe lexical binding/nested generated traversal, matching
candidate-offer ownership in that traversal, profile target-access migration,
remaining actual callback phase/exhaustion/escape controls and the finite package
exit still require completion. Application operation adoption belongs to P08/P09;
complete runtime differential cleanup/cycle integration belongs to P07, full owner
regression/build closure to P10, and integrated resource/target disposition to
P11/P12. Those later obligations do not excuse the open P03 work. Separate Strong
review is pending; no implemented/conformance transition is requested.

## Step 7 — reviewed generation-precedence repair

Dispatch after separate Strong review of `b19a0952`: Strong `gpt-6-astra` / high,
C3/R3. Only the confirmed P2 seed-path ordering issue is authorized. SPEC-010
amendment precedence (lines 177–181) and baseline first-failure order
(lines 852–859) require registration-generation exhaustion before model metadata
or backing capacity. New seed encounter previously materialized first. The fix
checks the cursor after applicable seed compatibility and before materialization;
replacement already performed this early check. Fresh typed seeds cannot already
have a structural owner, so duplicate ownership is inapplicable to this path.

The real-root fixture supplies an internal exhausted registration cursor over
actual Static model backing, once with the sole capture entitlement retained and
once with both metadata slots occupied. It expects generation exhaustion and
unchanged materializations, attachment/detachment/destruction counts, live ticket
validation and next allocation generation. The fixture adds 23 assertions;
existing root callbacks remain the Dynamic/Static differential control. This is
not whole-module or complete package evidence. The unsafe lexical join remains
stopped. Separate review rejects literal two-pass enumeration under OS-010;
see the updated blocker record. Repair counter at entry: 0 of 2 consecutive
unproductive attempts. Exact validation receipts follow below.

Step-7 validation passed on the first implementation attempt. Exact commands:

```text
scripts/format-swift.sh
scripts/contracts/check-spec-010-model-identities.py --giftui-build .build/contracts/spec-006-rfc-014/58ab1755cf57c634-0urm4i3k/macos-static
scripts/contracts/check-spec-010-model-identities.py --giftui-build .build/contracts/spec-006-rfc-014/58ab1755cf57c634-vlc1nqjo/macos-dynamic
scripts/contracts/check-spec-010-model-identities.py --giftui-build .build/raspberry-pi/contracts/spec-006-rfc-014/58ab1755cf57c634-wlpjbz9w/raspberry-pi-armv6
scripts/contracts/check-spec-010-model-identities.py --giftui-build .build/nrf52840/contracts/spec-006-rfc-014/58ab1755cf57c634-v850qxu1/nrf52840-embedded
git diff --check
scripts/validate-governance.rb
```

Both native profiles pass 473 assertions (450 existing plus 23 new), along with
the existing eight negative controls. ARMv6 and Embedded compile the updated
real-root probe and pass CPU/VFP checks without target execution. Actual layouts
remain unchanged, and the Embedded narrow install/replace direct-allocation
attribution still passes. Source/compiler/artifact-matched receipts:

- macOS Static: `.build/rfc014-p03/state/tmp_lh3fby2/macos-static/result.json`
- macOS Dynamic: `.build/rfc014-p03/state/tmplg1aflsb/macos-dynamic/result.json`
- ARMv6: `.build/raspberry-pi/rfc014-p03/state/tmpn6fh41bo/raspberry-pi-armv6/result.json`
- Embedded: `.build/nrf52840/rfc014-p03/state/tmpjabx3hec/nrf52840-embedded/result.json`

Formatting, governance and whitespace checks pass. No additional implementation
repair, broad gate, target execution or downstream work was performed. Consecutive
unproductive repair count remains 0 of 2. The confirmed P2 fix awaits separate
Strong verification; P03 remains blocked on the reviewed lexical visitor contract
question and no public contract change or approval is inferred.

## Package checkpoint — separate Strong review complete

Sequential implementation and independent review were dispatched to
`gpt-6-astra` with `high` reasoning. The review covered `d1b1f2df..b19a0952`,
then separately verified the bounded repair in `7594b724`. The implementation
commits are `12896815` (checked mutation/discovery), `e1cb8711` (scoped roots and
replacement), `8b726ce3` (fixed callbacks and escape evidence), and `7594b724`
(registration-generation precedence); `b19a0952` records the safety checkpoint.

The review's P2 precedence finding is resolved. The preflight preserves phase
and compatibility ordering and existing bindings, while checking exhaustion
before materialization. The reviewer verified that all four step-7 receipts
hash the committed changed inputs. The 23 new checks cover combined generation
and capacity failures with unchanged ownership, callbacks and allocation
identity. No additional confirmed issue was found in the bounded repair.
No redundant test rerun was needed for this read-only review.

The P1 lexical visitor finding remains open as the
[contract decision](lexical-visitor-blocker.md). Literal two-pass enumeration
violates OS-010, and no safe current-contract replacement has been demonstrated.
The recommended next decision is a coordinated SPEC-010/006 visitor lifetime
amendment preserving exactly-once discovery, binding before body, failure
suppression and existing capacities. No amendment is approved or implemented.

Package boundary: P01/P02 passed; P03 incomplete and stopped for that decision;
P04–P12 pending. Remaining P03 work is listed in step 6. The repair guard remains
0 consecutive unproductive attempts of 2. The evidence establishes selected
components only, with 473 assertions per native profile and cross-compilation/ABI
checks on ARMv6 and Embedded. There is no whole-module, linked zero-heap,
connected-hardware or implemented-Spec claim.

## Step 8 — approved scoped visitor contract correction

Following separate Strong review `3e82e2a9`, Eugene explicitly approved the
precise SPEC-006/010 generic Copyable/Escapable suppressions and concrete binder
lifetime requirement. The approval record and both normative amendments preserve
ordinary View values, authored syntax, exact-once binding, capacities and all
identity/replacement semantics. The manifest cross-reference and historical
blocker disposition are updated. No code or implemented transition is part of
this contract step. Governance/whitespace checks validate the recording; no old
receipt is claimed as implementation evidence. Repair counter remains 0 of 2.

## Step 9 — scoped lexical ownership and finite P03 exit

Actual dispatch: Strong `gpt-6-astra` / high, C3/R3; sequential implementation,
no child delegation. Authority is the explicitly approved step-8 amendment in
`567b59fb`, SPEC-010 OS-RD-001–004/OS-010 and unchanged ADR-036. This step awaits
separate Strong review; it does not itself mark P03 passed or T10.1 complete.

The public declaration and semantic visitor protocols now permit noncopyable,
nonescapable conformers, and host/View generic witnesses retain both suppressions
through the macro, built-in containers and modifiers. Ordinary View declarations
remain copyable. The concrete private binder contains a borrowed actual root
scope with a lifetime dependency; the root visits the copied declaration once,
binds before body, suppresses the body on failure and ends each read before child
discovery. The generated parent/child fixture traverses a modifier and proves
exact-once bodies, preserved-seed behavior and attachment failure suppression
on both real backing profiles. Four offered claim descriptors transfer existing
candidate ownership into the matching registration without acquiring another
claim; unused offers are released on candidate completion/shutdown.

Both profile target adapters now alias a scoped root target with generation
validation followed by checked model mutation. The Dynamic reconciler and binding
decorator alias the scoped root, replacing their copyable raw-model routes.
`ObservableTargetGeneration` moved unchanged from ExecutionValues into its own
Execution source file, allowing the selected-path driver to compile that real
four-byte contract value without claiming the complete Execution module.
Legacy coordinator protocols and the Interaction consumer are downstream P07/P05
migration, not compatibility shims in these new scoped joins.

The retaining-sink teardown audit found a package-helper lifetime hazard: a caller
could catch a failed detach and retain a ticket after temporary report storage
ended. A failed detach now latches the ledger's retired phase after mandatory
local commit/cleanup. Normal mutation/report, owner operations, frame entry and
reactivation refuse. Remaining route retirement/detach still occurs under the
root borrow. Before report-storage scope ends, terminal cleanup retires all
remaining claims and destroys retained models; destructor reports see stale
routes while their backing exists. The terminal phase survives outer cleanup.
The 37 dedicated assertions exercise shutdown, candidate removal and rejected
attachment with a sink deliberately retained on failed detach. The two real-root
postcommit tests prove B's selected identity, attached value and dirtiness, then
verify that a normal read cannot reopen after invariant failure. This follows
SPEC-010's “Safety-not-proven phase, reentrancy, or invariant failure” mandatory
stop row and shutdown requirement. It does not reinterpret rollback or grant
permission for a later normal cycle. Full coordinator containment/policy remains
P07; independent normal detach/release semantics are unchanged.

Validation is limited to the changed P03 paths and the amended P02 public/generic
surface. Formatter ran before focused gates. The macro snapshots initially needed
the approved signature update; the retaining-sink destructor fixture initially
needed a mutable sink binding. Both bounded corrections produced passing evidence;
no two consecutive unproductive attempts occurred. Counter: **0 of 2**.

Final results: **602 assertions on each native profile**, comprising 324 prior
identity/ledger/backing/State/mutation assertions, 58 generated nested lexical
assertions, 37 retaining-sink assertions, 23 generation-precedence assertions and
160 real Static/Dynamic root callback assertions. All four profiles pass 13
negative controls: declaration and semantic visitor copy/escape, root/ticket
escape, backing overlap, raw-reference State, State assignment and four malformed
lowering inputs. ARMv6 and Embedded compile the actual root/nested/teardown paths
and pass CPU/VFP checks; neither target was executed. P02 core refresh passes
120 assertions/28 checks on each native profile and 27 checks on each cross profile.

Actual compiler layouts remain: ledger 188B; model metadata 16B (one-byte pin at
offset 11); claim/claim record 16B; ticket 20B aligned to 4; replacement 56B;
UInt8 registration record 24B; report route/store 12/28B. Root metadata is now
164B including four 20B optional offered-claim descriptors. Native scope/read-slot/
sink/root-scope/target-scope are 32/24/24/48/56B; ARMv6/Embedded are
16/12/16/24/28B. These actual specialized layouts are not complete application
identity/model/stack accounting. Embedded IR still has no direct allocator calls
in the two specialized production install/replace bodies; this is not transitive
or linked zero-heap proof. The three analyzer transition banks remain 19,392B;
no payload copy, fourth bank or capacity relaxation is introduced.

Exact final commands/receipts and their source/compiler/artifact identities are
preserved in the [step-9 receipt bundle](scoped-binding-receipts.json). The bundle
also preserves the core receipt and component command-file hashes; original logs
remain at the recorded build paths. Whitespace and governance checks pass.
The registered SPEC-010 top-level driver owns the optional `rfc-014` route and
requires an explicit matching P02 directory. Its default legacy gate is unchanged.

Finite boundary: remaining P03 implementation is ready for separate Strong exit
review, including the retaining-sink stop and public custom-witness escape
boundary. P04 semantic records, P05 Interaction adoption, P07 coordinator/full-cycle
handling, P08/P09 application and host wiring, P10 full-module/regression gates,
and P11/P12 linked resource/target evidence and cutover remain pending. No broader
test gate, deployed/flashed artifact, connected execution, completed T10.1 or
implemented Specification transition is claimed.
