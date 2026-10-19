# P08 U01 retained I identity interpretation 1

Baseline: independent I-only result review
`2c6570e6daf716d632a91cc2f15445de7e8a36c4`. **Identity/text attribution only;
complete callee and safety STOP.** No dyld_info, S, old B, controller, target
runtime, compiler, build, test, acquisition, source repair or retry ran.

[inspection.json](inspection.json) and [retained-excerpts.txt](retained-excerpts.txt)
record exact raw line anchors, section counts, dependencies, selected symbols and
joins. [inspect.py](inspect.py) uses standard-library text/JSON/SHA-256 and
read-only Git only. All13 archived source files match manifest and reviewed Git
bytes. Raw stdout is2,944,589 bytes, SHA-256
`3c05b9f22facbe4e624915e637e13dfc9ba6bed21e92f89413db7f5a69f88cba`,
41,534 lines; stderr is empty. The [independent capture review](../u01-system-provider-static1-i-only-result1/independent-review.md)
retains its capture-only PASS and STOP_cache_schema_unestablished disposition.
No controller is resumed and both S commands remain skipped.

## Exact four records

All requested records are present in the [archived stdout](../u01-system-provider-static1-i-only-result1/system-image-identities.stdout).
Each reports **arm64e**, platform **zippered(macOS/Catalyst)**, minOS **26.6**,
SDK **26.6.1**. These are image build targets, not historical runtime OS identity.
Each has platform, UUID, linked-dylib, export, import and function-start sections.

| Image | Raw lines | UUID | Dependencies | Export / import / start rows |
| --- | --- | --- | --- | --- |
| `/usr/lib/swift/libswiftCore.dylib` |1–37364|`83794FB3-DE9B-3D23-AB5E-2C1D5D30F134`|7|15042 /246 /22057|
| `/usr/lib/libSystem.B.dylib` |37365–37517|`4FED5EE2-5D3E-35B1-A170-9859C4B683BB`|39|3 /77 /22|
| `/usr/lib/system/libsystem_c.dylib` |37518–41017|`D77CEB62-AFF6-3CEC-BA9B-4F057FBE2EB5`|16|1321 /271 /1880|
| `/usr/lib/system/libsystem_platform.dylib` |41018–41534|`EDB83A19-EC17-32DE-9350-6145970A85D6`|1|185 /40 /279|

UUID lines are6,37370,37523,41023; platform lines4,37368,37521,41021.
All dependency paths/attributes and section boundaries are retained in inspection
JSON. Swift's dependencies include Foundation/ObjectiveC/CoreFoundation
upward/delay-init records, libc++, libSystem, objc and libswiftPrespecialized.
libSystem lists39 reexport dependencies, including C (37386) and platform (37405).
C lists platform (37531) and other system dependencies, with16 total records;
platform lists only libsystem_kernel (41026). These image-wide dependency lists
do not establish a feasible call graph for the selected cold helper.

Although `-function_variants` was in the exact I request, **no distinct
function-variants heading/table is emitted** in any record. This is an output
observation, not proof that the images contain no variants or that a runtime
implementation was selected. Platform's export table does explicitly annotate
six other exports with dynamic resolvers: OSAtomicDequeue, platform strcmp/strncmp,
and three os_apt Swift task exports (41051,41123,41128,41168–41170).
The selected `__platform_memmove` export has no such printed annotation.
Named starts such as `__platform_memmove+736` (41342), SME memcpy/memmove and
os_apt variant-like names are retained labels; they are not decoded instructions,
structured variant selection or evidence of which implementation executes.

## Provider joins and their limits

The frozen [system inventory](../u01-system-provider1-preparation/inventory.json)
and all203 direct inputs match their hashes, including the full15-member cache
family, report, negative artifact/log, exact counter/link inputs, source42 and
five dirty files/cache. Exact cache membership remains unchanged. The map is
pinned along with the cache family; no cache/header-format decoder ran.

Swift and C I records exactly match the **path, arm64e architecture and UUID**
from the existing supplemental native-exclusivity negative process report. That
report records macOS26.6.2 build25G83 and shared-cache UUID
`f2e86c53-6052-388b-ba71-5a0c9b569413`; current SystemVersion.plist matches its
build/version. Their map bases0x193C4F000 /0x18038D000 and report bases retain
the same candidate slide0x2810000. This corroborates the supplemental/current
candidate; it does not make a different process the ordinary counter.

libSystem/platform I UUIDs have no direct match in that supplemental report.
Swift, libSystem and C operands lacked standalone files and the pinned installed
tool documents cache-backed lookup. The platform operand **did exist** as a
514,032-byte standalone file, SHA-256
`0e4588f3c7e7f855acbfc0e540b9517b318545e8d60ccf5c31ddd04966fc791c`.
Its printed starts are small offsets, while Swift/libSystem/C starts are larger
cache-address-form values. The output does not explicitly identify input origin.
Do not transfer platform's standalone record/offsets into the cache merely
because the map has the same path; exact cache-image UUID qualification is open.

The existing literal known cache UUID bytes at0x58 still supply **no independently
justified cache-header field schema**. I reports image UUIDs, not cache-header
UUID semantics. Missing ordinary-counter historical loaded-image identity and
cache-schema proof remain missing. arm64e library records do not themselves
prove what the ARM64 linked counter loaded historically. No toolchain-core B
retargeting, old S release or provider/safety PASS follows.

## Selected symbol attribution, without body/cost inference

The [prior linked result](../u01-linked-provider-interpretation1-result/README.md)
continues to fix both actual Text callers, local thunk/generic/cache helper and
strong counter imports: Swift ordinal3 for the runtime entry/ErrorWS; libSystem
ordinal1 for memcpy/canary. This interpretation adds these precise I records:

| Selected identity | Exact I evidence | What remains missing |
| --- | --- | --- |
| Swift `_swift_getTypeByMangledNameInContext2` | Export offset0x0009B7A4 (14843), function start0x193CEA7A4 (18862); equals pinned map base+export offset | Implementation instructions, local/transitive calls, initialization/cache paths, allocation and stack costs |
| Swift `_$ss5ErrorWS` | Export offset0x5C0FC8C0 (10510); no exact function-start row | Contents/layout/type applicability; this export offset is not numeric Error value size |
| Swift C/canary imports | fail/guard (15111–15112), memcpy/memmove (15217–15218), all printed from libSystem | Whether/when selected helper reaches them; image-wide imports alone prove no transitive call or allocation |
| libSystem umbrella | Reexports C/platform (37386,37405); own export table has only3 rows, none of these selected symbols | Complete umbrella export search/runtime resolution, not uniquely established by four records |
| C memcpy/memmove | Both explicitly reexport `__platform_memmove from libsystem_platform` (38307,38309); matching C import (38926) | Complete ordinary binding/provider/variant selection and body cost |
| Platform target | `__platform_memmove` export/start0x3360 (41117,41341); `+736` start0x3640 (41342); SME memcpy0x6E9C and memmove0x6F7C also present | Exact cache counterpart and runtime selection; SME names do not select an implementation; no instructions captured |
| C canary | fail export0x78A94 (37704), start0x180405A94 (40977), equals map base+export offset; guard export0x6CBBB4E0 (37705), no exact function-start row | Fail body/callees, guard data/value/access costs and selected branch/cold-safety costs |

This supplies a **recorded candidate route** from libSystem's C reexport to C's
explicit memcpy alias and platform target. The other libSystem reexports are not
all individually inspected, so no unique umbrella search winner is asserted.
Export offsets/function starts provide identities and locations only. No Error
metadata size, function extent, instruction count, allocator event, no-allocation
proof, resolver cost or whole-execution bound is inferred from them.

## R01–R04 and smallest next handoff

| Residual | Current disposition |
| --- | --- |
| R01 | OPEN: selected Swift export/start and supplemental identity joined; exact cold implementation, cache initialization and feasible transitive allocation/stack costs absent. |
| R02 | OPEN: prior `S=*(*(M-8)+0x40)`, `D=(S+15)&~15` remain symbolic. ErrorWS export identity gives neither populated metadata/value-witness bytes nor version-matched layout/numeric S/D. |
| R03 | PARTIAL: four I identities, two supplemental UUID joins and authenticated cache/map/input correspondence; ordinary historical loaded identity, cache-header schema and platform standalone/cache equivalence remain open. |
| R04 | OPEN_COST: C alias/platform candidate and C guard/fail identities sharpen attribution; unique umbrella/runtime variant/resolver choice, data/instructions and all selected costs remain unproved. |

Next is independent Strong review of this interpretation. The smallest subsequent
evidence handoff is **one new preparation-only cache-schema request**: inventory
existing authoritative `mach-o/dyld_cache_format.h` candidates at `/usr/include`,
the pinned Xcode toolchain's `usr/include`, and MacOSX26.5.sdk's `usr/include`,
record exact bytes/hash/version provenance if present, or explicitly mark missing.
Proposed inventory ceiling: three exact candidate files,16MiB total,60s aggregate,
standard-library/Git reads only; zero decoder/controller/network/acquisition or
runtime/compiler/build/test launches. A found header still needs independently
justified applicability to this cache/build before any field parser is proposed.
No header is acquired or read as part of the current interpretation. If absent,
freeze the missing schema input and prepare any acquisition separately with exact
provenance/budget/review. No automatic extra search or substitution follows.

Only after an independently authenticated schema/candidate identity may a fresh
separately reviewed body/data request be prepared; it must preserve the missing
ordinary historical identity and layout/transitive residuals. Neither body capture
nor schema work can resume the consumed I attempt or old B/S. No new execution
allowance is established here. No actual contract/scope decision arose; any
warm-up or heap/ownership/privacy/bound/scope relaxation goes upstream.

Three permanent marker identities remain unchanged, each1/1 consumed,
repairs0/retries0: collection `[16777234,29640436]`, A-only `[16777234,29650609]`,
I-only `[16777234,29652748]`. U02–U05, complete callee/safety, strict-cold/zero-heap,
remaining SO/four-profile/ABI/resources/independent-exit/conformance and
P08/R07/T8.1 remain open. ADR-039/040 and implementing SPEC-015 remain unchanged.
