import pathlib,subprocess,json,datetime,sys,os
R=pathlib.Path('/Users/eugene/work/GiftUI');C=R/'.build/contracts/p08-native-static-diagnostic-batchA'
argv=['scripts/contracts/run-spec-013.sh', '--profile', 'macos-static', '--compiler-baseline', 'rfc-014', '--giftui-build', '.build/contracts/spec-006-rfc-014-swift64/8e72c5a1adf5f02b-i9ayjitl/macos-static']
start=datetime.datetime.now(datetime.timezone.utc).isoformat();(C/'p07-start.json').write_text(json.dumps({'started_utc':start,'argv':argv,'capture_pid':os.getpid(),'scope':'NativeStaticfinitefour-classcompilerconstructioncorrection; existingputchartransport; noU02orresourceclaim'},indent=2)+'\n');print('START '+start+' '+json.dumps(argv),flush=True)
with (C/'p07.stdout').open('wb') as out,(C/'p07.stderr').open('wb') as err:r=subprocess.run(argv,cwd=R,stdout=out,stderr=err)
end=datetime.datetime.now(datetime.timezone.utc).isoformat();(C/'p07-exit.json').write_text(json.dumps({'ended_utc':end,'exit':r.returncode})+'\n');print('TERMINAL '+str(r.returncode)+' '+end,flush=True);sys.exit(r.returncode)
