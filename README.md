# Scipion-docker

## Deploy Scipion using IM
### 1. Go to IM-web and log in with your account
### 2. Make sure you have access to the desired platform
You can open a list your **Crendentials** on the left menu.
If necessary, add a new one by clicking the "Add +" button and entering correct information.

### 3. Paste the RADL/TOSCA recipe into the new IM topology

Click the **Topologies** button in the left menu and the **Add +** button at the top.

Paste the RADL/TOSCA recipe from the **im-topology.yml** file and save the topology.

**Please change default password for VNC at the beginning of the Ansible section!**

You can edit the recipe if needed.
More info about the IM: https://imdocs.readthedocs.io/en/latest/intro.html

### 4. Launch your topology

In the list of topologies launch the one you just created.
You will be redirected to the **Infrastructures** section on the page.
Wait for the **configured** status of the topology.

### 5. Connect to the application

Open info about the VM (**VM IDs** link in a table) and copy the public IP address.

Go to the following link:

    https://paste_the_address:5904

Log in using your password and enjoy working with the Scipion.

![IM - VM info](docs/im-infrastructures-vm-info.png)
![IM - VM address](docs/im-infrastructures-vm-address.png)


## Prepare Master node manually
### Prerequisites (ubuntu packages)
* nvidia drivers
* docker with nVidia runtime
* X11 server running
* **xserver-xorg xdm xauth nvidia-container-toolkit nvidia-container-runtime nvidia-docker2**

### Headless machines
#### Configure xdm
When running on headless machine (or a machine where nobody is playing FPS games all the time), 
make sure the X server accepts unauthenticated local connections even when a user session is not running. 
E.g., the /etc/X11/xdm/xdm-config file should contain:

    DisplayManager*authorize:       false

However, such settings can be dangerous if the machine is not dedicated for this purpos, check for possible side effects.

#### Configure xorg
<!-- https://virtualgl.org/Documentation/HeadlessNV -->

**1. Run `nvidia-xconfig --query-gpu-info` to obtain the bus ID of the GPU. Example:**

```bash
Number of GPUs: 1

GPU #0:
  Name      : GeForce RTX 2080 SUPER
  UUID      : GPU-4fcfbe08-eee6-df4b-59aa-4c867e089b2f
  PCI BusID : PCI:10:0:0

  Number of Display Devices: 0
```

**2. Create an appropriate xorg.conf file for headless operation:**

```bash
sudo nvidia-xconfig -a --allow-empty-initial-configuration --use-display-device=None \
--virtual=1920x1200 --busid {busid}
```
Replace `{busid}` with the bus ID you obtained in Step 1. Leave out `--use-display-device=None` if the GPU is headless, i.e. if it has no display outputs.

**3. If you are using version 440.xx or later of the nVidia proprietary driver, then edit /etc/X11/xorg.conf and add**

```
Option "HardDPMS" "false"
```
under the Device or Screen section.

### Installation of prerequisites

#### nVidia runtime

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

### Run a container

#### Re-pull the images before running the containers
```bash
docker pull registry.gitlab.ics.muni.cz:443/eosc-synergy/scipion-docker:latest
```


#### Run

```
docker run --privileged -d --rm -p 5904:5904 -e USE_DISPLAY="4" -e ROOT_PASS="abc" -e USER_PASS="abc" -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0 --mount src=scipion-plugins,dst=/opt/scipion/software/em registry.gitlab.ics.muni.cz:443/eosc-synergy/scipion-docker:latest
```

Env var "**USE_DISPLAY**" will create new display (e.g. "**:5**").
Please note that you need new one for each instance. Therefore change the "**USE_DISPLAY**" value for each instance.

Only one-digit display number is now supported.

This is also related to the port. Change last digit of the ports "**-p 5905:5905**".

In addition, if you are using default docker runtime, you have to run the container with "**--runtime=nvidia**" parameter.

### Basic test

Your instance should be available on the link: "**https://your-adress:5905**".

The log-in password is now hard-coded in **Dockerfile**.

Open terminal a try "**nvidia-smi**" and "**glxgears -info**" commands.
Both should print output containing information about your nVidia graphics card.

<!--
## Troubleshooting

If the commands described above print output that do not contains information about nVidia card, try to backup and delete file "**/etc/X11/xorg.conf**".
-->
