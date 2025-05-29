FROM ghcr.io/texasinstruments/ubuntu-distro:latest@sha256:7b47a9eaecfc2cc6a5b875c7f26632a40f98cf25dc63baba10eec42efacab812

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
