#!/usr/bin/env bash

set -ev

if [ -n "$HOST" ]; then
  export USE_HOST="--host=$HOST"
fi

if [ "x$HOST" = "xi686-linux-gnu" ]; then
  export CC="$CC -m32"
fi

./autogen.sh

mkdir buildautotools
pushd buildautotools

./configure \
  --enable-experimental=$EXPERIMENTAL \
  --enable-endomorphism=$ENDOMORPHISM \
  --with-field=$FIELD \
  --with-bignum=$BIGNUM \
  --with-scalar=$SCALAR \
  --enable-ecmult-static-precomputation=$STATICPRECOMPUTATION \
  --enable-module-ecdh=$ECDH \
  --enable-module-recovery=$RECOVERY \
  --enable-module-schnorr=$SCHNORR \
  --enable-jni=$JNI $EXTRAFLAGS $USE_HOST

make -j2 $BUILD

popd
