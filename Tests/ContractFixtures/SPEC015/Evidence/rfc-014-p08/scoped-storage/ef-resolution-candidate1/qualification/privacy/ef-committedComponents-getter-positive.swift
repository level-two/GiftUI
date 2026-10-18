import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUISemanticCore
import GiftUIRuntimeCore
package func forward<C, R, H>(_ state: borrowing InteractionOwnedKeyState<C, R, H>) -> UInt32 where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable, R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable, H: InteractionHitRegionStorage & ~Copyable & ~Escapable, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity { return state.committedComponents }
