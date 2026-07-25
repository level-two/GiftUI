import GiftUI
import GiftUIExampleThermostatView
import GiftUISimulatorMac

let simulator = GiftUISimulator(
    root: ThermostatView(),
    logicalSize: Size(width: 240, height: 240),
    scale: 3
)
simulator.run()
