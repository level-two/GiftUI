import GiftUIExampleThermostatView
import GiftUIPlatformRaspberryPi

#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

let arguments = Array(CommandLine.arguments.dropFirst())

if arguments.contains("-h") || arguments.contains("--help") {
    print(RaspberryPiConfiguration.usage)
    exit(EXIT_SUCCESS)
}

do {
    let configuration = try RaspberryPiConfiguration(arguments: arguments)
    try RaspberryPiPlatform(configuration: configuration).run(
        root: ThermostatView()
    )
} catch {
    print("GiftUI Raspberry Pi error: \(error)")
    exit(EXIT_FAILURE)
}
