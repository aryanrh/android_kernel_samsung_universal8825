#!/bin/sh
DIR=`readlink -f .`
PARENT_DIR=`readlink -f ..`

KERNEL_MAKE_ENV="LOCALVERSION=-fgnor"

export PLATFORM_VERSION=12
export ANDROID_MAJOR_VERSION=s
export PATH=$PARENT_DIR/clang-r416183b/bin/:$PATH
export PATH=$PARENT_DIR/build-tools/path/linux-x86:$PATH
export PATH=$PARENT_DIR/gas/linux-x86:$PATH
export TARGET_SOC=s5e8825
export LLVM=1 LLVM_IAS=1
export ARCH=arm64

clang(){
    if [ ! -d $PARENT_DIR/clang-r416183b ]; then
      pause 'clone Android Clang/LLVM Prebuilts'
      git clone https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-r416183b $PARENT_DIR/clang-r416183b
      . $DIR/build.sh
    fi
}

gas(){
  if [ ! -d $PARENT_DIR/gas/linux-x86 ]; then
    pause 'clone prebuilt binaries of GNU `as` (the assembler)'
    git clone https://android.googlesource.com/platform/prebuilts/gas/linux-x86 $PARENT_DIR/gas/linux-x86
    . $DIR/build.sh
  fi
}

build_tools(){
  if [ ! -d $PARENT_DIR/build-tools ]; then
    pause 'clone prebuilt binaries of build tools'
    mkdir $PARENT_DIR/build-tools
    wget https://android.googlesource.com/platform/prebuilts/build-tools/+archive/refs/heads/master.tar.gz -O $PARENT_DIR/master.tar.gz
    tar xf $PARENT_DIR/master.tar.gz -C $PARENT_DIR/build-tools
    rm -rf $DIR/master.tar*
    rm -rf $PARENT_DIR/master.tar*
    . $DIR/build.sh
  fi
}

pause() {
  read -p "Press enter" fackEnterKey
}

anykernel3() {
  if [ ! -d $PARENT_DIR/AnyKernel3 ]; then
    pause 'Press enter to clone anykernel3'
    git clone https://github.com/osm0sis/AnyKernel3 $PARENT_DIR/AnyKernel3
  fi
  if [ -e $DIR/arch/arm64/boot/Image ]; then
    cd $PARENT_DIR/AnyKernel3
    git reset --hard
    cp $DIR/arch/arm64/boot/Image zImage
    sed -i "s/ExampleKernel by osm0sis/a53x kernel by fgnor/g" anykernel.sh
    sed -i "s/=maguro/=a53x/g" anykernel.sh
    sed -i "s/=toroplus/=/g" anykernel.sh
    sed -i "s/=toro/=/g" anykernel.sh
    sed -i "s/=tuna/=/g" anykernel.sh
    sed -i "s/platform\/omap\/omap_hsmmc\.0\/by-name\/boot/bootdevice\/by-name\/boot/g" anykernel.sh
    sed -i "s/backup_file/#backup_file/g" anykernel.sh
    sed -i "s/replace_string/#replace_string/g" anykernel.sh
    sed -i "s/insert_line/#insert_line/g" anykernel.sh
    sed -i "s/append_file/#append_file/g" anykernel.sh
    sed -i "s/patch_fstab/#patch_fstab/g" anykernel.sh
    sed -i "s/dump_boot/split_boot/g" anykernel.sh
    sed -i "s/write_boot/flash_boot/g" anykernel.sh
    zip -r9 $PARENT_DIR/a53x_kernel_latest_`date '+%Y_%m_%d'`.zip * -x .git README.md *placeholder
    cd $DIR
    pause 'Press enter to continue'
    . $DIR/build.sh
  fi
}

compile() {
  single() {
    make $KERNEL_MAKE_ENV fgnor-a53x_defconfig
    make $KERNEL_MAKE_ENV
  }

  multi() {
    make -j$(nproc) $KERNEL_MAKE_ENV fgnor-a53x_defconfig
    make -j$(nproc) $KERNEL_MAKE_ENV
  }

  clear
  echo "1. Single Core"
  echo "2. Multi Core"
  echo "3. Exit"

  local CHOICE
  read -p "Enter choice " CHOICE
  case $CHOICE in
    1) single ;;
    2) multi ;;
    3) . $DIR/build.sh ;;
  esac

  if [ -e arch/arm64/boot/Image ]; then
    mkdir $(pwd)/out
    cp arch/arm64/boot/Image $(pwd)/out/Image
    echo "Kernel Built successfuly continuing to make flashable zip"
    pause "Press enter"
    anykernel3
  else
    echo "Building failed"
    pause 
    . $DIR/build.sh
  fi
}


clean() {
  make clean
  make mrproper
  pause 'Enter to continue'
  . $DIR/build.sh
}

clang
gas
build_tools

menu() {
  clear
  echo "Menu"
  echo "1. Build"
  echo "2. Clean"
  echo "3. Exit"
}

read_options() {
  local CHOICE
  read -p "Enter choice " CHOICE
  case $CHOICE in
    1) compile ;;
    2) clean ;;
    3) exit 0;; 
  esac
}

while true
do
  menu
  read_options
done

