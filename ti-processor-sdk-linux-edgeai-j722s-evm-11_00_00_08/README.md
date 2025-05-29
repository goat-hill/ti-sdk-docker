# TI Edge AI SDK Docker image

With a case sensitive file system at `/Volumes/LinuxCS/code` mounted to be shared between macOS and the container.

```sh
docker build -t tisdk-edgeai:latest .
docker run -it --rm -v /Volumes/LinuxCS/code:/home/tisdk/shared tisdk-edgeai:latest bash
```
