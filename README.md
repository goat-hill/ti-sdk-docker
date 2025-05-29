# ti-sdk-docker

[PROCESSOR-SDK-AM67A](https://www.ti.com/tool/PROCESSOR-SDK-AM67A) running on [TI Ubuntu](https://github.com/TexasInstruments/ti-docker-images)

## Running the image

```sh
docker run -it \
    -v /Volumes/LinuxCS/code:/home/tisdk/shared \
    ghcr.io/goat-hill/ti-sdk-docker:latest /bin/bash
```
