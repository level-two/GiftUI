import GiftUIDrawing
import GiftUIExecution
import GiftUIRuntimeCore

package struct StaticRuntimeExecutionBindingAdapter<Regions, Metadata>:
    StaticExecutionProfileBinding
where
    Regions: StaticProfileStorageRegions & ~Copyable,
    Metadata: RuntimeStaticCanvasAuditMetadata & StaticCanvasCallableTable
{
    private let binding: UnsafeMutablePointer<StaticRuntimeProfileBinding<Regions, Metadata>>

    package init(
        binding: UnsafeMutablePointer<StaticRuntimeProfileBinding<Regions, Metadata>>
    ) {
        self.binding = binding
    }

    package var executionContext: ExecutionContext {
        binding.pointee.executionContext
    }

    package var isQuiescent: Bool {
        binding.pointee.isQuiescent
    }

    package mutating func quiesce() {
        binding.pointee.quiesce()
    }
}
