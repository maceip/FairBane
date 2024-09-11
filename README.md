# freekey
### a service for hackers

this repo demonstrates running core internet infra: (rootCA, Geth, Pkarr, Tlsnotary) but with a twist: once it's deployed it's secrets will never be revealed. It achieves this using intel's encrypted virtual memory extension: TDX.

The domain is registered through 3dns.box, and the ephemeral wallet geth will create at boot will prove it owns the domain.

How can I verify this?

```go
	mux.With(srv.httpLogger).Get("/attest/{appdata}", srv.handleAttest)
	mux.With(srv.httpLogger).Post("/verify", srv.handleVerify)
```

free public endpoints, never to be captured:

pkarr relay: https://github.com/Pubky/pkarr/blob/main/design/relays.md
pkarr resolver: https://github.com/Nuhvi/pkarr/blob/main/design/resolvers.md
geth light client: https://github.com/ethereum/go-ethereum/tree/master/beacon/light
tlsnotary server: https://github.com/tlsnotary/tlsn/tree/0b1eef12f3d80621b1dca6554f88c9f9e100bea7/crates/notary/server
certificate authority for automated X.509 and SSH certificate management: 

if the server is down that means all its secrets went down with it


