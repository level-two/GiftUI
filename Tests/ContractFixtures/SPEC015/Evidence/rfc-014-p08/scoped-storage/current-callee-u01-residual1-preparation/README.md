# P08 U01 R01–R04 evidence request 1 — preparation only

Prepared 2026-10-19 from **`c91d82f977bd57b3b9600ea9e7cfd164c502abdd`**,
following the [independent U01 attribution review](../current-callee-u01-attribution1-result/independent-review.md).
**The inventory and one bounded identity-first static evidence request are
prepared; independent preparation review is next. No acquisition, decoder or
runtime execution allowance is granted here.** U01 remains open; complete
callee/safety proof remains STOP and `strict_cold_eligible=false`.

The subsequent [independent preparation review](independent-review.md) passes
identity/scope and stops execution readiness on B1's omitted system-only fallback
paths. The [narrow environment correction](ENVIRONMENT.md) now applies those
values to all six complete environments and authenticates applicable loader
roots/aliases. Concrete controller preparation and independent readiness review
remain required; no proposed decoder command has run.

The subsequent [concrete A-only controller preparation](CONTROLLER.md) implements
external final pins, fresh atomic consumption, full input/loader authentication,
aggregate/per-command limits, raw/actual-exit receipts and an explicit closed
provider gate. A maximum of three decoder commands is proposed for this concrete
attempt; all B commands are skipped. One separately accounted bootstrap remains
unused, unexecuted and unapproved. Independent Strong readiness review is next.

The [request JSON](request.json) contains six exact proposed argv arrays,
input/tool hashes, environments, ordering, gates, output limits and stop rules.
The [inventory](inventory.json) records availability and hash/provenance joins.
The [inventory program](inventory.py) uses only standard-library file hashing,
text/JSON/plist reads and read-only Git. It performs no binary metadata or
instruction decoding, imports no production code and writes only those two JSON
records. Its newly inventoried installation/tool inputs are checked against its
first record on repeat inspection. Reproduce the inventory from the repository
root with:

```text
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-u01-residual1-preparation/inventory.py
```

## Existing linked artifact and provenance

| Existing input | Availability and applicability |
| --- | --- |
| Actual ordinary counter | `.build/contracts/p08-counter-npoej3u2/counter`, **6,602,168 bytes**, SHA-256 **`12d51381b0a776a3a05c60aa3f97b732a0490434435194d6eda0e29ef0d89242`**. It equals the frozen receipt's `artifacts.counter` byte count/hash. This is the ordinary retained executable; it has not been run or decoded here. |
| Exact receipt and link | Its `result.json` equals previously frozen SHA-256 **`6850a3f150938e2a755f2260c94c42d7f103b0110639599a27925ba377b8ecb8`**. Command index **405** (zero based) links this counter; index **406** records its historical invocation. All **25** link object paths equal the collection's exact object-capture set and still match the input freeze hashes. `Main.swift` and empty `link.log` also match their frozen artifact records. |
| Root entry | The frozen 276-byte `Main.swift` invokes `p08CounterRoute()` plus model, semantic, fixed-storage and coordinator checks. The retained `[nothrow]` Text paths remain the U01 attribution roots. This receipt is ordinary observation evidence, not a silent/cold measurement. |
| Other retained executables | Native-exclusivity positive/negative executables match their own frozen hashes. Their distinct entry/source and purpose make them unsuitable replacements for the ordinary counter. No decoder command is proposed for them. |
| Historical environment | `.build/contracts/p08-retained-evidence-counter384-successor1/launch.json` records a sanitized environment with no `DYLD_*`, `Malloc*` or `SWIFT_*` overrides. The frozen `p08_check_collection.py:272` subprocess call inherits that environment. This supports static loader reasoning but supplies no loaded-image list, actual library UUID or historical system-cache build. |

The receipt's compile target is **`arm64-apple-macosx26.0`**, with the
**MacOSX26.5 SDK** and Swift 6.4 compiler. The three are distinct facts; none
selects a runtime library by itself. The linked executable has not yet supplied
its load commands, UUID, rpaths, import ordinals, fixups, retained symbol
addresses or actual linked callback/generic winner in this investigation.

## Runtime/library and source availability

| Candidate/evidence | Exact availability | What it cannot establish yet |
| --- | --- | --- |
| Swift 6.4 runtime bytes | `.toolchains/host/swift-6.4.0-RELEASE-osx/usr/lib/swift/macosx/libswiftCore.dylib`: **17,395,344 bytes**, SHA-256 **`51358d2d79fcdcb739e28d050109b49047131f1001c32654904dbbd63cd6013a`**. These bytes also equal the exact expanded Swift 6.4 package payload entry in the frozen predecessor `retained-trees.json`; that manifest itself matches the current collection input freeze. | Historical byte provenance is established; loader selection, matching architecture/UUID and provider applicability remain unresolved. No body/data from this candidate was decoded here. |
| Swift interface/version | The toolchain plist identifies `org.swift.640202609131a`, version `6.4.20260913101`. Its arm64 Swift interface matches the frozen payload manifest and reports `Apple Swift version 6.4 (swift-6.4-RELEASE)`, target `arm64-apple-macosx13.0`. | Public `Error` protocol declarations do not give the numeric existential value size or populate `M`/its value-witness table. They do not prove which dylib was loaded. |
| ABI implementation source | Three explicit toolchain ABI/Runtime metadata-header paths in the inventory are absent. No applicable exact runtime-source revision or numeric Error layout proof has been joined. | Do not substitute an assumed Error representation. This is an inventory limitation, not a claim that no such evidence can ever exist. |
| System Swift/C providers | `/usr/lib/swift/libswiftCore.dylib`, `/usr/lib/libSystem.B.dylib` and `/usr/lib/system/libsystem_c.dylib` are absent as standalone files at the inventoried paths. Current `/usr/lib/system/libsystem_platform.dylib` and `libsystem_kernel.dylib` exist and are hashed as unselected candidates. | Existence of another system dylib does not select `_memcpy`, guard or fail implementations. No decoder command is proposed for these unselected files. |
| Current dyld cache map | The current arm64e map lists `/usr/lib/swift/libswiftCore.dylib`, `/usr/lib/system/libsystem_c.dylib` and platform image ranges. Its exact hash/text entries are recorded. Fourteen other arm64e cache members were listed by path/size only. | Cache binary bytes were not hashed, decoded, copied or extracted. A current map is not executable code, a historical cache match or an actual loaded-image observation. |
| SDK stubs | The MacOSX26.5 `.tbd` files are present and hashed; selected export text names ErrorWS, the cold runtime entry, `_memcpy` and stack-guard/fail symbols. | `.tbd` exports contain no implementation instructions, metadata layout or runtime dispatch proof. |
| Current system metadata | SystemVersion.plist reports **macOS 26.6.2 / 25G83**; Xcode plist and SDK metadata are recorded separately. | This newly inventoried current installation metadata is not a historical OS/cache identity receipt. |

These are file/text/hash observations only. No cache acquisition or extraction,
network fetch, SDK/toolchain installation, runtime-source download, binary
loader operation or populated metadata read occurred.

## One proposed static request, with a provider gate

**Proposed allowance: one attempt, at most six static decoder commands, zero
acquisitions, zero runtime/compiler/build/test/controller/strict-cold launches,
zero repairs and zero retries. Used here: zero.** The proposed output directory
`.build/contracts/p08-u01-residual-static1` remains absent. No launch program is
created or invoked by this preparation; exact execution and permanent receipt
handling must be independently reviewed before a separately authorized launch.

All argv arrays are literal structured data in `request.json`; none has run.
They use the pinned Apple `otool-classic`, retained LLVM 21 `llvm-nm-21` and
`llvm-objdump-21`. The two LLVM tools still match the original input freeze;
all **34** retained decoder dependency-tree entries match their file hashes or
symlink targets. The Apple tool and its local manual are newly hashed. The
manual describes the requested header/load/dependency/indirect-symbol/bind and
chained-fixup switches; no tool help/probe command was invoked.

| Stage | Proposed exact operation | Bound/output |
| --- | --- | --- |
| A1 | `otool-classic -arch arm64 -hv -l -L -Iv -dyld_info -chained_fixups` on the exact retained counter. | One command; 8 MiB combined raw stdout/stderr maximum. Capture load/rpath/UUID/import/fixup information. |
| A2 | `llvm-nm-21 --numeric-sort` on that counter. | One command; 16 MiB maximum. Preserve all reported architecture labels; no cross-architecture target substitution. |
| A3 | `llvm-objdump-21 --macho --arch=arm64 --disassemble --reloc --full-contents --no-show-raw-insn` on that counter. | One command; 128 MiB maximum. Capture linked code/data and direct/indirect target material needed to join the U01 roots. |
| Gate | Interpret A's retained outputs with standard-library text/JSON reads. Establish exact arm64 root/body joins and unambiguous applicable provider resolution under the historical no-override environment. | If the pinned toolchain runtime cannot be established as applicable, **STOP before B**. Matching versions, filenames, export names or compatible duplicate bodies do not satisfy the gate. |
| B1–B3 | The same three structured command forms on the exact pinned toolchain `libswiftCore.dylib`. | One command each; 8/16/256 MiB maxima. B is conditional on the provider gate, never a default fallback. |

Each command has a **60-second wall limit**; the attempt has a **360-second /
512-MiB total output cap**. Metadata/symbol commands are static decoders too;
they count against the six-command maximum. An invocation with nonzero exit,
unsupported format/option, timeout, truncated output or missing required record
stops the attempt without a replacement command or retry. Additional targeted
disassembly after the proposed full captures is outside this request.

The proposed environments are explicit whitelists in the JSON. LLVM alone uses
the frozen decoder library directory in `DYLD_LIBRARY_PATH`; this affects the
inspection tool, not a counter/runtime process. No counter/library is executed
or loaded into a probe. Authenticate all inputs/tools/dependencies, source and
preservation hashes before execution and each command. Retain raw streams,
argv/environment, actual start/exit, timeout/cap states and hashes before any
interpretation; record every gated/skipped command. The former collection
marker **[16777234, 29640436]** is never reused, reset or modified. A later
authorized attempt requires its own permanent consumption receipt.

## R01–R04 deliverables, missing inputs and stops

| Residual | What these captures could supply | Evidence still unavailable/unproved and required stop |
| --- | --- | --- |
| R01 cold metadata | Actual linked import/provider identity; applicable cold entry body/data and feasible transitive implementation within the selected pinned core. | No selected cold runtime implementation/cost is yet captured. A transitive target outside the pinned inputs, unresolved runtime dispatch or cache initialization state remains open. No recursive library acquisition or extra decoder is allowed. |
| R02 numeric Error size | Applicable runtime static metadata or exact constructor/data evidence for `S=*(*(M-8)+0x40)` and `D=(S+15)&~15`, if the pinned static bytes establish it. | No populated process metadata or exact numeric ABI proof is currently available. If static data/construction cannot prove the slot and bound, stop with the missing evidence; do not run a metadata-size probe. The selected conditional `+0x20` error transfer stays excluded as independently reviewed. |
| R03 linked providers | Linked addresses/call targets for the selected callback/thunk/generic bodies; import ordinals, rpaths/fixups and provider candidates. | No actual loaded-image or historical system-cache identity receipt exists in the inventoried records. If static selection is ambiguous or selects unavailable system-cache bytes, stop. No warm-up/loader observation or candidate-provider substitution is implied. |
| R04 memcpy/canary | Exact linked import/stub/binding identities and applicable code if genuinely within the pinned selected inputs. Existing local guard helpers remain understood. | Selected C/system provider bodies, `_memcpy` dispatch/resolver choice and applicable guard/failure costs are not joined. SDK stubs and current map entries cannot close them; no cache extraction or unselected platform decode is prepared. Trap/canary infeasibility remains part of the separate safety proof. |

This request can produce useful partial static evidence and still stop with open
rows. It does not promise a complete resource or zero-heap result. If the missing
provider requires cache extraction, downloaded source, additional library bytes,
runtime loader observation or populated process metadata, preserve its exact
identity gap and prepare a separately reviewed, bounded request before any such
action. No command-ready acquisition recipe for those unknown providers is
claimed here.

## Independent review handoff and unchanged authority

Review this preparation at its resulting commit. Independently check the receipt
and 25-object joins, frozen payload runtime hash, distinction between bytes and
provider identity, current versus historical metadata/cache applicability,
proposed argv/options/tool dependencies, provider gate, caps and raw-receipt
requirements. Do not execute the proposed commands during review. The author's
inventory program may be read; independent standard-library inspection should
establish the preparation verdict. Any missing command/readiness detail remains
an explicit execution prerequisite; preparation review does not grant a new
allowance or declare U01 solved.

No actual contract/scope choice arose. Any warm-up exception or relaxation of
heap/ownership/privacy/bound/scope obligations must go upstream for the
maintainer-requested Astra Medium decision. No such choice is made here.
[ADR-039](../../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md),
[ADR-040](../../../../../../../docs/adrs/adr-040-counter-physical-sram-budget.md)
and [implementing SPEC-015 S15.1/S15.2](../../../../../../../docs/specs/spec-015-host-configuration.md)
remain authoritative; ADR-040's finite-counter exception stays in force.
This is active ITERATION-003's necessary finite-counter dependency for analyzer
and constrained stack validation; closed ITERATION-001 gains no work. Full
RFC-015 remains ITERATION-004 I4-07. R01–R04 remain current proof dependencies;
no optional deferred item was discovered and U02–U05 were not investigated.

The 67 prior frozen inputs, six reviewed U01 packet files, 42 source hashes,
five preexisting dirty-file hashes and preexisting Python cache remain intact.
Only evidence/preparation and minimal navigation records changed. Collection
**1/1 consumed**, repairs **0**, retries **0** remain unchanged. No compiler,
build, test, controller, decoder, demangler, qualifier, runtime, strict-cold,
image, connected action or maintained source repair occurred. Complete callee
**and** safety PASS must precede preparation of a new current strict-cold
manifest; exact host-first baseline, silent/observed/ordinary windows,
workload/baseline counts and zero-heap enforcement remain binding.
**P08/R07/T8.1, remaining SO criteria, strict-cold/zero-heap, four-profile,
ABI/resources, independent exit and later conformance gates remain open.**
