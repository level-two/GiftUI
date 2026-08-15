# Spikes

Spikes are targeted, bounded prototypes, benchmarks, or experiments that
produce missing evidence. Their code is disposable and non-production by
default; their record must be reproducible and explicit about limitations.

- Semantics and statuses: [Documentation Rules](../engineering/DOCUMENTATION_RULES.md)
- Capture and promotion flow: [Feature Lifecycle](../engineering/FEATURE_LIFECYCLE.md)
- Starting point: [Spike template](../templates/spike.md)

Use `spike-NNN-short-slug.md` and the next unused `SPIKE-NNN` ID. Put optional
experiment code in `experiments/spike-NNN-short-slug/` and link it from the
record. A Spike feeds evidence to its parent; it cannot establish architecture
or authorize production implementation.
