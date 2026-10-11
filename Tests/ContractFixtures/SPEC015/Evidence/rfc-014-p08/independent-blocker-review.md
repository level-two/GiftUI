# Independent P08 scoped-host proposal review — 2026-10-11

**Ready for human approval consideration.** Recommend approving the exact
[proposed SPEC-015 diff](proposed-spec-015.diff): permit `~Escapable` host
conformers and require compiler-checked dependence on every supplied backing
lifetime. This is a narrow contract correction consistent with accepted
architecture. No hidden architecture or scope change was identified. It does
not implement the existing generic bootstrap or establish P08 conformance.

## Frozen scope and authority

Separate sequential Strong review, Sol 6.1 High, of clean packet commit
`2579e980a6dca3fc43eeaa2fe08191ef345edd43`. SPEC-015 SHA-256:
`01cebe29a6167fb710095c475b276556183c51e960b0e5d0b2a7fe8bf7069940`.
Review applies the repository's Specification-review and lifecycle rules; it
does not approve or apply normative text. SPEC-015 remains `approved`, its plan
`ready`, and affected P08 integration stopped pending the human decision.

The bounded P08 package follows passed P07 under ITERATION-003 I3-04/05, with
the closed MVP supplying analyzer behavior and four-stack regression duties.
Accepted ADR-035/036/037 govern exact runtime records, stable model backing,
scoped access and Canvas ownership. The previous SPEC-009/013 coordinator
approval explicitly excluded the containing SPEC-015 host lifetime.

## Contract assessment

| Question | Finding |
| --- | --- |
| Is the blocker real? | Yes. SPEC-015 line 739 and the matching production declaration suppress Copyable only. The host still inherits Escapable, so a host retaining a nonescapable coordinator cannot conform. The current control's sole diagnostic is that inherited requirement. |
| Does the protocol edit weaken ownership? | No. `~Escapable` permits a scoped conformer; it does not make existing escapable conformers illegal or erase the concrete host's compiler-enforced dependence. Explicit backing dependence, no callback escape and backing-last release implement ADR-036 rather than substitute a convention for safety. |
| Is concrete return compatible with SPEC-015? | Yes as a contract shape. Lines 769–778 prescribe one concrete per-preset function, first validation failure without an instance, and valid-only instance exposure with the exact report. They do not prescribe the source-only associated factory or enum realization. A lifetime-dependent concrete result can preserve that surface inside the enclosing backing activation. It cannot outlive that activation. |
| Can the existing factory simply receive associated suppressions? | No on pinned Swift 6.3.2. `MVPValidatedHostInstanceFactory.Instance` imposes implicit Copyable/Escapable; the current factory rejects the scoped type, and naive suppression rejects both associated requirements. Approval must not be presented as fixing that source implementation automatically. |
| Does replacing the internal factory require new architecture? | Not when finite concrete per-preset construction preserves the approved graph, audit/report, endpoint compatibility, lifecycle and failure duties. These source-only mechanics are replaceable implementation. A new registry, ambient lookup, external host abstraction, escaping pointer alias or changed ownership graph is outside this proposal. |

SPEC-015's existing nine pure validation stages (lines 1053–1094), activation
sequence (lines 1103–1125), teardown order (lines 1171–1189), HC-002/003/018 and
HC-RD ownership/lifetime duties remain binding. In particular, the correction
does **not** move runtime coordinator/endpoint construction out of the first
`activate()` step. The proof accepts an already supplied coordinator solely to
test the return type and lifetime; adopting its inert lifecycle bodies as
production behavior would violate the existing contract. The proposed paragraph
does not authorize that adoption or override the surrounding activation clauses.

The internal factory's current safeguards must survive its replacement: one
validation call, first-error ordering, exact kind/profile/limits and report,
owner cardinality, endpoint/effective-presentation audit, and teardown of failed
partial construction before any instance is exposed. Permission to specialize a
construction function is not permission to omit those checks. No additional
normative change is needed for these already specified obligations.

## Independent evidence

Verified the frozen SPEC/source hashes, compiler/core receipt and all **165 P07
runtime inputs / 143 artifacts**. Confirmed `Proposed.swift` differs from
`Current.swift` by exactly the host protocol suppression. Independently reran
all seven saved compiler commands, changing only object output locations:

| Control | Independent result |
| --- | --- |
| Current | Rejected inherited Escapable. |
| Proposed | Compiled unchanged protocol members and failure/lifecycle types with the single suppression. |
| ConcreteConstruction | Compiled the scoped constructed/invalid result and return dependence for the real imported generic Static/Dynamic coordinator types. |
| CopyHost | Rejected explicit copying. |
| EscapeHost | Rejected storing the scoped host in an escapable container. |
| FactoryCurrent | Rejected scoped associated Instance's implicit Copyable requirement. |
| FactorySuppressionRejected | Rejected suppression of associated Copyable/Escapable requirements on the pinned compiler. |

Independent logs, objects and result are under
`.build/contracts/spec-015-lifetime-boundary/independent-p08-mujji_2k/`.
Original seven controls, logs and receipt remain unchanged. Reproduce from the
repository root using the packet's command/script and pinned P07 module directory;
for an independent replay without overwriting packet evidence, run the saved
`scoped-host-proof/commands.txt` commands with `-o` redirected into a new local
build directory.

This is native compile/type feasibility. It does not instantiate or execute a
complete validated preset, prove actual model/root/semantic/Canvas backing through
construction/activation, or cover target compilation, resources or hardware.
Inert report/audit/validation payloads are correctly labeled scaffolding.

## Decision and remaining proof

Approve both the suppression and lexical lifetime clarification together, if
the maintainer accepts the proposal. After that decision, P08 implementation
must propagate suppression and return annotations through its finite concrete
construction route, retain existing escapable conformers, and supply the packet's
four-route copy/escape/use-after-consume/returned-result/closed-backing negatives
and real partial-construction/activation/teardown tests. Stable backing must
outlive all retained owners, callbacks and frame reads; cleanup must release
independent cache tickets/pins and retire stale identities before backing last.
The unchanged P08 schema-4/counter/early-image exit and later P10–P12 gates remain.

There is no review blocker to presenting this exact proposal for human approval.
There is still an implementation blocker until that approval is recorded:
generic factory adaptation and complete lifecycle integration are unproved work,
not an exception. P08 guard remains **0/2**. No production/schema edit, compiler
upgrade, architecture selection, package pass, lifecycle transition or optional
follow-up was performed by this review.
