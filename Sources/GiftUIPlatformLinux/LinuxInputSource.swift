import GiftUI

public protocol LinuxInputSource: AnyObject {
    func poll() throws -> [InputEvent]
}

public protocol LinuxNavigationInputSource: AnyObject {
    func pollNavigation() throws -> [NavigationInput]
}
