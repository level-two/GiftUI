# Explicit Embedded source selection

2026-10-05. SPEC-013 T10.1 complete; T10.2/T10.3 final affected profile/dependency validation pending.

Exactly the 15 Step 15 outer guards are removed. SwiftPM explicitly excludes those Embedded-only source fragments; nRF CMake selects them. Native owner compilation consumes CMake's generated source manifest, and the host rehearsal compiles its exact amalgamation. A checked inventory and registered source-selection gate compare the lists and reject missing exclusions, missing firmware inputs and unexpected exclusions. Interior/residual guards preserve their previous profile/resource behavior.

The compatibility shell actually contained a typealias to GiftUIReferenceTextRasterView, rather than only the comment described by the review. Its two consumers now name that same shared type directly; the shell and its CMake entry are removed. No algorithm, storage or owner changes.

21 Swift Testing cases, full native firmware Layout/Drawing corpus, and three runner fixtures (28 assertions) pass. [Paired linked images](paired-images.json): flash 274,272 → 274,272; RAM 191,104 → 191,104. ARMv7E-M/VFP, zero heaps, allocator/refusal-stub and unchanged stack configuration verified. First cross-build exposed the removed alias; correcting its consumers resolved that compile failure without altering the contract.

Reproduce: `scripts/format-swift.sh`; `python3 scripts/contracts/check-nrf-source-selection.py`; `scripts/nrf52840/build.sh --application signal-analyzer-static`; `scripts/contracts/check-spec-001-nrf-full-layout-native.sh`; final `scripts/test.sh all-hardware-free`.
