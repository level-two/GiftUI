# Fresh Swift6.4 Foundation regression — 2026-10-12

The complete maintained SPEC-002 RFC014 gate passes macOS Dynamic, macOS Static,
Raspberry Pi ARMv6 and nRF52840 using the final driver at b5140b92. Each receipt's
complete repository input and output artifact inventories were hash-verified
before freeze. The report retains native execution versus target-IR/artifact
checks explicitly; no target application ran and no hardware was changed.

The gates retain the Foundation surface, import boundaries, fixed semantic corpus,
11 bounded value layouts, allocation/resource exclusions and matched linked
baseline/candidate section deltas and maps. Those descriptive linked deltas are
measured with the approved6.4 compiler on both sides. Full source/output hashes
are preserved; generated binaries and larger build caches remain at the recorded
project-local report/build paths. Reproduce using run-spec-002.sh --profile PROFILE
--compiler-baseline rfc-014.

The initial surface failure came from Swift6.4 interface module qualification
(`Swift::UInt8` instead of `Swift.UInt8`). The checker normalizes only the allowed
Swift/GiftUI owners; boundary checks reject prohibited owners using either
separator. Six controls verify both positive spellings plus wrong correlation
width, optional provenance and both forbidden-owner spellings. API access,
owner sets and dependency restrictions are unchanged.

Two narrowed setup/driver repairs followed: restore the SDK's standard identity
marker after re-verifying its archive SHA; select --target GiftUI because SwiftPM
ignores --product for an automatic library and starts the default application
build. The unintended run was explicitly interrupted and its logs preserved.
The native SwiftPM backend is explicit, as already required by the fresh macro
baseline. Final four-profile reruns use the same final driver source identity.
No Swift production source, feature contract, resource limit or gate was weakened.

The scope is closed with all four final passes and two productive compatibility
repairs. Historical initial native passes, setup failure and interrupted run
remain identified; no failure is recast as a pass. Independent review remains
required before activation-blocker closure. This Foundation baseline evidence
does not complete the application/P08/P11 acceptance package.
