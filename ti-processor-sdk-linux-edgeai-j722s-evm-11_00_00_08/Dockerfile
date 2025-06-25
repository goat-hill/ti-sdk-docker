# <tiubuntu> - TI Ubuntu Docker Image
#   Based on https://github.com/TexasInstruments/ti-docker-images
#   FROM ghcr.io/texasinstruments/ubuntu-distro
#
#   This is the supported docker image for working with PROCESSOR-SDK-AM67A
#
#   We duplicate implementation here because ghcr.io image is stale
#

FROM amd64/ubuntu:22.04

# Installing packages needed for Yocto & SDK Makefile builds
RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && \
         apt-get install -y --no-install-recommends file autoconf automake iproute2 usbutils dialog dfu-util \
         bison flex libssl-dev bc u-boot-tools swig wget device-tree-compiler python3 python3-pip python3-dev dosfstools fdisk sudo && \
         pip3 install jsonschema pyelftools PyYAML Mako yamllint && \
         apt-get install -y gawk git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect \
         xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev xterm pylint python3-subunit mesa-common-dev \
         zstd liblz4-tool file locales doxygen dos2unix bison flex libssl-dev u-boot-tools mono-devel mono-complete curl python3-distutils repo \
         pseudo python3-sphinx g++-multilib libc6-dev-i386 jq git-lfs pigz liblz4-tool lz4 net-tools zip corkscrew rsync \
         iputils-ping locales libacl1 apt-utils nano libgnutls28-dev && locale-gen en_US en_US.UTF-8 && rm -rf /var/lib/apt/lists/*

# Set locale's and reconfigure to use bash as the default shell for /bin/sh.
RUN export DEBIAN_FRONTEND=noninteractive; echo "dash dash/sh boolean false" | debconf-set-selections && \
         dpkg-reconfigure dash && addgroup --gid 786 tisdk && \
         # Add user tisdk with uid & gid as 786.
         adduser --disabled-password --uid 786 --gid 786 --gecos "" --home /home/tisdk --shell /bin/bash tisdk && \
         # Add tisdk to sudoers & make it passwordless
         adduser tisdk sudo && usermod -aG sudo tisdk && echo "tisdk ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
         chown -R tisdk /home/tisdk && \
         export LC_ALL="en_US.UTF-8" && export LC_CTYPE="en_US.UTF-8" && export LC_NUMERIC="en_US.UTF-8"

# Set default user as tisdk
USER tisdk

#
# </tiubuntu> - Ubuntu Docker Image
#

ARG SDK_INSTALLER_URL="https://dr-download.ti.com/software-development/software-development-kit-sdk/MD-NQjfZVt1aJ/11.00.00.08/ti-processor-sdk-linux-edgeai-j722s-evm-11_00_00_08-Linux-x86-Install.bin"

WORKDIR /tmp

RUN SDK_INSTALLER_FILENAME="${SDK_INSTALLER_URL##*/}" && \
    wget "${SDK_INSTALLER_URL}" -O "${SDK_INSTALLER_FILENAME}" && \
    chmod +x "${SDK_INSTALLER_FILENAME}" && \
    ./"${SDK_INSTALLER_FILENAME}" && \
    rm "${SDK_INSTALLER_FILENAME}"

ENV TI_SDK_PATH="/home/tisdk/ti-processor-sdk-linux-edgeai-j722s-evm-11_00_00_08"
COPY --chmod=755 uboot-env.sh /home/tisdk/

WORKDIR /home/tisdk
