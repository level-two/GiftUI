# SPEC-009 T6.1 Execution Failure Adapter Evidence

`GiftUIFailureExecution` imports exactly `GiftUIFailureCore` and
`GiftUIExecution`. Admission mapping covers queued success and all four
failures with the original post-cancellation `ExecutionContext`; mapping is
unavailable until mandatory mechanical effects are declared complete.

The execution matrix covers all nine local errors, both legal capacity scopes,
all three identity-exhaustion scopes, and safe-reuse containment. It rejects
unproven scope narrowing and incomplete cycle effects, preserving exact
condition, origin, smallest proven affected scope, containment, and context.
