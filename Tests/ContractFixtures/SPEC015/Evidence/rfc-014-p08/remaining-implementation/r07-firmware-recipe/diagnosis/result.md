# R07 residual prelink diagnostic checkpoint

Entry da087dd7; Sol6.1 High / Strong sequential continuation, 2026-10-12.
P08/R07 and SPEC-015 T8.1 remain open. This is a diagnostic checkpoint for
independent review, not a recipe correction, image pass or package approval.

## Exact bounded results

All four invocations reused the unchanged attempt-2 object/archive/config/linker
script inputs. Output paths were isolated under
.build/nrf52840/contracts/r07-link-diagnosis. No compiler ran and no maintained
source, firmware recipe, runtime config, workload or resource limit changed.

| Diagnostic | Exact change from frozen link | Link exit | Result |
| --- | --- | --- | --- |
| [Verbose](invocation.json) | -v / --verbose; isolated ELF/map paths | 1 | 222 .swift_modhash orphan warnings; no specific cause beyond collect2 exit1 |
| [Orphan reporting](orphan-place.json) | --orphan-handling=place; isolated paths | 1 | No orphan warnings; same silent collect2 exit1 |
| [No inhibit](noinhibit.json) | --noinhibit-exec; isolated paths | 1 | Same orphan warnings and exit; no ELF produced |
| [No GC](no-gc.json) | --no-gc-sections; isolated paths | 1 | Orphan warnings plus six undefined references; no ELF produced |

Logs and full argument arrays are adjacent to those receipts. Recorder commands
returned success for recording, whereas **each actual link exit was 1**.
No final zephyr.elf or any of the four diagnostic ELFs exists. All five partial
maps are byte-identical archive-extraction records (731 lines); hashes are in
diagnostic-map-identities.json, deduplicated to frozen zephyr_pre0.map. They do
not provide live retained sections, final LOADs, ABI or resource evidence.

No-GC exposes z_impl_k_sem_init/give/take, z_impl_k_sched_current_thread_query,
z_thread_abort and __device_dts_ord_100 from Zephyr/POSIX members. Removing GC
changes reachability, so this control cannot establish that the supported counter
image needs entropy, additional kernel behavior or any of those symbols.
The unchanged supported link still emits no such undefined diagnostic. It is
also incorrect to conclude from the failed control that GC itself is the cause.

## Narrowed facts and limits

Orphan warning mode alone is not sufficient to explain the failure: changing
only that reporting mode still exits1 without a diagnostic. This is not a reason
to suppress warnings in the firmware recipe. CMake already passes -wmo; missing
whole-module optimization is not established. A sample base GiftUI object has
alloc+retain .swift_modhash metadata. That observation does not prove a section
placement/retention defect or authorize deleting metadata.

nRF doctor passed the pinned Swift6.4 / armv7em-none-none-eabi, Zephyr4.3.0
3568e1b6d5cdd51a6b964a2a1d6d29200fea2056, SDK0.17.4 and board
nrf52840dk/nrf52840 checks. Installed ld reports GNU ld2.38. Frozen build commands,
333 object hashes, app archive, generated source handoff, CMake build/rules/cache,
compiler recipe scripts, SDK inspector/linker and R06 receipt identities are
preserved in input-identities.json and frozen-build-commands.txt.
Read-only ninja -t commands only lists existing commands; it executed no build.

A primary Zephyr Kconfig source confirms WARN places orphans and emits warnings:
https://github.com/zephyrproject-rtos/zephyr/blob/3568e1b6d5cdd51a6b964a2a1d6d29200fea2056/Kconfig.zephyr
The same installed source was inspected. External reports of similar silent
Swift/Zephyr failures were exploratory leads only; none establishes this cause.
Upstream binutils2.38 source was downloaded to /private/tmp for read-only
reference but did not lead to an established cause or any adopted implementation.

## Stop and handoff

Parent directed a finite stop after these diagnostics and independent Strong
review before further variants or repairs. No more compiler/linker invocation,
source repair or hardware work followed. Four diagnostic link calls, zero
production repair attempts in this continuation. Historical helper2/2+B031/1
remain permanently closed; changing models did not reopen them. No two
consecutive same-blocker unproductive repairs is claimed or reset.

The exact residual linker cause remains unresolved. Separate Strong review
should assess this frozen packet and identify a precise bounded next check or
existing-recipe defect before authorizing further implementation. A required
runtime constructor/entropy behavior, compiler setting, ownership/API, workload
or physical ceiling choice still requires its smallest upstream decision; none
is established by this packet. Do not infer exhaustion or request a speculative
contract exception merely from a silent linker failure.

Pi early linked ARMv6/VFP result remains separately qualified in
../../r07-early-images/pi-result.md. nRF final linked ABI, allocator/zero heap,
RAM/flash and actual root/corpus gross-stack evidence remain unavailable.
Main stack27648, heap0, RAM196608 and flash1048576 are unchanged. R07 actual
linked nRF image and independent P08 exit remain pending; P09–P12 untouched.
