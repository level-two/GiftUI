1: import GiftUI
2: import GiftUIExecution
3: import GiftUISemanticCore
4:
5: /// The configured component pools are independent of the two semantic banks.
6: /// The selected storage types own complete inline keys (including the endpoint
7: /// role); no reference or ordinal from a semantic bank is retained here.
8: package struct InteractionOwnedKeyState<Candidate, Committed, Hits>: ~Copyable, ~Escapable,
9:     InteractionCandidateBuilder, InteractionCommittedActionView, InteractionGestureResolver
10: where
11:     Candidate: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
12:     Committed: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
13:     Hits: InteractionHitRegionStorage & ~Copyable & ~Escapable,
14:     Candidate.Identity == SemanticCompleteIdentity,
15:     Committed.Identity == SemanticCompleteIdentity, Hits.Identity == SemanticCompleteIdentity
16: {
17:     package typealias Identity = SemanticCompleteIdentity
18:     private var state: InteractionState<Candidate, Committed, Hits>
19:     private let maximumComponentsPerKey: UInt16
20:     private let maximumComponents: UInt32
21:     private var configuredComponentsPerKey: UInt16
22:     private var configuredComponents: UInt32
23:     private var candidateComponents: UInt32 = 0
24:     package private(set) var committedComponents: UInt32 = 0
25:     private var isStaging = false
26:     private var failure: InteractionError?
27:     @_lifetime(copy state)
28:     package init?(
29:         state: consuming InteractionState<Candidate, Committed, Hits>,
30:         maximumComponentsPerKey: UInt16, maximumComponents: UInt32
31:     ) {
32:         guard maximumComponentsPerKey > 0,
33:             maximumComponentsPerKey <= SemanticCompleteIdentity.capacity, maximumComponents > 0
34:         else { return nil }
35:         self.state = consume state
36:         self.maximumComponentsPerKey = maximumComponentsPerKey
37:         self.maximumComponents = maximumComponents
38:         configuredComponentsPerKey = maximumComponentsPerKey
39:         configuredComponents = maximumComponents
40:     }
41:
42:     package var identityCapacities: (perKey: UInt16, perBank: UInt32) {
43:         (maximumComponentsPerKey, maximumComponents)
44:     }
45:
46:     package mutating func configureIdentityLimits(perKey: UInt16, perBank: UInt32) -> Bool {
47:         guard !isStaging, committedComponents == 0, perKey > 0, perKey <= maximumComponentsPerKey,
48:             perBank > 0, perBank <= maximumComponents
49:         else { return false }
50:         configuredComponentsPerKey = perKey
51:         configuredComponents = perBank
52:         return true
53:     }
54:
55:     package mutating func beginCandidate(limits: InteractionLimits) -> InteractionError? {
56:         if let error = state.beginCandidate(limits: limits) { return error }
57:         candidateComponents = 0
58:         failure = nil
59:         isStaging = true
60:         return nil
61:     }
62:     package mutating func rejectCandidate(_ error: InteractionError)
63:         -> InteractionCandidateAppendResult
64:     {
65:         guard isStaging else { return .failure(.invalidPhase) }
66:         if failure == nil { failure = error }
67:         return .failure(failure!)
68:     }
69:     /// Validates while the caller holds the candidate-bank borrow and copies its
70:     /// complete key synchronously. A stale/wrong-bank reference never stages.
71:     @inline(__always)
72:     package mutating func append<Payload>(
73:         record: SemanticRecordReference, in view: borrowing SemanticRecordView<Payload>,
74:         isEnabled: Bool, bounds: Rect, clip: Rect, paintOrder: UInt16,
75:         action: BoundedApplicationAction, targetGeneration: ObservableTargetGeneration
76:     ) -> InteractionCandidateAppendResult {
77:         guard isStaging else { return .failure(.invalidPhase) }
78:         if let failure { return .failure(failure) }
79:         guard view.isCandidate, view.record(record)?.kind == .action,
80:             let identity = view.completeIdentity(for: record)
81:         else { return rejectCandidate(.invalidIdentity) }
82:         return append(
83:             identity: identity, isEnabled: isEnabled, bounds: bounds, clip: clip,
84:             paintOrder: paintOrder, action: action, targetGeneration: targetGeneration)
85:     }
86:     @inline(__always)
87:     package mutating func append(
88:         identity: Identity, isEnabled: Bool, bounds: Rect, clip: Rect, paintOrder: UInt16,
89:         action: BoundedApplicationAction, targetGeneration: ObservableTargetGeneration
90:     ) -> InteractionCandidateAppendResult {
91:         guard isStaging else { return .failure(.invalidPhase) }
92:         if let failure { return .failure(failure) }
93:         if let error = appendFailure(
94:             identity: identity, bounds: bounds, clip: clip, paintOrder: paintOrder)
95:         {
96:             return rejectCandidate(error)
97:         }
98:         let next = candidateComponents + UInt32(identity.count)
99:         let result = state.append(
100:             identity: identity, isEnabled: isEnabled, bounds: bounds, clip: clip,
101:             paintOrder: paintOrder, action: action, targetGeneration: targetGeneration)
102:         switch result {
103:         case .failure(let error): return rejectCandidate(error)
104:         case .preserved, .requiresGeneration:
105:             candidateComponents = next
106:             return result
107:         }
108:     }
109:     package borrowing func appendFailure(
110:         identity: Identity, bounds: Rect, clip: Rect, paintOrder: UInt16
111:     ) -> InteractionError? {
112:         guard isStaging else { return .invalidPhase }
113:         if let failure { return failure }
114:         var failures = InteractionVisibleFailures()
115:         if let error = state.appendFailure(
116:             identity: identity, bounds: bounds, clip: clip, paintOrder: paintOrder)
117:         {
118:             failures.insert(error)
119:         }
120:         if identity.count < 2 || identity.component(at: 0)?.kind != .root
121:             || identity.component(at: identity.count - 1)?.kind != .declarationRole
122:         {
123:             failures.insert(.invalidIdentity)
124:         }
125:         let next = candidateComponents.addingReportingOverflow(UInt32(identity.count))
126:         let keyLimit = configuredComponentsPerKey
127:         let poolLimit = configuredComponents
128:         if identity.count > keyLimit || next.overflow
129:             || next.partialValue > poolLimit
130:         {
131:             failures.insert(.capacityExhausted)
132:         }
133:         return InteractionFailurePrecedence.select(from: failures)
134:     }
135:
136:     package mutating func assignGeneration(_ generation: ActionGeneration, to identity: Identity)
137:         -> InteractionError?
138:     {
139:         if let failure { return failure }
140:         if let error = state.assignGeneration(generation, to: identity) {
141:             failure = error
142:             return error
143:         }
144:         return nil
145:     }
146:     package mutating func finishCandidate() -> InteractionError? {
147:         if let failure { return failure }
148:         if let error = state.finishCandidate() {
149:             failure = error
150:             return error
151:         }
152:         isStaging = false
153:         return nil
154:     }
155:     package mutating func resolveCandidate(_ disposition: InteractionCandidateDisposition) {
156:         let ready = state.candidateIsReadyForOffer && failure == nil
157:         // A rejected append poisons the whole candidate even if a caller asks
158:         // to commit; no partial routing can become current.
159:         if case .commit = disposition, !ready { return }
160:         state.resolveCandidate(disposition)
161:         if case .commit = disposition { committedComponents = candidateComponents }
162:         candidateComponents = 0
163:         failure = nil
164:         isStaging = false
165:     }
166:     /// The containing runtime must establish quiescence before clearing routing.
167:     package mutating func resetAllStorage() {
168:         state.resetAllStorage()
169:         candidateComponents = 0
170:         committedComponents = 0
171:         isStaging = false
172:         failure = nil
173:     }
174:
175:     package var committedRevision: PresentationRevision? { state.committedRevision }
176:     package var committedRecordCount: UInt16 { state.committedRecordCount }
177:     package borrowing func committedRecord(for identity: Identity) -> BoundActionRecord<Identity>? {
178:         state.committedRecord(for: identity)
179:     }
180:     @inline(__always)
181:     package borrowing func resolveDown(at point: Point) -> PointerGestureOutcome<Identity> {
182:         state.resolveDown(at: point)
183:     }
184:     package borrowing func resolveMove(_ captured: CapturedAction<Identity>, at point: Point)
185:         -> PointerGestureOutcome<Identity>
186:     { state.resolveMove(captured, at: point) }
187:     @inline(__always)
188:     package borrowing func resolveUp(_ captured: CapturedAction<Identity>, at point: Point)
189:         -> PointerGestureOutcome<Identity>
190:     { state.resolveUp(captured, at: point) }
191: }
192:
193: // Conditional ownership preserves the existing owned bank aliases.
194: extension InteractionOwnedKeyState: Copyable
195: where
196:     Candidate: Copyable & ~Escapable, Committed: Copyable & ~Escapable, Hits: Copyable & ~Escapable
197: {}
198: extension InteractionOwnedKeyState: Escapable
199: where
200:     Candidate: Escapable & ~Copyable, Committed: Escapable & ~Copyable, Hits: Escapable & ~Copyable
201: {}
202:
203: // Instrumentation is confined to owned banks; it exports fixed value facts only.
204: extension InteractionOwnedKeyState
205: where
206:     Candidate: InteractionOwnedBankMeasurementSource,
207:     Committed: InteractionOwnedBankMeasurementSource,
208:     Hits: InteractionOwnedBankMeasurementSource
209: {
210:     package borrowing func ownedStorageMeasurement() -> InteractionOwnedStorageMeasurement {
211:         state.ownedStorageMeasurement()
212:     }
213: }
