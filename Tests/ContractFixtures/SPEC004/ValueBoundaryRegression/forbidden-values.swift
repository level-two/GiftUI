struct DeviceID {}
final class Registry {
    let names: Array<String>
    let callback: () -> Void
    let reflected: any Error

    init(names: Array<String>, callback: @escaping () -> Void) throws {
        self.names = names
        self.callback = callback
        reflected = Mirror(reflecting: names) as! any Error
    }
}
