#!/bin/sh

# version=2008052810

PAGER=$1
PRI=$2
type=$3
if [ -z "$PRI" ];then
  PRI=1
fi
if [ "$type" != "mail" ];then
  type="syslog"
fi
if [ "$type" = "syslog" ];then
  if [ ! -z "$PAGER" ];then
    /usr/bin/logger -t testsystem "${PAGER}::${PRI}"
    echo "$PAGER, PRI=$PRI"
  fi
 else
  echo "$PAGER"|/usr/bin/mail -s "$PAGER" root
fi
exit 0
##### file complit testsystem #####
