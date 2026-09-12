# SPEC-012 Canvas Callable Lifetime Evidence

Plan task: `SPEC-012 T4.3`

Focused plan-production fixtures exercise zero-Canvas and zero-stroke attempts,
multiple normal invocations, first-call failure, and later-call failure. Every
invoked callable is released immediately after normal or throwing return. On a
failure, every uninvoked suffix record is released without invocation so no
publication-eligible callable remains. Per-identity release counts are exactly
one and later use is rejected by the fixture source's active-record guard.

The empty attempt acquires and seals one zero-total plan without entering a
Canvas context. A Canvas that submits no stroke still contributes one Canvas
occurrence and zero stroke, point, subpath, and normalized-operation totals.
All acquired failure paths discard once, reset once, and expose no plan.

Reproduce from the repository root:

```text
swift test --filter CanvasPlanProducer
scripts/contracts/check-spec-012-module-contract.rb
```
