import GiftUI

struct ThermostatView: View {
    @State private var target = 21

    var body: some View {
        VStack(spacing: 8) {
            Text("Target")
            TemperatureValueView(value: target)
            ControlsView(
                decrement: { target -= 1 },
                increment: { target += 1 }
            )
        }
    }
}
