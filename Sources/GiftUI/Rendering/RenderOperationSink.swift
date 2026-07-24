public protocol RenderOperationSink {
    associatedtype Failure: Error = Never

    mutating func append(
        _ operation: RenderOperation
    ) throws(Failure)
}
