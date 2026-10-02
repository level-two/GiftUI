# Landscape owner-fixture revalidation — 2026-10-02

The SPEC-004 widest-path resolver probe still passed a 320-row region into its
amended 320×240 extent. Construction correctly rejected it before the resolver
ran. The probe now uses the complete 240-row surface height; the full-surface
candidate remains too large for 2,560 bytes, so the tiled alternate exercises
the same two-candidate path. All original instrumentation counts, including
44 primitive operations against the 96-operation bound, remain unchanged.
The standalone macOS Dynamic driver passes.

The SPEC-005 exact consumer inventory now includes GiftUIRuntimeDynamic and
SignalAnalyzerTargetHost. Their approved package edges and canonical metrics/
raster views are exercised by the joined production pipelines; they are direct
consumers of Text Resources declarations. No owner declaration or prohibited
edge changed. The standalone macOS Dynamic driver, including positive/negative
fixtures and downstream integration checks, passes.

Reports:
- SPEC-004: `a3434d85519aec30b875114076b8bed220cb17b8-3ee43584c692ba99/macos-dynamic`
- SPEC-005: `a3434d85519aec30b875114076b8bed220cb17b8-29bc37c12bbeed0b/macos-dynamic`

The registered gate's preceding failures remain revision-scoped evidence;
these focused reruns supersede only the named assertions and profile.
