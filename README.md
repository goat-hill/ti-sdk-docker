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
