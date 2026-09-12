# T2.5 Action Validation Faults

The recording coordinator adapter performs domain and total raw-value validation
before it can yield a bounded action to candidate append. The coordinator fault
oracle requires both failures to produce no append and no frame offer, discard
the complete candidate once, dispatch nothing, and preserve the exact local
error. The normalizer never substitutes a Semantic or Execution error.
