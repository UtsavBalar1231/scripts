#!/bin/bash
cd ..

git config --global user.name UtsavBalar1231
git config --global user.email utsavbalar1231@gmail.com

# Anykernl Flasher
git clone https://github.com/UtsavBalar1231/AnyKernel3 -b master anykernel

# BenzoClang-12.0
if [[ "$@" =~ "clang"* ]]; then
	git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 --depth=1 gcc
	git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 --depth=1 gcc32
	git clone https://github.com/BenzoRom/benzoClang-12.0  --depth=1 clang
# ProtonClang-12.0
elif [[ "$@" =~ "proton"* ]]; then
	git clone https://github.com/kdrag0n/proton-clang -b master --depth=1 clang
# BareMetal GCC-10.2.0
elif [[ "$@" =~ "gcc"* ]]; then
	git clone https://github.com/arter97/aarch64-gcc -b master --depth=1 gcc
	git clone https://github.com/arter97/arm32-gcc -b master --depth=1 gcc32
else
        git clone https://github.com/kdrag0n/proton-clang -b master --depth=1 clang
fi
