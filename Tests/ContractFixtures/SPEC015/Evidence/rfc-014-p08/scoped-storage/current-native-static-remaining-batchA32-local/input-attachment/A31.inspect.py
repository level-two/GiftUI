import shlex
import datetime, gzip, hashlib, io, json, os, pathlib, re, stat, struct, subprocess, sys, time, bisect
ROOT=pathlib.Path('/Users/eugene/work/GiftUI')
HERE=pathlib.Path(__file__).parent
BASE=HERE.parent
PREP=BASE/'current-callee-u02-attribution1-preparation'
RESULT=BASE/'current-native-static-remaining-batchA31-result'
COMMIT='3db4e1b13a728947569a700f35957bb4d17ef943'
NAMES=['README.md','inputs.json','roots.json','selected-rows.json','preservation.json','preservation-reads.json']
LIMIT=512*1024*1024
RESERVE=156*1024*1024
def utc(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
def dt(s): return datetime.datetime.fromisoformat(s)
def digest(b): return hashlib.sha256(b).hexdigest()
def parse_object(module,raw,symbols):
    lines=raw.decode().splitlines();heads=[]
    for i,l in enumerate(lines):
        m=re.match(r'^\s*([0-9a-fA-F]+) <([^>]+)>:\s*$',l)
        if m:heads.append((i,int(m[1],16),m[2]))
    if not heads:raise RuntimeError('no literal object headers '+module)
    alias={};alias_lines={}
    def put(name,address,line,kind):
        alias.setdefault(name,set()).add(address);alias_lines.setdefault(name,[]).append({'line':line,'kind':kind,'address':hex(address)})
    for i,l in enumerate(symbols.decode().splitlines(),1):
        m=re.match(r'^\s*([0-9a-fA-F]{8,16})\s+([tT])\s+(\S+)\s*$',l)
        if m:put(m[3],int(m[1],16),i,'nm-text')
        elif '(__TEXT,__text)' in l:
            m=re.match(r'^\s*([0-9a-fA-F]{8,16})\s+.*\s(\S+)\s*$',l)
            if m:put(m[2],int(m[1],16),i,'nm-MachO-text')
    parsed_text_symbols=len(alias)
    if not parsed_text_symbols:raise RuntimeError('unrecognized frozen symbol format '+module)
    bodies={};groups=[]
    for i,a,n in heads:
        put(n,a,i+1,'literal-header')
        if groups and groups[-1][1]==a:groups[-1][3].append(n)
        else:groups.append([i,a,n,[n]])
    for j,(lo,a,n,ns) in enumerate(groups):
        hi=groups[j+1][0] if j+1<len(groups) else len(lines)
        bodies[a]={'module':module,'address':hex(a),'symbol':n,'header_aliases':ns,'lo':lo,'hi':hi,'edges':[],'indirect':[]}
        reloc={}
        for k in range(lo,hi):
            m=re.match(r'^\s*([0-9a-fA-F]+):\s+ARM64_RELOC_(\S+)\s+(\S+)',lines[k])
            if m:reloc.setdefault(int(m[1],16),[]).append((m[2],m[3],k))
        for k in range(lo+1,hi):
            m=re.match(r'^\s*([0-9a-fA-F]+):\s+([a-z][a-z0-9.]*)\s*(.*)$',lines[k])
            if not m:continue
            site=int(m[1],16);op=m[2];operand=m[3]
            if op in ('blr','br'):bodies[a]['indirect'].append({'line':k+1,'address':hex(site),'instruction':lines[k]})
            if op in ('bl','b'):
                rr=[z for z in reloc.get(site,[]) if z[0]=='BRANCH26']
                if rr:
                    for typ,name,rline in rr:bodies[a]['edges'].append({'site':site,'line':k+1,'relocation_line':rline+1,'target_symbol':name,'kind':'relocation-call' if op=='bl' else 'relocation-tail','instruction':lines[k],'relocation':lines[rline]})
                else:
                    stub=re.search(r'symbol stub for:\s*(\S+)',operand);angle=re.search(r'<([^>]+)>',operand);dest=re.match(r'(?:0x)?([0-9a-fA-F]+)\b',operand)
                    if stub:bodies[a]['edges'].append({'site':site,'line':k+1,'target_symbol':stub[1],'kind':'stub-call','instruction':lines[k]})
                    elif dest and int(dest[1],16)!=a:bodies[a]['edges'].append({'site':site,'line':k+1,'target_address':int(dest[1],16),'kind':'direct-call' if op=='bl' else 'direct-tail','instruction':lines[k]})
            for typ,name,rline in reloc.get(site,[]):
                if typ in ('PAGE21','GOT_LOAD_PAGE21','UNSIGNED'):
                    bodies[a]['edges'].append({'site':site,'line':k+1,'relocation_line':rline+1,'target_symbol':name,'kind':'function-reference-candidate','instruction':lines[k],'relocation':lines[rline]})
    return {'module':module,'lines':lines,'aliases':alias,'alias_lines':alias_lines,'bodies':bodies,'parsed_text_symbols':parsed_text_symbols}
def resolve_edge(objects,module,edge):
    if 'target_address' in edge:
        a=edge['target_address'];o=objects[module]
        if a in o['bodies']:return (module,a),{'kind':'exact-local-address','address':hex(a)}
        return None,{'unresolved':'direct target is not an exact body entry','address':hex(a)}
    name=edge['target_symbol'];addend=0;m=re.match(r'^(.*)\+(0x[0-9a-fA-F]+)$',name)
    if m:name=m[1];addend=int(m[2],16)
    hits=[]
    order=[module]+[v for v in objects if v!=module]
    for mod in order:
        o=objects[mod]
        for a in o['aliases'].get(name,set()):
            if a in o['bodies']:hits.append(((mod,a),{'kind':'exact-symbol-address-alias','symbol':name,'addend':addend,'records':o['alias_lines'][name]}))
        if hits:break
    if len(hits)==1 and not addend:return hits[0]
    return None,{'unresolved':'ambiguous/missing exact body alias or nonzero entry addend','symbol':name,'addend':addend}
def find_candidate(objects,root,target):
    queue=[root];parent={root:None};unresolved=[]
    for node in queue:
        if node==target:
            path=[]
            while parent[node] is not None:
                prev,e,w=parent[node];path.append({'from':prev,'to':node,'edge':e,'alias_witness':w});node=prev
            return list(reversed(path)),unresolved
        mod,a=node
        for e in objects[mod]['bodies'][a]['edges']:
            dest,w=resolve_edge(objects,mod,e)
            if dest is None:
                if 'target_symbol' in e:unresolved.append({'from':node,'edge':e,'boundary':w})
            elif dest not in parent:parent[dest]=(node,e,w);queue.append(dest)
    return None,unresolved

def checked_payload(count,value,limit=8*1024*1024,reserve=0):
    data=(json.dumps(value,separators=(',',':'))+'\n').encode()
    if count+len(data)+reserve>limit:raise RuntimeError('checked payload exceeds reserved transcript')
    return data

def compact_bodies(raw,nodes):
    lines=raw.decode().splitlines();heads=[]
    for i,line in enumerate(lines):
        m=re.match(r'^\s*([0-9a-fA-F]+) <([^>]+)>:\s*$',line)
        if m:heads.append((i,int(m[1],16),m[2]))
    found={};labels={};long_labels=[];out=[];full=[]
    def label(name,line):
        if name not in labels:
            tag='S'+str(len(labels));labels[name]=tag
            # Exact symbol is durable once; display its literal semantic prefix and citation ID.
            readable=re.sub(r'33_[A-F0-9]{32}LL','[private]',name)
            long_labels.append({'id':tag,'line':line,'symbol':name,'display':readable if len(readable)<=85 else readable[:80]+'[id]'})
        return labels[name]
    for idx,address in enumerate(nodes):
        hits=[(j,h) for j,h in enumerate(heads) if h[1]==address]
        if len(hits)!=1:raise RuntimeError('fixed node header identity not unique')
        j,(lo,a,name)=hits[0];hi=heads[j+1][0] if j+1<len(heads) else len(lines)
        found[a]={'address':hex(a),'symbol':name,'lines':[lo+1,hi],'lo':lo,'hi':hi}
        full.append('N'+str(idx)+' '+hex(a)+'\n'+'\n'.join(str(k+1)+': '+lines[k] for k in range(lo,hi)))
        out.append('N'+str(idx)+'@'+hex(a)+' L'+str(lo+1)+'-'+str(hi))
        for k in range(lo+1,hi):
            text=lines[k];rel=re.match(r'^\s*([0-9a-fA-F]+):\s+ARM64_RELOC_(\S+)\s+(\S+)',text)
            if rel:out.append(str(k+1)+' R'+rel[2]+' '+label(rel[3],k+1));continue
            m=re.match(r'^\s*([0-9a-fA-F]+):\s+([a-z][a-z0-9.]*)\s*(.*)$',text)
            if not m:continue
            operand=re.sub(r' <[^>]+>','',m[3]);operand=re.sub(r'(_?\$s[\w.$]+)',lambda z:label(z[1],k+1),operand)
            # Comments retain literal text except exact long symbol names already assigned IDs.
            out.append(str(k+1)+' '+m[2]+' '+operand)
    return found,full,out,long_labels,lines
def instruction(line):
    m=re.match(r'^\s*([0-9a-fA-F]+):\s+([a-z][a-z0-9.]*)\s*(.*)$',line)
    return (int(m[1],16),m[2],m[3]) if m else None
def edges(body,aliases):
    result=[];by={}
    for n,line in body['lines']:
        v=instruction(line)
        if v and v[1] in ['bl','b']:
            m=re.match(r'(?:0x)?([0-9a-fA-F]+)\b',v[2]);edge={'site':hex(v[0]),'line':n,'kind':v[1]}
            if m:edge['to']=int(m[1],16)
            by[v[0]]=edge;result.append(edge)
    for n,line in body['lines']:
        m=re.match(r'^\s*([0-9a-fA-F]+)(?::|\s)\s*.*ARM64_RELOC_BRANCH26\s+(\S+)',line)
        if m and int(m[1],16) in by:
            edge=by[int(m[1],16)];name=m[2];edge['relocation_line']=n;edge['symbol']=name
            hits=aliases.get(name,[])
            if len(hits)==1:edge['to']=hits[0]['address']
            else:edge['unresolved']='exact relocation alias not unique';edge.pop('to',None)
    return result
def project(body,aliases):
    out=['base='+hex(body['base'])+' H='+str(body['header_line'])+' (L offsets; PC=base+4i)'];raw=[body['symbol']+' base='+hex(body['base'])+' H='+str(body['header_line'])];ids={};full={};index=0
    def intern(name):
        if name not in full:full[name]='S'+str(len(full))
        return full[name]
    for n,line in body['lines']:
        raw.append(str(n)+': '+line);v=instruction(line)
        if v:
            address,op,operand=v
            # Exact long names/comments are retained in the durable map; numeric branch targets remain literal.
            operand=re.sub(r' <([^>]+)>',lambda m:' '+intern(m[1]),operand)
            operand=re.sub(r'(_?\$s[\w.$]+)',lambda m:intern(m[1]),operand)
            operand=re.sub(r'; symbol stub for: (\S+)',lambda m:';'+m[1],operand)
            pc='' if address==body['base']+4*index else '@'+hex(address)+':'
            out.append(str(n-body['header_line'])+':'+pc+op+' '+operand);index+=1
        elif 'ARM64_RELOC_' in line:
            m=re.search(r'ARM64_RELOC_(\S+)\s+(\S+)',line)
            if m:out.append(str(n-body['header_line'])+':R'+m[1]+' '+intern(m[2]))
    for name,tag in full.items():ids[tag]={'symbol':name,'aliases':aliases.get(name,[])}
    # Display IDs carry exact destination address; full mangled identities live once in the durable map.
    shown={k:('0x'+format(v['aliases'][0]['address'],'x') if len(v['aliases'])==1 else 'retained-map') for k,v in ids.items()}
    mapbytes=(json.dumps({'body':body['symbol'],'labels':ids},separators=(',',':'))+'\n').encode();charge(len(mapbytes)*2,'exact_identity_map_write')
    with (HERE/'identity-map.ndjson').open('ab') as f:f.write(mapbytes)
    return '\n'.join(out),'\n'.join(raw)+'\n',shown

def object_metadata(b):
    if struct.unpack_from('<I',b)[0]!=0xfeedfacf:raise RuntimeError('thinARM64MachOrequired')
    ncmd=struct.unpack_from('<I',b,16)[0];at=32;sections=[];sym=None
    for _ in range(ncmd):
        cmd,size=struct.unpack_from('<II',b,at)
        if cmd==0x19:
            nsec=struct.unpack_from('<I',b,at+64)[0]
            for j in range(nsec):
                q=at+72+80*j;name=b[q:q+16].split(b'\0')[0];addr,length,offset=struct.unpack_from('<QQI',b,q+32);ro,nr=struct.unpack_from('<II',b,q+56);sections.append({'name':name,'addr':addr,'size':length,'offset':offset,'reloc':ro,'nreloc':nr})
        if cmd==2:sym=struct.unpack_from('<IIII',b,at+8)
        at+=size
    texts=[(i+1,x) for i,x in enumerate(sections) if x['name']==b'__text'];assert len(texts)==1 and sym
    sn,sec=texts[0];so,ns,st,sz=sym;names=[];aliases={};textsyms={}
    for i in range(ns):
        no,typ,sect,desc,val=struct.unpack_from('<IBBHQ',b,so+i*16);name=b[st+no:b.find(b'\0',st+no,st+sz)].decode() if no else '';names.append(name)
        if typ&0x0e==0x0e and sect==sn:
            aliases.setdefault(name,[]).append({'address':val,'nlist_index':i});textsyms.setdefault(val,[]).append(name)
    relocs={}
    for i in range(sec['nreloc']):
        off,info=struct.unpack_from('<iI',b,sec['reloc']+8*i);extern=(info>>27)&1;kind=info>>28
        if kind==2:
            if not extern:raise RuntimeError('unsupportedlocalBRANCH26relocation')
            relocs[sec['addr']+off]={'symbol':names[info&0xffffff],'type':kind,'index':i}
    bounds=sorted(set(textsyms)|{sec['addr'],sec['addr']+sec['size']});return {'aliases':aliases,'bounds':bounds,'text':sec,'relocs':relocs,'texts':textsyms,'bytes':b}
def branch_records(M):
    s=M['text'];b=M['bytes']
    def signed(v,n):return v-(1<<n) if v&(1<<(n-1)) else v
    for off in range(0,s['size'],4):
        w=struct.unpack_from('<I',b,s['offset']+off)[0];pc=s['addr']+off;op=None;to=None
        if w>>26 in (0x25,0x05):op='bl' if w>>26==0x25 else 'b';to=pc+signed(w&0x3ffffff,26)*4
        elif w&0xff000010==0x54000000:op='b.cond';to=pc+signed((w>>5)&0x7ffff,19)*4
        elif w&0x7e000000==0x34000000:op='cbnz' if w&(1<<24) else 'cbz';to=pc+signed((w>>5)&0x7ffff,19)*4
        elif w&0x7e000000==0x36000000:op='tbnz' if w&(1<<24) else 'tbz';to=pc+signed((w>>5)&0x3fff,14)*4
        elif w&0xfffffc1f==0xd61f0000:op='br'
        elif w&0xfffffc1f==0xd63f0000:op='blr'
        if op:yield pc,op,to

mode=sys.argv[1]
if mode in ('batch-limit-control','batch-limit-sample'):
    import ast
    if mode=='batch-limit-control':
        report={}
        for case,expected in [('complete',0),('overflow',2)]:
            r=subprocess.run([sys.executable,__file__,'batch-limit-sample',case],stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            (HERE/'invocation'/('batch-control-'+case+'.stdout')).write_bytes(r.stdout);(HERE/'invocation'/('batch-control-'+case+'.stderr')).write_bytes(r.stderr)
            saved=json.loads((HERE/'invocation'/('batch-control-'+case+'.json')).read_bytes());assert r.returncode==expected and not r.stderr and len(r.stdout)==saved['transcript_payload_bytes']
            assert (len(r.stdout)>10000) if case=='complete' else (saved['errors'] and b'STOP' in r.stdout)
            report[case]={'exit':r.returncode,'exact_stdout_bytes':len(r.stdout),'ledger_payload_bytes':saved['transcript_payload_bytes'],'durable_used':saved['used'],'errors':saved['errors']}
        (HERE/'invocation/batch-limit-control.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report));sys.exit(0)
    case=sys.argv[2];state={'started_utc':utc(),'used':0,'charges':{},'errors':[],'output_upper_bytes':0,'transcript_payload_bytes':0};statepath=HERE/'invocation'/('batch-control-'+case+'.json');final=False
    tree=ast.parse(pathlib.Path(__file__).read_bytes());wanted={'charge','emit','save'};defs=ast.Module(body=[x for x in tree.body if isinstance(x,ast.FunctionDef) and x.name in wanted],type_ignores=[]);exec(compile(defs,__file__,'exec'))
    status=0
    try:emit({'context':'x'*73942} if case=='complete' else {'context':'x'*(8*1024*1024)});save()
    except BaseException as exc:
        state['errors'].append(str(exc));save(emergency=True);emit({'s':'STOP','error':str(exc)},stop=True);save(emergency=True);status=2
    sys.exit(status)
if mode=='guard-flush-control':
    # Execute the actual reserved save implementation in a synthetic exhausted state.
    source=pathlib.Path(__file__).read_text();fragment=source[source.index(chr(10)+'def save(')+1:source.index(chr(10)+'def controls(')+1]
    fake={'used':4096,'charges':{},'errors':['syntheticreserveguard']};calls=[]
    def rejected_charge(n,k):calls.append((n,k));raise RuntimeError('ordinarychargeexhausted')
    ns={'json':json,'state':fake,'statepath':HERE/'invocation/guard-flush-control.json','final':False,'LIMIT':8192,'charge':rejected_charge}
    exec(fragment,ns);ns['save'](emergency=True);saved=json.loads(ns['statepath'].read_text())
    assert not calls and saved['errors']==['syntheticreserveguard'] and 4096<saved['used']<8192
    names=['_root','_constructor','_alias','_swift_allocObject'];strings=b'\0';offsets=[]
    for n in names:offsets.append(len(strings));strings+=n.encode()+b'\0'
    header=struct.pack('<IiiIIIII',0xfeedfacf,0x100000c,0,1,2,176,0,0)
    seg=struct.pack('<II16sQQQQiiII',0x19,152,b'__TEXT',0,24,256,24,7,5,1,0)
    sec=struct.pack('<16s16sQQIIIIIIII',b'__text',b'__TEXT',0,24,256,2,280,1,0x80000400,0,0,0)
    sym=struct.pack('<IIIIII',2,24,288,4,352,len(strings));text=struct.pack('<IIIIII',0x94000004,0xb4000040,0xd65f03c0,0xd503201f,0x94000000,0xd65f03c0);rel=struct.pack('<iI',16,0x2d000003)
    nl=b''.join(struct.pack('<IBBHQ',offsets[i],0x0e if i<3 else 1,1 if i<3 else 0,0,[0,16,16,0][i]) for i in range(4));blob=(header+seg+sec+sym).ljust(256,b'\0')+text+rel+nl+strings
    m=object_metadata(blob);branches=list(branch_records(m));assert m['bounds']==[0,16,24] and m['aliases']['_alias'][0]['address']==16 and branches[0]==(0,'bl',16) and branches[1]==(4,'cbz',12) and m['relocs'][16]['symbol']=='_swift_allocObject' and '_swift_allocObject' not in m['aliases']
    (HERE/'invocation/structural-control.json').write_text(json.dumps({'exactroot_constructor_alias':True,'conditionalpredicate_retained':True,'import_without_body_not_absent':True,'actual_reserved_flush_called':True,'ordinarycharge_calls':len(calls),'saved_used':saved['used']})+'\n');print('ACTUAL_GUARD_FLUSH_AND_BRANCH_ALIAS_CONTROL_PASS');sys.exit(0)
if mode=='exchange-sample':
    sample=sys.argv[2];count=0;exit_code=0
    values={'a':{'s':'AUTH'},'c':{'s':'CLOSED','sec':7199.999999},'f':{'s':'PRESERVED'}}
    try:
        value={'context':'x'*(73942-len(b'{"context":""}\n'))} if sample=='g' else ({'context':'x'*11000} if sample=='stop' else values[sample])
        data=checked_payload(count,value,8*1024*1024,256)
    except RuntimeError as exc:data=checked_payload(count,{'s':'STOP','error':str(exc)},8*1024*1024);exit_code=2
    count+=len(data);(HERE/'invocation'/('control-'+sample+'-ledger.json')).write_text(json.dumps({'counted_before_emission':count,'exit':exit_code})+'\n');sys.stdout.buffer.write(data);sys.exit(exit_code)
if mode.startswith('delivery-'):
    limit=2000;count=0;data=None;child_exit=0
    fake=b'0000000000000000 <_root>:\n 0: mov x0, #0x1\n 4: bl 0x4 <'+b'_$s4Test'+b'A'*400+b'>\n 4: ARM64_RELOC_BRANCH26 '+b'_$s4Test'+b'A'*400+b'\n 8: cbz x0, 0xc\n c: ret\n'
    _,_,out,labels,_=compact_bodies(fake,[0])
    try:data=checked_payload(count,{'context':out,'labels':[{'id':v['id'],'line':v['line'],'display':v['display']} for v in labels]} if mode=='delivery-good' else {'context':'x'*3000},limit,256)
    except RuntimeError as exc:data=checked_payload(count,{'state':'STOP','error':str(exc)},limit);child_exit=2
    count+=len(data);(HERE/'invocation'/(mode+'-ledger.json')).write_text(json.dumps({'counted':count,'exit':child_exit})+'\n');sys.stdout.buffer.write(data);sys.exit(child_exit)
if mode=='control':
    result={}
    for name,expected in [('delivery-good',0),('delivery-overflow',2)]:
        r=subprocess.run([sys.executable,__file__,name],stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        (HERE/'invocation'/(name+'.stdout')).write_bytes(r.stdout);(HERE/'invocation'/(name+'.stderr')).write_bytes(r.stderr)
        ledger=json.loads((HERE/'invocation'/(name+'-ledger.json')).read_bytes());assert r.returncode==expected and not r.stderr and ledger['counted']==len(r.stdout) and r.stdout.endswith(b'\n')
        result[name]={'exit':r.returncode,'actual_stdout_bytes':len(r.stdout),'counted_before_emission':ledger['counted']}
    result.update({'state':'DELIVERY_CONTROL_PASS','frozen_evidence_reads':0,'utc':utc()});(HERE/'invocation/control.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result));sys.exit(0)
if mode=='auth':
    startup_path=HERE/'invocation/startup.json'
    if startup_path.exists(): raise RuntimeError('actual startup already exists')
    startup=json.loads((HERE/'invocation/freeze.json').read_bytes());startup['started_utc']=utc()
    startup_path.write_text(json.dumps(startup,indent=2)+'\n')
startup=json.loads((HERE/'invocation/startup.json').read_bytes())
statepath=HERE/'state.json'
state=json.loads(statepath.read_bytes()) if statepath.exists() else {'started_utc':startup['started_utc'],'used':0,'charges':{},'transcript_payload_bytes':0,'groups':{},'auth':[],'errors':[]}
final=mode=='finish'
request_bytes=(HERE/'requests.json').read_bytes()
if digest(request_bytes)!=startup['requests_sha256']:raise RuntimeError('frozen requests changed')
request_plan=json.loads(request_bytes)
if mode in ('follow','close'):
    cmd='python3 /tmp/g31 '+('r ' if mode=='follow' else 'c ')+shlex.quote(sys.argv[2])
    args={'cmd':cmd,'max_output_tokens':20000 if mode=='follow' else 1000}
    code='// @exec: {"max_output_tokens":30000}\n'+'const r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);'
    request={'counted_UTF8_bytes':len(code.encode())+len(json.dumps(args,separators=(',',':')).encode()),'request_code':code,'nested_arguments':args}
    state.setdefault('actual_dynamic_requests',[]).append(request)
else:request=request_plan[mode]
state['transcript_payload_bytes']+=request['counted_UTF8_bytes']
# Request guard is inside the reserved durable exception path below.
state.setdefault('request_records',[]).append(request)

def charge(n,k):
    if not final and (dt(utc())-dt(state['started_utc'])).total_seconds()>7200:raise RuntimeError('7200secondtotalsession')
    if (dt(utc())-dt(state['started_utc'])).total_seconds()>7200: raise RuntimeError('7200-second ceiling')
    if state['used']+n+(0 if final else RESERVE)>LIMIT: raise RuntimeError('512MiB processing/final reserve')
    state['used']+=n; state['charges'][k]=state['charges'].get(k,0)+n
    if any(v in k for v in ['write','capture','forward','script_prepare','startup']):
        state['output_upper_bytes']=state.get('output_upper_bytes',1048576)+n
        if state['output_upper_bytes']+state.get('transcript_payload_bytes',0)+(0 if final else 1048576)>8*1024*1024:raise RuntimeError('cumulative output upper ceiling')
def read(p,k='read',size=None,sha=None):
    p=pathlib.Path(p); p=p if p.is_absolute() else ROOT/p
    if not p.is_relative_to(ROOT):
        if str(p) not in [refresh['OBJECT_TOOL']['path'],refresh['NM_TOOL']['path']]:raise RuntimeError('unapproved external input')
        n=p.stat().st_size
        if size is not None and n!=size:raise RuntimeError('tool size mismatch')
        charge(n,k);b=p.read_bytes()
        if sha is not None and digest(b)!=sha:raise RuntimeError('tool hash mismatch')
        return b
    cur=ROOT
    for part in p.relative_to(ROOT).parts:
        cur=cur/part; s=cur.lstat(); charge(256+len(str(cur)),'metadata')
        if stat.S_ISLNK(s.st_mode): raise RuntimeError('symlink')
    n=p.stat().st_size
    if size is not None and n!=size: raise RuntimeError('size mismatch '+str(p))
    charge(n,k); b=p.read_bytes()
    if sha is not None and digest(b)!=sha: raise RuntimeError('hash mismatch '+str(p))
    return b
def git(args,n,k='git_auth'):
    charge(n+4096,k)
    r=subprocess.run(['git']+args,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    if r.returncode or r.stderr or len(r.stdout)>n: raise RuntimeError('Git operation failed or bound exceeded')
    return r.stdout
def emit(v,stop=False):
    b=checked_payload(state['transcript_payload_bytes']+state.get('output_upper_bytes',1048576),v,8*1024*1024,0 if stop else 524288)
    if not stop:charge(len(b)*4,'payload_write_capture_forward')
    # STOP capture/forward processing is covered by the per-invocation8192-byte escrow.
    state['transcript_payload_bytes']+=len(b)
    with (HERE/'invocation/output.ndjson').open('ab') as f:f.write(b)
    sys.stdout.buffer.write(b)
def save(emergency=False):
    for _ in range(5):
        b=(json.dumps(state,separators=(',',':'))+'\n').encode()
        state['state_bytes']=len(b)
    
    if emergency:
        state['used']+=len(b);state['charges']['reserved_failure_state_write']=state['charges'].get('reserved_failure_state_write',0)+len(b)
        if state['used']>LIMIT:state['errors'].append('hardprocessingceilingexceededduringreservedflush')
    elif not final:charge(len(b),'state_write')
    statepath.write_bytes((json.dumps(state,separators=(',',':'))+'\n').encode())
def controls():
    out={}
    for name in NAMES:
        p=PREP/name; b=read(p,'control_read'); g=git(['show',COMMIT+':'+str(p.relative_to(ROOT))],len(b),'control_git')
        if b!=g: raise RuntimeError('control mismatch '+name)
        out[name]=b
    if sum(map(len,out.values()))>2*1024*1024: raise RuntimeError('control bound')
    return out
def preservation(pres):
    markers={}
    for p,r in pres['metadata_only_operations']['marker_lstat'].items():
        s=pathlib.Path(p).lstat(); charge(512+len(p),'preservation_metadata')
        identity=[s.st_dev,s.st_ino]
        if identity!=r['identity']: raise RuntimeError('marker identity')
        markers[p]=identity
    desc=pres['metadata_only_operations']['cache_directory_list_once_per_preservation_check']
    members=sorted(os.listdir(ROOT/desc['path'])); charge(len(json.dumps(members))+1024,'cache_metadata')
    if members!=desc['exact_member_names']: raise RuntimeError('cache membership')
    desc=pres['exact_diff_operation']
    for r in desc['base_blobs']:
        for spec in [r['exact_blob_commit']+':'+r['path'],':'+r['path']]:
            b=git(['show',spec],r['bytes'],'diff_base')
            if len(b)!=r['bytes'] or digest(b)!=r['sha256']: raise RuntimeError('diff base')
    charge(desc['worktree_payload_bytes_per_invocation']+desc['index_base_payload_bytes_per_invocation'],'diff_payload')
    b=git(desc['argv'][1:],desc['stdout_bytes'],'diff_stdout')
    if len(b)!=desc['stdout_bytes'] or digest(b)!=desc['stdout_sha256']: raise RuntimeError('dirty diff')
    return {'utc':utc(),'markers':markers,'cache_members':members,'dirty_diff_sha256':digest(b),'dirty_diff_bytes':len(b)}
def provider_read(desc):
    p=pathlib.Path(desc['path']);ss=p.stat()
    if [ss.st_size,ss.st_dev,ss.st_ino,ss.st_mtime_ns]!=[desc['file_bytes'],desc['device'],desc['inode'],desc['mtime_ns']]:raise RuntimeError('installed cache file identity changed')
    charge(desc['bytes']*2,'installed_provider_exact_extent_read_hash')
    with p.open('rb') as f:f.seek(desc['offset']);b=f.read(desc['bytes'])
    if len(b)!=desc['bytes'] or digest(b)!=desc['sha256']:raise RuntimeError('installed provider exact extent changed')
    return b
def provider_auth():
    b=read(HERE/'provider-slices.json','provider_descriptor_auth')
    if digest(b)!=startup['provider_slices_sha256']:raise RuntimeError('provider slice descriptor changed')
    meta=json.loads(b);provider_read(meta['cache_map'])
    for c in meta['cache_files'].values():provider_read(c['header']);provider_read(c['mapping'])
    for p in meta['providers'].values():
        for d in p['slices']:provider_read(d)
    for d in meta.get('extra_slices',[]):provider_read(d)
    return {'descriptor_sha256':digest(b),'provider_uuids':{n:p['uuid'] for n,p in meta['providers'].items()},'exact_extent_bytes_per_check':sum(d['bytes'] for p in meta['providers'].values() for d in p['slices'])+meta['cache_map']['bytes']}
refresh=json.loads((HERE/'refresh.json').read_bytes())
try:
    if state['transcript_payload_bytes']+state.get('output_upper_bytes',1048576)+1048576>8*1024*1024:raise RuntimeError('shared8MiBrequestplusfinalreserve')
    charge((HERE/'refresh.json').stat().st_size*2,'refresh_control')
    if digest((HERE/'refresh.json').read_bytes())!=startup['refresh_sha256']:raise RuntimeError('frozen refresh changed')
    charge(8192,'stop_capture_write_processing_escrow')
    charge((HERE/'deliver.py').stat().st_size*3+4096,'file_delivery_source_alias_read_decode_hash')
    if digest((HERE/'deliver.py').read_bytes())!=startup['delivery_sha256'] or os.readlink('/tmp/g31')!=startup['alias_target']:raise RuntimeError('frozen delivery/alias changed')
    charge(pathlib.Path(__file__).stat().st_size*3,'script_prepare_interpreter_hash')
    charge(startup['preflight_processing_upper_bytes'] if mode=='auth' else 0,'preflight_code_orientation_upper_charge')
    charge((HERE/'requests.json').stat().st_size*2,'request_plan_read_write')
    if digest(pathlib.Path(__file__).read_bytes())!=startup['helper_sha256']: raise RuntimeError('frozen helper changed')
    charge((HERE/'invocation/startup.json').stat().st_size*2+2048,'startup_capture_and_wrapper')
    if mode=='auth':
        if RESULT.exists() or statepath.exists(): raise RuntimeError('fresh destination/state already exists')
        c=controls(); ins=json.loads(c['inputs.json']); pres=json.loads(c['preservation-reads.json']); selected=json.loads(c['selected-rows.json'])
        assert len(ins['files'])==79 and sum(r['bytes'] for r in ins['files'])==126694715
        assert len(pres['files'])==48 and sum(r['bytes'] for r in pres['files'])==875385
        assert not set(r['path'] for r in ins['files'])&set(r['path'] for r in pres['files'])
        assert len(selected['rows'])==56 and sum(r['site_count'] for r in selected['rows'])==1892
        for r in ins['files']:
            b=read(r['path'],'evidence_auth',r['bytes'],r['sha256']); g=git(['show',r['exact_blob_commit']+':'+r['path']],r['bytes'])
            if len(g)!=r['bytes'] or digest(g)!=r['sha256']: raise RuntimeError('Git evidence mismatch')
            state['auth'].append({'path':r['path'],'bytes':r['bytes'],'sha256':r['sha256'],'later_access':r['later_access']})
        for r in pres['files']:
            rr=refresh.get(r['path'],r); read(rr['path'],'preservation_auth',rr['bytes'],rr['sha256'])
        for r in refresh.values():read(r['path'],'current_refresh_auth',r['bytes'],r['sha256'])
        if git(['rev-parse','HEAD'],128).decode().strip()!=startup['expected_HEAD']:raise RuntimeError('unexpected HEAD advance')
        state['before']=preservation(pres);state['provider_before']=provider_auth()
        state['controls']={n:{'bytes':len(b),'sha256':digest(b)} for n,b in c.items()}
        # No selected payload semantics until a group clock starts.
        emit({'s':'AUTH'})
    elif mode=='metadata':
        emit({'disassembly_bytes':{r['path'].split('/')[-1]:r['bytes'] for r in state['auth'] if r['path'].endswith('-disassembly.stdout')},'remaining_before_reserve':LIMIT-RESERVE-state['used']})
    elif mode=='group':
        gid='U02-X28';state['groups'][gid]={'started_utc':utc(),'status':'ACTIVE','context_emitted':False,'model_examined':False};save()
        roots=json.loads(read(PREP/'roots.json','exact_root_assignment',state['controls']['roots.json']['bytes'],state['controls']['roots.json']['sha256']))
        rootnames=[h[1] for j in roots['root_object_joins'] for h in j['exact_disassembly_headers'] if h[0]=='P08CounterRuntime'];assert len(rootnames)==3
        ob=read(refresh['.build/contracts/p08-counter-ob4qm63e/P08CounterRuntime.o']['path'],'selected_object_structure');charge(len(ob),'object_structure_decode');M=object_metadata(ob)
        aliases=M['aliases'];bounds=M['bounds'];section=M['text'];relocs=M['relocs'];texts=M['texts'];graph={};indirect={};imports=[]
        for r in rootnames:
            if len(aliases.get(r,[]))!=1:raise RuntimeError('exactfrozenrootnotunique '+r)
        rootaddrs=[aliases[r][0]['address'] for r in rootnames]
        def owner(pc):
            i=bisect.bisect_right(bounds,pc)-1
            return bounds[i] if 0<=i<len(bounds)-1 and pc<bounds[i+1] else None
        sites=[];allcalls=[]
        for pc,op,target in branch_records(M):
            fr=owner(pc)
            if fr is None:continue
            e={'site':pc,'op':op};rr=relocs.get(pc)
            if rr:
                e.update({'symbol':rr['symbol'],'relocation_index':rr['index'],'type':rr['type']})
                if rr['type']!=2:raise RuntimeError('nonBRANCH26relocationonbranch')
                hits=aliases.get(rr['symbol'],[])
                target=hits[0]['address'] if len(hits)==1 else None
                if rr['symbol']=='_swift_allocObject':sites.append({'caller':fr,'site':pc,'symbol':rr['symbol'],'relocation_index':rr['index']})
            e['target']=target
            if op in ['blr','br']:indirect.setdefault(fr,[]).append(e)
            elif target is not None and owner(target) is not None:
                e['to']=owner(target);e['entry_addend']=target-e['to']
                if e['to']!=fr:graph.setdefault(fr,[]).append(e)
            elif rr:imports.append({'caller':fr,**e})
            allcalls.append({'caller':fr,**e})
        parents={x:None for x in rootaddrs};queue=list(rootaddrs)
        for node in queue:
            for e in graph.get(node,[]):
                to=e['to']
                if to not in parents:parents[to]=(node,e);queue.append(to)
        for x in sites:
            n=x['caller'];chain=[]
            if n in parents:
                while parents[n] is not None:
                    prev,e=parents[n];chain.append({'from':prev,'to':n,'edge':e});n=prev
                x['root']=n;x['path']=list(reversed(chain))
            x['semantic']='UNEXAMINED'
        reachable=[x for x in sites if 'path' in x]
        if not reachable:raise RuntimeError('nolocalrootedallocatorfrontier; indirect/crossmodulecallsretainednotabsence')
        chosen=min(reachable,key=lambda x:(len(x['path']),sum(bounds[bisect.bisect_left(bounds,n)+1]-n for n in [x['root']]+[e['to'] for e in x['path']]),x['site']))
        nodes=list(dict.fromkeys([chosen['root']]+[e['to'] for e in chosen['path']]))
        # Exact function ranges, no whole-module textual decoder walk.
        bodies={};decoder=[]
        for addr in nodes:
            ix=bounds.index(addr);end=bounds[ix+1];argv=[refresh['OBJECT_TOOL']['path'],'--disassemble','--reloc','--no-show-raw-insn','--start-address='+hex(addr),'--stop-address='+hex(end),str(ROOT/refresh['.build/contracts/p08-counter-ob4qm63e/P08CounterRuntime.o']['path'])]
            charge(len(ob),'selected_decoder_object_input');r=subprocess.run(argv,stdout=subprocess.PIPE,stderr=subprocess.PIPE);charge(len(r.stdout)*2+len(r.stderr),'selected_decoder_output_and_decode');assert r.returncode==0 and not r.stderr
            lines=[];head=None
            for n,line in enumerate(r.stdout.decode().splitlines(),1):
                m=re.match(r'^\s*([0-9a-fA-F]+) <([^>]+)>:',line)
                if m and int(m[1],16)==addr:head=(n,m[2]);continue
                if head and (v:=instruction(line)) and addr<=v[0]<end:lines.append([n,line])
                elif head and 'ARM64_RELOC_' in line:lines.append([n,line])
            if head is None:raise RuntimeError('selectiveexactheadernotfound '+hex(addr))
            body={'base':addr,'symbol':head[1],'header_line':head[0],'lines':lines};bodies[addr]=body
            decoder.append({'argv':argv,'exit':r.returncode,'stdout_sha256':digest(r.stdout),'bytes':len(r.stdout),'range':[hex(addr),hex(end)]})
            charge(len(r.stdout),'selected_raw_capture_write');(HERE/('range-'+hex(addr)+'.stdout')).write_bytes(r.stdout)
        projections=[];raw=[];ident=[]
        for node in nodes:
            text,rr,ids=project(bodies[node],aliases);projections.append({'base':hex(node),'H':bodies[node]['header_line'],'code':text});raw.append(rr);ident.append({'base':hex(node),'symbol':bodies[node]['symbol'],'ids':ids})
        old=json.loads(read(refresh['OLD_MACHINE']['path'],'oldfrontieridentityreference'))['after']['other_allocator_sites'];reconciliation=[]
        for x in old:
            hits=aliases.get(x['caller'],[]);matches=[]
            if len(hits)==1:
                delta=int(x['site'],16)-int(x['caller_address'],16);matches=[z for z in sites if z['caller']==hits[0]['address'] and z['site']-z['caller']==delta]
            reconciliation.append({'old_caller':x['caller'],'old_site':x['site'],'new_sites':[hex(z['site']) for z in matches],'status':'exactsymbol+offsetmatch' if len(matches)==1 else 'UNRESOLVED_NOT_REMOVED'})
        meta=json.loads(read(HERE/'provider-slices.json','provider_descriptor_decode'));got=next(x for x in meta['extra_slices'] if x['role']=='opaque-getter-GOT-slot');slot=provider_read(got)
        frontier={'object':refresh['.build/contracts/p08-counter-ob4qm63e/P08CounterRuntime.o'],'all_allocators':sites,'roots':[{ 'symbol':n,'address':hex(aliases[n][0]['address'])} for n in rootnames],'chosen':chosen,'selected_identities':ident,'decoder':decoder,'old_to_new':reconciliation,'indirect_on_reachable_nodes':[{ 'caller':hex(k),'sites':v} for k,v in indirect.items() if k in parents],'imported_calls_on_reachable_nodes':[e for e in imports if e['caller'] in parents],'boundary':'Currentobjectexactstructuralclosureonly; crossmodule/indirectoriginsnotassumedabsent'}
        fb=(json.dumps(frontier,indent=2)+'\n').encode();charge(len(fb)*2,'frontier_projection_write');(HERE/'current-frontier.json').write_bytes(fb)
        rb=('\n'.join(raw)+'\n').encode();assert len(rb)<=1048576 and rb.count(b'\n')<=16384;charge(len(rb)*2,'context_write');(HERE/'context.txt').write_bytes(rb)
        state['focus']={'object':frontier['object'],'frontier_sha256':digest(fb),'allocator_sites':len(sites),'selected':chosen,'decoder':decoder,'context_sha256':digest(rb),'extracted':True,'emitted':False,'model_examined':False}
        value={'s':'SELECTIVE_CURRENT_FULL_FRONTIER','start':state['groups'][gid]['started_utc'],'objectSHA':frontier['object']['sha256'],'roots':[hex(x) for x in rootaddrs],'allocator_sites':len(sites),'rooted_local_sites':len(reachable),'chosen':{'site':hex(chosen['site']),'caller':hex(chosen['caller']),'path':[[hex(e['from']),hex(e['to']),hex(e['edge']['site']),e['edge']['op']] for e in chosen['path']]},'complete_bodies':projections,'identities':[{'base':v['base'],'symbol':v['symbol'] if len(v['symbol'])<130 else 'current-frontier.json exactsymbol'} for v in ident],'stdioGOT':{'address':hex(got['vmaddr']),'raw':slot.hex(),'boundary':'Encodedinstalledslotnotliveprocessstate;23-27lemmasreused,noR-to-Sinferencewithoutbinding/format'},'other_frontier':'Exact17countnotassumed; allremainingrooted/indirect/importedcasesretainedstructurallyUNEXAMINED,notexternalabsence. Completecallee/cold/providerallocationnotinferred.'}
        remaining=sum(request_plan[k]['counted_UTF8_bytes'] for k in ['clock','close-provider-gap','finish'])+240+256
        packet=checked_payload(state['transcript_payload_bytes'],value,8*1024*1024,remaining);state['joint_packet_bytes']=len(packet)
        if (dt(utc())-dt(state['started_utc'])).total_seconds()>7200:raise RuntimeError('7200sextractionstopbeforeemission')
        emit(value);state['focus']['emitted']=True;state['groups'][gid]['context_emitted']=True
    elif mode=='follow':
        addresses=json.loads(sys.argv[2]);assert len(addresses)<=12 and all(isinstance(x,int) for x in addresses)
        ob=read(refresh['.build/contracts/p08-counter-ob4qm63e/P08CounterRuntime.o']['path'],'follow_object_structure');charge(len(ob),'follow_structure_decode');M=object_metadata(ob);aliases=M['aliases'];bounds=M['bounds'];shown=[];raw=[]
        for addr in addresses:
            ix=bounds.index(addr);end=bounds[ix+1];argv=[refresh['OBJECT_TOOL']['path'],'--disassemble','--reloc','--no-show-raw-insn','--start-address='+hex(addr),'--stop-address='+hex(end),str(ROOT/refresh['.build/contracts/p08-counter-ob4qm63e/P08CounterRuntime.o']['path'])]
            charge(len(ob),'follow_decoder_object_input');r=subprocess.run(argv,stdout=subprocess.PIPE,stderr=subprocess.PIPE);charge(len(r.stdout)*2+len(r.stderr),'follow_decoder_output_decode');assert r.returncode==0 and not r.stderr
            lines=[];head=None
            for n,line in enumerate(r.stdout.decode().splitlines(),1):
                m=re.match(r'^\s*([0-9a-fA-F]+) <([^>]+)>:',line)
                if m and int(m[1],16)==addr:head=(n,m[2]);continue
                if head and (v:=instruction(line)) and addr<=v[0]<end:lines.append([n,line])
                elif head and 'ARM64_RELOC_' in line:lines.append([n,line])
            assert head is not None
            body={'base':addr,'symbol':head[1],'header_line':head[0],'lines':lines};text,rr,ids=project(body,aliases)
            raw.append(rr);shown.append({'base':hex(addr),'end':hex(end),'symbol':head[1],'code':text,'ids':ids,'decoderSHA':digest(r.stdout)})
            charge(len(r.stdout),'follow_raw_capture_write');(HERE/('range-'+hex(addr)+'.stdout')).write_bytes(r.stdout)
        rb=('\n'.join(raw)+'\n').encode();old=read(HERE/'context.txt','follow_existing_excerpt');assert len(old)+len(rb)<=1048576 and old.count(b'\n')+rb.count(b'\n')<=16384
        charge(len(rb)*2,'follow_context_write');(HERE/'context.txt').write_bytes(old+rb)
        emit({'s':'FOLLOW','bodies':shown})
    elif mode=='clock':
        g=state['groups']['U02-X28'];emit({'s':'CLOCK','sec':(dt(utc())-dt(g['started_utc'])).total_seconds()})
    elif mode=='close':
        gid='U02-X28'; g=state['groups'][gid]
        if g['status']!='ACTIVE': raise RuntimeError('group inactive')
        state['model_selected_disposition']=json.loads(sys.argv[2])
        state['model_examination_scope']='Actualfullcurrentrootedallocatorfrontier; qualified23–27provid erlemmasreused. Othercontextsmodelunexaminedunlessexplicitfinding.'
        if state.get('focus',{}).get('emitted'):
            state['focus']['model_examined']=True;g['model_examined']=True
        g['ended_utc']=utc();g['elapsed_UTC_seconds']=(dt(g['ended_utc'])-dt(g['started_utc'])).total_seconds();g['status']='CLOSED'
        if (dt(utc())-dt(state['started_utc'])).total_seconds()>7200: state['errors'].append('7200-second session exceeded')
        emit({'s':'CLOSED','sec':g['elapsed_UTC_seconds']})
    elif mode=='finish':
        c=controls(); ins=json.loads(c['inputs.json']); pres=json.loads(c['preservation-reads.json'])
        for r in ins['files']: read(r['path'],'final_evidence_hash',r['bytes'],r['sha256'])
        for r in pres['files']:
            rr=refresh.get(r['path'],r); read(rr['path'],'final_preservation_hash',rr['bytes'],rr['sha256'])
        for r in refresh.values():read(r['path'],'final_current_refresh_auth',r['bytes'],r['sha256'])
        if git(['rev-parse','HEAD'],128).decode().strip()!=startup['expected_HEAD']:raise RuntimeError('HEAD changed during proof')
        state['after']=preservation(pres);state['provider_after']=provider_auth();state['finished_utc']=utc()
        if any(g.get('status')=='ACTIVE' for g in state['groups'].values()):raise RuntimeError('semantic group not closed')
        charge(524288,'final_capture_snapshot_metadata_write_upper')
        RESULT.mkdir()
        focus=state.get('focus',{});row=focus.get('row');g=state['groups'].get('U02-X28',{})
        result={'old_frozen_universe':{'groups':56,'sites':1892,'roots':3,'status':'IMMUTABLE BASELINE; no current tuple substitution'},'model_status':state.get('model_selected_disposition','UNEXAMINED'),'current_focus':focus,'baseline_refresh':refresh,'qualification':'Model-selected disposition applies only when model_examined=true, total session<=7200 seconds and no errors; no allocator success/cost/cold/zero-heap claim','batch17_STOP_preserved':True}
        files={'rows.json':json.dumps(result,indent=2).encode(),'inspection-accounting.json':json.dumps(state,indent=2).encode(),'preservation.json':json.dumps({'before':state.get('before'),'after':state['after'],'controls':state.get('controls'),'inputs_authenticated':state['auth']},indent=2).encode(),'retained-excerpts.txt':read(HERE/'context.txt','final_context_reuse') if focus else b'','README.md':b'# Current diagnostic provider21\n\nOne amended-accounting attempt; retained exact focused context and partition. No Static allocation, heap/cold, complete-callee or P08 claim follows from reachability. See rows.json, exact raw citations/context and model result. Other frozen sites remain unexamined.\n'}
        if sum(map(len,files.values()))>8*1024*1024:raise RuntimeError('output ceiling')
        for n,b in files.items():charge(len(b),'semantic_result_write');(RESULT/n).write_bytes(b)

        emit({'s':'PRESERVED'})
    else: raise RuntimeError('unknown action')
except BaseException as exc:
    state['errors'].append(type(exc).__name__+': '+str(exc)); state['terminal_utc']=utc()
    save(emergency=True); (HERE/'invocation/terminal.json').write_text(json.dumps({'state':'STOP','error':state['errors'][-1],'utc':utc()})+'\n')
    emit({'s':'STOP','error':state['errors'][-1]},stop=True);save(emergency=True);sys.exit(2)
save()
(HERE/'invocation'/('terminal-'+mode+('-'+sys.argv[2] if len(sys.argv)>2 else '')+'.json')).write_text(json.dumps({'state':'COMPLETE','exit':0,'utc':utc()})+'\n')

if final and RESULT.exists():
    (RESULT/'inspection-accounting.json').write_text(json.dumps(state,indent=2)+'\n')
