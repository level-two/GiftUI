# T10.6 — Static typed preparation increment

2026-10-02. The selected firmware Layout adapter now exposes an exact typed result
from canonical validation and LayoutEngine failure retention. The optional wrapper
remains available to explicitly selected probes; the live common-runner adapter
will consume the typed result.

Static sealed fact application preserves the exact rejection condition, applied
fact count, and whether an earlier fact applied. Failure drains only the sealed
batch, ends model mutation and preserves active admission. The application condition
is imported from its actual Presentation owner in the CMake source selection.

The 0/1/3-prefix regression uses a representable capture publication whose base
revision disagrees with the model. It checks exact captureRevisionMismatch, dirty
progress, preserved model state, cleared sealed storage and an empty subsequent
batch without replay. Focused Static fact/repository tests pass (six tests).

The native production workload matches the current macOS Static reference:
129 ordered frames and 12 actions. Cortex-M4F ARMv7E-M hard-float cross-build passes;
FLASH_BYTES=270908 and RAM_BYTES=195132 remain within 1048576/196608 ceilings.
This is a preparatory increment. Firmware sequencing, production policy and common
cleanup are still T10.6 work. No new connected-board or stack high-water evidence
is claimed from the build or existing ignored reports.
