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
x/16gx production.regions.capture
delete breakpoints
monitor go
detach
