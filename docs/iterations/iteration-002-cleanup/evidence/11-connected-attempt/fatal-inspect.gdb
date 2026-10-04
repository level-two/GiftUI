set pagination off
set confirm off
target remote localhost:2331
monitor halt
info registers pc sp
bt
p production
p fault_counts
x/3wx 0xE000ED28
monitor go
detach
