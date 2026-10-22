import pathlib,subprocess,sys,json,hashlib,os
HERE=pathlib.Path(__file__).resolve().parent
ROOT=pathlib.Path('/Users/eugene/work/GiftUI')
def capture(label,args):
    child=subprocess.run([sys.executable,str(HERE/'inspect.py')]+args,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    for suffix,data in [('stdout',child.stdout),('stderr',child.stderr),('exit.json',(json.dumps({'exit':child.returncode})+'\n').encode())]:(HERE/'invocation'/(label+'-exit.json' if suffix=='exit.json' else label+'.'+suffix)).write_bytes(data)
    return child
freeze=json.loads((HERE/'invocation/freeze.json').read_bytes())
assert hashlib.sha256(pathlib.Path(__file__).resolve().read_bytes()).hexdigest()==freeze['delivery_sha256']
assert os.readlink('/tmp/g21')==freeze['alias_target']
label,args={'a':('auth',['auth']),'g':('group',['group']),'p':('provider',['provider']),'c':('close',['close','U02-X28','provider-gap']),'k':('close',['close','U02-X28','provider-gap']),'f':('finish',['finish'])}[sys.argv[1]]
r=capture(label,args);sys.stdout.buffer.write(r.stdout);sys.exit(r.returncode)
