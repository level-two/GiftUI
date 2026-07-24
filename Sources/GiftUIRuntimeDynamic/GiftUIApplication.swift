import GiftUI

public final class GiftUIApplication<Root: View> {
    public let runtime: DynamicRuntime
    public private(set) var hitRegions: [HitRegion] = []

    private let root: Root
    private let backgroundColor: Color
    private var actions: [ActionID: () -> Void] = [:]
    private var pressedAction: ActionID?
    private var isRendering = false
    private var isDispatching = false

    public init(
        root: Root,
        runtime: DynamicRuntime = DynamicRuntime(),
        backgroundColor: Color = Color(red: 24, green: 26, blue: 32)
    ) {
        self.root = root
        self.runtime = runtime
        self.backgroundColor = backgroundColor
    }

    @discardableResult
    public func renderIfNeeded<Backend: RenderBackend>(
        into backend: inout Backend
    ) -> Bool {
        guard runtime.isInvalid else { return false }
        precondition(!isRendering, "GiftUI rendering must not be reentrant")

        isRendering = true
        defer { isRendering = false }

        let graph = runtime.makeViewGraph(root, in: backend.surfaceSize)
        let displayList = graph.makeDisplayList()
        rebuildActions(from: graph)

        backend.beginFrame()
        backend.clear(backgroundColor)
        backend.execute(displayList)
        backend.endFrame()
        backend.present()
        runtime.markRendered()
        return true
    }

    @discardableResult
    public func send(_ event: InputEvent) -> Bool {
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
                let action = actions[pressedAction]
            else {
                return false
            }
            action()
            return true
        }
    }

    private func rebuildActions(from graph: ViewNode) {
        hitRegions.removeAll(keepingCapacity: true)
        actions.removeAll(keepingCapacity: true)
        var nextID = 0
        graph.collectActions(
            nextID: &nextID,
            hitRegions: &hitRegions,
            actions: &actions
        )
    }

    private func action(at point: Point) -> ActionID? {
        hitRegions.last { $0.bounds.contains(point) }?.action
    }
}
