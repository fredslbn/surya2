#!/usr/bin/env bash

 #
 # Script For Building Android Kernel
 #

##----------------------------------------------------------##
# Specify Kernel Directory
KERNEL_DIR="$(pwd)"

##----------------------------------------------------------##
# Device Name and Model
MODEL=Xiaomi
DEVICE=surya-ksu

# Kernel Version Code
#VERSION=

# Kernel Defconfig
DEFCONFIG=${DEVICE}_defconfig

# Select LTO variant ( Full LTO by default )
DISABLE_LTO=0
THIN_LTO=0

# Files
IMAGE=$(pwd)/out/arch/arm64/boot/Image
DTBO=$(pwd)/out/arch/arm64/boot/dtbo.img
DTB=$(pwd)/out/arch/arm64/boot/dts/qcom/sdmmagpie.dtb

# Verbose Build
VERBOSE=0

# Kernel Version
#KERVER=$(make kernelversion)

#COMMIT_HEAD=$(git log --oneline -1)

# Date and Time
DATE=$(TZ=Asia/Jakarta date +"%Y%m%d-%T")
TANGGAL=$(date +"%F%S")

# Specify Final Zip Name
ZIPNAME="SUPER.KERNEL-SURYA-CLO-$(TZ=Asia/Jakarta date +"%Y%m%d-%H%M").zip"
FINAL_ZIP=${ZIPNAME}-${DEVICE}-${TANGGAL}.zip
FINAL_ZIP_ALIAS=Karenulgarde-${TANGGAL}.zip

##----------------------------------------------------------##
# Specify compiler.

COMPILER=neutron

##----------------------------------------------------------##
# Specify Linker
LINKER=ld.lld

##----------------------------------------------------------##

##----------------------------------------------------------##
# Clone ToolChain
function cloneTC() {

	if [ $COMPILER = "atomx" ];
	then
	git clone --depth=1 https://gitlab.com/ElectroPerf/atom-x-clang.git clang
	PATH="${KERNEL_DIR}/clang/bin:$PATH"

    elif [ $COMPILER = "neutron" ];
    then
    mkdir Neutron
    curl -s https://api.github.com/repos/Neutron-Toolchains/clang-build-catalogue/releases/latest \
    | grep "browser_download_url.*tar.zst" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget --output-document=Neutron.tar.zst -qi -
    tar -xvf Neutron.tar.zst -C Neutron/
    
    export KERNEL_CLANG="clang"
    export KERNEL_CLANG_PATH="${KERNEL_DIR}/Neutron"
    export PATH="$KERNEL_CLANG_PATH/bin:$PATH"
    
    elif [ $COMPILER = "trb" ];
    then
    git clone --depth=1 https://gitlab.com/varunhardgamer/trb_clang.git clang
    PATH="${KERNEL_DIR}/clang/bin:$PATH"
    
    elif [ $COMPILER = "cosmic" ];
    then
    git clone --depth=1 https://gitlab.com/PixelOS-Devices/playgroundtc.git -b 17 cosmic
    PATH="${KERNEL_DIR}/cosmic/bin:$PATH"
    
    elif [ $COMPILER = "cosmic-clang" ];
    then
    git clone --depth=1 https://gitlab.com/GhostMaster69-dev/cosmic-clang.git -b master cosmic-clang
    PATH="${KERNEL_DIR}/cosmic-clang/bin:$PATH"
    
	elif [ $COMPILER = "azure" ];
	then
	git clone --depth=1 https://gitlab.com/Panchajanya1999/azure-clang clang
	PATH="${KERNEL_DIR}/clang/bin:$PATH"
	
	elif [ $COMPILER = "nexus14" ];
	then
	git clone --depth=1 https://gitlab.com/Project-Nexus/nexus-clang.git -b nexus-14 clang
	PATH="${KERNEL_DIR}/clang/bin:$PATH"

	elif [ $COMPILER = "proton" ];
	then
	git clone --depth=1 https://github.com/kdrag0n/proton-clang.git clang
	PATH="${KERNEL_DIR}/clang/bin:$PATH"
	
	elif [ $COMPILER = "clang14" ];
	then
	#git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/ -b android10-gsi --depth 1 --no-tags --single-branch clang_all
    wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r450784e.tar.gz && mkdir clang && tar -xzvf clang-r450784e.tar.gz -C clang/
    #mv clang_all/clang-r353983c clang
    #rm -rf clang_all
    export KERNEL_CLANG_PATH="${KERNEL_DIR}/clang"
    export KERNEL_CLANG="clang"
    export PATH="$KERNEL_CLANG_PATH/bin:$PATH"
    CLANG_VERSION=$(clang --version | grep version | sed "s|clang version ||")
	
    wget https://releases.linaro.org/components/toolchain/binaries/latest-5/aarch64-linux-gnu/gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz && tar -xf gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz
    mv gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu gcc64
    export KERNEL_CCOMPILE64_PATH="${KERNEL_DIR}/gcc64"
    export KERNEL_CCOMPILE64="aarch64-linux-gnu-"
    export PATH="$KERNEL_CCOMPILE64_PATH/bin:$PATH"
    GCC_VERSION=$(aarch64-linux-gnu-gcc --version | grep "(GCC)" | sed 's|.*) ||')
   
    wget https://releases.linaro.org/components/toolchain/binaries/latest-5/arm-linux-gnueabihf/gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz && tar -xf gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz
    mv gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf gcc32
    export KERNEL_CCOMPILE32_PATH="${KERNEL_DIR}/gcc32"
    export KERNEL_CCOMPILE32="arm-linux-gnueabihf-"
    export PATH="$KERNEL_CCOMPILE32_PATH/bin:$PATH"
    
    elif [ $COMPILER = "clang14-7" ];
	then
	#git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/ -b android10-gsi --depth 1 --no-tags --single-branch clang_all
    wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r450784e.tar.gz && mkdir clang && tar -xzvf clang-r450784e.tar.gz -C clang/
    #mv clang_all/clang-r353983c clang
    #rm -rf clang_all
    export KERNEL_CLANG_PATH="${KERNEL_DIR}/clang"
    export KERNEL_CLANG="clang"
    export PATH="$KERNEL_CLANG_PATH/bin:$PATH"
    CLANG_VERSION=$(clang --version | grep version | sed "s|clang version ||")
	
    wget https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz && tar -xf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
    mv gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu gcc64
    export KERNEL_CCOMPILE64_PATH="${KERNEL_DIR}/gcc64"
    export KERNEL_CCOMPILE64="aarch64-linux-gnu-"
    export PATH="$KERNEL_CCOMPILE64_PATH/bin:$PATH"
    GCC_VERSION=$(aarch64-linux-gnu-gcc --version | grep "(GCC)" | sed 's|.*) ||')
   
    wget https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz && tar -xf gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz
    mv gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf gcc32
    export KERNEL_CCOMPILE32_PATH="${KERNEL_DIR}/gcc32"
    export KERNEL_CCOMPILE32="arm-linux-gnueabihf-"
    export PATH="$KERNEL_CCOMPILE32_PATH/bin:$PATH"
  
    elif [ $COMPILER = "clang15" ];
	then
	#git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/ -b android10-gsi --depth 1 --no-tags --single-branch clang_all
    wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/914f9e5ae603f1a290c92160e3958c251184d3f0/clang-r458507.tar.gz && mkdir clang && tar -xzvf clang-r458507.tar.gz -C clang/
    #mv clang_all/clang-r353983c clang
    #rm -rf clang_all
    export KERNEL_CLANG_PATH="${KERNEL_DIR}/clang"
    export KERNEL_CLANG="clang"
    export PATH="$KERNEL_CLANG_PATH/bin:$PATH"
    CLANG_VERSION=$(clang --version | grep version | sed "s|clang version ||")
	
    wget https://releases.linaro.org/components/toolchain/binaries/latest-5/aarch64-linux-gnu/gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz && tar -xf gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz
    mv gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu gcc64
    export KERNEL_CCOMPILE64_PATH="${KERNEL_DIR}/gcc64"
    export KERNEL_CCOMPILE64="aarch64-linux-gnu-"
    export PATH="$KERNEL_CCOMPILE64_PATH/bin:$PATH"
    GCC_VERSION=$(aarch64-linux-gnu-gcc --version | grep "(GCC)" | sed 's|.*) ||')
   
    wget https://releases.linaro.org/components/toolchain/binaries/latest-5/arm-linux-gnueabihf/gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz && tar -xf gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz
    mv gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf gcc32
    export KERNEL_CCOMPILE32_PATH="${KERNEL_DIR}/gcc32"
    export KERNEL_CCOMPILE32="arm-linux-gnueabihf-"
    export PATH="$KERNEL_CCOMPILE32_PATH/bin:$PATH"
    
    elif [ $COMPILER = "clang15-7" ];
	then
	#git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/ -b android10-gsi --depth 1 --no-tags --single-branch clang_all
    wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/914f9e5ae603f1a290c92160e3958c251184d3f0/clang-r458507.tar.gz && mkdir clang && tar -xzvf clang-r458507.tar.gz -C clang/
    #mv clang_all/clang-r353983c clang
    #rm -rf clang_all
    export KERNEL_CLANG_PATH="${KERNEL_DIR}/clang"
    export KERNEL_CLANG="clang"
    export PATH="$KERNEL_CLANG_PATH/bin:$PATH"
    CLANG_VERSION=$(clang --version | grep version | sed "s|clang version ||")
	
    wget https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz && tar -xf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
    mv gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu gcc64
    export KERNEL_CCOMPILE64_PATH="${KERNEL_DIR}/gcc64"
    export KERNEL_CCOMPILE64="aarch64-linux-gnu-"
    export PATH="$KERNEL_CCOMPILE64_PATH/bin:$PATH"
    GCC_VERSION=$(aarch64-linux-gnu-gcc --version | grep "(GCC)" | sed 's|.*) ||')
   
    wget https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz && tar -xf gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz
    mv gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf gcc32
    export KERNEL_CCOMPILE32_PATH="${KERNEL_DIR}/gcc32"
    export KERNEL_CCOMPILE32="arm-linux-gnueabihf-"
    export PATH="$KERNEL_CCOMPILE32_PATH/bin:$PATH"
    
    
    elif [ $COMPILER = "clang17" ];
	then
	#git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/ -b android10-gsi --depth 1 --no-tags --single-branch clang_all	
    wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r498229b.tar.gz && mkdir clang && tar -xzvf clang-r498229b.tar.gz -C clang/
    #mv clang_all/clang-r353983c clang
    #rm -rf clang_all
    export KERNEL_CLANG_PATH="${KERNEL_DIR}/clang"
    export KERNEL_CLANG="clang"
    export PATH="$KERNEL_CLANG_PATH/bin:$PATH"
    CLANG_VERSION=$(clang --version | grep version | sed "s|clang version ||")
	
    wget https://releases.linaro.org/components/toolchain/binaries/latest-5/aarch64-linux-gnu/gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz && tar -xf gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz
    mv gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu gcc64
    export KERNEL_CCOMPILE64_PATH="${KERNEL_DIR}/gcc64"
    export KERNEL_CCOMPILE64="aarch64-linux-gnu-"
    export PATH="$KERNEL_CCOMPILE64_PATH/bin:$PATH"
    GCC_VERSION=$(aarch64-linux-gnu-gcc --version | grep "(GCC)" | sed 's|.*) ||')
   
    wget https://releases.linaro.org/components/toolchain/binaries/latest-5/arm-linux-gnueabihf/gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz && tar -xf gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz
    mv gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf gcc32
    export KERNEL_CCOMPILE32_PATH="${KERNEL_DIR}/gcc32"
    export KERNEL_CCOMPILE32="arm-linux-gnueabihf-"
    export PATH="$KERNEL_CCOMPILE32_PATH/bin:$PATH"
    
    
    elif [ $COMPILER = "clang17-7" ];
	then
	#git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/ -b android10-gsi --depth 1 --no-tags --single-branch clang_all	
    wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r498229b.tar.gz && mkdir clang && tar -xzvf clang-r498229b.tar.gz -C clang/
    #mv clang_all/clang-r353983c clang
    #rm -rf clang_all
    export KERNEL_CLANG_PATH="${KERNEL_DIR}/clang"
    export KERNEL_CLANG="clang"
    export PATH="$KERNEL_CLANG_PATH/bin:$PATH"
    CLANG_VERSION=$(clang --version | grep version | sed "s|clang version ||")
	
    wget https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz && tar -xf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
    mv gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu gcc64
    export KERNEL_CCOMPILE64_PATH="${KERNEL_DIR}/gcc64"
    export KERNEL_CCOMPILE64="aarch64-linux-gnu-"
    export PATH="$KERNEL_CCOMPILE64_PATH/bin:$PATH"
    GCC_VERSION=$(aarch64-linux-gnu-gcc --version | grep "(GCC)" | sed 's|.*) ||')
   
    wget https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz && tar -xf gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz
    mv gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf gcc32
    export KERNEL_CCOMPILE32_PATH="${KERNEL_DIR}/gcc32"
    export KERNEL_CCOMPILE32="arm-linux-gnueabihf-"
    export PATH="$KERNEL_CCOMPILE32_PATH/bin:$PATH"
   
	elif [ $COMPILER = "eva" ];
	then
	git clone --depth=1 https://github.com/mvaisakh/gcc-arm64.git -b gcc-new gcc64
	git clone --depth=1 https://github.com/mvaisakh/gcc-arm.git -b gcc-new gcc32
	PATH=$KERNEL_DIR/gcc64/bin/:$KERNEL_DIR/gcc32/bin/:/usr/bin:$PATH

	elif [ $COMPILER = "aosp" ];
	then
        mkdir aosp-clang
        cd aosp-clang || exit
	wget -q https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android10-gsi/clang-r353983c.tar.gz
        tar -xf clang*
        cd .. || exit
	git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git --depth=1 gcc
	git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9.git  --depth=1 gcc32
	PATH="${KERNEL_DIR}/aosp-clang/bin:${KERNEL_DIR}/gcc/bin:${KERNEL_DIR}/gcc32/bin:${PATH}"
	fi
	
    # Clone AnyKernel
    #git clone --depth=1 https://github.com/missgoin/AnyKernel3.git

	}


##------------------------------------------------------##
# Export Variables
function exports() {
	
        # Export KBUILD_COMPILER_STRING
        
#        if [ -d ${KERNEL_DIR}/clang ];
#           then
#               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
#               export LD_LIBRARY_PATH="${KERNEL_DIR}/clang/lib:$LD_LIBRARY_PATH"
        
#        elif [ -d ${KERNEL_DIR}/gcc64 ];
#           then
#               export KBUILD_COMPILER_STRING=$("$KERNEL_DIR/gcc64"/bin/aarch64-elf-gcc --version | head -n 1)       
        
        if [ -d ${KERNEL_DIR}/cosmic ];
           then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/cosmic/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')        
        
        elif [ -d ${KERNEL_DIR}/cosmic-clang ];
           then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/cosmic-clang/bin/clang --version | head -n 1 | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')       
        
        elif [ -d ${KERNEL_DIR}/Neutron ];
           then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/Neutron/bin/clang --version | head -n 1 | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')
               export LD_LIBRARY_PATH="${KERNEL_DIR}/Neutron/lib:$LD_LIBRARY_PATH"

        elif [ -d ${KERNEL_DIR}/aosp-clang ];
            then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/aosp-clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
        fi
        
        # Export ARCH and SUBARCH
        export ARCH=arm64
        export SUBARCH=arm64
        
        # Export Local Version
        #export LOCALVERSION="-${VERSION}"
        
        # KBUILD HOST and USER
        export KBUILD_BUILD_HOST=Pancali
        export KBUILD_BUILD_USER="unknown"
        
	    export PROCS=$(nproc --all)
	    export DISTRO=$(source /etc/os-release && echo "${NAME}")
	    
	    # Server caching for speed up compile
	    #export LC_ALL=C && export USE_CCACHE=1
	    #ccache -M 100G
	
	}
        
##----------------------------------------------------------------##
# Telegram Bot Integration
##----------------------------------------------------------------##

# Export Configs



##----------------------------------------------------------##
# Compilation
function compile() {
START=$(date +"%s")
		
	# Compile
	make O=out ARCH=arm64 ${DEFCONFIG}
	
	if [ -d ${KERNEL_DIR}/clang ];
	   then
	       make -kj$(nproc --all) O=out \
	       ARCH=arm64 \
	       CC=$KERNEL_CLANG \
           CROSS_COMPILE=$KERNEL_CCOMPILE64 \
           CROSS_COMPILE_ARM32=$KERNEL_CCOMPILE32 \
           LD=${LINKER} \
           LLVM=1 \
           LLVM_IAS=1 \
           #AR=llvm-ar \
	       #NM=llvm-nm \
	       #OBJCOPY=llvm-objcopy \
	       #OBJDUMP=llvm-objdump \
	       #STRIP=llvm-strip \
	       #OBJSIZE=llvm-size \
	       V=$VERBOSE 2>&1 | tee error.log
	       
	elif [ -d ${KERNEL_DIR}/cosmic ];
	   then
	       make -j$(nproc --all) O=out \
	       ARCH=arm64 \
	       CC=clang \
           CROSS_COMPILE=aarch64-linux-gnu- \
           CROSS_COMPILE_ARM32=arm-linux-gnueabi \
           LLVM=1 \
           LLVM_IAS=1 \
           #AR=llvm-ar \
           #NM=llvm-nm \
           #LD=${LINKER} \
           #OBJCOPY=llvm-objcopy \
           #OBJDUMP=llvm-objdump \
           #STRIP=llvm-strip \
	       V=$VERBOSE 2>&1 | tee error.log
	       
	elif [ -d ${KERNEL_DIR}/cosmic-clang ];
	   then
	       make -kj$(nproc --all) O=out \
	       ARCH=arm64 \
	       CC=clang \
	       CROSS_COMPILE=aarch64-linux-gnu- \
	       CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
	       #LD=${LINKER} \
	       #LLVM=1 \
	       #LLVM_IAS=1 \
	       AR=llvm-ar \
	       NM=llvm-nm \
	       OBJCOPY=llvm-objcopy \
	       OBJDUMP=llvm-objdump \
	       STRIP=llvm-strip \
	       #READELF=llvm-readelf \
	       #OBJSIZE=llvm-size \
	       V=$VERBOSE 2>&1 | tee error.log
	       
	elif [ -d ${KERNEL_DIR}/Neutron ];
	   then
	       make -kj$(nproc --all) O=out \
	       ARCH=arm64 \
	       CC=$KERNEL_CLANG \
	       CROSS_COMPILE=aarch64-linux-gnu- \
	       CLANG_TRIPLE=aarch64-linux-gnu- \
	       LD=${LINKER} \
	       LLVM=1 \
	       LLVM_IAS=1 \
	       AS=llvm-as \
	       AR=llvm-ar \
	       NM=llvm-nm \
	       OBJCOPY=llvm-objcopy \
	       OBJDUMP=llvm-objdump \
	       STRIP=llvm-strip \
	       #READELF=llvm-readelf \
	       #OBJSIZE=llvm-size \
	       V=$VERBOSE 2>&1 | tee error.log
	
	elif [ -d ${KERNEL_DIR}/gcc64 ];
	   then
	       make -kj$(nproc --all) O=out \
	       ARCH=arm64 \
	       CROSS_COMPILE_ARM32=arm-eabi- \
	       CROSS_COMPILE=aarch64-elf- \
	       LD=aarch64-elf-${LINKER} \
	       AR=llvm-ar \
	       NM=llvm-nm \
	       OBJCOPY=llvm-objcopy \
	       OBJDUMP=llvm-objdump \
	       STRIP=llvm-strip \
	       OBJSIZE=llvm-size \
	       V=$VERBOSE 2>&1 | tee error.log
	       
    elif [ -d ${KERNEL_DIR}/aosp-clang ];
       then
           make -kj$(nproc --all) O=out \
	       ARCH=arm64 \
	       CC=clang \
           #HOSTCC=clang \
	       #HOSTCXX=clang++ \
	       CLANG_TRIPLE=aarch64-linux-gnu- \
	       CROSS_COMPILE=aarch64-linux-android- \
	       CROSS_COMPILE_ARM32=arm-linux-androideabi- \
	       #LD=${LINKER} \
	       #AR=llvm-ar \
	       #NM=llvm-nm \
	       #OBJCOPY=llvm-objcopy \
	       #OBJDUMP=llvm-objdump \
           #STRIP=llvm-strip \
	       #READELF=llvm-readelf \
	       #OBJSIZE=llvm-size \
	       V=$VERBOSE 2>&1 | tee error.log
	fi
}

##----------------------------------------------------------------##
function zipping() {
	# Copy Files To AnyKernel3 Zip
	cp $IMAGE AnyKernel3
	cp $DTBO AnyKernel3
	cp $DTB AnyKernel3/dtb
	
	# Zipping and Push Kernel
	cd AnyKernel3 || exit 1
	
	   # zip -r9 UPDATE-AnyKernel2.zip * -x README.md LICENSE UPDATE-AnyKernel2.zip zipsigner.jar
	   # cp UPDATE-AnyKernel2.zip package.zip 
	   # curl -sLo zipsigner-3.0.jar https://github.com/Magisk-Modules-Repo/zipsigner/raw/master/bin/zipsigner-3.0-dexed.jar
	   # java -jar zipsigner-3.0.jar UPDATE-AnyKernel2.zip $ZIPNAME	    
	    
        zip -r9 ${ZIPNAME} *
        MD5CHECK=$(md5sum "$ZIPNAME" | cut -d' ' -f1)
        echo "Zip: $ZIPNAME"
        #curl -T $ZIPNAME temp.sh; echo
        #curl -T $ZIPNAME https://oshi.at; echo
        curl --upload-file $ZIPNAME https://free.keep.sh
    cd ..
}

    
##----------------------------------------------------------##

cloneTC
exports
compile
zipping

##----------------*****-----------------------------##