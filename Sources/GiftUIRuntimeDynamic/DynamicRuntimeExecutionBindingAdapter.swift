import GiftUIExecution

/// Compatibility with the retained pre-cutover profile binding. The current
/// scoped activation passes its concrete binding directly to the coordinator.
package struct DynamicRuntimeExecutionBindingAdapter: DynamicExecutionProfileBinding {
    private let binding: UnsafeMutablePointer<DynamicRuntimeProfileBinding>
    package init(binding: UnsafeMutablePointer<DynamicRuntimeProfileBinding>) {
        self.binding = binding
    }
    package var executionContext: ExecutionContext { binding.pointee.executionContext }
    package var isQuiescent: Bool { binding.pointee.isQuiescent }
    package mutating func quiesce() { binding.pointee.quiesce() }
}

package extension DynamicRuntimeExecutionCoordinator
where Binding == DynamicRuntimeExecutionBindingAdapter {
    @_lifetime(copy admission, copy opportunity)
    init(
        binding: UnsafeMutablePointer<DynamicRuntimeProfileBinding>, admission: consuming Admission,
        opportunity: consuming Opportunity
    ) {
        self.init(
            binding: DynamicRuntimeExecutionBindingAdapter(binding: binding),
            admission: consume admission, opportunity: consume opportunity)
    }
}
