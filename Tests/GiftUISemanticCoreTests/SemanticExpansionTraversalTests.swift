import GiftUI
import GiftUIObservableState
import XCTest

@testable import GiftUISemanticCore

final class SemanticExpansionTraversalTests: XCTestCase {
    func testButtonStagesOneActionAtItsIdentityBeforeStoredLabel() {
        var workspace = TraversalWorkspace()
        var sink = TraversalSink()
        let button = try! Button(action: TraversalAction.secondary) {
            TraversalPrimitive(marker: 9)
        }

        let result = expandStatelessSemanticTreeForTesting(
            button,
            limits: makeLimits(),
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(
            result,
            .success(
                SemanticExpansionSummary(
                    semanticNodeCount: 2,
                    bodyEvaluationCount: 0,
                    modifierApplicationCount: 0,
                    actionOccurrenceCount: 1,
                    maximumObservedDepth: 4
                )
            )
        )
        XCTAssertEqual(
            sink.committedEvents.map(\.kind),
            [.structural, .semantic, .action, .structural, .semantic]
        )
        XCTAssertEqual(sink.observedActions, [.secondary])
        XCTAssertEqual(
            sink.committedEvents[1].identity,
            sink.committedEvents[2].identity
        )
    }

    func testNestedDeclarationExpandsDepthFirstAndSkipsInactiveContent() {
        let bodyCounter = TraversalBodyCounter()
        var workspace = TraversalWorkspace()
        var sink = TraversalSink()

        let result = expandStatelessSemanticTreeForTesting(
            TraversalRoot(bodyCounter: bodyCounter),
            limits: makeLimits(),
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(
            result,
            .success(
                SemanticExpansionSummary(
                    semanticNodeCount: 2,
                    bodyEvaluationCount: 1,
                    modifierApplicationCount: 0,
                    actionOccurrenceCount: 0,
                    maximumObservedDepth: 9
                )
            )
        )
        XCTAssertEqual(bodyCounter.count, 1)
        XCTAssertEqual(
            sink.committedEvents.map(\.kind),
            [
                .structural,
                .structural,
                .structural,
                .semantic,
                .structural,
                .structural,
                .semantic,
                .structural,
            ]
        )
        XCTAssertEqual(sink.publishCount, 1)
        XCTAssertTrue(sink.stagedEvents.isEmpty)
        XCTAssertFalse(workspace.isExpanding)
    }

    func testActionNodePrecedesActionAndModifierChainUsesSourceOrder() {
        let root = TraversalModifier(
            content: TraversalModifier(
                content: TraversalActionPrimitive(action: .secondary),
                marker: 1
            ),
            marker: 2
        )
        var workspace = TraversalWorkspace()
        var sink = TraversalSink()

        let result = expandStatelessSemanticTreeForTesting(
            root,
            limits: makeLimits(),
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(
            result,
            .success(
                SemanticExpansionSummary(
                    semanticNodeCount: 1,
                    bodyEvaluationCount: 0,
                    modifierApplicationCount: 2,
                    actionOccurrenceCount: 1,
                    maximumObservedDepth: 4
                )
            )
        )
        XCTAssertEqual(
            sink.committedEvents.map(\.kind),
            [.structural, .structural, .structural, .semantic, .action, .modifier, .modifier]
        )
        XCTAssertEqual(
            sink.committedEvents.compactMap(\.modifierIndex),
            [0, 1]
        )
        XCTAssertEqual(sink.observedActions, [.secondary])
    }

    func testSiblingModifierChainsDoNotInterleave() {
        let root = ViewBuilder.buildBlock(
            TraversalModifier(
                content: TraversalModifier(
                    content: TraversalPrimitive(marker: 1),
                    marker: 1
                ),
                marker: 2
            ),
            TraversalModifier(
                content: TraversalPrimitive(marker: 2),
                marker: 3
            )
        )
        var workspace = TraversalWorkspace()
        var sink = TraversalSink()

        let result = expandStatelessSemanticTreeForTesting(
            root,
            limits: makeLimits(),
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(
            result,
            .success(
                SemanticExpansionSummary(
                    semanticNodeCount: 2,
                    bodyEvaluationCount: 0,
                    modifierApplicationCount: 3,
                    actionOccurrenceCount: 0,
                    maximumObservedDepth: 6
                )
            )
        )
        XCTAssertEqual(
            sink.committedEvents.compactMap(\.modifierIndex),
            [0, 1, 0]
        )
    }

    func testBodyLimitStopsBeforeTheRejectedBodyAndPublishesNothing() {
        let outerCounter = TraversalBodyCounter()
        let innerCounter = TraversalBodyCounter()
        let root = TraversalNestedCustom(
            bodyCounter: outerCounter,
            child: TraversalLeafCustom(bodyCounter: innerCounter)
        )
        var workspace = TraversalWorkspace()
        var sink = TraversalSink()
        let limits = SemanticExpansionLimits(
            maximumDepth: 8,
            maximumSemanticNodes: 4,
            maximumBodyEvaluations: 1,
            maximumModifierApplications: 4,
            maximumActionOccurrences: 4
        )!

        let result = expandStatelessSemanticTreeForTesting(
            root,
            limits: limits,
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(result, .failure(.capacityExhausted))
        XCTAssertEqual(outerCounter.count, 1)
        XCTAssertEqual(innerCounter.count, 0)
        XCTAssertTrue(sink.committedEvents.isEmpty)
        XCTAssertTrue(sink.stagedEvents.isEmpty)
        XCTAssertEqual(sink.publishCount, 0)
        XCTAssertEqual(sink.discardCount, 1)
        XCTAssertFalse(workspace.isExpanding)
    }

    func testWorkspacePathCapacityFailsBeforeTheNextEntry() {
        var workspace = TraversalWorkspace(maximumPathComponents: 1)
        var sink = TraversalSink()

        let result = expandStatelessSemanticTreeForTesting(
            ViewBuilder.buildBlock(),
            limits: makeLimits(),
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(result, .failure(.capacityExhausted))
        XCTAssertEqual(workspace.enterCount, 1)
        XCTAssertTrue(sink.committedEvents.isEmpty)
        XCTAssertTrue(sink.stagedEvents.isEmpty)
    }

    func testMissingAndMultipleVisitorCategoriesFailAtomically() {
        assertInvariantFailure(TraversalNoCategory())
        assertInvariantFailure(TraversalMultipleCategory())
    }

    func testDetectableNeverBodyFailsWithoutEvaluatingIt() {
        let bodyCounter = TraversalBodyCounter()
        var workspace = TraversalWorkspace()
        var sink = TraversalSink()

        let result = expandStatelessSemanticTreeForTesting(
            TraversalNeverBody(bodyCounter: bodyCounter),
            limits: makeLimits(),
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(result, .failure(.invariantViolation))
        XCTAssertEqual(bodyCounter.count, 0)
        XCTAssertTrue(sink.committedEvents.isEmpty)
        XCTAssertTrue(sink.stagedEvents.isEmpty)
        XCTAssertEqual(sink.publishCount, 0)
        XCTAssertEqual(sink.discardCount, 1)
        XCTAssertFalse(workspace.isExpanding)
    }

    func testStatefulDecoratorBindsLexicallyBeforeUnchangedSemanticTraversal() {
        let trace = TraversalBindingTrace()
        let root = TraversalStatefulRoot(trace: trace)
        var statefulWorkspace = TraversalWorkspace()
        var statefulSink = TraversalSink()
        let binding = TraversalTestBinding(trace: trace)

        let statefulResult = expandSemanticTreeWithStateBinding(
            root,
            limits: makeLimits(),
            workspace: &statefulWorkspace,
            sink: &statefulSink,
            stateBinding: binding
        )

        var ordinaryWorkspace = TraversalWorkspace()
        var ordinarySink = TraversalSink()
        let ordinaryResult = expandStatelessSemanticTreeForTesting(
            TraversalOrdinaryBoundEquivalent(),
            limits: makeLimits(),
            workspace: &ordinaryWorkspace,
            sink: &ordinarySink
        )

        XCTAssertEqual(
            statefulResult,
            .success(
                SemanticExpansionSummary(
                    semanticNodeCount: 1,
                    bodyEvaluationCount: 1,
                    modifierApplicationCount: 0,
                    actionOccurrenceCount: 0,
                    maximumObservedDepth: 4
                )
            )
        )
        XCTAssertEqual(
            ordinaryResult,
            .success(
                SemanticExpansionSummary(
                    semanticNodeCount: 1,
                    bodyEvaluationCount: 1,
                    modifierApplicationCount: 0,
                    actionOccurrenceCount: 0,
                    maximumObservedDepth: 4
                )
            )
        )
        XCTAssertEqual(trace.events, ["bind:0", "bind:1", "body"])
        XCTAssertEqual(trace.ordinals, [0, 1])
        XCTAssertEqual(trace.bodyValues, [8])
        XCTAssertEqual(
            statefulSink.committedEvents.map(\.kind),
            ordinarySink.committedEvents.map(\.kind)
        )
        XCTAssertEqual(statefulSink.publishCount, 1)
        XCTAssertTrue(statefulSink.stagedEvents.isEmpty)
    }

    func testEveryStateBindingFailureSuppressesBodyAndSemanticPublication() {
        let errors: [ObservableStateError] = [
            .locationCapacityExhausted,
            .registrationCapacityExhausted,
            .associationStagingCapacityExhausted,
            .replacementStagingCapacityExhausted,
            .registrationGenerationExhausted,
            .duplicateOwner,
            .incompatibleAssociation,
            .staleAttachment,
            .invalidPhaseContained,
            .invalidPhaseSafetyNotProven,
            .reentrancyViolation,
            .invariantViolation,
        ]

        for (index, error) in errors.enumerated() {
            let trace = TraversalBindingTrace()
            var workspace = TraversalWorkspace()
            var sink = TraversalSink()
            let failureOrdinal = UInt16(index % 2)
            let binding = TraversalTestBinding(
                trace: trace,
                failure: error,
                failureOrdinal: failureOrdinal
            )

            let result = expandSemanticTreeWithStateBinding(
                TraversalStatefulRoot(trace: trace),
                limits: makeLimits(),
                workspace: &workspace,
                sink: &sink,
                stateBinding: binding
            )

            XCTAssertEqual(result, .bindingFailure(error))
            XCTAssertEqual(trace.events.last, "fail:\(failureOrdinal)")
            XCTAssertFalse(trace.events.contains("body"))
            XCTAssertEqual(sink.bodyEvaluationStageCount, 0)
            XCTAssertTrue(sink.committedEvents.isEmpty)
            XCTAssertTrue(sink.stagedEvents.isEmpty)
            XCTAssertEqual(sink.publishCount, 0)
            XCTAssertEqual(sink.discardCount, 1)
            XCTAssertFalse(workspace.isExpanding)
        }
    }

    func testPrimitiveContainerStagesBeforeEmptyOneAndFiveChildContent() {
        let emptyBodyCounter = TraversalBodyCounter()
        var emptyWorkspace = TraversalWorkspace()
        var emptySink = TraversalSink()
        let emptyResult = expandStatelessSemanticTreeForTesting(
            TraversalPrimitiveContainer(marker: 10, bodyCounter: emptyBodyCounter) {},
            limits: makeLimits(),
            workspace: &emptyWorkspace,
            sink: &emptySink
        )

        XCTAssertEqual(emptyResult.successSummary?.semanticNodeCount, 1)
        XCTAssertEqual(
            emptySink.committedEvents.map(\.kind), [.structural, .semantic, .structural])
        XCTAssertEqual(emptyBodyCounter.count, 0)

        let oneBodyCounter = TraversalBodyCounter()
        var oneWorkspace = TraversalWorkspace()
        var oneSink = TraversalSink()
        let oneResult = expandStatelessSemanticTreeForTesting(
            TraversalPrimitiveContainer(marker: 20, bodyCounter: oneBodyCounter) {
                TraversalPrimitive(marker: 21)
            },
            limits: makeLimits(),
            workspace: &oneWorkspace,
            sink: &oneSink
        )

        XCTAssertEqual(oneResult.successSummary?.semanticNodeCount, 2)
        XCTAssertEqual(
            oneSink.committedEvents.map(\.kind),
            [.structural, .semantic, .structural, .semantic]
        )
        XCTAssertEqual(
            oneSink.committedEvents.filter { $0.kind == .semantic }.map(\.identity.path),
            [
                [.root, .declarationRole(0)],
                [.root, .declarationRole(0), .fixedChild(0), .declarationRole(1)],
            ]
        )
        XCTAssertEqual(oneBodyCounter.count, 0)

        let fiveBodyCounter = TraversalBodyCounter()
        var fiveWorkspace = TraversalWorkspace()
        var fiveSink = TraversalSink()
        let fiveResult = expandStatelessSemanticTreeForTesting(
            TraversalPrimitiveContainer(marker: 30, bodyCounter: fiveBodyCounter) {
                TraversalPrimitive(marker: 31)
                TraversalPrimitive(marker: 32)
                TraversalPrimitive(marker: 33)
                TraversalPrimitive(marker: 34)
                TraversalPrimitive(marker: 35)
            },
            limits: makeLimits(),
            workspace: &fiveWorkspace,
            sink: &fiveSink
        )

        XCTAssertEqual(fiveResult.successSummary?.semanticNodeCount, 6)
        XCTAssertEqual(fiveSink.committedEvents.first?.kind, .structural)
        XCTAssertEqual(fiveSink.committedEvents.dropFirst().first?.kind, .semantic)
        XCTAssertEqual(
            fiveSink.committedEvents.filter { $0.kind == .semantic }.count,
            6
        )
        XCTAssertEqual(
            fiveSink.committedEvents.filter { $0.kind == .semantic }.dropFirst().compactMap {
                $0.identity.path.firstFixedChildAfterContent
            },
            [0, 1, 2, 3, 4]
        )
        XCTAssertEqual(fiveBodyCounter.count, 0)
    }

    func testPrimitiveContainerUsesOrdinaryNestedConditionalOptionalAndModifierTraversal() {
        let bodyCounter = TraversalBodyCounter()
        let conditional: ConditionalContent<TraversalInactiveTrap, TraversalPrimitive> =
            ViewBuilder.buildEither(second: TraversalPrimitive(marker: 42))
        let optional = ViewBuilder.buildOptional(TraversalPrimitive(marker: 43))
        var workspace = TraversalWorkspace()
        var sink = TraversalSink()

        let result = expandStatelessSemanticTreeForTesting(
            TraversalPrimitiveContainer(marker: 40, bodyCounter: bodyCounter) {
                TraversalPrimitiveContainer(marker: 41, bodyCounter: bodyCounter) {
                    TraversalPrimitive(marker: 44)
                }
                conditional
                optional
                TraversalModifier(content: TraversalPrimitive(marker: 45), marker: 1)
            },
            limits: makeLimits(),
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(result.successSummary?.semanticNodeCount, 6)
        XCTAssertEqual(result.successSummary?.modifierApplicationCount, 1)
        XCTAssertEqual(bodyCounter.count, 0)
        XCTAssertEqual(sink.publishCount, 1)
        XCTAssertEqual(sink.discardCount, 0)
        XCTAssertTrue(sink.stagedEvents.isEmpty)
        XCTAssertTrue(
            sink.committedEvents.contains {
                $0.identity.path.contains(.conditionalBranch(1))
            }
        )
        XCTAssertTrue(
            sink.committedEvents.contains {
                $0.identity.path.contains(.optionalPresence)
            }
        )
        XCTAssertEqual(sink.committedEvents.compactMap(\.modifierIndex), [0])
    }

    func testPrimitiveContainerFailureIsAtomicAndObjectsAreReusable() {
        let bodyCounter = TraversalBodyCounter()
        let root = TraversalPrimitiveContainer(marker: 50, bodyCounter: bodyCounter) {
            TraversalPrimitive(marker: 51)
        }

        for refusal in 0 ... 1 {
            var workspace = TraversalWorkspace()
            var sink = TraversalSink(refusedSemanticStage: refusal)

            let failure = expandStatelessSemanticTreeForTesting(
                root,
                limits: makeLimits(),
                workspace: &workspace,
                sink: &sink
            )

            XCTAssertEqual(failure, .failure(.invariantViolation))
            XCTAssertTrue(sink.committedEvents.isEmpty)
            XCTAssertTrue(sink.stagedEvents.isEmpty)
            XCTAssertEqual(sink.publishCount, 0)
            XCTAssertEqual(sink.discardCount, 1)
            XCTAssertFalse(workspace.isExpanding)
            XCTAssertEqual(bodyCounter.count, 0)

            sink.refusedSemanticStage = nil
            let success = expandStatelessSemanticTreeForTesting(
                root,
                limits: makeLimits(),
                workspace: &workspace,
                sink: &sink
            )

            XCTAssertEqual(success.successSummary?.semanticNodeCount, 2)
            XCTAssertEqual(sink.publishCount, 1)
            XCTAssertEqual(sink.discardCount, 1)
            XCTAssertFalse(workspace.isExpanding)
            XCTAssertEqual(bodyCounter.count, 0)
        }

        var capacityWorkspace = TraversalWorkspace()
        var capacitySink = TraversalSink()
        let capacityLimits = SemanticExpansionLimits(
            maximumDepth: 16,
            maximumSemanticNodes: 1,
            maximumBodyEvaluations: 16,
            maximumModifierApplications: 16,
            maximumActionOccurrences: 16
        )!

        let capacityFailure = expandStatelessSemanticTreeForTesting(
            root,
            limits: capacityLimits,
            workspace: &capacityWorkspace,
            sink: &capacitySink
        )

        XCTAssertEqual(capacityFailure, .failure(.capacityExhausted))
        XCTAssertTrue(capacitySink.committedEvents.isEmpty)
        XCTAssertTrue(capacitySink.stagedEvents.isEmpty)
        XCTAssertEqual(capacitySink.publishCount, 0)
        XCTAssertEqual(capacitySink.discardCount, 1)
        XCTAssertFalse(capacityWorkspace.isExpanding)
        XCTAssertEqual(bodyCounter.count, 0)
    }

    func testActionContainerStagesBeforeEmptyOneAndFiveChildContent() {
        let emptyBodyCounter = TraversalBodyCounter()
        var emptyWorkspace = TraversalWorkspace()
        var emptySink = TraversalSink()
        let emptyResult = expandStatelessSemanticTreeForTesting(
            TraversalActionContainer(action: .primary, bodyCounter: emptyBodyCounter) {},
            limits: makeLimits(),
            workspace: &emptyWorkspace,
            sink: &emptySink
        )

        XCTAssertEqual(emptyResult.successSummary?.semanticNodeCount, 1)
        XCTAssertEqual(emptyResult.successSummary?.actionOccurrenceCount, 1)
        XCTAssertEqual(
            emptySink.committedEvents.map(\.kind),
            [.structural, .semantic, .action, .structural]
        )
        XCTAssertEqual(emptySink.observedActions, [.primary])
        XCTAssertEqual(emptyBodyCounter.count, 0)

        let oneBodyCounter = TraversalBodyCounter()
        var oneWorkspace = TraversalWorkspace()
        var oneSink = TraversalSink()
        let oneResult = expandStatelessSemanticTreeForTesting(
            TraversalActionContainer(action: .secondary, bodyCounter: oneBodyCounter) {
                TraversalPrimitive(marker: 61)
            },
            limits: makeLimits(),
            workspace: &oneWorkspace,
            sink: &oneSink
        )

        XCTAssertEqual(oneResult.successSummary?.semanticNodeCount, 2)
        XCTAssertEqual(oneResult.successSummary?.actionOccurrenceCount, 1)
        XCTAssertEqual(
            oneSink.committedEvents.map(\.kind),
            [.structural, .semantic, .action, .structural, .semantic]
        )
        XCTAssertEqual(
            oneSink.committedEvents.filter { $0.kind == .action }.map(\.identity.path),
            [[.root, .declarationRole(0)]]
        )
        XCTAssertEqual(
            oneSink.committedEvents.filter { $0.kind == .semantic }.last?.identity.path,
            [.root, .declarationRole(0), .fixedChild(0), .declarationRole(1)]
        )
        XCTAssertEqual(oneBodyCounter.count, 0)

        let fiveBodyCounter = TraversalBodyCounter()
        var fiveWorkspace = TraversalWorkspace()
        var fiveSink = TraversalSink()
        let fiveResult = expandStatelessSemanticTreeForTesting(
            TraversalActionContainer(action: .primary, bodyCounter: fiveBodyCounter) {
                TraversalPrimitive(marker: 62)
                TraversalPrimitive(marker: 63)
                TraversalPrimitive(marker: 64)
                TraversalPrimitive(marker: 65)
                TraversalPrimitive(marker: 66)
            },
            limits: makeLimits(),
            workspace: &fiveWorkspace,
            sink: &fiveSink
        )

        XCTAssertEqual(fiveResult.successSummary?.semanticNodeCount, 6)
        XCTAssertEqual(fiveResult.successSummary?.actionOccurrenceCount, 1)
        XCTAssertEqual(fiveSink.committedEvents.filter { $0.kind == .action }.count, 1)
        XCTAssertEqual(
            fiveSink.committedEvents.filter { $0.kind == .semantic }.dropFirst().compactMap {
                $0.identity.path.firstFixedChildAfterContent
            },
            [0, 1, 2, 3, 4]
        )
        XCTAssertEqual(fiveBodyCounter.count, 0)
    }

    func testActionContainerUsesOrdinaryNestedConditionalOptionalAndModifierTraversal() {
        let bodyCounter = TraversalBodyCounter()
        let conditional: ConditionalContent<TraversalInactiveTrap, TraversalPrimitive> =
            ViewBuilder.buildEither(second: TraversalPrimitive(marker: 72))
        let optional = ViewBuilder.buildOptional(TraversalPrimitive(marker: 73))
        var workspace = TraversalWorkspace()
        var sink = TraversalSink()

        let result = expandStatelessSemanticTreeForTesting(
            TraversalActionContainer(action: .primary, bodyCounter: bodyCounter) {
                TraversalActionContainer(action: .secondary, bodyCounter: bodyCounter) {
                    TraversalPrimitive(marker: 71)
                }
                conditional
                optional
                TraversalModifier(content: TraversalPrimitive(marker: 74), marker: 2)
            },
            limits: makeLimits(),
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(result.successSummary?.semanticNodeCount, 6)
        XCTAssertEqual(result.successSummary?.actionOccurrenceCount, 2)
        XCTAssertEqual(result.successSummary?.modifierApplicationCount, 1)
        XCTAssertEqual(sink.observedActions, [.primary, .secondary])
        XCTAssertEqual(sink.committedEvents.filter { $0.kind == .action }.count, 2)
        XCTAssertTrue(
            sink.committedEvents.contains {
                $0.identity.path.contains(.conditionalBranch(1))
            }
        )
        XCTAssertTrue(
            sink.committedEvents.contains {
                $0.identity.path.contains(.optionalPresence)
            }
        )
        XCTAssertEqual(sink.committedEvents.compactMap(\.modifierIndex), [0])
        XCTAssertEqual(bodyCounter.count, 0)
    }

    func testActionContainerFailureIsAtomicAndObjectsAreReusable() {
        let bodyCounter = TraversalBodyCounter()
        let root = TraversalActionContainer(action: .primary, bodyCounter: bodyCounter) {
            TraversalPrimitive(marker: 81)
        }

        for sink in [
            TraversalSink(refuseActionStage: true),
            TraversalSink(refusedSemanticStage: 0),
        ] {
            var workspace = TraversalWorkspace()
            var sink = sink

            let failure = expandStatelessSemanticTreeForTesting(
                root,
                limits: makeLimits(),
                workspace: &workspace,
                sink: &sink
            )

            XCTAssertEqual(failure, .failure(.invariantViolation))
            XCTAssertTrue(sink.committedEvents.isEmpty)
            XCTAssertTrue(sink.stagedEvents.isEmpty)
            XCTAssertEqual(sink.publishCount, 0)
            XCTAssertEqual(sink.discardCount, 1)
            XCTAssertFalse(workspace.isExpanding)
            XCTAssertEqual(bodyCounter.count, 0)

            sink.refuseActionStage = false
            sink.refusedSemanticStage = nil
            let success = expandStatelessSemanticTreeForTesting(
                root,
                limits: makeLimits(),
                workspace: &workspace,
                sink: &sink
            )

            XCTAssertEqual(success.successSummary?.semanticNodeCount, 2)
            XCTAssertEqual(success.successSummary?.actionOccurrenceCount, 1)
            XCTAssertEqual(sink.publishCount, 1)
            XCTAssertEqual(sink.discardCount, 1)
            XCTAssertFalse(workspace.isExpanding)
        }

        var capacityWorkspace = TraversalWorkspace()
        var capacitySink = TraversalSink()
        let capacityLimits = SemanticExpansionLimits(
            maximumDepth: 16,
            maximumSemanticNodes: 1,
            maximumBodyEvaluations: 16,
            maximumModifierApplications: 16,
            maximumActionOccurrences: 1
        )!

        let capacityFailure = expandStatelessSemanticTreeForTesting(
            root,
            limits: capacityLimits,
            workspace: &capacityWorkspace,
            sink: &capacitySink
        )

        XCTAssertEqual(capacityFailure, .failure(.capacityExhausted))
        XCTAssertTrue(capacitySink.committedEvents.isEmpty)
        XCTAssertTrue(capacitySink.stagedEvents.isEmpty)
        XCTAssertEqual(capacitySink.publishCount, 0)
        XCTAssertEqual(capacitySink.discardCount, 1)
        XCTAssertFalse(capacityWorkspace.isExpanding)
        XCTAssertEqual(bodyCounter.count, 0)
    }

    private func makeLimits() -> SemanticExpansionLimits {
        SemanticExpansionLimits(
            maximumDepth: 16,
            maximumSemanticNodes: 16,
            maximumBodyEvaluations: 16,
            maximumModifierApplications: 16,
            maximumActionOccurrences: 16
        )!
    }

    private func assertInvariantFailure<Content: View>(
        _ content: Content,
        file: StaticString = #filePath,
        line: UInt = #line
    ) where Content.Domain == _GiftUIEmptyReadDomain {
        var workspace = TraversalWorkspace()
        var sink = TraversalSink()
        let result = expandStatelessSemanticTreeForTesting(
            content,
            limits: makeLimits(),
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(result, .failure(.invariantViolation), file: file, line: line)
        XCTAssertTrue(sink.committedEvents.isEmpty, file: file, line: line)
        XCTAssertTrue(sink.stagedEvents.isEmpty, file: file, line: line)
        XCTAssertEqual(sink.publishCount, 0, file: file, line: line)
        XCTAssertEqual(sink.discardCount, 1, file: file, line: line)
        XCTAssertFalse(workspace.isExpanding, file: file, line: line)
    }
}

private final class TraversalBoundModel: _GiftUIObservableReference {
    let value: UInt8

    init(value: UInt8) {
        self.value = value
    }

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}

private enum TraversalBoundModelSchema: _GiftUIModelSchema {
    typealias Seed = TraversalBoundModel
}

private final class TraversalBoundModelBox<Model> {
    var model: Model?
}

private final class TraversalBindingTrace {
    var events: [String] = []
    var ordinals: [UInt16] = []
    var bodyValues: [UInt8] = []
}

@ObservableStateHost
private struct TraversalStatefulRoot: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = TraversalPrimitive

    @State<TraversalBoundModelSchema> private var first: _GiftUIModelKey<TraversalBoundModelSchema>?
    @State<TraversalBoundModelSchema> private var second:
        _GiftUIModelKey<TraversalBoundModelSchema>?
    let trace: TraversalBindingTrace

    init(trace: TraversalBindingTrace) {
        self.trace = trace
        _first = State<TraversalBoundModelSchema>(seed: TraversalBoundModel(value: 3))
        _second = State<TraversalBoundModelSchema>(seed: TraversalBoundModel(value: 5))
    }

    func _giftUIEvaluate(
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(_GiftUIAccessFailure) -> TraversalPrimitive {
        trace.events.append("body")
        let firstKey = try _first._giftUIKey()
        let secondKey = try _second._giftUIKey()
        guard firstKey._giftUISlot == 0, secondKey._giftUISlot == 1 else {
            throw .wrongOwner
        }
        let value = read.slots[0] + read.slots[1]
        trace.bodyValues.append(value)
        return TraversalPrimitive(marker: value)
    }
}

private struct TraversalOrdinaryBoundEquivalent: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = TraversalPrimitive

    func _giftUIEvaluate(
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(_GiftUIAccessFailure) -> TraversalPrimitive {
        TraversalPrimitive(marker: 8)
    }
}

private struct TraversalDeclarationVisitor: _GiftUIObservableStateDeclarationVisitor {
    let trace: TraversalBindingTrace
    let failure: ObservableStateError?
    let failureOrdinal: UInt16?
    var readSlots: InlineArray<2, UInt8> = .init(repeating: 0)
    var failed = false

    mutating func visit<Schema: _GiftUIModelSchema>(
        _ state: inout State<Schema>,
        declarationOrdinal: UInt16
    ) {
        guard !failed else { return }
        trace.events.append("bind:\(declarationOrdinal)")
        trace.ordinals.append(declarationOrdinal)
        if failureOrdinal == declarationOrdinal, failure != nil {
            trace.events.append("fail:\(declarationOrdinal)")
            failed = true
            return
        }
        guard
            declarationOrdinal < 2,
            let initial = state._giftUIInitial,
            case .seed(let seed) = initial,
            let model = seed as? TraversalBoundModel
        else {
            failed = true
            return
        }
        let key = _GiftUIModelKey<Schema>(
            ownerInstance: 1,
            allocationGeneration: 1,
            slot: declarationOrdinal
        )
        let binding = _GiftUIBoundState(
            locationSlot: declarationOrdinal,
            declarationOrdinal: declarationOrdinal,
            registrationGeneration: 1,
            key: key
        )
        guard state._giftUIBind(binding) != nil else {
            failed = true
            return
        }
        readSlots[Int(declarationOrdinal)] = model.value
    }
}

private struct TraversalTestBinding: SemanticStatefulBinding {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Identity = TraversalIdentity
    typealias Failure = ObservableStateError

    let trace: TraversalBindingTrace
    var failure: ObservableStateError? = nil
    var failureOrdinal: UInt16? = nil

    borrowing func evaluate<Declaration: View>(
        _ declaration: borrowing Declaration,
        beforeBody: () -> SemanticExpansionError?,
        body: (borrowing _GiftUIFrameRead<Domain>) throws(_GiftUIAccessFailure) -> Declaration.Body
    ) -> SemanticBodyEvaluation<Declaration.Body, Failure>
    where Declaration.Domain == Domain, Declaration.Body.Domain == Domain {
        if let error = beforeBody() { return .semanticFailure(error) }
        do throws(_GiftUIAccessFailure) {
            return .body(try body(_GiftUIFrameRead<Domain>(slots: Span<UInt8>())))
        } catch {
            return .accessFailure(error)
        }
    }

    borrowing func evaluateStateful<Declaration: View & _GiftUIObservableStateHost>(
        _ declaration: borrowing Declaration,
        structuralIdentity: Identity,
        beforeBody: () -> SemanticExpansionError?,
        body: (borrowing Declaration, borrowing _GiftUIFrameRead<Domain>)
            throws(_GiftUIAccessFailure) -> Declaration.Body
    ) -> SemanticBodyEvaluation<Declaration.Body, Failure>
    where Declaration.Domain == Domain, Declaration.Body.Domain == Domain {
        var copy = copy declaration
        var visitor = TraversalDeclarationVisitor(
            trace: trace, failure: failure, failureOrdinal: failureOrdinal)
        copy._giftUIVisitObservableStateDeclarations(&visitor)
        if visitor.failed, let failure { return .bindingFailure(failure) }
        if visitor.failed { return .bindingFailure(.invariantViolation) }
        if let error = beforeBody() { return .semanticFailure(error) }
        do throws(_GiftUIAccessFailure) {
            return .body(
                try body(copy, _GiftUIFrameRead<Domain>(slots: visitor.readSlots.span))
            )
        } catch {
            return .accessFailure(error)
        }
    }
}

private final class TraversalBodyCounter {
    var count = 0
}

private struct TraversalRoot: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = TupleView3<
        TraversalPrimitive,
        ConditionalContent<TraversalInactiveTrap, TraversalPrimitive>,
        OptionalContent<TraversalInactiveTrap>
    >

    let bodyCounter: TraversalBodyCounter

    func _giftUIEvaluate(
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(_GiftUIAccessFailure) -> Body {
        bodyCounter.count += 1
        let conditional: ConditionalContent<TraversalInactiveTrap, TraversalPrimitive> =
            ViewBuilder.buildEither(second: TraversalPrimitive(marker: 2))
        let optional = ViewBuilder.buildOptional(nil as TraversalInactiveTrap?)
        return ViewBuilder.buildBlock(
            TraversalPrimitive(marker: 1),
            conditional,
            optional
        )
    }
}

private struct TraversalInactiveTrap: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    init() {
        fatalError("inactive traversal content must not initialize")
    }

    func _giftUIEvaluate(
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(_GiftUIAccessFailure) -> Never {
        fatalError("inactive traversal content must not evaluate")
    }
}

private struct TraversalNestedCustom<Child: View>: View
where Child.Domain == _GiftUIEmptyReadDomain {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Child

    let bodyCounter: TraversalBodyCounter
    let child: Child

    func _giftUIEvaluate(
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(_GiftUIAccessFailure) -> Child {
        bodyCounter.count += 1
        return child
    }
}

private struct TraversalLeafCustom: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = TraversalPrimitive

    let bodyCounter: TraversalBodyCounter

    func _giftUIEvaluate(
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(_GiftUIAccessFailure) -> TraversalPrimitive {
        bodyCounter.count += 1
        return TraversalPrimitive(marker: 1)
    }
}

private struct TraversalPrimitive: View, _GiftUISemanticPrimitivePayload {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    let marker: UInt8

    func _giftUIEvaluate(
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(_GiftUIAccessFailure) -> Never {
        fatalError("primitive bodies are unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitPrimitive(self)
    }
}

private struct TraversalPrimitiveContainer<Content: View>: View {
    typealias Domain = Content.Domain

    typealias Body = Never

    let marker: UInt8
    let bodyCounter: TraversalBodyCounter
    let content: Content

    init(
        marker: UInt8,
        bodyCounter: TraversalBodyCounter,
        @ViewBuilder content: () -> Content
    ) {
        self.marker = marker
        self.bodyCounter = bodyCounter
        self.content = content()
    }

    func _giftUIEvaluate(
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(_GiftUIAccessFailure) -> Never {
        poison()
    }

    private func poison() -> Never {
        bodyCounter.count += 1
        fatalError("primitive container bodies are unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitPrimitive(
            content: content,
            payload: TraversalPrimitiveContainerPayload(marker: marker)
        )
    }
}

private struct TraversalPrimitiveContainerPayload: _GiftUISemanticPrimitivePayload {
    let marker: UInt8
}

private struct TraversalNoCategory: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    func _giftUIEvaluate(
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(_GiftUIAccessFailure) -> Never { fatalError("missing-category body is unreachable") }
    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {}
}

private struct TraversalMultipleCategory: View, _GiftUISemanticPrimitivePayload {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    func _giftUIEvaluate(
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(_GiftUIAccessFailure) -> Never { fatalError("multiple-category body is unreachable") }
    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitPrimitive(self)
        visitor.visitPrimitive(self)
    }
}

private struct TraversalNeverBody: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    let bodyCounter: TraversalBodyCounter
    func _giftUIEvaluate(
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(_GiftUIAccessFailure) -> Never { poison() }
    private func poison() -> Never {
        bodyCounter.count += 1
        fatalError("detectable Never.body must not run")
    }
    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitCustomView(self) { _ in poison() }
    }
}

private enum TraversalAction: UInt16, GiftUIAction {
    case primary = 1
    case secondary = 2
}

private struct TraversalActionPrimitive: View, _GiftUISemanticActionPayload {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    let action: TraversalAction

    var _giftUIAction: TraversalAction { action }

    func _giftUIEvaluate(
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(_GiftUIAccessFailure) -> Never {
        fatalError("action primitive bodies are unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitActionPrimitive(self)
    }
}

private struct TraversalActionContainer<Content: View>: View {
    typealias Domain = Content.Domain

    typealias Body = Never

    let action: TraversalAction
    let bodyCounter: TraversalBodyCounter
    let content: Content

    init(
        action: TraversalAction,
        bodyCounter: TraversalBodyCounter,
        @ViewBuilder content: () -> Content
    ) {
        self.action = action
        self.bodyCounter = bodyCounter
        self.content = content()
    }

    func _giftUIEvaluate(
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(_GiftUIAccessFailure) -> Never {
        poison()
    }

    private func poison() -> Never {
        bodyCounter.count += 1
        fatalError("action primitive container bodies are unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitActionPrimitive(
            content: content,
            payload: TraversalActionContainerPayload(action: action)
        )
    }
}

private struct TraversalActionContainerPayload: _GiftUISemanticActionPayload {
    let action: TraversalAction

    var _giftUIAction: TraversalAction { action }
}

private struct TraversalModifier<Content: View>: View, _GiftUISemanticModifierPayload {
    typealias Domain = Content.Domain
    typealias Body = EmptyView<Domain>

    let content: Content
    let marker: UInt8

    func _giftUIEvaluate(
        read: borrowing _GiftUIFrameRead<Domain>
    ) throws(_GiftUIAccessFailure) -> Body {
        fatalError("modifier bodies are unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitModifier(content: content, payload: self)
    }
}

private enum TraversalPathComponent: Equatable {
    case root
    case customBody
    case fixedChild(UInt8)
    case conditionalBranch(UInt8)
    case optionalPresence
    case declarationRole(UInt16)
}

private struct TraversalIdentity: Equatable {
    let path: [TraversalPathComponent]
}

private extension Array where Element == TraversalPathComponent {
    var firstFixedChildAfterContent: UInt8? {
        guard let contentIndex = firstIndex(of: .fixedChild(0)) else { return nil }
        return self[(contentIndex + 1)...].compactMap { component in
            if case .fixedChild(let index) = component {
                return index
            }
            return nil
        }.first
    }
}

private extension SemanticExpansionResult {
    var successSummary: SemanticExpansionSummary? {
        if case .success(let summary) = self {
            return summary
        }
        return nil
    }
}

private struct TraversalWorkspace: SemanticExpansionWorkspace {
    let maximumPathComponents: UInt16
    let maximumIdentities: UInt16
    var isExpanding = false
    var enterCount: UInt16 = 0
    private var path: [TraversalPathComponent] = []
    private var nextDeclarationRole: UInt16 = 0

    init(
        maximumPathComponents: UInt16 = 32,
        maximumIdentities: UInt16 = 64
    ) {
        self.maximumPathComponents = maximumPathComponents
        self.maximumIdentities = maximumIdentities
    }

    mutating func beginExpansion() -> Bool {
        guard !isExpanding else { return false }
        isExpanding = true
        enterCount = 0
        path.removeAll(keepingCapacity: true)
        nextDeclarationRole = 0
        return true
    }

    mutating func enterRoot<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout TraversalIdentity?
    ) -> SemanticExpansionError? {
        enter(.root, identity: &identity)
    }

    mutating func enterCustomBody<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout TraversalIdentity?
    ) -> SemanticExpansionError? {
        enter(.customBody, identity: &identity)
    }

    mutating func enterFixedChild(
        _ index: UInt8,
        identity: inout TraversalIdentity?
    ) -> SemanticExpansionError? {
        enter(.fixedChild(index), identity: &identity)
    }

    mutating func enterConditionalBranch(
        _ index: UInt8,
        identity: inout TraversalIdentity?
    ) -> SemanticExpansionError? {
        enter(.conditionalBranch(index), identity: &identity)
    }

    mutating func enterOptionalPresence(
        identity: inout TraversalIdentity?
    ) -> SemanticExpansionError? {
        enter(.optionalPresence, identity: &identity)
    }

    mutating func enterDeclarationRole<Declaration>(
        _ declaration: Declaration.Type,
        identity: inout TraversalIdentity?
    ) -> SemanticExpansionError? {
        let role = nextDeclarationRole
        nextDeclarationRole += 1
        return enter(.declarationRole(role), identity: &identity)
    }

    mutating func leavePathComponent() {
        _ = path.popLast()
    }

    mutating func completeExpansion() {}
    mutating func discardExpansion() {}

    mutating func resetExpansion() {
        isExpanding = false
        path.removeAll(keepingCapacity: true)
    }

    private mutating func enter(
        _ component: TraversalPathComponent,
        identity: inout TraversalIdentity?
    ) -> SemanticExpansionError? {
        enterCount += 1
        path.append(component)
        identity = TraversalIdentity(path: path)
        return nil
    }
}

private enum TraversalEventKind: Equatable {
    case structural
    case semantic
    case modifier
    case action
}

private struct TraversalEvent: Equatable {
    let identity: TraversalIdentity
    let kind: TraversalEventKind
    let modifierIndex: UInt16?
}

private struct TraversalSink: SemanticExpansionSink {
    let maximumStructuralOccurrences: UInt16 = 64
    let maximumBodyEvaluations: UInt16 = 64
    let maximumSemanticOccurrences: UInt16 = 64
    let maximumModifierApplications: UInt16 = 64
    let maximumActionOccurrences: UInt16 = 64
    var stagedEvents: [TraversalEvent] = []
    var committedEvents: [TraversalEvent] = []
    var observedActions: [TraversalAction] = []
    var publishCount = 0
    var discardCount = 0
    var bodyEvaluationStageCount = 0
    var refusedSemanticStage: Int?
    var refuseActionStage: Bool
    private var semanticStageAttemptCount = 0

    init(
        refusedSemanticStage: Int? = nil,
        refuseActionStage: Bool = false
    ) {
        self.refusedSemanticStage = refusedSemanticStage
        self.refuseActionStage = refuseActionStage
    }

    mutating func beginExpansion() -> Bool {
        stagedEvents.removeAll(keepingCapacity: true)
        bodyEvaluationStageCount = 0
        semanticStageAttemptCount = 0
        return true
    }

    mutating func stageStructuralOccurrence(
        identity: borrowing TraversalIdentity
    ) -> Bool {
        let storedIdentity = copy identity
        stagedEvents.append(
            TraversalEvent(identity: storedIdentity, kind: .structural, modifierIndex: nil)
        )
        return true
    }

    mutating func stageBodyEvaluation(
        identity: borrowing TraversalIdentity
    ) -> Bool {
        bodyEvaluationStageCount += 1
        return true
    }

    mutating func stageSemanticOccurrence<Payload: _GiftUISemanticPrimitivePayload>(
        identity: borrowing TraversalIdentity,
        payload: borrowing Payload
    ) -> Bool {
        defer { semanticStageAttemptCount += 1 }
        guard refusedSemanticStage != semanticStageAttemptCount else { return false }
        let storedIdentity = copy identity
        stagedEvents.append(
            TraversalEvent(identity: storedIdentity, kind: .semantic, modifierIndex: nil)
        )
        return true
    }

    mutating func stageModifierApplication<Payload: _GiftUISemanticModifierPayload>(
        identity: borrowing TraversalIdentity,
        payload: borrowing Payload,
        chainIndex: UInt16
    ) -> Bool {
        let storedIdentity = copy identity
        stagedEvents.append(
            TraversalEvent(identity: storedIdentity, kind: .modifier, modifierIndex: chainIndex)
        )
        return true
    }

    mutating func stageActionOccurrence<Action: GiftUIAction>(
        identity: borrowing TraversalIdentity,
        action: borrowing Action
    ) -> Bool {
        guard !refuseActionStage else { return false }
        let semanticIdentity = copy identity
        let actionIdentity = copy identity
        stagedEvents.append(
            TraversalEvent(identity: semanticIdentity, kind: .semantic, modifierIndex: nil)
        )
        stagedEvents.append(
            TraversalEvent(identity: actionIdentity, kind: .action, modifierIndex: nil)
        )
        if let action = TraversalAction(rawValue: action.rawValue) {
            observedActions.append(action)
        }
        return true
    }

    mutating func publishExpansion(_ summary: SemanticExpansionSummary) -> Bool {
        publishCount += 1
        committedEvents = stagedEvents
        stagedEvents.removeAll(keepingCapacity: true)
        return true
    }

    mutating func discardExpansion() {
        discardCount += 1
        stagedEvents.removeAll(keepingCapacity: true)
    }

    mutating func resetExpansion() {}
}
