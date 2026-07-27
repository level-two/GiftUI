import GiftUI
import GiftUIDynamicConveniences

struct TemperatureValueView: View {
    let value: Int

    var body: some View {
        Text("\(value)°")
    }
}
