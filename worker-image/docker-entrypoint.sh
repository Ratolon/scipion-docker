#!/bin/bash

set -xe

S_USER=scipionuser
S_USER_HOME=/home/${S_USER}

mkdir -p ${S_USER_HOME}/ScipionUserData/data
ln -s ${S_USER_HOME}/ScipionUserData/data ${S_USER_HOME}/scipion3/data

chown $S_USER:$S_USER $S_USER_HOME/scipion3/software/em
chown -R $S_USER:$S_USER $S_USER_HOME/ScipionUserData

sudo -H -u $S_USER "$@"