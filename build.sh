#!/bin/bash


export PATH=$(pwd)/pronton-toolchains/clang/host/linux-x86/clang-r416183b/bin:$PATH
export PATH=$(pwd)/pronton-toolchains/build/kernel/build-tools/path/linux-x86/:$PATH
export ARCH=arm64
export SUBARCH=arm64
export TARGET_SOC=s5e3830
export PLATFORM_VERSION=13
export ANDROID_MAJOR_VERSION=t
export CC=clang
export CROSS_COMPILE=aarch64-linux-gnu-
export CLANG_TRIPLE=aarch64-linux-gnu-
export LD=lld
export LLVM=1
export LLVM_IAS=1
export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y
MAKE_ARGS="ARCH=arm64 CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm \
OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip \
HOSTCC=clang HOSTCXX=clang++ HOSTAR=llvm-ar HOSTLD=ld.lld \
CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_COMPAT=arm-linux-gnueabi- \
CLANG_TRIPLE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1"

make $MAKE_ARGS exynos850-a12s_defconfig

make -j4
