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

if [[ -z "${UE4_CLANG_VERSION}" ]]; then
  echo "UE4_CLANG_VERSION is not set, exit."
  exit 1
else
  echo "UE4_CLANG_VERSION: ${UE4_CLANG_VERSION}"
fi

if [[ -z "${UE4_ZLIB_VERSION}" ]]; then
  echo "UE4_ZLIB_VERSION is not set, exit."
  exit 1
else
  echo "UE4_ZLIB_VERSION: ${UE4_ZLIB_VERSION}"
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
  exit 1
fi

echo "MYCFLAGS: ${MYCFLAGS}"
echo "MYLDFLAGS: ${MYLDFLAGS}"

# protobuf
readonly PROTOBUF_URL=https://github.com/google/protobuf/releases/download/v${PROTOBUF_UE4_VERSION}/protobuf-cpp-${PROTOBUF_UE4_VERSION}.tar.gz
readonly PROTOBUF_DIR=protobuf-${PROTOBUF_UE4_VERSION}
readonly PROTOBUF_TAR=${PROTOBUF_DIR}.tar.gz

readonly UE4_CLANG_ROOT="${UE4_ROOT}/Engine/Extras/ThirdPartyNotUE/SDKs/HostLinux/Linux_x64/${UE4_CLANG_VERSION}/x86_64-unknown-linux-gnu"
readonly UE4_LIBCXX_ROOT="${UE4_ROOT}/Engine/Source/ThirdParty/Linux/LibCxx"
readonly UE4_ZLIB_DIR="${UE4_ROOT}/Engine/Source/ThirdParty/zlib/${UE4_ZLIB_VERSION}/lib/Linux/x86_64-unknown-linux-gnu"

if [[ -d "${UE4_CLANG_ROOT}" ]]; then
  echo "ok: UE4_CLANG_ROOT: ${UE4_CLANG_ROOT} exist."
else
  echo "error: UE4_CLANG_ROOT: ${UE4_CLANG_ROOT} no exist."
  exit 1
fi

if [[ -d "${UE4_LIBCXX_ROOT}" ]]; then
  echo "ok: UE4_LIBCXX_ROOT: ${UE4_LIBCXX_ROOT} exist."
else
  echo "error: UE4_LIBCXX_ROOT: ${UE4_LIBCXX_ROOT} no exist."
  exit 1
fi

if [[ -d "${UE4_ZLIB_DIR}" ]]; then
  echo "ok: UE4_ZLIB_DIR: ${UE4_ZLIB_DIR} exist."
else
  echo "error: UE4_ZLIB_DIR: ${UE4_ZLIB_DIR} no exist."
  exit 1
fi

mkdir -p "${PROTOBUF_UE4_PREFIX}"

echo "Downloading: ${PROTOBUF_URL}"
wget -q -O ${PROTOBUF_TAR} ${PROTOBUF_URL}
tar zxf ${PROTOBUF_TAR}

# using ue4 toolchain clang
export CC="${UE4_CLANG_ROOT}/bin/clang --sysroot=${UE4_CLANG_ROOT}"
export CXX="${UE4_CLANG_ROOT}/bin/clang++ --sysroot=${UE4_CLANG_ROOT}"

# the LLVM linker
export CFLAGS="-fuse-ld=lld ${MYCFLAGS}"

export CXXFLAGS="-fPIC                    \
  -O2                                     \
  -DNDEBUG                                \
  -Wno-unused-command-line-argument       \
  -nostdinc++                             \
  -I${UE4_LIBCXX_ROOT}/include            \
  -I${UE4_LIBCXX_ROOT}/include/c++/v1     \
  ${CFLAGS}"

# (1) for libc++.a  libc++abi.a
# (2) for libz.a
# (3) -L for lib*.a
# (4) -B This option specifies where to find the executables, libraries, include files, and data files of the compiler itself.
export LDFLAGS="-L${UE4_LIBCXX_ROOT}/lib/Linux/x86_64-unknown-linux-gnu \
  -L${UE4_ZLIB_DIR}                                                     \
  -L${UE4_CLANG_ROOT}/usr/lib64                                         \
  -B${UE4_CLANG_ROOT}/usr/lib64                                         \
  ${MYLDFLAGS}"

# for clang
export LIBS="-lc++ -lc++abi"

pushd ${PROTOBUF_DIR}
  ./autogen.sh
  ./configure                               \
    --disable-shared                        \
    --disable-debug                         \
    --disable-dependency-tracking           \
    --prefix="${PROTOBUF_UE4_PREFIX}"

  make -j$(nproc)
  make check
  make install

  objdump -h "${PROTOBUF_UE4_PREFIX}/lib/libprotobuf.a" | head -n 25
popd
