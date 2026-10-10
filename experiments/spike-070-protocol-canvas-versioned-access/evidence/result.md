# SPIKE-070 terminal result

**Inconclusive across the four configurations.** The finite generated candidate
works in both native profile builds and compiles for ARMv6. The Embedded build
fails in test assertions after the two allowed repairs; required escape controls
and nRF resource inspection were not reached. This neither closes RFC-014 B1/B4
nor demonstrates that protocol Canvas or versioned properties are impossible.

## Observations

| Evidence | Result |
| --- | --- |
| Finite source transformation | Seven unsupported-use samples reject; three source perturbations change generated output. Only frozen reads are lowered; current mutation methods are handwritten. No complete source-checker or compiled-perturbation claim. |
| Lifetime policy, trials 1–3 | Default flags reject; LifetimeDependence alone rejects `@_lifetime`; LifetimeDependence plus Lifetimes compiles the same policy source without the old unsupported-annotation warning. Lifetimes alone was not tested. Still experimental policy, not adopted configuration. |
| Native Dynamic / Static, trials 6–9 | Both actual declaration compositions compile and execute 21 checks each. |
| Pi ARMv6, trial 10 | Composition compiles to an ARMv6 object; ELF attributes include VFP register arguments. No Pi execution. |
| nRF Embedded, trial 11 | Rejects two test assertions at `&&` right-hand scalar reads: “cannot use a value of protocol type 'any Error' in embedded Swift.” No successful nRF object. |
| Compiler-negative matrix | All 24 planned controls unrun. Prior SPIKE-069 negatives are not substituted for this candidate. |
| nRF sectioned build / rooted link / resource inspection | Unrun. No allocator, indirect-dispatch, nRF ABI or whole-image claim. |

The native checks cover scalar defaults and coherence, preservation of the
unchanged field into the next frame, indexed capture helper reads, foreign/
stale-generation/stale-frame/invalid-field/invalid-phase outcomes, repeated
Canvas occurrences with protocol leaf traversal, delayed drawing, a synthetic
layout-before-draw guard, real GraphicsContext path cleanup, body-access failure,
frozen-write refusal, revision copying and modeled dirty retention/publication.
Native strides: Transition 16, ModelKey 12, ModelOwner 72 bytes. These are fixture
values, not the complete proposed model/owner budget or target ABI accounting.

The two equal repeated Canvas values establish occurrence count and deferred
invocation, not a discriminating painter-order test. Failure is injected in the
first Canvas path, not halfway through the list. New State materialization,
retained former/replacement capacity, teardown ownership, source admission,
actual Layout and real publication remain outside the executed fixture. Do not
promote the 21 checks into all C-contract controls.

## Failures and stop

- Trial 4: fixture used a nonexistent Rect initializer. Repair 1 uses the actual
  failable origin/size initializer. Shared test helpers were also included in the
  negative-input recipe before any negative trial.
- Trial 5: the explicit lifetime checker rejects a read tied to a temporary
  `UnsafeBufferPointer` conversion. Repair 2 borrows the stored mutable buffer
  directly. The repaired source passes native and ARMv6 compilation.
- Trial 11: nRF rejects the two assertions described above. The local Swift
  interface declares `&&` with an untyped throwing autoclosure and `rethrows`;
  this explains the diagnostic location. A likely fixture repair is to evaluate
  each typed throwing read separately before combining owned Bool values, but
  **that repair was not applied or tested**. Further Embedded failures could
  remain behind this one.

The study stopped after **11 of 48 invocations and 2 of 2 repair rounds**, before
the 90-minute deadline. Its failure is not recorded as an architectural rejection
of C, and another invocation budget is not opened automatically. The lifetime
policy failures were planned observations, not repair rounds. Every failed trial
and its exact source/diagnostics is retained.

## Implication for the next decision

Keep C as the working RFC direction. The evidence supports a narrow mechanism:
source reads can be transformed into explicit context calls, owned key-bearing
Canvas values can be deferred, and actual GiftUI leaf traversal/GraphicsContext
can participate. It does not establish source compatibility: root evaluation and
the Canvas witness signature both changed in the disposable target code.

Before selecting final API or approving B1, specify the production contextual
View evaluation/failure seam, full finite getter/helper coverage and experimental
compiler policy. If the maintainer authorizes another proof, its first task is a
separately bounded assertion correction and Embedded positive build, followed by
the unrun escape matrix and resource inspection. Passing native tests is not
sufficient reason to skip those gates. Five-bank storage, actual owner tickets,
C-P3 integration and B0–B4 remain open. No production or accepted contract changed.
