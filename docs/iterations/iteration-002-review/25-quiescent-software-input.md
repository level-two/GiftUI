# Step 25 — Production nRF software input at service boundaries

The maintainer's request to proceed reopens the concrete connected corpus gaps
from Step 24. This step uses the unchanged production ELF SHA256
`c6d0f12c8585cad3f3949fb596e13fa7328989239a31a1f6e428afadb541ed5c`
on J-Link 683833660. GDB preserves registers on attach, halts at the production
`service` entry, admits against the current committed revision, and observes a
subsequent service boundary. It deletes breakpoints and resumes before detach.
No reset, flash or maintained implementation change occurs in these cases.

| Case | Observed outcome |
| --- | --- |
| Start | Idle/revision 1 → running/revision 2; two queued events drained |
| Stop | Running/revision 5 → stopped/revision 6; two events drained; eight capture records |
| Window 1s / 2s / 5s | Corresponding published action-code sets `[0,3,4]`, `[0,3,5]`, `[0,4,5]`; capture remains eight; each selected change advances revision once |
| Disabled Plus at 5s | Enabled lookup returns zero; gesture uses its previously enabled point; queued events drain with unchanged revision/window/capture |
| Move outside then Up | Down/Move/Up drain; revision/window/capture unchanged |
| Stale revision | Both events rejected with admission 258; queue zero; revision/window/capture unchanged |

Every completed case samples zero driver counters and CFSR/HFSR. DFSR's debug
bit is expected from breakpoints. These are actual production software-input
observations, not physical contact or complete independent semantic/pixel traces.
One revision increment does not independently count action dispatches. Disabled
Plus does not cover the separate overlapping-disabled fixture.

The earlier mid-frame Stop injection was inconclusive. A service-boundary Stop
now establishes the stopped outcome for this controlled method, without claiming
that physical input meets its deadline during a roughly22s synchronous frame.

## Reproduction and evidence

[Raw scripts/logs archive](evidence/25-quiescent-input-logs.tar.gz) and
[validated summary](evidence/25-quiescent-input.json) retain case details and hashes.
Run the reviewed `.gdb` scripts with `run-nrf-connected-gdb.py`; its optional
bounded timeout accepts at most 55s. `run-nrf-quiescent-corpus.py` prepares the
window/cancellation cases for this exact ELF. Start from a stopped 2s window,
then run window-one, window-two, window-five, disabled-plus, window-two,
movement-cancel and stale-revision. The final window-two log records restoration
from 5s to 2s. Software Start/Stop are preserved as their explicit raw scripts.

The first getter attempt found `hit_point` absent from the linked debugger
symbols; enabled `action_point` supplied the tested coordinates instead. A Clear
attempt found no UI hit target, as expected by SPEC-001, then requested an
unlinked `visible_window` getter and failed. It is retained as excluded evidence,
not a Clear test. Programmatic Clear belongs to the subsequent copied-application
experiment. These harness limitations do not identify production defects.

Validate archived evidence with the assertions in
`summarize-quiescent-corpus.py`; do not regenerate or overwrite this archive after
changing device state. Python syntax and the summary's behavior assertions pass.
No root/profile test rerun is needed for this research-only step.

## Disposition

The software Start/Stop, windows, disabled-control, movement and stale subset is
recorded. Physical provenance, independent full traces/pixels, exact-once and
transport/recovery coverage remain under [FW-033](../../future-work/fw-033-connected-validation-follow-up.md).
No acceptance criterion, exception, feature stage or cleanup selection changes.
