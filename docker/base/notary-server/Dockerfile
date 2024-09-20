FROM notaryserverbuilds.azurecr.io/gramine/tlsn7:latest

WORKDIR /workspace

ARG CACHE_DATE=1
ARG BUILD_TAG
ENV BUILD_TAG=${BUILD_TAG}

COPY . /workspace/source

RUN chmod 1777 /tmp && \
    apt update && \
    apt install -y \
        build-essential \
    autoconf bison gawk nasm ninja-build pkg-config python3 python3-click \
    python3-jinja2 python3-pip python3-pyelftools wget libprotobuf-c-dev \
    protobuf-c-compiler protobuf-compiler python3-cryptography python3-pip python3-protobuf

RUN python3 -m pip install 'meson>=0.56' 'tomli>=1.1.0' 'tomli-w>=0.4.0'

RUN cd /root && \
    git clone https://gramineproject/gramine -b v1.7 && \
    cd gramine && \
    meson setup build/ --buildtype=release -Ddirect=enabled -Dsgx=enabled -Ddcap=enabled && \
    ninja -C build && \
    ninja -C build install

RUN cp /user/local/bin/* /workspace


WORKDIR /workspace
