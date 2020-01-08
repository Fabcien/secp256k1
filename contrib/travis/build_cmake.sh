#!/usr/bin/env bash

set -ev

if [ "x$HOST" = "xi686-linux-gnu" ]; then
  export TOOLCHAIN_FILE="-DCMAKE_TOOLCHAIN_FILE=../cmake/platforms/Linux32.cmake"
fi

if [ "x$BIGNUM" = "xno" ]; then
  export USE_GMP="-DGMP_LIBRARY=OFF"
fi

export $EXTRAFLAGS

mkdir -p buildcmake
pushd buildcmake

cmake -GNinja .. \
  -DSECP256K1_ECMULT_STATIC_PRECOMPUTATION=$STATICPRECOMPUTATION \
  -DSECP256K1_ENABLE_MODULE_ECDH=$ECDH \
  -DSECP256K1_ENABLE_MODULE_RECOVERY=$RECOVERY \
  -DSECP256K1_ENABLE_MODULE_SCHNORR=$SCHNORR \
  -DSECP256K1_ENABLE_JNI=$JNI \
  -DUSE_ASM_X86_64=$ASM \
  $USE_GMP \
  $TOOLCHAIN_FILE \

ninja check-secp256k1

popd
