#!/bin/bash

CORE_COUNT=$(sysctl -n machdep.cpu.core_count)

if [ -z "${PROTOBUF_UE4_VERSION}" ]; then
    echo "PROTOBUF_UE4_VERSION is not set, exit."
    exit 1
else
    echo "PROTOBUF_UE4_VERSION: $PROTOBUF_UE4_VERSION"
fi

if [ -z "${PROTOBUF_UE4_PREFIX}" ]; then
    echo "PROTOBUF_UE4_PREFIX is not set, exit."
    exit 1
else
    echo "PROTOBUF_UE4_PREFIX: $PROTOBUF_UE4_PREFIX"
fi

if [ -z "${PROTOBUF_UE4_MAC_DEPLOYMENT_TARGET}" ]; then
    echo "PROTOBUF_UE4_MAC_DEPLOYMENT_TARGET is not set, exit."
    exit 1
else
    echo "PROTOBUF_UE4_MAC_DEPLOYMENT_TARGET: $PROTOBUF_UE4_MAC_DEPLOYMENT_TARGET"
fi

rm -rf $PROTOBUF_UE4_PREFIX
mkdir -p $PROTOBUF_UE4_PREFIX

PROTOBUF_URL=https://github.com/google/protobuf/releases/download/v$PROTOBUF_UE4_VERSION/protobuf-cpp-$PROTOBUF_UE4_VERSION.tar.gz
PROTOBUF_DIR=protobuf-$PROTOBUF_UE4_VERSION
PROTOBUF_TAR=$PROTOBUF_DIR.tar.gz

rm -rf $PROTOBUF_DIR
wget -q -O $PROTOBUF_TAR $PROTOBUF_URL

tar zxf $PROTOBUF_TAR
cd $PROTOBUF_DIR/cmake

# static 
cmake -Dprotobuf_BUILD_SHARED_LIBS=OFF -DCMAKE_OSX_DEPLOYMENT_TARGET=$PROTOBUF_UE4_MAC_DEPLOYMENT_TARGET -DCMAKE_INSTALL_PREFIX="$PROTOBUF_UE4_PREFIX/build" .

make -j$CORE_COUNT
make check
make install

rm -rf $PROTOBUF_UE4_PREFIX/mac
mkdir -p $PROTOBUF_UE4_PREFIX/mac/lib

mv $PROTOBUF_UE4_PREFIX/build/lib/libprotobuf.a $PROTOBUF_UE4_PREFIX/mac/lib/libprotobuf.a

rm -rf $PROTOBUF_UE4_PREFIX/build

otool -hv $PROTOBUF_UE4_PREFIX/mac/lib/libprotobuf.a | head -n 25


