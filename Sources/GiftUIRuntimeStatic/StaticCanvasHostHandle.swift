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
/// The handle is created only inside `StaticCanvasHostModelLocation.withHandle`.
/// That scope is the host's explicit proof that the address remains stable and
/// outlives every generated Canvas invocation performed by `body`.
package struct StaticCanvasObservableModelHandle<Model>: @unchecked Sendable {
    private let location: UnsafePointer<Model>

    fileprivate init(location: UnsafePointer<Model>) {
        self.location = location
    }

    package borrowing func withModel<Result>(
        _ body: (borrowing Model) -> Result
    ) -> Result {
        body(location.pointee)
    }
}

/// Caller-owned inline storage that supplies the only approved Static Canvas
/// observable-model handle construction seam.
package struct StaticCanvasHostModelLocation<Model>: ~Copyable {
    private var model: Model

    package init(model: consuming Model) {
        self.model = consume model
    }

    package mutating func withHandle<Result>(
        _ body: (StaticCanvasObservableModelHandle<Model>) throws -> Result
    ) rethrows -> Result {
        try withUnsafePointer(to: &model) { location in
            try body(StaticCanvasObservableModelHandle(location: location))
        }
    }
}
