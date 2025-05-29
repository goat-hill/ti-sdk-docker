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

```sh
make ARCH=arm O=/home/tisdk/uboot-build/r5 j722s_evm_r5_defconfig
make ARCH=arm O=/home/tisdk/uboot-build/r5 \
    CROSS_COMPILE="$CROSS_COMPILE_32" \
    BINMAN_INDIRS=${PREBUILT_IMAGES}
```

### a53

```sh
make ARCH=arm O=/home/tisdk/uboot-build/a53 j722s_evm_a53_defconfig
make ARCH=arm O=/home/tisdk/uboot-build/a53 \
    CROSS_COMPILE="$CROSS_COMPILE_64" \
    CC="$CC_64" \
    BL31=${PREBUILT_IMAGES}/bl31.bin \
    TEE=${PREBUILT_IMAGES}/bl32.bin \
    BINMAN_INDIRS=${PREBUILT_IMAGES}
```