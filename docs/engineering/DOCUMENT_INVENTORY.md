# GiftUI Documentation Inventory

**Inventory date:** 2026-08-08  
**Scope:** Documentation present before the engineering-governance bootstrap  
**Method:** Classification records what each document currently is; it does not grant lifecycle approval.

> **Historical inventory:** The `GiftUI_*.md` entries below describe the
> pre-governance tree as inventoried on 2026-08-08. Their active copies were
> retired during SPEC-002 implementation after current authority and links
> were established. Retrieve them from immutable tag `PoC` through the
> [proof-of-concept historical baseline](POC_HISTORICAL_BASELINE.md).

## Repository-level findings

- `docs/VISION.md` and `docs/PRINCIPLES.md` are the project-level direction and
  constraints supplied by the maintainers.
- No canonical Proposal/RFC/ADR/Specification lifecycle, feature manifest,
  lifecycle templates, or governance-specific agent skills existed.
- `AGENTS.md` contained platform toolchain, build, deployment, and hardware
  safety instructions. Those instructions remain relevant and must be
  preserved when governance routing is added.
- No roadmap artifact existed. Milestones and phase ordering were embedded in
  individual design and bring-up documents.
- Legacy filenames use descriptive `GiftUI_*` names rather than immutable
  lifecycle IDs.
- Several detailed documents mix architectural reasoning, decisions,
  implementation contracts, plans, and historical results. Their detail is
  not evidence of human approval.

## Existing document classification

| Existing document | Likely feature | Current nature | Known status | Relevant decisions or evidence | Unresolved questions | Recommended destination |
| --- | --- | --- | --- | --- | --- | --- |
| `VISION.md` | project-wide | Established project direction | Maintainer-provided | Linux and embedded focus; declarative SwiftUI-inspired model; platform and backend flexibility | None recorded in the document | Keep at `docs/VISION.md` as project authority |
| `PRINCIPLES.md` | project-wide | Established principles | Maintainer-provided | Backend independence; embedded first; explicit capabilities; cost awareness; conceptual rather than implementation parity with SwiftUI | None recorded in the document | Keep at `docs/PRINCIPLES.md` as project authority |
| `engineering/ENGINEERING_GOVERNANCE_BOOTSTRAP.md` | engineering governance | Bootstrap specification | Bootstrap Specification | Defines the requested lifecycle, authority model, migration constraints, and execution phases | Effectiveness of the pilot and future refinements | Keep as bootstrap provenance; canonical rules should live in focused engineering documents |
| `GiftUI_Framework_Spec.md` | framework architecture, runtime profiles, layout, rendering, state, interaction | Mixed: PoC specification, architecture exploration, candidate APIs, roadmap | Proof-of-concept specification | Records implemented PoC contracts and a section of “Architectural Decisions to Preserve,” including backend-independent declarations and core-owned layout | Numerous post-PoC topics remain exploratory; approval provenance for individual decisions is absent | Preserve as historical source; split one well-bounded pilot into conservative lifecycle artifacts before broader migration |
| `GiftUI_PoC_A_macOS_Simulator_Spec.md` | macOS simulator PoC | Mixed: implementation specification and historical plan | Implementation specification; implementation exists | Defines simulator scope, app/backend isolation, framebuffer rendering, input, state, layout, and tests | No explicit lifecycle approval record; later architecture has evolved | Preserve as historical source; classify under simulator PoC and extract only if future work needs an authoritative contract |
| `GiftUI_Raspberry_Pi_Platform.md` | Raspberry Pi platform | Current implementation/operations documentation | No explicit lifecycle status | Describes the working ARMv6 Linux platform slice, framebuffer, evdev, GPIO, and stable operational behavior | Productization and future platform scope are not governed here | Retain as platform documentation; eventually summarize accepted architecture under `docs/architecture/` when ADR provenance exists |
| `GiftUI_Runtime_Profile_Migration_Plan.md` | static/dynamic runtime profiles | Mixed: architecture review, migration plan, and progress record | Active migration plan; individual stages report completion | Documents dependency direction, portability seams, and staged migration evidence | Remaining stages and approval provenance for target architecture | Preserve as historical source; future changes should receive Proposal/RFC/ADR/Spec artifacts |
| `GiftUI_Embedded_Layer_Inventory.md` | embedded/static runtime | Implementation inventory and conformance evidence | Per-layer compile status | Records regular and Embedded Swift compilation gates and bounded/static replacements | Future admitted layers and continuing conformance | Retain as implementation/conformance record; link from future specs rather than converting it into a decision record |
| `GiftUI_nRF52840_DK_Platform_Spec.md` | nRF52840 platform | Mixed: RFC-like exploration, proposed platform specification, implementation plan | Proposed platform and migration specification | Proposes Zephyr/Embedded Swift platform boundaries, bounded runtime/backend direction, and resource gates | Explicit “Open Decisions” plus hardware-dependent validation | Preserve as historical source; do not infer acceptance; split only during a future platform lifecycle review |
| `GiftUI_ILI9486_Bring_Up_Record.md` | nRF52840 ILI9486 display | Experiment and validation record | Hardware-free baseline complete; connected checks unmeasured | Captures reproducible build artifacts, resource baseline, and hardware safety gates | Hardware provenance, electrical checks, accepted SPI clock, and controller profile | Retain as evidence; reference it from future specs/conformance reviews |
| `GiftUI_ADS7846_Bring_Up_Record.md` | nRF52840 touch input | Experiment and validation record | Hardware-free baseline complete; connected checks unmeasured | Captures touch-processing behavior, tests, and build/resource evidence | Exact controller, wiring continuity, calibration, and connected-board results | Retain as evidence; reference it from future specs/conformance reviews |
| `GiftUI_PiScreen_Phase_7_Validation_Record.md` | nRF52840 PiScreen integration | Validation plan and partial evidence | Hardware-free work complete; connected tests not run | Records candidate performance/resource values and prerequisite safety gates | Hardware acceptance, endurance, timing, current, and fault-path results | Retain as conformance evidence with unknown hardware results explicit |
| `GiftUI_KMRTM24024_SPI_nRF52840_Spec.md` | KMRTM24024 SPI display/touch | Mixed: RFC-like design, proposed specification, phased implementation and validation plan | Proposed implementation specification | Proposes a separate ILI9341 product/target and firmware application; implementation exists for major portions | Exact hardware identity, wiring, readback, orientation, and accepted clocks remain open | Preserve as historical source; do not promote embedded “shall” statements to accepted ADRs without approval |
| `GiftUI_KMRTM24024_Stack_Ownership_Proposal.md` | embedded static workspace ownership | Mixed: detailed proposal, candidate design, and acceptance plan | Proposed permanent fix | Diagnoses oversized stack frames and proposes caller-owned long-lived workspaces with build-time frame budgets | No explicit approval; permanent API/ownership choice remains proposed | Keep as legacy proposal source; migrate through the lifecycle if work resumes |

## Confident initial feature boundaries

The following identifiers can be introduced in a navigation manifest without
asserting approval:

- `framework-core` — broad legacy PoC architecture and API surface;
- `runtime-profiles` — dynamic/static separation and embedded layer migration;
- `layout-system` — a bounded pilot candidate contained in the framework PoC;
- `macos-simulator` — PoC A host platform;
- `raspberry-pi-platform` — current ARMv6 Linux platform slice;
- `nrf52840-platform` — proposed Zephyr/Embedded Swift platform work;
- `piscreen-ili9486` — display/touch bring-up and validation;
- `kmrtm24024-spi` — native-SPI display/touch support;
- `embedded-workspace-ownership` — proposed fixed-storage ownership change.

Relationships that require architectural interpretation or approval remain
unknown until lifecycle artifacts are drafted and reviewed.

## Migration status

At the time of this inventory, migration was explicitly deferred. The later
governed lifecycle created current Proposal, RFC, ADR, and Specification
artifacts. During SPEC-002 implementation, the maintainer confirmed retirement
of the mixed legacy active copies under the tagged-history policy. Their
reasoning remains available from immutable tag `PoC`; this inventory remains a
historical classification and does not grant any retired document authority.
