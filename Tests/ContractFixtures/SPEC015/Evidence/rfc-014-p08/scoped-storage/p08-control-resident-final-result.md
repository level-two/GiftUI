# P08 control-resident package — final compilation boundary

**STOP: correction 2/2 consumed; source compilation blocked.** The final focused
measurement ran at `37ba818a` (source `999de5f9`), exited 1, and produced 23 passed
preparation checks, one failed counter module, one blocked layout check and 202
not-run compiler controls. `fresh_focused=true`; `focused_passed`,
`collection_complete` and `passed` are all false. This is not a layout failure:
there is no `P08CounterRuntime.o`, decoded raw layout or accepted layout receipt.
The new control extent is unmeasured; the old Swift/C 32,000-byte slot constants
remain unchanged. No current stack, runtime, resource fit or P08 acceptance claim
follows. P08/R07/T8.1/HC-RD-003 remain open.

## Exact preserved evidence

[Failure manifest](control-resident-cycle2-measurement-failure/failure.json)
pins the exact compiler, driver, applicability proof, source, wrapper invocation
and numeric statuses. [Compressed actual run](control-resident-cycle2-measurement-failure/actual-run.tar.xz)
contains the original receipt (all exact commands/input hashes), compiler log and
wrapper invocation/result/stdout/stderr. The exact failing source is separately
compressed. No historical receipt, freeze or review was rewritten.

| Artifact | SHA-256 |
| --- | --- |
| Build `p08-counter-uhsvmp_l/result.json` | `49896075e03463a7d2c7ac8902c47a7fcd94d7d8e168ffa330eed0f302716a9b` |
| `counter-model.log` | `db169588ecb7dbbb84c26c062a23f15cca8620864cfc0f6b893c038ce3b99019` |
| Wrapper `20261015T223200527615Z-control-resident-cycle2-measurement/result.json` | `dbd04c236b2d92d00c4fd4b0bde3a577b4828980d41687601fd3e981f9c47018` |
| `CounterPipelineOwner.swift` | `fdd9ca325c2e73b57ae3f8b183851b3de78b70fde8d9bb171adcbd6fcfd75b26` |

## Emitted cause and source audit

The two primary errors identify `CounterPipelineOwner.swift:73` and `:78`,
`CounterControl.requireVacantRuntimeSlot` and `requireRuntimeClaim`. The diagnostic
notes point at reads of borrowed `self` in **short-circuit `&&`/`||` RHS
autoclosures** on lines 74–75 and 79. The final `precondition` calls already read
owned Bool locals. Merely moving an assertion to a Bool local was insufficient
because its initializer still contains these implicit closures.

The prior eight implicit Copyable/Escapable constraint diagnostics are absent in
this run after the scoped extension bounds correction. This is progress through
compiler checking, not proof that all subsequent checks or code generation pass.
The historical independent SOURCE PASS reviews assessed their stated source
scope before execution; this result supersedes any current compilation inference.

The source audit covered added borrowing declarations and assertion/short-circuit
sites in the candidate diff `f7e56cf0..999de5f9`, including both profile variants:

| Added borrowed/helper surface | Same source pattern |
| --- | --- |
| `requireVacantRuntimeSlot`, `requireRuntimeClaim` | Confirmed by actual diagnostics. |
| `clearOwnedRuntimeSlot` | Reads idle/inactive separately; assertion combines only owned Bools. |
| Both `counterObserveBackend` variants | Direct scalar field observations; no assertion or Boolean RHS closure. |
| `counterProduceStoredEndpoint` borrowed semantic argument | Existing synchronous offer/published-view callbacks; no borrowed-self Boolean assertion. Callback lifetime acceptance is not established by this failed run. |
| `CounterRecordingObservation.init` | Explicit owned recording copy; equality combines owned local recordings. |
| Both endpoint observation/idle getters and slot observation initializer | Direct owned facts; no new borrowed-self Boolean RHS assertion. |

The new claim/install/quiesce/clear mutators use mutating `self`, not these
borrowing signatures. Their full predicates remain required. Unchanged borrowing
action/model helpers and all existing full fingerprint checks remain intact.
This finite source audit cannot establish absence of later compiler errors.

## Minimal proposed follow-up — not applied or authorized by this record

In only the two failing methods, first evaluate each original stored-field
predicate independently into an owned Bool, then combine **only local Bools**:

```swift
// requireVacantRuntimeSlot: seven independent facts
let phaseVacant = runtimeSlotPhase == .vacant
let ownerAbsent = runtimeSlotOwner == nil
let endpointAbsent = runtimeEndpoint == nil
let rootAbsent = runtimeRootIdentity == nil
let actionAbsent = runtimeActionIdentity == nil
let candidateRootAbsent = runtimeCandidateRootIdentity == nil
let candidateActionAbsent = runtimeCandidateActionIdentity == nil
let vacant = phaseVacant && ownerAbsent && endpointAbsent
let noKeys = rootAbsent && actionAbsent && candidateRootAbsent && candidateActionAbsent
precondition(vacant && noKeys)

// requireRuntimeClaim: four independent facts
let sameOwner = runtimeSlotOwner == claim
let installed = runtimeSlotPhase == .installed
let quiesced = runtimeSlotPhase == .quiesced
let endpointPresent = runtimeEndpoint != nil
let matches = sameOwner && (installed || quiesced) && endpointPresent
precondition(matches)
```

These are pure stored-field tests. Eager evaluation preserves every original
field/equality/phase fact and assertion without copying the whole active control,
refreshing the baseline, changing lifetimes or introducing a capability/owner.
The follow-up would require an explicitly bounded mechanical source correction,
fresh exact source/applicability pins, independent source assessment and the same
registered focused measurement invocation preserved in the wrapper. It is not
performed here; both current correction cycles and all older budgets are closed.
If compilation then succeeds, strict target facts must still precede any exact
Swift/C sizing completion. No guessed extent, decoder relaxation or fit guarantee
is proposed. Further diagnostics remain possible.

This boundary step performed only source/log inspection, hash/absence checks and
lossless evidence preservation. It made no maintained source change and ran no
compiler, build, runtime, image or test suite.
