import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUISemanticCore
package func forward<C, R, H>(_ state: borrowing InteractionState<C, R, H>, identity: SemanticCompleteIdentity) -> BoundActionRecord<SemanticCompleteIdentity>? where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable, R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable, H: InteractionHitRegionStorage & ~Copyable & ~Escapable, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity { state.record(identity: identity) }
