# Candidate 2 maintained Swift format

`swift format format --configuration .swift-format --in-place` ran once on
`Sources/GiftUI/DeclarativeView.swift`,
`Sources/GiftUIMacros/ObservableStateHostMacro.swift`, and
`Tests/GiftUIMacrosTests/ObservableStateHostMacroTests.swift` before validation.
The contract fixture is excluded by repository format policy. Only two line
wraps in the macro test changed. The post-format macro test SHA-256 is
`42b14cf51ae9804414f6936d2c5f64dd55d6f2b5e8b8e2811adcccc9582158d6`.
The candidate source receipt preserves the pre-format frozen patch and hashes;
the validation input freeze must use this post-format test hash. `git diff --check`
passed. No compiler or test ran in this step.
