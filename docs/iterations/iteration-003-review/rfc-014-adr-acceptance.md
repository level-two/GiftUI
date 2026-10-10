# RFC-014 ADR acceptance — 2026-10-10

Eugene explicitly instructed: “Let's accept ADRs and commit everything. And after
that let's proceed with specs update.” This accepts the three proposed records
presented in the preceding response:

| Record | Presented commit | Accepted decision |
| --- | --- | --- |
| [ADR-035](../../adrs/adr-035-runtime-derived-records-and-exact-identity.md) | `b304d202` | Runtime records, exact identity and bank publication/retirement. |
| [ADR-036](../../adrs/adr-036-scoped-model-access-and-bounded-ownership.md) | `820ddfcd` | Fixed-domain access, stable ownership and three-bank bounded refusal. |
| [ADR-037](../../adrs/adr-037-protocol-canvas-and-scoped-post-layout-drawing.md) | `53740a73` | Protocol Canvas and preserved scoped post-layout lifecycle. |

All three are now `accepted`. As explicitly described in the presented ADR-037,
it supersedes [ADR-028](../../adrs/adr-028-post-layout-canvas-derivation-and-cycle-local-plan.md).
The predecessor's decision text is preserved; reciprocal metadata records the
transition. ADR-034's three-bank reservation and capture behavior are unchanged.

The same instruction authorizes preparation of the affected Specifications.
It does not approve unwritten contracts, authorize production migration, certify
conformance or open another investigation. The prior implemented Specs at `53740a73` describe the retained production
baseline. SPEC-001/012/013, which directly named ADR-028 as governing authority,
are reopened as amendment drafts and now reference ADR-037. Their conflicting
closure/access realization must be amended under the accepted architecture
before migration. The
[handoff](rfc-014-implementation-handoff.md) keeps source coverage, real owner
integration, resource proof and all IH-2–6 acceptance work mandatory.
