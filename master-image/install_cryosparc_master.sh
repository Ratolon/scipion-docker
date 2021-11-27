#!/bin/bash

set -ex

S_USER=scipionuser
S_USER_HOME=/home/$S_USER

export USER=$S_USER

mkdir ${S_USER_HOME}/cryosparc3
curl -L https://get.cryosparc.com/download/master-v${CRYOSPARC_VERSION}/${CRYOSPARC_LICENSE} -o ${S_USER_HOME}/cryosparc3/cryosparc_master.tar.gz
curl -L https://get.cryosparc.com/download/worker-v${CRYOSPARC_VERSION}/$CRYOSPARC_LICENSE -o ${S_USER_HOME}/cryosparc3/cryosparc_worker.tar.gz
tar -xf ${S_USER_HOME}/cryosparc3/cryosparc_master.tar.gz -C ${S_USER_HOME}/cryosparc3
tar -xf ${S_USER_HOME}/cryosparc3/cryosparc_worker.tar.gz -C ${S_USER_HOME}/cryosparc3
rm ${S_USER_HOME}/cryosparc3/cryosparc_*.tar.gz

cd $S_USER_HOME/cryosparc3/cryosparc_master
./install.sh --standalone --license $CRYOSPARC_LICENSE --worker_path $S_USER_HOME/cryosparc3/cryosparc_worker --cudapath /usr/local/cuda --nossd --initial_email 'i2pc@cnb.csic.es' --initial_password 'i2pc' --initial_username 'i2pc' --initial_firstname 'cnb' --initial_lastname 'csic' --yes
echo -e "CRYOSPARC_HOME = $S_USER_HOME/cryosparc3" >> $S_USER_HOME/scipion3/config/scipion.conf