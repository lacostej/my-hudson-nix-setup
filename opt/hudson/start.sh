#!/bin/bash
#
# Start hudson with a ssh-agent and preconfigured set of keys (without password)
#
# $Id: start.sh 22757 2008-12-16 20:13:12Z jerome $
#
# Must be ran as hudson

SSHAGENT=/usr/bin/ssh-agent
SSHAGENTARGS="-s"

HUDSON_OPTS=--httpPort=8082

JAVA_HOME="/opt/latest/java"

PATH="$JAVA_HOME/bin:/usr/local/bin:/usr/bin:/bin"

JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=8001,suspend=n"
#JAVA_OPTS="-Dhttp.proxyHost=proxy -Dhttp.proxyPort=8080 -Dhttp.nonProxyHosts=\"*.edb.com|10.*\" $JAVA_OPTS"
JAVA_OPTS="-Xmx1024m -XX:MaxPermSize=256m $JAVA_OPTS"
#JAVA_OPTS="-Djava.awt.headless=true $JAVA_OPTS" 

killall Xrealvnc; killall Xvnc; rm -fv /tmp/.X*-lock /tmp/.X11-unix/X*

nb_ssh_agent=`ps -aef | grep ssh-agent | grep -v grep | wc -l`

if [ $nb_ssh_agent -gt 0  ]; then
  ps -o pid,user,comm -ae | grep ssh-agent | cut -c 0-6 | xargs -l1 kill
fi

# initialize
if [ -x "$SSHAGENT" ]; then
  eval `$SSHAGENT $SSHAGENTARGS`
 # trap "kill $SSH_AGENT_PID" 0
fi

ssh-add

touch /opt/hudson/hudson.pid

#su -s /bin/sh hudson -c "
  cd /
  exec setsid java $JAVA_OPTS -jar /opt/hudson/hudson.war $HUDSON_OPTS \
    </dev/null >>/opt/hudson/console_log 2>&1 & 
                echo $! >/opt/hudson/hudson.pid 
                disown $!
#                "

echo $SSH_AGENT_PID > /opt/hudson/ssh-agent.pid
#kill $SSH_AGENT_PID
