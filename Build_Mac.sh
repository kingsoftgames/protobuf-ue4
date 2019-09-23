#!/bin/bash

set -ex

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
readonly PROTOBUF_URL=https://github.com/google/protobuf/releases/download/v${PROTOBUF_UE4_VERSION}/protobuf-cpp-${PROTOBUF_UE4_VERSION}.tar.gz
readonly PROTOBUF_DIR=protobuf-${PROTOBUF_UE4_VERSION}
readonly PROTOBUF_TAR=${PROTOBUF_DIR}.tar.gz

mkdir -p "${PROTOBUF_UE4_PREFIX}"

echo "Downloading: ${PROTOBUF_URL}"
wget -q -O ${PROTOBUF_TAR} ${PROTOBUF_URL}
tar zxf ${PROTOBUF_TAR}

pushd ${PROTOBUF_DIR}/cmake
  cmake .                                                                 \
    -Dprotobuf_BUILD_SHARED_LIBS=OFF                                      \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${PROTOBUF_UE4_MACOS_DEPLOYMENT_TARGET} \
    -DCMAKE_BUILD_TYPE=Release                                            \
    -DCMAKE_INSTALL_PREFIX="${PROTOBUF_UE4_PREFIX}"

  make -j${CORE_COUNT}
  make check
  make install

  otool -hv "${PROTOBUF_UE4_PREFIX}/lib/libprotobuf.a" | head -n 25
popd
