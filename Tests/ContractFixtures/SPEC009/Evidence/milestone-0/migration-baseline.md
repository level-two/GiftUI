# SPEC-009 Migration Baseline

Plan task: `SPEC-009 T0.4`

The machine-checked `migration-inventory.tsv` pins the immutable `PoC` tag at
`d5d6330432caa7c983d8dba35cf9f23c3800860b`. Its path/count maps cover the
prototype's immediate invalidation, direct action dispatch, reentrancy guards,
runtime-owned render operations, retained/replayed frame state, closure or
model capture, stale hit-map routing, and platform-to-runtime action path.
The absence of a named unbounded execution queue in both the PoC and current
maintained Swift is retained as an explicit zero-occurrence row.

The 49 rows reproduce 46 immediate-invalidation, four direct-dispatch, nine
reentrancy-guard, 30 runtime-render-operation, nine retained-frame, 23
closure/model-capture, 45 stale-hit-route, and four platform-action-path
occurrences.

The historical runtime combined semantic/layout/render/input work in
`GiftUIApplication`, `DynamicRuntime`, and `StaticRuntime`; stored a heap-backed
`DisplayList`, previous-root damage state, action closures, hit regions, and a
pressed action; and let Linux and simulator hosts call the runtime's input
method directly. These paths are retired or assigned to the approved focused
owners. Evidence-only test rows preserve provenance without adopting their
mechanisms or claims.

The eight former `GiftUIExecutionContract` placeholder references across the
SPEC-002 through SPEC-005 boundary fixtures and checks were replaced by the
real `GiftUIExecution` owner when its first compiling source landed. The
migration check now requires the obsolete name to be absent without creating
an alias target or compatibility shim.

`scripts/contracts/check-spec-009-migration.rb` reproduces every PoC
path/count map, checks the explicit absence row, and requires the obsolete
placeholder to remain absent. Its maintained-source scan rejects the removed execution,
display-list, callback-action, and stale-hit-map types so none can return as a
second execution path. This check is standalone until T0.3 creates and
registers the SPEC-009 driver.

Reproduce from the repository root:

```text
ruby scripts/contracts/check-spec-009-migration.rb
```
