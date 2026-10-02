#if GIFTUI_NRF_EMBEDDED
    /// Stages generated action records with the shared Static interaction
    /// grammar. The caller resolves each candidate after its physical offer.
    package struct StaticSignalAnalyzerNRFEmbeddedInteractionOwner:
        InteractionGestureResolver
    {
        package typealias Identity = UInt32
        private var interaction: StaticSixInteractionState<UInt32>
        private var generations = RuntimeActionGenerationAllocator<UInt32>()

        package init?() {
            guard let candidate = StaticSixInteractionCandidateStorage<UInt32>(capacity: 6),
                let candidateHits = StaticSixInteractionHitStorage<UInt32>(capacity: 6),
                let candidateCommitted = StaticSixInteractionCommittedStorage<UInt32>(capacity: 6),
                let committed = StaticSixInteractionCommittedStorage<UInt32>(capacity: 6),
                let committedHits = StaticSixInteractionHitStorage<UInt32>(capacity: 6)
            else { return nil }
            interaction = StaticSixInteractionState(
                candidateRecords: candidate,
                candidateHitRegions: candidateHits,
                candidateCommittedRecords: candidateCommitted,
                committedRecords: committed,
                committedHitRegions: committedHits
            )
        }

        package var candidateIsReadyForOffer: Bool {
            interaction.candidateIsReadyForOffer
        }

        package var committedRecordCount: UInt16 {
            interaction.committedRecordCount
        }

        package var committedRevision: PresentationRevision? {
            interaction.committedRevision
        }

        package borrowing func committedRecord(at index: UInt16)
            -> BoundActionRecord<UInt32>?
        {
            interaction.committedRecord(at: index)
        }

        package borrowing func committedRecord(for identity: UInt32)
            -> BoundActionRecord<UInt32>?
        {
            interaction.committedRecord(for: identity)
        }

        package borrowing func resolveDown(at point: Point) -> PointerGestureOutcome<UInt32> {
            interaction.resolveDown(at: point)
        }

        package borrowing func resolveMove(
            _ captured: CapturedAction<UInt32>, at point: Point
        ) -> PointerGestureOutcome<UInt32> {
            interaction.resolveMove(captured, at: point)
        }

        package borrowing func resolveUp(
            _ captured: CapturedAction<UInt32>, at point: Point
        ) -> PointerGestureOutcome<UInt32> {
            interaction.resolveUp(captured, at: point)
        }

        package mutating func build(
            occurrences: StaticSignalAnalyzerNRFEmbeddedInteractionOccurrences,
            targetGeneration: ObservableTargetGeneration
        ) -> Bool {
            buildTyped(occurrences: occurrences, targetGeneration: targetGeneration) == .ready
        }

        package mutating func buildTyped(
            occurrences: StaticSignalAnalyzerNRFEmbeddedInteractionOccurrences,
            targetGeneration: ObservableTargetGeneration
        ) -> RuntimeInteractionCandidateBuildResult {
            guard let limits = InteractionLimits(maximumActions: 6, maximumHitRegions: 6)
            else { return .ownerFailure(.interaction(.invariantViolation)) }
            var target = StaticSignalAnalyzerNRFInteractionTargetProjection(
                generation: targetGeneration)
            return RuntimeInteractionCandidateCoordinator.build(
                occurrences: occurrences, limits: limits, rootIdentity: 0, rootStateOrdinal: 0,
                interaction: &interaction, observable: &target, generations: &generations)
        }

        package mutating func resolve(
            accepted: Bool, presentationRevision: PresentationRevision
        ) {
            _ = RuntimeInteractionCandidateTransaction.resolve(
                offer: FrameOfferResult(
                    disposition: accepted ? .accepted : .nonRetryableRefusal,
                    failure: nil)!,
                presentationRevision: presentationRevision,
                interaction: &interaction, generations: &generations)
        }
    }
#endif
