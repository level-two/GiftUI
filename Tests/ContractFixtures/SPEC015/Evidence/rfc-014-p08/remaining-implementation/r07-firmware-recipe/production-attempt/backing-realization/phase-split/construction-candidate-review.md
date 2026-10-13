# Independent construction-candidate review — 2026-10-13

Reviewed clean065843c1, sequential Sol6.1 High / Strong. **Reject the candidate
as an implementation-ready plan. Its proposed scoped generic conformers do
not fit the unchanged generic contracts; an outer lease alone is not the
missing proof.** No source, compiler, link, test or experiment ran. No new
allowance, implementation approval or stack-fit claim.

## Exact semantic obstacle

Affected declarations are `CounterGeometry.swift:25`,
`Sources/GiftUIInteraction/InteractionStorage.swift:22`/`:36`/`:47`, the generic
where clauses in `InteractionState.swift` and `InteractionOwnedKeyState.swift`,
and fixture `CounterPipelineOwner.swift:115` / `CounterStorageMeasurement.swift`
(`CounterReturnedWorkspaces`). The portable protocol changes in option2 affect
cross-module callers, rather than just private counter storage.

The governing SPEC-015 schema-4 amendment's lifetime clauses at252–260 require
stable host/profile backing, accounted ownership and backing reuse only after
producer/callback/read lifetimes end. HC-RD-002 requires backing lifetime/no
stale dispatch through partial construction, activation and teardown;
HC-RD-003 requires actual linked/zero-heap/stack evidence under unchanged
constraints. Its Performance Requirements permit bounded caller-owned storage,
not lifetime-erasing adapters. These are the relevant existing requirements;
this review does not invent a blanket prohibition of pointer implementations.

`CounterGeometry` has ordinary implicit Copyable/Escapable requirements.
`CounterPipelineOwner` constrains Geometry to it and retains Geometry by value.
`CounterHostSuppliedStorage`, the concrete host state and
`CounterReturnedWorkspaces` also retain/transfer geometry values. The latter is
explicitly escapable and documents that only owned escapable workspaces leave
the scoped opportunity.

The portable `InteractionCandidateRecordStorage`,
`InteractionCommittedRecordStorage` and `InteractionHitRegionStorage` protocols
likewise do not suppress Copyable or Escapable. `InteractionState` and
`InteractionOwnedKeyState` retain those conformers by value. The existing
candidate/committed/hit fixture protocols inherit those constraints. Therefore
a proxy/adapter which itself carries a borrowed lifetime and is ~Escapable
cannot instantiate the candidate's proposed unchanged generic types.

Making the proxy an ordinary escaping raw-pointer wrapper permits conformance,
but does not make its lifetime depend on a separately stored nonescapable lease.
Existing geometry properties/returned-workspace types can transfer that wrapper
as an escaping value. A lease retained by a host can constrain the host; it
does not automatically constrain a copied geometry or bank adapter extracted
from it. The candidate provides neither an exact carrier chain nor access/
visibility restrictions proving such values cannot escape or be used after
the geometry local/typed bank lifetime. Do not erase this issue by labeling
the wrapper an ordinary owned generic argument. This rejects the supplied
proof, not every possible private unsafe adapter implementation.

## Interaction slot ownership

The existing2412-byte slot is initialized as one `CounterStaticKeys?`, containing
an `InteractionOwnedKeyState`/`InteractionState` and five owned typed banks.
It is not free space containing independently initialized bank objects.
`withBacking` exposes borrowing bank values, not mutable ownership of the
private bank fields. One cannot bind five new banks over that live optional,
continue `interaction.take()` as before, and also have adapters mutate the
same bytes: that would mix overlapping initialized owners and divergent state.

A valid replacement would have to change the Embedded slot's initializer,
typed binding, metadata owner and deinitializer together. It must establish
five disjoint typed physical banks, one live adapter-state owner, and no second
old keys owner. Committed/hit `exchangeContents` must preserve distinct banks
and exact logical commit/reset semantics; deinitialization must follow physical
initialized objects even if adapters exchange their pointers. All partial
construction/failure/teardown paths and existing identities/counts must remain.
No exact byte/layout audit is warranted until the lifetime/conformance model
above is settled. Capacity arithmetic alone cannot resolve that model.

## Smallest next options and authority boundary

1. **Stay within existing portable contracts.** Revise the design to keep the
   existing owned Interaction generic arguments and solve the fixture's
   construction transfers without borrowed bank conformers. A geometry-only
   change may use a genuinely scoped fixture geometry contract and explicit
   lifetime propagation through fixture supplied/pipeline/state types, while
   keeping owned/native returned-workspace paths separate. Those fixture-local
   design changes are permitted by existing P08 authority. They are not a
   promised stack repair: inline interaction/identity and construction copies
   remain, and final nested fit would still need evidence. No source attempt
   is selected here.
2. **Pursue scoped Interaction adapters as contract work.** If the chosen design
   requires lifetime-dependent generic storage, explicitly propose how the
   portable Interaction protocols, state types, ownership/transfer behavior
   and affected users support ~Escapable storage. That changes actual
   cross-module generic/lifetime contracts and must go to the maintainer through
   the normal Specification/architecture routing before implementation. Do not
   silently add those relaxations under this fixture candidate. The current
   packet does not establish that such a change is necessary for P08 or choose
   its architecture.

A revised owner-private pointer-adapter alternative would first need a concrete
proof of its restricted construction/extraction/use and full carrier lifetime;
the unreviewed phrase “explicit lease” is insufficient. It must also resolve
the old-slot ownership replacement above. It is not an automatically allowed
third implementation experiment. No human gate is inferred for design-only
work within existing contracts; the genuine boundary is adopting a changed
portable contract, not an internal file list.

Recommended disposition: keep this combined candidate unimplemented. Present
the real scoped-Interaction contract option to the maintainer only if that is
the desired direction; otherwise produce one ownership-preserving fixture-only
design under option1 for independent review. No compilation or byte-perfect
layout exercise precedes that semantic choice. No claimed compiler bug or
need to enlarge stack/heap/RAM or reduce workload follows from this review.

Maintainer-facing choice: retain the present portable contracts and pursue an
unproved fixture-only design, or authorize preparing a scoped Interaction
contract amendment for review. Choosing amendment preparation would not approve
that amendment, its architecture or implementation. No pointer workaround or
new source attempt is accepted by this decision packet.

Source63e717d1 and its four-route/link passes remain separately qualified;
actual58648-byte construction frame still fails27648. Capture1/1 and all
historical allowances stay closed; no repair/diagnostic count is consumed or
reset here. Package two-consecutive-unproductive rule unchanged. P08/R07/T8.1
open, SPEC-015 implementing/plan active; P09–P12 and hardware untouched.
