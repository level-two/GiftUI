# SPEC-003 T4.3 Execution Correlation Evidence

`GiftUIFailureExecution` exports the exact allocation-free generic
`GiftUICorrelatedFailure<Context>` envelope. It stores the unchanged
`GiftUIFailureFact`, caller-supplied context, and inline
`GiftUIFailureAnnotations`, defaulting the annotations to an empty value.
`Sendable` and `Equatable` are conditional on the supplied context.

The focused correlation test constructs a fact with every field non-default,
appends two ordered annotations, refuses a third without changing the buffer,
and proves the envelope preserves the fact, context, and annotations exactly.
Existing execution mapping tests now return this contract-owned envelope.

The registered boundary audit verifies that Failure Execution imports exactly
Failure Core and Execution, the Execution owner does not import its downstream
adapter, and the low-level SPEC-003 fixture cannot import correlation. No
execution-specific duplicate fact envelope remains.
