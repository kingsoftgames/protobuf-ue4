#!/bin/bash

if [[ -z "${PROTOBUF_UE4_VERSION}" ]]; then
  echo "PROTOBUF_UE4_VERSION is not set, exit."
  exit 1
else
  echo "PROTOBUF_UE4_VERSION: ${PROTOBUF_UE4_VERSION}"
fi

if [[ -z "${PROTOBUF_UE4_PREFIX}" ]]; then
  echo "PROTOBUF_UE4_PREFIX is not set, exit."
  exit 1
else
  echo "PROTOBUF_UE4_PREFIX: ${PROTOBUF_UE4_PREFIX}"
fi

if [[ -z "${PROTOBUF_UE4_MACOS_DEPLOYMENT_TARGET}" ]]; then
  echo "PROTOBUF_UE4_MACOS_DEPLOYMENT_TARGET is not set, exit."
  exit 1
else
  echo "PROTOBUF_UE4_MACOS_DEPLOYMENT_TARGET: ${PROTOBUF_UE4_MACOS_DEPLOYMENT_TARGET}"
fi

readonly CORE_COUNT=$(sysctl -n machdep.cpu.core_count)
readonly PROTOBUF_DIR=protobuf-${PROTOBUF_UE4_VERSION}

rm -rf ${PROTOBUF_UE4_PREFIX}
mkdir -p ${PROTOBUF_UE4_PREFIX}

cd ${PROTOBUF_DIR}/cmake

# static 
cmake .                                                                 \
  -Dprotobuf_BUILD_SHARED_LIBS=OFF                                      \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=${PROTOBUF_UE4_MACOS_DEPLOYMENT_TARGET} \
  -DCMAKE_INSTALL_PREFIX="${PROTOBUF_UE4_PREFIX}/build"

make -j${CORE_COUNT}
make check
make install

rm -rf ${PROTOBUF_UE4_PREFIX}/mac
mkdir -p ${PROTOBUF_UE4_PREFIX}/mac/lib

mv ${PROTOBUF_UE4_PREFIX}/build/lib/libprotobuf.a ${PROTOBUF_UE4_PREFIX}/mac/lib/libprotobuf.a

rm -rf ${PROTOBUF_UE4_PREFIX}/build

otool -hv ${PROTOBUF_UE4_PREFIX}/mac/lib/libprotobuf.a | head -n 25


