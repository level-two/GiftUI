# 02-capacity

Date: 2026-10-04. Base revision: `a14b0797c8f9091fdc3d98eb0df4499b53da6cc5`; changed source hashes recorded alongside this result.

T10.1 implemented. All five unequal store positions preserve previous committed tables; staged shortage returns capacityExhausted before copying, generation error precedence retained, discard/reuse and exact one-slot commit pass. T10.2/T10.3 retain profile validation obligations.

[Raw validation](validation.log), [source identities](source-hashes.txt). Host execution only; no connected evidence. Focused correctness: 14 XCTest cases and 15 Swift Testing cases passed.
