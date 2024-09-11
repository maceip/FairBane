FROM ubuntu:20.04 AS builder

ARG RUST_TOOLCHAIN='1.81.0'

WORKDIR /src
COPY . .

RUN apt-get update && \
    DEBIAN_FRONTEND='noninteractive' apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates cmake pkg-config libssl-dev git build-essential llvm clang libclang-dev rsync libboost-all-dev zlib1g-dev miniupnpc protobuf-compiler curl git make libcap-dev

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain="${RUST_TOOLCHAIN}" && \
    $HOME/.cargo/bin/rustup target add wasm32-unknown-unknown --toolchain "${RUST_TOOLCHAIN}"

RUN curl --proto '=https' --tlsv1.2 -sSf https://dl.google.com/go/go1.23.1.linux-amd64.tar.gz | tar -zxC /usr/local

RUN echo "compiling geth-light node" && \
	 git clone --depth 1 --recurse-submodules --shallow-submodules -j 8 https://github.com/ethereum/go-ethereum && \
	 cd go-ethereum && \
         PATH="$HOME/.cargo/bin:$PATH" make geth && \
	  cp build/bin/geth  ./src/bin

RUN echo "compiling dht node" && \
	 git clone --depth 1 --recurse-submodules --shallow-submodules -j 8 https://github.com/Nuhvi/pkarr dht && \
	 cd dht/server && \
         PATH="$HOME/.cargo/bin:$PATH" cargo build --release && \
	  cp ../target/release/pkarr-server ./src/bin

RUN echo "compiling tlshotary node" && \
         git clone --depth 1 --recurse-submodules --shallow-submodules -j 8 https://github.com/tlsnotary/tlsn  && \
         cd tlsn/crates/notary/server && \
         PATH="$HOME/.cargo/bin:$PATH" cargo build --release && \
          cp ../../../target/release/notary-server ./src/bin

RUN echo "compiling certificate authority"
RUN make V=1 bin/step-ca
RUN setcap CAP_NET_BIND_SERVICE=+eip bin/step-ca


FROM smallstep/step-cli:latest

COPY --from=builder /src/bin/step-ca /usr/local/bin/step-ca

USER step

ENV CONFIGPATH="/home/step/config/ca.json"
ENV PWDPATH="/home/step/secrets/password"

VOLUME ["/home/step"]
STOPSIGNAL SIGTERM
HEALTHCHECK CMD step ca health 2>/dev/null | grep "^ok" >/dev/null

COPY docker/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD exec /usr/local/bin/step-ca --password-file $PWDPATH $CONFIGPATH
