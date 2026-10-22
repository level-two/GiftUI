import pathlib,json,hashlib,datetime,subprocess
R=pathlib.Path('/Users/eugene/work/GiftUI');B=R/'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage';P=B/'current-native-static-provider-batchA22-local';H=B/'current-native-static-provider-batchA23-local';assert not H.exists();H.mkdir();(H/'invocation').mkdir()
s=(P/'inspect.py').read_text().replace('batchA22','batchA23').replace('/tmp/g22','/tmp/g23');a=s.index("    elif mode=='group':");z=s.index("    elif mode=='close':",a)
g='''    elif mode=='group':
        gid='U02-X28';state['groups'][gid]={'started_utc':utc(),'status':'ACTIVE','context_emitted':False,'model_examined':False};save()
        dd=refresh['DERIVED22'];bb=read(dd['path'],'authenticated_22_selected_provider_projection',dd['bytes'],dd['sha256']);charge(len(bb)*2,'22_projection_decode_copy');old=json.loads(bb)
        assert old['errors']==['RuntimeError: checked payload exceeds reserved transcript'] and old['groups']['U02-X28']['model_examined']==False
        f=old['focus'];functions=f['functions'];byaddr={v['address']:v for v in functions};roots=[v for v in functions if '_putchar' in v['aliases']];assert len(roots)==1
        queue=[roots[0]['address']];seen=set(queue);frontier=[];boundaries=[]
        for address in queue:
            fn=byaddr[address];frontier.append(fn)
            for edge in f['calls']:
                if edge['from'] not in fn['aliases']:continue
                target=int(edge['to'],16)
                if fn['address']<=target<fn['end']:continue
                if target in byaddr:
                    if target not in seen:seen.add(target);queue.append(target)
                else:boundaries.append(edge)
        texts=[];raws=[];indirect=[]
        for fn in frontier:
            ins=[];expected=0
            for line in fn['instructions'].splitlines():
                off,op=line.split(':',1);offset=int(off,16)
                if offset!=expected:raise RuntimeError('noncontiguous instruction projection; cannot use implicit PCs')
                expected+=4;op=re.sub(r',\\s+',',',op);ins.append(op)
                if re.match(r'(?:blr|br|blraa|blrab|braa|brab)\\b',op):indirect.append({'function':fn['name'],'site':hex(fn['address']+offset),'instruction':op})
            assert expected==fn['end']-fn['address']
            texts.append({'name':fn['name'],'base':hex(fn['address']),'code':'\\n'.join(ins)});raws.append(fn['name']+' '+hex(fn['address'])+' '+fn['bytes_sha256']+'\\n'+fn['instructions'])
        raw=('\\n\\n'.join(raws)+'\\n').encode();assert len(raw)<=1048576 and raw.count(b'\\n')<=16384;charge(len(raw)*3,'frontier_context_write');(HERE/'context.txt').write_bytes(raw)
        meta=json.loads(read(HERE/'provider-slices.json','provider_metadata_context'));binding={name:{'uuid':p['uuid'],'identity':p['identity'],'reexports':[d for d in p['dependencies'] if d['command']==0x8000001f and ('libsystem_c.' in d['name'] or 'libsystem_malloc.' in d['name'])]} for name,p in meta['providers'].items()}
        state['focus']={'frontier':frontier,'boundaries':boundaries,'indirect':indirect,'installed_binding':binding,'context_sha256':digest(raw),'context_bytes':len(raw),'original22STOP':{'processing':old['used'],'transcript':old['transcript_payload_bytes'],'output_upper':old['output_upper_bytes'],'model_examined':False},'source_root_lemma':f['source_root_lemma'],'extracted':True,'emitted':False,'model_examined':False,'scope':'Exact installed putchar executable frontier among already extracted bodies; no alternate entry bodies unless reached. Unknown calls/initial state not closed.'}
        value={'s':'CALLED_FRONTIER','start':state['groups'][gid]['started_utc'],'binding':binding,'functions':texts,'boundaries':boundaries,'indirect':indirect,'scope':'PC=base+4*zero_based_instruction_index; ALL instructions retained, operand comma spaces removed only. Full raw hashes/cache slice locations/UUIDs retained via authenticated22state. Root21 conditional lemma reused. Initial stdout/current-window state, loaded interposition and unjoined callees not inferred.'}
        remaining=sum(request_plan[k]['counted_UTF8_bytes'] for k in ['close-provider-gap','finish'])+160+256
        packet=checked_payload(state['transcript_payload_bytes'],value,10000,remaining);state['joint_packet_bytes']=len(packet);state['complete_exchange_forecast_upper']=state['transcript_payload_bytes']+len(packet)+remaining
        if (dt(utc())-dt(state['groups'][gid]['started_utc'])).total_seconds()>90:raise RuntimeError('90-second group expired before provider emission')
        emit(value);state['focus']['emitted']=True;state['groups'][gid]['context_emitted']=True
'''
s=s[:a]+g+s[z:];(H/'inspect.py').write_text(s)
(H/'deliver.py').write_text((P/'deliver.py').read_text().replace('/tmp/g22','/tmp/g23'));(H/'control.py').write_text((P/'control.py').read_text());(H/'provider-slices.json').write_bytes((P/'provider-slices.json').read_bytes())
refresh=json.loads((P/'refresh.json').read_bytes())
for key,path in [('DERIVED22',P/'state.json'),('HELPER22',P/'inspect.py'),('FREEZE22',P/'invocation/freeze.json'),('STOP22',B/'current-native-static-provider-batchA22-result/STOP-closeout.json')]:
 b=path.read_bytes();refresh[key]={'path':str(path.relative_to(R)),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'scope':'Immutable22bounded extraction/STOP/model-unexamined lineage; code is exact installed slice derivation, reused under23clock'}
(H/'refresh.json').write_text(json.dumps(refresh,indent=2)+'\n')
plan={}
for mode,letter in [('auth','a'),('group','g'),('close-provider-gap','c'),('finish','f')]:
 args={'cmd':'python3 /tmp/g23 '+letter};code='const r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';plan[mode]={'mode':mode,'request_code':code,'nested_arguments':args,'counted_UTF8_bytes':len(code.encode())+len(json.dumps(args,separators=(',',':')).encode())}
(H/'requests.json').write_text(json.dumps(plan,indent=2)+'\n');r=subprocess.run(['python3',str(H/'control.py')],stdout=subprocess.PIPE,stderr=subprocess.PIPE);assert r.returncode==0 and not r.stderr
f=json.loads((P/'invocation/freeze.json').read_bytes());f['frozen_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat();f['alias_target']=str(H/'deliver.py');f['preflight_processing_upper_bytes']=8388608;f['orientation']='Exact called-frontier selection only under group; opaque22lineage hashes/structural byte counts only preauth.22STOPand455.617628sacquisition retained; no pre-record timing certification.'
for key,path in [('helper_sha256','inspect.py'),('delivery_sha256','deliver.py'),('requests_sha256','requests.json'),('refresh_sha256','refresh.json'),('provider_slices_sha256','provider-slices.json'),('control_sha256','control.py'),('control_result_sha256','invocation/control.json')]:f[key]=hashlib.sha256((H/path).read_bytes()).hexdigest()
A=pathlib.Path('/tmp/g23');assert not A.exists() and not A.is_symlink();A.symlink_to(H/'deliver.py');(H/'invocation/freeze.json').write_text(json.dumps(f,indent=2)+'\n');print('23frozen '+f['helper_sha256']+'; same cache slices; actual called-frontier selection and interpretation remain under auth/group')
