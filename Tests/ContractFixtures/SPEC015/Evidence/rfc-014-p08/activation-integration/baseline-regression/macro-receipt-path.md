# Receipt-derived downstream macro path — 2026-10-12

P03 identity, P06 canvas and P07 runtime-cycle drivers now read `macro_tool`
from the verified P02 core receipt, falling back to the isolated Swift 6.4
macro scratch for receipts without that field. Their existing compiler, source,
core-artifact and macro SHA256 assertions remain unchanged. Python syntax
checks pass for all three drivers. P03/P06 execution is outside this bounded step.

Native dynamic/static and ARMv6 P02 routes already pass; parent authorized
starting native P07 alongside the final independent nRF P02 output. No shared
SwiftPM build is added by P07.
