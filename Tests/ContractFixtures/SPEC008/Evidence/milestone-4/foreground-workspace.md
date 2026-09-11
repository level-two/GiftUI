# Foreground Workspace Amendment Evidence

`RenderProductionWorkspace` now exposes the approved exact current/push/pop
foreground operations. The focused workspace fixture binds physical stack
capacity to `maximumTraversalDepth` and proves inactive refusal, empty current
and pop behavior, exact LIFO values, equality success, one-over refusal without
mutation, high-water reporting, acquisition clearing, and reset clearing.

Both maintained render-workspace fixtures clear the foreground stack on every
successful acquisition and every reset. The render-production source audit
locks the amended protocol declaration and continues to reject dynamic storage
from the protocol-owning production source.

Run:

```sh
swift test --filter boundedWorkspaceReportsCapacityAndHasExactAcquireResetLifecycle
scripts/contracts/check-spec-008-render-production-values.rb
```
