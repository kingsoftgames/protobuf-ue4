#!/bin/bash

# 
# Please make sure the following environment variables are set before calling this script:
# PROTOBUF_UE4_VERSION  - Release version string.
# PROTOBUF_UE4_PREFIX   - Install path prefix string.
#

set -ex

if [ -z "$PROTOBUF_UE4_VERSION" ]; then
    echo "PROTOBUF_UE4_VERSION is not set, exit."
    exit 1
else
    echo "PROTOBUF_UE4_VERSION: $PROTOBUF_UE4_VERSION"
fi

if [ -z "$PROTOBUF_UE4_PREFIX" ]; then
    echo "PROTOBUF_UE4_PREFIX is not set, exit."
    exit 1
else
    echo "PROTOBUF_UE4_PREFIX: $PROTOBUF_UE4_PREFIX"
fi

if [ -z "$UE4_ROOT" ]; then
    echo "UE4_ROOT is not set, exit."
    exit 1
else
    echo "UE4_ROOT: $UE4_ROOT"
fi

if [ -d "$UE4_ROOT" ]; then
    echo "ok: UE4_ROOT exist."
else
    echo "error: UE4_ROOT no exist."
fi

PROTOBUF_URL=https://github.com/google/protobuf/releases/download/v$PROTOBUF_UE4_VERSION/protobuf-cpp-$PROTOBUF_UE4_VERSION.tar.gz
PROTOBUF_DIR=protobuf-$PROTOBUF_UE4_VERSION
PROTOBUF_TAR=$PROTOBUF_DIR.tar.gz

rm -rf $PROTOBUF_DIR

wget -q -O $PROTOBUF_TAR $PROTOBUF_URL

tar zxf $PROTOBUF_TAR
cd $PROTOBUF_DIR

rm -rf $PROTOBUF_UE4_PREFIX
mkdir -p $PROTOBUF_UE4_PREFIX

export CC=/usr/bin/clang-5.0
export CXX=/usr/bin/clang++-5.0
export UE4_LIBCXX_ROOT=$UE4_ROOT/Engine/Source/ThirdParty/Linux/LibCxx
export CXXFLAGS="-fPIC -O2 -DNDEBUG \
                -Wno-unused-command-line-argument \
                -nostdinc++ \
                -I$UE4_LIBCXX_ROOT/include \
                -I$UE4_LIBCXX_ROOT/include/c++/v1" 
export LDFLAGS="-L$UE4_LIBCXX_ROOT/lib/Linux/x86_64-unknown-linux-gnu"
export LIBS="-lc++ -lc++abi"

#static
./autogen.sh
./configure \
    --disable-shared \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix="$PROTOBUF_UE4_PREFIX/build"

make -j$(nproc)
make check
make install

rm -rf $PROTOBUF_UE4_PREFIX/linux
mkdir -p $PROTOBUF_UE4_PREFIX/linux/lib

mv $PROTOBUF_UE4_PREFIX/build/lib/libprotobuf.a $PROTOBUF_UE4_PREFIX/linux/lib/libprotobuf.a

rm -rf $PROTOBUF_UE4_PREFIX/build

objdump -h $PROTOBUF_UE4_PREFIX/linux/lib/libprotobuf.a | head -n 25