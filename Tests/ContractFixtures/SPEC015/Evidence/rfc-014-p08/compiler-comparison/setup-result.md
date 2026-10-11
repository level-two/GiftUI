# Official comparison compiler setup — 2026-10-12

Both official packages in the [bounded scope](scope.md) downloaded and extracted
successfully under `.toolchains/p08-comparison/`. The existing Swift 6.3.2
toolchain and repository compiler pins remain unchanged. No installer, SDK setup,
global selection change, compiler test, or maintained-script edit occurred.

The initial sandboxed 6.3.3 signature query reported `invalid signature`.
Its pending escalation was interrupted by the parent, not rejected by the human.
Subsequent top-level, user-approved signature checks exited zero for both packages,
identifying Swift Open Source and trusted Apple notarization. Complete outputs
are retained in [6.3.3 signature](signature-6.3.3.txt) and
[6.4.0 signature](signature-6.4.0.txt). No compiler executable ran before those
successful verification results were available.

[Setup receipt](setup-receipt.json) records official URLs, local package and
executable paths, streamed SHA256 hashes, signature record identities and exact
version output. [Commands](setup-commands.txt) preserve the setup invocations;
signature commands represent the successful approved external verification.
Version queries are metadata only. The official 6.4.0 package's executable reports
`Apple Swift version 6.4 (swift-6.4-RELEASE)`; that exact output is preserved.

The isolated compiler executables are:

- `.toolchains/p08-comparison/expanded/swift-6.3.3-RELEASE-osx/swift-6.3.3-RELEASE-osx-package.pkg/Payload/usr/bin/swiftc`
- `.toolchains/p08-comparison/expanded/swift-6.4.0-RELEASE-osx/swift-6.4.0-RELEASE-osx-package.pkg/Payload/usr/bin/swiftc`

This completes setup only. Strong remains the sole compiler-test owner under the
six-invocation comparison scope. No candidate baseline adoption, verified host
join, cross-platform result, or P08 completion follows from package setup.
