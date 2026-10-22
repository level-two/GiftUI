import pathlib,subprocess,sys,json
H=pathlib.Path(__file__).parent
if len(sys.argv)>1:
 data=(json.dumps({'s':'JOINT','bodies':['@0 H1\n1:cbz x0, 0x10\n2:bl 0x20 S0\n3:ret','@0x20 H9\n1:bl 0x30 S0\n2:ret'],'ids':{'S0':'exact-map'},'type':'T'*700,'raw':'0'*64,'literal':'x'*6500},separators=(',',':'))+'\n').encode()
 if sys.argv[1]=='stop':data=b'x'*10000
 upper=530+len(data)+160+256
 if upper>10000:data=(json.dumps({'s':'STOP','error':'whole exchange reserve'},separators=(',',':'))+'\n').encode();exitcode=2
 else:exitcode=0
 (H/'invocation'/('control-'+sys.argv[1]+'-ledger.json')).write_text(json.dumps({'before_emit':len(data),'exit':exitcode,'whole_exchange_upper':upper})+'\n');sys.stdout.buffer.write(data);sys.exit(exitcode)
records={}
for case in ['joint','stop']:
 r=subprocess.run([sys.executable,__file__,case],stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 for suffix,b in [('stdout',r.stdout),('stderr',r.stderr),('exit.json',(json.dumps({'exit':r.returncode})+'\n').encode())]:(H/'invocation'/('control-'+case+'.'+suffix)).write_bytes(b)
 l=json.loads((H/'invocation'/('control-'+case+'-ledger.json')).read_bytes());assert l['before_emit']==len(r.stdout) and not r.stderr and r.returncode==(2 if case=='stop' else 0)
 records[case]=l
(H/'invocation/control.json').write_text(json.dumps({'state':'PASS','frozen_semantic_reads':0,'records':records},indent=2)+'\n');print(json.dumps(records))
