# A4 diagnostic-policy static check result

The user authorized one bounded A4 parser-policy implementation and static
check. After independent pre-execution review, the exact guarded invocation in
`../analyzer-abi-a4-diagnostic-policy-static-successor/invocation.json` ran once
and exited 0. Its raw stdout was:

```text
{"status": "STATIC_FIXTURE_EXPECTATIONS_MATCHED_ONLY", "inputs": 59, "output": "/Users/eugene/work/GiftUI/.build/contracts/p08-a4-diagnostic-policy-static-successor/static-result.json"}
```

The archived `static-result.json` has SHA-256
`5958a593b617f61284773636316f30a18936511ecf9fecb98eb097661a1c09a8`.
It records all 59 frozen inputs: 22 inherited and 37 new; eight accepted and
51 rejected as declared. The two accepted A4 display-note fixtures each record
one display-only note, excluded from dependency evidence. The missing-colon
malformed located note is rejected. No parser adjustment or retry followed.

This is static parser evidence only. Campaign2 A4 remains unqualified and
terminally stopped; P08/R07/T8.1 and all later compiler, profile and dependent
gates remain open. No compiler, producer, campaign, formatter or hardware step
was run by this static invocation. A new campaign requires a separately reviewed
recipe and allowance.
