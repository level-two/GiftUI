import GiftUI
import GiftUISemanticCore
import GiftUITextResources

package enum LayoutError: UInt8, Equatable, Sendable {
    case invalidDeclaration = 0
    case arithmeticOverflow = 1
    case capacityExhausted = 2
    case reentrancyViolation = 3
    case invariantViolation = 4
}
