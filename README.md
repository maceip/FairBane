![FairBane](https://img.shields.io/website?down_message=FairBane%20Not%20Deployed%20%3A%28&up_message=FairBane&url=https%3A%2F%2Ffairbane.hyper.box)

![fb](https://github.com/user-attachments/assets/e9d66efa-9910-45af-a43e-05f6da3950da)
# FairBane

### a service for hackers!

this repo demonstrates running core internet infra: ***rootca, geth, tlsnotary, pkarr***; but with a twist: once it's deployed it's secrets will never be revealed. It achieves this via intel's encrypted virtual memory extension: TDX.

> [!IMPORTANT]
> This will be launched before devcon 2024 </br>
> bootstrapped attestations will be posted here when it boots

The DNS / ENS FairBane will control: 
```diff 
+hyper.box
```
is controlled by an ethereum keypair. ownership of that account will be irrevocably transfered to FairBane at boot.

How can I verify this?

```go
	mux.With(srv.httpLogger).Get("/attest/{appdata}", srv.handleAttest)
	mux.With(srv.httpLogger).Post("/verify", srv.handleVerify)
```

free public endpoints, never to be captured:

- pkarr relay: https://github.com/Pubky/pkarr/blob/main/design/relays.md
- pkarr resolver: https://github.com/Nuhvi/pkarr/blob/main/design/resolvers.md
- geth light client: https://github.com/ethereum/go-ethereum/tree/master/beacon/light
- tlsnotary server: https://github.com/tlsnotary/tlsn/tree/0b1eef12f3d80621b1dca6554f88c9f9e100bea7/crates/notary/server
- certificate authority for automated X.509 and SSH certificate management: https://hub.docker.com/r/smallstep/step-ca

__if the server is down, all its secrets went down with it__


