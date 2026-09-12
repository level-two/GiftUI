# T2.2 Effective Disabled State

The lowering state is an immutable value passed down one semantic branch.
Applying a scope computes `ancestorEnabled && !localDisabled`; consequently
`disabled(false)` cannot re-enable an ancestor and sibling traversal receives
its original parent value. The modifier creates no identity and imports no
backend state.
