import GiftUI
import GiftUISemanticCore
import GiftUITextResources

package struct LayoutEngine {
    private struct StackMeasure {
        var childCount: UInt16 = 0
        var flexibleSpacerCount: UInt16 = 0
        var mainExtent: GeometryScalar = 0
        var crossExtent: GeometryScalar = 0
    }

    private let limits: LayoutLimits
    private var counters: LayoutCounters
    package private(set) var failure: LayoutError?

    package init(limits: LayoutLimits, validatedCounters: LayoutCounters) {
        self.limits = limits
        counters = validatedCounters
        counters.resetTextCounts()
    }

    package var finalCounters: LayoutCounters { counters }

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
            metrics: metrics,
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

    private mutating func measureOccurrence<Semantic, Metrics, Workspace>(
        _ identity: Semantic.Identity,
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
        guard let modifierCount = semantic.modifierCount(of: identity) else {
            return fail(.invariantViolation)
        }
        if modifierCount > 0 {
            return measureModifier(
                identity,
                index: modifierCount - 1,
                semantic: semantic,
                metrics: metrics,
                proposal: proposal,
                workspace: &workspace
            )
        }
        return measureContent(
            identity,
            semantic: semantic,
            metrics: metrics,
            proposal: proposal,
            workspace: &workspace
        )
    }

    private mutating func measureModifier<Semantic, Metrics, Workspace>(
        _ identity: Semantic.Identity,
        index: UInt16,
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
        guard let modifier = semantic.modifier(of: identity, at: index),
            let scopeIdentity = semantic.modifierScope(of: identity, at: index)
        else { return fail(.invariantViolation) }
        let childProposal: ProposedSize
        switch modifier {
        case .passthrough:
            childProposal = proposal
        case .padding, .paddingInsets:
            guard let insets = paddingInsets(for: modifier),
                let insetProposal = LayoutGeometry.insetProposal(
                    proposal,
                    horizontal: insets.horizontal,
                    vertical: insets.vertical
                )
            else { return fail(.arithmeticOverflow) }
            childProposal = insetProposal
        case .fixedFrame, .flexibleFrame:
            guard
                let frameProposal = frameChildProposal(
                    modifier: modifier,
                    parent: proposal
                )
            else { return fail(.arithmeticOverflow) }
            childProposal = frameProposal
        }
        let childMeasurement: LayoutMeasurement?
        if index > 0 {
            childMeasurement = measureModifier(
                identity,
                index: index - 1,
                semantic: semantic,
                metrics: metrics,
                proposal: childProposal,
                workspace: &workspace
            )
        } else {
            childMeasurement = measureContent(
                identity,
                semantic: semantic,
                metrics: metrics,
                proposal: childProposal,
                workspace: &workspace
            )
        }
        guard let childMeasurement else { return nil }
        let measurement: LayoutMeasurement
        switch modifier {
        case .passthrough:
            measurement = childMeasurement
        case .padding, .paddingInsets:
            guard let insets = paddingInsets(for: modifier),
                let ideal = LayoutGeometry.adding(
                    width: insets.horizontal,
                    height: insets.vertical,
                    to: childMeasurement.idealSize
                )
            else { return fail(.arithmeticOverflow) }
            measurement = LayoutGeometry.cap(ideal: ideal, to: proposal)
        case .fixedFrame, .flexibleFrame:
            measurement = frameMeasurement(
                modifier: modifier,
                child: childMeasurement,
                parent: proposal
            )
        }
        guard workspace.storeMeasurement(measurement, for: scopeIdentity)
        else { return fail(.invariantViolation) }
        return measurement
    }

    private mutating func measureText<Semantic, Metrics, Workspace>(
        _ identity: Semantic.Identity,
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
        guard metrics.descriptor.instanceCount == 1,
            let instance = metrics.instance(at: 0),
            metrics.instance(at: 1) == nil,
            let scalarCount = semantic.textScalarCount(of: identity)
        else { return fail(.invariantViolation) }
        guard
            let lineHeight = GeometryArithmetic.add(
                instance.lineMetrics.ascent,
                instance.lineMetrics.descent
            ),
            let baselineProgression = GeometryArithmetic.add(
                lineHeight,
                instance.lineMetrics.lineGap
            )
        else { return fail(.arithmeticOverflow) }
        guard lineHeight >= 0, baselineProgression >= 0 else {
            return fail(.invariantViolation)
        }

        if let error = counters.reserveTextLine() { return fail(error) }
        var localLineIndex: UInt16 = 0
        var localGlyphIndex: UInt16 = 0
        var currentAdvance: GeometryScalar = 0
        var currentHasGlyph = false
        var maximumLineWidth: GeometryScalar = 0
        var previousWasCarriageReturn = false
        var scalarIndex: UInt16 = 0

        while scalarIndex < scalarCount {
            if let error = counters.reserveTextScalar() { return fail(error) }
            guard let scalar = semantic.textScalar(of: identity, at: scalarIndex)
            else { return fail(.invariantViolation) }
            if scalar == 0x0d {
                guard
                    finalizeTextLine(
                        identity: identity,
                        lineIndex: localLineIndex,
                        advance: currentAdvance,
                        proposalWidth: proposal.width,
                        ascent: instance.lineMetrics.ascent,
                        lineHeight: lineHeight,
                        baselineProgression: baselineProgression,
                        maximumLineWidth: &maximumLineWidth,
                        workspace: &workspace
                    ), let nextLine = increment(localLineIndex)
                else { return nil }
                if let error = counters.reserveTextLine() { return fail(error) }
                localLineIndex = nextLine
                currentAdvance = 0
                currentHasGlyph = false
                previousWasCarriageReturn = true
            } else if scalar == 0x0a {
                if !previousWasCarriageReturn {
                    guard
                        finalizeTextLine(
                            identity: identity,
                            lineIndex: localLineIndex,
                            advance: currentAdvance,
                            proposalWidth: proposal.width,
                            ascent: instance.lineMetrics.ascent,
                            lineHeight: lineHeight,
                            baselineProgression: baselineProgression,
                            maximumLineWidth: &maximumLineWidth,
                            workspace: &workspace
                        ), let nextLine = increment(localLineIndex)
                    else { return nil }
                    if let error = counters.reserveTextLine() { return fail(error) }
                    localLineIndex = nextLine
                    currentAdvance = 0
                    currentHasGlyph = false
                }
                previousWasCarriageReturn = false
            } else {
                previousWasCarriageReturn = false
                if let error = counters.reservePositionedGlyph() {
                    return fail(error)
                }
                guard let mapping = metrics.mapScalar(scalar, in: instance.id) else {
                    return fail(.invariantViolation)
                }
                let glyph: GlyphID
                switch mapping {
                case .exact(let value), .replacement(let value):
                    glyph = value
                }
                guard
                    let glyphMetrics = metrics.metrics(
                        for: glyph,
                        in: instance.id
                    ), glyphMetrics.advanceX >= 0
                else { return fail(.invariantViolation) }
                guard
                    let prospectiveAdvance = GeometryArithmetic.add(
                        currentAdvance,
                        glyphMetrics.advanceX
                    )
                else { return fail(.arithmeticOverflow) }
                let wraps =
                    currentHasGlyph
                    && proposal.width.map {
                        $0 == 0 || prospectiveAdvance > $0
                    } == true
                if wraps {
                    guard
                        finalizeTextLine(
                            identity: identity,
                            lineIndex: localLineIndex,
                            advance: currentAdvance,
                            proposalWidth: proposal.width,
                            ascent: instance.lineMetrics.ascent,
                            lineHeight: lineHeight,
                            baselineProgression: baselineProgression,
                            maximumLineWidth: &maximumLineWidth,
                            workspace: &workspace
                        ), let nextLine = increment(localLineIndex)
                    else { return nil }
                    if let error = counters.reserveTextLine() { return fail(error) }
                    localLineIndex = nextLine
                    currentAdvance = 0
                }
                guard
                    let baselineY = textBaselineY(
                        lineIndex: localLineIndex,
                        ascent: instance.lineMetrics.ascent,
                        progression: baselineProgression
                    ),
                    workspace.appendPositionedGlyph(
                        LayoutPositionedGlyph(
                            identity: identity,
                            lineIndex: localLineIndex,
                            glyphIndex: localGlyphIndex,
                            instance: instance.id,
                            glyph: glyph,
                            baseline: Point(x: currentAdvance, y: baselineY),
                            clip: zeroRect
                        )
                    ), let nextGlyph = increment(localGlyphIndex)
                else { return fail(failure ?? .invariantViolation) }
                guard
                    let nextAdvance = GeometryArithmetic.add(
                        currentAdvance,
                        glyphMetrics.advanceX
                    )
                else { return fail(.arithmeticOverflow) }
                localGlyphIndex = nextGlyph
                currentAdvance = nextAdvance
                currentHasGlyph = true
            }
            scalarIndex += 1
        }
        guard
            finalizeTextLine(
                identity: identity,
                lineIndex: localLineIndex,
                advance: currentAdvance,
                proposalWidth: proposal.width,
                ascent: instance.lineMetrics.ascent,
                lineHeight: lineHeight,
                baselineProgression: baselineProgression,
                maximumLineWidth: &maximumLineWidth,
                workspace: &workspace
            )
        else { return nil }
        let localLineCount = localLineIndex + 1
        guard
            let additionalHeight = GeometryArithmetic.multiply(
                GeometryScalar(localLineCount - 1),
                baselineProgression
            ), let idealHeight = GeometryArithmetic.add(lineHeight, additionalHeight)
        else { return fail(.arithmeticOverflow) }
        return LayoutGeometry.cap(
            ideal: Size(width: maximumLineWidth, height: idealHeight)!,
            to: proposal
        )
    }

    private mutating func finalizeTextLine<Identity, Workspace>(
        identity: Identity,
        lineIndex: UInt16,
        advance: GeometryScalar,
        proposalWidth: GeometryScalar?,
        ascent: GeometryScalar,
        lineHeight: GeometryScalar,
        baselineProgression: GeometryScalar,
        maximumLineWidth: inout GeometryScalar,
        workspace: inout Workspace
    ) -> Bool
    where Workspace: LayoutWorkspace, Workspace.Identity == Identity {
        guard
            let baselineY = textBaselineY(
                lineIndex: lineIndex,
                ascent: ascent,
                progression: baselineProgression
            ), let lineY = GeometryArithmetic.subtract(baselineY, ascent)
        else { return fail(.arithmeticOverflow) }
        let width = proposalWidth.map { min(advance, $0) } ?? advance
        maximumLineWidth = max(maximumLineWidth, width)
        guard
            let bounds = Rect(
                origin: Point(x: 0, y: lineY),
                size: Size(width: width, height: lineHeight)!
            ),
            workspace.appendTextLine(
                LayoutTextLine(
                    identity: identity,
                    lineIndex: lineIndex,
                    bounds: bounds,
                    baseline: Point(x: 0, y: baselineY),
                    clip: zeroRect
                )
            )
        else { return fail(.invariantViolation) }
        return true
    }

    private mutating func textBaselineY(
        lineIndex: UInt16,
        ascent: GeometryScalar,
        progression: GeometryScalar
    ) -> GeometryScalar? {
        guard
            let offset = GeometryArithmetic.multiply(
                GeometryScalar(lineIndex),
                progression
            ), let baseline = GeometryArithmetic.add(ascent, offset)
        else { return fail(.arithmeticOverflow) }
        return baseline
    }

    private var zeroRect: Rect {
        Rect(origin: Point(x: 0, y: 0), size: LayoutGeometry.zeroSize)!
    }

    private mutating func measureContent<Semantic, Metrics, Workspace>(
        _ identity: Semantic.Identity,
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
        guard let primitive = semantic.primitive(at: identity) else {
            return measureOnlyFlattenedChild(
                identity,
                semantic: semantic,
                metrics: metrics,
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
                metrics: metrics,
                proposal: proposal,
                workspace: &workspace
            )
        case .vStack:
            measurement = measureStack(
                identity,
                semantic: semantic,
                metrics: metrics,
                proposal: proposal,
                vertical: true,
                workspace: &workspace
            )
        case .hStack:
            measurement = measureStack(
                identity,
                semantic: semantic,
                metrics: metrics,
                proposal: proposal,
                vertical: false,
                workspace: &workspace
            )
        case .spacer:
            measurement = LayoutGeometry.cap(
                ideal: LayoutGeometry.zeroSize,
                to: proposal
            )
        case .zStack:
            measurement = measureZStack(
                identity,
                semantic: semantic,
                metrics: metrics,
                proposal: proposal,
                workspace: &workspace
            )
        case .text:
            measurement = measureText(
                identity,
                semantic: semantic,
                metrics: metrics,
                proposal: proposal,
                workspace: &workspace
            )
        }
        guard let measurement,
            workspace.storeMeasurement(measurement, for: identity)
        else { return fail(.invariantViolation) }
        return measurement
    }

    private mutating func measureZStack<Semantic, Metrics, Workspace>(
        _ identity: Semantic.Identity,
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
        var maximumWidth: GeometryScalar = 0
        var maximumHeight: GeometryScalar = 0
        var result = StackMeasure()
        guard
            measureFlattenedChildren(
                of: identity,
                semantic: semantic,
                metrics: metrics,
                proposal: proposal,
                vertical: true,
                recognizesFlexibleSpacers: false,
                workspace: &workspace,
                result: &result,
                each: { measurement in
                    maximumWidth = max(maximumWidth, measurement.idealSize.width)
                    maximumHeight = max(maximumHeight, measurement.idealSize.height)
                    return true
                }
            )
        else { return nil }
        return LayoutGeometry.cap(
            ideal: Size(width: maximumWidth, height: maximumHeight)!,
            to: proposal
        )
    }

    private mutating func measureOnlyFlattenedChild<Semantic, Metrics, Workspace>(
        _ identity: Semantic.Identity,
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
        var found: LayoutMeasurement?
        var count: UInt16 = 0
        var result = StackMeasure()
        guard
            measureFlattenedChildren(
                of: identity,
                semantic: semantic,
                metrics: metrics,
                proposal: proposal,
                vertical: true,
                recognizesFlexibleSpacers: false,
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

    private mutating func measureStack<Semantic, Metrics, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        metrics: borrowing Metrics,
        proposal: ProposedSize,
        vertical: Bool,
        workspace: inout Workspace
    ) -> LayoutMeasurement?
    where
        Semantic: SemanticLayoutView,
        Metrics: CanonicalTextMetricsView,
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
                metrics: metrics,
                proposal: childProposal,
                vertical: vertical,
                recognizesFlexibleSpacers: true,
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
        let proposedMain = vertical ? proposal.height : proposal.width
        let idealMain: GeometryScalar
        let extra: GeometryScalar
        if result.flexibleSpacerCount > 0,
            let proposedMain,
            proposedMain > mainExtent
        {
            idealMain = proposedMain
            guard
                let difference = GeometryArithmetic.subtract(
                    proposedMain,
                    mainExtent
                )
            else { return fail(.arithmeticOverflow) }
            extra = difference
        } else {
            idealMain = mainExtent
            extra = 0
        }
        let ideal =
            vertical
            ? Size(width: result.crossExtent, height: idealMain)!
            : Size(width: idealMain, height: result.crossExtent)!
        let measurement = LayoutGeometry.cap(ideal: ideal, to: proposal)
        var assignedCount: UInt16 = 0
        guard
            assignFlexibleSpacers(
                of: identity,
                semantic: semantic,
                vertical: vertical,
                extra: extra,
                spacerCount: result.flexibleSpacerCount,
                crossExtent: vertical
                    ? measurement.resolvedSize.width
                    : measurement.resolvedSize.height,
                assignedCount: &assignedCount,
                workspace: &workspace
            )
        else { return nil }
        return measurement
    }

    private mutating func measureFlattenedChildren<Semantic, Metrics, Workspace>(
        of identity: Semantic.Identity,
        semantic: borrowing Semantic,
        metrics: borrowing Metrics,
        proposal: ProposedSize,
        vertical: Bool,
        recognizesFlexibleSpacers: Bool,
        workspace: inout Workspace,
        result: inout StackMeasure,
        each: (LayoutMeasurement) -> Bool
    ) -> Bool
    where
        Semantic: SemanticLayoutView,
        Metrics: CanonicalTextMetricsView,
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
                    metrics: metrics,
                    proposal: proposal,
                    vertical: vertical,
                    recognizesFlexibleSpacers: recognizesFlexibleSpacers,
                    workspace: &workspace,
                    result: &result,
                    each: each
                )
            else { return false }
            index += 1
        }
        return true
    }

    private mutating func measureFlattenedOccurrence<Semantic, Metrics, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        metrics: borrowing Metrics,
        proposal: ProposedSize,
        vertical: Bool,
        recognizesFlexibleSpacers: Bool,
        workspace: inout Workspace,
        result: inout StackMeasure,
        each: (LayoutMeasurement) -> Bool
    ) -> Bool
    where
        Semantic: SemanticLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let modifierCount = semantic.modifierCount(of: identity) else {
            fail(.invariantViolation)
            return false
        }
        let primitive = semantic.primitive(at: identity)
        if primitive != nil || modifierCount > 0 {
            let measurement: LayoutMeasurement
            if recognizesFlexibleSpacers,
                modifierCount == 0,
                case .spacer(let minimum) = primitive
            {
                let size =
                    vertical
                    ? Size(width: 0, height: minimum)!
                    : Size(width: minimum, height: 0)!
                measurement = LayoutMeasurement(idealSize: size, resolvedSize: size)
                guard let next = increment(result.flexibleSpacerCount) else {
                    return fail(.capacityExhausted)
                }
                result.flexibleSpacerCount = next
            } else {
                guard
                    let measured = measureOccurrence(
                        identity,
                        semantic: semantic,
                        metrics: metrics,
                        proposal: proposal,
                        workspace: &workspace
                    )
                else { return false }
                measurement = measured
            }
            guard each(measurement) else { return false }
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
            metrics: metrics,
            proposal: proposal,
            vertical: vertical,
            recognizesFlexibleSpacers: recognizesFlexibleSpacers,
            workspace: &workspace,
            result: &result,
            each: each
        )
    }

    private mutating func assignFlexibleSpacers<Semantic, Workspace>(
        of identity: Semantic.Identity,
        semantic: borrowing Semantic,
        vertical: Bool,
        extra: GeometryScalar,
        spacerCount: UInt16,
        crossExtent: GeometryScalar,
        assignedCount: inout UInt16,
        workspace: inout Workspace
    ) -> Bool
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let childCount = semantic.childCount(of: identity) else {
            return fail(.invariantViolation)
        }
        var index: UInt16 = 0
        while index < childCount {
            guard let child = semantic.child(of: identity, at: index),
                let modifierCount = semantic.modifierCount(of: child)
            else { return fail(.invariantViolation) }
            let primitive = semantic.primitive(at: child)
            if modifierCount == 0, case .spacer(let minimum) = primitive {
                guard spacerCount > 0 else { return fail(.invariantViolation) }
                let divisor = GeometryScalar(spacerCount)
                let quotient = extra / divisor
                let remainder = extra % divisor
                let bonus: GeometryScalar =
                    GeometryScalar(assignedCount) < remainder
                    ? 1 : 0
                guard let withShare = GeometryArithmetic.add(minimum, quotient),
                    let mainExtent = GeometryArithmetic.add(withShare, bonus),
                    let nextAssigned = increment(assignedCount)
                else { return fail(.arithmeticOverflow) }
                let size =
                    vertical
                    ? Size(width: crossExtent, height: mainExtent)!
                    : Size(width: mainExtent, height: crossExtent)!
                guard
                    workspace.storeMeasurement(
                        LayoutMeasurement(idealSize: size, resolvedSize: size),
                        for: child
                    )
                else { return fail(.invariantViolation) }
                assignedCount = nextAssigned
            } else if primitive == nil, modifierCount == 0 {
                guard
                    assignFlexibleSpacers(
                        of: child,
                        semantic: semantic,
                        vertical: vertical,
                        extra: extra,
                        spacerCount: spacerCount,
                        crossExtent: crossExtent,
                        assignedCount: &assignedCount,
                        workspace: &workspace
                    )
                else { return false }
            }
            index += 1
        }
        return true
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
            let scopeIdentity = semantic.modifierScope(of: identity, at: index),
            let measurement = workspace.measurement(for: scopeIdentity),
            let bounds = Rect(origin: origin, size: measurement.resolvedSize)
        else {
            fail(.invariantViolation)
            return false
        }
        let scopeClip: Rect
        switch modifier {
        case .fixedFrame, .flexibleFrame:
            guard
                let intersection = LayoutGeometry.intersection(
                    inheritedClip,
                    bounds
                )
            else { return fail(.arithmeticOverflow) }
            scopeClip = intersection
        default:
            scopeClip = inheritedClip
        }
        guard
            workspace.storePlacement(
                LayoutPlacement(bounds: bounds, clip: scopeClip),
                for: scopeIdentity
            )
        else {
            fail(.invariantViolation)
            return false
        }
        let childOrigin: Point
        switch modifier {
        case .passthrough:
            childOrigin = origin
        case .padding, .paddingInsets:
            guard let insets = paddingInsets(for: modifier),
                let translated = LayoutGeometry.translated(
                    origin,
                    x: insets.leading,
                    y: insets.top
                )
            else { return fail(.arithmeticOverflow) }
            childOrigin = translated
        case .fixedFrame(_, _, let alignment),
            .flexibleFrame(_, _, _, _, let alignment):
            guard
                let childMeasurement = innerMeasurement(
                    identity,
                    modifierIndex: index,
                    semantic: semantic,
                    workspace: workspace
                ),
                let xOffset = LayoutGeometry.offset(
                    container: bounds.size.width,
                    child: childMeasurement.resolvedSize.width,
                    alignment: alignment.horizontal
                ),
                let yOffset = LayoutGeometry.offset(
                    container: bounds.size.height,
                    child: childMeasurement.resolvedSize.height,
                    alignment: alignment.vertical
                ),
                let translated = LayoutGeometry.translated(
                    origin,
                    x: xOffset,
                    y: yOffset
                )
            else { return fail(.arithmeticOverflow) }
            childOrigin = translated
        }
        if index > 0 {
            return placeModifier(
                identity,
                index: index - 1,
                semantic: semantic,
                origin: childOrigin,
                inheritedClip: scopeClip,
                workspace: &workspace
            )
        }
        return placeContent(
            identity,
            semantic: semantic,
            origin: childOrigin,
            inheritedClip: scopeClip,
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
            let bounds = Rect(origin: origin, size: measurement.resolvedSize)
        else {
            fail(.invariantViolation)
            return false
        }
        let scopeClip: Rect
        if primitive == .text {
            guard
                let intersection = LayoutGeometry.intersection(
                    inheritedClip,
                    bounds
                )
            else { return fail(.arithmeticOverflow) }
            scopeClip = intersection
        } else {
            scopeClip = inheritedClip
        }
        guard
            workspace.storePlacement(
                LayoutPlacement(bounds: bounds, clip: scopeClip),
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
        case .zStack(let alignment):
            return placeZStack(
                identity,
                semantic: semantic,
                bounds: bounds,
                inheritedClip: inheritedClip,
                alignment: alignment,
                workspace: &workspace
            )
        case .text:
            return placeTextGeometry(
                identity,
                origin: origin,
                textClip: scopeClip,
                workspace: &workspace
            )
        }
    }

    private mutating func placeTextGeometry<Workspace: LayoutWorkspace>(
        _ identity: Workspace.Identity,
        origin: Point,
        textClip: Rect,
        workspace: inout Workspace
    ) -> Bool {
        var lineStart: UInt16?
        var lineEnd: UInt16 = 0
        var lineIndex: UInt16 = 0
        while lineIndex < workspace.textLineCount {
            guard let line = workspace.textLine(at: lineIndex) else {
                return fail(.invariantViolation)
            }
            if line.identity == identity {
                if lineStart == nil { lineStart = lineIndex }
                guard
                    let boundsOrigin = LayoutGeometry.translated(
                        line.bounds.origin,
                        x: origin.x,
                        y: origin.y
                    ), let bounds = Rect(origin: boundsOrigin, size: line.bounds.size),
                    let baseline = LayoutGeometry.translated(
                        line.baseline,
                        x: origin.x,
                        y: origin.y
                    ), let clip = LayoutGeometry.intersection(textClip, bounds),
                    workspace.storeTextLine(
                        LayoutTextLine(
                            identity: identity,
                            lineIndex: line.lineIndex,
                            bounds: bounds,
                            baseline: baseline,
                            clip: clip
                        ),
                        at: lineIndex
                    ), let next = increment(lineIndex)
                else { return fail(.arithmeticOverflow) }
                lineEnd = next
            }
            lineIndex += 1
        }
        guard let firstLine = lineStart else { return fail(.invariantViolation) }

        var lineCursor = firstLine
        var glyphIndex: UInt16 = 0
        while glyphIndex < workspace.positionedGlyphCount {
            guard let glyph = workspace.positionedGlyph(at: glyphIndex) else {
                return fail(.invariantViolation)
            }
            if glyph.identity == identity {
                while lineCursor < lineEnd,
                    workspace.textLine(at: lineCursor)?.lineIndex != glyph.lineIndex
                {
                    lineCursor += 1
                }
                guard lineCursor < lineEnd,
                    let line = workspace.textLine(at: lineCursor),
                    let baseline = LayoutGeometry.translated(
                        glyph.baseline,
                        x: origin.x,
                        y: origin.y
                    ),
                    workspace.storePositionedGlyph(
                        LayoutPositionedGlyph(
                            identity: identity,
                            lineIndex: glyph.lineIndex,
                            glyphIndex: glyph.glyphIndex,
                            instance: glyph.instance,
                            glyph: glyph.glyph,
                            baseline: baseline,
                            clip: line.clip
                        ),
                        at: glyphIndex
                    )
                else { return fail(.arithmeticOverflow) }
            }
            glyphIndex += 1
        }
        return true
    }

    private mutating func placeZStack<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        bounds: Rect,
        inheritedClip: Rect,
        alignment: Alignment,
        workspace: inout Workspace
    ) -> Bool
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let childCount = semantic.childCount(of: identity) else {
            return fail(.invariantViolation)
        }
        var index: UInt16 = 0
        while index < childCount {
            guard let child = semantic.child(of: identity, at: index),
                placeZFlattenedOccurrence(
                    child,
                    semantic: semantic,
                    bounds: bounds,
                    inheritedClip: inheritedClip,
                    alignment: alignment,
                    workspace: &workspace
                )
            else { return false }
            index += 1
        }
        return true
    }

    private mutating func placeZFlattenedOccurrence<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        bounds: Rect,
        inheritedClip: Rect,
        alignment: Alignment,
        workspace: inout Workspace
    ) -> Bool
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let modifierCount = semantic.modifierCount(of: identity) else {
            return fail(.invariantViolation)
        }
        if semantic.primitive(at: identity) != nil || modifierCount > 0 {
            guard
                let measurement = measurementForOccurrence(
                    identity,
                    semantic: semantic,
                    workspace: workspace
                ),
                let xOffset = LayoutGeometry.offset(
                    container: bounds.size.width,
                    child: measurement.resolvedSize.width,
                    alignment: alignment.horizontal
                ),
                let yOffset = LayoutGeometry.offset(
                    container: bounds.size.height,
                    child: measurement.resolvedSize.height,
                    alignment: alignment.vertical
                ),
                let x = GeometryArithmetic.add(bounds.minX, xOffset),
                let y = GeometryArithmetic.add(bounds.minY, yOffset)
            else { return fail(.arithmeticOverflow) }
            return placeOccurrence(
                identity,
                semantic: semantic,
                origin: Point(x: x, y: y),
                inheritedClip: inheritedClip,
                workspace: &workspace
            )
        }
        return placeZStack(
            identity,
            semantic: semantic,
            bounds: bounds,
            inheritedClip: inheritedClip,
            alignment: alignment,
            workspace: &workspace
        )
    }

    private mutating func paddingInsets(
        for modifier: SemanticLayoutModifier
    ) -> (
        top: GeometryScalar,
        leading: GeometryScalar,
        horizontal: GeometryScalar,
        vertical: GeometryScalar
    )? {
        let top: GeometryScalar
        let leading: GeometryScalar
        let bottom: GeometryScalar
        let trailing: GeometryScalar
        switch modifier {
        case .padding(let edges, let length):
            top = edges.contains(.top) ? length : 0
            leading = edges.contains(.leading) ? length : 0
            bottom = edges.contains(.bottom) ? length : 0
            trailing = edges.contains(.trailing) ? length : 0
        case .paddingInsets(let insets):
            top = insets.top
            leading = insets.leading
            bottom = insets.bottom
            trailing = insets.trailing
        default:
            return nil
        }
        guard let horizontal = GeometryArithmetic.add(leading, trailing),
            let vertical = GeometryArithmetic.add(top, bottom)
        else { return nil }
        return (top, leading, horizontal, vertical)
    }

    private mutating func measurementForOccurrence<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        workspace: borrowing Workspace
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
            guard
                let scopeIdentity = semantic.modifierScope(
                    of: identity,
                    at: modifierCount - 1
                )
            else { return fail(.invariantViolation) }
            return workspace.measurement(for: scopeIdentity)
        }
        return workspace.measurement(for: identity)
    }

    private mutating func innerMeasurement<Semantic, Workspace>(
        _ identity: Semantic.Identity,
        modifierIndex: UInt16,
        semantic: borrowing Semantic,
        workspace: borrowing Workspace
    ) -> LayoutMeasurement?
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        if modifierIndex > 0 {
            guard
                let scopeIdentity = semantic.modifierScope(
                    of: identity,
                    at: modifierIndex - 1
                )
            else { return fail(.invariantViolation) }
            return workspace.measurement(for: scopeIdentity)
        }
        if semantic.primitive(at: identity) != nil {
            return workspace.measurement(for: identity)
        }
        return onlyFlattenedChildMeasurement(
            of: identity,
            semantic: semantic,
            workspace: workspace
        )
    }

    private mutating func onlyFlattenedChildMeasurement<Semantic, Workspace>(
        of identity: Semantic.Identity,
        semantic: borrowing Semantic,
        workspace: borrowing Workspace
    ) -> LayoutMeasurement?
    where
        Semantic: SemanticLayoutView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let childCount = semantic.childCount(of: identity) else {
            return fail(.invariantViolation)
        }
        var found: LayoutMeasurement?
        var foundCount: UInt16 = 0
        var index: UInt16 = 0
        while index < childCount {
            guard let child = semantic.child(of: identity, at: index),
                let modifierCount = semantic.modifierCount(of: child)
            else { return fail(.invariantViolation) }
            let measurement: LayoutMeasurement?
            if semantic.primitive(at: child) != nil || modifierCount > 0 {
                measurement = measurementForOccurrence(
                    child,
                    semantic: semantic,
                    workspace: workspace
                )
            } else {
                measurement = onlyFlattenedChildMeasurement(
                    of: child,
                    semantic: semantic,
                    workspace: workspace
                )
            }
            if let measurement {
                guard let next = increment(foundCount) else {
                    return fail(.capacityExhausted)
                }
                foundCount = next
                found = measurement
            }
            index += 1
        }
        guard foundCount == 1 else { return fail(.invariantViolation) }
        return found
    }

    private func frameChildProposal(
        modifier: SemanticLayoutModifier,
        parent: ProposedSize
    ) -> ProposedSize? {
        switch modifier {
        case .fixedFrame(let width, let height, _):
            return ProposedSize(
                width: childFrameProposalAxis(
                    parent: parent.width,
                    fixed: width,
                    maximum: nil
                ),
                height: childFrameProposalAxis(
                    parent: parent.height,
                    fixed: height,
                    maximum: nil
                )
            )
        case .flexibleFrame(_, let maxWidth, _, let maxHeight, _):
            return ProposedSize(
                width: childFrameProposalAxis(
                    parent: parent.width,
                    fixed: nil,
                    maximum: maxWidth
                ),
                height: childFrameProposalAxis(
                    parent: parent.height,
                    fixed: nil,
                    maximum: maxHeight
                )
            )
        default:
            return nil
        }
    }

    private func childFrameProposalAxis(
        parent: GeometryScalar?,
        fixed: GeometryScalar?,
        maximum: FrameLimit?
    ) -> GeometryScalar? {
        if let fixed { return fixed }
        if let parent {
            if case .points(let finiteMaximum) = maximum {
                return min(parent, finiteMaximum)
            }
            return parent
        }
        if case .points(let finiteMaximum) = maximum {
            return finiteMaximum
        }
        return nil
    }

    private func frameMeasurement(
        modifier: SemanticLayoutModifier,
        child: LayoutMeasurement,
        parent: ProposedSize
    ) -> LayoutMeasurement {
        let ideal: Size
        switch modifier {
        case .fixedFrame(let width, let height, _):
            ideal = Size(
                width: width ?? child.idealSize.width,
                height: height ?? child.idealSize.height
            )!
        case .flexibleFrame(
            let minWidth,
            let maxWidth,
            let minHeight,
            let maxHeight,
            _
        ):
            ideal = Size(
                width: requestedFrameAxis(
                    child: child.idealSize.width,
                    minimum: minWidth ?? 0,
                    maximum: maxWidth,
                    parent: parent.width
                ),
                height: requestedFrameAxis(
                    child: child.idealSize.height,
                    minimum: minHeight ?? 0,
                    maximum: maxHeight,
                    parent: parent.height
                )
            )!
        default:
            ideal = child.idealSize
        }
        return LayoutGeometry.cap(ideal: ideal, to: parent)
    }

    private func requestedFrameAxis(
        child: GeometryScalar,
        minimum: GeometryScalar,
        maximum: FrameLimit?,
        parent: GeometryScalar?
    ) -> GeometryScalar {
        var requested = LayoutGeometry.clamped(
            child,
            minimum: minimum,
            maximum: maximum
        )
        if maximum == .infinity, let parent, parent > requested {
            requested = parent
        }
        return requested
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
                guard
                    let measurement = measurementForOccurrence(
                        child,
                        semantic: semantic,
                        workspace: workspace
                    )
                else {
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
