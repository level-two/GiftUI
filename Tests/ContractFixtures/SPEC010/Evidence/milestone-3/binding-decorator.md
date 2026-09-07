# SPEC-010 T3.2 Binding Decorator Evidence

`ObservableStateBindingDecorator` is a package-generic owner-side decorator
over one typed `ObservableStateReconciler`. It copies the borrowed declaration
once, drives the macro-generated state-host witness on that mutable transient
copy, moves the updated reconciler back to its caller-visible value, and calls
the body exactly once only after complete successful binding.

The generated fixture contains two direct wrappers. Focused tests observe
declaration ordinals `[0, 1]`, the same structural identity for both, original
initializer values through the bound copy, and one body call after the second
binding. Both exact encounter successes, `.materialized` and `.preserved`, are
accepted. An unexpected success fails closed as `.invariantViolation`.

Failures at the first or second wrapper preserve the exact
`ObservableStateError`, stop all later binding work, and suppress the body.
The decorator stores no declaration, wrapper, binding, body, model,
existential, dynamic collection, reflection state, task, or profile-specific
payload after return. The reconciler remains the sole owner of association
effects.

The registered audit proves the fixture uses `@ObservableStateHost` rather
than a handwritten witness and rejects suspension, reflection, dynamic
storage, failure-owner imports, runtimes, backends, and platforms. SPEC-006
T5.2–T5.3 may now compose this exact seam without interpreting observable
state or importing `GiftUIObservableState` into Semantic Core.
