import json,re,collections,pathlib,struct,bisect,sys,importlib.util
sys.dont_write_bytecode=True
root=pathlib.Path('/Users/eugene/work/GiftUI');out=pathlib.Path(__file__).resolve().parent
D=json.loads((out/'graph.json').read_text());F={int(k):v for k,v in D['functions'].items()}
spec=importlib.util.spec_from_file_location('facts',root/'scripts/contracts/p08_layout_facts.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
elf=m.ELF((root/'.build/nrf52840/signal-analyzer-static/rfc014-counter-firmware/zephyr/zephyr.elf').read_bytes())
mapping=sorted(set((s['value']&~1,s['name']) for s in elf.symbols if s['name'] in ('$t','$d') and 0<s['owner']<len(elf.sections) and elf.sections[s['owner']]['flags']&4))
conds={'eq','ne','cs','cc','hs','lo','mi','pl','vs','vc','hi','ls','ge','lt','gt','le'}
def reg(s):return {'sl':'r10','fp':'r11','ip':'r12','lr':'r14','pc':'r15','sp':'r13'}.get(s.strip(),s.strip())
def imm(s):
 try:return int(s.strip().lstrip('#'),0)
 except ValueError:return None
def val(k,a,b=None):
 b=a if b is None else b
 return (k,a,b,(a,) if a==b else None) if k=='c' else (k,a,b)
def cset(v):return v[3] if len(v)>3 else ((v[1],) if v[1]==v[2] else None)
def setval(xs):
 xs=tuple(sorted(set(xs)));return ('c',min(xs),max(xs),xs if len(xs)<=64 else None)
def plus(a,b,sgn=1):
 if a is None or b is None:return None
 if b[0]!='c' or a[0] not in ('s','c'):return None
 if a[0]=='c' and cset(a) and cset(b):return setval((x+sgn*y)&0xffffffff for x in cset(a) for y in cset(b))
 lo=a[1]+(b[1] if sgn==1 else -b[2]);hi=a[2]+(b[2] if sgn==1 else -b[1])
 if a[0]=='c' and lo==hi:lo=hi=lo&0xffffffff
 return val(a[0],lo,hi)
def mergev(a,b):
 if a is None or b is None or a[0]!=b[0]:return None
 if a[0]=='c' and cset(a) and cset(b):return setval(tuple(cset(a))+tuple(cset(b)))
 return val(a[0],min(a[1],b[1]),max(a[2],b[2]))
def readword(a):
 for s in elf.sections:
  if s['flags']&2 and s['type']!=8 and s['address']<=a and a+4<=s['address']+s['size']:
   return struct.unpack_from('<I',elf.section_data(s),a-s['address'])[0]
 return None
def splitargs(text):return [v.strip() for v in re.split(r',\s*(?![^\[]*\]|[^\{]*\})',text)]
def countregs(text):
 body=re.search(r'\{([^}]+)\}',text)
 if not body:return 0
 n=0
 for x in body[1].split(','):
  if '-' in x:
   a,b=x.split('-');n+=int(re.search(r'\d+',reg(b))[0])-int(re.search(r'\d+',reg(a))[0])+1
  else:n+=1
 return n
def solve(f, initial=None, inline_depth=0):
 ins={a:i for a,i in f['instructions'] if not i.startswith('.')};order=sorted(ins);nexta={a:order[j+1] if j+1<len(order) else None for j,a in enumerate(order)}
 if not order:return dict(complete=False,issues=['no instructions'])
 states={order[0]:initial or ({'r13':val('s',0)}, {})};exits=[];todo=collections.deque([order[0]]);counts=collections.Counter();issues=set();minimum=0;calls={};iterations=0
 def offer(a,R,M):
  if a is None or a not in ins:return
  if a not in states:states[a]=(R.copy(),M.copy());todo.append(a);return
  X,Y=states[a];nR={k:mergev(X.get(k),R.get(k)) for k in X.keys()|R.keys()};nM={k:mergev(Y.get(k),M.get(k)) for k in Y.keys()|M.keys()}
  if nR!=X or nM!=Y:
   counts[a]+=1
   if counts[a]>30:
    if nR.get('r13')!=X.get('r13') and counts[a]>1000:issues.add(f'nonconvergent SP at0x{a:x}');return
    nR={k:(v if k=='r13' or v==X.get(k) else None) for k,v in nR.items()};nM={k:(v if v==Y.get(k) else None) for k,v in nM.items()}
    if nR==X and nM==Y:return
   states[a]=(nR,nM);todo.append(a)
 while todo:
  a=todo.popleft();iterations+=1
  if iterations>100000:issues.add('instruction iteration bound');break
  R,M=states[a];R=R.copy();M=M.copy();orig=ins[a];text=orig.split(';')[0].split('<')[0].strip();op,*rest=text.split(None,1);args=splitargs(rest[0] if rest else '')
  op=op.replace('.w','').replace('.n','');conditional=False
  if op not in ('bl','blx','bx','b','tbb','tbh','cbz','cbnz') and len(op)>2 and op[-2:] in conds:
   conditional=True;op=op[:-2]
  if conditional:offer(nexta[a],R,M)
  def get(x):
   z=imm(x)
   if z is not None:return val('c',z)
   return val('c',a+4) if reg(x)=='r15' else R.get(reg(x))
  def address(s):
   z=re.search(r'\[([^\]]+)\]',s)
   if not z:return None
   aa=[v.strip() for v in z[1].split(',')];v=get(aa[0])
   if len(aa)>1:v=plus(v,get(aa[1]))
   return v
  if op in ('udf','bkpt'):continue
  if op in ('b','bl') or op.startswith('b') and op[1:] in conds:
   target=imm('0x'+args[0])
   if op=='bl':
    tf=F.get(target)
    if tf and tf['aliases'][0]['name'].startswith('OUTLINED_FUNCTION') and inline_depth<12:
     sub=solve(tf,(R,M),inline_depth+1);minimum=min(minimum,-sub['local_upper']);issues.update(sub['issues']);calls.update({str(a)+':'+str(k):v for k,v in sub['calls'].items()})
     for rr,mm in sub['exits']:offer(nexta[a],rr,mm)
     continue
    calls[a]=dict(sp=R.get('r13'),target=target,indirect=False,args=R.copy(),memory=[(k,v) for k,v in M.items() if v is not None])
    for k in ('r0','r1','r2','r3','r8','r12','r14'):R[k]=None
    if target not in (0x31a3e,0x414):offer(nexta[a],R,M)
    continue
   offer(target,R,M)
   if op!='b':offer(nexta[a],R,M)
   elif target not in ins:
    calls[a]=dict(sp=R.get('r13'),target=target,indirect=False,tail=True,args=R.copy(),memory=[(k,v) for k,v in M.items() if v is not None])
    tf=F.get(target)
    if tf and tf['aliases'][0]['name'].startswith('OUTLINED_FUNCTION') and inline_depth<12:
     sub=solve(tf,(R,M),inline_depth+1);minimum=min(minimum,-sub['local_upper']);issues.update(sub['issues']);calls.pop(a);calls.update({str(a)+':'+str(k):v for k,v in sub['calls'].items()});exits.extend(sub['exits'])
    else:
     for k in ('r0','r1','r2','r3','r8','r12','r14'):R[k]=None
     exits.append((R,M))
   continue
  if op in ('cbz','cbnz'):
   v=get(args[0]);t=imm('0x'+args[-1])
   if v and v[0]=='c' and v[1]==v[2]:offer(t if (v[1]==0)==(op=='cbz') else nexta[a],R,M)
   else:offer(t,R,M);offer(nexta[a],R,M)
   continue
  if op in ('tbb','tbh'):
   loc=a+4;unit=1 if op=='tbb' else 2;mark=next((j for j,v in enumerate(mapping) if v==(loc,'$d')),None)
   if mark is None or mark+1>=len(mapping):issues.add(f'unclosed{op} table0x{a:x}');continue
   end=mapping[mark+1][0]
   s=next((s for s in elf.sections if s['flags']&2 and s['type']!=8 and s['address']<=loc<end<=s['address']+s['size']),None)
   if s is None:issues.add(f'unmapped switch table0x{a:x}');continue
   data=elf.section_data(s)[loc-s['address']:end-s['address']]
   for j in range(0,len(data)-unit+1,unit):offer(loc+2*int.from_bytes(data[j:j+unit],'little'),R,M)
   continue
  if op in ('blx','bx'):
   if op=='bx' and reg(args[0])=='r14':exits.append((R,M));continue
   target=get(args[0]);calls[a]=dict(sp=R.get('r13'),target=target,indirect=True,args=R.copy(),memory=[(k,v) for k,v in M.items() if v is not None])
   if op=='blx':
    for k in ('r0','r1','r2','r3','r8','r12','r14'):R[k]=None
    offer(nexta[a],R,M)
   continue
  if op in ('push','vpush') or op in ('stmdb','vstmdb') and args[0]=='sp!':
   n=countregs(text)*(8 if op.startswith('v') else 4);R['r13']=plus(R.get('r13'),val('c',-n))
  elif op in ('pop','vpop') or op in ('ldmia','vldmia') and args[0]=='sp!':
   n=countregs(text)*(8 if op.startswith('v') else 4);R['r13']=plus(R.get('r13'),val('c',n))
   if re.search(r'\bpc\b',text):exits.append((R,M));continue
   for x in re.search(r'\{([^}]+)\}',text)[1].split(','):R[reg(x)]=None
  elif op in ('mov','movs','movw') and len(args)==2:R[reg(args[0])]=get(args[1])
  elif op=='movt' and len(args)==2:
   v=get(args[0]);n=imm(args[1]);R[reg(args[0])]=val('c',(v[1]&65535)|(n<<16)) if v and v[0]=='c' and v[1]==v[2] and n is not None else None
  elif op in ('add','adds','addw','sub','subs','subw'):
   dst=reg(args[0]);x=get(args[1] if len(args)==3 else args[0]);y=get(args[-1]);R[dst]=plus(x,y,-1 if op.startswith('sub') else 1)
  elif op in ('orr','orrs','and','ands','eor','eors'):
   x=get(args[1] if len(args)==3 else args[0]);y=get(args[-1]);n=None
   if x and y and x[0]==y[0]=='c' and x[1]==x[2] and y[1]==y[2]:n=(x[1]|y[1]) if op.startswith('orr') else ((x[1]&y[1]) if op.startswith('and') else (x[1]^y[1]))
   R[reg(args[0])]=val('c',n) if n is not None else None
  elif op=='bfc':
   dst=reg(args[0]);x=get(args[0]);lo=imm(args[1]);width=imm(args[2]);R[dst]=val(x[0],x[1]-(1<<width)+1,x[2]) if x and lo==0 else None
  elif op in ('bic','bics'):
   dst=reg(args[0]);x=get(args[1] if len(args)==3 else args[0]);mask=imm(args[-1]);R[dst]=val(x[0],x[1]-mask,x[2]) if x and mask is not None and mask&(mask+1)==0 else None
  elif op in ('ldr','ldrb','ldrh'):
   dst=reg(args[0]);loc=address(args[1]);v=None
   base=reg(re.search(r'\[([^,\]]+)',args[1])[1]);oldbase=get(base)
   if loc:
    if loc[0]=='s':
     candidate=M.get(loc);v=candidate if candidate and candidate[0]=='s' and op=='ldr' else None
    elif loc[0]=='c' and loc[1]==loc[2] and op=='ldr':
     # literal LDR aligns its PC base; other register loads do not.
     q=re.search(r'\[pc,\s*#(\d+)\]',args[1]);z=((a+4)&~3)+int(q[1]) if q else loc[1];readonly=any(sec['address']<=z<sec['address']+sec['size'] and not sec['flags']&1 for sec in elf.sections if sec['flags']&2);word=readword(z) if q or readonly else None;v=val('c',word) if word is not None else None
   R[dst]=v
   if len(args)>2:R[base]=plus(oldbase,get(args[2]))
   elif '!' in args[1]:R[base]=loc
   if dst=='r15':
    if '[sp' not in args[1]:calls[a]=dict(sp=R.get('r13'),target=v,indirect=True,tail=True,args=R.copy(),memory=[(k,v) for k,v in M.items() if v is not None])
    exits.append((R,M));continue
  elif op in ('str','strb','strh'):
   loc=address(args[1]);v=get(args[0])
   if loc and loc[0]=='s':
    if op=='str':M[loc]=v
    else:
     for kk in list(M):
      if kk[0]=='s' and kk[1]<loc[2]+4 and loc[1]<kk[2]+4:M[kk]=None
   if '!' in args[1] or len(args)>2:
    base=reg(re.search(r'\[([^,\]]+)',args[1])[1]);R[base]=loc if '!' in args[1] else plus(get(base),get(args[2]))
  elif op in ('ldmia','ldm'):
   base=reg(args[0].rstrip('!'));oldbase=get(base)
   for rr in re.search(r'\{([^}]+)\}',text)[1].split(','):R[reg(rr)]=None
   if args[0].endswith('!'):R[base]=plus(oldbase,val('c',4*countregs(text)))
  elif op in ('stmia','stm'):
   base=reg(args[0].rstrip('!'));loc=get(base);width=4*countregs(text)
   if loc and loc[0]=='s':
    for kk in list(M):
     if kk[0]=='s' and kk[1]<loc[2]+width and loc[1]<kk[2]+4:M[kk]=None
   if args[0].endswith('!'):R[base]=plus(loc,val('c',width))
  elif op in ('strd','ldrd'):
   loc=address(args[2]);base=reg(re.search(r'\[([^,\]]+)',args[2])[1]);oldbase=get(base)
   if loc and loc[0]=='s':
    if op=='strd':M[loc]=get(args[0]);M[plus(loc,val('c',4))]=get(args[1])
    else:
     for rr,kk in [(args[0],loc),(args[1],plus(loc,val('c',4)))]:
      vv=M.get(kk);R[reg(rr)]=vv if vv and vv[0]=='s' else None
   elif op=='ldrd':R[reg(args[0])]=R[reg(args[1])]=None
   if '!' in args[2]:R[base]=loc
   elif len(args)>3:R[base]=plus(oldbase,get(args[3]))
  elif op not in ('cmp','cmn','tst','teq','it','itt','ite','ittt','ittee','nop','udf','dmb','dsb','isb','bkpt','svc','msr','cpsid','cpsie') and args:
   if re.match(r'^(r\d+|sp|sl|fp|ip|lr)$',args[0]):R[reg(args[0])]=None
  v=R.get('r13')
  if v is None:issues.add(f'unknown SP after0x{a:x}:{orig}')
  elif v[0]!='s':issues.add(f'nonrelative SP after0x{a:x}:{orig}')
  else:minimum=min(minimum,v[1])
  offer(nexta[a],R,M)
 return dict(complete=not issues,local_upper=-minimum,issues=sorted(issues),calls=calls,iterations=iterations,exits=exits)
if __name__=='__main__':
 results={}
 for a,f in F.items():
  results[a]=solve(f);results[a].pop('exits')
 (out/'local-sp.json').write_text(json.dumps({str(k):v for k,v in results.items()},indent=2)+'\n')
 for name,a in D['roots'].items():
  seen=set();todo=[a]
  while todo:
   b=todo.pop()
   if b in seen:continue
   seen.add(b);todo.extend(x['target'] for x in F[b]['direct'] if x['target'] in F)
  bad=[x for x in seen if not results[x]['complete']]
  print(name,'local closed',len(seen)-len(bad),'/',len(seen),'bad',len(bad),'topbad',[(hex(x),results[x]['issues'][:1]) for x in bad[:5]])
 print('global local closed',sum(r['complete'] for r in results.values()),'/',len(results))
