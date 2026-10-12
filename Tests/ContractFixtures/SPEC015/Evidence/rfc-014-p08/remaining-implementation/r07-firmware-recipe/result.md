# R07 firmware recipe checkpoint

P08/R07 remain incomplete. This checkpoint preserves the implementation worker's
bounded existing-firmware recipe correction and exact failed validations. It is
not independent acceptance of the patch or a linked nRF image.

The recipe now reconstructs 24 separate selected owners from verified source
receipts, including fresh base GiftUI, under the existing firmware flags. The
new isolated directory is `.build/nrf52840/signal-analyzer-static/rfc014-counter-firmware`.
Historical route inputs and prior image attempt remain intact. No new runtime
configuration, resource ceiling, workload, compiler/SDK or hardware action.

Attempt 1 failed at macro execution because the existing `-disable-sandbox`
flag was omitted. Attempt 2 restored that flag. The first escalated recorder
request was canceled before execution; root retried that exact request and it
was approved. Session43658 completed; the recorder returned success for recording,
while the actual build exit_status is **1**. See attempt-2/invocation.json and
build.log for timestamps, exact command and patch identity. No build remains
running from this session.

Attempt 2 compiled the selected modules and reached Zephyr prelink. The earlier
undefined division, constructor and entropy diagnostics are absent. Its log
contains `.swift_modhash` orphan warnings followed by collect2 exit1. The actual
cause remains undiagnosed: current config selects orphan warnings, not orphan
errors, and warnings alone do not prove the cause. No further compiler attempt
was made. Partial map/config are not final ABI, allocator, RAM/flash or gross
stack-fit evidence.

Implementation and independent Strong workers repeatedly returned selected-model
capacity errors before completing this checkpoint's diagnosis/review. Root saved
this mechanical handoff without substituting another model or claiming review.
Resume with Sol6.1High: inspect the exact remaining linker cause, complete bounded
local repair if supported, validate actual image/resources and obtain independent
review. Escalate genuine contract/scope choices to the user. Historical helper2/2
and B031/1 stay closed; no same-blocker exhaustion is claimed. Earlier failures
were narrowed; no scope/resource relaxation is authorized.


## Sequential diagnostic continuation — 2026-10-12

[Exact frozen diagnosis](diagnosis/result.md) records four isolated link diagnostics,
all exit1/no ELF. Orphan reporting alone does not explain the failure; exact cause
remains unresolved. No compiler, recipe/source/config repair or hardware action.
Parent stopped further variants pending independent Strong review. Frozen333object/
archive/build-command identities and partial maps/logs accompany the result.
Final nRF ABI/zeroheap/RAM/flash/gross-stack evidence and R07/P08 exit remain open;
historicalhelper2/2+B031/1 closed, zero production repairs in this continuation.


## One reviewed GOT-placement control — 2026-10-12

[Exact one-link result](got-placement/result.md): actual exit0, isolated diagnostic
pre0 ELF/map, all346frozen inputs unchanged. Sole reviewed script block change
retains20bytes of GOT including swift_initStackObject/swift_setDeallocating entries;
RasterFillCoverage.swift.obj intersection survives. This narrows the frozen
failure to its script/GOT interaction, without accepting FLASH placement or
a production correction. Budget1/1 consumed; STOP for independent Strong review.
Final supported nRF image and R07/P08 exit remain open; no compiler/config/
runtime/limit/source change or hardware action.


## Reviewed production image — 2026-10-12

[Final supported image result](production-attempt/result.md): sourcee5620a35,
one build exit0, final ELF/HEX/map, ARMv7EM/VFP/zeroheap and linked RAM31616/
flash297604 checks pass. GOT20bytes are inside accounted ROM with no RAM copy
or remaining relocations. **Gross-stack FAIL:** actual root calls graph32344bytes
then host121216bytes, each above unchanged mainstack27648. No target execution
or follow-on repair; budget1/1 consumed. STOP for independent Strong review of
the failure and whether approved backing/layout permits local realization.
R07/P08 remain open; no speculative contract/ceiling/workload/runtime change.
