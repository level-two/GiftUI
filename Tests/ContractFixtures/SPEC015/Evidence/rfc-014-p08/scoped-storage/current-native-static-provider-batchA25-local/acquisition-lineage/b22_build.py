import pathlib,json,hashlib,subprocess,datetime
R=pathlib.Path('/Users/eugene/work/GiftUI');B=R/'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage';P=B/'current-native-static-diagnostic-provider21-local';H=B/'current-native-static-provider-batchA22-local';assert not (H/'inspect.py').exists()
s=(P/'inspect.py').read_text().replace('current-native-static-diagnostic-provider21','current-native-static-provider-batchA22').replace('/tmp/g21','/tmp/g22')
s=s.replace('import datetime, gzip, hashlib, io, json, os, pathlib, re, stat, subprocess, sys, time','import datetime, gzip, hashlib, io, json, os, pathlib, re, stat, struct, subprocess, sys, time, bisect')
a=s.index("    elif mode=='group':");z=s.index("    elif mode=='close':",a)
g='''    elif mode=='group':
        gid='U02-X28';state['groups'][gid]={'started_utc':utc(),'status':'ACTIVE','context_emitted':False,'model_examined':False};save()
        meta=json.loads(read(HERE/'provider-slices.json','provider_descriptor_decode'))
        loaded={};exports={};starts={};byaddr={};ids={}
        def uleb(b,i):
            value=0;shift=0
            while True:
                x=b[i];i+=1;value|=(x&127)<<shift
                if not x&128:return value,i
                shift+=7
                if shift>63:raise RuntimeError('ULEB overflow')
        def trie(b,base):
            result={};todo=[(0,'')];visited=set()
            while todo:
                off,prefix=todo.pop()
                if (off,prefix) in visited:raise RuntimeError('export trie cycle')
                visited.add((off,prefix));n,i=uleb(b,off);end=i+n
                if n:
                    flags,j=uleb(b,i)
                    if flags&8:
                        ordinal,j=uleb(b,j);tail=b[j:end].split(b'\\0')[0].decode();result[prefix]={'flags':flags,'reexport_ordinal':ordinal,'import_name':tail}
                    else:
                        address,j=uleb(b,j);result[prefix]={'flags':flags,'address':base+address}
                i=end;count=b[i];i+=1
                for _ in range(count):
                    end=b.index(0,i);edge=b[i:end].decode();off,i=uleb(b,end+1);todo.append((off,prefix+edge))
            charge(sum(len(k)+96 for k in result),'provider_export_parse_processing');return result
        for name,p in meta['providers'].items():
            slices={v['role']:v for v in p['slices']};exp=trie(provider_read(slices['exports-trie']),p['base']);exports[name]=exp
            bs=provider_read(slices['function-starts']);at=0;address=p['base'];ss=[]
            while at<len(bs):
                delta,at=uleb(bs,at)
                if not delta:break
                address+=delta;ss.append(address)
            starts[name]=ss;loaded[name]={'text':provider_read(slices['__TEXT']),'slice':slices['__TEXT']};ids[name]={'uuid':p['uuid'],'identity':p['identity'],'dependencies':p['dependencies']}
            for sym,row in exp.items():
                if 'address' in row:byaddr.setdefault(row['address'],[]).append(name+':'+sym)
        selected=['_putchar','_fputc','_putc','_putc_unlocked','___swbuf','___swbuf0','___smakebuf','___sinit'];functions=[];raws=[];missing=[];calls=[]
        for symbol in selected:
            hits=[(name,row) for name,rows in exports.items() if (row:=rows.get(symbol)) and 'address' in row]
            # Equal address aliases are rendered once, with every requested name retained.
            if not hits:missing.append({'symbol':symbol,'boundary':'No exact ordinary address in four frozen provider export tries; private local bodies not searched or absent-inferred'});continue
            if len(hits)!=1:raise RuntimeError('nonunique provider symbol '+symbol)
            name,row=hits[0];address=row['address'];seq=starts[name]
            if address not in seq:raise RuntimeError('exact provider entry lacks function-start bound '+symbol)
            ix=seq.index(address)
            if ix+1>=len(seq):raise RuntimeError('provider entry has no next function bound '+symbol)
            end=seq[ix+1];info=loaded[name];off=address-info['slice']['vmaddr'];code=info['text'][off:off+end-address];assert len(code)==end-address and len(code)%4==0
            if any(v['address']==address for v in functions):
                next(v for v in functions if v['address']==address)['aliases'].append(symbol);continue
            # Exact bytes projected into one minimal read-only Mach-O section; no code executed.
            header=struct.pack('<IiiIIIII',0xfeedfacf,0x100000c,2,1,1,152,0,0)
            seg=struct.pack('<II16sQQQQiiII',0x19,152,b'__TEXT',address,len(code),4096,len(code),7,5,1,0)
            sec=struct.pack('<16s16sQQIIIIIIII',b'__text',b'__TEXT',address,len(code),4096,2,0,0,0x80000400,0,0,0)
            derived=(header+seg+sec).ljust(4096,b'\\0')+code;path=HERE/('provider-'+symbol.replace('/','_')+'.o');charge(len(derived)*3,'provider_projection_write');path.write_bytes(derived)
            argv=[refresh['OBJECT_TOOL']['path'],'--disassemble','--no-show-raw-insn',str(path)];charge(len(derived),'selected_provider_decoder_read');rr=subprocess.run(argv,stdout=subprocess.PIPE,stderr=subprocess.PIPE);charge(len(rr.stdout)*3+len(rr.stderr),'provider_decoder_output_processing');assert rr.returncode==0 and not rr.stderr
            raw=rr.stdout.decode();raws.append(symbol+' '+name+' uuid='+ids[name]['uuid']+' bytesSHA='+digest(code)+'\\n'+raw);lines=[]
            for lno,line in enumerate(raw.splitlines(),1):
                v=instruction(line)
                if not v:continue
                pc,op,operand=v;operand=re.sub(r'\\s*; =-?(?:0x[0-9a-fA-F]+|[0-9]+)$','',operand);lines.append(hex(pc-address)[2:]+':'+op+' '+operand)
                if op in ['bl','b']:
                    m=re.match(r'(?:0x)?([0-9a-fA-F]+)',operand)
                    if m:
                        dest=int(m[1],16);calls.append({'from':symbol,'site':hex(pc),'to':hex(dest),'exports':byaddr.get(dest,[]),'op':op})
            functions.append({'name':symbol,'aliases':[symbol],'provider':name,'address':address,'end':end,'raw_sha256':digest(rr.stdout),'bytes_sha256':digest(code),'slice':{'path':info['slice']['path'],'offset':info['slice']['offset']+off,'bytes':len(code)},'instructions':'\\n'.join(lines),'decoder_argv':argv})
        rb=('\\n\\n'.join(raws)+'\\n').encode();assert len(rb)<=1048576 and rb.count(b'\\n')<=16384;charge(len(rb)*3,'provider_raw_context_write');(HERE/'context.txt').write_bytes(rb)
        state['focus']={'provider_identities':ids,'functions':functions,'calls':calls,'not_export_bound':missing,'body_context_sha256':digest(rb),'body_context_bytes':len(rb),'source_root_lemma':'Reviewed provider21 root/typed/writer/helper relation, same exact wrapel2y source/object; no local-chain replay','extracted':True,'emitted':False,'model_examined':False,'provider_scope':'Selected installed provider code only; earlier/later state and indirect bindings unresolved unless explicitly read'}
        payload={'s':'PROVIDER','start':state['groups'][gid]['started_utc'],'identities':{k:{'uuid':v['uuid'],'version':v['identity']['current_version']} for k,v in ids.items()},'libSystem_putchar':exports['/usr/lib/libSystem.B.dylib'].get('_putchar'),'functions':[{'name':f['name'],'aliases':f['aliases'],'base':hex(f['address']),'end':hex(f['end']),'code':f['instructions']} for f in functions],'calls':[x for x in calls if x['exports']],'unbound':missing,'scope':'Instruction offsets from exact VM base; full raw addresses/decoder lines and exact cache offset/hash/UUID durable. Root applicability is reviewed provider21 conditional lemma. No counter/runtime execution; live stdout initial/window state not observed.'}
        remaining=sum(request_plan[k]['counted_UTF8_bytes'] for k in ['close-provider-gap','finish'])+160+256
        packet=checked_payload(state['transcript_payload_bytes'],payload,10000,remaining);state['joint_packet_bytes']=len(packet);state['complete_exchange_forecast_upper']=state['transcript_payload_bytes']+len(packet)+remaining
        if (dt(utc())-dt(state['groups'][gid]['started_utc'])).total_seconds()>90:raise RuntimeError('90-second group expired before provider emission')
        emit(payload);state['focus']['emitted']=True;state['groups'][gid]['context_emitted']=True
'''
s=s[:a]+g+s[z:]
# Add exact bounded installed-file range authentication; no opaque shared-cache inspector.
pos=s.index('refresh=json.loads')
s=s[:pos]+'''def provider_read(desc):
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
    return {'descriptor_sha256':digest(b),'provider_uuids':{n:p['uuid'] for n,p in meta['providers'].items()},'exact_extent_bytes_per_check':sum(d['bytes'] for p in meta['providers'].values() for d in p['slices'])+meta['cache_map']['bytes']}
''' +s[pos:]
s=s.replace("state['before']=preservation(pres)","state['before']=preservation(pres);state['provider_before']=provider_auth()")
s=s.replace("state['after']=preservation(pres);state['finished_utc']=utc()", "state['after']=preservation(pres);state['provider_after']=provider_auth();state['finished_utc']=utc()")
s=s.replace("'model_examination_scope']='Joint packet includes root, exact argument helper, typed-entry prefix, whole StaticString writer and whole exact entry helper0xbf288. No later trace/caller/provider bodies inferred.'", "'model_examination_scope']='Selected installed-provider code packet; existing reviewed21root applicability reused. Other callees/window state unexamined.'")
s=s.replace("b'# Current diagnostic provider18", "b'# Installed provider Batch A22")
(H/'inspect.py').write_text(s)
(H/'deliver.py').write_text((P/'deliver.py').read_text().replace('/tmp/g21','/tmp/g22'))
(H/'control.py').write_text((P/'control.py').read_text())
refresh=json.loads((P/'refresh.json').read_bytes())
for key,f in [('PROOF21','current-native-static-diagnostic-provider21-result/rows.json')]:
 b=(B/f).read_bytes();refresh[key]={'path':str((B/f).relative_to(R)),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'scope':'Reviewed exact21root/typed/writer/helper and original source bindings, no repetition'}
(H/'refresh.json').write_text(json.dumps(refresh,indent=2)+'\n')
plan={}
for mode,letter in [('auth','a'),('group','g'),('close-provider-gap','c'),('finish','f')]:
 args={'cmd':'python3 /tmp/g22 '+letter};code='const r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';plan[mode]={'mode':mode,'request_code':code,'nested_arguments':args,'counted_UTF8_bytes':len(code.encode())+len(json.dumps(args,separators=(',',':')).encode())}
(H/'requests.json').write_text(json.dumps(plan,indent=2)+'\n')
rr=subprocess.run(['python3',str(H/'control.py')],stdout=subprocess.PIPE,stderr=subprocess.PIPE);assert rr.returncode==0 and not rr.stderr
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R).decode().strip();assert head.startswith('c94574d0')
A=pathlib.Path('/tmp/g22');assert not A.exists() and not A.is_symlink();A.symlink_to(H/'deliver.py')
def sha(f):return hashlib.sha256((H/f).read_bytes()).hexdigest()
f={'frozen_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'helper_sha256':sha('inspect.py'),'delivery_sha256':sha('deliver.py'),'requests_sha256':sha('requests.json'),'refresh_sha256':sha('refresh.json'),'provider_slices_sha256':sha('provider-slices.json'),'alias_target':str(H/'deliver.py'),'expected_HEAD':head,'preflight_processing_upper_bytes':16777216,'control_sha256':sha('control.py'),'control_result_sha256':sha('invocation/control.json'),'complete_exchange_rule':'Actual complete selected provider packet+requests/status/STOP reserve<=10000 before emission; no subcap','authority':'Explicit human bounded installed-provider evidence; opaque metadata/range hashes frozen before semantic reading; no live process or new provider acquired'}
(H/'invocation/freeze.json').write_text(json.dumps(f,indent=2)+'\n')
print(json.dumps({'frozen_helper':f['helper_sha256'],'HEAD':head,'provider_bytes':1078930,'preflight_upper':f['preflight_processing_upper_bytes'],'control':'PASS','no_semantic_provider_examination_yet':True}))
