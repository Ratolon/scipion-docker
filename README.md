# Scipion-docker

## Prerequisites (ubuntu packages)

* nvidia drivers
* docker with nVidia runtime
* X11 server running
* **xserver-xorg xdm xauth nvidia-container-toolkit nvidia-container-runtime nvidia-docker2**


## Installation of prerequisites

### nVidia runtime

**Installation**

https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(Native-GPU-Support)

**Configuration**

You should now have the **nvidia** runtime installed, which is required to run this project.

You can now replace the default docker runtime **runc** by **nvidia** runtime.  
Backup and edit file "**/etc/docker/daemon.json**".
```json
{
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "default-runtime": "nvidia"
}
```


https://github.com/NVIDIA/nvidia-docker/wiki/Advanced-topics#default-runtime

If you need **runc** as a default runtime for some purpose, do not change this runtime.
Note that you will now need to start the docker image with "**--runtime=nvidia**".

## Run a container

```
docker run --privileged -d -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0 -e USE_DISPLAY="5" --rm -p 5905:5905 scipion-image
```

Env var "**USE_DISPLAY**" will create new display (e.g. "**:5**").
Please note that you need new one for each instance. Therefore change the "**USE_DISPLAY**" value for each instance.

Only one-digit display number is now supported.

This is also related to the port. Change last digit of the ports "**-p 5905:5905**".

In addition, if you are using default docker runtime, you have to run the container with "**--runtime=nvidia**" parameter.

## Basic test

Your instance should be available on the link: "**https://your-adress:5905**".

The log-in password is now hard-coded in **Dockerfile**.

Open terminal a try "**nvidia-smi**" and "**glxgears -info**" commands.
Both should print output containing information about your nVidia graphics card.

## Troubleshooting

If the commands described above print output that do not contains information about nVidia card, try to backup and delete file "**/etc/X11/xorg.conf**".
