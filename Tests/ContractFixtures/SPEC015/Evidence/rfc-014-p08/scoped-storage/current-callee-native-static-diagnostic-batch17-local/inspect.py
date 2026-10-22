import datetime, gzip, hashlib, io, json, os, pathlib, re, stat, subprocess, sys, time
ROOT=pathlib.Path('/Users/eugene/work/GiftUI')
HERE=pathlib.Path(__file__).parent
BASE=HERE.parent
PREP=BASE/'current-callee-u02-attribution1-preparation'
RESULT=BASE/'current-callee-native-static-diagnostic-batch17-result'
COMMIT='3db4e1b13a728947569a700f35957bb4d17ef943'
NAMES=['README.md','inputs.json','roots.json','selected-rows.json','preservation.json','preservation-reads.json']
LIMIT=512*1024*1024
RESERVE=167*1024*1024
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

def checked_payload(count,value,limit=10000,reserve=0):
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
mode=sys.argv[1]
if mode=='exchange-sample':
    sample=sys.argv[2];count=0;exit_code=0
    values={'a':{'s':'AUTH'},'c':{'s':'CLOSED','sec':89.999999},'f':{'s':'PRESERVED'}}
    try:
        value={'context':'x'*(8600-len(b'{"context":""}\n'))} if sample=='g' else ({'context':'x'*11000} if sample=='stop' else values[sample])
        data=checked_payload(count,value,10000,256)
    except RuntimeError as exc:data=checked_payload(count,{'s':'STOP','error':str(exc)},10000);exit_code=2
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
request=request_plan[('close-'+sys.argv[3]) if mode=='close' else mode]
state['transcript_payload_bytes']+=request['counted_UTF8_bytes']
if state['transcript_payload_bytes']>10000: raise RuntimeError('request transcript ceiling')
state.setdefault('request_records',[]).append(request)

def charge(n,k):
    if (dt(utc())-dt(state['started_utc'])).total_seconds()>7200: raise RuntimeError('7200-second ceiling')
    if state['used']+n+(0 if final else RESERVE)>LIMIT: raise RuntimeError('512MiB processing/final reserve')
    state['used']+=n; state['charges'][k]=state['charges'].get(k,0)+n
    if any(v in k for v in ['write','capture','forward','script_prepare','startup']):
        state['output_upper_bytes']=state.get('output_upper_bytes',1048576)+n
        if state['output_upper_bytes']>8*1024*1024:raise RuntimeError('cumulative output upper ceiling')
def read(p,k='read',size=None,sha=None):
    p=pathlib.Path(p); p=p if p.is_absolute() else ROOT/p
    if not p.is_relative_to(ROOT):
        if str(p)!=refresh['OBJECT_TOOL']['path']:raise RuntimeError('unapproved external input')
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
    b=checked_payload(state['transcript_payload_bytes'],v,10000,0 if stop else 256)
    if not stop:charge(len(b)*4,'payload_write_capture_forward')
    # STOP capture/forward processing is covered by the per-invocation8192-byte escrow.
    state['transcript_payload_bytes']+=len(b)
    with (HERE/'invocation/output.ndjson').open('ab') as f:f.write(b)
    sys.stdout.buffer.write(b)
def save():
    for _ in range(5):
        b=(json.dumps(state,separators=(',',':'))+'\n').encode()
        state['state_bytes']=len(b)
    
    if not final:charge(len(b),'state_write')
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
refresh=json.loads((HERE/'refresh.json').read_bytes())
try:
    charge((HERE/'refresh.json').stat().st_size*2,'refresh_control')
    if digest((HERE/'refresh.json').read_bytes())!=startup['refresh_sha256']:raise RuntimeError('frozen refresh changed')
    charge(8192,'stop_capture_write_processing_escrow')
    charge((HERE/'deliver.py').stat().st_size*3+4096,'file_delivery_source_alias_read_decode_hash')
    if digest((HERE/'deliver.py').read_bytes())!=startup['delivery_sha256'] or os.readlink('/tmp/g17')!=startup['alias_target']:raise RuntimeError('frozen delivery/alias changed')
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
        state['before']=preservation(pres)
        state['controls']={n:{'bytes':len(b),'sha256':digest(b)} for n,b in c.items()}
        # No selected payload semantics until a group clock starts.
        emit({'s':'AUTH'})
    elif mode=='metadata':
        emit({'disassembly_bytes':{r['path'].split('/')[-1]:r['bytes'] for r in state['auth'] if r['path'].endswith('-disassembly.stdout')},'remaining_before_reserve':LIMIT-RESERVE-state['used']})
    elif mode=='group':
        gid='U02-X28'
        if gid in state['groups']:raise RuntimeError('no group retry')
        state['groups'][gid]={'started_utc':utc(),'status':'ACTIVE','context_emitted':False,'model_examined':False};save()
        roots=json.loads(read(PREP/'roots.json','focused_control_reuse',state['controls']['roots.json']['bytes'],state['controls']['roots.json']['sha256']))
        exact_root='_$s17P08CounterRuntime03p08B4Host5write7backingSis5Int32Vs6UInt16V_A3HSPys5UInt8VGSgSitXCSg_SwSgtF'
        assignments=[h for j in roots['root_object_joins'] for h in j['exact_disassembly_headers'] if h==['P08CounterRuntime',exact_root]]
        assert len(assignments)==1
        source=read(ROOT/'Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift','current_selected_source',refresh['Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift']['bytes'],refresh['Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift']['sha256'])
        obj=ROOT/'.build/contracts/p08-counter-v5bqywpm/P08CounterRuntime.o'
        command=[refresh['OBJECT_TOOL']['path'],'--disassemble','--reloc','--no-show-raw-insn',str(obj)]
        p=subprocess.Popen(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE); bodies={};active=None;linecount=0;rawhash=hashlib.sha256();generated=0
        # Byte-stream structural parsing: no whole-module decoded/string materialization or raw copy.
        for linecount,line in enumerate(p.stdout,1):
            generated+=len(line);rawhash.update(line);charge(len(line),'current_object_stream')
            if generated>33554432:raise RuntimeError('current object stream exceeds declared32MiB bound')
            m=re.match(br'^\s*([0-9a-fA-F]+) <([^>]+)>:',line)
            if m:
                a=int(m[1],16);active=bodies.setdefault(a,{'address':a,'symbols':[],'lo':linecount,'lines':[],'edges':[],'alloc':[]});active['symbols'].append(m[2]);continue
            if active is None:continue
            active['lines'].append((linecount,line))
            m=re.match(br'^\s*([0-9a-fA-F]+):\s+(bl|b)\s+(?:0x)?([0-9a-fA-F]+)\b',line)
            if m:active['edges'].append({'site':int(m[1],16),'line':linecount,'to':int(m[3],16),'kind':m[2].decode()})
            if b'_swift_allocObject' in line:active['alloc'].append(linecount)
        stderr=p.stderr.read();rc=p.wait();charge(len(stderr),'object_stderr')
        if rc or stderr:raise RuntimeError('object tool exit/nonempty stderr')
        root_hits=[a for a,b in bodies.items() if exact_root.encode() in b['symbols']];assert len(root_hits)==1
        root=root_hits[0];queue=[root];parents={root:None}
        for a in queue:
            for edge in bodies[a]['edges']:
                dest=edge['to']
                if dest in bodies and dest not in parents:parents[dest]=(a,edge);queue.append(dest)
        traces={a:b for a,b in bodies.items() if any(b'counterTrace' in n and b'counterTraceWrite' not in n for n in b['symbols'])}
        selected={a:b for a,b in traces.items() if a in parents}; paths={};selected_nodes={root}
        for a in selected:
            path=[];node=a
            while parents[node] is not None:
                prev,edge=parents[node];path.append({'from':hex(prev),'to':hex(node),**edge});selected_nodes.add(node);selected_nodes.add(prev);node=prev
            paths[hex(a)]=list(reversed(path))
        # Exact compiled generic identities are demangled, not inferred from abbreviated names.
        symbols=[b['symbols'][0].decode() for b in selected.values()]
        dem=subprocess.run(['xcrun','swift-demangle','--compact'],input=('\n'.join(symbols)+'\n').encode(),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        charge(sum(len(x) for x in symbols)+len(dem.stdout)+len(dem.stderr)+8192,'exact_type_demangling')
        if dem.returncode or dem.stderr:raise RuntimeError('demangler failed')
        types=dict(zip([hex(a) for a in selected],dem.stdout.decode().splitlines()))
        raw=[];display=[];labels={}
        def shorten(text):
            text=re.sub(r' <[^>]+>','',text)
            text=re.sub(r'(_?\$s[\w.$]+)',lambda m: labels.setdefault(m[1],'S'+str(len(labels))),text)
            return text
        for a in sorted(selected_nodes):
            b=bodies[a];raw.append('NODE '+hex(a)+' '+b['symbols'][0].decode()+' L'+str(b['lo']))
            display.append('N'+hex(a)+' L'+str(b['lo']))
            for n,line in b['lines']:
                text=line.decode().strip();raw.append(str(n)+': '+text)
                if text:display.append(str(n)+' '+shorten(text))
        rawbytes=('\n'.join(raw)+'\n').encode();charge(len(rawbytes)*3,'selected_context_decode_write');assert len(rawbytes)<=1048576 and rawbytes.count(b'\n')<=16384
        (HERE/'context.txt').write_bytes(rawbytes)
        source_lines=source.decode().splitlines();source_calls=[{'line':i,'text':line.strip()} for i,line in enumerate(source_lines,1) if 'counterTrace(' in line or 'func counterTrace' in line]
        focus={'root_symbol':exact_root,'root_address':hex(root),'command':command,'whole_disassembly_sha256':rawhash.hexdigest(),'whole_disassembly_bytes':generated,'whole_disassembly_lines':linecount,'retention':'Only selected raw context retained; full stream not copied','rooted_trace_functions':[{'address':hex(a),'symbols':[n.decode() for n in b['symbols']],'type':types[hex(a)],'allocObject_lines':b['alloc'],'path':paths[hex(a)]} for a,b in selected.items()],'other_trace_functions_unexamined':[{'address':hex(a),'symbols':[n.decode() for n in b['symbols']]} for a,b in traces.items() if a not in selected],'labels':labels,'source_call_locators':source_calls,'context_sha256':digest(rawbytes),'context_bytes':len(rawbytes),'extracted':True,'emitted':False,'model_examined':False}
        state['focus']=focus
        item={'s':'BATCH_CONTEXT','utc':state['groups'][gid]['started_utc'],'types':types,'paths':paths,'machine':'\n'.join(display),'labels':labels,'source_calls':source_calls,'note':'All rooted candidate trace functions above. Actual conditions/allocator semantics require model examination; nonrooted functions unexamined.'}
        checked_payload(state['transcript_payload_bytes'],item,10000,1100)
        emit(item);focus['emitted']=True;state['groups'][gid]['context_emitted']=True
    elif mode=='close':
        gid=sys.argv[2]; g=state['groups'][gid]
        if g['status']!='ACTIVE': raise RuntimeError('group inactive')
        state['model_selected_disposition']=sys.argv[3]
        if state.get('focus',{}).get('emitted'):
            state['focus']['model_examined']=True;g['model_examined']=True
        g['ended_utc']=utc();g['elapsed_UTC_seconds']=(dt(g['ended_utc'])-dt(g['started_utc'])).total_seconds();g['status']='CLOSED'
        if g['elapsed_UTC_seconds']>90: state['errors'].append(gid+' exceeded 90-second active group window')
        emit({'s':'CLOSED','sec':g['elapsed_UTC_seconds']})
    elif mode=='finish':
        c=controls(); ins=json.loads(c['inputs.json']); pres=json.loads(c['preservation-reads.json'])
        for r in ins['files']: read(r['path'],'final_evidence_hash',r['bytes'],r['sha256'])
        for r in pres['files']:
            rr=refresh.get(r['path'],r); read(rr['path'],'final_preservation_hash',rr['bytes'],rr['sha256'])
        for r in refresh.values():read(r['path'],'final_current_refresh_auth',r['bytes'],r['sha256'])
        if git(['rev-parse','HEAD'],128).decode().strip()!=startup['expected_HEAD']:raise RuntimeError('HEAD changed during proof')
        state['after']=preservation(pres);state['finished_utc']=utc()
        if any(g.get('status')=='ACTIVE' for g in state['groups'].values()):raise RuntimeError('semantic group not closed')
        charge(524288,'final_capture_snapshot_metadata_write_upper')
        RESULT.mkdir()
        focus=state.get('focus',{});row=focus.get('row');g=state['groups'].get('U02-X28',{})
        result={'old_frozen_universe':{'groups':56,'sites':1892,'roots':3,'status':'IMMUTABLE BASELINE; refreshed current addresses are not substituted into old tuples'},'model_status':state.get('model_selected_disposition','UNEXAMINED'),'current_focus':focus,'baseline_refresh':refresh,'qualification':'Compiler-level evidence only; no allocator success/cost/cold/zero-heap claim','historical_semantic11_transcript':{'actual':3877,'recorded':3773,'not_requalified':True}}
        files={'rows.json':json.dumps(result,indent=2).encode(),'inspection-accounting.json':json.dumps(state,indent=2).encode(),'preservation.json':json.dumps({'before':state.get('before'),'after':state['after'],'controls':state.get('controls'),'inputs_authenticated':state['auth']},indent=2).encode(),'retained-excerpts.txt':read(HERE/'context.txt','final_context_reuse') if focus else b'','README.md':b'# Native Static diagnostic batch17\n\nOne amended-accounting attempt; retained exact focused context and partition. No Static allocation, heap/cold, complete-callee or P08 claim follows from reachability. See rows.json, exact raw citations/context and model result. Other frozen sites remain unexamined.\n'}
        if sum(map(len,files.values()))>8*1024*1024:raise RuntimeError('output ceiling')
        for n,b in files.items():charge(len(b),'semantic_result_write');(RESULT/n).write_bytes(b)

        emit({'s':'PRESERVED'})
    else: raise RuntimeError('unknown action')
except BaseException as exc:
    state['errors'].append(type(exc).__name__+': '+str(exc)); state['terminal_utc']=utc()
    save(); (HERE/'invocation/terminal.json').write_text(json.dumps({'state':'STOP','error':state['errors'][-1],'utc':utc()})+'\n')
    emit({'s':'STOP','error':state['errors'][-1]},stop=True);save();sys.exit(2)
save()
(HERE/'invocation'/('terminal-'+mode+('-'+sys.argv[2] if len(sys.argv)>2 else '')+'.json')).write_text(json.dumps({'state':'COMPLETE','exit':0,'utc':utc()})+'\n')

if final and RESULT.exists():
    (RESULT/'inspection-accounting.json').write_text(json.dumps(state,indent=2)+'\n')
