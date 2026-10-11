# Approved baseline regression scope — 2026-10-12

Under explicit Swift 6.4 correction approval `267616c9`, Standard Sol 6.1 Medium
migrates the current P01/P02 compiler/SDK selections, isolated macro scratch/cache,
and narrow current target-tool paths/receipt labels. Historical Apple 6.3.3
default gates remain unchanged. No source, schema, feature or semantic repair is
included. The official package tag is 6.4.0; the reported compiler version is 6.4.

Commit migration before running one P01 four-configuration control gate and four
sequential registered P02 profile runs. Rebuild the actual macro executable with
Swift 6.4 in `.build/rfc014-p02-swift64/tool`, with its independent tool-cache.
Preserve historical macro/build outputs. At most two narrowed repairs; stop after
two consecutive unproductive repairs and preserve failures. Sandbox/network
failures follow ordinary escalation policy and do not justify bypassing checks.

After successful P02 receipts, a separate committed P07 driver change derives the
macro executable from the core receipt (with the new scratch fallback). Then run
at most four initial P07 routes plus two narrowed repairs, under the same stop
rule. Run profiles sequentially; other assigned activation tests use separate
outputs. Record exact receipts, source/compiler/macro identities and freshness.
No target execution, deployment, restart, flash or full P08 acceptance is implied.
