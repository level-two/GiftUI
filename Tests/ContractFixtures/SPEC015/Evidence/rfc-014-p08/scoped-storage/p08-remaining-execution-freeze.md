# P08 remaining execution freeze — 2026-10-15

Source `7b43e199`, independent source PASS `a01ba257`; current activity corrections
0/2. The [source manifest](p08-remaining-layout-source-manifest.json) and exact
qualification pin inputs. No source edits during execution. Luna 6 Medium owns
fixed commands/monitoring; Strong owns failure diagnosis and resource/exit review.

First run the pinned repository formatter. A source diff requires review before
validation. Then run exactly one fresh focused Embedded layout check, supported
by independent source review, before the long full collections. This exercises
the existing current-module recipe and new registered extraction check, not a
standalone probe/IR capture or changed compiler variant. It avoids spending the
whole matrix on an unsupported materialization. Failed or nonconstant extraction
is preserved for grouped Strong diagnosis; no decoder broadening or automatic
rerun. Its partial receipt cannot qualify image or full acceptance.

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded --host-build .build/contracts/p08-scoped-host-hzs5q7za --fresh-focused --select-family so07-layout-facts --collect-failures
```

After that selected check succeeds, run the four full collections sequentially:

```sh
scripts/contracts/run-spec-015.sh --profile macos-dynamic --corpus rfc-014-counter --runtime-build .build/contracts/spec-013-runtime-cycle/tmpi1u8hyk5/macos-dynamic --host-build .build/contracts/p08-scoped-host-ezcy1qan --collect-failures
scripts/contracts/run-spec-015.sh --profile macos-static --corpus rfc-014-counter --runtime-build .build/contracts/spec-013-runtime-cycle/tmpmynn4963/macos-static --host-build .build/contracts/p08-scoped-host-hzs5q7za --collect-failures
scripts/contracts/run-spec-015.sh --profile raspberry-pi-armv6 --corpus rfc-014-counter --runtime-build .build/raspberry-pi/contracts/spec-013-runtime-cycle/tmpsb8yw4yu/raspberry-pi-armv6 --host-build .build/contracts/p08-scoped-host-hzs5q7za --collect-failures
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded --host-build .build/contracts/p08-scoped-host-hzs5q7za --collect-failures
```

Each full non-Embedded collection retains all 384 scoped controls; native also
runs actual runtime/reuse and five exclusivity controls. Embedded has 202 scoped
controls plus 24 preparation checks and one layout extraction (227 total).
Existing component receipts remain exactly qualified; prior counter collections
are historical after changed compiled inputs and cannot be promoted by partial
reuse. Every invocation records argv/revision/cleanliness/times/exits/log hashes
and its actual emitted build path. Independent failures collect without per-error
user stops. Read-only monitoring is not an extra compiler invocation.

After full success, platform doctors and the two existing SO-08 image recipes
from the activity use actual successful Pi/nRF counter paths. Preserve failures
before corrections; no hardware or later-package activity. Complete linked layout,
stack/IRQ/ABI/allocator/resource evidence and caller reconciliation then receive
independent P08 exit review. This record does not claim materialization or fit.
