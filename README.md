# ti-sdk-docker

[PROCESSOR-SDK-AM67A](https://www.ti.com/tool/PROCESSOR-SDK-AM67A) running on [TI Ubuntu](https://github.com/TexasInstruments/ti-docker-images)

## Running the image

```sh
docker run -it \
    -v /Volumes/LinuxCS/code:/home/tisdk/shared \
    ghcr.io/goat-hill/ti-sdk-docker:latest /bin/bash
```

## Building image

In same directory as `Dockerfile`:

```sh
docker build -t ghcr.io/goat-hill/ti-sdk-docker:latest .
```

Push to Github, using classic Github token:

```sh
docker login ghcr.io -u your-github-user
docker push ghcr.io/goat-hill/ti-sdk-docker:latest
```

## Building U-Boot

### r5

EVM configure:

```sh
make ARCH=arm O=/home/tisdk/uboot-build/r5 j722s_evm_r5_defconfig
```

BeagleY-AI configure:

```sh
make ARCH=arm O=/home/tisdk/uboot-build/r5 beagleyai_r5_defconfig
```

Compile:

```sh
make -j$(nproc) ARCH=arm O=/home/tisdk/uboot-build/r5 \
    CROSS_COMPILE="$CROSS_COMPILE_32" \
    BINMAN_INDIRS=${PREBUILT_IMAGES}
```

Copy output to shared volume:

```sh
cp /home/tisdk/uboot-build/r5/tiboot3-j722s-hs-fs-evm.bin /home/tisdk/shared/ti-uboot-build/tiboot3.bin
```

#### Other tasks

Clean:

```sh
make ARCH=arm O=/home/tisdk/uboot-build/r5 mrproper
```

Simplify defconfig:

```sh
make ARCH=arm O=/home/tisdk/uboot-build/r5 savedefconfig
cp /home/tisdk/uboot-build/r5/defconfig configs/beagleyai_r5_defconfig
```

### a53

EVM configure:

```sh
make ARCH=arm O=/home/tisdk/uboot-build/a53 j722s_evm_a53_defconfig
```

BeagleY-AI configure:

```
make ARCH=arm O=/home/tisdk/uboot-build/a53 beagleyai_a53_defconfig
```

Compile:

```sh
make -j$(nproc) ARCH=arm O=/home/tisdk/uboot-build/a53 \
    CROSS_COMPILE="$CROSS_COMPILE_64" \
    CC="$CC_64" \
    BL31=${PREBUILT_IMAGES}/bl31.bin \
    TEE=${PREBUILT_IMAGES}/bl32.bin \
    BINMAN_INDIRS=${PREBUILT_IMAGES}
```

Copy output to shared volume:

```sh
cp /home/tisdk/uboot-build/a53/tispl.bin /home/tisdk/shared/ti-uboot-build/
cp /home/tisdk/uboot-build/a53/u-boot.img /home/tisdk/shared/ti-uboot-build/
```

#### Other tasks

Clean:

```sh
make ARCH=arm O=/home/tisdk/uboot-build/a53 mrproper
```

Simplify defconfig:

```sh
make ARCH=arm O=/home/tisdk/uboot-build/a53 savedefconfig
cp /home/tisdk/uboot-build/a53/defconfig configs/beagleyai_a53_defconfig
```

## Building Linux kernel

### Device tree DTBs

```sh
make -j$(nproc) ARCH=arm64 CROSS_COMPILE="$CROSS_COMPILE_64" dtbs
```

## Installing U-Boot

Follow [SDK instructions here](https://software-dl.ti.com/jacinto7/esd/processor-sdk-linux-am67a/latest/exports/docs/linux/Foundational_Components/U-Boot/UG-General-Info.html#build-u-boot)

## Installing kernel

Instructions based on [SDK docs here](https://software-dl.ti.com/jacinto7/esd/processor-sdk-linux-am67a/latest/exports/docs/linux/Foundational_Components_Kernel_Users_Guide.html#installing-the-kernel)

```sh
sudo cp arch/arm64/boot/Image /media/brady/rootfs/boot/
sudo cp arch/arm64/boot/dts/ti/k3-am67a-beagleyai.dtb /media/brady/rootfs/boot/dtb/
sudo cp arch/arm64/boot/dts/ti/k3-am67a-beagley-ai-edgeai-apps.dtbo /media/brady/rootfs/boot/dtb/ti/
sudo cp arch/arm64/boot/dts/ti/k3-am67a-beagley-ai-csi0-imx219.dtbo /media/brady/rootfs/boot/dtb/ti/
sudo make ARCH=arm64 INSTALL_MOD_PATH=/media/brady/rootfs/ modules_install
```

Make sure `boot` partition `uEnv.txt` indicates the overlays:
```
name_overlays=ti/k3-am67a-beagley-ai-edgeai-apps.dtbo ti/k3-am67a-beagley-ai-csi0-imx219.dtbo
```

## Issues

- Need to add `libncurses-dev` apt package for menuconfig
- TI Ubuntu Docker build is [broken](https://github.com/TexasInstruments/ti-docker-images/pull/14#issuecomment-2970968176) (there was a gnutls package missing as a result)
