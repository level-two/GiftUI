"""Check and preserve candidate connected records, exact images and raw measurements."""
from pathlib import Path
import hashlib,json,subprocess,tarfile
root=Path.cwd();spike=root/'experiments/spike-012-connected-hierarchy-costs';records={}
for mode in ('packed','roles','snapshot'):
 record=json.loads((spike/f'evidence/{mode}.json').read_text())
 build=root/f'.build/nrf52840/spike-012-connected-{mode}/firmware'
 assert hashlib.sha256((root/record['elf']).read_bytes()).hexdigest()==record['elf_sha256']
 elf_record=json.loads((spike/f'evidence/{mode}-elf.json').read_text())['images']['candidate']
 assert elf_record['sha256']==record['elf_sha256'] and elf_record['ram_bytes']<=196608
 for name,digest in record['files'].items():
  assert hashlib.sha256((build.parent/'connected'/name).read_bytes()).hexdigest()==digest
 assert (build.parent/'connected/results.bin').stat().st_size==124
 assert (build.parent/'connected/stack.bin').stat().st_size==27648
 records[mode]=record
assert records['packed']['batch_results']==records['roles']['batch_results']==[[3008]*5,[6080]*5]
assert records['snapshot']['batch_results']==[[2944]*5]*2
assert records['snapshot']['refusal_and_reuse']==[0,0,92]
assert all(v['cfsr_hfsr']==[0,0] for v in records.values())
preparation=json.loads((spike/'evidence/preparation.json').read_text())
for name,digest in preparation['inputs'].items():assert hashlib.sha256((root/name).read_bytes()).hexdigest()==digest
archive=spike/'evidence/connected-artifacts.tar.gz';manifest={}
with tarfile.open(archive,'w:gz') as tar:
 for mode in records:
  directory=root/f'.build/nrf52840/spike-012-connected-{mode}'
  files=[directory/'build.log',directory/'flash.log',directory/'application/CMakeLists.txt',directory/'application/src/main.c',
   *sorted((directory/'connected').glob('*')),
   *(directory/f'firmware/zephyr/{name}' for name in ('zephyr.elf','zephyr.hex','zephyr.map','.config'))]
  for path in files:
   assert path.is_file();name=str(path.relative_to(root/'.build/nrf52840'))
   manifest[name]=hashlib.sha256(path.read_bytes()).hexdigest();tar.add(path,arcname=name)
summary={'revision':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),
 'modes':{m:{k:r[k] for k in ('elf_sha256','median_per_call_microseconds','observed_sentinel_extent_bytes','calibration','batch_results','cfsr_hfsr')} for m,r in records.items()},
 'roles_relative_percent':[(r-b)/b*100 for b,r in zip(records['packed']['median_per_call_microseconds'],records['roles']['median_per_call_microseconds'])],
 'limits':['Five batches32 calls per case, one board, two diagnostic variants; no adoption budget.',
 'Packed model/capture setup amortized once per batch. Snapshot constructs each call and does incomplete semantics with different diagnostic/window fixture.',
 'Only return counts matched on board; prior42 full semantic comparisons were native. No fresh complete on-board semantic/pixel parity claimed.',
 'Single-thread configured stack range, observed sentinel extent not control-flow bound; rendering and acquisition excluded.',
 'Instrumented image sizes include benchmark and both mechanisms; do not substitute for SPIKE009/010 production deltas.',
 'Initial extraction used ambiguous decimal J-Link dump lengths and failed the byte-count assertion; valid rerun uses explicit hexadecimal lengths.'],
 'code':{str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(spike.glob('*')) if p.is_file()},
 'archive':{'path':str(archive.relative_to(root)),'sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'files':manifest}}
(spike/'evidence/summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({'modes':summary['modes'],'roles_relative_percent':summary['roles_relative_percent']},indent=2))
