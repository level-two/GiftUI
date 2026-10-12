# Swift 6.4 baseline and runtime regression results — 2026-10-12

P01 passes all 17 controls across four configurations. All four registered P02
routes pass (28 checks plus 120 runtime assertions per native profile; 27 checks
per cross profile), including their existing P04 record components. The macro
was rebuilt with the approved Swift 6.4 compiler in the isolated scratch.
`repairs.md` preserves the initial SwiftPM build-layout failure and the one
productive repair; no second P02 repair was needed.

All four P07 routes pass with no repair. Each native profile passes 33 checks
and 5,904 assertions, with 26 matched Static/Dynamic logical transcript cases.
Audited storage totals remain Static 68,503 bytes and Dynamic 166,240 bytes.
ARMv6 passes 32 checks; nRF52840 passes 31, including the expected CPU and VFP
calling convention checks. Cross results are compilation/ABI evidence only;
no target execution or hardware action occurred.

`p01-receipt.json`, `p02-receipts.json` and `p07-receipts.json` identify exact
commands, local result paths and hashes; adjacent results freeze full receipts.
All recorded P02 inputs/compiler/macro and all P07 inputs/artifacts/core
receipts/compiler match current bytes at freezing. P07 `source_dirty` is
retained honestly for concurrently prepared evidence; source hashes are fresh.
Native P07 execution logs, transcripts and storage reports plus cross ABI logs
are frozen alongside their receipts.

This completes the bounded baseline/core/runtime regression packet. It does
not claim full P08 acceptance or replace the separately assigned activation
and resource regressions. P03/P06 receipt-path changes received Python syntax
checks only, preserving their existing hash safeguards.
