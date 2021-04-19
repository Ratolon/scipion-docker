#!/bin/bash

set -ex

S_USER=scipionuser
S_USER_HOME=/home/$S_USER

export USER=$S_USER
cd $S_USER_HOME/cryosparc3/cryosparc_master
./install.sh --license $1
echo -e "CRYOSPARC_HOME = $S_USER_HOME/cryosparc3" >> $S_USER_HOME/scipion3/config/scipion.conf