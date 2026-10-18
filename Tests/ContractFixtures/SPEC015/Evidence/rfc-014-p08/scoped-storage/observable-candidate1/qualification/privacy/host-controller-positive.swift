import GiftUIHostConfiguration
package func forward<Owner: MVPHostActivationOwner & MVPHostTeardownOwner & ~Copyable & ~Escapable>(_ controller: inout MVPHostActivationController<Owner.ActivationFailure>, owner: inout Owner, failure: Owner.ActivationFailure) { _ = controller.lifecycleState; _ = controller.activate(owner: &owner, invariantFailure: failure); controller.teardown(owner: &owner) }
