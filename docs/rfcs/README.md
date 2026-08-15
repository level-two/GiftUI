# RFCs

RFCs explore how an accepted Proposal should be solved. They preserve design
reasoning, alternatives, trade-offs, and open questions but are not
implementation contracts.

- Canonical semantics and statuses: [Documentation Rules](../engineering/DOCUMENTATION_RULES.md)
- Lifecycle gates: [Feature Lifecycle](../engineering/FEATURE_LIFECYCLE.md)
- Starting point: [RFC template](../templates/rfc.md)

Use filenames of the form `rfc-NNN-short-slug.md`. An RFC requires an accepted
Proposal and must be added to `docs/features.yaml`.

When review exposes a valuable question or optimization outside current scope,
capture it under [Future Work](../future-work/README.md) or
[Explorations](../explorations/README.md) and cross-link it from the RFC.
Keep any decision required for RFC coherence as an open approval blocker.
