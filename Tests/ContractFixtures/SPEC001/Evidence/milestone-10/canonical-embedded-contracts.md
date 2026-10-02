# T10.4 — Canonical embedded contracts

The firmware consumes canonical semantic layout/render payloads and text
resource identities. Packed records remain in their existing caller-owned
regions. Metrics and bitmap raster use the same selected Inter catalogue; glyph
projections retain its checked font instance rather than a host constant.
Canonical render-view protocols are visible under the actual Embedded flag.
The retired host lookalike file contains no declarations and is not selected.

CMake builds 21 distinct lower-owner modules plus the existing composition
module. Imports are retained; only transitive lower-owner module directories
are visible. One WMO translation unit per owner links successfully with the
pinned compiler; per-source partitioned output failed linking and is not used.
The generated selected-source manifest drives native owner compilation.

Validation:
- `check-spec-001-embedded-owner-feasibility.sh`: four canonical ARM modules pass
  with `GIFTUI_NRF_EMBEDDED`, forbidden Dynamic import fails.
- `check-spec-001-nrf-owner-isolation.py`: actual firmware compiler invocations
  reject SemanticCore→ReferenceTextResources, Layout→RuntimeDynamic, and
  GiftUI→TargetHost. Registered in the embedded SPEC-001 driver.
- `check-spec-001-nrf-full-layout-native.sh`: full layout, Canvas, action
  dispatch, physical offer/refusal, revision replacement and teardown pass.
  Stale six-control/96-scope fixture expectations now follow the approved
  three-control/92-scope touch amendment; Clear is an integration operation.
- Production native rehearsal and seven injected hardware-boundary faults pass.
- Comparison against the latest timeline-cleanup Static reference passes:
  129 ordered frames and 12 actions; seven raster candidates generated.
- `scripts/nrf52840/build.sh --application signal-analyzer-static`: ARMv7E-M
  hard-float ELF, fixed named stores, zero heap, RAM/flash checks pass.

Baseline→current: RAM 195,008→195,132 bytes (+124), flash
241,052→270,700 bytes (+29,648). Ceilings remain 196,608 RAM and
1,048,576 flash; warning remains 917,504 flash. Zephyr's summary includes four
extra RAM bytes compared with the inspected ELF load-segment accounting.
No board was flashed. Connected stack high-water and reviewed-pixel evidence
remain separate outstanding criteria. The full raster gate cannot pass without
reviewed pixel references; generated candidates are not approval evidence.

Raw evidence: `canonical-selected-sources.tsv`, `canonical-owner-sources.tsv`,
`canonical-nrf-memory.txt`, `canonical-nrf-abi.txt`,
`canonical-native-layout.log`, `canonical-raster-hashes.tsv`.
