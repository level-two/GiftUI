# SPEC-010 T2.2 Owner Protocol Evidence

`GiftUIObservableState` now owns the exact profile-neutral reconciler,
mutation-owner, and borrowed target-view protocols. Each operation preserves a
typed `StructuralIdentity`, `UInt16` declaration ordinal, and the one closed
`ObservableStateResult`; replacement consumes its candidate and reconciliation
borrows an `inout State<Model>` without selecting profile storage.

The target view exposes only optional opaque `ObservableTargetGeneration`
values. Its source contains no model, state wrapper, attachment, sink, handler,
callable, or mutating operation. Focused fixtures prove distinct live and
publishable lookup paths return values only for exact identity/ordinal keys.

Fixture-only bounded records account separately for all five normative logical
storage families: live location, registration, candidate association,
replacement staging, and runtime bookkeeping. The replacement record is
independent of permanent registration capacity and represents one staging
record only while its candidate is validated. These records are test evidence,
not production SPI or a selection of dynamic/static packing.

The registered audit enforces exact protocol ownership/signatures, package-only
visibility, absence of dynamic collections and existential/profile/platform
facilities, the restricted target-view surface, and presence of each logical
field family. Concrete reconciliation lifecycle remains T3 work.
