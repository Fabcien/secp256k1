#!/usr/bin/env bash

export LC_ALL=C

set -ex

if [ "x$HOST" = "xi686-linux-gnu" ]; then
  CMAKE_EXTRA_FLAGS="$CMAKE_EXTRA_FLAGS -DCMAKE_C_FLAGS=-m32"
fi
if [ "$TRAVIS_OS_NAME" = "osx" ] && [ "$TRAVIS_COMPILER" = "gcc" ]
then
  CMAKE_EXTRA_FLAGS="$CMAKE_EXTRA_FLAGS -DCMAKE_C_COMPILER=gcc-9"
fi

# "auto" is not a valid value for SECP256K1_ECMULT_GEN_PRECISION with cmake.
# In this case we use the default value instead by not setting the cache
# variable on the cmake command line.
if [ "x$ECMULTGENPRECISION" != "xauto" ]; then
  ECMULT_GEN_PRECISION_ARG="-DSECP256K1_ECMULT_GEN_PRECISION=$ECMULTGENPRECISION"
fi

mkdir -p buildcmake/install
pushd buildcmake

# Use the cmake version installed via the install_cmake.sh script on linux
if [ "$TRAVIS_OS_NAME" = "linux" ]
then
  CMAKE_COMMAND=/opt/cmake/bin/cmake
else
  CMAKE_COMMAND=cmake
fi
${CMAKE_COMMAND} --version

${CMAKE_COMMAND} -GNinja .. \
  -DCMAKE_INSTALL_PREFIX=install \
  -DSECP256K1_BUILD_OPENSSL_TESTS=$OPENSSL_TESTS \
  -DSECP256K1_ECMULT_STATIC_PRECOMPUTATION=$STATICPRECOMPUTATION \
  -DSECP256K1_ENABLE_MODULE_ECDH=$ECDH \
  -DSECP256K1_ENABLE_MODULE_MULTISET=$MULTISET \
  -DSECP256K1_ENABLE_MODULE_RECOVERY=$RECOVERY \
  -DSECP256K1_ENABLE_MODULE_SCHNORR=$SCHNORR \
  -DSECP256K1_ENABLE_JNI=$JNI \
  -DSECP256K1_ENABLE_ENDOMORPHISM=$ENDOMORPHISM \
  -DSECP256K1_ENABLE_BIGNUM=$BIGNUM \
  -DSECP256K1_USE_ASM=$ASM \
  -DSECP256K1_TEST_OVERRIDE_WIDE_MULTIPLY=$WIDEMUL \
  $ECMULT_GEN_PRECISION_ARG \
  $CMAKE_EXTRA_FLAGS

ninja $CMAKE_TARGET

if [ -n "$VALGRIND" ]; then
  # the `--error-exitcode` is required to make the test fail if valgrind found
  # errors, otherwise it'll return 0
  # (http://valgrind.org/docs/manual/manual-core.html)
  valgrind --error-exitcode=42 ./secp256k1-tests 16
  valgrind --error-exitcode=42 ./secp256k1-exhaustive_tests
fi

popd
