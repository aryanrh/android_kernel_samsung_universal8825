#!/bin/sh
DIR=`readlink -f .`
OUT_DIR=$DIR/out
PARENT_DIR=`readlink -f ${DIR}/..`
      
export CROSS_COMPILE=$PARENT_DIR/clang/bin/aarch64-linux-gnu-
export CC=$PARENT_DIR/clang=r416183b/bin/clang

export ANDROID_MAJOR_VERSION=t
cflags+="-I${PARENT_DIR}/build-tools/linux-x86/include "
ldflags+="-Wl,-rpath,${PARENT_DIR}/build-tools/linux-x86/lib64 "
ldflags+="-L ${PARENT_DIR}/build-tools/linux-x86/lib64 "
ldflags+="-fuse-ld=lld --rtlib=compiler-rt"
export HOSTCFLAGS="$cflags"
export HOSTLDFLAGS="$ldflags"
export PLATFORM_VERSION=12
export ANDROID_MAJOR_VERSION=s
export PATH=$PARENT_DIR/clang-r416183b/bin:$PATH
export PATH=$PARENT_DIR/build-tools/path/linux-x86:$PATH
export PATH=$PARENT_DIR/kernel-build-tools/linux-x86/bin:$PATH
export TARGET_SOC=s5e8825
export LLVM=1 LLVM_IAS=1
export ARCH=arm64
KERNEL_MAKE_ENV="LOCALVERSION=-aryanrh"


git clone https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-r416183b ~/clang-r416183b
git clone https://android.googlesource.com/platform/prebuilts/gas/linux-x86 ~/gas/linux-x86
mkdir $PARENT_DIR/build-tools
wget https://android.googlesource.com/platform/prebuilts/build-tools/+archive/refs/heads/master.tar.gz -O $PARENT_DIR/master.tar.gz
tar xf $PARENT_DIR/master.tar.gz -C $PARENT_DIR/build-tools
rm -rf $DIR/master.tar*
rm -rf $PARENT_DIR/master.tar*

export PATH=~/clang-r416183b/bin:$PATH
export PATH=~/build-tools/linux-x86:~/gas/linux-x86:$PATH
make PLATFORM_VERSION=12 ANDROID_MAJOR_VERSION=s LLVM=1 LLVM_IAS=1 ARCH=arm64 TARGET_SOC=s5e8825 CROSS_COMPILE=~/build-tools/linux-x86/clang-r416183b/bin/aarch64-linux-gnu- lineage_a53x_defconfig
make PLATFORM_VERSION=12 ANDROID_MAJOR_VERSION=s LLVM=1 LLVM_IAS=1 ARCH=arm64 TARGET_SOC=s5e8825 CROSS_COMPILE=~/clang-r416183b/bin/aarch64-linux-gnu- -j32
