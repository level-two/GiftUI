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
    package func measure() -> Size {
        let size: Size
        switch kind {
        case .group:
            size = measureGroup()
        case .text(let content):
            size = Size(
                width: content.unicodeScalars.count * Self.glyphSize.width,
                height: Self.glyphSize.height
            )
        case .button:
            let labelSize = children.first?.measure() ?? Size(width: 0, height: 0)
            size = Size(
                width: labelSize.width + Self.buttonPadding.width * 2,
                height: labelSize.height + Self.buttonPadding.height * 2
            )
        case .vStack(let spacing):
            size = measureVerticalStack(spacing: spacing)
        case .hStack(let spacing):
            size = measureHorizontalStack(spacing: spacing)
        }
        measuredSize = size
        return size
    }

    package func place(at origin: Point) {
        frame = Rect(origin: origin, size: measuredSize)

        switch kind {
        case .group:
            for child in children {
                child.place(at: origin)
            }
        case .text:
            break
        case .button:
            guard let label = children.first else { return }
            label.place(
                at: Point(
                    x: origin.x + Self.buttonPadding.width,
                    y: origin.y + Self.buttonPadding.height
                )
            )
        case .vStack(let spacing):
            var y = origin.y
            for child in children {
                child.place(
                    at: Point(
                        x: origin.x + (measuredSize.width - child.measuredSize.width) / 2,
                        y: y
                    )
                )
                y += child.measuredSize.height + spacing
            }
        case .hStack(let spacing):
            var x = origin.x
            for child in children {
                child.place(
                    at: Point(
                        x: x,
                        y: origin.y + (measuredSize.height - child.measuredSize.height) / 2
                    )
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

    package func render<Backend: RenderBackend>(
        into backend: inout Backend
    ) {
        switch kind {
        case .group, .vStack, .hStack:
            for child in children {
                child.render(into: &backend)
            }
        case .text(let content):
            backend.drawText(
                TextRun(content, color: .white),
                at: frame.origin
            )
        case .button:
            backend.fill(
                frame,
                color: Color(red: 62, green: 68, blue: 82)
            )
            backend.stroke(
                frame,
                color: Color(red: 116, green: 130, blue: 160),
                lineWidth: 1
            )
            for child in children {
                child.render(into: &backend)
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

    private func measureGroup() -> Size {
        var width = 0
        var height = 0
        for child in children {
            let childSize = child.measure()
            width = max(width, childSize.width)
            height = max(height, childSize.height)
        }
        return Size(width: width, height: height)
    }

    private func measureVerticalStack(spacing: Int) -> Size {
        guard !children.isEmpty else {
            return Size(width: 0, height: 0)
        }

        var width = 0
        var height = spacing * (children.count - 1)
        for child in children {
            let childSize = child.measure()
            width = max(width, childSize.width)
            height += childSize.height
        }
        return Size(width: width, height: height)
    }

    private func measureHorizontalStack(spacing: Int) -> Size {
        guard !children.isEmpty else {
            return Size(width: 0, height: 0)
        }

        var width = spacing * (children.count - 1)
        var height = 0
        for child in children {
            let childSize = child.measure()
            width += childSize.width
            height = max(height, childSize.height)
        }
        return Size(width: width, height: height)
    }
}
