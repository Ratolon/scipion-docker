
#FROM registry.gitlab.ics.muni.cz:443/eosc-synergy/scipion-docker/base-image:dev
FROM ldelcano/scipion-base:slurm

ARG S_USER=scipionuser
ARG S_USER_HOME=/home/${S_USER}
ARG CRYOS_LICENSE_ID=a3dc0cc0-3181-11ea-84d0-8b3771c7f13b

USER root

RUN apt update && apt install -y --no-install-recommends python bash iputils-ping

COPY plugin-list.txt ${S_USER_HOME}/

USER scipionuser

# Install scipion3 plugins
 RUN for pl in $(cat ${S_USER_HOME}/plugin-list.txt); do ${S_USER_HOME}/scipion3/scipion3 installp -p $pl -j $(nproc); done

# Modify MOTIONCOR2_BIN variable to point to cuda10.2 binary
RUN echo MOTIONCOR2_BIN=${S_USER_HOME}/software/em/motioncor2-1.4.0/bin/MotionCor2_1.4.0_Cuda102 >> ${S_USER_HOME}/scipion3/config/scipion.conf

# Install deepLearningToolkit for Xmipp (need CUDA=True in scipion.conf)
#RUN ["/bin/bash", "-c" , "${S_USER_HOME}/scipion3/scipion3 installb deepLearningToolkit"]

# Install cryosparc
#RUN mkdir ${S_USER_HOME}/cryosparc3
#RUN cd ${S_USER_HOME}/cryosparc3 && \
#    curl -L https://get.cryosparc.com/download/master-latest/${CRYOS_LICENSE_ID} -o cryosparc_master.tar.gz && \
#    tar -xf cryosparc_master.tar.gz
#RUN cd ${S_USER_HOME}/cryosparc3 && \
#    curl -L https://get.cryosparc.com/download/worker-latest/${CRYOS_LICENSE_ID} -o cryosparc_worker.tar.gz && \
#    tar -xf cryosparc_worker.tar.gz
#ENV USER=${USER}
#ENV CUDA_HOME "/usr/local/cuda"
#ENV CUDA_BIN "/usr/local/cuda/bin"
#WORKDIR ${S_USER_HOME}/cryosparc3/cryosparc_master
#RUN ["/bin/bash", "-c", "./install.sh --standalone --license ${CRYOS_LICENSE_ID} --worker_path ${S_USER_HOME}/cryosparc3/cryosparc_worker --cudapath /usr/local/cuda-10.2 --nossd --initial_email 'i2pc@cnb.csic.es' --initial_password 'abc' --initial_username 'i2pc' --initial_firstname 'cnb' --initial_lastname 'csic' --yes"]

# Delete software packages
#RUN rm ${S_USER_HOME}/scipion3/software/em/*gz && rm ${S_USER_HOME}/cryosparc3/*.gz
RUN rm ${S_USER_HOME}/scipion3/software/em/*gz

ENTRYPOINT ["bash"]