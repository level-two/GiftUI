from pathlib import Path
import ast,json,hashlib,datetime,sys,struct,bisect,collections,traceback
R=Path('/Users/eugene/work/GiftUI');H=Path(__file__).resolve().parent;P=H/'ledger.json';F=json.loads((H/'freeze.json').read_bytes());S=json.loads(P.read_bytes());sha=lambda b:hashlib.sha256(b).hexdigest();src=(H/'page.py').read_bytes();t=ast.parse(src);exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'charge','save','read','emit'}],type_ignores=[]),'<exact-frozen-accounting-functions>','exec'));args={'cmd':'python3 '+str(Path(__file__).relative_to(R)),'max_output_tokens':10000};code='// @exec: {"max_output_tokens":12000}\nconst r=await tools.exec_command('+json.dumps(args,separators=(',',':'))+');text(r.output);';S['requests'].append({'code':code,'args':args});S['transcript']+=len(code.encode())+len(json.dumps(args,separators=(',',':')).encode());charge(len(code.encode())*3+Path(__file__).stat().st_size*12);save()
try:
 ns={'struct':struct};t=ast.parse(read(F['inputs']['parser']));exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'object_metadata','branch_records'}],type_ignores=[]),'<exact-frozen-structural-functions>','exec'),ns);obj=read(F['inputs']['object']);charge(len(obj)*3);M=ns['object_metadata'](obj);roots=json.loads(read(F['inputs']['roots']));names=[h[1] for j in roots['root_object_joins'] for h in j['exact_disassembly_headers'] if h[0]=='P08CounterRuntime'];rootrows=[]
 for name in names:
  hits=M['aliases'].get(name,[]);S.setdefault('root_join_predicates',[]).append({'symbol':name,'aliases':hits});save()
  if len(hits)!=1:raise RuntimeError('exact frozen root alias not unique')
  rootrows.append({'symbol':name,'address':hits[0]['address']})
 bounds=M['bounds'];owner=lambda pc:bounds[bisect.bisect_right(bounds,pc)-1] if bounds[0]<=pc<bounds[-1] else None;graph={};frontier={};sites=[]
 for pc,op,to in ns['branch_records'](M):
  fr=owner(pc);rr=M['relocs'].get(pc)
  if rr and rr['symbol']=='_swift_allocObject':sites.append({'pc':pc,'owner':fr})
  if op not in ['bl','b','b.cond','cbz','cbnz','tbz','tbnz']:continue
  e={'pc':pc,'op':op}
  if rr:
   name=rr['symbol'];hits=M['aliases'].get(name,[])
   if len(hits)!=1:frontier.setdefault(fr,[]).append({'pc':pc,'op':op,'target_symbol':name,'local_alias_hits':len(hits)});continue
   to=hits[0]['address'];e['relocation_symbol']=name
  if to is not None and owner(to) is not None:
   dest=owner(to);e.update(to=dest,entry_addend=to-dest)
   if dest!=fr:graph.setdefault(fr,[]).append(e)
 reference=json.loads(read(F['inputs']['machine']))['after']['whole_object_allocator_import_sites'];expected={int(x['pc'],16) for x in reference};actual={x['pc'] for x in sites};S['site_identity_check']={'actual_count':len(actual),'reference_count':len(expected),'equal':actual==expected};save()
 if actual!=expected:raise RuntimeError('current17 exact site identity mismatch')
 parents=[]
 for root in rootrows:
  p={root['address']:None};q=collections.deque([root['address']])
  while q:
   n=q.popleft()
   for e in graph.get(n,[]):
    if e['to'] not in p:p[e['to']]=(n,e);q.append(e['to'])
  parents.append(p)
 rows=[];needed=set(x['address'] for x in rootrows)
 for site in sorted(sites,key=lambda x:x['pc']):
  chains=[]
  for root,p in zip(rootrows,parents):
   if site['owner'] not in p:chains.append({'root':root['address'],'status':'NOT_JOINED_IN_LOCAL_DIRECT_GRAPH','not_infeasible':True});continue
   node=site['owner'];edges=[]
   while p[node] is not None:
    fr,e=p[node];edges.append({'from':fr,**e});needed.add(fr);needed.add(node);node=fr
   chains.append({'root':root['address'],'status':'STRUCTURAL_PATH_ONLY','edges':list(reversed(edges))})
  rows.append({**site,'root_chains':chains});needed.add(site['owner'])
 selected={'object':F['inputs']['object'],'roots':rootrows,'sites':rows,'identities':[{'address':a,'end':bounds[bounds.index(a)+1],'symbols':M['texts'].get(a)} for a in sorted(needed)],'qualification':'Only selected exact rooted17-site joins retained. Direct graph reachability does not discharge branch/argument/type feasibility. Nonjoined is not absence/infeasibility; imported cross-module and indirect edges not closed.'};z=(json.dumps(selected,indent=2)+'\n').encode();charge(len(z)*3);(H/'selected-root-site-joins.json').write_bytes(z);S['selected_join_sha256']=sha(z);save();emit({'s':'SELECTED_EXACT_CURRENT_ROOT_SITE_JOINS','path':str((H/'selected-root-site-joins.json').relative_to(R)),'bytes':len(z),'sha256':sha(z),'roots':[hex(x['address']) for x in rootrows],'sites':[{'pc':hex(x['pc']),'owner':hex(x['owner']),'root_edges':[len(c.get('edges',[])) if 'edges' in c else None for c in x['root_chains']],'last_edges':[c.get('edges',[])[-2:] for c in x['root_chains'] if 'edges' in c]} for x in rows]})
except BaseException as e:
 S['selected_join_exception']={'type':type(e).__name__,'message':str(e),'traceback':traceback.format_exc()};save();emit({'s':'STOP','error':S['selected_join_exception']});sys.exit(2)
