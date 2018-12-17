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

if [[ -z "${PROTOBUF_UE4_IOS_DEPLOYMENT_TARGET}" ]]; then
  echo "PROTOBUF_UE4_IOS_DEPLOYMENT_TARGET is not set, exit."
  exit 1
else
  echo "PROTOBUF_UE4_IOS_DEPLOYMENT_TARGET: ${PROTOBUF_UE4_IOS_DEPLOYMENT_TARGET}"
fi

readonly CORE_COUNT=$(sysctl -n machdep.cpu.core_count)
readonly PROTOBUF_URL=https://github.com/google/protobuf/releases/download/v${PROTOBUF_UE4_VERSION}/protobuf-cpp-${PROTOBUF_UE4_VERSION}.tar.gz
readonly PROTOBUF_DIR=protobuf-${PROTOBUF_UE4_VERSION}
readonly PROTOBUF_TAR=${PROTOBUF_DIR}.tar.gz

rm -rf ${PROTOBUF_UE4_PREFIX}
mkdir -p ${PROTOBUF_UE4_PREFIX}

rm -rf ${PROTOBUF_DIR}
wget -q -O ${PROTOBUF_TAR} ${PROTOBUF_URL}

tar zxf ${PROTOBUF_TAR}
cd ${PROTOBUF_DIR}/cmake

cmake -DCMAKE_INSTALL_PREFIX=${PROTOBUF_UE4_PREFIX}/ios . -G "Xcode"
xcodebuild -project protobuf.xcodeproj                               \
  -target libprotobuf                                                \
  -configuration Release                                             \
  -sdk iphoneos                                                      \
  -arch arm64                                                        \
  IPHONEOS_DEPLOYMENT_TARGET=${PROTOBUF_UE4_IOS_DEPLOYMENT_TARGET}   \
  GCC_SYMBOLS_PRIVATE_EXTERN=YES                                     \
  -jobs ${CORE_COUNT}                                                \
  build
xcodebuild -target install build

rm -rf ${PROTOBUF_UE4_PREFIX}/ios/include
rm -rf ${PROTOBUF_UE4_PREFIX}/ios/bin
rm -rf ${PROTOBUF_UE4_PREFIX}/ios/lib/*

mv Release-iphoneos/libprotobuf.a Release-iphoneos/libprotobuf-arm64.a
lipo -create Release-iphoneos/libprotobuf-arm64.a -output ${PROTOBUF_UE4_PREFIX}/ios/lib/libprotobuf.a
lipo -info ${PROTOBUF_UE4_PREFIX}/ios/lib/libprotobuf.a
