import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUISemanticCore
import GiftUIRuntimeCore
package func owned<C, R, H>(_ state: inout InteractionOwnedKeyState<C, R, H>, disposition: InteractionCandidateDisposition) where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable, R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable, H: InteractionHitRegionStorage & ~Copyable & ~Escapable, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity { state.resolveCandidate(disposition) }
package func direct<C, R, H>(_ state: inout InteractionState<C, R, H>, disposition: InteractionCandidateDisposition) where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable, R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable, H: InteractionHitRegionStorage & ~Copyable & ~Escapable, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity { state.resolveCandidate(disposition) }
package func generation(_ state: inout RuntimeActionGenerationAllocator<SemanticCompleteIdentity>) { state.resolveCandidate(committed: true); state.resolveCandidate(committed: false) }
