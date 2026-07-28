import GiftUI

public enum StaticRuntimeError: Error, Equatable, Sendable {
    case nodeCapacityExceeded(capacity: Int)
    case traversalDepthExceeded(capacity: Int)
    case hitRegionCapacityExceeded(capacity: Int)
    case unsupportedDynamicText
    case unsupportedDynamicAction
    case invalidViewTree
}

public enum StaticLayoutResult {
    case success(StaticLayout)
    case failure(StaticRuntimeError)
}

private enum StaticNodeKind: Equatable {
    case group
    case text(TextRun)
    case button(ActionID)
    case vStack(spacing: Int)
    case hStack(spacing: Int)
}

private struct StaticNode {
    var kind: StaticNodeKind = .group
    var firstChild = -1
    var lastChild = -1
    var nextSibling = -1
    var measuredSize = Size(width: 0, height: 0)
    var frame = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 0, height: 0)
    )
}

private struct StaticNodeStorage {
    #if hasFeature(Embedded)
    private var values: InlineArray<64, StaticNode> = .init { _ in
        StaticNode()
    }
    #else
    private var values = Array(repeating: StaticNode(), count: 64)
    #endif

    subscript(index: Int) -> StaticNode {
        get { values[index] }
        set { values[index] = newValue }
    }
}

private struct ParentStorage {
    #if hasFeature(Embedded)
    private var values: InlineArray<16, Int> = .init { _ in -1 }
    #else
    private var values = Array(repeating: -1, count: 16)
    #endif

    subscript(index: Int) -> Int {
        get { values[index] }
        set { values[index] = newValue }
    }
}

private struct HitRegionStorage {
    private static var emptyRegion: HitRegion {
        HitRegion(
            bounds: Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: 0, height: 0)
            ),
            action: ActionID(rawValue: 0)
        )
    }

    #if hasFeature(Embedded)
    private var values: InlineArray<16, HitRegion> = .init { _ in
        Self.emptyRegion
    }
    #else
    private var values = Array(repeating: Self.emptyRegion, count: 16)
    #endif

    subscript(index: Int) -> HitRegion {
        get { values[index] }
        set { values[index] = newValue }
    }
}

public struct StaticLayout {
    public static let nodeCapacity = 64
    public static let traversalDepthCapacity = 16
    public static let hitRegionCapacity = 16

    private var nodes: StaticNodeStorage
    private var hitRegions: HitRegionStorage
    public let nodeCount: Int
    public let hitRegionCount: Int
    private let rootIndex: Int

    fileprivate init(
        nodes: StaticNodeStorage,
        hitRegions: HitRegionStorage,
        nodeCount: Int,
        hitRegionCount: Int,
        rootIndex: Int
    ) {
        self.nodes = nodes
        self.hitRegions = hitRegions
        self.nodeCount = nodeCount
        self.hitRegionCount = hitRegionCount
        self.rootIndex = rootIndex
    }

    public var rootFrame: Rect {
        nodes[rootIndex].frame
    }

    public func frame(at index: Int) -> Rect? {
        guard index >= 0, index < nodeCount else { return nil }
        return nodes[index].frame
    }

    public func action(at point: Point) -> ActionID? {
        guard hitRegionCount > 0 else { return nil }
        var index = hitRegionCount
        while index > 0 {
            index -= 1
            let region = hitRegions[index]
            if region.bounds.contains(point) {
                return region.action
            }
        }
        return nil
    }

    /// Returns the smallest rectangle containing nodes whose rendered pixels
    /// can differ from `previous`. A structural change falls back to the union
    /// of both root frames; an identical visual layout returns `nil`.
    public func changedRenderBounds(comparedTo previous: StaticLayout) -> Rect? {
        guard nodeCount == previous.nodeCount,
              rootIndex == previous.rootIndex else {
            return Self.union(rootFrame, previous.rootFrame)
        }

        var dirtyBounds: Rect?
        for index in 0..<nodeCount {
            let current = nodes[index]
            let old = previous.nodes[index]
            guard current.firstChild == old.firstChild,
                  current.lastChild == old.lastChild,
                  current.nextSibling == old.nextSibling,
                  Self.sameRenderRole(current.kind, old.kind) else {
                return Self.union(rootFrame, previous.rootFrame)
            }

            let changed: Bool
            switch (current.kind, old.kind) {
            case (.text(let currentText), .text(let oldText)):
                changed = currentText != oldText || current.frame != old.frame
            case (.button, .button):
                // Action identity affects hit testing, not button pixels.
                changed = current.frame != old.frame
            default:
                // Container nodes do not draw. Child frame changes are checked
                // independently, so their bounds need not inflate the damage.
                changed = false
            }
            if changed {
                let nodeBounds = Self.union(current.frame, old.frame)
                dirtyBounds = dirtyBounds.map { Self.union($0, nodeBounds) }
                    ?? nodeBounds
            }
        }
        return dirtyBounds
    }

    /// Emits operations directly from the fixed layout arena. No retained
    /// display-list allocation is required by the static runtime.
    public func appendRenderOperations<Sink: RenderOperationSink>(
        to sink: inout Sink
    ) throws(Sink.Failure) {
        try appendRenderOperations(at: rootIndex, to: &sink)
    }

    private func appendRenderOperations<Sink: RenderOperationSink>(
        at index: Int,
        to sink: inout Sink
    ) throws(Sink.Failure) {
        let node = nodes[index]
        switch node.kind {
        case .group, .vStack, .hStack:
            try appendChildRenderOperations(of: node, to: &sink)
        case .text(let text):
            try sink.append(.text(text, at: node.frame.origin))
        case .button:
            try sink.append(
                .fillRect(
                    node.frame,
                    Color(red: 62, green: 68, blue: 82)
                )
            )
            try sink.append(
                .strokeRect(
                    node.frame,
                    Color(red: 116, green: 130, blue: 160),
                    lineWidth: 1
                )
            )
            try appendChildRenderOperations(of: node, to: &sink)
        }
    }

    private func appendChildRenderOperations<Sink: RenderOperationSink>(
        of node: StaticNode,
        to sink: inout Sink
    ) throws(Sink.Failure) {
        var child = node.firstChild
        while child >= 0 {
            try appendRenderOperations(at: child, to: &sink)
            child = nodes[child].nextSibling
        }
    }

    private static func sameRenderRole(
        _ lhs: StaticNodeKind,
        _ rhs: StaticNodeKind
    ) -> Bool {
        switch (lhs, rhs) {
        case (.group, .group), (.text(_), .text(_)),
             (.button(_), .button(_)), (.vStack(_), .vStack(_)),
             (.hStack(_), .hStack(_)):
            true
        default:
            false
        }
    }

    private static func union(_ lhs: Rect, _ rhs: Rect) -> Rect {
        let minX = min(lhs.origin.x, rhs.origin.x)
        let minY = min(lhs.origin.y, rhs.origin.y)
        let maxX = max(
            lhs.origin.x + lhs.size.width,
            rhs.origin.x + rhs.size.width
        )
        let maxY = max(
            lhs.origin.y + lhs.size.height,
            rhs.origin.y + rhs.size.height
        )
        return Rect(
            origin: Point(x: minX, y: minY),
            size: Size(width: maxX - minX, height: maxY - minY)
        )
    }
}

public struct StaticRuntime: GiftUIRuntime {
    public typealias Profile = PortableRuntimeProfile

    public init() {}

    /// Allocation-free result form for Embedded clients that cannot
    /// materialize an existential `Error` across a module boundary.
    public func layoutResult<Content: View>(
        _ content: Content,
        in surfaceSize: Size
    ) -> StaticLayoutResult {
        do {
            return .success(try layout(content, in: surfaceSize))
        } catch let error {
            return .failure(error)
        }
    }

    public func layout<Content: View>(
        _ content: Content,
        in surfaceSize: Size
    ) throws(StaticRuntimeError) -> StaticLayout {
        var builder = StaticGraphBuilder()
        content._visit(&builder)
        if let failure = builder.failure {
            throw failure
        }
        guard builder.nodeCount > 0, builder.rootIndex >= 0 else {
            throw .invalidViewTree
        }

        var arena = StaticLayoutArena(builder: builder)
        try arena.layout(in: surfaceSize)
        return arena.snapshot()
    }
}

private struct StaticGraphBuilder: ViewVisitor {
    private(set) var nodes = StaticNodeStorage()
    private var parents = ParentStorage()
    private(set) var nodeCount = 0
    private var parentCount = 0
    private(set) var rootIndex = -1
    private(set) var failure: StaticRuntimeError?

    private mutating func append(_ kind: StaticNodeKind) -> Int? {
        guard failure == nil else { return nil }
        guard nodeCount < StaticLayout.nodeCapacity else {
            failure = .nodeCapacityExceeded(capacity: StaticLayout.nodeCapacity)
            return nil
        }

        let index = nodeCount
        nodeCount += 1
        nodes[index].kind = kind

        if parentCount > 0 {
            let parent = parents[parentCount - 1]
            let previousLast = nodes[parent].lastChild
            if previousLast >= 0 {
                nodes[previousLast].nextSibling = index
            } else {
                nodes[parent].firstChild = index
            }
            nodes[parent].lastChild = index
        } else if rootIndex < 0 {
            rootIndex = index
        } else {
            failure = .invalidViewTree
            return nil
        }
        return index
    }

    private mutating func withContainer<Content: View>(
        _ kind: StaticNodeKind,
        content: Content
    ) {
        guard let index = append(kind), failure == nil else { return }
        guard parentCount < StaticLayout.traversalDepthCapacity else {
            failure = .traversalDepthExceeded(
                capacity: StaticLayout.traversalDepthCapacity
            )
            return
        }
        parents[parentCount] = index
        parentCount += 1
        content._visit(&self)
        parentCount -= 1
    }

    private mutating func appendEmptyRootIfNeeded() {
        if parentCount == 0, rootIndex < 0 {
            _ = append(.group)
        }
    }

    mutating func visitBody<Content: View>(_ content: () -> Content) {
        content()._visit(&self)
    }

    mutating func visitEmpty() {
        appendEmptyRootIfNeeded()
    }

    mutating func visitTuple<A: View, B: View>(_ a: A, _ b: B) {
        a._visit(&self)
        b._visit(&self)
        appendEmptyRootIfNeeded()
    }

    mutating func visitTuple<A: View, B: View, C: View>(
        _ a: A, _ b: B, _ c: C
    ) {
        a._visit(&self)
        b._visit(&self)
        c._visit(&self)
        appendEmptyRootIfNeeded()
    }

    mutating func visitTuple<A: View, B: View, C: View, D: View>(
        _ a: A, _ b: B, _ c: C, _ d: D
    ) {
        a._visit(&self)
        b._visit(&self)
        c._visit(&self)
        d._visit(&self)
        appendEmptyRootIfNeeded()
    }

    mutating func visitTuple<A: View, B: View, C: View, D: View, E: View>(
        _ a: A, _ b: B, _ c: C, _ d: D, _ e: E
    ) {
        a._visit(&self)
        b._visit(&self)
        c._visit(&self)
        d._visit(&self)
        e._visit(&self)
        appendEmptyRootIfNeeded()
    }

    mutating func visitConditional<TrueContent: View, FalseContent: View>(
        _ storage: ConditionalContent<TrueContent, FalseContent>.Storage
    ) {
        switch storage {
        case .first(let content):
            content._visit(&self)
        case .second(let content):
            content._visit(&self)
        }
    }

    mutating func visitOptional<Content: View>(_ content: Content?) {
        if let content {
            content._visit(&self)
        } else {
            appendEmptyRootIfNeeded()
        }
    }

    mutating func visitVStack<Content: View>(
        spacing: Int,
        content: Content
    ) {
        withContainer(.vStack(spacing: spacing), content: content)
    }

    mutating func visitHStack<Content: View>(
        spacing: Int,
        content: Content
    ) {
        withContainer(.hStack(spacing: spacing), content: content)
    }

    mutating func visitText(_ content: TextContent) {
        switch content.storage {
        case .staticString, .boundedInteger:
            _ = append(.text(content.makeTextRun()))
        #if !hasFeature(Embedded)
        case .dynamicString:
            failure = .unsupportedDynamicText
        #endif
        }
    }

    mutating func visitButton<Label: View>(
        action: ButtonAction,
        label: Label
    ) {
        switch action.storage {
        case .identified(let identifier):
            withContainer(.button(identifier), content: label)
        #if !hasFeature(Embedded)
        case .callback:
            failure = .unsupportedDynamicAction
        #endif
        }
    }

}

private struct StaticLayoutArena {
    private static let glyphSize = Size(width: 8, height: 12)
    private static let buttonPadding = Size(width: 8, height: 6)

    private var nodes: StaticNodeStorage
    private var hitRegions = HitRegionStorage()
    private let nodeCount: Int
    private let rootIndex: Int
    private var hitRegionCount = 0

    init(builder: StaticGraphBuilder) {
        nodes = builder.nodes
        nodeCount = builder.nodeCount
        rootIndex = builder.rootIndex
    }

    mutating func layout(in surfaceSize: Size) throws(StaticRuntimeError) {
        let proposal = ProposedSize(
            width: surfaceSize.width,
            height: surfaceSize.height
        )
        let rootSize = measure(rootIndex, proposal: proposal)
        let origin = Point(
            x: (surfaceSize.width - rootSize.width) / 2,
            y: (surfaceSize.height - rootSize.height) / 2
        )
        place(
            rootIndex,
            in: Rect(origin: origin, size: rootSize)
        )
        try collectHitRegions()
    }

    func snapshot() -> StaticLayout {
        StaticLayout(
            nodes: nodes,
            hitRegions: hitRegions,
            nodeCount: nodeCount,
            hitRegionCount: hitRegionCount,
            rootIndex: rootIndex
        )
    }

    private mutating func measure(
        _ index: Int,
        proposal: ProposedSize
    ) -> Size {
        let kind = nodes[index].kind
        let size: Size
        switch kind {
        case .group:
            size = measureGroup(index, proposal: proposal)
        case .text(let text):
            size = Size(
                width: text.glyphCount * Self.glyphSize.width,
                height: Self.glyphSize.height
            )
        case .button:
            size = measureButton(index, proposal: proposal)
        case .vStack(let spacing):
            size = measureVStack(index, spacing: spacing, proposal: proposal)
        case .hStack(let spacing):
            size = measureHStack(index, spacing: spacing, proposal: proposal)
        }
        nodes[index].measuredSize = size
        return size
    }

    private mutating func measureGroup(
        _ index: Int,
        proposal: ProposedSize
    ) -> Size {
        var size = Size(width: 0, height: 0)
        var child = nodes[index].firstChild
        while child >= 0 {
            let childSize = measure(child, proposal: proposal)
            size.width = max(size.width, childSize.width)
            size.height = max(size.height, childSize.height)
            child = nodes[child].nextSibling
        }
        return size
    }

    private mutating func measureButton(
        _ index: Int,
        proposal: ProposedSize
    ) -> Size {
        let horizontalPadding = Self.buttonPadding.width * 2
        let verticalPadding = Self.buttonPadding.height * 2
        let labelProposal = ProposedSize(
            width: proposal.width.map { max(0, $0 - horizontalPadding) },
            height: proposal.height.map { max(0, $0 - verticalPadding) }
        )
        let child = nodes[index].firstChild
        let labelSize = child >= 0
            ? measure(child, proposal: labelProposal)
            : Size(width: 0, height: 0)
        return Size(
            width: labelSize.width + horizontalPadding,
            height: labelSize.height + verticalPadding
        )
    }

    private mutating func measureVStack(
        _ index: Int,
        spacing: Int,
        proposal: ProposedSize
    ) -> Size {
        var width = 0
        var height = 0
        var count = 0
        var child = nodes[index].firstChild
        while child >= 0 {
            let childSize = measure(
                child,
                proposal: ProposedSize(width: proposal.width)
            )
            width = max(width, childSize.width)
            height += childSize.height
            count += 1
            child = nodes[child].nextSibling
        }
        if count > 1 {
            height += spacing * (count - 1)
        }
        return Size(width: width, height: height)
    }

    private mutating func measureHStack(
        _ index: Int,
        spacing: Int,
        proposal: ProposedSize
    ) -> Size {
        var width = 0
        var height = 0
        var count = 0
        var child = nodes[index].firstChild
        while child >= 0 {
            let childSize = measure(
                child,
                proposal: ProposedSize(height: proposal.height)
            )
            width += childSize.width
            height = max(height, childSize.height)
            count += 1
            child = nodes[child].nextSibling
        }
        if count > 1 {
            width += spacing * (count - 1)
        }
        return Size(width: width, height: height)
    }

    private mutating func place(_ index: Int, in bounds: Rect) {
        nodes[index].frame = bounds
        switch nodes[index].kind {
        case .group:
            var child = nodes[index].firstChild
            while child >= 0 {
                place(
                    child,
                    in: Rect(origin: bounds.origin, size: nodes[child].measuredSize)
                )
                child = nodes[child].nextSibling
            }
        case .text:
            break
        case .button:
            let child = nodes[index].firstChild
            if child >= 0 {
                place(
                    child,
                    in: Rect(
                        origin: Point(
                            x: bounds.origin.x + Self.buttonPadding.width,
                            y: bounds.origin.y + Self.buttonPadding.height
                        ),
                        size: nodes[child].measuredSize
                    )
                )
            }
        case .vStack:
            placeVStackChildren(index, in: bounds)
        case .hStack:
            placeHStackChildren(index, in: bounds)
        }
    }

    private mutating func placeVStackChildren(_ index: Int, in bounds: Rect) {
        guard case .vStack(let spacing) = nodes[index].kind else { return }
        var y = bounds.origin.y
        var child = nodes[index].firstChild
        while child >= 0 {
            let childSize = nodes[child].measuredSize
            place(
                child,
                in: Rect(
                    origin: Point(
                        x: bounds.origin.x + (bounds.size.width - childSize.width) / 2,
                        y: y
                    ),
                    size: childSize
                )
            )
            y += childSize.height + spacing
            child = nodes[child].nextSibling
        }
    }

    private mutating func placeHStackChildren(_ index: Int, in bounds: Rect) {
        guard case .hStack(let spacing) = nodes[index].kind else { return }
        var x = bounds.origin.x
        var child = nodes[index].firstChild
        while child >= 0 {
            let childSize = nodes[child].measuredSize
            place(
                child,
                in: Rect(
                    origin: Point(
                        x: x,
                        y: bounds.origin.y + (bounds.size.height - childSize.height) / 2
                    ),
                    size: childSize
                )
            )
            x += childSize.width + spacing
            child = nodes[child].nextSibling
        }
    }

    private mutating func collectHitRegions() throws(StaticRuntimeError) {
        var index = 0
        while index < nodeCount {
            if case .button(let action) = nodes[index].kind {
                guard hitRegionCount < StaticLayout.hitRegionCapacity else {
                    throw .hitRegionCapacityExceeded(
                        capacity: StaticLayout.hitRegionCapacity
                    )
                }
                hitRegions[hitRegionCount] = HitRegion(
                    bounds: nodes[index].frame,
                    action: action
                )
                hitRegionCount += 1
            }
            index += 1
        }
    }
}
