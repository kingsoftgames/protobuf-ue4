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

readonly PROTOBUF_URL=https://github.com/google/protobuf/releases/download/v${PROTOBUF_UE4_VERSION}/protobuf-cpp-${PROTOBUF_UE4_VERSION}.tar.gz
readonly PROTOBUF_DIR=protobuf-${PROTOBUF_UE4_VERSION}
readonly PROTOBUF_TAR=${PROTOBUF_DIR}.tar.gz

rm -rf ${PROTOBUF_DIR}

wget -q -O ${PROTOBUF_TAR} ${PROTOBUF_URL}

tar zxf ${PROTOBUF_TAR}
cd ${PROTOBUF_DIR}

rm -rf ${PROTOBUF_UE4_PREFIX}
mkdir -p ${PROTOBUF_UE4_PREFIX}

# android-19 means Android 4.4
export SYSROOT=${NDKROOT}/platforms/android-19/arch-arm
export TOOLCHAIN=${NDKROOT}/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin

# build tools
export CC="${TOOLCHAIN}/arm-linux-androideabi-gcc --sysroot=${SYSROOT}"
export CXX="${TOOLCHAIN}/arm-linux-androideabi-g++ --sysroot=${SYSROOT}"
export AR=${TOOLCHAIN}/arm-linux-androideabi-ar
export LD=${TOOLCHAIN}/arm-linux-androideabi-ld
export RANLIB=${TOOLCHAIN}/arm-linux-androideabi-ranlib
export STRIP=${TOOLCHAIN}/arm-linux-androideabi-strip
export READELF=${TOOLCHAIN}/arm-linux-androideabi-readelf
export CXXSTL=${NDKROOT}/sources/cxx-stl/gnu-libstdc++/4.9
export LIBS="-llog ${CXXSTL}/libs/armeabi-v7a/libgnustl_static.a"

./autogen.sh

./configure --prefix=${PROTOBUF_UE4_PREFIX}/build         \
  --host=arm-linux-androideabi                            \
  --with-sysroot=${SYSROOT}                               \
  --disable-shared                                        \
  --disable-debug                                         \
  --disable-dependency-tracking                           \
  --enable-cross-compile                                  \
  --with-protoc=protoc                                    \
  CFLAGS="-march=armv7-a"                                 \
  CXXFLAGS="${CFLAGS} -I${CXXSTL}/include -I${CXXSTL}/libs/armeabi-v7a/include"

make -j$(nproc)
make install

rm -rf ${PROTOBUF_UE4_PREFIX}/android
mkdir -p ${PROTOBUF_UE4_PREFIX}/android/lib

mv ${PROTOBUF_UE4_PREFIX}/build/lib/libprotobuf.a ${PROTOBUF_UE4_PREFIX}/android/lib/libprotobuf.a

rm -rf ${PROTOBUF_UE4_PREFIX}/build

objdump -h ${PROTOBUF_UE4_PREFIX}/android/lib/libprotobuf.a | head -n 25