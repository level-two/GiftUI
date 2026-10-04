"""Explicitly authorized connected software pointer corpus; no physical-input claim."""
from pathlib import Path
import hashlib,json,re,subprocess,sys
root=Path.cwd();out=root/'.build/nrf52840/iteration-002-followup';out.mkdir(exist_ok=True)
elf=root/'.build/nrf52840/signal-analyzer-static/zephyr/zephyr.elf'
assert hashlib.sha256(elf.read_bytes()).hexdigest()=='c6d0f12c8585cad3f3949fb596e13fa7328989239a31a1f6e428afadb541ed5c'
cases={'window-one':(3,'normal'),'window-two':(4,'normal'),'window-five':(5,'normal'),
       'disabled-plus':(5,'disabled'),'movement-cancel':(3,'move'),'stale-revision':(3,'stale')}
label=sys.argv[1];code,kind=cases[label]
script='''set pagination off
set confirm off
target remote localhost:2331
monitor halt
break service
continue
set $prior=(unsigned int)giftui_signal_analyzer_current_revision()
set $enabled=(unsigned int)giftui_signal_analyzer_action_point(CODE)
set $point=$enabled
printf "BEFORE LABEL revision=%u point=%u enabled=%u\\n",$prior,$point,$enabled
set $observed=$prior
'''.replace('CODE',str(code)).replace('LABEL',label)
if kind=='disabled':
 prior_log=(out/'window-five.log').read_text()
 point=int(re.search(r'BEFORE window-five revision=\d+ point=(\d+)',prior_log)[1])
 assert point>0
 script=script.replace('set $point=$enabled',f'set $point={point}')
if kind=='stale':script+='set $observed=$prior-1\n'
script+='p (int)giftui_signal_analyzer_input_admit(0,$point&65535,$point>>16,$observed,1)\n'
if kind=='move':script+='p (int)giftui_signal_analyzer_input_admit(1,319,239,$observed,0)\n'
script+='''p (int)giftui_signal_analyzer_input_admit(2,$point&65535,$point>>16,$observed,0)
set $attempt=0
continue
set $pending=(unsigned short)giftui_signal_analyzer_input_pending_count()
while $pending>0 && $attempt<50
set $attempt=$attempt+1
continue
set $pending=(unsigned short)giftui_signal_analyzer_input_pending_count()
end
set $revision=(unsigned int)giftui_signal_analyzer_current_revision()
set $state=(unsigned int)giftui_signal_analyzer_acquisition_state()
set $capture=(unsigned int)giftui_signal_analyzer_capture_count()
set $actions=(unsigned short *)(production.regions.profile+3024+72)
printf "AFTER LABEL revision=%u state=%u pending=%u capture=%u actions=%u,%u,%u\\n",$revision,$state,$pending,$capture,$actions[0],$actions[1],$actions[2]
p fault_counts
x/3wx 0xE000ED28
delete breakpoints
monitor go
detach
'''.replace('LABEL',label)
path=out/(label+'.gdb');path.write_text(script)
r=subprocess.run(['python3','docs/iterations/iteration-002-review/run-nrf-connected-gdb.py',str(path),'55'])
assert r.returncode==0
