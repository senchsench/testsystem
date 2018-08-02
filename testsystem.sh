#!/bin/sh

# version=2018030201

. /usr/local/etc/testsystem/testsystem.subr

dc=`ps -axw|grep -v grep|grep "$testsystem/testsystem.sh"|wc -l`
if [ "$dc" -gt "4" ];then
    $testsystem/daemon_pager.sh "testsystem.sh already started counts=$dc" "1"
    exit 1
fi

testsystem_perm
testsystem_update "daemon.sh" "$testsystem" "root:wheel" "0750"
testsystem_update "daemon_pager.sh" "$testsystem" "root:wheel" "0750"
testsystem_update "daemon.subr" "$testsystem" "root:wheel" "0750"
testsystem_update "testsystem.subr" "$testsystem" "root:wheel" "0750"
testsystem_update "testsystem.sh" "$testsystem" "root:wheel" "0750"
testsystem_monitor

exit 0
##### file complit testsystem #####
