#!/bin/bash
set -e

mkdir -p scripts
mkdir -p workspace
mkdir -p stellar-core

if [ ! -d "stellar-core/.git" ]; then
    git clone https://github.com/stellar/stellar-core
    cd stellar-core
    git checkout v23.0.0
    git submodule init
    git submodule update --init --recursive
    cd ..
fi

docker build -t stellar-core-dev:ubuntu24.04 .
docker-compose up -d
