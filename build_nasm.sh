#!/bin/bash

set -e

cd $CROSS_COMPILE_SRC

wget https://www.nasm.us/pub/nasm/releasebuilds/2.11.08/nasm-2.11.08.tar.gz && tar -xzvf nasm-2.11.08.tar.gz && rm nasm-2.11.08.tar.gz
(cd nasm-2.11.08/ && ./configure --target=$CROSS_TARGET --prefix="$CROSS_PREFIX" && make all && make install)
rm -rf $CROSS_COMPILE_SRC/*

