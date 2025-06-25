# ti-sdk-docker

[PROCESSOR-SDK-AM67A](https://www.ti.com/tool/PROCESSOR-SDK-AM67A) running on [TI Ubuntu](https://github.com/TexasInstruments/ti-docker-images)

## Docker setup

### Running the image

```sh
docker run -it \
    -v /Volumes/LinuxCS/code:/home/tisdk/shared \
    ghcr.io/goat-hill/ti-sdk-docker:latest /bin/bash
```

### Building image

In same directory as `Dockerfile`:

```sh
docker build -t ghcr.io/goat-hill/ti-sdk-docker:latest .
```

Push to Github, using classic Github token:

```sh
docker login ghcr.io -u your-github-user
docker push ghcr.io/goat-hill/ti-sdk-docker:latest
```

## Running TI Edge AI SDK on BeagleY-AI

I have the TI Edge AI SDK [11.00.00.08](https://www.ti.com/tool/download/PROCESSOR-SDK-LINUX-AM67A/11.00.00.08) running on BeagleY-AI with a few modifications.

- [UBoot - branch `ti-u-boot-2025.01-bb`](https://github.com/goat-hill/ti-u-boot/tree/ti-u-boot-2025.01-bb)
- [Linux kernel - branch `ti-linux-6.12.y-bb`](https://github.com/goat-hill/linux/tree/ti-linux-6.12.y-bb)
- [TI vision_apps - branch `11.00.00.06-beagley`](https://github.com/goat-hill/ti-vision-apps/tree/11.00.00.06-beagley)

## U-Boot development workflow

### Building U-Boot

#### r5

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

##### Other tasks

Clean:

```sh
make ARCH=arm O=/home/tisdk/uboot-build/r5 mrproper
```

Simplify defconfig:

```sh
make ARCH=arm O=/home/tisdk/uboot-build/r5 savedefconfig
cp /home/tisdk/uboot-build/r5/defconfig configs/beagleyai_r5_defconfig
```

#### a53

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

##### Other tasks

Clean:

```sh
make ARCH=arm O=/home/tisdk/uboot-build/a53 mrproper
```

Simplify defconfig:

```sh
make ARCH=arm O=/home/tisdk/uboot-build/a53 savedefconfig
cp /home/tisdk/uboot-build/a53/defconfig configs/beagleyai_a53_defconfig
```

### Installing U-Boot

Based on [SDK instructions here](https://software-dl.ti.com/jacinto7/esd/processor-sdk-linux-am67a/latest/exports/docs/linux/Foundational_Components/U-Boot/UG-General-Info.html#build-u-boot)

```sh
sudo cp tiboot3.bin tispl.bin u-boot.img /media/brady/BOOT
```

## Linux kernel development workflow

### Building Linux kernel

#### Image and modules

Must be on same git commit for `Image` + `modules` + `module_install` with no local changes to avoid `-dirty` flagging.

Clean and configure make:

```sh
make -j$(nproc) ARCH=arm64 CROSS_COMPILE="$CROSS_COMPILE_64" distclean
make -j$(nproc) ARCH=arm64 CROSS_COMPILE="$CROSS_COMPILE_64" defconfig ti_arm64_prune.config
```

Compile linux kernel image and modules:

```sh
make -j$(nproc) ARCH=arm64 CROSS_COMPILE="$CROSS_COMPILE_64" Image
make -j$(nproc) ARCH=arm64 CROSS_COMPILE="$CROSS_COMPILE_64" modules
```

#### Device tree DTBs

```sh
make -j$(nproc) ARCH=arm64 CROSS_COMPILE="$CROSS_COMPILE_64" dtbs
```

### Installing kernel

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

## TI vision_apps development workflow

Install `PROCESSOR-SDK-RTOS-J722S` on TI Ubuntu docker image. Download SDK here:
https://www.ti.com/tool/PROCESSOR-SDK-J722S

I'm mostly following AM67A [firmware builder guide](https://software-dl.ti.com/jacinto7/esd/processor-sdk-rtos-j722s/11_00_00_06/exports/docs/psdk_rtos/docs/user_guide/firmware_builder.html)

To setup firmware builder run the following below. Exclude `--firmware-only` flag as we need Linux changes. Execute this in the root directory of PSDK RTOS.

```sh
./sdk_builder/scripts/setup_psdk_rtos.sh
```

### Swap to modified BeagleY-AI modified vision_apps

We need to use a modified verison of vision_apps to support memory map for BeagleY-AI with 4 GB DDR vs 8 GB EVM. Modifications are based on instructions [here](https://software-dl.ti.com/jacinto7/esd/processor-sdk-rtos-j722s/latest/exports/docs/psdk_rtos/docs/user_guide/developer_notes_memory_map.html)

```sh
mv vision_apps/ vision_apps_bak/
git clone https://github.com/goat-hill/ti-vision-apps.git vision_apps
cd vision_apps/
git checkout 11.00.00.06-beagley
```

### Compilation

Then:

```sh
cd sdk_builder/
TISDK_IMAGE=edgeai ./make_firmware.sh
```

### Gather build outputs

```sh
cp -r /tmp/tivision_apps_targetfs_stage /home/tisdk/shared/tivision_apps_targetfs_stage
```

### Installing vision_apps

```sh
export LINUX_FS_PATH=/media/brady/rootfs
export LINUX_FS_STAGE_PATH=/home/brady/host-shared/code/tivision_apps_targetfs_stage

# remove old remote files from filesystem
sudo rm -f $LINUX_FS_PATH/usr/lib/firmware/j722s-*-fw
sudo rm -f $LINUX_FS_PATH/usr/lib/firmware/j722s-*-fw-sec
sudo rm -rf $LINUX_FS_PATH/usr/lib/firmware/vision_apps_eaik
sudo rm -rf $LINUX_FS_PATH/opt/tidl_test/*
sudo rm -rf $LINUX_FS_PATH/opt/notebooks/*
sudo rm -rf $LINUX_FS_PATH/usr/include/processor_sdk/*

# create new directories
sudo mkdir -p $LINUX_FS_PATH/usr/include/processor_sdk

# copy full vision apps linux fs stage directory into linux fs
sudo cp -r $LINUX_FS_STAGE_PATH/* $LINUX_FS_PATH/.
```

## Edge AI development workflow

### Obtaining Edge AI image rootfs .tar.gz

Download same [TI SDK Edge AI](https://www.ti.com/tool/download/PROCESSOR-SDK-LINUX-AM67A/11.00.00.08) .wic.gz used for flashing SD card.
Now we want to get the rootfs of the .wic available in the same directory. A bit tricky becuase it's a .wic image and not .tar.gz like TI SDK adas edition.

Steps if in a docker image:
```sh
sudo losetup -P $(losetup -f) ~/host-shared/code/tisdk-edgeai-image-j722s-evm.wic 
losetup -a
sudo mount /dev/loop13p2 /mnt/rootfs-edgeai
sudo tar -czpf targetfs.tar.gz -C /mnt/rootfs-edgeai/ .
```

Hold on to this .tar.gz. Now cleanup the mess:

```sh
sudo umount /mnt/rootfs-edgeai 
sudo losetup -d /dev/loop13
```

### Creating build environment

On TI Ubuntu docker image with Edge AI SDK installed:

```sh
git clone https://github.com/TexasInstruments/edgeai-app-stack
git submodule init
git submodule update
```

Extract EdgeAI rootfs to `targetfs/` local directory.

```sh
tar -zxf targetfs.tar.gz -C targetfs
```

### Compilation
Note: Required modifications to Makefile (point to local compile toolchain, targetfs/, and new targetfs-install/ dir)

Now compile:
```sh
ARCH=arm64 make -j$(nproc)
```
I had to compile it a few times...

### Copy to SD card

```sh
sudo cp -r targetfs-install/* /media/brady/rootfs/
```

## Testing TI Edge AI SDK

Kill the default app started at launch

```sh
killall edgeai-gui-app
```

Pipe OpenVX logs to shell:
```sh
source /opt/vision_apps/vision_apps_init.sh
```

Run IMX219 demo:

```sh
cd /opt/edgeai-gst-apps/apps_cpp/
./bin/Release/app_edgeai ../configs/imx219_cam_example.yaml
```

## Issues

- Need to add `libncurses-dev` apt package for menuconfig
- TI Ubuntu Docker build is [broken](https://github.com/TexasInstruments/ti-docker-images/pull/14#issuecomment-2970968176) (there was a gnutls package missing as a result)
