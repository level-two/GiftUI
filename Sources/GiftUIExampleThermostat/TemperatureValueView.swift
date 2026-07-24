import GiftUI

struct TemperatureValueView: View {
    let value: Int

    var body: some View {
        Text("\(value)°")
    }
}
