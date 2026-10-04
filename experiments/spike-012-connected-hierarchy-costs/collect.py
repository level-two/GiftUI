"""Authorized connected collection only, after explicit J-Link flashing of the image."""
from pathlib import Path
import datetime,hashlib,json,re,statistics,struct,subprocess,sys,time
root=Path.cwd(); mode=sys.argv[1]
assert mode in ('packed','roles','snapshot')
build=root/f'.build/nrf52840/spike-012-connected-{mode}/firmware'
elf=build/'zephyr/zephyr.elf'; out=build.parent/'connected';out.mkdir(exist_ok=True)
prefix=str(root/'.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-')
nm=subprocess.check_output([prefix+'nm','-S',str(elf)],text=True)
symbols={f[-1]:(int(f[0],16),int(f[1],16)) for l in nm.splitlines() if len(f:=l.split())==4}
attrs=subprocess.check_output([prefix+'readelf','-A',str(elf)],text=True)
config=(build/'zephyr/.config').read_text()
assert 'Tag_CPU_arch: v7E-M' in attrs and 'Tag_ABI_VFP_args: VFP registers' in attrs
assert 'CONFIG_HEAP_MEM_POOL_SIZE=0' in config and 'CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0' in config
assert not {f[-1] for l in nm.splitlines() if (f:=l.split())}&{'malloc','calloc','realloc','aligned_alloc','swift_allocObject'}
stack_size=int(re.search(r'^CONFIG_MAIN_STACK_SIZE=(\d+)$',config,re.M)[1])
stack_address,stack_reservation=symbols['z_main_stack']; guard=stack_reservation-stack_size
assert guard==64
start=stack_address+guard; end=start+stack_size
result_address,result_size=symbols['giftui_spike012_results'];assert result_size==124
paint=out/'stack-paint.bin';paint.write_bytes(bytes([0xaa])*stack_size)
command=['JLinkExe','-device','NRF52840_XXAA','-if','SWD','-speed','4000','-SelectEmuBySN','683833660','-autoconnect','1']
def run(name,commands):
 script=out/(name+'.jlink');script.write_text('\n'.join(commands)+'\n')
 with (out/(name+'.log')).open('w') as log:
  r=subprocess.run(command+['-CommanderScript',str(script)],stdout=log,stderr=subprocess.STDOUT,timeout=45)
 text=(out/(name+'.log')).read_text()
 assert r.returncode==0 and 'Could not' not in text and 'Cannot' not in text
 return text
record={'revision':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),
 'started_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),
 'mode':mode,'elf':str(elf.relative_to(root)),'elf_sha256':hashlib.sha256(elf.read_bytes()).hexdigest(),
 'probe_serial':'683833660','command':command,'v7em':True,'hard_float':True,'zero_heaps':True,
 'stack_range':[start,end],'guard_bytes':guard,'stack_configured_bytes':stack_size,
 'result_address':result_address,'result_bytes':result_size}
paint_log=run('paint',['connect','h','r','h','regs','mem32 0xE000EDF0, 1',
 f'loadbin {paint}, 0x{start:08X}','regs','mem32 0xE000EDF0, 1','g','q'])
assert paint_log.count('E000EDF0 = 00030003')==2
started=time.monotonic()
# Nonhalting reads verify completion before a halted snapshot; no target function calls.
observe=run('observe',['connect']+sum(([f'mem32 0x{result_address:08X}, 4','mem32 0xE000ED28, 3','sleep 1000'] for _ in range(20)),[])+['q'])
complete=re.findall(fr'{result_address:08X} = ([A-F0-9 ]+)',observe)
assert complete and int(complete[-1].split()[1],16)==2, 'Benchmark did not complete within bounded observation'
read=run('read',['connect','h','regs',f'savebin {out}/results.bin, 0x{result_address:08X}, 0x{result_size:X}',
 f'savebin {out}/stack.bin, 0x{start:08X}, 0x{stack_size:X}','mem32 0xE000ED28, 3','g','q'])
faults=re.findall(r'E000ED28 = ([A-F0-9 ]+)',read);assert faults and all(int(x,16)==0 for x in faults[-1].split()[:2])
words=list(struct.unpack('<31I',(out/'results.bin').read_bytes()))
magic,status,kind,iterations,cpu_hz,clock_hz,cal_cycles,cal_ticks=words[:8]
assert magic==0x53503132 and status==2 and kind=={'packed':0,'roles':1,'snapshot':2}[mode]
assert iterations==32 and cpu_hz==64000000 and clock_hz==32768
assert 0.098 <= cal_cycles/cpu_hz <=0.105 and abs(cal_cycles/cpu_hz-cal_ticks/clock_hz)<0.002
cycles=[words[8:13],words[13:18]]; returns=[words[18:23],words[23:28]]
assert all(0<value<2**32-1 for values in returns for value in values)
if mode != 'snapshot':
 assert returns==[[3008]*5,[6080]*5]
if mode=='snapshot':
 assert returns==[[2944]*5]*2 and words[28:]==[0,0,92]
stack=(out/'stack.bin').read_bytes();untouched=0
for byte in stack:
 if byte!=0xaa:break
 untouched+=1
record.update(elapsed_seconds=time.monotonic()-started,raw_words=words,cpu_hz=cpu_hz,clock_hz=clock_hz,
 calibration=dict(cycles=cal_cycles,ticks=cal_ticks,seconds_cpu=cal_cycles/cpu_hz,seconds_rtc=cal_ticks/clock_hz),
 batch_cycles=cycles,batch_results=returns,iterations=iterations,
 per_call_microseconds=[[v*1e6/cpu_hz/iterations for v in values] for values in cycles],
 median_per_call_microseconds=[statistics.median(values)*1e6/cpu_hz/iterations for values in cycles],
 refusal_and_reuse=words[28:],untouched_prefix_bytes=untouched,observed_sentinel_extent_bytes=stack_size-untouched,
 cfsr_hfsr=[int(x,16) for x in faults[-1].split()[:2]],
 scope='Packed includes one setup per32 stages; snapshot constructs each call. Interrupts included; no render/input/acquisition corpus; extent is not a universal bound.')
record['files']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(out.iterdir()) if p.is_file()}
(root/f'experiments/spike-012-connected-hierarchy-costs/evidence/{mode}.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps({k:record[k] for k in ('mode','median_per_call_microseconds','observed_sentinel_extent_bytes','batch_results','calibration')},indent=2))
