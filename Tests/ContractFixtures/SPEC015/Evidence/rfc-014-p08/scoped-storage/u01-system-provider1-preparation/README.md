# P08 U01 system-provider evidence request — preparation only

Baseline: independent linked/provider review `8e3c74694f75a233221b32fe179ddfde9cf00fcb`.
This is a new, bounded U01 R01–R04 static evidence request. No acquisition,
extraction, decoder, controller, runtime, compiler, build or test ran. The old B
request remains inapplicable and unexecuted. No scope, contract, architecture,
source acceptance or strict-cold disposition changes.

The [linked/provider result](../u01-linked-provider-interpretation1-result/README.md)
and its [independent review](../u01-linked-provider-interpretation1-result/independent-review.md)
remain authoritative for this evidence boundary: linked counter UUID
`3DEE5FE5-1F72-3C9A-8A36-4F30A2CE9ADF` imports absolute system Swift and
libSystem, with no LC_RPATH selecting the pinned toolchain core. LC_BUILD_VERSION
is a link target/SDK record, not the historical runtime OS identity.

## Existing evidence and applicability

[inventory.json](inventory.json) pins paths, sizes, SHA-256, selected report
fields, cache membership and literal-byte correspondences. The standard-library
[inventory.py](inventory.py) reads/hashes existing files only and writes this
packet's two JSON files. It verifies 180 prior direct inputs, the 42 sources,
five preexisting dirty files/cache and both permanent consumed marker identities.

An existing local diagnostic report,
`/Users/eugene/Library/Logs/DiagnosticReports/so06-native-exclusivity-negative-2026-10-19-131150.ips`,
is 7,394 bytes, SHA-256
`f15190c81d022debc91037c07a4064a9d9d3f78e4130afffad65ce0cba420203`.
It records macOS 26.6.2 build `25G83`, ARM64, untranslated, capture time
`2026-10-19 13:11:49.7076 +0200`, and shared-cache UUID
`f2e86c53-6052-388b-ba71-5a0c9b569413`. Selected image records are:

| Image | Architecture | Historical UUID |
| --- | --- | --- |
| Supplemental native-exclusivity negative | arm64 | `634a7b5f-1800-3c84-ad42-d09276ca5562` |
| `/usr/lib/swift/libswiftCore.dylib` | arm64e | `83794fb3-de9b-3d23-ab5e-2c1d5d30f134` |
| `/usr/lib/system/libsystem_c.dylib` | arm64e | `d77ceb62-aff6-3cec-ba9b-4f057fbe2eb5` |
| `/usr/lib/dyld` | arm64e | `74e52480-c2bd-3c8d-812d-95fe2b74a096` |

The negative executable and execute log match the frozen counter result's
artifact hashes. The report's negative executable UUID bytes occur uniquely at
file offset 2,808. This supports association with that retained supplemental
artifact. The report was absent from the frozen counter artifact manifest and
is first pinned here. Only relevant selected fields are retained; the complete
local report is authenticated by hash.

**This report describes a different process.** No ordinary-counter loaded-image
UUID receipt has been found or established. These joins cannot prove the
ordinary counter's historical loaded provider, even when a cache candidate
matches the supplemental process.

The existing cache family under
`/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld` has 15
`dyld_shared_cache_arm64e*` members, 5,824,684,071 bytes total. All members,
including map/atlas files, are individually hashed; membership and file stat
identities remain unchanged across this inventory. The primary header's first
16 bytes are `64796c645f7631202061726d36346500`. The reported shared-cache UUID's
literal bytes occur at `0x58` in its first 4,096 bytes. Reported Swift/C UUID
bytes also occur in the family, and their map __TEXT bases yield the same
candidate slide `0x2810000` against the report. Current SystemVersion.plist
records matching `25G83`/26.6.2. These are byte/text correspondences; no cache
format decoder ran. Field semantics and image identities need the proposed
identity gate. Map names, offsets or matching OS version alone do not pass it.

Swift core, libSystem.B and libsystem_c lack standalone files at their exact
install paths; libsystem_platform exists. No selected-system Swift ABI source
revision, `Metadata.h`, `ExistentialContainer.h`, arm64e Swift interface, or
populated Error metadata/value-witness size has been established. Toolchain 6.4
interfaces and SDK stubs are insufficient version/implementation evidence.

## Narrow proposed static route

The installed Apple tool
`/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/dyld_info`
is 354,688 bytes, SHA-256
`af56890ce0c564d0df60929914018f484a75db2a42011acda629b39ce2c66aeb`.
Its pinned installed manual documents cache-backed dylib paths without standalone
files and the proposed options. The tool itself was not invoked, including help.
This avoids proposing cache extraction or acquiring any bytes. Actual support,
format, output size and identity remain subject to independent review and the
one-shot stop conditions.

[request.json](request.json) contains exact argv arrays, complete environments,
cwd, input pins, output caps and gates. Each environment explicitly fixes
`DYLD_FALLBACK_LIBRARY_PATH=/usr/lib` and
`DYLD_FALLBACK_FRAMEWORK_PATH=/System/Library/Frameworks`, with no library
provider override. Commands use the exact Apple tool path above, sequentially:

| Stage / ID | Literal options and operands after tool path | Combined raw cap |
| --- | --- | --- |
| I / system-image-identities | `-arch arm64e -uuid -platform -linked_dylibs -exports -imports -function_starts -function_variants /usr/lib/swift/libswiftCore.dylib /usr/lib/libSystem.B.dylib /usr/lib/system/libsystem_c.dylib /usr/lib/system/libsystem_platform.dylib` | 16 MiB |
| S / system-swift-body-data | `-arch arm64e -disassemble -all_sections_bytes /usr/lib/swift/libswiftCore.dylib` | 192 MiB |
| S / system-c-body-data | `-arch arm64e -disassemble -all_sections_bytes /usr/lib/libSystem.B.dylib /usr/lib/system/libsystem_c.dylib /usr/lib/system/libsystem_platform.dylib` | 64 MiB |

Proposed budget: one fresh attempt, at most three decoder commands, 60 seconds
each, 240 seconds aggregate including bootstrap/authentication/provider gate,
320 MiB total retained output including receipts. Acquisition/extraction/network,
runtime/compiler/build/test, automatic repair and retry budgets are all zero.
A separate concrete one-shot bootstrap/controller would need preparation and
readiness review; none is supplied or executed here. New output root
`.build/contracts/p08-u01-system-provider-static1` is absent. No historical
attempt marker or allowance can be reused.

Before S, I must identify each exact install path and arm64e image, with Swift/C
UUIDs matching the supplemental report, authenticated cache UUID field semantics,
and OS build correspondence. Exact linked imports must remain system Swift and
libSystem. Failure means immediate STOP with both S commands skipped; no human
wait or deadline reset, provider substitution, extraction or alternate tool.
libSystem/platform identities have no direct historical report pin; preserve
that applicability limit. Successful S can supply conditional implementation
bytes, while ordinary-process identity remains open.

Before launch and every command, authenticate all 15 cache members/membership,
report/artifact/log, linked evidence, tool/manual, previous complete interpreter
and Xcode loader roots/aliases, sources and dirty/cache identities. The installed
OS `/usr/lib` and `/System/Library` loader trust boundary is explicit; no hermetic
OS claim follows. External final commit/repository/packet/input/code/environment
pins must precede any future bootstrap. A fresh permanent attempt marker must be
atomically claimed before any child, with durable exact argv/environment/auth,
claim/start, raw stdout/stderr, actual exit, hashes, timeout/cap and skipped-command
receipts. Caps stop and kill owned process groups; truncated output cannot pass.

## R01–R04 handoff and stop boundary

| Residual | Available now | Proposed contribution / still missing |
| --- | --- | --- |
| R01 cold metadata implementation/transitive cost | Exact ordinary linked helper/runtime import and conditional system Swift candidate | S Swift bodies/data may identify cold implementation; all feasible transitive costs, initialization/cache state and allocations remain to be attributed. |
| R02 Error size/aligned temporary | Exact `S=*(*(M-8)+0x40)`, `D=(S+15)&~15` and selected local control flow | No numeric S or matched layout source. Static body/data may expose a constructor/layout constant; do not assume it will. |
| R03 linked/loaded provider | Exact system install-name imports; supplemental historical UUID/build/cache correspondence | I authenticates cache candidate identity. Direct ordinary-counter historical loaded-image evidence remains missing. |
| R04 memcpy/guard/fail | Exact linked strong libSystem imports/stubs and local guard branches | I/S may resolve reexports/variants and selected bodies. Resolver choice, canary data, fail path and transitive costs remain conditional/unproved. |

Stop on any input or membership drift, unsupported format/flag/path/architecture,
missing identity/body, nonzero exit, timeout or output cap. Preserve residuals if
Error size, resolver/transitive implementation or ordinary-process applicability
is still missing; no automatic additional operation follows. Need for source/tool
acquisition, runtime observation, warmup, or a contract/scope exception goes back
to the parent for a separate decision. No actual contract/scope decision is made
by this preparation.

Next: independent Strong preparation review of identity/applicability, exact tool
feasibility, budget, loader trust and fail-closed gate; then separately concrete
controller/readiness and execution authorization. This packet does not approve
itself. R01–R04, U02–U05, P08/R07/T8.1 remain open and
`strict_cold_eligible=false`. ADR-039/040 and SPEC-015 S15.1/S15.2 remain unchanged;
this serves active ITERATION-003 counter dependency, with no closed ITERATION-001
or broader RFC-015 implementation commitment.

Preserved consumed markers: historical collection `[16777234,29640436]` and
A-only static `[16777234,29650609]`, each 1/1 consumed, repairs0/retries0. Five
preexisting dirty tracked files and the preexisting cache remain unchanged.
