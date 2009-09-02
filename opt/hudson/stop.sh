#!/bin/bash
#
# Stop hudson
#
# $Id: start.sh 22757 2008-12-16 20:13:12Z jerome $
#
# Must be ran as root


if [ -f /opt/hudson/hudson.pid ]; then
  kill `cat /opt/hudson/hudson.pid` 2> /dev/null
  rm /opt/hudson/hudson.pid
fi

if [ -f /opt/hudson/ssh-agent.pid ]; then
  kill `cat /opt/hudson/ssh-agent.pid` 2> /dev/null
  rm /opt/hudson/ssh-agent.pid
fi
