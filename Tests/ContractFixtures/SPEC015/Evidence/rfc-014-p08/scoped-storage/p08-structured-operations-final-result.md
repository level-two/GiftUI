# P08 structured operations — final focused result and resource boundary

**STOP: current focused behavior/layout PASS; required construction stack FAIL.**
Source `597dbd7f`, independent SOURCE review `3ce6f91f`, passing receipt checkpoint
`37ae3bd3`. Correction2/2 is consumed and this bounded package is closed; no third
automatic source variant. Historical closed budgets remain closed. This result
does not authorize a new representation, limit, resource waiver or contract change.
No compiler/runtime/image execution was added by this read-only analysis.

## Actual current evidence

The [receipt manifest](structured-operations-cycle2-collections/result.json), SHA256
`3c5a228ea447fab159efaa64dc7b9b668a6f9d1162e03648d2d776fd54af4033`, pins
exact receipts/commands/compiler/inputs/logs in
[the verified compressed packet](structured-operations-cycle2-collections/focused-receipts.tar.xz),
SHA256 `feea96e0d4b5b9657a8ed527f54043770f575c5602baf505935880c535cecf62`.

| Current focused collection | Passed | Explicitly omitted | Native assertions/failures |
|---|---:|---:|---:|
| nRF52840 Embedded | 25 | 202 | not executed |
| macOS Dynamic | 42 | 384 | 1,736,244 / 0 |
| macOS Static | 42 | 384 | 1,736,320 / 0 |

Both Native collections pass all13 reuse labels,5 exclusivity and2 projection
controls. The3,472,564 assertions have zero failures. All three receipts are
fresh-focused/focused-passed; collection_complete=false and passed=false. These
are functional/loan/control passes for the selected checks, not full acceptance.
There is no current functional failure or compile failure.

Current strict160 roots retain active cursor34713/alignment8, four34720 slots
(138880 total), metadata15760 and donor tail18960. Object
`.build/nrf52840/contracts/p08-counter-ji2g9krm/P08CounterRuntime.o` SHA256:
`ab282982f862af35cf75f2f81ec09ca5733176ff7b834ff29b4c6ed12877291e`.
No old object measurement is substituted for current code.

## Decisive required main-stack lower bound

The [analysis manifest](structured-operations-cycle2-analysis-manifest.json) pins
selected prologues, exact symbols, linked symbol-table/index relocation targets,
commands/script and trust-critical complete bodies in
[the analysis packet](structured-operations-cycle2-analysis.tar.xz), SHA256
`5cce14b823bcaacfca432cb30ac3a0e288d976b0863af7ed31e7749bab1139b0`.
`required-cold-path.json` records the following **simultaneously retained** subset:

| Source operation / current ELF section | Entry frame bytes |
|---|---:|
| two-host4254 → one-host4285 | 3624 + 4064 |
| original model lender210 → root body4022 | 520 + 1104 |
| original semantic lender10396 → body4029 → scoped body4033 | 520 + 1056 + 336 |
| original owner.withStorage3426 → session3983 | 3056 + 3824 |
| cold host constructor3968 → actual nRF host factory3979 | 8408 + 3360 |
| **Selected required construction lower bound** | **29872** |

This exceeds main27648 by **2224** before omitted outer factory/corpus/custody/
dispatch, callback thunks, remaining original bank-loan callbacks, deeper factory
callees, alignment and IRQ. They are additional, not assumed zero. Alternative
Native/Embedded callback implementations are **not** summed. The constructor is
called on the main workload even though it returns before live host operations.
The current source's required twoHosts case calls each one-host operation with
failAfterRuntime=false, default early0 and candidateFailure=nil. Normal construction
reaches the original host factory; no rejected-binding-only alternative is used.

Actual direct BL relocations include4254 offsets88/144→4285,4285 offset508→210,
4022 offset486→10396,4029 offset242→3426,4033 offset208→3983,3983 offset178→3968,
and3968 offset1546/0x60a→3979. The original callback chain retains model→semantic→
canvas→fourteen actual storage loans→scoped body. Model callback literal13897
routes through14119→12061→12135→4022; semantic callback12349→4029 and scoped
callback12353→4033 are preserved in the packet. Forwarder costs are omitted from
the sum, not silently eliminated.

Current caller continuations prevent tail-frame removal:4254 must check/reconstruct/
run the second host/finalize;4285 shuts down the original root after its callback;
3426 calls original b0.withBorrow at0x112 and subsequently requires empty storage/
restores idle;3983 uses/cleans its one Optional host after construction. At3968's
factory BL0x60a the return address is formed from **sp+6240**; its8408-byte frame
is still reserved and the following branch enters a common epilogue. Frame entry
arithmetic includes sub/sub.w/**subw**, push/stmdb and preindexed stack stores.
For example3968 saves36, subtracts8320 then52;3979 saves16 and subtracts3344.
No dynamic adjustment uncertainty was reported for the charged entry frames.

The new cold session constructor3422 (1328) has already returned before the scoped
body; live host phase3960 starts after3968/3979 return; final cleanup4297 starts
after the second one-host return. None is incorrectly added to this cold path.
This is sufficient main-stack rejection, **not a complete upper bound**. No new
RAM impossibility is claimed:138880+29872=168752 alone is below196608, leaving
other current linked RAM/IRQ costs unproved. No current image was built or needed
to disprove the unchanged main-stack ceiling. Full202/image and broader omitted
profile controls remain held rather than being reported as accepted.

## Measured progress and remaining source attribution

| Operation | Correction1 | Final correction2 |
|---|---:|---:|
| two-host caller | 4632 | 3624 |
| full runtime-slot comparison parent | 2920 | 72 |
| actual backend equality leaf | in shared parent | 1216 |
| each full identity equality leaf | in shared parent | 848 |
| five emitted loan callback homes | 2784/3152/4400/2712/2136 | 1008/1008/1104/1096/1096 |
| selected cold construction subset | 30880 | 29872 |

Those callback alternatives are measured individually, never summed as one path.
The implementation preserved complete comparisons and improved their materialization;
the final rejection is not evidence that these changes failed semantically.

Remaining cost is concrete: `CounterScopedStorage.swift:2443` still passes consuming
session/semantic/values through supplied→pipeline owner→host construction and an
Optional host return; its current8408 frame nests the unchanged actual factory3360.
The one-host4285 frame4064, session3983 frame3824 and owner.withStorage3426 frame3056
remain simultaneously live along original scopes. Source location1173 holds original
inventory/capacity/physical-selection facts and nested field lenders; location2485
retains its one Optional host and original completion/defer. These identify source
and calling-convention regions; this analysis does **not** assign every byte to a
particular field, prove a new duplicate owner, or infer that logical contracts require
these exact frame sizes. Full upper-bound/IRQ/linked-memory/allocator accounting
and all nine SO/P08 acceptance obligations remain open.

The next decision must use this measured boundary. This package permits no further
automatic correction or unmeasured attribute/helper loop. Further work would need
an explicitly bounded, source-grounded realization or resource assessment with
its own authority; these results do not establish that accepted contracts must
change, nor authorize raising main27648/RAM196608. Independent result review is next.

Verification: both compressed packets' members matched their individual SHA256
manifest entries; actual receipt/object identities matched. Governance passes
(204 authority nodes/2036 edges;7 features/76 lifecycle artifacts/9 skills), and
`git diff --check` passes. Only the pre-existing pycache remains untracked.
