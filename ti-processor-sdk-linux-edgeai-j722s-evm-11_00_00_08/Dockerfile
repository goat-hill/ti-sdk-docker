FROM ghcr.io/texasinstruments/ubuntu-distro:latest

ARG SDK_INSTALLER_URL="https://dr-download.ti.com/software-development/software-development-kit-sdk/MD-NQjfZVt1aJ/11.00.00.08/ti-processor-sdk-linux-edgeai-j722s-evm-11_00_00_08-Linux-x86-Install.bin"

WORKDIR /tmp

RUN SDK_INSTALLER_FILENAME="${SDK_INSTALLER_URL##*/}" && \
    wget "${SDK_INSTALLER_URL}" -O "${SDK_INSTALLER_FILENAME}" && \
    chmod +x "${SDK_INSTALLER_FILENAME}" && \
    ./"${SDK_INSTALLER_FILENAME}" && \
    rm "${SDK_INSTALLER_FILENAME}"

WORKDIR /home/tisdk
