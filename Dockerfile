# noVNC + TurboVNC + VirtualGL
# http://novnc.com
# https://turbovnc.org
# https://virtualgl.org

FROM nvidia/cudagl:10.1-runtime-ubuntu18.04

ARG TURBOVNC_VERSION=2.2.4
ARG VIRTUALGL_VERSION=2.5.2
ARG LIBJPEG_VERSION=1.5.2
ARG WEBSOCKIFY_VERSION=0.8.0
ARG NOVNC_VERSION=1.1.0

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
	g++ \
        libssl1.0.0 \
        gcc-5 \
        g++-5 \
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

RUN curl -fsSL -o /tmp/scipion_latest_linux64_Ubuntu.tgz http://scipion.i2pc.es/startdownload/?bundleId=4
RUN cd /tmp/ && tar -xzf scipion_latest_linux64_Ubuntu.tgz && mv /tmp/scipion /opt/

# https://wiki.archlinux.org/index.php/VirtualGL
RUN chmod u+s /usr/lib/libvglfaker.so && \
    chmod u+s /usr/lib32/libvglfaker.so && \
    chmod u+s /usr/lib/libdlfaker.so && \
    chmod u+s /usr/lib32/libdlfaker.so

# Create scipionuser
RUN groupadd -r scipionuser && \
    useradd -r -m -d /home/scipionuser -s /bin/bash -g scipionuser scipionuser

RUN usermod -aG sudo scipionuser
#RUN echo "abc\nabc" | passwd root
#RUN echo "abc\nabc" | passwd scipionuser

# Create Scipion icon
RUN mkdir /home/scipionuser/Desktop | true
ADD Scipion.desktop /home/scipionuser/Desktop/
RUN chmod +x /home/scipionuser/Desktop/Scipion.desktop

# Prepare home and Scipion for scipionuser
RUN chown -R scipionuser:scipionuser /home/scipionuser && \
    chown -R scipionuser:scipionuser /opt/scipion

USER scipionuser
#######################

# Install Scipion
RUN echo "" | /opt/scipion/scipion config

RUN sed -i 's/MPI_LIBDIR\s*=.*/MPI_LIBDIR = \/usr\/lib\/x86_64-linux-gnu\/openmpi\/lib/' /opt/scipion/config/scipion.conf && \
    sed -i 's/MPI_INCLUDE\s*=.*/MPI_INCLUDE = \/usr\/lib\/x86_64-linux-gnu\/openmpi\/include/' /opt/scipion/config/scipion.conf && \
    echo "RELION_CUDA_LIB = /usr/local/cuda-8.0/lib64" >>  /opt/scipion/config/scipion.conf && \
    echo "RELION_CUDA_BIN = /usr/local/cuda-8.0/bin" >>  /opt/scipion/config/scipion.conf

RUN /opt/scipion/scipion install -j12

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
RUN mkdir /tmp/.X11-unix | true
RUN chmod -R ugo+rwx /tmp/.X11-unix

RUN echo '#!/bin/sh\n\
vglrun xterm & \
vglrun xfce4-session \
' >/tmp/xsession; chmod +x /tmp/xsession

ENV MYVNCPASSWORD abc
ENV EDITOR=/usr/bin/pluma

COPY self.pem /

# run docker-entrypoint.sh
COPY docker-entrypoint-root.sh /
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint-root.sh
RUN chmod +x /docker-entrypoint.sh

#USER scipionuser
#######################

ENTRYPOINT ["/docker-entrypoint-root.sh"]

