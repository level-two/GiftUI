# SPEC-009 T6.2 Focused-Owner Adapter Evidence

The common adapter recognizes only `.focusedOwner` and returns the unchanged
generic finite value with its detecting context. Every other common failure
case returns no focused mapping, so no fallback fact or generic translation is
available.

The fixture owner exhaustively switches over mutation, completion, semantic,
layout, and immutable-render-input cases and supplies its own exact facts. The
switch has no default and the common adapter never observes or substitutes the
owner's mapping.
