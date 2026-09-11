import GiftUI
import GiftUISemanticCore
import GiftUITextResources
import Testing

@testable import GiftUILayout

@Test
func semanticValidationAcceptsOneWellFormedRootScope() {
    let semantic = ValidationSemanticView(
        scopeCount: 1,
        records: [ValidationRecord(identity: 1, primitive: .spacer(minLength: 0))]
    )

    #expect(validate(semantic) == nil)
}

@Test
func semanticValidationRejectsInvalidPayloadBeforePublication() {
    let semantic = ValidationSemanticView(
        scopeCount: 1,
        records: [ValidationRecord(identity: 1, primitive: .spacer(minLength: -1))]
    )

    #expect(validate(semantic) == .invalidDeclaration)
}

@Test
func semanticValidationRejectsMissingInRangeChildAsInvariantFailure() {
    let semantic = ValidationSemanticView(
        scopeCount: 1,
        records: [
            ValidationRecord(
                identity: 1,
                primitive: .proxy,
                declaredChildCount: 1
            )
        ]
    )

    #expect(validate(semantic) == .invariantViolation)
}

@Test
func semanticValidationRequiresTheDeclaredScopeCountToMatchTraversal() {
    let semantic = ValidationSemanticView(
        scopeCount: 2,
        records: [ValidationRecord(identity: 1, primitive: .spacer(minLength: 0))]
    )

    #expect(validate(semantic) == .invariantViolation)
}

@Test
func semanticValidationRejectsInvalidUnicodeScalar() {
    let semantic = ValidationSemanticView(
        scopeCount: 1,
        records: [ValidationRecord(identity: 1, primitive: .text, scalars: [0xd800])]
    )

    #expect(validate(semantic) == .invalidDeclaration)
}

@Test
func textScalarLimitFailsBeforeTheOneOverLookup() {
    let accesses = ScalarAccesses()
    let semantic = ValidationSemanticView(
        scopeCount: 1,
        records: [
            ValidationRecord(identity: 1, primitive: .text, scalars: [0x41, 0x42])
        ],
        scalarAccesses: accesses
    )

    #expect(validate(semantic, maximum: 1) == .capacityExhausted)
    #expect(accesses.indices == [0])
}

@Test
func declaredScopeLimitFailsBeforeRootOrOccurrenceInspection() {
    let accesses = SemanticAccesses()
    let semantic = ScopeLimitSemanticView(accesses: accesses)
    let limits = LayoutLimits(
        maximumScopes: 1,
        maximumDepth: 1,
        maximumTextScalars: 1,
        maximumTextLines: 1,
        maximumPositionedGlyphs: 1
    )!
    var workspace = ValidationWorkspace(maximum: 2)
    let acquired = workspace.acquireLayout()
    #expect(acquired)
    var validation = LayoutSemanticValidation(limits: limits)

    #expect(
        validation.validate(
            semantic: semantic,
            metrics: ValidationMetricsView(),
            workspace: &workspace
        ) == .capacityExhausted
    )
    #expect(accesses.rootCount == 0)
    #expect(accesses.occurrenceCount == 0)
}

@Test
func explicitLineLimitFailsAtTheBreakBeforeLaterScalarLookup() {
    let accesses = ScalarAccesses()
    let semantic = ValidationSemanticView(
        scopeCount: 1,
        records: [
            ValidationRecord(
                identity: 1,
                primitive: .text,
                scalars: [0x41, 0x0a, 0x42]
            )
        ],
        scalarAccesses: accesses
    )
    let limits = LayoutLimits(
        maximumScopes: 4,
        maximumDepth: 4,
        maximumTextScalars: 4,
        maximumTextLines: 1,
        maximumPositionedGlyphs: 4
    )!
    var workspace = ValidationWorkspace(maximum: 4)
    let acquired = workspace.acquireLayout()
    #expect(acquired)
    var validation = LayoutSemanticValidation(limits: limits)

    #expect(
        validation.validate(
            semantic: semantic,
            metrics: ValidationMetricsView(),
            workspace: &workspace
        ) == .capacityExhausted
    )
    #expect(accesses.indices == [0, 1])
}

@Test
func positionedGlyphLimitFailsBeforeTheOneOverMappingLookup() {
    let accesses = MappingAccesses()
    let semantic = ValidationSemanticView(
        scopeCount: 1,
        records: [
            ValidationRecord(identity: 1, primitive: .text, scalars: [0x41, 0x42])
        ]
    )
    let limits = LayoutLimits(
        maximumScopes: 4,
        maximumDepth: 4,
        maximumTextScalars: 4,
        maximumTextLines: 4,
        maximumPositionedGlyphs: 1
    )!
    var workspace = ValidationWorkspace(maximum: 4)
    let acquired = workspace.acquireLayout()
    #expect(acquired)
    var validation = LayoutSemanticValidation(limits: limits)

    #expect(
        validation.validate(
            semantic: semantic,
            metrics: ValidationMetricsView(mappingAccesses: accesses),
            workspace: &workspace
        ) == .capacityExhausted
    )
    #expect(accesses.scalars == [0x41])
}

private func validate(
    _ semantic: ValidationSemanticView,
    maximum: UInt16 = 8
) -> LayoutError? {
    let limits = LayoutLimits(
        maximumScopes: maximum,
        maximumDepth: maximum,
        maximumTextScalars: maximum,
        maximumTextLines: maximum,
        maximumPositionedGlyphs: maximum
    )!
    var workspace = ValidationWorkspace(maximum: maximum)
    let acquired = workspace.acquireLayout()
    #expect(acquired)
    var validation = LayoutSemanticValidation(limits: limits)
    let result = validation.validate(
        semantic: semantic,
        metrics: ValidationMetricsView(),
        workspace: &workspace
    )
    workspace.resetLayout()
    return result
}

private final class ScalarAccesses: @unchecked Sendable {
    var indices: [UInt16] = []
}

private final class SemanticAccesses: @unchecked Sendable {
    var rootCount = 0
    var occurrenceCount = 0
}

private final class MappingAccesses: @unchecked Sendable {
    var scalars: [UInt32] = []
}

private struct ScopeLimitSemanticView: SemanticLayoutView {
    let accesses: SemanticAccesses

    var rootIdentity: UInt16 {
        accesses.rootCount += 1
        return 1
    }

    var scopeCount: UInt16 { 2 }

    func primitive(at identity: UInt16) -> SemanticLayoutPrimitive? {
        accesses.occurrenceCount += 1
        return .spacer(minLength: 0)
    }

    func childCount(of identity: UInt16) -> UInt16? {
        accesses.occurrenceCount += 1
        return 0
    }

    func child(of identity: UInt16, at index: UInt16) -> UInt16? {
        accesses.occurrenceCount += 1
        return nil
    }

    func modifierCount(of identity: UInt16) -> UInt16? {
        accesses.occurrenceCount += 1
        return 0
    }

    func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? {
        accesses.occurrenceCount += 1
        return nil
    }

    func modifier(
        of identity: UInt16,
        at index: UInt16
    ) -> SemanticLayoutModifier? {
        accesses.occurrenceCount += 1
        return nil
    }

    func textScalarCount(of identity: UInt16) -> UInt16? {
        accesses.occurrenceCount += 1
        return nil
    }

    func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? {
        accesses.occurrenceCount += 1
        return nil
    }
}

private struct ValidationRecord {
    let identity: UInt16
    let primitive: SemanticLayoutPrimitive?
    let children: [UInt16]
    let declaredChildCount: UInt16
    let modifiers: [(UInt16, SemanticLayoutModifier)]
    let scalars: [UInt32]?

    init(
        identity: UInt16,
        primitive: SemanticLayoutPrimitive?,
        children: [UInt16] = [],
        declaredChildCount: UInt16? = nil,
        modifiers: [(UInt16, SemanticLayoutModifier)] = [],
        scalars: [UInt32]? = nil
    ) {
        self.identity = identity
        self.primitive = primitive
        self.children = children
        self.declaredChildCount = declaredChildCount ?? UInt16(children.count)
        self.modifiers = modifiers
        self.scalars = scalars
    }
}

private struct ValidationSemanticView: SemanticLayoutView {
    let rootIdentity: UInt16
    let scopeCount: UInt16
    let records: [ValidationRecord]
    let scalarAccesses: ScalarAccesses?

    init(
        rootIdentity: UInt16 = 1,
        scopeCount: UInt16,
        records: [ValidationRecord],
        scalarAccesses: ScalarAccesses? = nil
    ) {
        self.rootIdentity = rootIdentity
        self.scopeCount = scopeCount
        self.records = records
        self.scalarAccesses = scalarAccesses
    }

    func primitive(at identity: UInt16) -> SemanticLayoutPrimitive? {
        record(identity)?.primitive
    }

    func childCount(of identity: UInt16) -> UInt16? {
        record(identity)?.declaredChildCount
    }

    func child(of identity: UInt16, at index: UInt16) -> UInt16? {
        guard let children = record(identity)?.children, Int(index) < children.count
        else { return nil }
        return children[Int(index)]
    }

    func modifierCount(of identity: UInt16) -> UInt16? {
        record(identity).map { UInt16($0.modifiers.count) }
    }

    func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? {
        guard let modifiers = record(identity)?.modifiers, Int(index) < modifiers.count
        else { return nil }
        return modifiers[Int(index)].0
    }

    func modifier(
        of identity: UInt16,
        at index: UInt16
    ) -> SemanticLayoutModifier? {
        guard let modifiers = record(identity)?.modifiers, Int(index) < modifiers.count
        else { return nil }
        return modifiers[Int(index)].1
    }

    func textScalarCount(of identity: UInt16) -> UInt16? {
        record(identity)?.scalars.map { UInt16($0.count) }
    }

    func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? {
        scalarAccesses?.indices.append(index)
        guard let scalars = record(identity)?.scalars, Int(index) < scalars.count
        else { return nil }
        return scalars[Int(index)]
    }

    private func record(_ identity: UInt16) -> ValidationRecord? {
        records.first { $0.identity == identity }
    }
}

private struct ValidationMetricsView: CanonicalTextMetricsView {
    let instanceValue: FontInstanceDescriptor
    let mappingAccesses: MappingAccesses?

    init(mappingAccesses: MappingAccesses? = nil) {
        self.mappingAccesses = mappingAccesses
        let resource = FontResourceID(
            rawValue: TextResourceDigest(
                word0: 0,
                word1: 0,
                word2: 0,
                word3: 0,
                word4: 0,
                word5: 0,
                word6: 0,
                word7: 0
            )
        )
        instanceValue = FontInstanceDescriptor(
            id: FontInstanceID(resource: resource, instanceIndex: 0),
            lineMetrics: FontLineMetrics(ascent: 1, descent: 1, lineGap: 0),
            replacementGlyph: GlyphID(rawValue: 0),
            glyphCount: 1,
            mappingCount: 1
        )
    }

    var descriptor: TextResourceDescriptor {
        TextResourceDescriptor(
            schemaVersion: 1,
            resource: instanceValue.id.resource,
            instanceCount: 1,
            realizationCount: 0,
            canonicalManifestByteCount: 0
        )
    }

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        index == 0 ? instanceValue : nil
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? {
        nil
    }

    func mapScalar(
        _ scalarValue: UInt32,
        in instance: FontInstanceID
    ) -> GlyphMapping? {
        mappingAccesses?.scalars.append(scalarValue)
        return instance == instanceValue.id
            ? GlyphMapping.exact(GlyphID(rawValue: 0)) : nil
    }

    func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        guard glyph.rawValue == 0, instance == instanceValue.id else { return nil }
        return GlyphMetrics(
            advanceX: 1,
            offsetX: 0,
            offsetY: 0,
            inkSize: Size(width: 1, height: 1)!
        )
    }
}

private struct ValidationWorkspace: LayoutWorkspace {
    let maximumScopes: UInt16
    let maximumDepth: UInt16
    let maximumTextScalars: UInt16
    let maximumTextLines: UInt16
    let maximumPositionedGlyphs: UInt16
    var isLayoutActive = false
    private var scopes: [(UInt16, LayoutMeasurement)] = []
    private var depth: [UInt16] = []

    init(maximum: UInt16) {
        maximumScopes = maximum
        maximumDepth = maximum
        maximumTextScalars = maximum
        maximumTextLines = maximum
        maximumPositionedGlyphs = maximum
    }

    mutating func acquireLayout() -> Bool {
        guard !isLayoutActive else { return false }
        isLayoutActive = true
        return true
    }

    mutating func appendScope(
        identity: borrowing UInt16,
        measurement: LayoutMeasurement
    ) -> Bool {
        let identity = copy identity
        guard !scopes.contains(where: { $0.0 == identity }) else { return false }
        scopes.append((identity, measurement))
        return true
    }

    var scopeCount: UInt16 { UInt16(scopes.count) }

    func scopeIdentity(at index: UInt16) -> UInt16? {
        guard Int(index) < scopes.count else { return nil }
        return scopes[Int(index)].0
    }

    func measurement(for identity: borrowing UInt16) -> LayoutMeasurement? {
        let identity = copy identity
        return scopes.first { $0.0 == identity }?.1
    }

    mutating func storeMeasurement(
        _ measurement: LayoutMeasurement,
        for identity: borrowing UInt16
    ) -> Bool {
        let identityCopy = copy identity
        guard let index = scopes.firstIndex(where: { $0.0 == identityCopy }) else {
            return false
        }
        scopes[index].1 = measurement
        return true
    }

    mutating func storePlacement(
        _ placement: LayoutPlacement,
        for identity: borrowing UInt16
    ) -> Bool { false }

    func placement(for identity: borrowing UInt16) -> LayoutPlacement? { nil }

    var textLineCount: UInt16 { 0 }
    mutating func appendTextLine(_ line: LayoutTextLine<UInt16>) -> Bool { false }
    func textLine(at index: UInt16) -> LayoutTextLine<UInt16>? { nil }

    var positionedGlyphCount: UInt16 { 0 }
    mutating func appendPositionedGlyph(
        _ glyph: LayoutPositionedGlyph<UInt16>
    ) -> Bool { false }
    func positionedGlyph(at index: UInt16) -> LayoutPositionedGlyph<UInt16>? { nil }

    mutating func pushScope(_ identity: borrowing UInt16) -> Bool {
        depth.append(copy identity)
        return true
    }

    mutating func popScope() {
        _ = depth.popLast()
    }

    mutating func resetLayout() {
        scopes.removeAll(keepingCapacity: true)
        depth.removeAll(keepingCapacity: true)
        isLayoutActive = false
    }
}
