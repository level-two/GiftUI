import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUISemanticCore
package func forward<C, R, H>(_ state: borrowing InteractionState<C, R, H>, captured: CapturedAction<SemanticCompleteIdentity>, point: Point) -> BoundActionRecord<SemanticCompleteIdentity>? where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable, R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable, H: InteractionHitRegionStorage & ~Copyable & ~Escapable, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity { state.capturedRecord(captured, contains: point) }
