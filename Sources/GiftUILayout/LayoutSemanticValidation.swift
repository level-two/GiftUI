import GiftUI
import GiftUISemanticCore
import GiftUITextResources

package struct LayoutSemanticValidation {
    private let limits: LayoutLimits
    private var counters: LayoutCounters

    package init(limits: LayoutLimits) {
        self.limits = limits
        counters = LayoutCounters(limits: limits)
    }

    package var countersSnapshot: LayoutCounters { counters }

    package mutating func validate<Semantic, Metrics, Workspace>(
        semantic: borrowing Semantic,
        metrics: borrowing Metrics,
        workspace: inout Workspace
    ) -> LayoutError?
    where
        Semantic: SemanticLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        let expectedScopeCount = semantic.scopeCount
        guard expectedScopeCount <= limits.maximumScopes,
            expectedScopeCount <= workspace.maximumScopes
        else {
            return .capacityExhausted
        }

        let rootIdentity = semantic.rootIdentity
        var instance: FontInstanceDescriptor?
        var flattenedCount: UInt16 = 0
        if let error = validateOccurrence(
            rootIdentity,
            semantic: semantic,
            metrics: metrics,
            instance: &instance,
            workspace: &workspace,
            flattenedCount: &flattenedCount
        ) {
            return error
        }
        guard flattenedCount == 1 else { return .invalidDeclaration }
        return counters.finish(expectedScopeCount: expectedScopeCount)
    }

    private mutating func validateOccurrence<Semantic, Metrics, Workspace>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        metrics: borrowing Metrics,
        instance: inout FontInstanceDescriptor?,
        workspace: inout Workspace,
        flattenedCount: inout UInt16
    ) -> LayoutError?
    where
        Semantic: SemanticLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        guard let modifierCount = semantic.modifierCount(of: identity),
            let childCount = semantic.childCount(of: identity)
        else { return .invariantViolation }

        var modifierIndex = modifierCount
        while modifierIndex > 0 {
            modifierIndex -= 1
            guard
                let scopeIdentity = semantic.modifierScope(
                    of: identity,
                    at: modifierIndex
                ),
                let modifier = semantic.modifier(of: identity, at: modifierIndex)
            else { return .invariantViolation }
            if let error = validate(modifier) { return error }
            if let error = reserveScope(
                scopeIdentity,
                workspace: &workspace
            ) {
                return error
            }
        }
        guard semantic.modifierScope(of: identity, at: modifierCount) == nil,
            semantic.modifier(of: identity, at: modifierCount) == nil
        else { return .invariantViolation }

        let primitive = semantic.primitive(at: identity)
        if let primitive {
            if let error = validate(primitive) { return error }
            if let error = reserveScope(identity, workspace: &workspace) {
                return error
            }
            if let error = validatePrimitiveContent(
                primitive,
                identity: identity,
                childCount: childCount,
                semantic: semantic,
                metrics: metrics,
                instance: &instance,
                workspace: &workspace
            ) {
                return error
            }
            flattenedCount = 1
        } else {
            var childIndex: UInt16 = 0
            var transparentChildCount: UInt16 = 0
            while childIndex < childCount {
                guard let child = semantic.child(of: identity, at: childIndex) else {
                    return .invariantViolation
                }
                var childFlattenedCount: UInt16 = 0
                if let error = validateOccurrence(
                    child,
                    semantic: semantic,
                    metrics: metrics,
                    instance: &instance,
                    workspace: &workspace,
                    flattenedCount: &childFlattenedCount
                ) {
                    return error
                }
                let sum = transparentChildCount.addingReportingOverflow(
                    childFlattenedCount
                )
                guard !sum.overflow else { return .capacityExhausted }
                transparentChildCount = sum.partialValue
                childIndex += 1
            }
            flattenedCount = transparentChildCount
        }

        guard semantic.child(of: identity, at: childCount) == nil else {
            return .invariantViolation
        }
        if modifierCount > 0, flattenedCount != 1 {
            return .invalidDeclaration
        }

        var scopeIndex: UInt16 = 0
        let primitiveScopeCount: UInt16 = primitive == nil ? 0 : 1
        let ownedScopeCountResult = modifierCount.addingReportingOverflow(
            primitiveScopeCount
        )
        guard !ownedScopeCountResult.overflow else { return .capacityExhausted }
        let ownedScopeCount = ownedScopeCountResult.partialValue
        while scopeIndex < ownedScopeCount {
            if let error = counters.leaveScope() { return error }
            workspace.popScope()
            scopeIndex += 1
        }
        if modifierCount > 0 {
            flattenedCount = 1
        }
        return nil
    }

    private mutating func validatePrimitiveContent<Semantic, Metrics, Workspace>(
        _ primitive: SemanticLayoutPrimitive,
        identity: Semantic.Identity,
        childCount: UInt16,
        semantic: borrowing Semantic,
        metrics: borrowing Metrics,
        instance: inout FontInstanceDescriptor?,
        workspace: inout Workspace
    ) -> LayoutError?
    where
        Semantic: SemanticLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: LayoutWorkspace,
        Semantic.Identity == Workspace.Identity
    {
        switch primitive {
        case .spacer, .text, .canvas:
            guard childCount == 0 else { return .invalidDeclaration }
        case .proxy:
            guard childCount > 0 else { return .invalidDeclaration }
        case .vStack, .hStack, .zStack:
            break
        }

        var childIndex: UInt16 = 0
        var flattenedChildren: UInt16 = 0
        while childIndex < childCount {
            guard let child = semantic.child(of: identity, at: childIndex) else {
                return .invariantViolation
            }
            var childFlattenedCount: UInt16 = 0
            if let error = validateOccurrence(
                child,
                semantic: semantic,
                metrics: metrics,
                instance: &instance,
                workspace: &workspace,
                flattenedCount: &childFlattenedCount
            ) {
                return error
            }
            let sum = flattenedChildren.addingReportingOverflow(childFlattenedCount)
            guard !sum.overflow else { return .capacityExhausted }
            flattenedChildren = sum.partialValue
            childIndex += 1
        }
        if primitive == .proxy, flattenedChildren != 1 {
            return .invalidDeclaration
        }

        if primitive == .text {
            return validateText(
                identity,
                semantic: semantic,
                metrics: metrics,
                instance: &instance
            )
        }
        guard semantic.textScalarCount(of: identity) == nil else {
            return .invariantViolation
        }
        return nil
    }

    private mutating func validateText<Semantic, Metrics>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        metrics: borrowing Metrics,
        instance: inout FontInstanceDescriptor?
    ) -> LayoutError?
    where Semantic: SemanticLayoutView, Metrics: CanonicalTextMetricsView {
        guard let scalarCount = semantic.textScalarCount(of: identity) else {
            return .invariantViolation
        }
        if instance == nil {
            guard metrics.descriptor.instanceCount == 1,
                let canonicalInstance = metrics.instance(at: 0),
                metrics.instance(at: 1) == nil
            else { return .invariantViolation }
            instance = canonicalInstance
        }
        guard let instance else { return .invariantViolation }

        if let error = counters.reserveTextLine() { return error }
        var previousWasCarriageReturn = false
        var scalarIndex: UInt16 = 0
        while scalarIndex < scalarCount {
            if let error = counters.reserveTextScalar() { return error }
            guard let scalar = semantic.textScalar(of: identity, at: scalarIndex)
            else { return .invariantViolation }
            guard isValidUnicodeScalar(scalar) else { return .invalidDeclaration }

            if scalar == 0x0d {
                if let error = counters.reserveTextLine() { return error }
                previousWasCarriageReturn = true
            } else if scalar == 0x0a {
                if !previousWasCarriageReturn,
                    let error = counters.reserveTextLine()
                {
                    return error
                }
                previousWasCarriageReturn = false
            } else {
                previousWasCarriageReturn = false
                if let error = counters.reservePositionedGlyph() { return error }
                guard let mapping = metrics.mapScalar(scalar, in: instance.id) else {
                    return .invariantViolation
                }
                let glyph: GlyphID
                switch mapping {
                case .exact(let value), .replacement(let value):
                    glyph = value
                }
                guard metrics.metrics(for: glyph, in: instance.id) != nil else {
                    return .invariantViolation
                }
            }
            scalarIndex += 1
        }
        guard semantic.textScalar(of: identity, at: scalarCount) == nil else {
            return .invariantViolation
        }
        return nil
    }

    private mutating func reserveScope<Workspace: LayoutWorkspace>(
        _ identity: Workspace.Identity,
        workspace: inout Workspace
    ) -> LayoutError? {
        if let error = counters.reserveScope() { return error }
        if let error = counters.enterScope() { return error }
        let zero = Size(width: 0, height: 0)!
        guard
            workspace.appendScope(
                identity: identity,
                measurement: LayoutMeasurement(idealSize: zero, resolvedSize: zero)
            )
        else { return .invariantViolation }
        guard workspace.pushScope(identity) else { return .invariantViolation }
        return nil
    }

    private func validate(_ primitive: SemanticLayoutPrimitive) -> LayoutError? {
        switch primitive {
        case .proxy, .text, .canvas, .zStack:
            return nil
        case .vStack(_, let spacing), .hStack(_, let spacing):
            return spacing < 0 ? .invalidDeclaration : nil
        case .spacer(let minLength):
            return minLength < 0 ? .invalidDeclaration : nil
        }
    }

    private func validate(_ modifier: SemanticLayoutModifier) -> LayoutError? {
        switch modifier {
        case .passthrough:
            return nil
        case .padding(let edges, let length):
            return edges.rawValue & ~EdgeSet.all.rawValue != 0 || length < 0
                ? .invalidDeclaration : nil
        case .paddingInsets(let insets):
            return insets.top < 0 || insets.leading < 0 || insets.bottom < 0
                || insets.trailing < 0 ? .invalidDeclaration : nil
        case .fixedFrame(let width, let height, _):
            return invalid(width) || invalid(height) ? .invalidDeclaration : nil
        case .flexibleFrame(
            let minWidth,
            let maxWidth,
            let minHeight,
            let maxHeight,
            _
        ):
            guard !invalid(minWidth), !invalid(minHeight),
                !invalid(maxWidth), !invalid(maxHeight),
                relationIsValid(minimum: minWidth, maximum: maxWidth),
                relationIsValid(minimum: minHeight, maximum: maxHeight)
            else { return .invalidDeclaration }
            return nil
        }
    }

    private func invalid(_ value: GeometryScalar?) -> Bool {
        value.map { $0 < 0 } ?? false
    }

    private func invalid(_ value: FrameLimit?) -> Bool {
        guard case .points(let points) = value else { return false }
        return points < 0
    }

    private func relationIsValid(
        minimum: GeometryScalar?,
        maximum: FrameLimit?
    ) -> Bool {
        guard let minimum, case .points(let maximum) = maximum else {
            return true
        }
        return maximum >= minimum
    }

    private func isValidUnicodeScalar(_ value: UInt32) -> Bool {
        value <= 0x10ffff && !(0xd800 ... 0xdfff).contains(value)
    }
}
