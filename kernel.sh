#!/bin/bash

# We're building IMMENSITY.
cd ..

# Export compiler type
if [[ "$@" =~ "clang"* ]]; then
	export COMPILER="Clang 9.0.6"
elif [[ "$@" =~ "dragon"* ]]; then
        export COMPILER="DragonTC-10.0"
elif [[ "$@" =~ "gcc9"* ]]; then
        export COMPILER="Bare Metal GCC-9.2.0"
else
	export COMPILER="Bare Metal GCC 10.0"
fi

# Export correct version
if [[ "$@" =~ "beta"* ]]; then
	export TYPE=beta
	export VERSION="IMMENSITY-BETA-KERNEL-${DRONE_BUILD_NUMBER}-${RELEASE_CODENAME}"
	export INC="$(echo ${RC} | grep -o -E '[0-9]+')"
	INC="$((INC + 1))"
else
	export TYPE=stable
	export VERSION="IMMENSITY-KERNEL-${RELEASE_CODENAME}"
fi

export ZIPNAME="${VERSION}.zip"

# How much kebabs we need? Kanged from @raphielscape :)
if [[ -z "${KEBABS}" ]]; then
	COUNT="$(grep -c '^processor' /proc/cpuinfo)"
	export KEBABS="$((COUNT * 2))"
fi

# Post to CI channel
curl -s -X POST https://api.telegram.org/bot${BOT_API_KEY}/SendAnimation -d animation=https://thumbs.gfycat.com/TidyOccasionalIncatern-size_restricted.gif -d chat_id=${CI_CHANNEL_ID}
curl -s -X POST https://api.telegram.org/bot${BOT_API_KEY}/sendMessage -d text="Kernel: <code>iMMENSITY Kernel</code>
Type: <code>${TYPE}</code>
Device: <code>XiaoMi Redmi K20 Pro (raphael)</code>
Compiler: <code>${COMPILER}</code>
Branch: <code>$(git rev-parse --abbrev-ref HEAD)</code>
<i>Build started on Drone Cloud...</i>
Check the build status here: https://cloud.drone.io/UtsavisGreat/kernel_xiaomi_raphael/${DRONE_BUILD_NUMBER}" -d chat_id=${CI_CHANNEL_ID} -d parse_mode=HTML
curl -s -X POST https://api.telegram.org/bot${BOT_API_KEY}/sendMessage -d text="Build started for revision ${DRONE_BUILD_NUMBER}" -d chat_id=${CI_CHANNEL_ID} -d parse_mode=HTML

# Make is shit so I have to pass thru some toolchains
# Let's build, anyway
PATH="/drone/src/clang/bin:${PATH}"
START=$(date +"%s")
make O=out ARCH=arm64 raphael_defconfig
if [[ "$@" =~ "clang"* ]]; then
        make -j${KEBABS} O=out ARCH=arm64 CC=clang CLANG_TRIPLE="aarch64-linux-android-" CROSS_COMPILE="/drone/src/gcc/bin/aarch64-linux-android-" CROSS_COMPILE_ARM32="/drone/src/gcc32/bin/arm-linux-androideabi-"
elif [[ "$@" =~ "dragon"* ]]; then
	PATH="/drone/src/dragontc/bin:${PATH}"
	make -j${KEBABS} O=out ARCH=arm64 CROSS_COMPILE="/drone/src/dragontc/bin/aarch64-linux-gnu-" CROSS_COMPILE_ARM32="/drone/src/dragontc/bin/arm-linux-gnueabi-"
elif [[ "$@" =~ "gcc9"* ]]; then
        make -j${KEBABS} O=out ARCH=arm64 CROSS_COMPILE="/drone/src/gcc/bin/aarch64-elf-" CROSS_COMPILE_ARM32="/drone/src/gcc32/bin/arm-eabi-"
else
	make -j${KEBABS} O=out ARCH=arm64 CROSS_COMPILE="/drone/src/gcc/bin/aarch64-raphiel-elf-" CROSS_COMPILE_ARM32="/drone/src/gcc32/bin/arm-eabi-"
fi
END=$(date +"%s")
DIFF=$(( END - START))

cp $(pwd)/out/arch/arm64/boot/Image.gz $(pwd)/anykernel
cp $(pwd)/out/arch/arm64/boot/dts/qcom/sm8150-v2.dtb $(pwd)/anykernel/dtbs

# POST ZIP OR FAILURE
cd anykernel
zip -r9 ${ZIPNAME} *
CHECKER=$(ls -l ${ZIPNAME} | awk '{print $5}')

if (($((CHECKER / 1048576)) > 5)); then
	curl -s -X POST https://api.telegram.org/bot${BOT_API_KEY}/sendMessage -d text="Kernel compiled successfully in $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds for Raphael" -d chat_id=${CI_CHANNEL_ID} -d parse_mode=HTML
	curl -F chat_id="${CI_CHANNEL_ID}" -F document=@"$(pwd)/${ZIPNAME}" https://api.telegram.org/bot${BOT_API_KEY}/sendDocument
else
	curl -s -X POST https://api.telegram.org/bot${BOT_API_KEY}/sendMessage -d text="Error in build!!" -d chat_id=${CI_CHANNEL_ID}
	exit 1;
fi

rm -rf ${ZIPNAME} && rm -rf Image.gz

