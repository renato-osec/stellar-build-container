#!/bin/bash
set -e

git config --global --add safe.directory /root/stellar-core

if [ ! -d "/root/stellar-core/.git" ]; then
    cd /root
    git clone https://github.com/stellar/stellar-core
    cd stellar-core
    git checkout v23.0.0
    git submodule init
    git submodule update --init --recursive
fi

cd /root/stellar-core

if [ ! -f "Makefile" ]; then
    ./autogen.sh
    ./configure --enable-threadsafety
    
    cd /root/stellar-core/lib/xdrpp
    rm -f xdrc/scan.cc xdrc/parse.cc xdrc/parse.hh
    flex -o xdrc/scan.cc xdrc/scan.ll
    bison -d -o xdrc/parse.cc xdrc/parse.yy
fi

cd /root/stellar-core
make -j$(($(nproc)-2))
