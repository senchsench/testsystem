#!/bin/sh

# version=2018021800

command=`echo $1|cut -f1 -d\ `
param=`echo $1|cut -f2- -d\ `

if [ -z "$command" ];then
  echo "not command!"
  exit 1
fi

. /usr/local/etc/testsystem/daemon.subr

case "$command" in

'mount_system')
  nfs_mount srv0.net.pl130.ru /mnt/main/system /mnt/system
  ;;
'mount_backup')
  nfs_mount srv0.net.pl130.ru /mnt/main/backup /mnt/backup
  ;;
'mount_sait')
  nfs_mount srv0.net.pl130.ru /mnt/main/sait /mnt/sait
  ;;
'mount_reserv')
  nfs_mount sench.net.pl130.ru /mnt/sys/reserv /mnt/reserv
  ;;
'mount_nfs')
  nfs_mount $param
  ;;
'free_disk')
  freedisk
  ;;
'quota')
  quotafs $param
  ;;
'transparent_proxy')
  transparent_proxy $param
  ;;
'home')
  homes="/home" 
  ls -lL $homes|while read attr i user group size month day times name
  do
    if [ "$attr" != "total" ];then
      if [ "$attr" != "dr-xr-x--x" ];then
        $testsystem/daemon_pager.sh "$homes/$name $attr!" 3
        chmod 0551 $homes/$name
      fi
      if [ "$user" != "root" -o "$group" != "users" ];then
        $testsystem/daemon_pager.sh "$homes/$name $user:$group!" 3
        chown root:users $homes/$name
      fi
    fi
  done
  ;;
'smb')
  hostname=`hostname -s`
  if [ -f /usr/local/samba/bin/smbstatus ];then
    err=`/usr/local/samba/bin/smbstatus 2>&1 > /mnt/system/load/smb.$hostname`
  fi
  if [ -f /usr/local/bin/smbstatus ];then
    err=`/usr/local/bin/smbstatus 2>&1 > /mnt/system/load/smb.$hostname`
  fi
  ;;
'del_dir')
  del_dir $param
  ;;
'spam')
  read_spam spam
  read_spam ham
  daemon spamass-milter
  daemon spamd
  ;;
'daemon')
  daemon $param
  ;;
'rsync')
  rsync $param
  ;;
'apache_home_log_del')
  apache_home_log_del
  ;;
'mysql_quota')
  if [ -r "$testsystem/mysql_quota.conf" ];then
    . "$testsystem/mysql_quota.conf"
    mysql_quota
   else
    $testsystem/daemon_pager.sh "Not found $testsystem/mysql_quota.conf" "1"
  fi
  ;;
'videocam')
  if [ -r "$testsystem/videocam.conf" ];then
    . "$testsystem/videocam.conf"
    videocam
   else
    $testsystem/daemon_pager.sh "Not found $testsystem/videocam.conf" "1"
  fi
  ;;
'backup_firebird_remote')
      conf_file="$testsystem/$param.conf"
      if [ -r $conf_file ];then
        . $conf_file
        backup_firebird_remote
       else
        $testsystem/daemon_pager.sh "Not found $conf_file" "1"
      fi
  ;;
'backup_firebird_home')
      conf_file="$testsystem/$param.conf"
      if [ -r $conf_file ];then
        . $conf_file
        backup_firebird_home
       else
        $testsystem/daemon_pager.sh "Not found $conf_file" "1"
      fi
  ;;
'backup_mysql_home')
      conf_file="$testsystem/$param.conf"
      if [ -r $conf_file ];then
        . $conf_file
        backup_mysql_home
       else
        $testsystem/daemon_pager.sh "Not found $conf_file" "1"
      fi
  ;;
'backup_dir_home')
      conf_file="$testsystem/$param.conf"
      if [ -r $conf_file ];then
        . $conf_file
        backup_dir_home
       else
        $testsystem/daemon_pager.sh "Not found $conf_file" "1"
      fi
  ;;
'backup_dump')
      conf_file="$testsystem/$param.conf"
      if [ -r $conf_file ];then
        . $conf_file
        backup_dump
       else
        $testsystem/daemon_pager.sh "Not found $conf_file" "1"
      fi
  ;;
'backup_dir')
      conf_file="$testsystem/$param.conf"
      if [ -r $conf_file ];then
        . $conf_file
        backup_dir
       else
        $testsystem/daemon_pager.sh "Not found $conf_file" "1"
      fi
  ;;
'raid_status')
  raid_status
  ;;
'wifi_client')
  wifiap="apc5l apc5r apc4l apc4r apc3l apc3r apc2l apc2r apc1c"
  wifi_domain="net.vrcdo.edu.ru"
  wifi_html="/home/netmon/wwws/stats/wifi_client.html"
  echo "<h1>######  WIFI CLIENTS ######</h1>">$wifi_html
  echo "<h2>`date`</h2>">>$wifi_html
  for wifi in $wifiap
  do
    if [ ! -z "`/sbin/ping -c 2 -t 2 $wifi.$wifi_domain 2>&1 |grep time`" ];then
      echo -n "<hr><h2>WIFI AP $wifi.$wifi_domain</h2>">>$wifi_html
      /usr/bin/rsh $wifi.$wifi_domain show dot11 associations|sed "s//<br>/g">>$wifi_html
    fi
  done
  ;;
'centurion_update')
  centurion_update
  ;;
'backup_cisco')
      conf_file="$testsystem/$param.conf"
      if [ -r $conf_file ];then
        . $conf_file
        backup_cisco
       else
        $testsystem/daemon_pager.sh "Not found $conf_file" "1"
      fi
  ;;
'virus_check_www')
      virus_check_home
  ;;
'virus_check_home')
      virus_check_home
  ;;
'process_monitor')
      ps -axuww|logger -t sysinfo
  ;;
'pppoe_link')
      pppoelink $param
  ;;
'net_test')
  int="net0"
  test_ip="192.168.11.10 192.168.11.15 192.168.11.17"
  livep="Error"
  for ip in $test_ip
  do
    if [ ! -z "`ping -c 4 -t 4 $ip 2>&1 | grep time`" ];then
      livep=""
      break
    fi
  done
  if [ ! -z "$livep" ];then
    $testsystem/daemon_pager.sh "Interface $int lock ..." 1
    ifconfig $int down
    sleep 1
    ifconfig $int up
    $testsystem/daemon_pager.sh "Interface $int is restarted ..." 1
  fi
  ;;
*)
  echo "Error: $command"
  echo "Usage: [ mount_fs|mount_info|mount_distrib|ats|free_disk|fsnp|dvb|route|proxy|cons|ups|ups_snmp|quota|home|smb|wins|test_link|rinetd|del_dir|spam|ave|kav|radiusd|dhcpd|lpd|named|rinetd|daemon|rsync|apache_home_log_del|mysql_chown|videocam|backup_firebird_home|backup_mysql_home|test_http_link|raid_status|centurion_update|process_monitor ]"
  ;;
esac

exit 0
##### file complit testsystem #####
