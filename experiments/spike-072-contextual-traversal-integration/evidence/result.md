# SPIKE-072 terminal result

**Supported bounded integration mechanism; full application feasibility remains
unproved.** Completed on 2026-10-10 within the 90-minute and 64-invocation bounds.
The [ledger](ledger.json) retains **60 compiler/executable invocations**, including
all failed trials. Five repairs were made: the executor explicitly extended its
initial four-round estimate for a missed multiline leaf declaration. This is a
recorded process deviation, not compliance with the original repair ceiling or
an additional maintainer approval. See [repair history](repairs.md).

## Evidence

| Gate | Result and precise scope |
| --- | --- |
| Actual traversal and drawing source | Adapted copies of SemanticExpansionTraversal and CanvasPlanProducer/CanvasInvocationSource; all changes/hashes in adaptations.json and per-file diffs |
| Four-configuration positive builds | macOS Dynamic, macOS Static, ARMv6 Pi Dynamic and nRF Embedded Static pass after repair; initial monolithic positive trials 11–16 |
| Separate module boundaries | Seven modules plus application compile on all four configurations, trials 17–50; no Runtime module is built or imported |
| Final native behavior | **111 checks, zero failures on each native profile**, trials 55–58; final target application objects pass trials 59–60 |
| Parent read versus child discovery | One control rejects with the intended overlapping-access diagnostic on all four configurations, trials 51–54 |
| Source controls | Six unsupported source variations rejected; changing the selected property changes generated output; initializer ABI mismatch rejects |
| ARM ABI | Pi object reports v6/VFP-register arguments; nRF reports Cortex-M4, v7E-M, Thumb-2, VFPv4-D16/VFP-register arguments |
| Complete application coverage | **Not covered**; source inventory identifies counter modifiers/actions/current writes and analyzer capture/helpers/mutations outside this grammar |

## What the behavioral checks establish

The generated root and nested custom host both have non-Never concrete Body
associations. Real traversal binds/evaluates each once, follows runtime true/false
branches, returns owned child values, then discovers and seeds the nested entry
in the same frozen frame. Independent expected paths and counts verify two body
evaluations, eight structural occurrences and four semantic nodes in this corpus.
Repeated traversal ignores replacement seeds at existing fixture locations.

A poisoned scale getter is skipped when the left operand is false, and becomes a
typed access failure when evaluated. Body access failure and nested capacity
refusal remain distinct, discard the semantic candidate, and do not publish it.
Current scalar writes refuse while frozen. These checks cover the bounded fixture,
not production initializer/association/owner rollback semantics.

Three distinct Canvas values reach actual post-layout producer orchestration.
Drawing happens after semantic staging with values from the frozen child entry.
Ordered geometry observations distinguish their invocation order. A mid-list
DrawingError preserves its origin, closes the active path, and releases the
failing and pending occurrences exactly once. A drawing read error maps to
invalidScope and releases all occurrences before any path opens. Both success
and failure leave no Canvas values in the fixture source, while the frame stays
pinned until explicitly finished.

## Design finding

**A generic opaque-return method plus a broadly constrained leaf default was
not a valid View integration.** Trials 04/05 compiled, but trial 06 failed 45 of
81 checks. The SIL inspection in trial 09 proves Root.Body and Nested.Body were
Never. The corrected generator derives explicit concrete Body aliases and the
framework limits its default evaluator to a leaf marker. All final controls pass.
Authored `some View` remains a finite source form; automatic generic opaque Body
witness inference is not established. The frontend must establish each supported
body shape, reject unsupported cases, and preserve structural identity. This is
additional evidence for CE-2/CE-4, not transparent macro compatibility.

## Remaining gates

See [application coverage](../application-coverage.md) and [fixture limits](../README.md).
The production State/reconciler, current setter lowering/reporting, independent
owner/registration/frame tickets, capture backing, full Body-shape language,
Dynamic owner equivalence, exact nominal identities, immutable geometry plan,
full linked image resources and compiler-policy adoption remain unproved.
Only explicit source/ABI/module evidence was added; no production tests or
connected hardware were run. ADR-034's three-bank contract remains unchanged.

The evidence supports continuing the candidate at RFC stage. Do not rerun the
small borrow matrix or call this a complete application frontend. The next design
work is the finite source/effect contract and complete candidate application
inventory, alongside the separate C-P3 ownership/storage proof. Formal RFC/ADR/Spec
gates still precede production adoption; no follow-on experiment is opened here.
