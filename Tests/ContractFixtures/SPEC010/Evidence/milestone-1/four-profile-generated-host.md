# SPEC-010 Four-Profile Generated Host

Plan task: `T1.5`

Date: 2026-09-06

The canonical `portable-profile` fixture contains one portable observable
reference model and one public `@ObservableStateHost` view with direct `@State`
and `@GiftUI.State` declarations. The host macro snapshot test expands that
input to the checked-in generated source. The expansion assigns ordinals zero
and one in lexical order, emits the state-host conformance, and routes semantic
traversal through `visitStatefulCustomView`.

Each SPEC-010 profile driver compiles that same checked-in generated source as
an optimized target object after compiling the production `GiftUI` module. All
four reports record the identical generated-source SHA-256:

```text
02831ec5318c786ef899dcae52c0f82910981af79658f4e81bdb45e8645c862b
```

| Profile | Target | Optimization | Result |
| --- | --- | --- | --- |
| macOS dynamic | `arm64-apple-macosx26.0` | `-O -whole-module-optimization` | complete |
| macOS static | `arm64-apple-macosx26.0` | `-O -whole-module-optimization` | complete |
| Raspberry Pi | `armv6-unknown-linux-gnueabihf` | `-O -whole-module-optimization` | complete |
| nRF52840 | `armv7em-none-none-eabi` | `-Osize -whole-module-optimization` | complete |

Every report retains the target object's complete named-symbol inventory.
`check-spec-010-profile-host.rb` rejects `GiftUIMacros`, SwiftSyntax,
SwiftDiagnostics, SwiftCompilerPlugin, and `ObservableStateHostMacro` in that
closure. The four audits pass, proving the build-host macro and compiler
support do not enter either embedded target image. This is hardware-free
compile and image-inspection evidence; it claims no simulator, target
execution, deployment, service restart, or flashing.

Reproduction commands:

```text
swift test --filter ObservableStateHostMacroTests
scripts/contracts/run-spec-010.sh --profile macos-dynamic
scripts/contracts/run-spec-010.sh --profile macos-static
scripts/contracts/run-spec-010.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-010.sh --profile nrf52840-embedded
```

Reports remain generated under `.build/contract-reports/`; the fixture,
driver, and this evidence record are the stable reproduction inputs. OS-001
and OS-010 remain pending until their later owner, behavior, and final
four-profile tasks are complete.
