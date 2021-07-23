#! /usr/bin/env bash
#
# Author: Hans Liljestrand <hans@liljestrand.dev>
# Copyright (C) 2021 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.

shared_libs=On
build_type=Debug
sanitizers=Memory

cmake -G Ninja \
    "-DCMAKE_BUILD_TYPE:STRING=${build_type}" \
    "-DCMAKE_INSTALL_PREFIX:FILEPATH=${HOME}/opt/llvm/mte"  \
    "-DLLVM_OCAML_INSTALL_PATH:FILEPATH=${HOME}/opt/ocaml/mte"  \
    "-DLLVM_TARGETS_TO_BUILD:STRING=AArch64"  \
    "-DLLVM_ENABLE_PROJECTS:STRING=clang"  \
    "-DLLVM_CCACHE_BUILD:BOOL=On"  \
    "-DLLVM_OPTIMIZED_TABLEGEN:BOOL=On"  \
    "-DCMAKE_CXX_STANDARD:STRING=14"  \
    "-DBUILD_SHARED_LIBS:BOOL=${shared_libs}"  \
    "-DLLVM_BUILD_TOOLS:BOOL=Off"  \
    "-DLLVM_PARALLEL_LINK_JOBS:STRING="  \
    "-DLLVM_DEFAULT_TARGET_TRIPLE:STRING=aarch64-unknown-linux-gnu"  \
    "-DLLVM_ENABLE_BINDINGS:BOOL=Off"  \
    "-DCMAKE_CXX_FLAGS:STRING=-Wno-deprecated-copy"  \
    "-DLLVM_USE_SANITIZER:STRING=${sanitizers}"  \
    -Wno-dev \
    ../../llvm
