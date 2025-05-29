#!/bin/bash -e
export CROSS_COMPILE_64="${TI_SDK_PATH}/linux-devkit/sysroots/x86_64-arago-linux/usr/bin/aarch64-oe-linux/aarch64-oe-linux-"
export SYSROOT_64="${TI_SDK_PATH}/linux-devkit/sysroots/aarch64-oe-linux"
export CC_64="${CROSS_COMPILE_64}gcc --sysroot=${SYSROOT_64}"
export CROSS_COMPILE_32="${TI_SDK_PATH}/k3r5-devkit/sysroots/x86_64-arago-linux/usr/bin/arm-oe-eabi/arm-oe-eabi-"
export PREBUILT_IMAGES="${TI_SDK_PATH}/board-support/prebuilt-images"
