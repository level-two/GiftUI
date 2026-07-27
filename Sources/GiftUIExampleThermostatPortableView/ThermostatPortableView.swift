import GiftUI

public struct ThermostatPortableView: View {
    private let target: Int

    public init(target: Int) {
        self.target = target
    }

    public var body: some View {
        VStack(spacing: 8) {
            Text("Target")
            Text(integer: target, suffix: "°")
            HStack(spacing: 8) {
                Button("-", action: ThermostatAction.decrement)
                Button("+", action: ThermostatAction.increment)
            }
        }
    }
}
