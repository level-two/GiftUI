from pathlib import Path
import json,hashlib,os,subprocess,datetime
base=Path('Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage');loc=base/'current-native-static-diagnostic-provider18-local';old=base/'current-callee-native-static-diagnostic-batch17-local';s=(old/'inspect.py').read_text();s=s.replace('current-callee-native-static-diagnostic-batch17-result','current-native-static-diagnostic-provider18-result').replace('/tmp/g17','/tmp/g18')
s=s.replace("str(p)!=refresh['OBJECT_TOOL']['path']","str(p) not in [refresh['OBJECT_TOOL']['path'],refresh['NM_TOOL']['path']]")
a=s.index("    elif mode=='group':");z=s.index("    elif mode=='close':",a)
block=r'''    elif mode=='group':
        gid='U02-X28';state['groups'][gid]={'started_utc':utc(),'status':'ACTIVE','context_emitted':False,'model_examined':False};save()
        roots=json.loads(read(PREP/'roots.json','focused_control',state['controls']['roots.json']['bytes'],state['controls']['roots.json']['sha256']))
        rootname='_$s17P08CounterRuntime03p08B4Host5write7backingSis5Int32Vs6UInt16V_A3HSPys5UInt8VGSgSitXCSg_SwSgtF'
        target='_$s17P08CounterRuntime12counterTraceyys12StaticStringV_21GiftUIObservableState28ObservableModelOwnerIdentityV_AG0H14UISemanticCore014SemanticRecordmN0VAJttF'
        writer='_$s17P08CounterRuntime17counterTraceWrite33_F69033F4DB287CAFB71641A3EEA15F2ALLyys12StaticStringVF'
        assert sum(h==['P08CounterRuntime',rootname] for j in roots['root_object_joins'] for h in j['exact_disassembly_headers'])==1
        obj=ROOT/'.build/contracts/p08-counter-wrapel2y/P08CounterRuntime.o';aliases={};nmrows=[]
        cmd=[refresh['NM_TOOL']['path'],'-n',str(obj)];charge(obj.stat().st_size,'nm_object_read');r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE);charge(len(r.stdout)*2+len(r.stderr),'nm_output_decode');assert r.returncode==0 and not r.stderr
        for n,line in enumerate(r.stdout.splitlines(),1):
            m=re.match(br'^\s*([0-9a-fA-F]+)\s+[tT]\s+(\S+)\s*$',line)
            if m:aliases.setdefault(m[2].decode(),[]).append({'address':int(m[1],16),'line':n})
            if b'_putchar' in line:nmrows.append({'line':n,'text':line.decode()})
        for name in [rootname,target,writer]:
            if len(aliases.get(name,[]))!=1:raise RuntimeError('nonunique exact current alias '+name)
        addresses={name:aliases[name][0]['address'] for name in [rootname,target,writer]};wanted=set(addresses.values());bodies={};active=None;hh=hashlib.sha256();total=0
        cmd=[refresh['OBJECT_TOOL']['path'],'--disassemble','--reloc','--no-show-raw-insn',str(obj)];charge(obj.stat().st_size,'decoder_object_read');p=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        for n,line in enumerate(p.stdout,1):
            total+=len(line);hh.update(line);charge(len(line),'selected_current_object_stream')
            if total>33554432:raise RuntimeError('32MiB decoder stream ceiling')
            m=re.match(br'^\s*([0-9a-fA-F]+) <([^>]+)>:',line)
            if m:
                address=int(m[1],16);keep=address in wanted or b'OUTLINED_FUNCTION_' in m[2];active=address if keep else None
                if keep:bodies.setdefault(address,{'base':address,'symbol':m[2].decode(),'header_line':n,'lines':[]})
                continue
            if active is not None:bodies[active]['lines'].append([n,line.decode().rstrip()])
        err=p.stderr.read();rc=p.wait();charge(len(err),'decoder_stderr');assert rc==0 and not err
        cache={'bodies':bodies,'aliases':aliases,'addresses':addresses,'rootname':rootname,'target':target,'writer':writer,'nm_putchar':nmrows,'raw_sha256':hh.hexdigest(),'raw_bytes':total,'nm_sha256':digest(r.stdout),'decoder_argv':cmd}
        # Cache only exact selected and outlined bodies, not a decoded full-module dump.
        cb=(json.dumps(cache,separators=(',',':'))+'\n').encode();charge(len(cb)*2,'selected_cache_write');assert len(cb)<3000000;(HERE/'selected-cache.json').write_bytes(cb)
        state['focus']={'root_symbol':rootname,'target_symbol':target,'writer_symbol':writer,'addresses':addresses,'raw_disassembly_sha256':hh.hexdigest(),'raw_disassembly_bytes':total,'root_emitted':False,'provider_emitted':False,'model_examined':False,'emitted':False,'extracted':True}
        projection,raw,ids=project(bodies[addresses[rootname]],aliases)
        (HERE/'context.txt').write_text(raw);charge(len(raw.encode())*2,'root_context_decode_write')
        state['focus']['root_packet_bytes']=len(projection.encode());state['focus']['root_context_sha256']=digest(raw.encode())
        value={'s':'ROOT','started':state['groups'][gid]['started_utc'],'raw_sha256':hh.hexdigest(),'root':projection,'identities':ids,'target_type':'counterTrace(StaticString,(GiftUIObservableState.ObservableModelOwnerIdentity,GiftUIObservableState.ObservableModelOwnerIdentity,GiftUISemanticCore.SemanticRecordOwnerIdentity,GiftUISemanticCore.SemanticRecordOwnerIdentity))','scope':'Literal root; raw line offsets refer to exact decoder stream. PC=base+4*instruction_index unless explicit. Earlier callees are conditions, not assumed success.'}
        b=checked_payload(state['transcript_payload_bytes'],value,10000,4000)
        if len(b)>5000:raise RuntimeError('literal root packet exceeds planned5000B bound')
        emit(value);state['focus']['root_emitted']=True;state['focus']['emitted']=True;state['groups'][gid]['context_emitted']=True
    elif mode=='provider':
        g=state['groups']['U02-X28']
        if (dt(utc())-dt(g['started_utc'])).total_seconds()>90:raise RuntimeError('90-second model window expired')
        cache=json.loads(read(HERE/'selected-cache.json','selected_cache_reuse'));bodies={int(k):v for k,v in cache['bodies'].items()};aliases=cache['aliases'];addresses=cache['addresses'];root=bodies[addresses[cache['rootname']]];trace=bodies[addresses[cache['target']]];writer=bodies[addresses[cache['writer']]]
        allnames={v['address']:name for name,rows in aliases.items() for v in rows}
        rootedges=edges(root,aliases);direct=[e for e in rootedges if e.get('to')==trace['base']];chain=[];argument=[]
        if direct:
            chosen=direct[0];chain=[chosen]
            prior=[e for e in rootedges if e['line']<chosen['line'] and 'OUTLINED_FUNCTION_' in allnames.get(e.get('to'),'')]
            if prior and prior[-1]['to'] in bodies:argument=[bodies[prior[-1]['to']]]
        else:
            for e in rootedges:
                if e.get('to') in bodies and 'OUTLINED_FUNCTION_' in bodies[e['to']]['symbol']:
                    for e2 in edges(bodies[e['to']],aliases):
                        if e2.get('to')==trace['base']:chain=[e,e2];argument=[bodies[e['to']]];break
                if chain:break
        traceedges=edges(trace,aliases);first=[e for e in traceedges if e.get('to')==writer['base']]
        if first:
            cutoff=first[0]['line'];prefix={**trace,'lines':[v for v in trace['lines'] if v[0]<=cutoff]};prefix_scope='Exact trace-entry prefix through first common writer call; subsequent work explicitly unexamined'
        else:prefix=trace;prefix_scope='No exact direct writer edge resolved: full selected trace body; no absence inference'
        blocks=[prefix]+argument+[writer];texts=[];raws=[];ids={}
        for body in blocks:
            text,raw,labels=project(body,aliases);texts.append(text);raws.append(raw);ids.update(labels)
        exe=refresh['EXECUTABLE'];charge(exe['bytes'],'executable_nm_read');r=subprocess.run([refresh['NM_TOOL']['path'],'-m',str(ROOT/exe['path'])],stdout=subprocess.PIPE,stderr=subprocess.PIPE);charge(len(r.stdout)*2+len(r.stderr),'executable_nm_decode');assert r.returncode==0 and not r.stderr
        imports=[line.decode() for line in r.stdout.splitlines() if b'_putchar' in line]
        # Symbol-index coverage, not library/provider acquisition.
        ins=json.loads(read(PREP/'inputs.json','coverage_control',state['controls']['inputs.json']['bytes'],state['controls']['inputs.json']['sha256']));coverage=[]
        for desc in ins['files']:
            if not desc['path'].endswith('-symbols.stdout') or desc['later_access']!='retained_attribution_read':continue
            bb=read(desc['path'],'frozen_provider_symbol_index',desc['bytes'],desc['sha256']);hits=[(i,line.decode()) for i,line in enumerate(bb.splitlines(),1) if line.split() and line.split()[-1]==b'_putchar'];coverage.append({'path':desc['path'],'sha256':desc['sha256'],'hits':hits})
        # Exact typed entry declaration from the already qualified retained SIL projection.
        desc=refresh['SELECTED_SIL'];bb=read(desc['path'],'selected_SIL_projection',desc['bytes'],desc['sha256']);needle=cache['target'].removeprefix('_');type_lines=[line.decode() for line in bb.splitlines() if b'sil ' in line and ('@'+needle+' :').encode() in line]
        raw='\n'.join(raws)+'\nEXTERNAL NM\n'+'\n'.join(imports)+'\nSIL TYPE\n'+'\n'.join(type_lines)+'\n';prior=(HERE/'context.txt').read_bytes();charge(len(prior)+len(raw.encode())*3,'provider_context_read_decode_write');combined=prior+raw.encode();assert len(combined)<=1048576 and combined.count(b'\n')<=16384;(HERE/'context.txt').write_bytes(combined)
        state['focus'].update({'exact_root_trace_chain':chain,'trace_writer_edges':first,'trace_prefix_scope':prefix_scope,'symbol_index_coverage':coverage,'current_object_nm_putchar':cache['nm_putchar'],'executable_nm_putchar':imports,'selected_SIL_type_lines':type_lines,'provider_context_sha256':digest(raw.encode()),'combined_context_bytes':len(combined)})
        value={'s':'PROVIDER','blocks':texts,'identities':ids,'chain':chain,'trace_writer_edges':first,'scope':prefix_scope,'object_import':cache['nm_putchar'],'executable_import':imports,'exact_SIL_type':type_lines,'frozen_symbol_indexes_examined':len(coverage),'frozen_putchar_definitions_or_uses':sum(len(v['hits']) for v in coverage),'coverage_boundary':'Selected current object/executable plus all retained-attribution symbol indexes. No libSystem body was acquired; other unexamined bodies are not globally absent.'}
        b=checked_payload(state['transcript_payload_bytes'],value,10000,600)
        if len(b)>3500:raise RuntimeError('complete provider packet exceeds planned3500B bound')
        emit(value);state['focus']['provider_emitted']=True
'''
# Lossless compact projection: preserve instructions, literal addresses/relocations; exact full identities interned once durably.
functions=r'''def instruction(line):
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
'''
s=s[:a]+block+s[z:];s=s.replace("mode=sys.argv[1]",functions+"\nmode=sys.argv[1]",1)
# Preserve failed batch17 separately; new result never imports its examination flags.
a=s.index("        result={'old_frozen_universe':");z=s.index("        files=",a);s=s[:a]+"        result={'old_frozen_universe':{'groups':56,'sites':1892,'roots':3,'status':'IMMUTABLE BASELINE; no current tuple substitution'},'model_status':state.get('model_selected_disposition','UNEXAMINED'),'current_focus':focus,'baseline_refresh':refresh,'qualification':'Conditional current root/provider proof only; no allocator success/cost/cold/zero-heap claim','batch17_STOP_preserved':True}\n"+s[z:];s=s.replace('Native Static diagnostic batch17','Current diagnostic provider18')
# Use fixed exact model disposition choices.
s=s.replace("'batch-native-static-traces-examined'","'provider-gap'")
(loc/'inspect.py').write_text(s)
meta=json.loads((base/'current-callee-native-static-diagnostic-batch17-result/implementation-result.json').read_bytes());oldrefresh=json.loads((old/'refresh.json').read_bytes());ref={}
owner='Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift';result='.build/contracts/p08-counter-wrapel2y/result.json';obj='.build/contracts/p08-counter-wrapel2y/P08CounterRuntime.o'
for path,hashvalue in [(owner,'de2df6fd0730393aaa2aca89b2aca937d0b20b38817dc1d399b2dc0ea2252084'),(result,'af9ba8ef87a2f33d4d6d7ea46d2e1f4f925228f667c0b7fb95b4ae3023b06773'),(obj,'3c106c086ef904fdf3a74481fd479a138fbfe39dca5587169ac501e1bfaea4cf')]:ref[path]={'path':path,'bytes':Path(path).stat().st_size,'sha256':hashvalue,'authority':'95bec0b4 reviewed batch17 current-artifact baseline; old raw corpus preserved'}
ref['OBJECT_TOOL']=oldrefresh['OBJECT_TOOL'];nm=Path('/usr/bin/nm');ref['NM_TOOL']={'path':str(nm),'bytes':nm.stat().st_size,'sha256':hashlib.sha256(nm.read_bytes()).hexdigest()};exe=meta['full']['selected_artifacts']['counter'];ref['EXECUTABLE']={'path':'.build/contracts/p08-counter-wrapel2y/counter','bytes':exe['bytes'],'sha256':exe['sha256']};sil=next(v for v in meta['raw_artifact_references'] if v['path'].endswith('selected-trace-functions.sil.txt'));ref['SELECTED_SIL']={k:sil[k] for k in ['path','bytes','sha256']};(loc/'refresh.json').write_text(json.dumps(ref,indent=2)+'\n')
d=(old/'deliver.py').read_text().replace('/tmp/g17','/tmp/g18').replace("'g':('group',['group'])","'g':('group',['group']),'p':('provider',['provider'])").replace("'p':('close',['close','U02-X28','batch-native-static-traces-examined'])","'k':('close',['close','U02-X28','provider-gap'])").replace('close-batch-native-static-traces-examined','close-provider-gap')
# Existing actual delivery control remains, with two-packet maxima rather than a generic selected-context placeholder.
d=d.replace("assert records['g']['stdout']==8600","assert records['g']['stdout']==8600")
d=d.replace("['auth','group','close-provider-gap','finish']","['auth','group','provider','close-provider-gap','finish']");(loc/'deliver.py').write_text(d)
req={}
for key,action in [('auth','a'),('group','g'),('provider','p'),('close-metadata-proof-gap','c'),('close-provider-gap','k'),('finish','f')]:
 args={'cmd':'python3 /tmp/g18 '+action};code='const r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';req[key]={'mode':key,'request_code':code,'nested_arguments':args,'counted_UTF8_bytes':len(code.encode())+len(json.dumps(args,separators=(',',':')).encode())}
(loc/'requests.json').write_text(json.dumps(req,indent=2)+'\n')
# Actual same-file control succeeds and deliberately STOPs, no cache/syntax gate.
p=subprocess.run(['python3',str(loc/'deliver.py'),'control'],stdout=subprocess.PIPE,stderr=subprocess.PIPE);(loc/'invocation/delivery-control.stdout').write_bytes(p.stdout);(loc/'invocation/delivery-control.stderr').write_bytes(p.stderr);assert p.returncode==0,(p.returncode,p.stderr)
assert 5*106+8500+240+256<10000
assert not Path('/tmp/g18').exists();os.symlink(str((loc/'deliver.py').resolve()),'/tmp/g18')
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();freeze={'frozen_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'helper_sha256':h(loc/'inspect.py'),'delivery_sha256':h(loc/'deliver.py'),'requests_sha256':h(loc/'requests.json'),'refresh_sha256':h(loc/'refresh.json'),'alias_target':str((loc/'deliver.py').resolve()),'expected_HEAD':'95bec0b4ed4a601c891300c9148e61bedfcd9f9e','preflight_processing_upper_bytes':8388608,'two_packet_context_upper_bytes':[5000,3500],'complete_exchange_upper':9526,'control':'Existing actual file delivery child exits/streams checked, plus finite root5000/provider3500 request/status/STOP budget; no py_compile','preauth_orientation_start':json.loads((loc/'orientation-start.json').read_bytes()),'not_yet_authenticated':True};(loc/'invocation/freeze.json').write_text(json.dumps(freeze,indent=2)+'\n');print(json.dumps({'frozen':freeze['helper_sha256'],'delivery_control_exit':p.returncode,'whole_exchange_bound':9526,'fresh_auth_not_started':True}))
