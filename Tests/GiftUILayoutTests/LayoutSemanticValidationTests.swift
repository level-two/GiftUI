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

    init() {
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
        instance == instanceValue.id ? .exact(GlyphID(rawValue: 0)) : nil
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

    func measurement(for identity: borrowing UInt16) -> LayoutMeasurement? {
        let identity = copy identity
        return scopes.first { $0.0 == identity }?.1
    }

    mutating func storePlacement(
        _ placement: LayoutPlacement,
        for identity: borrowing UInt16
    ) -> Bool { false }

    func placement(for identity: borrowing UInt16) -> LayoutPlacement? { nil }

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
