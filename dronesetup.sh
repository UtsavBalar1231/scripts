#!/bin/bash
cd ..

git clone https://github.com/UtsavisGreat/AnyKernel3 -b master anykernel

if [[ "$@" =~ "clang"* ]]; then
	git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 --depth=1 gcc
	git clone https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-5696680 --depth=1 clang
elif [[ "$@" =~ "gcc10"* ]]; then
	git clone https://github.com/RaphielGang/aarch64-raph-linux-android -b elf --depth=1 gcc
        git clone https://github.com/baalajimaestro/arm-maestro-linux-gnueabi/ -b 240719 --depth=1 gcc32
else
	git clone https://github.com/kdrag0n/aarch64-elf-gcc -b 9.x --depth=1 gcc
	git clone https://github.com/kdrag0n/arm-eabi-gcc -b 9.x --depth=1 gcc32
fi
