#!/usr/bin/env python3
"""Source coverage inventory, not a semantic call-graph or transformation proof."""
from pathlib import Path
import hashlib,json,re
H=Path(__file__).resolve().parent; R=H.parents[1]
paths=[
 'Sources/SignalAnalyzerPresentation/SignalAnalyzerView.swift',
 'Sources/SignalAnalyzerPresentation/SignalAnalyzerPresentationValues.swift',
 'Sources/SignalAnalyzerPresentation/SignalAnalyzerWaveformGeometry.swift',
 'Sources/SignalAnalyzerPresentation/SignalAnalyzerTimelineFormatting.swift',
 'Sources/SignalAnalyzerPresentation/SignalAnalyzerOwnerFailureAdapter.swift',
 'Sources/SignalAnalyzerPresentation/SignalAnalyzerPresentationAdmissionAdapter.swift',
 'Sources/SignalAnalyzerDomain/SignalValues.swift',
 'Sources/SignalAnalyzerDomain/SignalCapturePublication.swift',
 'Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFModelLocation.swift',
 'Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFModelCaptureState.swift',
 'Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPiInitialPresentationOwner.swift',
 'experiments/spike-014-external-consumer-access/PortableCounter.swift',
 'docs/iterations/iteration-003-review/rfc-014-c-contract.md']
records=[]
for path in paths:
 p=R/path
 if not p.exists(): raise SystemExit('Missing inventory input '+path)
 s=p.read_text()
 records.append(dict(path=path,sha256=hashlib.sha256(s.encode()).hexdigest(),symbols=[dict(line=i,text=line.strip()) for i,line in enumerate(s.splitlines(),1) if re.search(r'\b(func|var|let|class|struct)\b|\b(model|viewModel|state|capture)\.',line)]))
(H/'evidence/application-inventory.json').write_text(json.dumps(records,indent=2)+'\n')
print(f'{len(records)} source/contract inputs inventoried')
