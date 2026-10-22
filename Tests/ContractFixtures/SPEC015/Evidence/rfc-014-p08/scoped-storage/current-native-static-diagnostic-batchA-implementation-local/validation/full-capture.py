import pathlib,subprocess,json,datetime,sys,os,hashlib
R=pathlib.Path('/Users/eugene/work/GiftUI');C=R/'.build/contracts/p08-native-static-diagnostic-batchA'
argv=['python3','scripts/contracts/check-spec-015-counter.py','--profile','macos-static','--runtime-build','.build/contracts/spec-013-runtime-cycle/tmps4xst3kt/macos-static','--host-build','.build/contracts/p08-scoped-host-7gj3vxnl','--collect-failures']
ident=json.loads((C/'current-source-identities.json').read_text())
for row in ident:assert hashlib.sha256((R/row['path']).read_bytes()).hexdigest()==row['after_sha256']
now=datetime.datetime.now(datetime.timezone.utc);deadline=now+datetime.timedelta(hours=4)
start={'started_utc':now.isoformat(),'deadline_utc':deadline.isoformat(),'argv':argv,'capture_pid':os.getpid(),'source_identities':ident,'output_limit_bytes':805306368,'retained_bytes_before_full_known':433919300,'final_reserve_bytes':16777216,'amendment':'Coordinator amended ordinary validation512MiB to768MiB before full launch: immutable failed compile141355479B + focused153665965B + P0725073836B + capture/SIL/controls113824020B, plus full~176MiB/provider lineage/reserve. No U02 cap change; no wholeBatchA timing certification.'}
(C/'full-start.json').write_text(json.dumps(start,indent=2)+'\n');print('FULL_START '+json.dumps(start),flush=True)
with (C/'full.stdout').open('wb') as out,(C/'full.stderr').open('wb') as err:p=subprocess.run(argv,cwd=R,stdout=out,stderr=err)
end=datetime.datetime.now(datetime.timezone.utc);(C/'full-exit.json').write_text(json.dumps({'ended_utc':end.isoformat(),'exit':p.returncode,'elapsed_seconds':(end-now).total_seconds()})+'\n');print('FULL_TERMINAL '+str(p.returncode)+' '+end.isoformat(),flush=True);sys.exit(p.returncode)
