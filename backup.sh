#! /bin/bash
#########################
## Author : Oguz BALKAYA
## Description : This script uses to backup all home directory of users.
## Date : 26-05-2022
## Version : 1.0
#########################

# Configurations
source ./backup.conf



create_cronjob(){
	#This function creates cronjob to run this script everyday at 23.05, if it doesn't exist.
        full_path=`realpath $0`
        crons=`crontab -l 2>&1`
        if [[ $crons != *"$full_path"* ]]; then
                cron="05 23 * * * $full_path"
		(crontab -l ; echo "$cron") | crontab - >> /dev/null
        fi
}



cat /etc/passwd | awk -F: '$3>=1000 {print $1,$6}' | while read OUTPUT
do
        user=`echo $OUTPUT | awk  '{print $1}'`
        home_directory=`echo $OUTPUT | awk '{print $2}'`
        user_md5=`echo $user | md5sum`
	now=`date +"%m%d%Y_%H%M"`
	backup_name="${user}_${now}.tar.gz"
	md5_file_name="${user}_${now}.tar.gz.md5.txt"		

	#Creating archive file
	tar -czf $DEST_DIR/$backup_name $home_directory 2&> /dev/null 

	#Creating md5 file
	echo $user_md5 > "$DEST_DIR/$md5_file_name"

done

#Last run log
date +"%m-%d-%Y %H:%M" > "$LOG_DEST_DIR/$LAST_RUN_NAME" 

create_cronjob
