#!/bin/bash

set -xe

S_USER=scipionuser
S_USER_HOME=/home/${S_USER}
CORE_COUNT=$(nproc)

export PATH="/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/VirtualGL/bin:/opt/TurboVNC/bin"

echo $USE_DISPLAY
export WEBPORT=590${USE_DISPLAY}
export DISPLAY=:${USE_DISPLAY}

echo $WEBPORT
echo $DISPLAY

# install all installed plugins
#for pl in $(cat $S_USER_HOME/scipion3/software/em/plugin-list-pl.txt); do $S_USER_HOME/scipion3/scipion3 installp -p $pl -j $CORE_COUNT; done
#for bin in $(cat $S_USER_HOME/scipion3/software/em/plugin-list-bin.txt); do $S_USER_HOME/scipion3/scipion3 installb $bin -j $CORE_COUNT; done
for pl in $(cat ${S_USER_HOME}/plugin-list-pl.txt); do ${S_USER_HOME}/scipion3/scipion3 installp -p $pl -j $CORE_COUNT --noBin; done
#for bin in $(cat ${S_USER_HOME}/plugin-list-bin.txt); do ${S_USER_HOME}/scipion3/scipion3 installb $bin -j $CORE_COUNT; done

mkdir $S_USER_HOME/.vnc
echo $MYVNCPASSWORD
echo $MYVNCPASSWORD | vncpasswd -f > $S_USER_HOME/.vnc/passwd
chmod 0600 $S_USER_HOME/.vnc/passwd
/opt/websockify/run ${WEBPORT} --cert=/self.pem --ssl-only --web=/opt/noVNC --wrap-mode=ignore -- vncserver ${DISPLAY} -xstartup /tmp/xsession
