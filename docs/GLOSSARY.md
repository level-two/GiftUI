# GiftUI Project Glossary

This glossary defines GiftUI framework, runtime, configuration, and
architecture terminology. Lifecycle and documentation-process terms are kept
separately in the
[Engineering Governance Glossary](engineering/GLOSSARY.md).

**Backend SPI (Service Provider Interface)**
: The implementation-facing contracts through which a GiftUI backend consumes
  resolved frame information and ordered render operations, presents the
  resulting frame, and reports relevant outcomes. Backend implementations
  conform to this SPI; GiftUI application code does not use it as its
  client-facing API. In this term, SPI means Service Provider Interface, not
  the Serial Peripheral Interface hardware bus used by some displays.

**Capability**
: An externally meaningful promise about which GiftUI semantics a configured
  stack can provide to client code, including constraints that affect those
  semantics. A Capability is resolved from Traits, requirements, and policy;
  it is not a raw component or platform fact.

**Dynamic profile**
: A GiftUI execution profile that can use facilities such as heap allocation,
  dynamically sized collections, runtime type information, or escaping
  closures.

**Runtime profile**
: The selected execution and storage constraints under which a GiftUI runtime
  realizes the common portable semantics. The MVP defines dynamic and static
  profiles.

**Service**
: An operation GiftUI delegates to its environment through an explicitly
  supplied contract, such as monotonic time, wake scheduling, or diagnostic
  delivery. A Service is a dependency and mechanism, not by itself a promise
  about client-visible GiftUI semantics.

**Static profile**
: A GiftUI execution profile designed for bounded or forbidden allocation and
  constrained runtime features, including Embedded Swift targets.

**Trait**
: A typed fact owned by one selected component, runtime profile, Service, or
  environment, such as a storage bound, supported pixel format, or timer
  resolution. Traits are inputs to composition and Capability resolution; they
  are not client-facing semantic promises. This term does not imply that every
  Trait is represented by a SwiftPM trait.
