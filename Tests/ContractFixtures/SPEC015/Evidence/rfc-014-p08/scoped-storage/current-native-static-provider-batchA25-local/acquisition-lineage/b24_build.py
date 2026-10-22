import pathlib,json,hashlib,subprocess,datetime
R=pathlib.Path('/Users/eugene/work/GiftUI');B=R/'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage';P=B/'current-native-static-provider-batchA22-local';H=B/'current-native-static-provider-batchA24-local';assert not H.exists();H.mkdir();(H/'invocation').mkdir()
s=(P/'inspect.py').read_text().replace('batchA22','batchA24').replace('/tmp/g22','/tmp/g24')
s=s.replace("selected=['_putchar','_fputc','_putc','_putc_unlocked','___swbuf','___swbuf0','___smakebuf','___sinit']","selected=['___swsetup','___smakebuf']")
needle="        rb=('\\n\\n'.join(raws)+'\\n').encode();"
pos=s.index(needle)
extra='''        initial=[]
        libc='/usr/lib/system/libsystem_c.dylib';provider=meta['providers'][libc]
        for symbol,amount in [('___stdoutp',8),('___sF',384)]:
            row=exports[libc].get(symbol)
            if not row or 'address' not in row:
                initial.append({'symbol':symbol,'status':'No exact data-export address in this frozen trie; no global absence claim'});continue
            address=row['address'];hits=[v for v in provider['slices'] if v['vmaddr'] is not None and v['vmaddr']<=address and address+amount<=v['vmaddr']+v['bytes'] and v['role'] not in ['exports-trie','function-starts','image-load-commands']]
            if len(hits)!=1:
                initial.append({'symbol':symbol,'address':hex(address),'status':'Exact address not wholly within one frozen provider data slice; not followed'});continue
            desc=hits[0];bb=provider_read(desc);off=address-desc['vmaddr'];rawdata=bb[off:off+amount]
            initial.append({'symbol':symbol,'address':hex(address),'raw_hex':rawdata.hex(),'file':desc['path'],'offset':desc['offset']+off,'sha256':digest(rawdata),'status':'Pristine frozen cache bytes only; pointer-slide/fixup and process-window state not inferred'})
        compact=[]
        for fn in functions:
            lines=[];expected=0
            for line in fn['instructions'].splitlines():
                off,op=line.split(':',1)
                if int(off,16)!=expected:raise RuntimeError('noncontiguous code cannot use implicit PCs')
                expected+=4;lines.append(re.sub(r',\\s+',',',op))
            assert expected==fn['end']-fn['address'];compact.append({'name':fn['name'],'base':hex(fn['address']),'code':'\\n'.join(lines)})
'''
s=s[:pos]+extra+s[pos:]
s=s.replace("'provider_scope':'Selected installed provider code only; earlier/later state and indirect bindings unresolved unless explicitly read'","'provider_scope':'Complete installed setup/buffer bodies plus bounded pristine data; current loaded/window state not inferred','initial_cache_data':initial")
a=s.index("        payload={'s':'PROVIDER'");z=s.index("        remaining=",a)
s=s[:a]+'''        payload={'s':'SETUP_BUFFER','start':state['groups'][gid]['started_utc'],'identities':{k:{'uuid':v['uuid'],'version':v['identity']['current_version']} for k,v in ids.items()},'functions':compact,'calls':[x for x in calls if x['exports']],'initial_cache_data':initial,'scope':'Exact PC=base+4*zero_based_instruction_index; all instructions retained. Actual23putchar→__swbuf→___swsetup relation reused by exact installed addresses/UUIDs; source/root21lemma unchanged. Pristine cache bytes are not actual process-window state; no runtime experiment or interposition/state assumption.'}
''' +s[z:]
(H/'inspect.py').write_text(s);(H/'deliver.py').write_text((P/'deliver.py').read_text().replace('/tmp/g22','/tmp/g24'));(H/'control.py').write_text((P/'control.py').read_text());(H/'provider-slices.json').write_bytes((P/'provider-slices.json').read_bytes())
refresh=json.loads((P/'refresh.json').read_bytes())
for key,path in [('PROOF23',B/'current-native-static-provider-batchA23-result/rows.json'),('HELPER23',B/'current-native-static-provider-batchA23-local/inspect.py'),('STOP22',B/'current-native-static-provider-batchA22-result/STOP-closeout.json')]:
 b=path.read_bytes();refresh[key]={'path':str(path.relative_to(R)),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'scope':'Exact frozen installed-body/context lineage; closed23rooted-frontier facts and immutable22STOP'}
(H/'refresh.json').write_text(json.dumps(refresh,indent=2)+'\n');plan={}
for mode,letter in [('auth','a'),('group','g'),('close-provider-gap','c'),('finish','f')]:
 args={'cmd':'python3 /tmp/g24 '+letter};code='const r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';plan[mode]={'mode':mode,'request_code':code,'nested_arguments':args,'counted_UTF8_bytes':len(code.encode())+len(json.dumps(args,separators=(',',':')).encode())}
(H/'requests.json').write_text(json.dumps(plan,indent=2)+'\n');rr=subprocess.run(['python3',str(H/'control.py')],stdout=subprocess.PIPE,stderr=subprocess.PIPE);assert rr.returncode==0 and not rr.stderr
f=json.loads((P/'invocation/freeze.json').read_bytes());f.update({'frozen_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'alias_target':str(H/'deliver.py'),'preflight_processing_upper_bytes':8388608,'orientation':'Exact23___swsetup prerequisite selected; full setup/buffer code and data interpretation only under24group; same originally frozen installed image slices'})
for key,path in [('helper_sha256','inspect.py'),('delivery_sha256','deliver.py'),('requests_sha256','requests.json'),('refresh_sha256','refresh.json'),('provider_slices_sha256','provider-slices.json'),('control_sha256','control.py'),('control_result_sha256','invocation/control.json')]:f[key]=hashlib.sha256((H/path).read_bytes()).hexdigest()
A=pathlib.Path('/tmp/g24');assert not A.exists() and not A.is_symlink();A.symlink_to(H/'deliver.py');(H/'invocation/freeze.json').write_text(json.dumps(f,indent=2)+'\n');print('24frozen '+f['helper_sha256']+'; actual full setup/buffer body/initial-state interpretation awaits active ledger')
