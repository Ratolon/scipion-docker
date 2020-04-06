# noVNC + TurboVNC + VirtualGL
# http://novnc.com
# https://turbovnc.org
# https://virtualgl.org

# xhost +si:localuser:root
# openssl req -new -x509 -days 365 -nodes -out self.pem -keyout self.pem
# docker build -t turbovnc .
# docker run --init --runtime=nvidia --name=turbovnc --rm -i -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0 -p 5902:5902 turbovnc
# docker exec -ti turbovnc vglrun glxspheres64

FROM nvidia/cuda:8.0-runtime-ubuntu16.04
#FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu18.04
#FROM k8s.gcr.io/cuda-vector-add:v1.0

#ARG use_display=2

ARG TURBOVNC_VERSION=2.2.4
ARG VIRTUALGL_VERSION=2.5.2
ARG LIBJPEG_VERSION=1.5.2
ARG WEBSOCKIFY_VERSION=0.8.0
ARG NOVNC_VERSION=1.1.0

ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES},display


RUN apt update && apt upgrade -y
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata

RUN apt install -y --no-install-recommends \
        wget \
	htop \
	vim \
        libssl1.0.0 \
        gcc-5 \
        g++-5 cmake openjdk-8-jdk libxft-dev libssl-dev libxext-dev\
 libxml2-dev libquadmath0 libxslt1-dev libopenmpi-dev openmpi-bin\
 libxss-dev libgsl0-dev libx11-dev gfortran libfreetype6-dev scons libfftw3-dev libopencv-dev curl git

RUN apt install -y --no-install-recommends \
        ca-certificates \
        curl \
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
	openbox \
	xterm \
        libdbus-1-3 \
	libxcb-keysyms1 \
	mesa-utils \
	pluma \
	sudo \
	bison \
	flex \
	ssh \
	g++

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
	dbus-x11 \
	xfce4

RUN apt install -y --no-install-recommends \
	cuda-core-8-0 \
#	cuda-libraries-8-0 \
	cuda-samples-8-0

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

COPY self.pem /

RUN echo 'no-remote-connections\n\
no-httpd\n\
no-x11-tcp-connections\n\
no-pam-sessions\n\
permitted-security-types = TLSVnc, TLSOtp, TLSPlain, TLSNone, X509Vnc, X509Otp, X509Plain, X509None, VNC, OTP, UnixLogin, Plain\
' > /etc/turbovncserver-security.conf

ADD turbovncserver.conf /etc/turbovncserver.conf


RUN echo '#!/bin/sh\n\
vglrun xterm & \
vglrun openbox \
#\nexport DISPLAY=:${DISPLAY}\n\
#cd /opt/genomecruzer && ./Adrastea &\
' >/tmp/xsession; chmod +x /tmp/xsession


#EXPOSE 590${use_display}
#ENV USE_DISPLAY 7
#ENV WEBPORT 590${USE_DISPLAY}
#ENV DISPLAY :${USE_DISPLAY}
ENV MYVNCPASSWORD abc
ENV OSG_FILE_PATH=/opt/genomecruzer/data
ENV EDITOR=/usr/bin/pluma
#ENV LD_LIBRARY_PATH="/opt/genomecruzer/bin:$LD_LIBRARY_PATH"

#ENTRYPOINT /opt/websockify/run ${WEBPORT} --cert=/self.pem --ssl-only --web=/opt/noVNC --wrap-mode=ignore -- vncserver ${DISPLAY} -securitytypes otp -otp -xstartup /tmp/xsession
#ENTRYPOINT /opt/websockify/run ${WEBPORT} --cert=/self.pem --ssl-only --web=/opt/noVNC --wrap-mode=ignore -- vncserver ${DISPLAY} -xstartup /tmp/xsession


#RUN pip install --upgrade pip

#ADD scipion/ /opt/scipion/

RUN groupadd -r scipionuser
RUN useradd -r -m -d /home/scipionuser -s /bin/bash -g scipionuser scipionuser

ADD xfce4 /home/scipionuser/.config/

RUN chown -R scipionuser:scipionuser /home/scipionuser

RUN chown -R scipionuser:scipionuser /opt/scipion

USER scipionuser

RUN echo "" | /opt/scipion/scipion config

RUN sed -i 's/MPI_LIBDIR\s*=.*/MPI_LIBDIR = \/usr\/lib\/x86_64-linux-gnu\/openmpi\/lib/' /opt/scipion/config/scipion.conf
RUN sed -i 's/MPI_INCLUDE\s*=.*/MPI_INCLUDE = \/usr\/lib\/x86_64-linux-gnu\/openmpi\/include/' /opt/scipion/config/scipion.conf
RUN echo "RELION_CUDA_LIB = /usr/local/cuda-8.0/lib64" >>  /opt/scipion/config/scipion.conf
RUN echo "RELION_CUDA_BIN = /usr/local/cuda-8.0/bin" >>  /opt/scipion/config/scipion.conf

RUN /opt/scipion/scipion install -j12
#RUN /opt/scipion/scipion installp -p scipion-em-xmipp -j 12
#RUN /opt/scipion/scipion installp -p scipion-em-eman2 -j 12
#RUN /opt/scipion/scipion installb xmippBin_Debian -j 12

USER root
RUN mkdir /tmp/.X11-unix | true
RUN chmod -R ugo+rwx /tmp/.X11-unix
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

RUN usermod -aG sudo scipionuser
RUN echo "abc\nabc" | passwd root
RUN echo "abc\nabc" | passwd scipionuser

USER scipionuser
ENTRYPOINT ["/docker-entrypoint.sh", "1>/docker-entrypoint.out.log", "2>/docker-entrypoint.err.log"]

