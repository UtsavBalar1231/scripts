#!/bin/bash
cd ..

git clone https://github.com/UtsavisGreat/AnyKernel3 -b master anykernel

if [[ "$@" =~ "clang"* ]]; then
	git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 --depth=1 gcc
	git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 --depth=1 gcc32
	git clone https://github.com/BenzoRom/benzoClang-10.0  --depth=1 clang
elif [[ "$@" =~ "dragon"* ]]; then
        git clone https://github.com/kdrag0n/proton-clang --depth=1 clang
elif [[ "$@" =~ "gcc9"* ]]; then
        git clone https://github.com/kdrag0n/aarch64-elf-gcc -b  9.x --depth=1 gcc
	git clone https://github.com/kdrag0n/arm-eabi-gcc -b 9.x --depth=1 gcc32
else
	git clone https://github.com/RaphielGang/aarch64-raph-linux-android -b elf --depth=1 gcc
        git clone https://github.com/kdrag0n/arm-eabi-gcc -b 9.x --depth=1 gcc32
fi
