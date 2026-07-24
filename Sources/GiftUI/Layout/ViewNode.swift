package enum ViewNodeKind {
    case group
    case text(String)
    case button(() -> Void)
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
                width: content.unicodeScalars.count * Self.glyphSize.width,
                height: Self.glyphSize.height
            )
        case .button:
            let labelProposal = ProposedSize(
                width: proposal.width.map {
                    max(0, $0 - Self.buttonPadding.width * 2)
                },
                height: proposal.height.map {
                    max(0, $0 - Self.buttonPadding.height * 2)
                }
            )
            let labelSize = children.first?.measure(
                proposal: labelProposal,
                context: &context
            ) ?? Size(width: 0, height: 0)
            size = Size(
                width: labelSize.width + Self.buttonPadding.width * 2,
                height: labelSize.height + Self.buttonPadding.height * 2
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
                        x: bounds.origin.x + Self.buttonPadding.width,
                        y: bounds.origin.y + Self.buttonPadding.height
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
                            x: bounds.origin.x
                                + (bounds.size.width - child.measuredSize.width) / 2,
                            y: y
                        ),
                        size: child.measuredSize
                    ),
                    context: &context
                )
                y += child.measuredSize.height + spacing
            }
        case .hStack(let spacing):
            var x = bounds.origin.x
            for child in children {
                child.place(
                    in: Rect(
                        origin: Point(
                            x: x,
                            y: bounds.origin.y
                                + (bounds.size.height - child.measuredSize.height) / 2
                        ),
                        size: child.measuredSize
                    ),
                    context: &context
                )
                x += child.measuredSize.width + spacing
            }
        }
    }

    package func layoutNode() -> LayoutNode {
        LayoutNode(
            frame: frame,
            children: children.map { $0.layoutNode() }
        )
    }

    package func makeDisplayList() -> DisplayList {
        var displayList = DisplayList()
        appendRenderOperations(to: &displayList)
        return displayList
    }

    private func appendRenderOperations(to displayList: inout DisplayList) {
        switch kind {
        case .group, .vStack, .hStack:
            for child in children {
                child.appendRenderOperations(to: &displayList)
            }
        case .text(let content):
            displayList.append(
                .text(
                    TextRun(content, color: .white),
                    at: frame.origin
                )
            )
        case .button:
            displayList.append(
                .fillRect(
                    frame,
                    Color(red: 62, green: 68, blue: 82)
                )
            )
            displayList.append(
                .strokeRect(
                    frame,
                    Color(red: 116, green: 130, blue: 160),
                    lineWidth: 1
                )
            )
            for child in children {
                child.appendRenderOperations(to: &displayList)
            }
        }
    }

    package func collectActions(
        nextID: inout Int,
        hitRegions: inout [HitRegion],
        actions: inout [ActionID: () -> Void]
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
        var height = spacing * (children.count - 1)
        for child in children {
            let childSize = child.measure(
                proposal: ProposedSize(width: proposal.width),
                context: &context
            )
            width = max(width, childSize.width)
            height += childSize.height
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

        var width = spacing * (children.count - 1)
        var height = 0
        for child in children {
            let childSize = child.measure(
                proposal: ProposedSize(height: proposal.height),
                context: &context
            )
            width += childSize.width
            height = max(height, childSize.height)
        }
        return Size(width: width, height: height)
    }
}
