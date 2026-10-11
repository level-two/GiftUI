# Approved Swift 6.4 pin and local setup step — 2026-10-12

The [explicit approval](../../../../../../../docs/iterations/iteration-003-review/rfc-014-spec-approval.md#swift-64-compiler-baseline-correction--2026-10-12)
at `267616c9` is applied to the RFC-014 compiler selector and Pi/Nordic toolchain
pins. The official package tag is `swift-6.4.0-RELEASE`; the executable's exact
reported version is `Apple Swift version 6.4 (swift-6.4-RELEASE)`. Version checks
use the latter instead of requiring a nonexistent `6.4.0` version string.

The canonical `.toolchains/host/swift-6.4.0-RELEASE-osx` and
`.toolchains/nrf52840/swift/swift-6.4.0-RELEASE-osx` paths are project-local links
to the previously verified package payload. Package links also provide the
expected cached-download paths. No existing directory was overwritten. The
[compiler setup](compiler-setup.json) rechecks package/executable SHA256 values,
records exact links and version output, and identifies preserved 6.3.2 compilers.
Original trusted signature records remain in the
[comparison setup receipt](../../compiler-comparison/setup-receipt.json).

The matching Bookworm ARMv6 SDK archive was downloaded under `.toolchains/` and
verified against SHA256
`3332907e1fe366a24cdd9b4af566cb4f1a1f39aa8fad785cb328af17c7484848`
before extraction. Its 6,973 archive paths were checked for the expected root,
absolute paths and parent traversal. Both extracted destination files now select
the project-local SDK and host tools, retaining `armv6-unknown-linux-gnueabihf`
and all existing compile/link flags. The [extraction receipt](sdk-extraction.json)
and [destination identities](sdk-destinations.json) retain that evidence; original
and localized JSON snapshots are included. The old 6.3.2 SDK remains present.

[Checks](checks.json) pass shell syntax and both metadata-only doctor commands.
Full doctor output is retained in [Pi log](pi-doctor.log) and
[Nordic log](nrf-doctor.log). Neither command used `--probe`.
[Receipt](receipt.json) records changed-source hashes and the step's limits;
[commands](commands.txt) records external setup and verification invocations.

No compiler probe, compilation, global installation/selection, target execution,
deploy, restart or flash occurred. Zephyr and its SDK were not changed. These
checks establish local setup and pin selection, not fresh ABI, target compatibility,
resource, host-integration or P08 acceptance. Fresh validation remains required.
