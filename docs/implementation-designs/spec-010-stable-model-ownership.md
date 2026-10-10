---
spec: SPEC-010
feature: observable-reference-state
title: Implementation Design — Stable Model Ownership
status: current
authors:
  - codex
created: 2026-10-10
updated: 2026-10-10
implementation_plan: ../implementation-plans/spec-010-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Stable Model Ownership

> This note explains the P03 realization of the approved contract. It does not
> amend architecture, contract, production capacities or source scope.

## Purpose and authority

[SPEC-010's model ownership and replacement amendment](../specs/spec-010-observable-reference-state.md#model-read-ownership-and-mutation-contract)
and [ADR-036](../adrs/adr-036-scoped-model-access-and-bounded-ownership.md) require
live backing before key validation, distinct identity namespaces, checked writes,
scoped reads, separately bounded ownership and exact replacement cleanup.
P03 / T10.1 realizes OS-RD-001–004. SPEC-015 selects two model metadata slots,
four application/candidate tickets, two distinct-model frame pins and one analyzer
capture entitlement (zero for counter). P07 owns complete-cycle integration;
P08/P09 own complete host/application adoption; P11 owns full resource proof.

## Organization and backing proof

The existing Dynamic and Static model-storage files own their concrete model
buffers and ownership ledger. Static keeps initialized typed InlineArray storage
in caller-owned memory before activation. Dynamic keeps the same bounded pools
in a retained object. There is no new module or migration conditional.

GiftUIObservableState owns the profile-neutral ownership transitions and the
scoped access adapter; it does not allocate model or capture storage. The two
profile factories lend a MutableSpan of their initialized model buffer and an
exclusive borrow of their separate ledger. The adapter invokes the complete
activation callback inside both standard-library pointer-lending callbacks.
Those callbacks establish actual backing lifetime, initialization, alignment and
bounds. A borrowed pointer descriptor by itself would establish none of them.

The adapter's private constructor cannot be called outside that factory. Its
noncopyable, nonescapable scope is lifetime-dependent on the descriptors whose
validity the surrounding callbacks establish. The callback returns an Escapable
result. Application tickets inherit the scope's lifetime and cannot be returned
or captured beyond activation. A copied ModelKey remains an owned, nonowning
value and may leave the callback; later access still needs a live scope and exact
identity validation. Compiler controls reject ticket escape and an overlapping
borrow of the caller-owned Static storage. Dynamic's separate activation guard
rejects reentry before accessing its already-borrowed pools.

## Identities, claims and reclamation

The host keeps a noncopyable owner-instance namespace across replacement
assemblies. Each store keeps a separate noncopyable allocation namespace.
Checked UInt32 issuance never wraps; registration/target generations remain in
their existing namespace. Reusing a model slot consumes a fresh allocation
identity even after a failed candidate reservation.

The ledger contains two metadata records and four claim records, never model
payloads. An internal claim descriptor is bookkeeping, not an application owner;
the noncopyable scoped ticket carries its one explicit release obligation.
A released ticket retains only a stale, nonowning key and cannot release again.
Claim serials prevent an old descriptor from releasing a reused claim slot;
exhausted serial space refuses another claim without wrapping or changing owners.

Application claims, structural registration and one pin per distinct participating
model are counted independently. Repeated reads share the model's existing pin.
Detach ends registration but leaves independent claims valid. Reclamation returns
the exact slot to the profile only when claims, registration and pins have all
ended; the profile then destroys the initialized model. A frame pin can therefore
outlive a body read, and registration can outlive the entire frame-reading interval.

## Phases and read scopes

The ledger distinguishes mutation, frame reading, State discovery, guarded
replacement and retirement. A single active read scope prevents child discovery
and writes until the body returns an owned declaration. Frame ownership continues
while discovery reserves inert new State and while Layout/Canvas use that frame.
Discovery cannot acquire independent owners of or mutate an existing model.

A read constructs two finite typed descriptors over the still-owned model buffer
and separate metadata. Binding checks phase, owner, schema, occupied slot and
allocation generation before model access. The frame must already pin the model.
Only the generated/trusted domain bridge sees these internal descriptors;
authored code sees the SPEC-006 facade with owned scalar results and checked
indexed access. The descriptor array itself lives inside the read callback, and
FrameRead cannot escape it. Ending a read preserves frame pins; ending the last
frame read releases pins and reclaims only otherwise-unowned models.

## Guarded replacement and callback integration

Compiled State now stores either an initial schema seed/candidate descriptor or
a bound location slot, declaration ordinal, registration generation and typed
model key. It has no resolver/replacement closures. The initial descriptor is
discarded when binding; a bound value cannot retain another seed. An unbound
generated read throws invalidPhase before resolving model storage. Copying a
bound State copies only the nonowning descriptor.

The existing macro tool lowers inventoried authored model constructors into
owned seed structs and State reads into checked key/facade reads. The host
macro recognizes the resulting generic State attribute. Explicit authored
`State(wrappedValue: model)` initialization becomes a candidate key descriptor;
the host must still present, validate and explicitly transfer its corresponding
owning ticket during new-location binding. The descriptor alone neither owns
the candidate nor authorizes attachment. The scoped root now validates the matching candidate ticket and transfers its
claim to the separately retained registration only after real attachment
verification. Preserved locations discard fresh seeds without attachment. The
lexical visitor join remains pending.
Effectful/malformed seed construction, computed State and unsupported local
shadowing fail before generated output is emitted.

Reservation validates mutation phase, current identity/association, generations,
the transferred final claim, metadata/claim/backing capacity and registration/
staging capacity before touching candidate data. Installed-empty A still owns
the sole analyzer capture entitlement. Retained A or a second populated B refuses.
The ledger reserves B's metadata and claim while A remains installed and owns the
bank, then blocks reentrant reads, writes and ownership changes.

The scoped root constructs B's actual empty seed and invokes the existing
registration lifecycle verifier through the real model attach hook under that
guard. Precommit failure detaches only a successfully
attached candidate and releases candidate reservations once. Commit retires A's
registration, transfers its final claim and bank entitlement, and activates B.
The profile resets B's count/baselines without copying or clearing the bank.
No source/admission storage participates. Later draw failure cannot reverse commit.

Model data, registration/dirty state and operation-result storage remain disjoint
so synchronous reporting occurs after the mutable model borrow ends. Generated
scalar/compound writes perform fallible preflight followed by non-failing commit;
no full-capture rollback value is created. Teardown must quiesce admission/handoffs,
retire registrations and invalidate generations before releasing backing last.

The scoped adapter now brackets nested discovery and finite checked mutations.
A concrete storage model supplies a borrowing preflight and non-failing commit
witness; this avoids a noncopyable associated-type dependency. The mutation
borrow ends before synchronous reporting, while the ledger remains guarded
against reentrant mutation/retention until reporting returns. Preflight failure
changes no bytes; report failure preserves already committed bytes.

The existing Dynamic and Static root adapters now lend actual model and
registration storage into one nonescapable root callback. That root implements
new/preserved State binding, explicit candidate-ticket transfer, guarded
replacement, candidate publication/discard and registration shutdown. Reports
travel through the model-owned sink into the disjoint registration record.
Shutdown retires routing before detach; the owning activation then releases all
remaining nonescapable claims and destroys model values before backing ends,
without resetting allocation or claim serials.

The lexical generated visitor, target-access join and complete application
operation witnesses remain pending in P03 and the named downstream consumers. The ledger and typed backing checks are incremental
evidence, not a claim that these remaining callback obligations already pass.

## Resource and validation boundary

The ledger stride is 188 bytes on all four tested profiles, including its bounded records,
claim serials, namespaces, phase and replacement reservation. Profile model data,
the Dynamic object, scoped tickets, two read descriptors, registration, frame and
callback stack costs remain separate charges. The analyzer's three transition
banks remain 19,392 bytes; this ledger reserves no transition payload or fallback.
Each model metadata record is 16 bytes, with its one-byte frame pin at offset
11. Claims and claim records are 16 bytes, scoped tickets 20 bytes aligned to 4,
and replacement bookkeeping 56 bytes. With the fixture's UInt8 structural
identity, each actual registration record is 36 bytes and root storage 84 bytes.
Read-slot/scope/sink strides are respectively 24/32/24 bytes on native macOS and
12/16/16 on ARMv6/Embedded. The final exact-path identity and application model
payloads remain separate charges. Compiler IR supplies target layouts without
claiming target execution. P11 linked heap/stack measurements remain separate;
the callback fixture has allocation symbols, so it is not zero-heap evidence.

The focused suite exercises the production ledger and both concrete backing
factories, not a substitute owner. Its current boundary is recorded in
[P03 progress](../../Tests/ContractFixtures/SPEC010/Evidence/rfc-014-p03/progress.md).
The historical [binding/report note](spec-010-binding-and-report-routing.md)
retains unchanged association and first-failure semantics; its old raw-reference
binding realization is superseded by the approved amendment and this P03 work.
