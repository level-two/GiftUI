# Frozen compiler comparison result — 2026-10-12

The fixed six-call matrix identifies a compiler-version-dependent result on the
unchanged minimal wrapped-owner callback-escape control. It establishes a
candidate compiler remedy for this minimal control, not a P08 implementation or
an adopted compiler baseline.

| Official package | Reported compiler | Positive compile / execution | Wrapped-owner switch callback negative | Direct Span.take callback negative |
| --- | --- | --- | --- | --- |
| Swift 6.3.3 | Apple Swift version 6.3.3 (swift-6.3.3-RELEASE) | 0 / 0 | Accepted, exit 0; never executed | Rejected, exit 1, marker lifetime |
| Swift 6.4.0 | Apple Swift version 6.4 (swift-6.4-RELEASE) | 0 / 0 | Rejected, exit 1, marker lifetime | Rejected, exit 1, marker lifetime |

Both successful positives print `invariant private struct span positive passed`.
The 6.4 wrapped negative reports `lifetime-dependent variable 'escaped' escapes
its scope`, identifies dependence on callback-local `marker`, and identifies
callback return as the escaping use. The direct Span negatives report the same
intended lifetime condition. No rejection was a syntax, SDK or feature failure.
The Swift 6.3.3 outcome matches the previously frozen accepted 6.3.2 baseline
controls; this matrix did not recompile 6.3.2.

## Identity and unchanged comparison inputs

`setup-receipt.json` retains official URLs, isolated toolchain paths, signatures,
versions and hashes. `verified-inputs.json` records independently revalidated
package, compiler and signature-log SHA256 identities before the first compile.
Each call also checks the compiler hash, setup receipt hash and frozen source
hashes. Package 6.4.0's reported compiler version is exactly 6.4, as shown above.

`run-1` through `run-6` preserve each complete command, source snapshots, stdout,
stderr, raw result and executable hash when successful. `ledger.json` adds
classification and positive execution exit/output hashes. Positive output files
are retained at this directory's root. The two frozen receiver controls and the
frozen extraction direct Span.take control were compiled without edits.
Post-run checks verified all sources still match their frozen hashes and every
command differs from its historical command only in compiler, output and module
cache paths. Target, SDK, optimization, feature flags and all remaining flags
are unchanged. Sources import only implicit Swift, and link commands include
no GiftUI objects; historical search/plugin flags remain inert comparison inputs.
No GiftUI module binary was reused across compilers. No accepted negative was run.

## Limits and closure

Six of six compiler/link invocations are used; this scope is closed. No source
repairs, actual runtime assembly, host integration, copy negative, physical
backing-expiry negative, constant-seed control, ARMv6, nRF52840 or complete
repository validation was attempted in this scope. Swift 6.4 is promising for
this specific minimal ownership shape; a baseline decision and fresh validation
would be required before relying on it for maintained P08 work. This comparison
does not establish why compiler behavior differs or attribute an upstream fix.
The accepted compiler, contracts, maintained sources and all historical evidence
remain unchanged. Independent review is required before further decisions.
