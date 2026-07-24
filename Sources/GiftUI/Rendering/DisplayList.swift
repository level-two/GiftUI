public struct DisplayList: Equatable, Sendable {
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

    mutating func execute(_ operation: RenderOperation) {
        switch operation {
        case .fillRect(let rect, let color):
            fill(rect, color: color)
        case .strokeRect(let rect, let color, let lineWidth):
            stroke(rect, color: color, lineWidth: lineWidth)
        case .text(let text, let origin):
            drawText(text, at: origin)
        }
    }
}
