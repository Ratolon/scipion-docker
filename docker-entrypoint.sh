#!/bin/bash
set -x

echo $USE_DISPLAY
export WEBPORT=590${USE_DISPLAY}
export DISPLAY=:${USE_DISPLAY}

echo $WEBPORT
echo $DISPLAY


mkdir /home/scipionuser/.vnc
echo $MYVNCPASSWORD
echo $MYVNCPASSWORD | vncpasswd -f > /home/scipionuser/.vnc/passwd
chmod 0600 /home/scipionuser/.vnc/passwd
/opt/websockify/run ${WEBPORT} --cert=/self.pem --ssl-only --web=/opt/noVNC --wrap-mode=ignore -- vncserver ${DISPLAY} -xstartup /tmp/xsession
#export DISPLAY=$DISPLAY
#cd /opt/genomecruzer && ./Adrastea &
#echo "end"


