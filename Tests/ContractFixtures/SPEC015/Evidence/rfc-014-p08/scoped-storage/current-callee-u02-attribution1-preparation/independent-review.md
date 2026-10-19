# Independent Strong review — P08 U02 attribution 1 preparation

Reviewed 2026-10-19 at **`b8c459697098941a317aa0ec014e8a39a6b1206f`**.
Verdict: **STOP / NOT READY for dependent attribution.** One concrete read-boundary
defect remains below. No attribution session or result destination was started.
The preparation's inventory copying and input authentication are correct.
Complete current-callee and safety proof remains STOP;
`strict_cold_eligible` remains false. This is not P08 acceptance.

The parent orchestrator selected **gpt-6.1-sol / high**, meeting the **Strong**
review level for this C3/R3 slice. This records the orchestrator's setting,
not runtime identity self-attestation. This review is independent of preparation
authorship and makes no contract or scope decision.

## Blocking finding B01 — inconsistent complete read allowlist and byte boundary

The [packet](README.md#reviewed-provenance-and-literal-input-allowlist), lines
44–50, calls `inputs.json` the **complete literal repository-relative read
allowlist**, exactly **79 files / 126,694,715 distinct encoded bytes**. The limits
table repeats that exact distinct-input boundary at line 176. It expressly
excludes implicit discovered paths and siblings.

The same packet requires source42, dirty-file and cache hash checks before and
after inspection, at lines 124–125 and 195–214. **None** of those preservation
content paths appears in `inputs.json`: the 42 actual-host sources total
**776,334 bytes**, and the five dirty files plus one cache file add **99,051
bytes**. These are **48 additional distinct files / 875,385 bytes**. The combined
required content-read set is therefore **127 files / 127,570,100 bytes**, before
preparation metadata or generated diff bytes. The two source files listed in
`inputs.json` are different files from the actual-host source42 set.

The hash-only permission at lines 195–199 states the preservation purpose, but
does not reconcile the later mandatory reads with the asserted complete
79-file allowlist and exact distinct-input ceiling. A future inspector must
either exceed that declared complete boundary or omit required applicability/
preservation checks. Those are incompatible execution instructions. Current
hash equality does not resolve the instructions for the future session.

Before execution, prepare a concrete revision that explicitly distinguishes the
79 frozen evidence inputs from the literal preservation-only content reads and
stat/list checks, or includes the required paths in one complete manifest.
Freeze the precise permitted operations for each set and make the distinct-byte
description and cumulative 512 MiB accounting cover every required content read,
Git authentication, diff input/output and reread. Preserve hash-only access to
source/cache, existing limits and the prohibition on semantic source inspection.
This review does not require increasing a limit. Independently re-review that
exact revision before dependent reads. **The reviewer has not patched the
preparation.**

## Independent inspection and findings that passed

Read AGENTS, the implementation-executor skill, canonical lifecycle and
implementation-documentation rules, the active plan/context, committed next-step
decision `f45edee87362572fb62826befaf5768c5d201110`, underlying collection and
interpretation reviews, both compressed inventories, U01's reviewed disposition,
accepted ADR-039/040, implementing SPEC-015 S15.1/S15.2 and iteration provenance.
Independent standard-library SHA-256/JSON/gzip inspection and read-only Git
comparisons produced [the inspection record](independent-review-inspection.json).
No preparation or historical inspection program was executed or imported.

- All **five preparation files** equal their exact reviewed-commit blobs.
  All **79 input files** match their declared sizes/SHA-256 and exact baseline
  blobs; all paths are free of symlinks. The declared 79-file sum is correct
  for `inputs.json` itself. All non-null existing review provenance commits
  contain identical input bytes; the sequencing record correctly has no
  independent evidence-review commit.
- All **three complete root records**, exact object joins, member IDs and
  union/bodyless IDs equal the already reviewed inventories. S0171/S0170/S0174
  retain **912/1,035/1,063** members and **269/281/282** bodyless nodes at SIL
  **400836/417207/562306**. Union **1,064/282**, **8,068** references,
  **9,544** apply-family sites, **25** objects and **4,064** object context
  headers agree. These remain conservative memberships.
- IDs **U02-X01–X56** are exact and unique. Every symbol and ordered full
  module/caller/address/line/kind/target site list equals its inventory group:
  **56 symbols / 1,892 sites**, with no duplicate site tuple or omitted group.
  Every preparation category and ordinary/cold/cost field remains unresolved;
  every result status is `NOT_EXECUTED`. No feasibility was inferred.
- The two inventories inflate to **4,629,201** and **18,997,145** bytes,
  respectively, within the proposed per-file and aggregate gzip ceilings.
  Finite time, per-group context, output/transcript, one-session, zero-repair/
  retry and exclusive five-file destination rules are explicit. The exact
  future result directory is absent. B01 prevents declaring overall readiness.
- All **42 actual-host source hashes**, **five dirty-file hashes**, exact dirty
  diff hash, cache membership/hash and marker device/inode identities match
  the preservation records. Source/cache were read only as opaque hash bytes;
  markers were statted only. The review preserved those bytes and identities.

The proposed per-site proof rules correctly distinguish exact Static origin,
Dynamic exclusion, observer provenance, proved infeasibility and unresolved
gaps. They retain module identity, mixed partitions, missing providers, ordinary
versus cold behavior and transitive cost. Existing U01 callback/local-helper
conclusions and R01–R04 remain separate; no error-transfer, linked-provider,
metadata-size, cold, memcpy or stack-guard residual is erased by an external
symbol's membership. Witness/indirect duties and U03–U05 remain outside the
selected attribution task. No additional readiness blocker was identified in
those rules.

## Preservation, authority and next boundary

This review performed offline documentation/inventory parsing, byte/hash
authentication and read-only Git operations only. It did not semantically
attribute retained raw SIL/disassembly, read source content for meaning, follow
source/header/object material, access the network, run a compiler/build/test/
target/controller/collector/qualifier/fixture driver, or create the future result
directory. It changed only this independent review, its inspection record and
minimal navigation. No raw receipt, source, dirty file, cache, marker or historical
evidence was edited or staged.

Collection, A-only and I-only stay **1/1 consumed**, at
**[16777234,29640436]**, **[16777234,29650609]** and
**[16777234,29652748]**. S and old B stay closed; prior API ref1 **1/1**, ref2
session **1/1** and requests **2/2** remain consumed. Header candidates/bytes
stay **0/3 / 0**, and all evidence repairs/retries stay **0/0**. Failed startup
`9542d659` and prior STOP dispositions are preserved. Review inspection does
not consume or release an attribution/evidence-producer session.

Accepted ADR-039/040 and implementing SPEC-015 remain authoritative; the
finite-counter physical-SRAM exception remains intact. This is the necessary
finite-counter evidence dependency in active ITERATION-003 revision 5 I3-04/05,
supporting the analyzer and constrained-stack/four-configuration validation
required by closed ITERATION-001. It adds no closed-MVP commitment. Full RFC-015
remains ITERATION-004 I4-07. Plans stay active and Specifications implementing.

Next is **offline B01 preparation correction and separate Strong re-review**.
A passing preparation review would still require separate human authorization
before attribution, followed by independent Strong result review before reliance.
No automatic continuation, acquisition, retry, alternate endpoint or strict-cold
preparation follows. U01/R01–R04/U02–U05, complete callee/safety, P08/R07/T8.1,
unmet SO criteria, strict cold/zero heap, four-profile/ABI/resources, matched
Native allocation, complete Native/Pi bounds, exit review and conformance remain
open. B01 is a current readiness defect, not optional deferred work. Any actual
warm-up/heap/ownership/privacy/bound/scope choice still goes to the parent for
the maintainer-requested Astra Medium decision and normal human gates.
