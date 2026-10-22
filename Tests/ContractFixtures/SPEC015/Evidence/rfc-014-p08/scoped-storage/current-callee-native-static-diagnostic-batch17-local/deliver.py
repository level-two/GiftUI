import pathlib,subprocess,sys,json,hashlib,os
HERE=pathlib.Path(__file__).resolve().parent
ROOT=pathlib.Path('/Users/eugene/work/GiftUI')
def capture(label,args):
    child=subprocess.run([sys.executable,str(HERE/'inspect.py')]+args,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    for suffix,data in [('stdout',child.stdout),('stderr',child.stderr),('exit.json',(json.dumps({'exit':child.returncode})+'\n').encode())]:(HERE/'invocation'/(label+'-exit.json' if suffix=='exit.json' else label+'.'+suffix)).write_bytes(data)
    return child
if sys.argv[1]=='control':
    plan=json.loads((HERE/'requests.json').read_bytes());records={}
    for sample in ['a','g','c','f','stop']:
        r=capture('control-'+sample,['exchange-sample',sample]);ledger=json.loads((HERE/'invocation'/('control-'+sample+'-ledger.json')).read_bytes())
        assert not r.stderr and ledger['counted_before_emission']==len(r.stdout) and r.returncode==(2 if sample=='stop' else 0) and r.stdout.endswith(b'\n')
        records[sample]={'exit':r.returncode,'stdout':len(r.stdout),'precount':ledger['counted_before_emission']}
    assert records['g']['stdout']==8600
    request_upper=sum(plan[k]['counted_UTF8_bytes'] for k in ['auth','group','close-batch-native-static-traces-examined','finish'])
    upper=request_upper+8600+80+80+80+256
    assert upper<=10000
    result={'state':'WHOLE_EXCHANGE_CONTROL_PASS','context_bytes':8600,'request_upper':request_upper,'other_payload_upper':240,'STOP_reserve':256,'total_upper':upper,'slack':10000-upper,'children':records,'frozen_evidence_reads':0}
    (HERE/'invocation/control.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result));sys.exit(0)
freeze=json.loads((HERE/'invocation/freeze.json').read_bytes())
assert hashlib.sha256(pathlib.Path(__file__).resolve().read_bytes()).hexdigest()==freeze['delivery_sha256']
assert os.readlink('/tmp/g17')==freeze['alias_target']
label,args={'a':('auth',['auth']),'g':('group',['group']),'c':('close',['close','U02-X28','metadata-proof-gap']),'p':('close',['close','U02-X28','batch-native-static-traces-examined']),'f':('finish',['finish'])}[sys.argv[1]]
r=capture(label,args);sys.stdout.buffer.write(r.stdout);sys.exit(r.returncode)
