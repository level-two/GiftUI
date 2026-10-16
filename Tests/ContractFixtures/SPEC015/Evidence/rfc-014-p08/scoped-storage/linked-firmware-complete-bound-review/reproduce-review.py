"""Read-only proof replay. Never changes the original packet or builds firmware."""
import hashlib,json,pathlib,subprocess,sys,tarfile,tempfile
sys.dont_write_bytecode=True
here=pathlib.Path(__file__).resolve().parent
root=pathlib.Path('/Users/eugene/work/GiftUI')
packet=root/'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/linked-firmware-complete-bound/complete-bound-proof.tar.xz'
hashof=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert hashof(packet)=='44aff7957b6be3fdef318520c2531b0c63342a113472ffa0ff9815df18363e94'
assert hashof(here/'local_sp.py')=='d328af427c74038a211047d5d0fc63014f1093cc08e475598e87533b22d454c7'
with tempfile.TemporaryDirectory(prefix='p08-independent-proof-') as d:
 p=pathlib.Path(d)
 with tarfile.open(packet) as t:
  assert all(not pathlib.PurePosixPath(x.name).is_absolute() and '..' not in pathlib.PurePosixPath(x.name).parts and x.isfile() for x in t.getmembers())
  t.extractall(p)
 for n,h in json.loads((p/'archive-files.json').read_text()).items():
  assert hashof(p/n)==h,(n,'archive hash')
 for n,h in json.loads((p/'input-hashes.json').read_text()).items():
  assert hashof(root/n)==h,(n,'current input changed; fresh review required')
  assert hashof(p/'inputs'/n)==h,(n,'snapshot hash')
 (p/'local_sp.py').write_bytes((here/'local_sp.py').read_bytes())
 subprocess.run([sys.executable,str(p/'reproduce.py')],check=True)
 g=json.loads((p/'phase-graph.json').read_text());c=g['contexts']
 assert len(c)==1788 and len({x['address'] for x in c.values()})==1469
 assert all(x['analysis']['complete'] and not x['unresolved'] for x in c.values())
 sys.path.insert(0,str(p));import bounded
 assert bounded.bound(g['root'])[0]==95349
 assert bounded.bound(g['extra_roots']['0x2d3a8'],startup=True)[0]==312
 assert bounded.bound(g['extra_roots']['0x2d27c'])[0]==524
 assert bounded.bound(g['extra_roots']['0x2d488'])[0]==444
 assert 95349+8+112==95469 and 312+10*(524+112)==6672
 assert 170620-27648-2048+106496+8192==255612<262144
 print('PASS: independently repaired frozen proof; main 95469, ISR 6672; proposed RAM 255612')
