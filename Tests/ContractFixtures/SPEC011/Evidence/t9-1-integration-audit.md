# T9.1 Integration Audit Evidence

`scripts/contracts/check-spec-011-integration-audit.rb` audits the maintained
package registry and every production Swift source. It requires:

- the exact approved direct consumers of `GiftUIInteraction`;
- one action-generation allocator construction, one pointer-capture owner, one
  Interaction state owner, one observable target-generation owner, and one
  candidate-coordinator join;
- exactly the Dynamic and Static Interaction state realizations;
- exactly the Dynamic and Static Signal Analyzer dispatch joins; and
- no backend, display, driver, or platform Interaction owner and no portable
  `GiftUIInteraction` re-export.

Reproduction:

```sh
scripts/contracts/check-spec-011-integration-audit.rb
scripts/contracts/check-spec-011-boundaries.rb
```

Both commands pass at the repository revision that contains this evidence.
Connected-target behavior is deliberately outside this source/package audit
and remains separately governed by T9.3 and T9.4.
