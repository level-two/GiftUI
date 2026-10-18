import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUISemanticCore
import GiftUIRuntimeCore
package func forward<C, R, H>(_ state: inout InteractionOwnedKeyState<C, R, H>) where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable, R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable, H: InteractionHitRegionStorage & ~Copyable & ~Escapable, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity { state.committedComponents = 0 }
