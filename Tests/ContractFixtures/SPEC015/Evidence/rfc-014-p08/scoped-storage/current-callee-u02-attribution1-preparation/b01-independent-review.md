# Independent Strong re-review — P08 U02 preparation B01 correction

Reviewed 2026-10-19 at **`3db4e1b13a728947569a700f35957bb4d17ef943`** against
original preparation **`b8c459697098941a317aa0ec014e8a39a6b1206f`** and
[review B01](independent-review.md) at
**`e7ddd72c3eb4ac471686d66a5c32c5fab697c8db`**.
Verdict: **PASS — B01 resolved; bounded preparation is technically ready.**
**No remaining preparation-readiness blocker was identified.** Separate human
authorization is still required before the one proposed attribution session;
this review grants no execution or evidence-producer allowance.

The orchestrator selected **gpt-6.1-sol / high**, meeting **Strong** for C3/R3.
This records the orchestration setting, not runtime identity self-attestation.
The earlier STOP review and its inspection record remain unchanged history.

## Independent checks

Independent offline standard-library hashing/JSON/gzip inspection and read-only
Git blob/index authentication, plus the exact frozen diff operation, produced
[the inspection record](b01-independent-review-inspection.json).

- All **79 evidence files / 126,694,715 bytes** match their frozen sizes,
  SHA-256 values and exact baseline blobs. All **48 preservation files /
  875,385 bytes** match current opaque bytes and the exact union of source42,
  five dirty files and one cache file. The sets are disjoint: **127 files /
  127,570,100 bytes**. Paths have no symlink components. The added set permits
  no semantic source/cache inspection.
- The exact **six control files** match their reviewed-commit blobs and total
  **1,038,385 bytes**, below the **2,097,152-byte** distinct control ceiling.
  They are separately identified control metadata, with no inferred permission
  to read another packet-directory file.
- Original `inputs.json`, `roots.json`, `selected-rows.json` and
  `preservation.json` are byte-identical to `b8c45969`. The three root memberships
  and object joins still match the authenticated inventories. All **56 stable
  symbol rows / 1,892 site tuples** equal their complete inventory groups and
  remain initially `unresolved` / `NOT_EXECUTED`. No attribution was performed.
- Each of the five literal diff index bases matches its pinned commit blob,
  size and hash: **54,304 bytes** total. The exact permitted
  `git diff --no-ext-diff --no-textconv -- <five literal paths>` returns
  **5,230 stdout bytes / zero stderr bytes**, SHA-256
  `731edcb6d8b9458a3c7519ea0efd9f3988314b510b105ddfef718013394c2ac7`.
  Its **54,853 worktree bytes + 54,304 index bytes**, returned bytes and separate
  authentication reads are explicitly charged on every invocation.
- The unchanged **536,870,912-byte** session ceiling now covers every evidence,
  preservation and control read, every Git authentication/reread, diff payload
  consumption/output, encoded and inflated gzip materialization, and accepted
  stat/list/Git metadata bytes. Reservations precede operations; there is no
  reset or refund. Before semantic inspection, mandatory final payload/control
  hashes, diff/base authentication and bounded metadata checks must be reserved,
  and semantic reads cannot spend that reserve. The known final content/diff
  components total **128,831,480 bytes** when both exact and index base blobs are
  separately authenticated; bounded metadata reservations are additional.
  Exhaustion leaves unfinished rows unresolved while preserving the final
  checks and accounting. B01's omitted-read/byte conflict is resolved.
- All source42/dirty/cache hashes, dirty diff, exact cache membership and three
  marker identities match. The proposed result destination remains absent.
  Original finite output, elapsed, group, gzip and zero-repair/retry limits,
  exclusive five-file destination and preservation/STOP duties remain binding.

This is a B01-only re-review; the prior review's passing inventory, per-site proof,
U01 separation and governance findings remain applicable because those bytes and
rules are unchanged. No packet correction was authored by this reviewer. Only
this re-review, its inspection record and minimal navigation were added.

## Remaining authorization and evidence boundaries

No attribution, network, source/header/object follow, compiler/build/test/target,
controller/collector/qualifier/fixture execution or result-directory creation ran.
Source/cache were opaque preservation hash inputs only; markers were lstat-only.
No raw receipt, dirty/source/cache/marker byte or historical record was mutated
or staged. Collection/A-only/I-only **1/1**, prior API/ref2 consumption, header
**0/3 / 0**, repairs/retries **0/0**, failed startup and all historical stops stay.

After separate human authorization, the exact bounded session may execute under
this packet; independent Strong result review must precede reliance or dependent
preparation. This PASS proves readiness of that boundary, not Static feasibility,
body/provider identity, transitive cost, safety, allocation or fit. U01/R01–R04,
U02–U05, complete callee/safety, P08/R07/T8.1, unmet SO criteria, strict cold/zero
heap, four-profile/ABI/resources, exit review and conformance remain open.
`strict_cold_eligible` stays false. ADR-039/040, implementing SPEC-015 and active
ITERATION-003 I3-04/05 remain governing; closed MVP gains no commitment and full
RFC-015 remains ITERATION-004 I4-07. No architecture/contract/scope decision or
optional deferred item arose. Any such choice still follows the parent/Astra
Medium decision route and normal human gates.
