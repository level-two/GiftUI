"""Explicitly authorized connected collection after flashing the named copy."""
from pathlib import Path
import datetime,hashlib,json,re,struct,subprocess,sys,time
root=Path.cwd();mode=sys.argv[1];assert mode in ('normal','refusal')
build=root/f'.build/nrf52840/spike-013-connected-host-{mode}/firmware';out=build.parent/'connected';out.mkdir(exist_ok=True)
elf=build/'zephyr/zephyr.elf';prefix=str(root/'.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-')
nm=subprocess.check_output([prefix+'nm','-S',str(elf)],text=True)
symbols={f[-1]:(int(f[0],16),int(f[1],16)) for line in nm.splitlines() if len(f:=line.split())==4}
address,size=symbols['giftui_spike013_trace'];assert size==704
stack,reservation=symbols['z_main_stack'];stack+=64;stack_size=reservation-64
config=(build/'zephyr/.config').read_text();assert f'CONFIG_MAIN_STACK_SIZE={stack_size}' in config
resource=json.loads((root/f'experiments/spike-013-connected-host-followup/evidence/{mode}-resource.json').read_text())['images']['candidate']
assert resource['sha256']==hashlib.sha256(elf.read_bytes()).hexdigest() and resource['ram_bytes']<=196608
assert resource['v7em'] and resource['hard_float'] and resource['zero_zephyr_heap'] and resource['zero_libc_heap'] and not resource['allocator_entries']
headers=subprocess.check_output([prefix+'readelf','-SW',str(elf)],text=True)
row=re.search(r'rom_start\s+PROGBITS\s+00000000\s+([0-9a-f]+)\s+([0-9a-f]+)',headers)
assert row
offset=int(row[1],16);length=int(row[2],16)
(out/'vector.bin').write_bytes(elf.read_bytes()[offset:offset+length])
sp,pc=struct.unpack('<II',(out/'vector.bin').read_bytes()[:8]);pc&=~1
paint=out/'paint.bin';paint.write_bytes(b'\xaa'*stack_size)
command=['JLinkExe','-device','NRF52840_XXAA','-if','SWD','-speed','4000','-SelectEmuBySN','683833660','-autoconnect','1']
def run(name,lines):
 p=out/(name+'.jlink');p.write_text('\n'.join(lines)+'\n')
 with (out/(name+'.log')).open('w') as log:r=subprocess.run(command+['-CommanderScript',str(p)],stdout=log,stderr=subprocess.STDOUT,timeout=30)
 text=(out/(name+'.log')).read_text();assert r.returncode==0 and 'Could not' not in text and 'Cannot' not in text;return text
text=run('paint',['connect','h','r','h','regs','mem32 0xE000EDF0, 1',f'loadbin {paint}, 0x{stack:08X}','regs','mem32 0xE000EDF0, 1','g','q'])
assert text.count('E000EDF0 = 00030003')==2
assert len(re.findall(fr'PC = {pc:08X}',text))>=2 and len(re.findall(fr'SP\(R13\)= {sp:08X}',text))>=2
started=time.monotonic();complete=False
for i in range(22):
 text=run(f'observe-{i:02}', ['connect']+sum(([f'mem32 0x{address:08X}, 8','mem32 0xE000ED28, 3','sleep 1000'] for _ in range(10)),[])+['q'])
 rows=re.findall(fr'{address:08X} = ([A-F0-9 ]+)',text);assert rows
 status=int(rows[-1].split()[1],16)
 faults=re.findall(r'E000ED28 = ([A-F0-9 ]+)',text);assert faults and all(int(w,16)==0 for row in faults for w in row.split()[:2])
 assert status in (1,2),status
 print(f'{mode}: elapsed {time.monotonic()-started:.1f}s, status={status}',flush=True)
 if status==2:complete=True;break
assert complete,'Bounded workload did not complete'
text=run('read',['connect','h','regs',f'savebin {out}/trace.bin, 0x{address:08X}, 0x{size:X}',f'savebin {out}/stack.bin, 0x{stack:08X}, 0x{stack_size:X}',f'savebin {out}/faults.bin, 0x{symbols["fault_counts"][0]:08X}, 0x14','mem32 0xE000ED28, 3','g','q'])
subprocess.run(['python3','experiments/spike-013-connected-host-followup/summarize.py',mode],check=True)
