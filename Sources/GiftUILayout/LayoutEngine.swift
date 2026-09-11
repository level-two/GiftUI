import GiftUI
import GiftUISemanticCore
import GiftUITextResources

package struct LayoutEngine {
    private struct StackMeasure {
        var childCount: UInt16 = 0
        var mainExtent: GeometryScalar = 0
        var crossExtent: GeometryScalar = 0
    }

    private let limits: LayoutLimits
    private let validatedCounters: LayoutCounters
    package private(set) var failure: LayoutError?

    package init(limits: LayoutLimits, validatedCounters: LayoutCounters) {
        self.limits = limits
        self.validatedCounters = validatedCounters
    }

    package var finalCounters: LayoutCounters { validatedCounters }

    package mutating func measure<Semantic, Metrics, Workspace>(
        semantic: borrowing Semantic,
        metrics: borrowing Metrics,
        proposal: ProposedSize,
        workspace: inout Workspace
    ) -> LayoutMeasurement?
    where
        Semantic: SemanticLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        _ = metrics
        return measureOccurrence(
            semantic.rootIdentity,
            semantic: semantic,
            proposal: proposal,
            workspace: &workspace
        )
    }

    package mutating func place<Semantic, Metrics, Workspace>(
        semantic: borrowing Semantic,
        metrics: borrowing Metrics,
        rootBounds: Rect,
        workspace: inout Workspace
    ) -> Bool
    where
        Semantic: SemanticLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        _ = metrics
        return placeOccurrence(
            semantic.rootIdentity,
            semantic: semantic,
            origin: rootBounds.origin,
            inheritedClip: rootBounds,
            workspace: &workspace
        )
    }

    private mutating func measureOccurrence<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        proposal: ProposedSize,
        workspace: inout Workspace
    ) -> LayoutMeasurement?
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let modifierCount = semantic.modifierCount(of: identity) else {
            return fail(.invariantViolation)
        }
        if modifierCount > 0 {
            return measureModifier(
                identity,
                index: modifierCount - 1,
                semantic: semantic,
                proposal: proposal,
                workspace: &workspace
            )
        }
        return measureContent(
            identity,
            semantic: semantic,
            proposal: proposal,
            workspace: &workspace
        )
    }

    private mutating func measureModifier<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        index: UInt16,
        semantic: borrowing Semantic,
        proposal: ProposedSize,
        workspace: inout Workspace
    ) -> LayoutMeasurement?
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let modifier = semantic.modifier(of: identity, at: index),
            let scopeIdentity = semantic.modifierScope(of: identity, at: index)
        else { return fail(.invariantViolation) }
        guard modifier == .passthrough else { return fail(.invariantViolation) }
        let childMeasurement: LayoutMeasurement?
        if index > 0 {
            childMeasurement = measureModifier(
                identity,
                index: index - 1,
                semantic: semantic,
                proposal: proposal,
                workspace: &workspace
            )
        } else {
            childMeasurement = measureContent(
                identity,
                semantic: semantic,
                proposal: proposal,
                workspace: &workspace
            )
        }
        guard let measurement = childMeasurement,
            workspace.storeMeasurement(measurement, for: scopeIdentity)
        else { return fail(.invariantViolation) }
        return measurement
    }

    private mutating func measureContent<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        proposal: ProposedSize,
        workspace: inout Workspace
    ) -> LayoutMeasurement?
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let primitive = semantic.primitive(at: identity) else {
            return measureOnlyFlattenedChild(
                identity,
                semantic: semantic,
                proposal: proposal,
                workspace: &workspace
            )
        }
        let measurement: LayoutMeasurement?
        switch primitive {
        case .proxy:
            measurement = measureOnlyFlattenedChild(
                identity,
                semantic: semantic,
                proposal: proposal,
                workspace: &workspace
            )
        case .vStack:
            measurement = measureStack(
                identity,
                semantic: semantic,
                proposal: proposal,
                vertical: true,
                workspace: &workspace
            )
        case .hStack:
            measurement = measureStack(
                identity,
                semantic: semantic,
                proposal: proposal,
                vertical: false,
                workspace: &workspace
            )
        case .spacer:
            measurement = LayoutGeometry.cap(
                ideal: LayoutGeometry.zeroSize,
                to: proposal
            )
        case .zStack, .text:
            measurement = fail(.invariantViolation)
        }
        guard let measurement,
            workspace.storeMeasurement(measurement, for: identity)
        else { return fail(.invariantViolation) }
        return measurement
    }

    private mutating func measureOnlyFlattenedChild<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        proposal: ProposedSize,
        workspace: inout Workspace
    ) -> LayoutMeasurement?
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        var found: LayoutMeasurement?
        var count: UInt16 = 0
        var result = StackMeasure()
        guard
            measureFlattenedChildren(
                of: identity,
                semantic: semantic,
                proposal: proposal,
                vertical: true,
                workspace: &workspace,
                result: &result,
                each: { measurement in
                    count += 1
                    found = measurement
                    return true
                }
            ), count == 1
        else { return fail(.invariantViolation) }
        return found
    }

    private mutating func measureStack<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        proposal: ProposedSize,
        vertical: Bool,
        workspace: inout Workspace
    ) -> LayoutMeasurement?
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        let childProposal = ProposedSize(
            width: vertical ? proposal.width : nil,
            height: vertical ? nil : proposal.height
        )!
        var result = StackMeasure()
        guard
            measureFlattenedChildren(
                of: identity,
                semantic: semantic,
                proposal: childProposal,
                vertical: vertical,
                workspace: &workspace,
                result: &result,
                each: { _ in true }
            )
        else { return nil }
        let spacing: GeometryScalar
        switch semantic.primitive(at: identity) {
        case .vStack(_, let value), .hStack(_, let value):
            spacing = value
        default:
            return fail(.invariantViolation)
        }
        guard
            let gapTotal = LayoutGeometry.spacingTotal(
                spacing: spacing,
                childCount: result.childCount
            ), let mainExtent = GeometryArithmetic.add(result.mainExtent, gapTotal)
        else { return fail(.arithmeticOverflow) }
        let ideal =
            vertical
            ? Size(width: result.crossExtent, height: mainExtent)!
            : Size(width: mainExtent, height: result.crossExtent)!
        return LayoutGeometry.cap(ideal: ideal, to: proposal)
    }

    private mutating func measureFlattenedChildren<Semantic, Workspace>(
        of identity: Semantic.Identity,
        semantic: borrowing Semantic,
        proposal: ProposedSize,
        vertical: Bool,
        workspace: inout Workspace,
        result: inout StackMeasure,
        each: (LayoutMeasurement) -> Bool
    ) -> Bool
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let childCount = semantic.childCount(of: identity) else {
            fail(.invariantViolation)
            return false
        }
        var index: UInt16 = 0
        while index < childCount {
            guard let child = semantic.child(of: identity, at: index),
                measureFlattenedOccurrence(
                    child,
                    semantic: semantic,
                    proposal: proposal,
                    vertical: vertical,
                    workspace: &workspace,
                    result: &result,
                    each: each
                )
            else { return false }
            index += 1
        }
        return true
    }

    private mutating func measureFlattenedOccurrence<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        proposal: ProposedSize,
        vertical: Bool,
        workspace: inout Workspace,
        result: inout StackMeasure,
        each: (LayoutMeasurement) -> Bool
    ) -> Bool
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let modifierCount = semantic.modifierCount(of: identity) else {
            fail(.invariantViolation)
            return false
        }
        if semantic.primitive(at: identity) != nil || modifierCount > 0 {
            guard
                let measurement = measureOccurrence(
                    identity,
                    semantic: semantic,
                    proposal: proposal,
                    workspace: &workspace
                ), each(measurement)
            else { return false }
            guard let nextCount = increment(result.childCount),
                let nextMain = GeometryArithmetic.add(
                    result.mainExtent,
                    vertical
                        ? measurement.resolvedSize.height
                        : measurement.resolvedSize.width
                )
            else {
                fail(.arithmeticOverflow)
                return false
            }
            result.childCount = nextCount
            result.mainExtent = nextMain
            let cross =
                vertical
                ? measurement.resolvedSize.width
                : measurement.resolvedSize.height
            result.crossExtent = max(result.crossExtent, cross)
            return true
        }
        return measureFlattenedChildren(
            of: identity,
            semantic: semantic,
            proposal: proposal,
            vertical: vertical,
            workspace: &workspace,
            result: &result,
            each: each
        )
    }

    private mutating func placeOccurrence<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        origin: Point,
        inheritedClip: Rect,
        workspace: inout Workspace
    ) -> Bool
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let modifierCount = semantic.modifierCount(of: identity) else {
            fail(.invariantViolation)
            return false
        }
        if modifierCount > 0 {
            return placeModifier(
                identity,
                index: modifierCount - 1,
                semantic: semantic,
                origin: origin,
                inheritedClip: inheritedClip,
                workspace: &workspace
            )
        }
        return placeContent(
            identity,
            semantic: semantic,
            origin: origin,
            inheritedClip: inheritedClip,
            workspace: &workspace
        )
    }

    private mutating func placeModifier<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        index: UInt16,
        semantic: borrowing Semantic,
        origin: Point,
        inheritedClip: Rect,
        workspace: inout Workspace
    ) -> Bool
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let modifier = semantic.modifier(of: identity, at: index),
            modifier == .passthrough,
            let scopeIdentity = semantic.modifierScope(of: identity, at: index),
            let measurement = workspace.measurement(for: scopeIdentity),
            let bounds = Rect(origin: origin, size: measurement.resolvedSize),
            workspace.storePlacement(
                LayoutPlacement(bounds: bounds, clip: inheritedClip),
                for: scopeIdentity
            )
        else {
            fail(.invariantViolation)
            return false
        }
        if index > 0 {
            return placeModifier(
                identity,
                index: index - 1,
                semantic: semantic,
                origin: origin,
                inheritedClip: inheritedClip,
                workspace: &workspace
            )
        }
        return placeContent(
            identity,
            semantic: semantic,
            origin: origin,
            inheritedClip: inheritedClip,
            workspace: &workspace
        )
    }

    private mutating func placeContent<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        origin: Point,
        inheritedClip: Rect,
        workspace: inout Workspace
    ) -> Bool
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let primitive = semantic.primitive(at: identity) else {
            return placeOnlyFlattenedChild(
                identity,
                semantic: semantic,
                origin: origin,
                inheritedClip: inheritedClip,
                workspace: &workspace
            )
        }
        guard let measurement = workspace.measurement(for: identity),
            let bounds = Rect(origin: origin, size: measurement.resolvedSize),
            workspace.storePlacement(
                LayoutPlacement(bounds: bounds, clip: inheritedClip),
                for: identity
            )
        else {
            fail(.invariantViolation)
            return false
        }
        switch primitive {
        case .proxy:
            return placeOnlyFlattenedChild(
                identity,
                semantic: semantic,
                origin: origin,
                inheritedClip: inheritedClip,
                workspace: &workspace
            )
        case .vStack(let alignment, let spacing):
            return placeStack(
                identity,
                semantic: semantic,
                bounds: bounds,
                inheritedClip: inheritedClip,
                vertical: true,
                horizontalAlignment: alignment,
                verticalAlignment: .top,
                spacing: spacing,
                workspace: &workspace
            )
        case .hStack(let alignment, let spacing):
            return placeStack(
                identity,
                semantic: semantic,
                bounds: bounds,
                inheritedClip: inheritedClip,
                vertical: false,
                horizontalAlignment: .leading,
                verticalAlignment: alignment,
                spacing: spacing,
                workspace: &workspace
            )
        case .spacer:
            return true
        case .zStack, .text:
            fail(.invariantViolation)
            return false
        }
    }

    private mutating func placeOnlyFlattenedChild<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        origin: Point,
        inheritedClip: Rect,
        workspace: inout Workspace
    ) -> Bool
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard
            let count = placeFlattenedChildrenAtOrigin(
                of: identity,
                semantic: semantic,
                origin: origin,
                inheritedClip: inheritedClip,
                workspace: &workspace,
            ), count == 1
        else {
            fail(.invariantViolation)
            return false
        }
        return true
    }

    private mutating func placeStack<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        bounds: Rect,
        inheritedClip: Rect,
        vertical: Bool,
        horizontalAlignment: HorizontalAlignment,
        verticalAlignment: VerticalAlignment,
        spacing: GeometryScalar,
        workspace: inout Workspace
    ) -> Bool
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        var cursor: GeometryScalar = vertical ? bounds.minY : bounds.minX
        guard
            let childCount = flattenedChildCount(
                of: identity,
                semantic: semantic
            )
        else { return false }
        var placedCount: UInt16 = 0
        return placeStackChildren(
            of: identity,
            semantic: semantic,
            bounds: bounds,
            inheritedClip: inheritedClip,
            vertical: vertical,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment,
            spacing: spacing,
            totalChildCount: childCount,
            placedCount: &placedCount,
            cursor: &cursor,
            workspace: &workspace,
        )
    }

    private mutating func placeFlattenedChildrenAtOrigin<Semantic, Workspace>(
        of identity: Semantic.Identity,
        semantic: borrowing Semantic,
        origin: Point,
        inheritedClip: Rect,
        workspace: inout Workspace
    ) -> UInt16?
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let childCount = semantic.childCount(of: identity) else {
            return fail(.invariantViolation)
        }
        var flattenedCount: UInt16 = 0
        var index: UInt16 = 0
        while index < childCount {
            guard let child = semantic.child(of: identity, at: index),
                let modifierCount = semantic.modifierCount(of: child)
            else { return fail(.invariantViolation) }
            let addedCount: UInt16
            if semantic.primitive(at: child) != nil || modifierCount > 0 {
                guard
                    placeOccurrence(
                        child,
                        semantic: semantic,
                        origin: origin,
                        inheritedClip: inheritedClip,
                        workspace: &workspace
                    )
                else { return nil }
                addedCount = 1
            } else {
                guard
                    let nestedCount = placeFlattenedChildrenAtOrigin(
                        of: child,
                        semantic: semantic,
                        origin: origin,
                        inheritedClip: inheritedClip,
                        workspace: &workspace
                    )
                else { return nil }
                addedCount = nestedCount
            }
            let total = flattenedCount.addingReportingOverflow(addedCount)
            guard !total.overflow else { return fail(.capacityExhausted) }
            flattenedCount = total.partialValue
            index += 1
        }
        return flattenedCount
    }

    private mutating func placeStackChildren<Semantic, Workspace>(
        of identity: Semantic.Identity,
        semantic: borrowing Semantic,
        bounds: Rect,
        inheritedClip: Rect,
        vertical: Bool,
        horizontalAlignment: HorizontalAlignment,
        verticalAlignment: VerticalAlignment,
        spacing: GeometryScalar,
        totalChildCount: UInt16,
        placedCount: inout UInt16,
        cursor: inout GeometryScalar,
        workspace: inout Workspace,
    ) -> Bool
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let childCount = semantic.childCount(of: identity) else {
            fail(.invariantViolation)
            return false
        }
        var index: UInt16 = 0
        while index < childCount {
            guard let child = semantic.child(of: identity, at: index) else {
                fail(.invariantViolation)
                return false
            }
            guard let modifierCount = semantic.modifierCount(of: child) else {
                fail(.invariantViolation)
                return false
            }
            if semantic.primitive(at: child) != nil || modifierCount > 0 {
                guard let measurement = workspace.measurement(for: child) else {
                    return fail(.invariantViolation)
                }
                let childSize = measurement.resolvedSize
                let x: GeometryScalar
                let y: GeometryScalar
                if vertical {
                    guard
                        let offset = LayoutGeometry.offset(
                            container: bounds.size.width,
                            child: childSize.width,
                            alignment: horizontalAlignment
                        ), let resolvedX = GeometryArithmetic.add(bounds.minX, offset)
                    else { return fail(.arithmeticOverflow) }
                    x = resolvedX
                    y = cursor
                } else {
                    guard
                        let offset = LayoutGeometry.offset(
                            container: bounds.size.height,
                            child: childSize.height,
                            alignment: verticalAlignment
                        ), let resolvedY = GeometryArithmetic.add(bounds.minY, offset)
                    else { return fail(.arithmeticOverflow) }
                    x = cursor
                    y = resolvedY
                }
                guard
                    placeOccurrence(
                        child,
                        semantic: semantic,
                        origin: Point(x: x, y: y),
                        inheritedClip: inheritedClip,
                        workspace: &workspace
                    )
                else { return false }
                let extent = vertical ? childSize.height : childSize.width
                guard let afterChild = GeometryArithmetic.add(cursor, extent),
                    let nextPlacedCount = increment(placedCount)
                else { return fail(.arithmeticOverflow) }
                placedCount = nextPlacedCount
                if placedCount < totalChildCount {
                    guard let next = GeometryArithmetic.add(afterChild, spacing)
                    else { return fail(.arithmeticOverflow) }
                    cursor = next
                } else {
                    cursor = afterChild
                }
            } else if !placeStackChildren(
                of: child,
                semantic: semantic,
                bounds: bounds,
                inheritedClip: inheritedClip,
                vertical: vertical,
                horizontalAlignment: horizontalAlignment,
                verticalAlignment: verticalAlignment,
                spacing: spacing,
                totalChildCount: totalChildCount,
                placedCount: &placedCount,
                cursor: &cursor,
                workspace: &workspace,
            ) {
                return false
            }
            index += 1
        }
        return true
    }

    private mutating func flattenedChildCount<Semantic: SemanticLayoutView>(
        of identity: Semantic.Identity,
        semantic: borrowing Semantic
    ) -> UInt16? {
        guard let childCount = semantic.childCount(of: identity) else {
            return fail(.invariantViolation)
        }
        var total: UInt16 = 0
        var index: UInt16 = 0
        while index < childCount {
            guard let child = semantic.child(of: identity, at: index),
                let modifierCount = semantic.modifierCount(of: child)
            else { return fail(.invariantViolation) }
            let contribution: UInt16
            if semantic.primitive(at: child) != nil || modifierCount > 0 {
                contribution = 1
            } else {
                guard let nested = flattenedChildCount(of: child, semantic: semantic)
                else { return nil }
                contribution = nested
            }
            let result = total.addingReportingOverflow(contribution)
            guard !result.overflow else { return fail(.capacityExhausted) }
            total = result.partialValue
            index += 1
        }
        return total
    }

    @discardableResult
    private mutating func fail<T>(_ error: LayoutError) -> T? {
        if failure == nil { failure = error }
        return nil
    }

    @discardableResult
    private mutating func fail(_ error: LayoutError) -> Bool {
        if failure == nil { failure = error }
        return false
    }

    private func increment(_ value: UInt16) -> UInt16? {
        let result = value.addingReportingOverflow(1)
        return result.overflow ? nil : result.partialValue
    }
}
