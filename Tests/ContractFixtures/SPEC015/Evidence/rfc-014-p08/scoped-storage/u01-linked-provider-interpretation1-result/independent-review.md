# Independent Strong review — U01 linked/provider interpretation 1

Reviewed 2026-10-19 at **`7848788d84e3e67988c06bd696fcab197552bb9f`**.
**PASS for the bounded linked-body/static-provider interpretation and its STOP
disposition.** No blocking factual, contract or scope finding was identified.
System implementation/cold-cost/numeric-size proof remains open; B is
inapplicable and `strict_cold_eligible=false`. This is not U01/P08 acceptance.

## Independent method and integrity

Read the packet, extractor, retained captures and prior result/readiness records.
Independent standard-library text/JSON/hex/hash reads and read-only Git inspection
produced the [inspection record](independent-review-inspection.json). The author's
extractor was read, not executed or imported. Finite BL and ADRP+ADD arithmetic
used only existing archived hex; no decoder, controller, compiler, build, test,
runtime, acquisition, demangler, qualifier, image, connected action or source
repair ran.

All **four interpretation files** equal the reviewed Git blobs. All **32 archived
files** equal their baseline blobs; all **28 source-packet members** match manifest
sizes/hashes and live files. All **180 direct inputs**, **42 source hashes**, five
preexisting dirty-file hashes and cache membership/hashes match. Every numbered
line in **55 excerpt spans** equals its raw source. Both consumed directory
identities remain unchanged.

## Decisive findings

- **Static providers:** all **22 load commands** reconstruct with no LC_RPATH,
  UUID **3DEE5FE5-1F72-3C9A-8A36-4F30A2CE9ADF** and the stated ARM64 executable
  header. All **203 chained imports** agree with their encoded ordinal/weak/name
  fields. The selected Swift cold entry/ErrorWS are strong **ordinal 3** imports
  of `/usr/lib/swift/libswiftCore.dylib`; memcpy/guard/fail are strong **ordinal 1**
  imports of `/usr/lib/libSystem.B.dylib`. Selected GOT fixups, chained indices,
  indirect-symbol entries and call-stub addresses agree. The historical sanitized
  environment does not supply a toolchain override. Static install-name binding
  is established; historical loaded UUID/cache identity, reexports, interposition
  and concrete runtime implementation remain unproved. Toolchain B cannot be
  released by these system imports.
- **Actual caller joins:** exact P08 object caller symbols and call offsets match
  linked calls **0x1001b87d4** and **0x1001b9b64** (offsets **0x558/0x9c**).
  Independent arithmetic on **12 BL words** confirms both call **0x100001648**,
  its generic call reaches **0x100001740**, and the helper/stub joins agree.
  Four literal ADRP+ADD pairs independently form traversal callback
  **0x1001cc2b0**, Canvas callback **0x1001c90cc**, ABI thunk **0x100001704**
  and Error cache **0x10028c200**. The captures/context offsets establish the
  selected indirect callback targets; symbolic branch names alone are not used.
- **Duplicate names and bodies:** traversal **0x1001cc2b8** targets P08 local
  **0x1001c90cc**, whose **0x1001c90d8** targets decoder **0x100106574**.
  The separate same-named thunk **0x100106634** is not either selected callback
  pointer. The 48-instruction canonical decoder matches the retained
  GiftUISemanticCore body and differs from the P08 body. The linked generic
  matches both retained copies; no link map selects which indistinguishable
  source copy won. Exact linked code is resolved without inventing object origin.
- **Selected normal returns:** the actual linked thunks/canonical decoder preserve
  zero x21, so the conditional error transfer at **0x1000017a8** remains excluded
  on these normal returns. The decoder has no calls, stack or error-register
  reference. Traps terminate; trap/canary infeasibility and complete safety are
  not established. ErrorWS is an unused x6 data argument in this generic, not
  the metadata value-witness transfer target.
- **Cache versus size:** independent hex reads give cache bytes
  **`508af6fff9ffffff`**, word **`0xfffffff9fff68a50`**, relative name offset
  **-619,952** and negative length **-7**. They point to **0x1001f4c50**, bytes
  **`02df7a06005f70`**. The helper's sign test interprets this as the cold-form
  name descriptor. Seven bytes describe name encoding, not an Error value,
  populated metadata or stack bound. Runtime cache state at the selected Text
  call is unobserved. The unconditional linked `S=*(*(M-8)+0x40)` and
  `D=(S+15)&~15` reservation still precede callback/error testing; numeric S/D
  and feasible cold runtime costs remain absent.

R01 cold implementation/cost and R02 numeric metadata bound remain **OPEN**.
R03 is **PARTIAL RESOLVED** for exact linked bodies/branches/static imports;
historical loaded system identities/bytes remain missing. R04 remains
**OPEN COST** after resolving local guard helpers, stubs/GOT and libSystem binding.
No heap event, cold zero-heap PASS, whole-stack bound or contract impossibility
is established. These classifications match the retained evidence.

## Exact next dependency and allowances

Prepare **one separately bounded system-provider evidence request** for the
selected system Swift and libSystem/C leaves. Inventory applicable historical
image/cache UUID/build evidence and exact existing implementation bytes; identify
genuinely missing inputs. Specify proposed inspection/acquisition commands,
budgets, raw receipts, independent review and stops before execution. Current
cache-map ranges are preparation leads, not selected code or historical identity.
Any applicable metadata/layout source must match that selected runtime. The
toolchain-core B forms remain inapplicable; retargeting them is a new request.
No cache extraction, runtime/metadata probe, decoder/controller, acquisition,
source repair or successor allowance follows from this review. U02–U05 retain
their separately bounded open dispositions.

No actual contract/scope choice arose. Any proposed warm-up or heap/ownership/
privacy/bound/scope relaxation goes upstream for the requested Astra Medium
decision. Accepted ADR-039/040 and implementing SPEC-015 remain authoritative,
including the finite-counter SRAM exception. R01–R04 are current proof dependencies;
closed ITERATION-001 gains no work, and full RFC-015 remains ITERATION-004 I4-07.

Both attempts remain **1/1 consumed**, repairs **0**, retries **0**: collection
marker **[16777234,29640436]**, A-only marker **[16777234,29650609]**. Complete
callee **and** safety PASS still precede a current strict-cold manifest with its
existing host-first baseline, silent/observed/ordinary windows, counts and
zero-heap enforcement. **P08/R07/T8.1, remaining SO, strict-cold/zero-heap,
four-profile, ABI/resources, independent exit and later conformance stay open.**
