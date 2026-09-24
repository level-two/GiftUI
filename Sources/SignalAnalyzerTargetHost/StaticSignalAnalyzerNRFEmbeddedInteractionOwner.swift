#if GIFTUI_NRF_EMBEDDED
    /// Stages generated action records with the shared Static interaction
    /// grammar. The caller resolves each candidate after its physical offer.
    package struct StaticSignalAnalyzerNRFEmbeddedInteractionOwner:
        InteractionGestureResolver
    {
        package typealias Identity = UInt32
        private var interaction: StaticInteractionState<UInt32>
        private var generations = ActionGenerationAllocator()

        package init?() {
            guard let candidate = StaticInteractionCandidateStorage<UInt32>(capacity: 6),
                let candidateHits = StaticInteractionHitStorage<UInt32>(capacity: 6),
                let candidateCommitted = StaticInteractionCommittedStorage<UInt32>(capacity: 6),
                let committed = StaticInteractionCommittedStorage<UInt32>(capacity: 6),
                let committedHits = StaticInteractionHitStorage<UInt32>(capacity: 6)
            else { return nil }
            interaction = StaticInteractionState(
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
            guard
                let limits = InteractionLimits(
                    maximumActions: 6, maximumHitRegions: 6
                ), interaction.beginCandidate(limits: limits) == nil
            else { return false }
            var index: UInt16 = 0
            while index < occurrences.count {
                guard let occurrence = occurrences.occurrence(at: index) else {
                    interaction.resolveCandidate(.discard)
                    return false
                }
                let identity = UInt32(occurrence.identity)
                switch interaction.append(
                    identity: identity, isEnabled: occurrence.isEnabled,
                    bounds: occurrence.bounds, clip: occurrence.clip,
                    paintOrder: index,
                    action: BoundedApplicationAction(code: UInt16(occurrence.actionCode)),
                    targetGeneration: targetGeneration
                ) {
                case .preserved:
                    break
                case .requiresGeneration:
                    guard let generation = generations.reserve(),
                        interaction.assignGeneration(generation, to: identity) == nil
                    else {
                        interaction.resolveCandidate(.discard)
                        return false
                    }
                case .failure:
                    interaction.resolveCandidate(.discard)
                    return false
                }
                index += 1
            }
            guard interaction.finishCandidate() == nil else {
                interaction.resolveCandidate(.discard)
                return false
            }
            return true
        }

        package mutating func resolve(
            accepted: Bool, presentationRevision: PresentationRevision
        ) {
            interaction.resolveCandidate(
                accepted ? .commit(presentationRevision) : .discard
            )
        }
    }
#endif
