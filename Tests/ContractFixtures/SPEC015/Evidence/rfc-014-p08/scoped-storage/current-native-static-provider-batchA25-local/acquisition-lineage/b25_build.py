import pathlib,json,hashlib,subprocess,datetime
R=pathlib.Path('/Users/eugene/work/GiftUI');B=R/'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage';P=B/'current-native-static-provider-batchA24-local';H=B/'current-native-static-provider-batchA25-local';assert not (H/'inspect.py').exists()
s=(P/'inspect.py').read_text().replace('batchA24','batchA25').replace('/tmp/g24','/tmp/g25')
s=s.replace("selected=['___swsetup','___smakebuf'];functions=[];raws=[];missing=[];calls=[]", "allocation_binding=[b for b in meta['stdio_stub_bindings'] if b['address']==0x180406c20]\n        assert len(allocation_binding)==1\n        selected=[('___swhatbuf',None),('stdio_once_callback',0x1803989a0),(allocation_binding[0]['symbol'],None)];functions=[];raws=[];missing=[];calls=[]")
s=s.replace("for symbol in selected:\n            hits=[(name,row) for name,rows in exports.items() if (row:=rows.get(symbol)) and 'address' in row]", "for symbol,exact_address in selected:\n            hits=[('/usr/lib/system/libsystem_c.dylib',{'address':exact_address})] if exact_address is not None else [(name,row) for name,rows in exports.items() if (row:=rows.get(symbol)) and 'address' in row]")
s=s.replace("for p in meta['providers'].values():\n        for d in p['slices']:provider_read(d)", "for p in meta['providers'].values():\n        for d in p['slices']:provider_read(d)\n    for d in meta.get('extra_slices',[]):provider_read(d)")
start=s.index('        initial=[]');end=s.index('        compact=[]',start)
s=s[:start]+'''        statebytes=provider_read(meta['pristine_state_range']);slideheaders=[{'mapping_vmaddr':hex(v['mapping_vmaddr']),'bytes_hex':provider_read(v['header']).hex()} for v in meta['state_slide_metadata']]
        initial=[{'symbol':'___sF','address':hex(meta['pristine_state_range']['vmaddr']),'raw_hex':statebytes.hex(),'slice':meta['pristine_state_range'],'status':'Pristine frozen cache bytes; actual process-window/once state not observed'}, {'symbol':'___stdoutp','address':'0x1ea4732a8','prior24_raw_hex':'7058f46c00001000','status':'Exact prior24cache-byte lemma, not live process pointer'}]
        requested={0x180406c20,0x180406f90}|{int(v['to'],16) for v in calls};bindings=[];deps=meta['providers']['/usr/lib/system/libsystem_c.dylib']['dependencies']
        for v in meta['stdio_stub_bindings']:
            if v['address'] not in requested:continue
            ordinal=v['library_ordinal'];lib=deps[ordinal-1]['name'] if 1<=ordinal<=len(deps) else 'special-or-unresolved-ordinal';matches=[{'provider':name,'address':hex(row['address'])} for name,rows in exports.items() if (row:=rows.get(v['symbol'])) and 'address' in row]
            bindings.append({'stub':hex(v['address']),'symbol':v['symbol'],'ordinal':ordinal,'dependency':lib,'selected_provider_exports':matches})
''' +s[end:]
s=s.replace("'initial_cache_data':initial", "'initial_cache_data':initial,'stub_bindings':bindings,'slide_headers':slideheaders")
s=s.replace("'s':'SETUP_BUFFER'", "'s':'BINDING_SIZE_STATE'")
s=s.replace("'initial_cache_data':initial,'stub_bindings':bindings,'slide_headers':slideheaders,'scope'", "'initial_cache_data':[{'symbol':v['symbol'],'address':v['address'],'raw_hex':v.get('raw_hex',v.get('prior24_raw_hex'))} for v in initial],'stub_bindings':bindings,'slide_headers':slideheaders,'scope'")
s=s.replace("Actual23putchar→__swbuf→___swsetup relation reused by exact installed addresses/UUIDs; source/root21lemma unchanged.", "Exact23/24root/putchar/setup/buffer lemmas reused. Code here is size/flag helper, exact setup-once callback and exact size-taking import provider entry.")
(H/'inspect.py').write_text(s);(H/'deliver.py').write_text((P/'deliver.py').read_text().replace('/tmp/g24','/tmp/g25'));(H/'control.py').write_text((P/'control.py').read_text())
refresh=json.loads((P/'refresh.json').read_bytes())
for key,path in [('PROOF24',B/'current-native-static-provider-batchA24-result/rows.json'),('HELPER24',P/'inspect.py')]:
 b=path.read_bytes();refresh[key]={'path':str(path.relative_to(R)),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'scope':'Closed24conditionalsetup/bufferbody lemma; exact same installedcache and source21bindings'}
(H/'refresh.json').write_text(json.dumps(refresh,indent=2)+'\n');plan={}
for mode,letter in [('auth','a'),('group','g'),('close-provider-gap','c'),('finish','f')]:
 args={'cmd':'python3 /tmp/g25 '+letter};code='const r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';plan[mode]={'mode':mode,'request_code':code,'nested_arguments':args,'counted_UTF8_bytes':len(code.encode())+len(json.dumps(args,separators=(',',':')).encode())}
(H/'requests.json').write_text(json.dumps(plan,indent=2)+'\n');rr=subprocess.run(['python3',str(H/'control.py')],stdout=subprocess.PIPE,stderr=subprocess.PIPE);assert rr.returncode==0 and not rr.stderr
f=json.loads((P/'invocation/freeze.json').read_bytes());f.update({'frozen_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'alias_target':str(H/'deliver.py'),'preflight_processing_upper_bytes':8388608,'orientation':'Only exact requested stub/import metadata and pristine selected512B state range added; actual binding/control/body reasoning under25group'})
for key,path in [('helper_sha256','inspect.py'),('delivery_sha256','deliver.py'),('requests_sha256','requests.json'),('refresh_sha256','refresh.json'),('provider_slices_sha256','provider-slices.json'),('control_sha256','control.py'),('control_result_sha256','invocation/control.json')]:f[key]=hashlib.sha256((H/path).read_bytes()).hexdigest()
A=pathlib.Path('/tmp/g25');assert not A.exists() and not A.is_symlink();A.symlink_to(H/'deliver.py');(H/'invocation/freeze.json').write_text(json.dumps(f,indent=2)+'\n');print('25frozen '+f['helper_sha256']+'; imports/state/size/callbackbody interpretation not begun')
