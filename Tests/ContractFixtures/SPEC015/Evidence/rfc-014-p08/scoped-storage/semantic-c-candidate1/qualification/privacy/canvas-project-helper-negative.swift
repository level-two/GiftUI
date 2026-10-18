import GiftUI
import GiftUIDrawing
import GiftUISemanticCore
package func forward<Roles: SemanticDeclarationRoles, Value, Expected>(_ value: borrowing Value, as type: Expected.Type, roles: Roles.Type) -> Expected { SemanticStandardPayloadCodec<Roles>.project(value, as: type) }
