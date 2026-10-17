# Native cold Static candidate 1 — 2026-10-17

**Implementation candidate prepared; first actual cold screen pending.** This
implements the [reviewed design](../../../../../../docs/implementation-designs/spec-015-p08-native-cold-static.md)
under the maintainer's strict-contract direction and [independent design PASS](p08-native-cold-static-independent-design-review.md).
One candidate is now written; **0/2 corrective cycles used, zero actual candidate
profile runs** at this commit boundary. Previous allowances remain closed. The
11/336 accepted baseline failure is not replaced by compiler success, synthetic
zero controls or this candidate. P08/R07/T8.1 remain open.

## Source and ownership change

Native `CounterStaticRootStorage` owns concrete contiguous arrays of two model
slots and two semantic identities, the existing ownership ledger, nongeneric
registration control and schema/capture values. Embedded aliases the original
`StaticObservableRootAdapter`; generic callers retain their wrapper. All root
call sites, type measurements and explicit init/deinit/reconstruction sites use
the matching actual type together. Static root accounting derives model, pin,
live/candidate control and padding charges from the new physical fields and
`MemoryLayout<Self>`; no old byte-size promise or saving is assumed.

`ObservableStateRootControl` holds identity-independent registration fields.
`ObservableStateRootScope<Model,Identity>` retains its exact generic type, with
separately borrowed identity slots. Each former identity read/write/reset now
uses the corresponding slot. Model/root lifecycle, attachment failure cleanup,
replacement commit/discard, generations and first-error handling retain their
existing algorithms; the identity is cleared wherever its record is cleared.
Checked factory callbacks borrow the actual fields until shutdown and return.
The private constructor union adds `borrow identities` to the original model/
control/report dependencies; borrowedRoot/borrowedScope retain the union.

Model/read/root factory bodies and measured gesture/target/dispatch forwarding
are serialized. Unsafe constructors are module-internal, not package/public.
Four fresh source-client compile controls pass: legal borrowed access, rejected
model construction, rejected root construction and rejected root extraction,
all negatives for internal access. Serialization does not grant source access.

The fourteen loan callbacks, five banks, session token, Optional host destination,
G/C/R/H contracts and complete supplied/pipeline/coordinator/retired/activation
lifetime graph are unchanged. The concrete root replaces the outer root object;
it does not add an inventory entry or coexist with an initialized old root.
Failable root construction retains Swift's typed partial-initialization cleanup;
explicit outer reconstruction/deinitialization continues to operate on that one
matching type. Model/report retirement precedes backing destruction as before.
Actual fault, lifetime/exclusivity, cleanup/reuse and cold allocation outcomes
remain to be executed; no safety or zero-heap acceptance is inferred from typing.

## Exact allowlist additions

The reviewed root/action/fixture files change as described. These additional
files are compiler-required serialization visibility forwarding only:

- `Sources/GiftUI/DeclarativeView.swift`: existing read-span field/initializer.
- `Sources/GiftUIExecution/{AdmissionValues,ExecutionValues,ObservableTargetGeneration,PointerActionCapture}.swift`:
  action/generation/capture types and the existing capture operations referenced
  by serialized gesture/dispatch bodies.
- `Sources/GiftUIInteraction/InteractionValues.swift`: existing resolver/action
  view/result types and dispatch-read properties.
- `Sources/GiftUIObservableState/{ObservableModelOwnership,ObservableModelTicket,ObservableModelMutation,ObservableStateModel,ObservableStateValues}.swift`:
  existing ledger/read-slot/protocol/value declarations required by the checked
  model/read/root/target bodies. No new source-callable unchecked constructor.

One direct physical-layout consumer also required correction:
`Tests/ContractFixtures/SPEC010/RuntimeDerived/LayoutProbe.swift` now measures the
actual nongeneric control record and a separate typed identity slot, retaining
all19 historical labels and adding one. Its collector's exact export-count check
changes19→20. This repairs the removed nested-type reference and adds actual
physical coverage; it removes no assertion or expected behavior. Compile-only IR
extraction passes all20 exports ([constants/commands](native-cold-static-candidate/registration-layout.json)).
No SPEC-010 workload was executed.

The existing Static generic adapters need no source edit: their model factory
and root wrapper now reach the same checked bridge. No public API, capacity,
corpus, algorithm, compiler-policy or resource-limit change is made.

## Preparation, controls and handoff

The [recipe](native-cold-static-candidate/README.md), [compact preparation identity](native-cold-static-candidate/preparation.json)
and [exact compile/link commands](native-cold-static-candidate/preparation-commands.json)
freeze the prepared candidate. Nine owning/dependent modules (including the
fixture) compile. The ordinary, host-first, trace-free host-first and immutable
baseline host-first links all link. These operations do not execute a profile.
Source-access control sources/logs are preserved in the same packet.

Baseline wrapper compilation imports only original retained module interfaces;
all25 baseline object inputs and their owning receipts are hash-checked. Candidate
wrappers import the freshly rebuilt interfaces first and use the matching new
objects. Source-layout consumers are rebuilt rather than linking an old scope
layout against new implementation. Retained runtime/host dependencies keep their
explicit stale-original-manifest qualifications; preparation records their source
deltas without labeling them freshly compiled/current. Current compilation inputs,
compiler/plugin, images and collector sources are pinned before/after preparation.

The first preparation guard rejected historical nested `Package.swift` drift;
the corrected recipe records existing qualified retained-owner deltas. A later
preparation inherited the original wrapper module-cache location; the selected
current preparation uses disposable caches for every wrapper. No original object
or receipt changed, and no profile process ran in those preparation attempts.
They are collector/compiler preparation feedback, not concealed candidate screens.

Run exactly the recipe's first bounded comparison through the sequential runner.
It derives host-only counts from the frozen baseline `p08CounterHost`, compares
silent/ordinary host counts and cold/reuse equality, and requires the registered
route's unchanged1735019 count. Strict replay retains raw streams/full stacks and
failure flags. The diagnostic silent copies suppress exactly three successful
print statements, leaving assertions/error output and workload source intact;
they cannot certify the ordinary image. No common graph executes before the
host-first windows. Direct-zone/VM/temp coverage remains an explicit observer
limitation, not zero allocation. Classify any actual cold profile allocation,
including common Static construction outside11/336, before a corrective change.

Formatting, lint, source-access controls, compiler/link preparation, governance,
local links and maintained-source whitespace checks pass. Two trailing spaces in
the byte-preserved `root-extraction-negative.log` are original compiler output;
they are retained with its recorded hash. No full collection/image/hardware work
ran. Five external SignalAnalyzer/CMake/build edits and Python cache remain
untouched and excluded. Shared layout/code changes require affected fresh
conformance/resource evidence after the cold and lifetime screens pass; historical
Native/Pi/nRF packets remain immutable baselines, not candidate certification.
