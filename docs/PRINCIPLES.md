# GiftUI Principles

GiftUI is guided by the following principles:

- **Familiar Swift experience**  
  Prefer a declarative, composable API that feels natural to developers familiar with SwiftUI.

- **Backend independence**  
  Application-facing concepts should not depend on a particular renderer, graphics library, operating system, or display technology.

- **Embedded is a first-class target**  
  Resource-constrained and statically built environments must influence the design from the beginning rather than being treated as later ports.

- **Capabilities are explicit**  
  Differences between platforms and hardware should be represented deliberately rather than hidden behind assumptions.

- **Scale across environments**  
  Core abstractions should remain useful from small embedded displays to richer Linux systems.

- **Pay attention to cost**  
  Memory use, binary size, runtime overhead, and implementation complexity are important design considerations.

- **Preserve concepts, not implementations**  
  Different platforms may realize the same UI concept in different ways.

- **SwiftUI is inspiration, not specification**  
  Familiarity and conceptual similarity are valuable, but GiftUI should adapt where non-Apple environments require different choices.

## Non-goals

GiftUI does not aim to:

- reproduce every SwiftUI API;
- provide SwiftUI source compatibility at any cost;
- replace SwiftUI on Apple platforms;
- hide meaningful differences between fundamentally different hardware;
- require runtime features that make constrained Embedded Swift targets impractical.
