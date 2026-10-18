from pathlib import Path
import hashlib,json,tarfile,re
base=Path('Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result')
out=base/'analyzer-abi-diagnostic-policy-batch1'
a=base/'analyzer-abi-diagnostic-discovery-sweep-result'; b=base/'analyzer-abi-continuation-campaign10-result'
sha=lambda v:hashlib.sha256(v).hexdigest()
r=json.loads((a/'result.json').read_bytes()); c=json.loads((b/'campaign/result.json').read_bytes())
t=tarfile.open(a/'audits.tar.gz'); records={}; contexts={}; source_pool={}
def sources_for(root,stage,archive):
 paths=set(x['path'] for x in stage.get('inputs',[]) if x['path'].endswith('.swift'))
 if archive:
  # Enumerated compiler recipe inputs, never paths extracted from diagnostics.
  primary=next(x for x in stage['argv'] if x.endswith('.swift'))
  cell=primary.split('/inputs/')[0] if '/inputs/' in primary else str(Path(primary).parent)
  for name in ['AcquisitionState.swift','SignalPrimitiveValues.swift','SignalAnalyzerDiagnostic.swift','Analyzer.swift']:
   paths.add(cell+'/inputs/'+name)
  for name in ['AnalyzerSchema.swift','AnalyzerPresentation.swift']:
   paths.add(cell+'/'+name)
  positive=cell.rsplit('/scratch/',1)[0]+'/scratch/positive-actual-lowering'
  for name in ['AcquisitionState.swift','SignalPrimitiveValues.swift','SignalAnalyzerDiagnostic.swift','Analyzer.swift']:
   paths.add(positive+'/inputs/'+name)
 else:
  primary=next(x for x in stage['argv'] if x.endswith('.swift'));cell=str(Path(primary).parent)
  for name in ['AcquisitionState.swift','SignalPrimitiveValues.swift','SignalAnalyzerDiagnostic.swift','Analyzer.swift']:
   paths.add(cell+'/inputs/'+name)
  paths.add(primary)
 result={}
 for path in sorted(paths):
  if archive:
   file=root/'sources'/(sha(path.encode())+'-'+Path(path).name)
  else:
   # Campaign archive's manifest explicitly maps original paths to local paths.
   manifest=json.loads((root/'manifest.json').read_bytes())['files']
   matches=[root/x['path'] for x in manifest if x.get('original')==path]
   file=matches[0] if matches else root/'NOT_PRESENT'
  if file.is_file():
   data=file.read_bytes(); digest=sha(data);source_pool[digest]=data.decode();result[path]={'sha256':digest,'bytes':len(data)}
 return result

def add(profile,control,name,stage,stdout,stderr,context,source_map,origin):
 key=profile+'--'+control+'--'+name
 headers=[]
 for path,line,col,kind,msg in re.findall(r'^(.+?):(\d+):(\d+): (error|note|warning): (.*)$',stderr.decode(),re.M):
  row={'path':path,'line':int(line),'column':int(col),'kind':kind,'message':msg}
  if path in source_map:
   row['source_sha256']=source_map[path]['sha256']; row['source_row']=source_pool[row['source_sha256']].splitlines()[int(line)-1]
  else:
   assert kind=='note' and path.startswith('SignalAnalyzerDomain.SignalAnalyzerDiagnostic.'),path
   row['display_only']=True
  headers.append(row)
 assert any(x['kind']=='error' for x in headers)
 contexts[key]=context
 records[key]={'profile':profile,'control':control,'stage':name,'origin':origin,'context_sha256':sha(json.dumps(context,sort_keys=True,separators=(',',':'),allow_nan=False).encode()),'sources':source_map,'stdout':stdout.decode(),'stderr':stderr.decode(),'diagnostics':headers,'exit':1,'qualification':False}

for cell in r['cells']:
 if cell.get('rejection_stage') is None:continue
 stage=next(s for s in r['stages'] if s['id']==cell['id']+'--'+cell['rejection_stage'])
 audit_data=t.extractfile('audits/'+stage['id']+'.json').read();audit=json.loads(audit_data)
 assert sha(audit_data)==stage['prelaunch_audit']['sha256']
 # Complete audit is pinned by digest; selected authentication fields remain inspectable.
 context={k:stage[k] for k in ['id','argv','cwd','environment','effective_environment_sha256','inputs','prelaunch_audit']}
 context.update({k:audit[k] for k in ['current_commit','reviewed_packet_commit','reviewed_packet_tree','reviewed_packet_snapshot_sha256','dependencies']})
 context['compiler_and_tool_identities']=[x for x in audit['compiler_and_tool_identities'] if '/.toolchains/' in x['path'] or 'GiftUIMacros-tool' in x['path']]
 context['all_compiler_tool_identities_sha256']=sha(json.dumps(audit['compiler_and_tool_identities'],sort_keys=True,separators=(',',':')).encode())
 context['registered_control']=cell['registered_control'];context['qualified']=False
 stdout=(a/'logs'/Path(stage['stdout']['path']).name).read_bytes();stderr=(a/'logs'/Path(stage['stderr']['path']).name).read_bytes()
 assert sha(stdout)==stage['stdout']['sha256'] and sha(stderr)==stage['stderr']['sha256'] and stage['exit']==1
 add(cell['profile'],cell['control'],cell['rejection_stage'],stage,stdout,stderr,context,sources_for(a,stage,True),{'packet':a.name,'result_sha256':sha((a/'result.json').read_bytes()),'audit_sha256':sha(audit_data),'discovery_commit':r['current_commit']})
stage=next(s for s in c['stages'] if s.get('name')=='raspberry-pi-armv6-negative-A7-AnalyzerPresentation')
context={'stage':stage,'authenticated_current_commit':c['authenticated_current_commit'],'armv6_sdk_preflight':c['armv6_sdk_preflight'],'postformat_freeze_sha256':c['postformat_freeze_sha256'],'manifest_sha256':sha((b/'manifest.json').read_bytes()),'qualified':False}
# The complete reviewed preparation provenance pins compiler/tool inputs for this archive.
prep=base/'analyzer-abi-continuation-campaign10-preparation'
context['preparation_provenance_sha256']=sha((prep/'provenance.json').read_bytes())
context['compiler_identities']=json.loads((prep/'provenance.json').read_bytes())['compiler_identities']
context['p02_receipt_sha256']=sha((b/'campaign/receipts/2.json').read_bytes())
stdout=(b/'campaign/logs'/(stage['name']+'.stdout')).read_bytes();stderr=(b/'campaign/logs'/(stage['name']+'.stderr')).read_bytes()
assert stage['exit']==1 and sha(stderr)==stage['stderr_sha256'] and sha(stdout)==stage['stdout_sha256']
add('raspberry-pi-armv6','negative-A7','AnalyzerPresentation',stage,stdout,stderr,context,sources_for(b,stage,False),{'packet':b.name,'result_sha256':sha((b/'campaign/result.json').read_bytes()),'campaign_commit':c['authenticated_current_commit']})
assert len(records)==45
policy={'schema':1,'status':'unqualified_policy_static_only','cases':records,'source_pool':source_pool}
for name,value in [('policy.json',policy),('archived-captures.json',contexts)]:
 (out/name).write_text(json.dumps(value,indent=2,sort_keys=True)+'\n')
print('policy',sha((out/'policy.json').read_bytes()),'bytes',(out/'policy.json').stat().st_size,'sources',len(source_pool))
