# SPEC-002 Traceability and Adapter Ownership Audit

Implementation-plan task `T6.2` audits the complete reciprocal boundary among
SPEC-002, SPEC-003, and SPEC-004 and the provenance/action authority chain
through RFC-004, RFC-011, superseded ADR-013, and accepted ADR-033.

## Lifecycle review

- Current stage: `giftui-mvp-architecture` and `capability-system` are both in
  implementation; SPEC-002, SPEC-003, and SPEC-004 are `implementing`.
- Authoritative contract: the three Specifications remain mutually related;
  their respective accepted ADRs remain the governing architecture.
- Supersession: ADR-013 is preserved as `superseded`, identifies ADR-033 as its
  successor, and ADR-033 reciprocally supersedes it.
- Navigation correction: RFC-011 already supplies the approved action decision
  inherited by ADR-033 and referenced by SPEC-002, but its metadata/reference
  list omitted the reciprocal SPEC-002 navigation link. This task adds that
  link without changing RFC meaning, status, requirements, or decisions.
- Manifest: SPEC-002/003 remain registered under `giftui-mvp-architecture`;
  SPEC-004 remains under `capability-system`, whose dependency on the
  architecture feature is explicit.

No authority conflict, hidden decision, stale deferred-work promotion, or
missing approval gate was found in this review boundary. This audit does not
claim conformance: SPEC-002 `T6.3` and `T6.4`, the conformance review, and the
maintainer-only `implemented` transition remain open.

Linked Future Work remains non-authoritative and reconstructable: SPEC-002's
FW-005/FW-016, RFC-004's FW-010/FW-011/FW-014, and RFC-011/ADR-033's FW-021
retain source links, concrete revisit triggers, and no improper promotion.
The reviewed capability/failure deferred items and completed Spikes likewise
remain evidence or post-MVP capture rather than implementation authority; no
revisit trigger was established by this navigation/adapter audit.

## Package and adapter boundary

The exact graph keeps all three production owner leaves independent:

| Boundary | Location | Exact owner imports |
| --- | --- | --- |
| Foundation rejection to failure fact | `GiftUIFoundationFailureAdapterTests` | `GiftUI`, `GiftUIFailureCore` |
| Foundation extent to capability value | `GiftUICapabilityAdapterTests` | `GiftUI`, `GiftUICapabilities` |
| Capability unavailability to failure outcome | `GiftUICapabilityFailureAdapterFixture` | `GiftUICapabilities`, `GiftUIFailureCore` |

The capability/failure adapter is an unpublished test fixture. No target
imports all three owners, no foundational owner imports another, and no
adapter is placed in the `GiftUI`, `GiftUIFailureCore`, or
`GiftUICapabilities` leaf.

## Reproduction

```text
scripts/contracts/check-spec-002-traceability.rb
scripts/validate-governance.rb
scripts/contracts/run-spec-002.sh --profile macos-dynamic
```

The traceability checker is part of the standalone SPEC-002 driver. It fails
on a missing reciprocal relation, broken ADR supersession, manifest-stage or
feature-registration drift, changed adapter edges/imports, a monolithic
three-owner target, or publication of the test-only capability/failure
fixture.
