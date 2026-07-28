import GiftUI

/// Heap-backed render storage for dynamic runtime clients.
public struct DisplayList: Equatable, Sendable, RenderOperationSink {
    public private(set) var operations: [RenderOperation]

    public init(operations: [RenderOperation] = []) {
        self.operations = operations
    }

    public mutating func append(_ operation: RenderOperation) {
        operations.append(operation)
    }
}

public extension RenderBackend {
    mutating func execute(_ displayList: DisplayList) {
        for operation in displayList.operations {
            execute(operation)
        }
    }
}

extension ViewNode {
    package func makeDisplayList() -> DisplayList {
        var displayList = DisplayList()
        appendRenderOperations(to: &displayList)
        return displayList
    }
}
