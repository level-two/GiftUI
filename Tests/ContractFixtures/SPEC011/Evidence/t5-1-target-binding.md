# SPEC-011 T5.1 Target-Binding Evidence

`RuntimeInteractionCandidateCoordinator` reads the observable root's exact
publishable target generation once after successful encounter and supplies
that value to every Interaction append in semantic order. Recording tests cover
initial/candidate-only and changed target generations without consulting or
substituting a former live value.

The missing-generation case returns `missingModelTarget`, resolves the begun
Interaction candidate with `.discard`, and finishes the Observable State
candidate with `.discard` exactly once. No occurrence is appended or offered.

Reproduce with:

```sh
swift test --filter RuntimeInteractionCandidateCoordinatorTests
```
