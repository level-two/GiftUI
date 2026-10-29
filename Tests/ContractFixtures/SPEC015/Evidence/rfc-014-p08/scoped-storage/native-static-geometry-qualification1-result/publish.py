from pathlib import Path
import json,hashlib,datetime
from meter import Meter
m=Meter();B=Path(__file__).resolve().parent
A=Path('Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-static-geometry-qualification1-result');A.mkdir(exist_ok=False)
out=json.loads(m.read(B/'outcome.json'));out['review']='Independent coordinator substantive ACCEPT; transcribed delivered review in independent-review.md. Publication/ledger closure only remains.';out['coordinator_processing_charged_bytes']=5550852;out['coordinator_processing_note']='Includes512KiB advice exactly once; final2,365,282B review/hash charge and earlier conservative uncertainty. Advice transcript exceeded12KiB split forecast and consumes32KiB of existing128KiB total.';out['publication_archive']=str(A);m.save('outcome.json',out)
review='''# Independent scoped review

Coordinator independently accepts the geometry scalar family. Source changes are only eight conditional checked annotations; all five source/fixture hashes match. Four fresh checked producers and ordinary twins pass. Full module traces bind all nine intended providers. Runtime-argument noinline imported wrappers and61 boundary checks pass; controls0/1 and repository formatting lint0. The independently hashed focused executable is1,152,304bytes.

All four ordinary/qualified defined global-symbol inventories match and preserve every baseline export. GiftUI adds26 existing witness/initializer symbols in both fresh testing-enabled recipes; the testing-recipe cause remains supported inference, not controlled reproduction, binary identity or resource equality.

Actual42 remains FAIL at Observable ownership.storageCapacities outside this family. Host is unadopted; global current-callee/U03/lifetime/unsafe-bridge/cold/resource/target/P08 obligations remain open. Wrong-provider, missing-link-modules, plan-order, ABI assertion failures and premature corrected-link sequencing are preserved, with no retrospective preflight claim.

This is a transcription of the coordinator’s delivered review, not a cryptographic signature. Combined coordinator/advice charged processing is5,550,852bytes, including512KiB advice once. Advice’s12KiB transcript split forecast missed;32KiB is charged within the existing128KiB reviewer transcript reserve.
'''
readme='''# Native Static geometry scalar qualification

Scoped ACCEPT: four complete checked defining modules, ordinary twins and61 boundary checks pass. The exact42-input allocation entry remains FAIL at CounterProfileStorage.swift45: ownership.storageCapacities. No complete allocation, cold, resource or P08 acceptance follows.

The four maintained files add eight GIFTUI_GEOMETRY_QUALIFICATION-only @_noAllocation annotations to the actual five geometry/render global values’ constructor dependencies: LayoutLimits, DrawingLimits, RenderLimits, RenderWorkspaceCapacity, Point, Size, Rect and checked GeometryArithmetic.add. Original bodies, guards, fields, defaults and layout remain byte-for-byte after removing those annotation blocks. Adjacent APIs are unchanged.

The single focused executable contains all eight imported noinline runtime-argument checked wrappers. It covers exact counter values, smallest/max valid limits, zero at each guarded position, invalid signed line widths, Drawing’s normalized-operations relation, every stored field, zero-size acceptance, negative representable origins, both signed-add overflow directions, both Rect endpoint overflows and value layouts. Seven retained object modules are the legitimate scalar dead_strip closure; Execution remains a declared eighth target dependency with no retained required symbol. No full Counter executable or pruning was used.

All four ordinary/qualified global symbol inventories are identical, and all old exports remain. Fresh GiftUI uses enable-testing and has26 extra existing witness/initializer symbols compared with the retained baseline. That flag cause is inferred from recorded recipes, not a controlled reproduction. No baseline binary identity or target/resource equality is claimed.

Failure history remains explicit: first actual-entry selected old Host due fallback import order; first link omitted three defining-module dependencies; stored plan order tried the absent executable before appended build2; corrected link finished before the later STOP/reassess message and closure review; initial ABI assertion incorrectly required exact baseline equality. No retrospective preflight, erased failure or new helper variant is claimed.

batch-plan.json has exact argv; input-freeze/source-freeze and producer receipts bind sources/modules. validation-summary and complete raw streams bind outcomes; provider-order-and-loading authenticates all nine intended providers. candidate.patch and the versioned GeometryQualification.swift reproduce the candidate from1e147925. run.py/meter.py preserve the bounded runner; invoke final build2 before execute when replaying individual jobs because the preserved plan retains its original failed ordering.

The fixed geometry session is19:34:38.834107–21:34:38.834107UTC29October,7200seconds,512MiB processing and8MiB shared retained output/transcript. No previous16MiB amendment transfers. Conservative orientation/external/transcript provisions and append-only processing reconciliation disclose uncertainty. Exact modules/binary remain once under .build/contracts/p08-native-static-geometry-qualification1. Independent review accepts only this scope. Root owns Git publication; unrelated edits remain outside the manifest.
'''
def archive(name,data):
 p=A/name;assert not p.exists();assert m.retained()+m.external_retained()+len(data)+m.reserve()<m.state['retention_limit_bytes'];p.write_bytes(data)
files=['batch-plan.json','input-freeze.json','source-before.json','source-freeze.json','source-normalization.json','candidate.patch','validation-summary.json','provider-order-and-loading.json','ordinary-qualified-symbol-comparison.json','baseline-recipe-difference.json','preserved-initial-symbol-assertion-failure.json','preserved-launch-order-failure.json','additional-link-inputs.json','outcome.json','processing-reconciliation.json','actual-entry.raw','actual-entry2.raw','geometry-functional-build.raw','geometry-functional-build2.raw','geometry-functional-execute.raw','allocation-negative.raw','positive-source.json','allocation-negative-source.json','prepare.py','run.py','meter.py','final-checks.py','compare-symbols.py','close.py','publish.py']
forecast=sum((B/x).stat().st_size for x in files)+len(review.encode())+len(readme.encode())+15000
assert m.retained()+m.external_retained()+forecast+m.reserve()<m.state['retention_limit_bytes']
for n in files:archive(n,m.read(B/n))
archive('independent-review.md',review.encode());archive('README.md',readme.encode())
manifest={'source_paths':list(out['source_scope']),'evidence_directory':str(A),'archive_files':{str(p):{'bytes':p.stat().st_size,'sha256':hashlib.sha256(m.read(p)).hexdigest()} for p in sorted(A.iterdir())},'producer_root':str(B),'baseline':'1e147925','no_index_commit_by_owner':True}
m.save('scope-manifest.json',manifest);archive('scope-manifest.json',m.read(B/'scope-manifest.json'))
print(json.dumps({'archive_bytes':sum(p.stat().st_size for p in A.iterdir()),'local_bytes':m.retained(),'combined_plus_reserves':m.retained()+m.external_retained()+m.reserve(),'remaining_hard_envelope_bytes':m.state['retention_limit_bytes']-m.retained()-m.external_retained()-m.reserve(),'processing_charged':m.state['processing_own_metered_bytes']}))
