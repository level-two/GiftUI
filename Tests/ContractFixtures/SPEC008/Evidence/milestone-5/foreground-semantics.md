# Foreground and Background Semantics Evidence

Streaming now requires an empty caller-owned foreground stack, pushes the root
foreground before `begin`, and resolves every text group from
`currentForeground`. Each foreground modifier pushes before its subtree and
pops after it, with restoration checked at both modifier and root boundaries.
No foreground value is passed through recursive traversal frames.

The focused golden combines nested green/red foreground modifiers, nested
blue/gray backgrounds, and a root-level sibling. Events show outer background
before inner background, innermost red text, and restoration to the white root
foreground for the sibling. Workspace high-water is exactly three values and
reset leaves the stack empty. The workspace contract test covers inactive,
full, empty, and LIFO behavior.

Run:

```sh
swift test --filter foregroundStackUsesInnermostColorRestoresSiblingsAndOrdersNestedBackgrounds
scripts/contracts/check-spec-008-foreground-semantics.rb
```
