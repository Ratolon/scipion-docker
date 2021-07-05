FROM nvidia/cudagl:10.2-devel-ubuntu18.04

ARG S_USER=scipionuser
ARG S_USER_HOME=/home/${S_USER}
ARG XMIPP_VERSION=xmippSrc-v3.21.06.1

RUN apt update && apt upgrade -y

RUN apt update && DEBIAN_FRONTEND="noninteractive" apt install -y \
	tzdata

# Install necessary packages
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
	bash \
	make \
	curl \
	wget \
	openssh-client \
	ca-certificates \
	python3 \
	bison \
	flex \
	git
# bison, flex, ca-certificates, git ??

# Required by Scipion
RUN apt update && apt install -y \
	libxv1 \
	openjdk-8-jdk \
	libfftw3-dev \
	libtiff-dev

# Required by Scipion for conda installation
RUN apt-get -y install sudo wget gcc g++ libopenmpi-dev mesa-utils openssh-client cmake libnss3 libfontconfig1 libxrender1 libxtst6 xterm libasound2 libglu1 libxcursor1 libdbus-1-3 libxkbcommon-x11-0 libhdf5-dev

# Clean apt
RUN rm -rf /var/lib/apt/lists/*

# Create scipionuser
RUN groupadd --gid 1042 ${S_USER} && \
    useradd --uid 1042 --create-home --home-dir ${S_USER_HOME} -s /bin/bash -g ${S_USER} ${S_USER} && \
    usermod -aG sudo ${S_USER}

RUN chown -R ${S_USER}:${S_USER} ${S_USER_HOME}

ENV CUDA_HOME "/usr/local/cuda"
#ENV PATH "${CUDA_HOME}/bin:$PATH"
ENV CUDA_BIN "/usr/local/cuda/bin"

ENV NVIDIA_DRIVER_CAPABILITIES compute,utility


USER ${S_USER}
#######################

RUN ["/bin/bash", "-c", "echo $CUDA_HOME"]
RUN ["/bin/bash", "-c", "echo $PATH"]


# Install Scipion
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ${S_USER_HOME}/miniconda.sh
RUN bash ${S_USER_HOME}/miniconda.sh -b
RUN ${S_USER_HOME}/miniconda3/bin/conda init
RUN ["/bin/bash", "-ci" , "python3 -m pip install scipion-installer"]
RUN ["/bin/bash", "-ci" , "cd ${S_USER_HOME} && python3 -m scipioninstaller ${S_USER_HOME}/scipion3 -noAsk -noXmipp -j $(nproc)"]

# Install xmipp without native compilation flags
RUN ["/bin/bash", "-c" , "${S_USER_HOME}/scipion3/scipion3 installp -p scipion-em-xmipp -j $(nproc) --noBin"]
RUN wget http://scipion.cnb.csic.es/downloads/scipion/software/em/${XMIPP_VERSION}.tgz -O ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}.tgz
RUN tar xfz ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}.tgz -C ${S_USER_HOME}/scipion3/software/em/
RUN ["/bin/bash", "-c" , "cd ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION} && ${S_USER_HOME}/scipion3/scipion3 run ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp noAsk config"]
RUN sed -i 's/-mtune=native -march=native //g' ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp.conf
#RUN sed -i 's/CUDA=True/CUDA=False/g' ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp.conf
RUN ["/bin/bash", "-c" , "cd ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION} && ${S_USER_HOME}/scipion3/scipion3 run ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp compile"]
RUN ["/bin/bash", "-c" , "cd ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION} && ${S_USER_HOME}/scipion3/scipion3 run ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp install"]
RUN ln -s ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/build ${S_USER_HOME}/scipion3/software/em/xmipp

# data directory for mount NFS using docker volume
RUN mkdir ${S_USER_HOME}/ScipionUserData

# Disable conda auto activation
RUN ${S_USER_HOME}/miniconda3/bin/conda config --set auto_activate_base false

USER ${S_USER}

# Install plugins for Scipion
COPY plugin-list.txt ${S_USER_HOME}/
RUN for pl in $(cat ${S_USER_HOME}/plugin-list.txt); do ${S_USER_HOME}/scipion3/scipion3 installp -p $pl -j $(nproc); done
RUN  rm ${S_USER_HOME}/scipion3/software/em/*gz

# Install deeplearningtoolkit
RUN ${S_USER_HOME}/scipion3/scipion3 installb deepLearningToolkit -j $(nproc)

# Modify MOTIONCOR2_BIN variable to point to cuda10.2 binary
RUN echo MOTIONCOR2_BIN=${S_USER_HOME}/software/em/motioncor2-1.4.0/bin/MotionCor2_1.4.0_Cuda102 >> ${S_USER_HOME}/scipion3/config/scipion.conf

USER root
# run docker-entrypoint.sh
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

#ENTRYPOINT ["bash"]