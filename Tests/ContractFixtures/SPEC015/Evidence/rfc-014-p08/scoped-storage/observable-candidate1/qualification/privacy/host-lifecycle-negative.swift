import GiftUIHostConfiguration
package func reject<F: Equatable & Sendable>(_ controller: inout MVPHostActivationController<F>) { controller.lifecycleState = .failed }
