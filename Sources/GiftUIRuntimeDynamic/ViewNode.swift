import GiftUI

package enum ViewNodeKind {
    case group
    case text(TextRun)
    case button(ButtonAction)
    case vStack(spacing: Int)
    case hStack(spacing: Int)
}

public final class ViewNode {
    package static let glyphSize = Size(width: 8, height: 12)
    package static let buttonPadding = Size(width: 8, height: 6)

    package let kind: ViewNodeKind
    package var children: [ViewNode]
    package var measuredSize = Size(width: 0, height: 0)
    package var frame = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 0, height: 0)
    )

    package init(
        kind: ViewNodeKind,
        children: [ViewNode] = []
    ) {
        self.kind = kind
        self.children = children
    }

    package var unwrappedGroupChildren: [ViewNode] {
        if case .group = kind {
            return children.flatMap(\.unwrappedGroupChildren)
        }
        return [self]
    }

    @discardableResult
    package func measure(
        proposal: ProposedSize,
        context: inout LayoutContext
    ) -> Size {
        let size: Size
        switch kind {
        case .group:
            size = measureGroup(proposal: proposal, context: &context)
        case .text(let content):
            size = Size(
                width: LayoutArithmetic.requireMultiply(
                    content.glyphCount,
                    Self.glyphSize.width,
                    operation: "measuring text"
                ),
                height: Self.glyphSize.height
            )
        case .button:
            let horizontalPadding = LayoutArithmetic.requireMultiply(
                Self.buttonPadding.width,
                2,
                operation: "measuring button horizontal padding"
            )
            let verticalPadding = LayoutArithmetic.requireMultiply(
                Self.buttonPadding.height,
                2,
                operation: "measuring button vertical padding"
            )
            let labelProposal = ProposedSize(
                width: proposal.width.map {
                    max(
                        0,
                        LayoutArithmetic.requireSubtract(
                            $0,
                            horizontalPadding,
                            operation: "proposing button label width"
                        )
                    )
                },
                height: proposal.height.map {
                    max(
                        0,
                        LayoutArithmetic.requireSubtract(
                            $0,
                            verticalPadding,
                            operation: "proposing button label height"
                        )
                    )
                }
            )
            let labelSize = children.first?.measure(
                proposal: labelProposal,
                context: &context
            ) ?? Size(width: 0, height: 0)
            size = Size(
                width: LayoutArithmetic.requireAdd(
                    labelSize.width,
                    horizontalPadding,
                    operation: "measuring button width"
                ),
                height: LayoutArithmetic.requireAdd(
                    labelSize.height,
                    verticalPadding,
                    operation: "measuring button height"
                )
            )
        case .vStack(let spacing):
            size = measureVerticalStack(
                spacing: spacing,
                proposal: proposal,
                context: &context
            )
        case .hStack(let spacing):
            size = measureHorizontalStack(
                spacing: spacing,
                proposal: proposal,
                context: &context
            )
        }
        measuredSize = size
        return size
    }

    package func place(
        in bounds: Rect,
        context: inout LayoutContext
    ) {
        frame = bounds

        switch kind {
        case .group:
            for child in children {
                child.place(
                    in: Rect(origin: bounds.origin, size: child.measuredSize),
                    context: &context
                )
            }
        case .text:
            break
        case .button:
            guard let label = children.first else { return }
            label.place(
                in: Rect(
                    origin: Point(
                        x: LayoutArithmetic.requireAdd(
                            bounds.origin.x,
                            Self.buttonPadding.width,
                            operation: "placing button label horizontally"
                        ),
                        y: LayoutArithmetic.requireAdd(
                            bounds.origin.y,
                            Self.buttonPadding.height,
                            operation: "placing button label vertically"
                        )
                    ),
                    size: label.measuredSize
                ),
                context: &context
            )
        case .vStack(let spacing):
            var y = bounds.origin.y
            for child in children {
                child.place(
                    in: Rect(
                        origin: Point(
                            x: LayoutArithmetic.requireAdd(
                                bounds.origin.x,
                                LayoutArithmetic.requireSubtract(
                                    bounds.size.width,
                                    child.measuredSize.width,
                                    operation: "centering vertical stack child"
                                ) / 2,
                                operation: "placing vertical stack child"
                            ),
                            y: y
                        ),
                        size: child.measuredSize
                    ),
                    context: &context
                )
                y = LayoutArithmetic.requireAdd(
                    y,
                    LayoutArithmetic.requireAdd(
                        child.measuredSize.height,
                        spacing,
                        operation: "advancing vertical stack spacing"
                    ),
                    operation: "advancing vertical stack position"
                )
            }
        case .hStack(let spacing):
            var x = bounds.origin.x
            for child in children {
                child.place(
                    in: Rect(
                        origin: Point(
                            x: x,
                            y: LayoutArithmetic.requireAdd(
                                bounds.origin.y,
                                LayoutArithmetic.requireSubtract(
                                    bounds.size.height,
                                    child.measuredSize.height,
                                    operation: "centering horizontal stack child"
                                ) / 2,
                                operation: "placing horizontal stack child"
                            )
                        ),
                        size: child.measuredSize
                    ),
                    context: &context
                )
                x = LayoutArithmetic.requireAdd(
                    x,
                    LayoutArithmetic.requireAdd(
                        child.measuredSize.width,
                        spacing,
                        operation: "advancing horizontal stack spacing"
                    ),
                    operation: "advancing horizontal stack position"
                )
            }
        }
    }

    package func layoutNode() -> LayoutNode {
        LayoutNode(
            frame: frame,
            children: children.map { $0.layoutNode() }
        )
    }

    package func appendRenderOperations<Sink: RenderOperationSink>(
        to sink: inout Sink
    ) throws(Sink.Failure) {
        switch kind {
        case .group, .vStack, .hStack:
            for child in children {
                try child.appendRenderOperations(to: &sink)
            }
        case .text(let content):
            try sink.append(
                .text(
                    content,
                    at: frame.origin
                )
            )
        case .button:
            try sink.append(
                .fillRect(
                    frame,
                    Color(red: 62, green: 68, blue: 82)
                )
            )
            try sink.append(
                .strokeRect(
                    frame,
                    Color(red: 116, green: 130, blue: 160),
                    lineWidth: 1
                )
            )
            for child in children {
                try child.appendRenderOperations(to: &sink)
            }
        }
    }

    package func makeInteractionSnapshot() -> InteractionSnapshot {
        var nextID = 0
        var hitRegions: [HitRegion] = []
        var actions: [ActionID: ButtonAction] = [:]
        collectActions(
            nextID: &nextID,
            hitRegions: &hitRegions,
            actions: &actions
        )
        return InteractionSnapshot(
            hitTestMap: HitTestMap(regions: hitRegions),
            actions: actions
        )
    }

    package func makeIdentifiedHitRegions() -> [HitRegion] {
        var regions: [HitRegion] = []
        collectIdentifiedHitRegions(into: &regions)
        return regions
    }

    private func collectIdentifiedHitRegions(
        into regions: inout [HitRegion]
    ) {
        if case .button(let action) = kind,
           case .identified(let identifier) = action.storage {
            regions.append(HitRegion(bounds: frame, action: identifier))
        }
        for child in children {
            child.collectIdentifiedHitRegions(into: &regions)
        }
    }

    private func collectActions(
        nextID: inout Int,
        hitRegions: inout [HitRegion],
        actions: inout [ActionID: ButtonAction]
    ) {
        if case .button(let action) = kind {
            let actionID = ActionID(rawValue: nextID)
            nextID += 1
            hitRegions.append(HitRegion(bounds: frame, action: actionID))
            actions[actionID] = action
        }

        for child in children {
            child.collectActions(
                nextID: &nextID,
                hitRegions: &hitRegions,
                actions: &actions
            )
        }
    }

    private func measureGroup(
        proposal: ProposedSize,
        context: inout LayoutContext
    ) -> Size {
        var width = 0
        var height = 0
        for child in children {
            let childSize = child.measure(
                proposal: proposal,
                context: &context
            )
            width = max(width, childSize.width)
            height = max(height, childSize.height)
        }
        return Size(width: width, height: height)
    }

    private func measureVerticalStack(
        spacing: Int,
        proposal: ProposedSize,
        context: inout LayoutContext
    ) -> Size {
        guard !children.isEmpty else {
            return Size(width: 0, height: 0)
        }

        var width = 0
        var height = LayoutArithmetic.requireMultiply(
            spacing,
            children.count - 1,
            operation: "measuring vertical stack spacing"
        )
        for child in children {
            let childSize = child.measure(
                proposal: ProposedSize(width: proposal.width),
                context: &context
            )
            width = max(width, childSize.width)
            height = LayoutArithmetic.requireAdd(
                height,
                childSize.height,
                operation: "measuring vertical stack height"
            )
        }
        return Size(width: width, height: height)
    }

    private func measureHorizontalStack(
        spacing: Int,
        proposal: ProposedSize,
        context: inout LayoutContext
    ) -> Size {
        guard !children.isEmpty else {
            return Size(width: 0, height: 0)
        }

        var width = LayoutArithmetic.requireMultiply(
            spacing,
            children.count - 1,
            operation: "measuring horizontal stack spacing"
        )
        var height = 0
        for child in children {
            let childSize = child.measure(
                proposal: ProposedSize(height: proposal.height),
                context: &context
            )
            width = LayoutArithmetic.requireAdd(
                width,
                childSize.width,
                operation: "measuring horizontal stack width"
            )
            height = max(height, childSize.height)
        }
        return Size(width: width, height: height)
    }
}
