#if GIFTUI_DYNAMIC_PROFILE
    import GiftUI
    import Testing

    @testable import GiftUIDrawing
    @testable import GiftUISemanticCore

    @Test
    func semanticCanvasAdapterStagesAndInvokesTheExactRootOccurrence() throws {
        var invocationCount = 0
        var observedSize: Size?
        let root = Canvas { _, size in
            invocationCount += 1
            observedSize = size
        }
        var workspace = CanvasAdapterWorkspace()
        var sink = SemanticLayoutResultSink(storage: CanvasAdapterStorage(capacity: 1))

        let result = expandSemanticTree(
            root,
            limits: canvasAdapterLimits,
            workspace: &workspace,
            sink: &sink
        )

        guard case .success(let summary) = result else {
            Issue.record("Canvas semantic expansion must succeed: \(result)")
            return
        }
        let identity = sink.rootIdentity
        #expect(summary.semanticNodeCount == 1)
        #expect(summary.bodyEvaluationCount == 0)
        #expect(sink.primitive(at: identity) == .canvas)
        #expect(sink.childCount(of: identity) == 0)
        #expect(sink.child(of: identity, at: 0) == nil)
        #expect(sink.storage.canvasOccurrenceCount == 1)
        #expect(sink.storage.canvasIdentity(at: 0) == identity)
        #expect(sink.storage.canvasIdentity(at: 1) == nil)
        #expect(invocationCount == 0)

        let expectedSize = Size(width: 17, height: 23)!
        try withCanvasAdapterContext { context in
            try sink.storage.invokeCanvas(
                at: identity,
                context: &context,
                size: expectedSize
            )
        }

        #expect(invocationCount == 1)
        #expect(observedSize == expectedSize)
        sink.storage.releaseCanvas(at: identity)
        _ = withCanvasAdapterContext { context in
            #expect(throws: DrawingError.invariantViolation) {
                try sink.storage.invokeCanvas(
                    at: identity,
                    context: &context,
                    size: expectedSize
                )
            }
        }
    }

    @Test
    func semanticCanvasAdapterPreservesTraversalOrderAndCapacityAtomically() {
        var workspace = CanvasAdapterWorkspace()
        var sink = SemanticLayoutResultSink(storage: CanvasAdapterStorage(capacity: 2))

        let result = expandSemanticTree(
            CanvasPair(),
            limits: canvasAdapterLimits,
            workspace: &workspace,
            sink: &sink
        )

        guard case .success = result else {
            Issue.record("two-Canvas semantic expansion must succeed: \(result)")
            return
        }
        let first = sink.storage.canvasIdentity(at: 0)
        let second = sink.storage.canvasIdentity(at: 1)
        #expect(sink.storage.canvasOccurrenceCount == 2)
        #expect(first != nil)
        #expect(second != nil)
        #expect(first != second)
        #expect(sink.storage.canvasIdentity(at: 2) == nil)

        var refusingWorkspace = CanvasAdapterWorkspace()
        var refusingSink = SemanticLayoutResultSink(
            storage: CanvasAdapterStorage(capacity: 1)
        )
        let refusal = expandSemanticTree(
            CanvasPair(),
            limits: canvasAdapterLimits,
            workspace: &refusingWorkspace,
            sink: &refusingSink
        )
        #expect(
            refusal
                == SemanticExpansionResult.failure(.invariantViolation)
        )
        #expect(refusingSink.storage.canvasOccurrenceCount == 0)
    }

    private let canvasAdapterLimits = SemanticExpansionLimits(
        maximumDepth: 16,
        maximumSemanticNodes: 4,
        maximumBodyEvaluations: 2,
        maximumModifierApplications: 1,
        maximumActionOccurrences: 1
    )!

    private struct CanvasPair: View {
        var body: some View {
            VStack {
                Canvas { _, _ in }
                Canvas { _, _ in }
            }
        }
    }

    private struct CanvasAdapterIdentity: SemanticRecordingIdentity {
        let components: [SemanticRecordingPathComponent]
        let declarationRole: SemanticRecordingRole

        var componentCount: UInt16 { UInt16(components.count) }

        func component(at index: UInt16) -> SemanticRecordingPathComponent? {
            guard Int(index) < components.count else { return nil }
            return components[Int(index)]
        }

        func isPrefix(of other: Self) -> Bool {
            guard components.count <= other.components.count else { return false }
            return components.elementsEqual(other.components.prefix(components.count))
        }
    }

    private struct CanvasAdapterWorkspace: SemanticExpansionWorkspace {
        let maximumPathComponents: UInt16 = 16
        let maximumIdentities: UInt16 = 16
        var isExpanding = false
        private var path: [SemanticRecordingPathComponent] = []
        private var nextRole: UInt16 = 0

        mutating func beginExpansion() -> Bool {
            guard !isExpanding else { return false }
            isExpanding = true
            path.removeAll(keepingCapacity: true)
            nextRole = 0
            return true
        }

        mutating func enterRoot<Declaration: View>(
            _ declaration: Declaration.Type,
            identity: inout CanvasAdapterIdentity?
        ) -> SemanticExpansionError? {
            enter(.root, identity: &identity)
        }

        mutating func enterCustomBody<Declaration: View>(
            _ declaration: Declaration.Type,
            identity: inout CanvasAdapterIdentity?
        ) -> SemanticExpansionError? {
            enter(.customBody, identity: &identity)
        }

        mutating func enterFixedChild(
            _ index: UInt8,
            identity: inout CanvasAdapterIdentity?
        ) -> SemanticExpansionError? {
            enter(.fixedChild(index), identity: &identity)
        }

        mutating func enterConditionalBranch(
            _ index: UInt8,
            identity: inout CanvasAdapterIdentity?
        ) -> SemanticExpansionError? {
            enter(.conditionalBranch(index), identity: &identity)
        }

        mutating func enterOptionalPresence(
            identity: inout CanvasAdapterIdentity?
        ) -> SemanticExpansionError? {
            enter(.optionalPresence, identity: &identity)
        }

        mutating func enterDeclarationRole<Declaration>(
            _ declaration: Declaration.Type,
            identity: inout CanvasAdapterIdentity?
        ) -> SemanticExpansionError? {
            let role = SemanticRecordingRole(rawValue: nextRole)
            nextRole += 1
            return enter(.declarationRole(role), identity: &identity)
        }

        mutating func leavePathComponent() {
            _ = path.popLast()
        }

        mutating func completeExpansion() {}
        mutating func discardExpansion() {}

        mutating func resetExpansion() {
            path.removeAll(keepingCapacity: true)
            isExpanding = false
        }

        private mutating func enter(
            _ component: SemanticRecordingPathComponent,
            identity: inout CanvasAdapterIdentity?
        ) -> SemanticExpansionError? {
            path.append(component)
            let role =
                path.reversed().lazy.compactMap { component in
                    if case .declarationRole(let role) = component { return role }
                    return nil
                }.first ?? SemanticRecordingRole(rawValue: 0)
            identity = CanvasAdapterIdentity(
                components: path,
                declarationRole: role
            )
            return nil
        }
    }

    private struct StagedCanvas {
        let identity: CanvasAdapterIdentity
        var payload: Canvas?
    }

    private struct CanvasAdapterStorage: SemanticLayoutResultStorage,
        CanvasInvocationSource
    {
        let maximumStructuralOccurrences: UInt16 = 16
        let maximumBodyEvaluations: UInt16 = 2
        let maximumSemanticOccurrences: UInt16 = 4
        let maximumModifierApplications: UInt16 = 1
        let maximumActionOccurrences: UInt16 = 1
        let capacity: UInt16

        private var structural: [CanvasAdapterIdentity] = []
        private var canvases: [StagedCanvas] = []
        private var isPublished = false

        init(capacity: UInt16) {
            self.capacity = capacity
        }

        mutating func beginSemanticResult() -> Bool {
            structural.removeAll(keepingCapacity: true)
            canvases.removeAll(keepingCapacity: true)
            isPublished = false
            return true
        }

        mutating func stageStructuralOccurrence(
            identity: borrowing CanvasAdapterIdentity
        ) -> Bool {
            structural.append(copy identity)
            return true
        }

        mutating func stageBodyEvaluation(
            identity: borrowing CanvasAdapterIdentity
        ) -> Bool {
            true
        }

        mutating func stagePrimitive<Payload>(
            identity: borrowing CanvasAdapterIdentity,
            primitive: SemanticLayoutPrimitive,
            payload: borrowing Payload
        ) -> Bool where Payload: _GiftUISemanticPrimitivePayload {
            guard primitive == .canvas else { return true }
            guard canvasOccurrenceCount < capacity else { return false }
            let payloadCopy = copy payload
            guard let canvas = payloadCopy as? Canvas else { return false }
            canvases.append(StagedCanvas(identity: copy identity, payload: canvas))
            return true
        }

        mutating func stageModifier<Payload>(
            identity: borrowing CanvasAdapterIdentity,
            modifier: SemanticLayoutModifier,
            payload: borrowing Payload,
            chainIndex: UInt16
        ) -> Bool where Payload: _GiftUISemanticModifierPayload {
            true
        }

        mutating func stageActionOccurrence(
            identity: borrowing CanvasAdapterIdentity
        ) -> Bool {
            true
        }

        mutating func publishSemanticResult(
            _ summary: SemanticExpansionSummary
        ) -> Bool {
            isPublished = true
            return true
        }

        mutating func discardSemanticResult() {
            structural.removeAll(keepingCapacity: true)
            canvases.removeAll(keepingCapacity: true)
            isPublished = false
        }

        mutating func resetSemanticResult() {}

        var rootIdentity: CanvasAdapterIdentity {
            precondition(isPublished)
            return structural[0]
        }

        var scopeCount: UInt16 { UInt16(canvases.count) }

        func primitive(
            at identity: CanvasAdapterIdentity
        ) -> SemanticLayoutPrimitive? {
            canvases.contains { $0.identity == identity } ? .canvas : nil
        }

        func childCount(of identity: CanvasAdapterIdentity) -> UInt16? {
            structural.contains(identity) ? 0 : nil
        }

        func child(
            of identity: CanvasAdapterIdentity,
            at index: UInt16
        ) -> CanvasAdapterIdentity? {
            nil
        }

        func modifierCount(of identity: CanvasAdapterIdentity) -> UInt16? {
            structural.contains(identity) ? 0 : nil
        }

        func modifierScope(
            of identity: CanvasAdapterIdentity,
            at index: UInt16
        ) -> CanvasAdapterIdentity? {
            nil
        }

        func modifier(
            of identity: CanvasAdapterIdentity,
            at index: UInt16
        ) -> SemanticLayoutModifier? {
            nil
        }

        func textScalarCount(of identity: CanvasAdapterIdentity) -> UInt16? {
            nil
        }

        func textScalar(
            of identity: CanvasAdapterIdentity,
            at index: UInt16
        ) -> UInt32? {
            nil
        }

        var canvasOccurrenceCount: UInt16 { UInt16(canvases.count) }

        func canvasIdentity(at index: UInt16) -> CanvasAdapterIdentity? {
            guard Int(index) < canvases.count else { return nil }
            return canvases[Int(index)].identity
        }

        mutating func invokeCanvas(
            at identity: CanvasAdapterIdentity,
            context: inout GraphicsContext,
            size: Size
        ) throws(DrawingError) {
            guard let payload = canvases.first(where: { $0.identity == identity })?.payload
            else { throw DrawingError.invariantViolation }
            try payload._giftUIInvokeCanvas(context: &context, size: size)
        }

        mutating func releaseCanvas(at identity: CanvasAdapterIdentity) {
            guard let index = canvases.firstIndex(where: { $0.identity == identity }) else {
                return
            }
            canvases[index].payload = nil
        }
    }

    private struct CanvasAdapterContextStorage {}

    private let canvasAdapterOperations = _GiftUIDrawingOperations(
        beginPath: { _, _, _ in _GiftUIDrawingStatus.success.rawValue },
        endPath: { _, _, _ in _GiftUIDrawingStatus.success.rawValue },
        movePath: { _, _, _, _, _ in _GiftUIDrawingStatus.success.rawValue },
        addLineToPath: { _, _, _, _, _ in _GiftUIDrawingStatus.success.rawValue },
        strokePath: { _, _, _, _, _, _, _, _, _ in
            _GiftUIDrawingStatus.success.rawValue
        }
    )

    private func withCanvasAdapterContext<Result>(
        _ body: (inout GraphicsContext) throws -> Result
    ) rethrows -> Result {
        var storage = CanvasAdapterContextStorage()
        return try withUnsafeMutablePointer(to: &storage) { pointer in
            var context = GraphicsContext(
                storage: UnsafeMutableRawPointer(pointer),
                generation: 1,
                operations: canvasAdapterOperations
            )
            return try body(&context)
        }
    }
#endif
