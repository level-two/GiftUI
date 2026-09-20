import GiftUIDrawing
import GiftUIRuntimeCore

package enum StaticCanvasHostValidationError: UInt8, Equatable, Sendable {
    case invalidLimits = 0
    case incompleteCallableTable = 1
}

/// Performs the Static Canvas limit/table join without constructing profile storage
/// or invoking a generated callable.
package enum StaticCanvasHostValidation {
    package static func validate<Metadata: RuntimeStaticCanvasAuditMetadata>(
        limits: StaticCanvasLimits?,
        metadata: borrowing Metadata
    ) -> StaticCanvasHostValidationError? {
        guard let limits else { return .invalidLimits }
        guard metadata.callableCaseCount > 0,
            metadata.callableCaseCount <= limits.maximumStaticCallableCases,
            metadata.declaredEntryCount == metadata.callableCaseCount,
            metadata.maximumDeclaredID == metadata.callableCaseCount
        else {
            return .incompleteCallableTable
        }

        var id: UInt16 = 1
        while true {
            guard metadata.coverageMultiplicity(for: id) == 1,
                let captureBytes = metadata.captureByteCount(for: id),
                captureBytes <= limits.maximumStaticCaptureBytes
            else {
                return .incompleteCallableTable
            }
            if id == metadata.callableCaseCount { break }
            id += 1
        }
        return nil
    }
}

/// A copyable, unretained view of one host-owned observable model location.
///
/// The handle is created only from a host-owned address. Constructing it is the
/// host's explicit proof that the address remains stable and outlives every
/// generated Canvas invocation that receives the handle.
package struct StaticCanvasObservableModelHandle<Model>: @unchecked Sendable {
    private let location: UnsafePointer<Model>

    package init(hostOwnedLocation: UnsafePointer<Model>) {
        location = hostOwnedLocation
    }

    package borrowing func withModel<Result, Failure: Error>(
        _ body: (borrowing Model) throws(Failure) -> Result
    ) throws(Failure) -> Result {
        try body(location.pointee)
    }
}
