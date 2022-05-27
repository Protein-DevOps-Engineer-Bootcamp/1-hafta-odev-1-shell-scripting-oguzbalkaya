#! /bin/bash
#########################
## Author : Oguz BALKAYA
## Description : This script checks disk usage.If disk usage is more than 90%, the script will send a mail.
## Date : 26-05-2022
## Version : 1.0
#########################

#Configoration file
source ./disk_alert.conf


create_cronjob(){
        #This function creates cronjob to run this script every minutes, if it doesn't exist.
        full_path=`realpath $0`
        crons=`crontab -l 2>&1`
        if [[ $crons != *"$full_path"* ]]; then
                cron="* * * * * $full_path"
                (crontab -l ; echo "$cron") | crontab - >> /dev/null
        fi
}



df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{print $5,$1}' | while read output
do
	usage=`echo $output | awk '{print $1}' | cut -d'%' -f1`
	partition=`echo $output | awk '{print $2}'`
	hostname=`hostname`
	now=`date -u`
	if [ $usage -ge 90 ]
	then
		echo "The partition \"$partition\" on $hostname has used $usage% at $now" | mail -s "$hostname Disk Usage Alert:$usage% used" $ADMIN_MAIL
	fi
done

create_cronjob
