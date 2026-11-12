# Future Work

Future Work is the cheapest durable capture for ideas, optimization
opportunities, unanswered questions, and intentionally postponed decisions.
It is not a backlog commitment or architectural authority.

- Semantics and statuses: [Documentation Rules](../engineering/DOCUMENTATION_RULES.md)
- Capture and promotion flow: [Feature Lifecycle](../engineering/FEATURE_LIFECYCLE.md)
- Starting point: [Future Work template](../templates/future-work.md)

Use `fw-NNN-short-slug.md` and the next unused `FW-NNN` ID. Cross-link the
source artifact in the same change. A Future Work item may remain short and
does not require a feature-manifest entry merely to be captured.

FW-034 is reserved in the [preparation archive](../iterations/iteration-003-review/preparation-archive.md); FW-035 is retained by the reconstructed preparation. Check existing artifacts and reservations before allocating the next ID.

- [FW-040: Compiler-Specialized View Derivation](fw-040-compiler-specialized-view-derivation.md): candidate investigation for a future performance-focused iteration after runtime-derivation conformance, or earlier on a measured resource problem.
- [FW-042: InlineArray and Span for Fixed Buffer Storage](fw-042-inline-array-and-span-storage-assessment.md): ITERATION-005 I5-01 assessment of tuple-buffer replacement with precise allocation, ownership and lifetime evidence; adoption remains separately gated.
- [FW-043: Assess Bounded Counter Trace Writing for Linux Dynamic](fw-043-linux-dynamic-bounded-counter-trace.md): candidate resource-proof optimization; deferred until an exact current Pi stdout oracle or supported local ARMv6 runner exists.

- [FW-046: Non-integration Scoped Storage Residuals](fw-046-non-integration-scoped-storage-residuals.md): preserve RFC-015 residuals excluded by evidenced iteration-4 dependency classification; no full conformance or iteration-5 assignment implied.

## Vision-related opportunities

These captures originated in the [long-term vision](../VISION.md) discussion.
They preserve specific questions without assigning delivery milestones. Each
item records its own evidence needs and revisit triggers; none depends on
building the whole platform vision first.

| Capture | Question preserved |
| --- | --- |
| [FW-022: Target simulator](fw-022-contract-accurate-embedded-target-simulator.md) | Can production owners support useful target previews and reproducible interaction/capture comparisons? |
| [FW-044: Resource accountability](fw-044-resource-accountability-development-loop.md) | Can predictions, build costs, and runtime observations be compared and attributed for one workload? |
| [FW-007: Realization planning](fw-007-cost-aware-capability-planning.md) | When do measured trade-offs justify more than explicit target policy? |
| [FW-045: Frontends and migration](fw-045-frontend-neutral-migration-platform.md) | What can a representative existing UI or alternate frontend express through GiftUI, and where are the gaps? |
| [FW-035: Generated graphs](fw-035-generated-view-graph-for-interchangeable-frontends.md) | Does a concrete frontend consumer actually need graph generation? |
