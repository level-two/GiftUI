# SPEC-010 Portable Declaration Family

Plan task: `T1.1`

Date: 2026-09-05

`Sources/GiftUI/ObservableState.swift` implements the exact public declaration
family owned by SPEC-010: the seven closed report outcomes, noncopyable change
sink, observable-reference attach/detach protocol, non-forgeable attachment,
state-declaration visitor, state-host protocol, and the `State` source shape
required by the visitor signature.

Attachment and sink construction are package-only. The sink exposes only its
read-only attachment and synchronous report operation. The wrapper contains
one logical initial or bound case; successful package binding replaces the
initializer with fixed read/replacement routes and returns the former
initializer to its owner. Full owner binding, mutation-result routing, and
profile-specific storage remain T1.3 work and are not claimed complete here.

The registered declaration audit fixes names, types, raw values, ownership
modifiers, and the non-forgeable boundary while rejecting Foundation,
Observation, task-local, string-key, reflection, and `Any` mechanisms. The
ordered fixture manifest compiles a public model and manual lexical host
witness and rejects external attachment, sink, and binding construction.
Those fixtures compile with the maintained `GiftUI` module in macOS dynamic,
macOS static, Raspberry Pi ARMv6, and nRF52840 Embedded driver modes.

Host unit tests execute every raw-value assertion, complete attachment
identity, exact report-route forwarding, initializer consumption, bound reads,
bound replacements, and repeated-binding rejection. This evidence establishes
T1.1 only; macro generation and the generated traversal witness remain
T1.2/T1.4.
