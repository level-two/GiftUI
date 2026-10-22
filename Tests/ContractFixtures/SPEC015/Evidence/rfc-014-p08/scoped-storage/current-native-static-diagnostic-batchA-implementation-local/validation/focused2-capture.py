import pathlib,subprocess,json,datetime,sys,os
R=pathlib.Path('/Users/eugene/work/GiftUI');C=R/'.build/contracts/p08-native-static-diagnostic-batchA'
argv=['python3', 'scripts/contracts/check-spec-015-counter.py', '--profile', 'macos-static', '--runtime-build', '.build/contracts/spec-013-runtime-cycle/tmps4xst3kt/macos-static', '--host-build', '.build/contracts/p08-scoped-host-7gj3vxnl', '--fresh-focused', '--select-family', 'runtime']
start=datetime.datetime.now(datetime.timezone.utc).isoformat();(C/'focused2-start.json').write_text(json.dumps({'started_utc':start,'argv':argv,'capture_pid':os.getpid(),'scope':'NativeStaticfinitefour-classcompilerconstructioncorrection; existingputchartransport; noU02orresourceclaim'},indent=2)+'\n');print('START '+start+' '+json.dumps(argv),flush=True)
with (C/'focused2.stdout').open('wb') as out,(C/'focused2.stderr').open('wb') as err:r=subprocess.run(argv,cwd=R,stdout=out,stderr=err)
end=datetime.datetime.now(datetime.timezone.utc).isoformat();(C/'focused2-exit.json').write_text(json.dumps({'ended_utc':end,'exit':r.returncode})+'\n');print('TERMINAL '+str(r.returncode)+' '+end,flush=True);sys.exit(r.returncode)
