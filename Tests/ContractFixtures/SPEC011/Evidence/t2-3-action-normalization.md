# T2.3 Action Normalization

The recording coordinator's assembled handler type is the sole domain witness. Dynamic lowering checks
the borrowed occurrence against `Handler.Action`, performs the required total
raw-value round trip, and copies only the `UInt16` code into the two-byte
bounded value. No handler, action existential, model, or type token is retained.
Static assembly supplies the exact generic action type and therefore rejects a
wrong domain during compilation. The focused production Interaction target
does not own or import this handler-aware coordinator operation.
