# Analyzer ABI continuation after disk interruption

The user authorized one fresh bounded continuation on 2026-10-18 after clearing
the full disk. The previous campaign was consumed and stopped during its first
P02 macOS Static attempt when the result write failed with `ENOSPC`. Its `.build`
logs and incomplete producer directory were subsequently removed during cleanup;
they cannot be recovered or qualified as a P02 result. The committed source
candidate `9bb82929` and postformat freeze `1d8913c9` remain unchanged.

The cleanup removed all `.build` contents, including 87 of the 541 frozen inputs:
eight SwiftSyntax checkout headers, 78 prebuilt module/doc/ABI files, and
`libMacroSupport.a`. No surviving frozen input has a changed hash. Before a new
campaign, run the exact registered P02 `host-macro-build` command once under the
validation lock with the pinned Swift 6.4 toolchain, package scratch path and
cache root. Record the argv, environment, exit and raw logs. This is dependency
restoration only; it grants no P02 or macro-test PASS.

```sh
ruby scripts/lib/serialize-validation.rb bash -c '
set -e
source scripts/lib/swiftpm.sh
GIFTUI_SWIFT_EXECUTABLE="$PWD/.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swift" \
giftui_swiftpm --package-path "$PWD" \
  --scratch-path "$PWD/.build/rfc014-p02-swift64/tool" \
  --cache-root "$PWD/.build/rfc014-p02-swift64/tool-cache" \
  --configuration debug --target GiftUI --disable-sandbox \
  -- build --build-system native
'
```

After restoration, require the original 541-path freeze to match every byte,
including all 87 restored inputs. Do not replace any frozen hash. Stop on a
missing or changed input, compiler/SDK identity, bootstrap failure or unexpected
producer choice. Then freeze and independently review a successor recipe with
fresh output roots; run each macro, P02/profile, control and dependent stage once
in the original order, zero source repairs and zero retries. The original packet
and freeze remain immutable. Strict-cold and P08 acceptance remain unproved.

The successor packet's independent pre-execution review found that the cleanup
also removed the generic `.build/contracts` parent. Its guarded wrapper creates
the campaign root with `mkdir()` and therefore requires that parent to exist.
Recreate only the empty parent with `mkdir -p .build/contracts`; require
`.build/contracts/p08-analyzer-abi-continuation-campaign2` to remain absent.
This is directory setup, not a campaign invocation or source/recipe repair.
