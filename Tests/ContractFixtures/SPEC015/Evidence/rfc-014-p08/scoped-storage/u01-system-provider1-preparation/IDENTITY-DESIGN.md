# U01 system-provider identity boundary — I only

Prepared after independent review `61466053`; no launch. The independently
reviewed inventory pins complete existing cache bytes and the supplemental
report, but supplies no applicable independently justified cache-header schema.
A literal known UUID occurrence at `0x58` does not define a UUID field. No schema
source, offset parser, SDK/toolchain substitution or acquisition is introduced.

[gate-policy.json](gate-policy.json) therefore freezes
`STOP_AFTER_I_CACHE_SCHEMA_UNESTABLISHED`, `S_launch_enabled=false`, with null
field offset/parser and an empty schema-evidence list. This is the fail-closed
I-only realization expressly permitted by the review and delegated task. Both S
commands remain exact historical request entries, recorded skipped. No I record,
name, architecture, UUID, OS version or current map correspondence can release S.
Old toolchain-core B remains unchanged/inapplicable.

## Exact verification design

The concrete verifier will operate only on authenticated report/OS/inventory and
linked-result bytes, not decode the cache or load an image. It must:

1. Parse the report's two JSON objects, reconstruct exactly the inventory's
   selected fields, and compare them. Require the distinct supplemental process,
   ARM-64 untranslated, macOS 26.6.2 build25G83, cache UUID
   `f2e86c53-6052-388b-ba71-5a0c9b569413`, and exact path/arm64e UUID joins for
   Swift core `83794fb3-de9b-3d23-ab5e-2c1d5d30f134` and system C
   `d77ceb62-aff6-3cec-ba9b-4f057fbe2eb5`. These describe the supplemental process.
2. Require current authenticated SystemVersion.plist version/build to match that
   report. Preserve its limitation: current build matching cannot qualify the
   ordinary counter's historical loaded images.
3. Check the authenticated linked interpretation's exact ordinary counter hash,
   no rpaths/toolchain-core selection, strong Swift core ordinal3 runtime/ErrorWS
   imports and libSystem ordinal1 memcpy/guard/fail imports. The independently
   reviewed linked JSON, raw archive and exact original link inputs remain
   authenticated; this verifier does not rerun their decoder/parser.
4. Verify full15 cache membership/hashes before tools and every command, with
   stat/alias stability. Authenticate report/artifact/log, all linked evidence,
   source42, five dirty files/cache, complete prior loader roots/aliases and
   exact tool/manual. Do not parse `0x58` as a UUID field.
5. Capture only exact stageI argv/environment under fresh permanent consumption.
   An actual zero exit and nonempty raw output qualify capture only. There is no
   undocumented dyld_info output grammar/semantic parser: raw identity records
   are handed to independent interpretation, and S is always closed. Nonzero,
   unsupported/missing output, cap, timeout or drift stops with no retry.

The gate receipt will explicitly distinguish authenticated input correspondence,
I capture status, unestablished cache schema, skipped S, missing ordinary-process
identity and `strict_cold_eligible=false`. No path/UUID list can become a runtime
provider or full R01–R04 PASS. No actual contract/scope decision arose.

## Controller dependency and review

Next commit prepares a concrete externally pinned one-shot bootstrap/controller
and this verifier. It may launch at most one dyld_info child, 60s per child within
240s aggregate including bootstrap/authentication/verifier/gate. Total retained
raw output plus receipts is capped at320MiB; I raw is capped at16MiB. A bounded
receipt reserve must survive cap/timeout. Both historical1/1 markers stay untouched;
the new output directory is absent and must be atomically created before tools.
No source repair, runtime/compiler/build/test/controller/decoder/acquisition runs
in preparation. Independent Strong readiness review of final pins precedes any
launch. Further cache-schema/S work requires separate evidence/preparation and
review; this attempt cannot pause, reload a new gate or reset its deadline.
