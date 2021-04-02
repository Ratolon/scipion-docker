#!/bin/bash

set -xe

S_USER=scipionuser
S_USER_HOME=/home/${S_USER}
CRYOS_LICENSE_ID=a3dc0cc0-3181-11ea-84d0-8b3771c7f13b

# Update cryosparc hostnames
su - $S_USER
sed -i -e 's+CRYOSPARC_MASTER_HOSTNAME=.*+CRYOSPARC_MASTER_HOSTNAME="$HOSTNAME"+g' $S_USER_HOME/cryosparc3/cryosparc_master/config.sh
$S_USER_HOME/cryosparc3/cryosparc_master/bin/cryosparcm start
cd $S_USER_HOME/cryosparc3/cryosparc_worker
./bin/cryosparcw connect --master localhost --port 39000 --worker $HOSTNAME --nossd

exec "$@"