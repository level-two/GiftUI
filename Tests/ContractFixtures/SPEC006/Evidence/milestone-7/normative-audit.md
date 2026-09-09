# SPEC-006 T7.1 Normative and Scope Audit

The checked-in `normative-audit.tsv` maps all 24 normative areas from the
approved Specification to an existing stable evidence record and an executable
contract check. The inventory covers the public and module contracts, every API
seam, expansion/identity/action/modifier/atomic behavior, lifecycle, errors,
performance, compatibility, all four testing subsections, and the explicit
non-goals.

The dependency and forbidden-surface audit proves Semantic Core contains no
layout, rendering, observable-state ownership or invalidation, interaction or
input activation, capability selection, backend, frame, host, driver, or
connected-hardware policy. The only state-host contact is the approved generic
SPEC-010 traversal/binding seam owned above Semantic Core.

The immutable migration ledger is closed: every historical entry is classified
as removed, already absent, or replaced through the sealed SPEC-006 surface.
The repository-wide migration checker rejects restored proof-of-concept paths,
string identities, client traversal witnesses, compatibility shims, or a second
expansion engine.
