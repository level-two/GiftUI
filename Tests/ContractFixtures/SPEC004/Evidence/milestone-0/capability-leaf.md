# SPEC-004 Capability Leaf Evidence

Plan task: `T0.2`

Date: 2026-08-29

## Package graph

The root package exposes `GiftUICapabilities` as a library product backed by
one regular target with zero dependencies. `GiftUICapabilitiesTests` depends
only on that leaf. The SPEC-002 exact-set graph fixture now contains eight
targets and preserves the existing GiftUI, failure-core, and optional
diagnostic edges unchanged.

`Tests/ContractFixtures/SPEC004/target-boundaries.yaml` records the active leaf
and focused test target plus the complete forbidden higher/concrete import
set. Compile and compiled-module inspections are added by T0.4; this task
establishes the fail-closed expected graph they will enforce.

## Lifecycle transition

Production implementation began in this step. The governing records now agree:

- SPEC-004: `implementing`;
- SPEC-004 implementation plan: `active`; and
- `capability-system` manifest stage: `implementation`.

No architectural or contract status was approved by this transition. No
runtime, backend, host, driver, failure adapter, remote access, deployment, or
flashing was introduced.
