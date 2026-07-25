import GiftUI

public protocol LinuxInputSource: AnyObject {
    func poll() throws -> [InputEvent]
}
