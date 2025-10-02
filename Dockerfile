FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update -y && apt-get install -y \
    git \
    build-essential \
    pkg-config \
    autoconf \
    automake \
    libtool \
    libtool-bin \
    bison \
    flex \
    libpq-dev \
    parallel \
    libunwind-17-dev \
    sed \
    perl \
    clang-17 \
    libc++-17-dev \
    libc++abi-17-dev \
    libssl-dev \
    postgresql \
    ninja-build \
    cmake \
    libsodium-dev \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

ENV CC=clang-17
ENV CXX=clang++-17
ENV CXXFLAGS="-stdlib=libc++ -std=c++17"
ENV LDFLAGS="-stdlib=libc++"

WORKDIR /root

COPY build.sh /usr/local/bin/build-stellar
RUN chmod +x /usr/local/bin/build-stellar

WORKDIR /root/stellar-core

CMD ["/bin/bash"]
