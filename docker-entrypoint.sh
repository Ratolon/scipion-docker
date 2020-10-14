#!/bin/bash

set -xe

export PATH="/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/VirtualGL/bin:/opt/TurboVNC/bin"

echo $USE_DISPLAY
export WEBPORT=590${USE_DISPLAY}
export DISPLAY=:${USE_DISPLAY}

echo $WEBPORT
echo $DISPLAY

# install all installed plugins
#export CORE_COUNT=$(nproc) && \
#for pl in $(cat /opt/scipion/software/em/plugin-list-pl.txt); do /opt/scipion/scipion installp -p $pl -j $CORE_COUNT; done
#for bin in $(cat /opt/scipion/software/em/plugin-list-bin.txt); do /opt/scipion/scipion installb $bin -j $CORE_COUNT; done

mkdir /home/scipionuser/.vnc
echo $MYVNCPASSWORD
echo $MYVNCPASSWORD | vncpasswd -f > /home/scipionuser/.vnc/passwd
chmod 0600 /home/scipionuser/.vnc/passwd
/opt/websockify/run ${WEBPORT} --cert=/self.pem --ssl-only --web=/opt/noVNC --wrap-mode=ignore -- vncserver ${DISPLAY} -xstartup /tmp/xsession
