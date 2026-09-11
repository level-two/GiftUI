# T4.5 Frame Evidence

Fixed and flexible frames now resolve each axis independently. Child proposals
cover exact fixed requests, parent pass-through capped by finite maxima,
absent-parent finite maxima, and infinity without invented space. Frame ideals
apply fixed/minimum/finite-maximum/infinite requests before the parent cap.

Top-down placement aligns the already measured child within the resolved frame
and intersects every frame scope with the inherited logical clip. Ordered
padding/frame tests prove the modifiers are neither commuted nor merged. The
focused 100-under-50 test distinguishes a fixed request, whose expanding stack
child remains 100 wide and overflows, from a minimum request, whose child sees
the 50-wide parent proposal while the frame's minimum remains unsatisfied.

Reproduce with:

```sh
swift test --filter LayoutStackTests
```
