"""Decode completed bounded traces; 1% clock-agreement tolerance is explicit."""
from pathlib import Path
import datetime,hashlib,json,re,struct,subprocess,sys
root=Path.cwd();mode=sys.argv[1];assert mode in ('normal','refusal')
build=root/f'.build/nrf52840/spike-013-connected-host-{mode}/firmware';out=build.parent/'connected'
resource=json.loads((root/f'experiments/spike-013-connected-host-followup/evidence/{mode}-resource.json').read_text())['images']['candidate']
assert resource['sha256']==hashlib.sha256((build/'zephyr/zephyr.elf').read_bytes()).hexdigest()
prefix=str(root/'.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-')
nm=subprocess.check_output([prefix+'nm','-S',str(build/'zephyr/zephyr.elf')],text=True)
row=re.search(r'^([0-9a-f]+) ([0-9a-f]+) [A-Za-z] z_main_stack$',nm,re.M);assert row
stack=int(row[1],16)+64;stack_size=int(row[2],16)-64
fault_rows=re.findall(r'E000ED28 = ([A-F0-9 ]+)',(out/'read.log').read_text());assert fault_rows and all(int(w,16)==0 for w in fault_rows[-1].split()[:2])
counts=list(struct.unpack('<5I',(out/'faults.bin').read_bytes()))
assert counts==([0,0,1,0,0] if mode=='refusal' else [0]*5)
words=struct.unpack('<176I',(out/'trace.bin').read_bytes());head=list(words[:32]);frames=[list(words[32+i*24:32+(i+1)*24]) for i in range(head[7])]
assert head[:3]==[0x53503133,2,int(mode=='refusal')] and head[3:5]==[64000000,32768]
assert 0.098<=head[5]/head[3]<=0.105 and abs(head[5]/head[3]-head[6]/head[4])<0.002
assert head[27]==0 and all(x==0 for x in head[10:18])
results=list(struct.unpack('<ii',struct.pack('<II',*head[8:10])))
if mode=='normal':
 assert len(frames)==6 and results[0]==0 and [f[2] for f in frames]==[1]*6
 assert frames[1][6]==1 and frames[3][6]==2 and frames[4][7]==0 and frames[5][6]==3
else:
 assert len(frames)==3 and results==[-5,0] and [f[2] for f in frames]==[1,0,1]
 assert frames[1][12]==1 and sum(f[12] for f in frames)==1
stages=json.loads((root/'experiments/spike-013-connected-host-followup/evidence/preparation.json').read_text())['stages']
formatted=[]
for f in frames:
 seconds=(f[4]-f[3])%2**32/head[4];assert seconds<67 and abs(seconds-f[5]/head[3])/max(seconds,f[5]/head[3])<0.01
 assert sum(f[13:])<=f[5]
 formatted.append(dict(revision=f[0],initial=bool(f[1]),outcome=f[2],seconds=seconds,total_cycles=f[5],state=f[6],capture=f[7],window=f[8],spi_calls=f[9],successful_pixel_bytes=f[10],spi_seconds=f[11]/head[3],refusals=f[12],clock_relative_difference=abs(seconds-f[5]/head[3])/max(seconds,f[5]/head[3]),stage_seconds=dict(zip(stages,[c/head[3] for c in f[13:]]))))
stack_bytes=(out/'stack.bin').read_bytes();untouched=next((i for i,b in enumerate(stack_bytes) if b!=0xaa),len(stack_bytes))
record=dict(driver_fault_counts=counts,cfsr_hfsr=[0,0],mode=mode,utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),elf_sha256=resource['sha256'],probe_serial='683833660',resource=resource,raw_header=head,results=results,calibration_seconds_cpu=head[5]/head[3],calibration_seconds_rtc=head[6]/head[4],frames=formatted,source_polls=head[22],first_source_microseconds=head[23]+(head[24]<<32),last_source_microseconds=head[25]+(head[26]<<32),stack_range=[stack,stack+stack_size],observed_sentinel_extent_bytes=stack_size-untouched,retired_revision=head[10:12],retired_pending=head[12:14],retired_needs=head[14:16],retired_touch_valid=head[16:18],files={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(out.iterdir()) if p.is_file()},limits='Copied application; software actions/model diagnostic/backend refusal; not physical input, independent pixels, or a universal stack bound.')
(root/f'experiments/spike-013-connected-host-followup/evidence/{mode}.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps({k:record[k] for k in ('mode','results','source_polls','observed_sentinel_extent_bytes')},indent=2))
