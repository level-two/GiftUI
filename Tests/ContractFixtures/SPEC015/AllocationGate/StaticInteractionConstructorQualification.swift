import GiftUI
import GiftUIExecution
import GiftUIInteraction
import P08CounterRuntime

// Reference identities exercise real generic payload destruction. Allocations
// here are intentional behavior controls, not a Static allocation measurement.
private final class ConstructorIdentity: Equatable, @unchecked Sendable {
    let value: Int
    let deaths: UnsafeMutablePointer<Int>

    init(_ value: Int, _ deaths: UnsafeMutablePointer<Int>) {
        self.value = value
        self.deaths = deaths
    }
    deinit { deaths.pointee += 1 }
    static func == (lhs: ConstructorIdentity, rhs: ConstructorIdentity) -> Bool {
        lhs.value == rhs.value
    }
}

private let bounds = Rect(origin: Point(x: 0, y: 0), size: Size(width: 1, height: 1)!)!

private func isAbsent<Value>(_ value: Value?) -> Bool {
    if case .none = value { return true }
    return false
}

private func candidate(_ value: Int, _ deaths: UnsafeMutablePointer<Int>) -> InteractionCandidateRecord<ConstructorIdentity> {
    .init(identity: ConstructorIdentity(value, deaths), generation: nil,
        isEnabled: true, hitBounds: bounds, paintOrder: 0,
        action: .init(code: 0), targetGeneration: .init(rawValue: 0))
}

private func committed(_ value: Int, _ deaths: UnsafeMutablePointer<Int>) -> BoundActionRecord<ConstructorIdentity> {
    .init(identity: ConstructorIdentity(value, deaths), generation: .init(rawValue: 0),
        isEnabled: true, hitBounds: bounds, paintOrder: 0,
        action: .init(code: 0), targetGeneration: .init(rawValue: 0))
}

@inline(never)
private func exerciseCandidate(_ deaths: UnsafeMutablePointer<Int>) {
    var storage = StaticTwoInteractionCandidateStorage<ConstructorIdentity>(capacity: 2)!
    precondition(storage.count == 0 && storage.record(at: 0) == nil)
    precondition(storage.append(candidate(1, deaths)))
    precondition(storage.append(candidate(2, deaths)))
    var retained = storage
    precondition(storage.replace(at: 0, with: candidate(3, deaths)))
    precondition(!storage.append(candidate(4, deaths)))
    storage.reset()
    precondition(storage.count == 0 && storage.record(at: 0) == nil)
    precondition(retained.record(at: 0)?.identity.value == 1)
    precondition(retained.record(at: 1)?.identity.value == 2)
    precondition(retained.record(at: 2) == nil)
    retained.reset()
}

@inline(never)
private func exerciseCommitted(_ deaths: UnsafeMutablePointer<Int>) {
    var left = StaticTwoInteractionCommittedStorage<ConstructorIdentity>(capacity: 1)!
    var right = StaticTwoInteractionCommittedStorage<ConstructorIdentity>(capacity: 2)!
    precondition(left.append(committed(10, deaths)))
    precondition(right.append(committed(20, deaths)))
    precondition(right.append(committed(21, deaths)))
    var retained = left
    left.exchangeContents(with: &right)
    precondition(left.capacity == 2 && left.count == 2)
    precondition(right.capacity == 1 && right.count == 1)
    precondition(left.record(at: 1)?.identity.value == 21)
    precondition(right.record(at: 0)?.identity.value == 10)
    left.reset()
    right.reset()
    precondition(retained.record(at: 0)?.identity.value == 10)
    retained.reset()
}

@inline(never)
private func exerciseHit(_ deaths: UnsafeMutablePointer<Int>) {
    var left = StaticTwoInteractionHitStorage<ConstructorIdentity>(capacity: 1)!
    var right = StaticTwoInteractionHitStorage<ConstructorIdentity>(capacity: 2)!
    precondition(left.append(.init(identity: ConstructorIdentity(30, deaths), bounds: bounds, paintOrder: 0)))
    precondition(right.append(.init(identity: ConstructorIdentity(40, deaths), bounds: bounds, paintOrder: 0)))
    precondition(right.append(.init(identity: ConstructorIdentity(41, deaths), bounds: bounds, paintOrder: 1)))
    var retained = right
    left.exchangeContents(with: &right)
    precondition(left.capacity == 2 && left.count == 2)
    precondition(right.capacity == 1 && right.count == 1)
    precondition(left.region(at: 1)?.identity.value == 41)
    left.reset()
    right.reset()
    precondition(retained.region(at: 0)?.identity.value == 40)
    retained.reset()
}

@main
private struct StaticInteractionConstructorQualification {
    static func main() {
        for capacity: UInt16 in [0, 3, .max] {
            precondition(isAbsent(StaticTwoInteractionCandidateStorage<ConstructorIdentity>(capacity: capacity)))
            precondition(isAbsent(StaticTwoInteractionCommittedStorage<ConstructorIdentity>(capacity: capacity)))
            precondition(isAbsent(StaticTwoInteractionHitStorage<ConstructorIdentity>(capacity: capacity)))
        }
        var deaths = 0
        withUnsafeMutablePointer(to: &deaths) { pointer in
            exerciseCandidate(pointer)
            precondition(pointer.pointee == 4)
            exerciseCommitted(pointer)
            precondition(pointer.pointee == 7)
            exerciseHit(pointer)
            precondition(pointer.pointee == 10)
        }
        precondition(deaths == 10)
        print("static-interaction-constructor-lifetimes=10 refusals=9")
    }
}
