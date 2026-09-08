# SPEC-009 T3.3 Pointer Capture Evidence

The focused capture stores only the exact `CapturedAction` identity-generation
pair. Down clears older capture before hit resolution and captures only when
the borrowed committed action view supplies one hit identity, a current
generation, and enabled state. Movement cancellation releases it immediately.

Release always clears the stored capture and yields an activation candidate
only after provenance, generation unambiguity, same-identity hit, unchanged
generation, and enabled state all revalidate. The matrix covers removal,
movement away, disablement, generation/target-record change, unavailable
lookup, ambiguous reuse, and unrelated commits that preserve the exact record.
No failed check dispatches or retargets old or replacement behavior.

```sh
swift test --filter PointerActionCaptureTests
ruby scripts/contracts/check-spec-009-pointer-capture.rb
```

The source audit rejects action values, target generations, callables,
handlers, models, revisions, dynamic erasure, suspension, and downstream owner
imports. Same-cycle semantic-action admission and dispatch remain T3.4-T4.2.
