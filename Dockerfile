# Use Ubuntu 24.04 as base image
FROM ubuntu:24.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Update and install all required dependencies
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
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Set compiler environment variables
ENV CC=clang-17
ENV CXX=clang++-17
ENV CXXFLAGS="-stdlib=libc++ -std=c++17"
ENV LDFLAGS="-stdlib=libc++"

# Create a directory for stellar-core
WORKDIR /root

# Create a build script that can be run inside the container
RUN echo '#!/bin/bash\n\
set -e\n\
# Fix git ownership issue for mounted volumes\n\
git config --global --add safe.directory /root/stellar-core\n\
if [ ! -d "/root/stellar-core/.git" ]; then\n\
    echo "Stellar-core not found. Cloning repository..."\n\
    cd /root\n\
    git clone https://github.com/stellar/stellar-core\n\
    cd stellar-core\n\
    git checkout v23.0.0\n\
    git submodule init && git submodule update --init --recursive\n\
fi\n\
cd /root/stellar-core\n\
if [ ! -f "Makefile" ]; then\n\
    echo "Running initial configuration..."\n\
    ./autogen.sh\n\
    ./configure --enable-threadsafety\n\
    echo "Fixing xdrpp build issues..."\n\
    cd /root/stellar-core/lib/xdrpp\n\
    rm -f xdrc/scan.cc xdrc/parse.cc xdrc/parse.hh\n\
    flex -o xdrc/scan.cc xdrc/scan.ll\n\
    bison -d -o xdrc/parse.cc xdrc/parse.yy\n\
fi\n\
cd /root/stellar-core\n\
echo "Building stellar-core with $(($(nproc)-2)) cores..."\n\
make -j$(($(nproc)-2))\n\
echo "Build complete! Run ./src/stellar-core --version to verify"\n\
' > /usr/local/bin/build-stellar-core && \
    chmod +x /usr/local/bin/build-stellar-core

# Set the working directory
WORKDIR /root/stellar-core

# Default command to keep container running
CMD ["/bin/bash"]
