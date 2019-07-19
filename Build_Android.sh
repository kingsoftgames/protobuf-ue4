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

if [[ -z "${NDKROOT}" ]]; then
  echo "NDKROOT is not set, exit."
  exit 1
else
  echo "NDKROOT: ${NDKROOT}"
fi

readonly PROTOBUF_DIR=protobuf-${PROTOBUF_UE4_VERSION}

cd ${PROTOBUF_DIR}

rm -rf ${PROTOBUF_UE4_PREFIX}
mkdir -p ${PROTOBUF_UE4_PREFIX}

# android-19 means Android 4.4
export SYSROOT=${NDKROOT}/platforms/android-24/arch-arm64
export TOOLCHAIN=${NDKROOT}/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin

# build tools
export CC="${TOOLCHAIN}/aarch64-linux-android-gcc --sysroot=${SYSROOT}"
export CXX="${TOOLCHAIN}/aarch64-linux-android-g++ --sysroot=${SYSROOT}"
export AR=${TOOLCHAIN}/aarch64-linux-android-ar
export LD=${TOOLCHAIN}/aarch64-linux-android-ld
export RANLIB=${TOOLCHAIN}/aarch64-linux-android-ranlib
export STRIP=${TOOLCHAIN}/aarch64-linux-android-strip
export READELF=${TOOLCHAIN}/aarch64-linux-android-readelf
export CXXSTL=${NDKROOT}/sources/cxx-stl/gnu-libstdc++/4.9
export LIBS="-llog ${CXXSTL}/libs/arm64-v8a/libgnustl_static.a"

chmod +x autogen.sh configure

./autogen.sh

./configure --prefix=${PROTOBUF_UE4_PREFIX}/build         \
  --host=aarch64-linux-android                            \
  --with-sysroot=${SYSROOT}                               \
  --disable-shared                                        \
  --disable-debug                                         \
  --disable-dependency-tracking                           \
  --enable-cross-compile                                  \
  --with-protoc=protoc                                    \
  CFLAGS="-march=armv8-a"                                 \
  CXXFLAGS="${CFLAGS} -I${CXXSTL}/include -I${CXXSTL}/libs/arm64-v8a/include"

make -j$(nproc)
make install

rm -rf ${PROTOBUF_UE4_PREFIX}/android
mkdir -p ${PROTOBUF_UE4_PREFIX}/android/lib

mv ${PROTOBUF_UE4_PREFIX}/build/lib/libprotobuf.a ${PROTOBUF_UE4_PREFIX}/android/lib/libprotobuf.a

rm -rf ${PROTOBUF_UE4_PREFIX}/build

objdump -h ${PROTOBUF_UE4_PREFIX}/android/lib/libprotobuf.a | head -n 25