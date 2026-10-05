set pagination off
set confirm off
set remotetimeout 10
target remote localhost:2331
monitor halt
thbreak service
continue
printf "SERVICE BOUNDARY\n"
info registers pc sp
p production
p (unsigned int)giftui_signal_analyzer_current_revision()
p (unsigned int)giftui_signal_analyzer_acquisition_state()
p (unsigned int)giftui_signal_analyzer_capture_count()
p (unsigned int)giftui_signal_analyzer_action_point(3)
p (unsigned int)giftui_signal_analyzer_action_point(4)
p (unsigned int)giftui_signal_analyzer_action_point(5)
p fault_counts
x/3wx 0xE000ED28
set $point=(unsigned int)giftui_signal_analyzer_action_point(5)
set $revision=(unsigned int)giftui_signal_analyzer_current_revision()
printf "SOFTWARE ACTION code=5 point=%u revision=%u\n", $point, $revision
if $point == 0
error Requested action is not enabled
end
p (int)giftui_signal_analyzer_input_admit(0,$point&65535,$point>>16,$revision,0)
p (int)giftui_signal_analyzer_input_admit(2,$point&65535,$point>>16,$revision,0)
p (unsigned short)giftui_signal_analyzer_input_pending_count()
delete breakpoints
monitor go
detach
