import GiftUI
import Testing

@testable import GiftUISemanticCore

private enum CorpusToken: UInt8, CaseIterable, Equatable, Sendable {
    case root
    case stack
    case stackPadding
    case actionProxy
    case spacer
    case text
}

private struct CorpusMeaning: Equatable {
    let token: CorpusToken
    let primitive: SemanticLayoutPrimitive?
    let children: [CorpusToken]
    let modifiers: [(CorpusToken, SemanticLayoutModifier)]
    let scalars: [UInt32]?

    static func == (lhs: CorpusMeaning, rhs: CorpusMeaning) -> Bool {
        lhs.token == rhs.token
            && lhs.primitive == rhs.primitive
            && lhs.children == rhs.children
            && lhs.modifiers.elementsEqual(rhs.modifiers) {
                $0.0 == $1.0 && $0.1 == $1.1
            }
            && lhs.scalars == rhs.scalars
    }
}

@Test
func layoutProfileViewsExposeEqualMeaningWithoutComparingIdentityBytes() {
    let recording = RecordingLayoutView()
    let dynamic = DynamicLayoutView()
    let fixed = FixedLayoutView()

    let recordingMeaning = meaning(of: recording) { $0.token }
    let dynamicMeaning = meaning(of: dynamic) { $0.token }
    let fixedMeaning = meaning(of: fixed) { $0.token }

    #expect(recordingMeaning == dynamicMeaning)
    #expect(dynamicMeaning == fixedMeaning)
    #expect(recording.scopeCount == 5)
    #expect(dynamic.scopeCount == 5)
    #expect(fixed.scopeCount == 5)
}

@Test
func layoutProfileViewsPreserveExactIdentityRelationsAndBounds() {
    assertIdentityRelations(RecordingLayoutView()) { $0.token }
    assertIdentityRelations(DynamicLayoutView()) { $0.token }
    assertIdentityRelations(FixedLayoutView()) { $0.token }
}

@Test
func malformedLayoutProfileViewCanInjectMissingInRangeContent() {
    let view = DynamicLayoutView(omitFirstStackChild: true)
    let stack = DynamicIdentity(slot: 41, token: .stack)

    #expect(view.childCount(of: stack) == 2)
    #expect(view.child(of: stack, at: 0) == nil)
    #expect(view.child(of: stack, at: 1)?.token == .text)
    #expect(view.child(of: stack, at: 2) == nil)
}

private func meaning<View: SemanticLayoutView>(
    of view: View,
    token: (View.Identity) -> CorpusToken
) -> [CorpusMeaning] {
    CorpusToken.allCases.map { expectedToken in
        let identity = identity(for: expectedToken, in: view, token: token)!
        let childCount = view.childCount(of: identity)!
        let modifierCount = view.modifierCount(of: identity)!
        let scalarCount = view.textScalarCount(of: identity)
        return CorpusMeaning(
            token: expectedToken,
            primitive: view.primitive(at: identity),
            children: values(count: childCount) {
                view.child(of: identity, at: $0).map(token)
            },
            modifiers: values(count: modifierCount) { index in
                guard
                    let scope = view.modifierScope(of: identity, at: index),
                    let modifier = view.modifier(of: identity, at: index)
                else { return nil }
                return (token(scope), modifier)
            },
            scalars: scalarCount.map { count in
                values(count: count) { view.textScalar(of: identity, at: $0) }
            }
        )
    }
}

private func assertIdentityRelations<View: SemanticLayoutView>(
    _ view: View,
    token: (View.Identity) -> CorpusToken
) {
    let root = view.rootIdentity
    #expect(token(root) == .root)
    #expect(view.childCount(of: root) == 1)
    #expect(view.child(of: root, at: 0).map(token) == .stack)
    #expect(view.child(of: root, at: 1) == nil)

    let stack = view.child(of: root, at: 0)!
    #expect(view.modifierCount(of: stack) == 1)
    #expect(view.modifierScope(of: stack, at: 0).map(token) == .stackPadding)
    #expect(view.modifierScope(of: stack, at: 1) == nil)
    #expect(view.modifier(of: stack, at: 1) == nil)

    let text = view.child(of: stack, at: 1)!
    #expect(view.textScalarCount(of: text) == 3)
    #expect(view.textScalar(of: text, at: 0) == 0x41)
    #expect(view.textScalar(of: text, at: 1) == 0x0a)
    #expect(view.textScalar(of: text, at: 2) == 0x00b0)
    #expect(view.textScalar(of: text, at: 3) == nil)

    let unknown = identity(for: .stackPadding, in: view, token: token)!
    #expect(view.primitive(at: unknown) == nil)
    #expect(view.childCount(of: unknown) == 0)
    #expect(view.modifierCount(of: unknown) == 0)
    #expect(view.textScalarCount(of: unknown) == nil)
}

private func identity<View: SemanticLayoutView>(
    for expected: CorpusToken,
    in view: View,
    token: (View.Identity) -> CorpusToken
) -> View.Identity? {
    if token(view.rootIdentity) == expected { return view.rootIdentity }
    let root = view.rootIdentity
    guard let rootCount = view.childCount(of: root) else { return nil }
    var rootIndex: UInt16 = 0
    while rootIndex < rootCount {
        if let child = view.child(of: root, at: rootIndex) {
            if token(child) == expected { return child }
            if let modifierCount = view.modifierCount(of: child) {
                var modifierIndex: UInt16 = 0
                while modifierIndex < modifierCount {
                    if let scope = view.modifierScope(of: child, at: modifierIndex),
                        token(scope) == expected
                    {
                        return scope
                    }
                    modifierIndex += 1
                }
            }
            if let childCount = view.childCount(of: child) {
                var childIndex: UInt16 = 0
                while childIndex < childCount {
                    if let descendant = view.child(of: child, at: childIndex) {
                        if token(descendant) == expected { return descendant }
                        if let grandchild = view.child(of: descendant, at: 0),
                            token(grandchild) == expected
                        {
                            return grandchild
                        }
                    }
                    childIndex += 1
                }
            }
        }
        rootIndex += 1
    }
    return nil
}

private func values<Value>(
    count: UInt16,
    value: (UInt16) -> Value?
) -> [Value] {
    var result: [Value] = []
    var index: UInt16 = 0
    while index < count {
        if let item = value(index) { result.append(item) }
        index += 1
    }
    return result
}

private struct RecordingIdentity: Equatable, Sendable {
    let path: (UInt8, UInt8, UInt8)
    let token: CorpusToken

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.path.0 == rhs.path.0 && lhs.path.1 == rhs.path.1
            && lhs.path.2 == rhs.path.2 && lhs.token == rhs.token
    }
}

private struct DynamicIdentity: Equatable, Sendable {
    let slot: UInt32
    let token: CorpusToken
}

private enum FixedIdentity: UInt16, Equatable, Sendable {
    case root = 0x310
    case stack = 0x522
    case stackPadding = 0x19
    case actionProxy = 0x770
    case spacer = 0x23
    case text = 0x640

    var token: CorpusToken {
        switch self {
        case .root: .root
        case .stack: .stack
        case .stackPadding: .stackPadding
        case .actionProxy: .actionProxy
        case .spacer: .spacer
        case .text: .text
        }
    }
}

private struct LayoutRecord<Identity> {
    let identity: Identity
    let primitive: SemanticLayoutPrimitive?
    let children: [Identity]
    let modifiers: [(Identity, SemanticLayoutModifier)]
    let scalars: [UInt32]?
}

private protocol CorpusLayoutView: SemanticLayoutView {
    var records: [LayoutRecord<Identity>] { get }
}

extension CorpusLayoutView {
    var scopeCount: UInt16 { 5 }

    func primitive(at identity: Identity) -> SemanticLayoutPrimitive? {
        record(identity)?.primitive
    }

    func childCount(of identity: Identity) -> UInt16? {
        record(identity).map { UInt16($0.children.count) }
    }

    func child(of identity: Identity, at index: UInt16) -> Identity? {
        guard let children = record(identity)?.children, Int(index) < children.count
        else { return nil }
        return children[Int(index)]
    }

    func modifierCount(of identity: Identity) -> UInt16? {
        record(identity).map { UInt16($0.modifiers.count) }
    }

    func modifierScope(of identity: Identity, at index: UInt16) -> Identity? {
        guard let modifiers = record(identity)?.modifiers, Int(index) < modifiers.count
        else { return nil }
        return modifiers[Int(index)].0
    }

    func modifier(
        of identity: Identity,
        at index: UInt16
    ) -> SemanticLayoutModifier? {
        guard let modifiers = record(identity)?.modifiers, Int(index) < modifiers.count
        else { return nil }
        return modifiers[Int(index)].1
    }

    func textScalarCount(of identity: Identity) -> UInt16? {
        record(identity)?.scalars.map { UInt16($0.count) }
    }

    func textScalar(of identity: Identity, at index: UInt16) -> UInt32? {
        guard let scalars = record(identity)?.scalars, Int(index) < scalars.count
        else { return nil }
        return scalars[Int(index)]
    }

    private func record(_ identity: Identity) -> LayoutRecord<Identity>? {
        records.first { $0.identity == identity }
    }
}

private struct RecordingLayoutView: CorpusLayoutView {
    let rootIdentity = RecordingIdentity(path: (1, 0, 0), token: .root)
    let records: [LayoutRecord<RecordingIdentity>]

    init() {
        let id: (CorpusToken, (UInt8, UInt8, UInt8)) -> RecordingIdentity = {
            RecordingIdentity(path: $1, token: $0)
        }
        records = canonicalRecords(
            root: id(.root, (1, 0, 0)),
            stack: id(.stack, (1, 4, 0)),
            padding: id(.stackPadding, (1, 4, 9)),
            proxy: id(.actionProxy, (1, 4, 1)),
            spacer: id(.spacer, (1, 4, 2)),
            text: id(.text, (1, 4, 3))
        )
    }
}

private struct DynamicLayoutView: CorpusLayoutView {
    let rootIdentity = DynamicIdentity(slot: 90, token: .root)
    let records: [LayoutRecord<DynamicIdentity>]

    init(omitFirstStackChild: Bool = false) {
        let stack = DynamicIdentity(slot: 41, token: .stack)
        records = canonicalRecords(
            root: rootIdentity,
            stack: stack,
            padding: DynamicIdentity(slot: 7, token: .stackPadding),
            proxy: DynamicIdentity(slot: 101, token: .actionProxy),
            spacer: DynamicIdentity(slot: 3, token: .spacer),
            text: DynamicIdentity(slot: 66, token: .text)
        ).map { record in
            guard omitFirstStackChild, record.identity == stack else { return record }
            return LayoutRecord(
                identity: record.identity,
                primitive: record.primitive,
                children: [DynamicIdentity(slot: 999, token: .actionProxy)]
                    + Array(record.children.dropFirst()),
                modifiers: record.modifiers,
                scalars: record.scalars
            )
        }
    }

    func child(of identity: DynamicIdentity, at index: UInt16) -> DynamicIdentity? {
        if identity == DynamicIdentity(slot: 41, token: .stack),
            records.first(where: { $0.identity == identity })?.children.first?.slot == 999,
            index == 0
        {
            return nil
        }
        guard let record = records.first(where: { $0.identity == identity }),
            Int(index) < record.children.count
        else { return nil }
        return record.children[Int(index)]
    }
}

private struct FixedLayoutView: SemanticLayoutView {
    let rootIdentity = FixedIdentity.root
    let scopeCount: UInt16 = 5

    func primitive(at identity: FixedIdentity) -> SemanticLayoutPrimitive? {
        switch identity {
        case .root, .stackPadding: nil
        case .stack: .vStack(alignment: .leading, spacing: 2)
        case .actionProxy: .proxy
        case .spacer: .spacer(minLength: 4)
        case .text: .text
        }
    }

    func childCount(of identity: FixedIdentity) -> UInt16? {
        switch identity {
        case .root: 1
        case .stack: 2
        case .actionProxy: 1
        case .stackPadding, .spacer, .text: 0
        }
    }

    func child(of identity: FixedIdentity, at index: UInt16) -> FixedIdentity? {
        switch (identity, index) {
        case (.root, 0): .stack
        case (.stack, 0): .actionProxy
        case (.stack, 1): .text
        case (.actionProxy, 0): .spacer
        default: nil
        }
    }

    func modifierCount(of identity: FixedIdentity) -> UInt16? {
        identity == .stack ? 1 : 0
    }

    func modifierScope(
        of identity: FixedIdentity,
        at index: UInt16
    ) -> FixedIdentity? {
        identity == .stack && index == 0 ? .stackPadding : nil
    }

    func modifier(
        of identity: FixedIdentity,
        at index: UInt16
    ) -> SemanticLayoutModifier? {
        identity == .stack && index == 0
            ? .padding(edges: .horizontal, length: 3) : nil
    }

    func textScalarCount(of identity: FixedIdentity) -> UInt16? {
        identity == .text ? 3 : nil
    }

    func textScalar(of identity: FixedIdentity, at index: UInt16) -> UInt32? {
        guard identity == .text else { return nil }
        return switch index {
        case 0: 0x41
        case 1: 0x0a
        case 2: 0x00b0
        default: nil
        }
    }
}

private func canonicalRecords<Identity>(
    root: Identity,
    stack: Identity,
    padding: Identity,
    proxy: Identity,
    spacer: Identity,
    text: Identity
) -> [LayoutRecord<Identity>] {
    [
        LayoutRecord(
            identity: root,
            primitive: nil,
            children: [stack],
            modifiers: [],
            scalars: nil
        ),
        LayoutRecord(
            identity: stack,
            primitive: .vStack(alignment: .leading, spacing: 2),
            children: [proxy, text],
            modifiers: [(padding, .padding(edges: .horizontal, length: 3))],
            scalars: nil
        ),
        LayoutRecord(
            identity: padding,
            primitive: nil,
            children: [],
            modifiers: [],
            scalars: nil
        ),
        LayoutRecord(
            identity: proxy,
            primitive: .proxy,
            children: [spacer],
            modifiers: [],
            scalars: nil
        ),
        LayoutRecord(
            identity: spacer,
            primitive: .spacer(minLength: 4),
            children: [],
            modifiers: [],
            scalars: nil
        ),
        LayoutRecord(
            identity: text,
            primitive: .text,
            children: [],
            modifiers: [],
            scalars: [0x41, 0x0a, 0x00b0]
        ),
    ]
}
