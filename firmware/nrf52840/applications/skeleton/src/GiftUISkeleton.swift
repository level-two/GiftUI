@_silgen_name("giftui_board_initialize")
func giftuiBoardInitialize() -> Int32

@_silgen_name("giftui_board_button_is_pressed")
func giftuiBoardButtonIsPressed() -> Int32

@_silgen_name("giftui_board_set_status_led")
func giftuiBoardSetStatusLED(_ enabled: Int32)

@_silgen_name("giftui_board_sleep_ms")
func giftuiBoardSleep(milliseconds: UInt32)

@_silgen_name("giftui_board_log_event")
func giftuiBoardLogEvent(_ event: Int32)

private let eventStarted: Int32 = 0
private let eventBoardInitializationFailed: Int32 = 1
private let eventButtonPressed: Int32 = 2
private let eventButtonReleased: Int32 = 3
private let eventButtonReadFailed: Int32 = 4

private let loopPeriodMilliseconds: UInt32 = 20
private let heartbeatHalfPeriodTicks: UInt32 = 25

@_cdecl("giftui_swift_application_run")
public func giftuiSwiftApplicationRun() -> Int32 {
    let initializationResult = giftuiBoardInitialize()
    if initializationResult != 0 {
        giftuiBoardLogEvent(eventBoardInitializationFailed)
        return initializationResult
    }

    giftuiBoardLogEvent(eventStarted)

    var buttonWasPressed = false
    var heartbeatIsOn = false
    var heartbeatTick: UInt32 = 0
    var displayedLEDState = false

    while true {
        let buttonResult = giftuiBoardButtonIsPressed()
        if buttonResult < 0 {
            giftuiBoardLogEvent(eventButtonReadFailed)
            giftuiBoardSetStatusLED(0)
            giftuiBoardSleep(milliseconds: loopPeriodMilliseconds)
            continue
        }

        let buttonIsPressed = buttonResult != 0
        if buttonIsPressed != buttonWasPressed {
            giftuiBoardLogEvent(buttonIsPressed ? eventButtonPressed : eventButtonReleased)
            buttonWasPressed = buttonIsPressed
        }

        if buttonIsPressed {
            heartbeatTick = 0
            heartbeatIsOn = false
        } else {
            heartbeatTick &+= 1
            if heartbeatTick >= heartbeatHalfPeriodTicks {
                heartbeatTick = 0
                heartbeatIsOn.toggle()
            }
        }

        let requestedLEDState = buttonIsPressed || heartbeatIsOn
        if requestedLEDState != displayedLEDState {
            giftuiBoardSetStatusLED(requestedLEDState ? 1 : 0)
            displayedLEDState = requestedLEDState
        }

        giftuiBoardSleep(milliseconds: loopPeriodMilliseconds)
    }
}
