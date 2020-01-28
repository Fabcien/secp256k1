#!/usr/bin/env bash

export LC_ALL=C

set -ex

if [ "x$HOST" = "xi686-linux-gnu" ]; then
  CMAKE_EXTRA_FLAGS="-DCMAKE_C_FLAGS=-m32"
fi

mkdir -p buildcmake
pushd buildcmake

# Use the cmake version installed via APT instead of the Travis custom one.
CMAKE_COMMAND=/usr/bin/cmake
${CMAKE_COMMAND} --version

${CMAKE_COMMAND} -GNinja .. \
  -DSECP256K1_ECMULT_STATIC_PRECOMPUTATION=$STATICPRECOMPUTATION \
  -DSECP256K1_ENABLE_MODULE_ECDH=$ECDH \
  -DSECP256K1_ENABLE_MODULE_RECOVERY=$RECOVERY \
  -DSECP256K1_ENABLE_MODULE_SCHNORR=$SCHNORR \
  -DSECP256K1_ENABLE_JNI=$JNI \
  -DSECP256K1_ENABLE_BIGNUM=$BIGNUM \
  -DUSE_ASM_X86_64=$ASM \
  $TOOLCHAIN_FILE \
  $CMAKE_EXTRA_FLAGS

ninja check-secp256k1

popd
