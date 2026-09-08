# SPEC-009 T3.6 Admission Seal Fault Evidence

The finite seal transaction injects failure independently at every
execution-owned reservation boundary: staged pointer transition storage and
complete batch storage. Either failure returns `capacityExhausted` with a
zero-count admission summary, commits no staged pointer or activation state,
and requests no sequence cancellation.

Stale or malformed pointer provenance and semantic-action overflow preserve
the first failure, zero all staged counts, and identify the complete affected
source sequence for mandatory cancellation. The fixture removes that entire
sequence while retaining unrelated queued work in original order. No
activation escapes the failed transaction. Finalization clears the workspace,
and a later seal reuses it successfully without inherited state.

The earlier admission-controller boundary fixtures complete the matrix:
active-source and full-queue refusal synchronously cancel the affected pointer
sequence, retain unrelated queued values, and after-seal arrivals remain
ordered for a later wake. The earlier sealer fixtures prove that a valid
per-cycle suffix is deferred, not failed.

```sh
swift test --filter 'ExecutionAdmission(SealTransaction|Controller|Sealer)Tests'
ruby scripts/contracts/check-spec-009-admission-seal-faults.rb
```

This focused transaction stages counts and cancellation identity only. The
Milestone 4 coordinator will own queue removal, wake emission, phase changes,
and the final `RunCycleResult` transcript.
