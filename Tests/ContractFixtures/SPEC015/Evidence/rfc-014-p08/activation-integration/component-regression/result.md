# Fresh native activation regressions — 2026-10-12

Both maintained `check-spec-015-schema4.py --activation-join` routes pass on
fresh Swift6.4 P02/P07 graphs and the newly rebuilt Swift6.4 macro tool.
Each profile passes37 driver checks and368 runtime assertions (320 existing
host/schema plus48 actual activation). No old GiftUI module/object or old macro
binary is used. Dynamic and Static flags retain their separate receipt identity.

The gate rebuilds seven host modules and the runtime probe plus maintained
activation sources. Copy, callback, constant-marker callback and destroyed
backing controls reject for their exact consumption/lifetime diagnostics. It
also retains the schema missing-field and fail-closed workload-generator checks.
All recorded source and output artifact hashes were verified before freezing.

Scope closes at2 initial invocations, zero repairs, zero unproductive failures.
Commands, complete logs, generated top-level test sources and receipts are frozen
per profile; output binaries stay in the recorded build directories. Source
identities and remaining output hashes are in each original receipt. The project
formatter, strict formatting lint, governance validator and whitespace check
passed before these native gates. Independent final baseline review remains
required before activation-blocker closure.

This proves the bounded host/controller/runtime component. Synthetic reports and
application-stage trace adapters do not establish the full validator/application,
finite counter, target host execution, early-image/resources or P08 package exit.
