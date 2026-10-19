# Independent Strong review — U01 I-only controller readiness

Reviewed 2026-10-19: closed-gate design
**`b2e94bc8bbba4ecf8261056d6c843b4bdf6d22c8`**, controller
**`0e485568e39d674c8244ce55e82ea6ae2a64fb74`**.
**PASS for the exact I-only controller/environment and closed-schema gate.**
No blocking factual, contract or scope finding remains. No bootstrap,
controller, verifier, decoder/help, runtime, compiler, build, test, acquisition,
extraction or production/source repair ran during review.

## Independent checks and control findings

Read the [handoff](CONTROLLER.md), identity design, bootstrap/controller/verifier,
preparation source and all pinned manifests. Independent standard-library
file/hash/JSON/tree/alias inspection, syntax parsing and read-only Git checks
produced the [inspection record](controller-independent-review-inspection.json).
Reviewed modules were not executed or imported.

Every existing packet file equals its reviewed Git blob. All **nine external
file pins**, **203 direct inputs**, **15 cache-family members / 5,824,684,071
bytes**, **8,720 complete loader entries** and **72 aliases** match. File hashes,
sizes, resolved paths/kinds/targets, membership, absent paths and stat stability
agree. All **42 source hashes**, five preexisting dirty files, cache membership/
hashes and both consumed marker identities remain unchanged. The proposed output
directory remains absent.

- **External trust:** the caller authenticates final Git-blob bootstrap bytes
  against the externally supplied SHA before literal isolated Python `-c`
  execution. Full external commit/repository/packet trees and nine file hashes
  control the exact packet. Bootstrap verifies object hashes, HEAD/tree/blob
  joins, ordinary-file membership and workspace equality; controller/verifier
  source executes only from authenticated Git bytes. Fixed read-only Git calls
  reject includes and disable helpers/replacements/lazy fetching under the same
  remaining deadline. Mutable workspace code or locally regenerated launch pins
  cannot substitute for this boundary.
- **Environment and inputs:** complete bootstrap/controller/child dictionaries
  fix system-only fallback library/framework paths, isolated interpreter startup
  and exact optional interpreter-added encoding. There is no provider override
  or HOME fallback. Local policy equals its authenticated prior policy; complete
  loader roots/aliases, direct/cache/report/link/tool/preservation inputs and old
  markers are rechecked before the child. Installed Apple system loader/runtime
  remains the explicit OS trust boundary, not historical-process qualification.
- **No schema inference:** policy keeps cache field offset/parser null and schema
  evidence empty. The verifier compares authenticated supplemental report/OS and
  retained linked-system-import joins only. It never interprets offset 0x58,
  decodes a cache header or parses I output semantically. Ordinary-counter loaded
  identity remains false. There is no condition that can release S.
- **One-shot accounting:** atomic creation of the canonical fresh output directory
  refuses duplicate/resume attempts. Exclusive, fsynced consumption and claim
  records precede the sole child. Old markers are checked, never changed. A failed
  bootstrap consumes its authorized bootstrap invocation even if authentication
  ends before marker creation; absent child work does not grant a retry.
- **Time and output:** bootstrap entry starts the unchanged **240-second**
  monotonic/alarm deadline, covering Git/input/loader/verifier/gate work. The
  one child has at most **60 seconds**, its own process group and **16 MiB**
  combined raw ceiling. Raw writes reserve **1 MiB** for receipts; every JSON
  write enforces the shared **320 MiB raw-plus-receipt cap**, the reserve,
  **24-receipt** count and **64 KiB** per receipt. Terminal accounting explicitly
  precedes its own bounded write. No pause or deadline reset can extend work.
- **Durable actual outcomes:** raw prefixes, observed/retained counts, actual
  wait exits, hashes and timeout/cap/truncation states are persisted before any
  capture check. Nonzero/empty/capped/timed-out/exception outcomes stop; owned
  groups are killed and finitely reaped. After stopped work, only cleanup and
  receipt persistence may finish. Hard-kill/filesystem failure can leave partial
  receipts, never invented exits or permission to resume.
- **Exact execution boundary:** only `capture(commands[0])` can spawn dyld_info.
  A zero exit plus nonempty stdout establishes capture only. Successful I ends
  **STOP_cache_schema_unestablished**; both S commands receive skipped/null-exit
  records. Old B and all other decoder/runtime/acquisition routes are absent.

## Exact clearance and unchanged gates

This review clears **one exact I-only orchestration bootstrap** under existing
P08 authorization: **one** pinned dyld_info child, zero repairs/retries,
acquisition/extraction/network/runtime/compiler/build/test/strict-cold launches.
Use the externally supplied final review commit/repository/packet trees and the
nine exact hashes in the inspection record. Verify bootstrap source from that
Git blob before isolated invocation; do not derive replacement pins from HEAD
or execute the mutable workspace file. Count the single bootstrap invocation
even on pre-marker authentication failure. Any drift/failure ends this allowance
without an automatic successor; no additional confirmation is needed for this
already authorized bounded continuation.

This is readiness clearance, not a successful capture or identity/provider
proof. I raw will require independent interpretation. Any schema/S continuation
needs separately reviewed evidence/preparation, final external pins and its
own explicit allowance. The different-process supplemental report does not
close ordinary-counter applicability. R01–R04, Error size and implementation/
transitive/resolver costs remain open; strict cold stays false.

Both prior attempts remain **1/1 consumed**, repairs **0**, retries **0**,
markers **[16777234,29640436]** and **[16777234,29650609]**. No actual
contract/scope choice arose; any warm-up or heap/ownership/privacy/bound/scope
relaxation goes upstream for the requested Astra Medium decision. Accepted
ADR-039/040 and implementing SPEC-015 remain authoritative, including the
finite-counter SRAM exception. U02–U05, P08/R07/T8.1, remaining SO,
strict-cold/zero-heap, four-profile, ABI/resources, independent exit and later
conformance stay open. Complete callee **and** safety PASS still precede a
current strict-cold manifest under its existing baseline/windows/counts and
zero-heap requirements.
