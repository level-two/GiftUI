# GiftUI Proof-of-Concept Historical Baseline

The retired proof-of-concept implementation and mixed legacy documents remain
available from the immutable annotated Git tag `PoC`.

| Evidence | Value |
| --- | --- |
| Durable remote | `https://github.com/level-two/GiftUI.git` |
| Annotated tag object | `2b2837a66b94df38c7b74ead33ebbb54aa08a06d` |
| Dereferenced commit | `d5d6330432caa7c983d8dba35cf9f23c3800860b` |
| Complete root tree | `305e3cd4226c14873204a4711e0b5fd1a7fd9d1f` |

Retrieve a historical path without restoring it to the active tree:

```sh
git show PoC:<path>
```

Reconstruct the complete tracked baseline with:

```sh
git archive --format=tar --output=/tmp/giftui-poc.tar PoC
```

The following mixed legacy documents were retired from the active tree. They
remain historical evidence only and do not carry Proposal, RFC, ADR, or
Specification authority:

```text
docs/GiftUI_ADS7846_Bring_Up_Record.md
docs/GiftUI_Embedded_Layer_Inventory.md
docs/GiftUI_Framework_Spec.md
docs/GiftUI_ILI9486_Bring_Up_Record.md
docs/GiftUI_KMRTM24024_SPI_nRF52840_Spec.md
docs/GiftUI_KMRTM24024_Stack_Ownership_Proposal.md
docs/GiftUI_PiScreen_Phase_7_Validation_Record.md
docs/GiftUI_PoC_A_macOS_Simulator_Spec.md
docs/GiftUI_Raspberry_Pi_Platform.md
docs/GiftUI_Runtime_Profile_Migration_Plan.md
docs/GiftUI_nRF52840_DK_Platform_Spec.md
```

For example:

```sh
git show PoC:docs/GiftUI_Framework_Spec.md
```

Current architecture and implementation authority remains in accepted ADRs
and approved or implementing Specifications under the governed lifecycle.
