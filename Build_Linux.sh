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

if [[ -z "${UE4_ROOT}" ]]; then
  echo "UE4_ROOT is not set, exit."
  exit 1
else
  echo "UE4_ROOT: ${UE4_ROOT}"
fi

if [[ -d "${UE4_ROOT}" ]]; then
  echo "ok: UE4_ROOT exist."
else
  echo "error: UE4_ROOT no exist."
fi

readonly PROTOBUF_DIR=protobuf-${PROTOBUF_UE4_VERSION}

cd ${PROTOBUF_DIR}

rm -rf ${PROTOBUF_UE4_PREFIX}
mkdir -p ${PROTOBUF_UE4_PREFIX}

export CC=/usr/bin/clang-5.0
export CXX=/usr/bin/clang++-5.0
export UE4_LIBCXX_ROOT=${UE4_ROOT}/Engine/Source/ThirdParty/Linux/LibCxx
export CXXFLAGS="-fPIC                    \
  -O2                                     \
  -DNDEBUG                                \
  -Wno-unused-command-line-argument       \
  -nostdinc++                             \
  -I${UE4_LIBCXX_ROOT}/include            \
  -I${UE4_LIBCXX_ROOT}/include/c++/v1     \
  -I${PROTOBUF_UE4_WORKSPACE}/${PROTOBUF_DIR}/src"
  
export LDFLAGS="-L${UE4_LIBCXX_ROOT}/lib/Linux/x86_64-unknown-linux-gnu"
export LIBS="-lc++ -lc++abi"

# static
chmod +x autogen.sh                                          \
         src/google/protobuf/io/gzip_stream_unittest.sh      \
         src/google/protobuf/compiler/zip_output_unittest.sh

./autogen.sh
./configure                               \
  --disable-shared                        \
  --disable-debug                         \
  --disable-dependency-tracking           \
  --prefix="${PROTOBUF_UE4_PREFIX}/build"

make -j$(nproc)
make check
make install

rm -rf ${PROTOBUF_UE4_PREFIX}/linux
mkdir -p ${PROTOBUF_UE4_PREFIX}/linux/lib

mv ${PROTOBUF_UE4_PREFIX}/build/lib/libprotobuf.a ${PROTOBUF_UE4_PREFIX}/linux/lib/libprotobuf.a

rm -rf ${PROTOBUF_UE4_PREFIX}/build

objdump -h ${PROTOBUF_UE4_PREFIX}/linux/lib/libprotobuf.a | head -n 25