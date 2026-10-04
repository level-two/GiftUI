# Shared-owner startup text

2026-10-05. SPEC-001 T11.3 complete; connected startup regression remains T11.7.

Startup text now uses LayoutEngine over one text scope and the common packed workspace. Font/glyph, packed append/readback, publication, reset invalidation and region rejection checks remain. The two duplicate text measure/place implementations and CMake entries are removed. The semantic-region test verifies shared-engine results through Embedded packed scope/line/glyph codecs rather than retaining the retired algorithms as an oracle.

71 focused shared Layout/codec tests pass. The native firmware Layout/Drawing harness passes, including startup success, null/wrong size, repeated reuse and a new shared-workspace corpus: empty/CR/LF, narrow wrapping/clipping, exact/first-excess line and glyph limits, full physical capacities, coordinate overflow, publication invalidation, cleanup and repeated success. Fixed-font D advance is 12 points, so the independent 224-glyph expectation is nine lines at width 320. The initial six-line expectation was corrected after checking the registered font metrics; production rules were unchanged.

[Paired images](paired-images.json): LOAD-segment flash 275,568 → 274,272 bytes (−1,296); RAM 191,104 → 191,104. ARMv7E-M/VFP, zero heaps and allocator-symbol/refusal-stub checks pass; configured stack reservations match. Source-derived Zephyr table sizes may include padding outside LOAD bytes; comparisons use the same method. No connected timing or stack high-water claim.

[Tests](tests.log), [build](firmware-build.log), [native corpus](native.log). Reproduce: format maintained Swift, focused test filter `GiftUILayoutTests|EmbeddedLayout|LayoutTextCodec|staticNRFEmbeddedSemanticRegion`, `scripts/nrf52840/build.sh --application signal-analyzer-static`, `scripts/contracts/check-spec-001-nrf-full-layout-native.sh`.
