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

if [[ -z "${ANDROID_NDK}" ]]; then
  echo "ANDROID_NDK is not set, exit."
  exit 1
else
  echo "ANDROID_NDK: ${ANDROID_NDK}"
fi

if [[ -z "${NDKROOT}" ]]; then
  echo "NDKROOT is not set, exit."
  exit 1
else
  echo "NDKROOT: ${NDKROOT}"
fi

if [[ -d "${NDKROOT}" ]]; then
  echo "ok: NDKROOT exist."
else
  echo "error: NDKROOT no exist."
  exit 1
fi

echo "MYCFLAGS: ${MYCFLAGS}"
echo "MYLDFLAGS: ${MYLDFLAGS}"

readonly PROTOBUF_URL=https://github.com/google/protobuf/releases/download/v${PROTOBUF_UE4_VERSION}/protobuf-cpp-${PROTOBUF_UE4_VERSION}.tar.gz
readonly PROTOBUF_DIR=protobuf-${PROTOBUF_UE4_VERSION}
readonly PROTOBUF_TAR=${PROTOBUF_DIR}.tar.gz

echo "Downloading: ${PROTOBUF_URL}"
wget -q -O ${PROTOBUF_TAR} ${PROTOBUF_URL}

function handle_r12 {
  # android-24 means Android 7.0
  export SYSROOT="${NDKROOT}/platforms/android-24/${MYARCHARM}"
  export TOOLCHAIN="${NDKROOT}/toolchains/${MYTOOL}-4.9/prebuilt/linux-x86_64/bin"

  # build tools
  export CC="${TOOLCHAIN}/${MYTOOL}-gcc --sysroot=${SYSROOT}"
  export CXX="${TOOLCHAIN}/${MYTOOL}-g++ --sysroot=${SYSROOT}"
  export AR="${TOOLCHAIN}/${MYTOOL}-ar"
  export LD="${TOOLCHAIN}/${MYTOOL}-ld"
  export RANLIB="${TOOLCHAIN}/${MYTOOL}-ranlib"
  export STRIP="${TOOLCHAIN}/${MYTOOL}-strip"
  export READELF="${TOOLCHAIN}/${MYTOOL}-readelf"
  export CXXSTL="${NDKROOT}/sources/cxx-stl/gnu-libstdc++/4.9"
  export LIBS="-llog ${CXXSTL}/libs/${MYLIB}/libgnustl_static.a"

  MYCXXFLAGS="-I${CXXSTL}/include -I${CXXSTL}/libs/${MYLIB}/include"
}

function handle_r21 {
  # android-24 means Android 7.0
  export TOOLCHAIN="${NDKROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin"

  # build tools
  export CC="${TOOLCHAIN}/aarch64-linux-android24-clang"
  export CXX="${TOOLCHAIN}/aarch64-linux-android24-clang++"
  export AR="${TOOLCHAIN}/aarch64-linux-android-ar"
  export LD="${TOOLCHAIN}/aarch64-linux-android-ld"
  export RANLIB="${TOOLCHAIN}/aarch64-linux-android-ranlib"
  export STRIP="${TOOLCHAIN}/aarch64-linux-android-strip"
  export READELF="${TOOLCHAIN}/aarch64-linux-android-readelf"
  export LIBS="-llog"
}

function build_android {
  MYARCHARM=$1
  MYTOOL=$2
  MYHOST=$2
  MYLIB=$3
  MYARCH=$3
  MYMARCH=$4

  tar zxf ${PROTOBUF_TAR}
  mkdir -p "${PROTOBUF_UE4_PREFIX}/${MYARCH}"

  # pattern like *r12b or *r12
  case "${ANDROID_NDK}" in
    *r12[!0-9]*|*r12)
      echo "Tool chain: handle_r12"
      handle_r12
      ;;
    *r21[!0-9]*|*r21)
      echo "Tool chain: handle_r21"
      handle_r21
      ;;
    *)
      echo "The NDK: ${NDKROOT} is not supported"
      exit 1
      ;;
  esac

  pushd ${PROTOBUF_DIR}
    ./autogen.sh

    ./configure --prefix="${PROTOBUF_UE4_PREFIX}/${MYARCH}"   \
      --host=${MYHOST}                                        \
      --with-sysroot="${SYSROOT}"                             \
      --disable-shared                                        \
      --disable-debug                                         \
      --disable-dependency-tracking                           \
      --enable-cross-compile                                  \
      --with-protoc=protoc                                    \
      CFLAGS="-march=${MYMARCH} ${MYCFLAGS}"                  \
      CXXFLAGS="${CFLAGS} ${MYCXXFLAGS}"                      \
      LDFLAGS="${MYLDFLAGS}"

    make -j$(nproc)
    make install

    objdump -h "${PROTOBUF_UE4_PREFIX}/${MYARCH}/lib/libprotobuf.a" | head -n 25
  popd
}

rm -rfv ${PROTOBUF_DIR}
build_android arch-arm64 aarch64-linux-android arm64-v8a armv8-a
