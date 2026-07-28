import GiftUI

public final class GiftUIApplication<Root: View> {
    public let runtime: DynamicRuntime
    public var hitRegions: [HitRegion] {
        interaction.hitTestMap.regions
    }

    private let root: Root
    private let backgroundColor: Color
    private let identifiedActionHandler: ((ActionID) -> Void)?
    private var interaction = InteractionSnapshot()
    private var pressedAction: ActionID?
    private var isRendering = false
    private var isDispatching = false
    private var hasRendered = false
    private var previousRootFrame: Rect?

    public init(
        root: Root,
        runtime: DynamicRuntime = DynamicRuntime(),
        backgroundColor: Color = Color(red: 24, green: 26, blue: 32),
        identifiedActionHandler: ((ActionID) -> Void)? = nil
    ) {
        self.root = root
        self.runtime = runtime
        self.backgroundColor = backgroundColor
        self.identifiedActionHandler = identifiedActionHandler
    }

    @discardableResult
    public func renderIfNeeded<Backend: RenderBackend>(
        into backend: inout Backend
    ) -> Bool {
        renderIfNeeded(in: backend.surfaceSize) { backgroundColor, displayList, _, _ in
            backend.beginFrame()
            backend.clear(backgroundColor)
            backend.execute(displayList)
            backend.endFrame()
            backend.present()
        }
    }

    /// Builds one invalidated frame and lets a platform choose how its pixels
    /// are stored and presented.
    ///
    /// The dirty region is the union of the previous and current root frames.
    /// The first frame covers the full surface so retained displays start from
    /// a deterministic background.
    @discardableResult
    public func renderIfNeeded(
        in surfaceSize: Size,
        rendering: (
            _ backgroundColor: Color,
            _ displayList: DisplayList,
            _ dirtyRegion: Rect,
            _ isFullRefresh: Bool
        ) throws -> Void
    ) rethrows -> Bool {
        guard runtime.isInvalid else { return false }
        precondition(!isRendering, "GiftUI rendering must not be reentrant")

        isRendering = true
        defer { isRendering = false }

        let renderGeneration = runtime.invalidationGeneration
        let graph = runtime.makeViewGraph(root, in: surfaceSize)
        let displayList = graph.makeDisplayList()
        rebuildActions(from: graph)
        let rootFrame = graph.layoutNode().frame
        let isFullRefresh = previousRootFrame == nil
        let dirtyRegion = previousRootFrame.map {
            Self.union($0, rootFrame)
        } ?? Rect(origin: Point(x: 0, y: 0), size: surfaceSize)

        try rendering(
            backgroundColor,
            displayList,
            dirtyRegion,
            isFullRefresh
        )
        previousRootFrame = rootFrame
        runtime.markRendered(ifUnchangedSince: renderGeneration)
        hasRendered = true
        return true
    }

    @discardableResult
    public func send(_ event: InputEvent) -> Bool {
        guard hasRendered else { return false }
        precondition(!isDispatching, "GiftUI input dispatch must not be reentrant")
        isDispatching = true
        defer { isDispatching = false }

        switch event {
        case .pointerDown(let point):
            pressedAction = action(at: point)
            return false
        case .pointerMove(let point):
            if let pressedAction,
               action(at: point) != pressedAction {
                self.pressedAction = nil
            }
            return false
        case .pointerUp(let point):
            let releasedAction = action(at: point)
            defer { pressedAction = nil }
            guard
                let pressedAction,
                releasedAction == pressedAction,
                interaction.perform(
                    pressedAction,
                    identifiedActionHandler: identifiedActionHandler
                )
            else {
                return false
            }
            return true
        }
    }

    private func rebuildActions(from graph: ViewNode) {
        pressedAction = nil
        interaction = graph.makeInteractionSnapshot()
    }

    private func action(at point: Point) -> ActionID? {
        interaction.action(at: point)
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
