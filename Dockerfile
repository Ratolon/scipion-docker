# noVNC + TurboVNC + VirtualGL
# http://novnc.com
# https://turbovnc.org
# https://virtualgl.org

#FROM nvidia/cudagl:10.1-runtime-ubuntu18.04

# cannot compile xmipp using "runtime" image
FROM nvidia/cudagl:10.1-devel-ubuntu18.04

ARG TURBOVNC_VERSION=2.2.4
ARG VIRTUALGL_VERSION=2.5.2
ARG LIBJPEG_VERSION=1.5.2
ARG WEBSOCKIFY_VERSION=0.8.0
ARG NOVNC_VERSION=1.1.0

ARG S_USER=scipionuser
ARG S_USER_HOME=/home/${S_USER}

RUN apt update && apt upgrade -y

RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata


# Install necessary packages
RUN apt update && apt install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        gcc \
        libc6-dev \
        libglu1 \
        libsm6 \
        libxv1 \
        make \
        python \
        python-numpy \
        x11-xkb-utils \
        xauth \
        xfonts-base \
        xkb-data \
	xterm \
        libdbus-1-3 \
	libxcb-keysyms1 \
	pluma \
	sudo \
	bison \
	flex \
	ssh \
        libssl1.0.0 \
cmake openjdk-8-jdk libxft-dev libssl-dev libxext-dev\
 libxml2-dev libquadmath0 libxslt1-dev libopenmpi-dev openmpi-bin\
 libxss-dev libgsl0-dev libx11-dev gfortran libfreetype6-dev scons libfftw3-dev libopencv-dev git

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
	dbus-x11 \
	xfce4

RUN apt update && apt install -y --no-install-recommends \
	mesa-utils \
	htop \
	vim

# conda
RUN apt-get -y install sudo wget gcc g++ libopenmpi-dev mesa-utils openssh-client cmake libnss3 libfontconfig1 libxrender1 libxtst6 xterm libasound2 libglu1 libxcursor1 libdbus-1-3 libxkbcommon-x11-0 libhdf5-dev

# venv
#RUN apt-get install -y gcc g++ make libopenmpi-dev python3-tk libfftw3-dev libhdf5-dev libtiff-dev libjpeg-dev libsqlite3-dev openjdk-8-jdk

# Install TurboVNC, VirtualGL, noVNC
RUN rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    curl -fsSL -O https://svwh.dl.sourceforge.net/project/turbovnc/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb \
        -O https://svwh.dl.sourceforge.net/project/libjpeg-turbo/${LIBJPEG_VERSION}/libjpeg-turbo-official_${LIBJPEG_VERSION}_amd64.deb \
        -O https://svwh.dl.sourceforge.net/project/virtualgl/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb \
        -O https://svwh.dl.sourceforge.net/project/virtualgl/${VIRTUALGL_VERSION}/virtualgl32_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb && \
    sed -i 's/$host:/unix:/g' /opt/TurboVNC/bin/vncserver

ENV PATH ${PATH}:/opt/VirtualGL/bin:/opt/TurboVNC/bin

RUN curl -fsSL https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz | tar -xzf - -C /opt && \
    curl -fsSL https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz | tar -xzf - -C /opt && \
    mv /opt/noVNC-${NOVNC_VERSION} /opt/noVNC && \
    mv /opt/websockify-${WEBSOCKIFY_VERSION} /opt/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html && \
    cd /opt/websockify && make

#RUN curl -fsSL -o /tmp/scipion_latest_linux64_Ubuntu.tgz http://scipion.i2pc.es/startdownload/?bundleId=4
#RUN cd /tmp/ && tar -xzf scipion_latest_linux64_Ubuntu.tgz && mv /tmp/scipion /opt/


# Create scipionuser
RUN groupadd --gid 1042 ${S_USER} && \
    useradd --uid 1042 --create-home --home-dir ${S_USER_HOME} -s /bin/bash -g ${S_USER} ${S_USER} && \
    usermod -aG sudo ${S_USER}

# Create Scipion icon
RUN mkdir ${S_USER_HOME}/Desktop || true
ADD res/scipion_logo.png ${S_USER_HOME}/scipion3/
ADD res/Scipion.desktop ${S_USER_HOME}/Desktop/
RUN chmod +x ${S_USER_HOME}/scipion3/scipion_logo.png && \
    chmod +x ${S_USER_HOME}/Desktop/Scipion.desktop

# Prepare home and Scipion for scipionuser
#RUN chown -R scipionuser:scipionuser /home/scipionuser && \
#    chown -R scipionuser:scipionuser /opt/scipion

RUN chown -R ${S_USER}:${S_USER} ${S_USER_HOME}

# docasne - test v3 using venv
#RUN apt install -y python-support
#RUN update-python-modules -a
#RUN apt install -y python-pip python-dev python3-pip python3-dev python3-h5py python-h5py libhdf5-serial-dev gcc g++ make libopenmpi-dev python3-tk libfftw3-dev libhdf5-dev libtiff-dev libjpeg-dev libsqlite3-dev openjdk-8-jdk

#RUN apt install -y libjpeg8-dev libtiff5-dev libgtk2.0-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libatlas-base-dev gfortran libhdf5-serial-dev python2.7-dev

ENV CUDA_HOME "/usr/local/cuda"
#ENV PATH "${CUDA_HOME}/bin:$PATH"
ENV CUDA_BIN "/usr/local/cuda/bin"

ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,display


USER ${S_USER}
#######################

# Install Scipion
#RUN echo "" | /opt/scipion/scipion config

#RUN sed -i 's/MPI_LIBDIR\s*=.*/MPI_LIBDIR = \/usr\/lib\/x86_64-linux-gnu\/openmpi\/lib/' /opt/scipion/config/scipion.conf && \
#    sed -i 's/MPI_INCLUDE\s*=.*/MPI_INCLUDE = \/usr\/lib\/x86_64-linux-gnu\/openmpi\/include/' /opt/scipion/config/scipion.conf && \
#    sed -i 's/CUDA\s*=.*/CUDA = True/' /opt/scipion/config/scipion.conf && \
#    sed -i 's/CUDA_LIB\s*=.*/CUDA_LIB = \/usr\/local\/cuda\/lib64/' /opt/scipion/config/scipion.conf && \
#    sed -i 's/CUDA_BIN\s*=.*/CUDA_BIN = \/usr\/local\/cuda\/bin/' /opt/scipion/config/scipion.conf && \
#    echo "RELION_CUDA_LIB = /usr/local/cuda/lib64" >>  /opt/scipion/config/scipion.conf && \
#    echo "RELION_CUDA_BIN = /usr/local/cuda/bin" >>  /opt/scipion/config/scipion.conf && \
#    echo "MOTIONCOR2_BIN = MotionCor2_1.3.0-Cuda101" >>  /opt/scipion/config/scipion.conf && \
#    echo "GCTF = Gctf_v1.18_sm30-75_cu10.1" >>  /opt/scipion/config/scipion.conf && \
#    echo "GAUTOMATCH = Gautomatch_v0.56_sm30-75_cu10.1" >>  /opt/scipion/config/scipion.conf && \
#    sed -i 's/NVCC_INCLUDE\s*=.*/NVCC_INCLUDE = \/usr\/local\/cuda\/include/' /opt/scipion/config/scipion.conf

#RUN /opt/scipion/scipion install -j12


RUN ["/bin/bash", "-ci", "echo $CUDA_HOME"]
RUN ["/bin/bash", "-ci", "echo $PATH"]

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ${S_USER_HOME}/miniconda.sh
RUN bash ${S_USER_HOME}/miniconda.sh -b
RUN ${S_USER_HOME}/miniconda3/bin/conda init
RUN ["/bin/bash", "-ci" , "python -m pip install scipion-installer"]
RUN ["/bin/bash", "-ci" , "python -m scipioninstaller /home/scipionuser/scipion3 -noAsk -j $(nproc)"]

#RUN export PATH=$PATH:/usr/local/cuda/bin
RUN ["/bin/bash", "-ci", "echo $PATH"]
#RUN python -m pip install --user scipion-installer
#RUN python -m pip install --user h5py
#RUN python3 -m pip install --user h5py
#RUN ["/bin/bash", "-ci", "source /home/scipionuser/scipion/.scipion3env/bin/activate && pip3 install h5py && deactivate"]
#RUN python -m scipioninstaller /home/scipionuser/scipion -venv -j $(nproc)

#RUN conda update -n base -c defaults conda

USER root
#######################


# Create TurboVNC config
RUN echo 'no-remote-connections\n\
no-httpd\n\
no-x11-tcp-connections\n\
no-pam-sessions\n\
permitted-security-types = TLSVnc, TLSOtp, TLSPlain, TLSNone, X509Vnc, X509Otp, X509Plain, X509None, VNC, OTP, UnixLogin, Plain\
' > /etc/turbovncserver-security.conf

ADD turbovncserver.conf /etc/turbovncserver.conf

# Prepare environment
RUN mkdir /tmp/.X11-unix || true
RUN chmod -R ugo+rwx /tmp/.X11-unix

COPY xfce4 ${S_USER_HOME}/.config/xfce4/
RUN chown -R ${S_USER}:${S_USER} ${S_USER_HOME}/.config/xfce4

RUN echo '#!/bin/sh\n\
vglrun xfce4-session \
' >/tmp/xsession; chmod +x /tmp/xsession

ENV MYVNCPASSWORD abc
ENV EDITOR=/usr/bin/pluma

COPY self.pem /

# run docker-entrypoint.sh
COPY docker-entrypoint-root.sh /
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint-root.sh && \
    chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint-root.sh"]

