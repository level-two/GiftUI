import GiftUI

func requireEquatable<T: Equatable>(_ value: T) {}
func requireHashable<T: Hashable>(_ value: T) {}
func requireSendable<T: Sendable>(_ value: T) {}

let custom = Color(red: 1, green: 2, blue: 3)
requireEquatable(custom)
requireHashable(custom)
requireSendable(custom)

let named: [Color] = [.black, .white, .red, .green, .blue, .gray]
precondition(named.count == 6)
