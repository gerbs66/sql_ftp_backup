#!/bin/bash

############### Infos - Edit them accordingly  ########################

DATE=`date +%Y-%m-%d_%H%M`
LOCAL_BACKUP_DIR="/variable/variable/variable"
DB_NAME="variable"
DB_USER="variable"
DB_PASSWORD="variable"

FTP_SERVER="variable"
FTP_USERNAME="variable"
FTP_PASSWORD="variable"
FTP_UPLOAD_DIR="/variable/variable/"

LOG_FILE=/backups/backup-DATE.log

################## Delete backup file older than 7 days (local backup)########################
find $LOCAL_BACKUP_DIR/*.sql.tgz -mtime +7 -exec rm {} \;

############### Local Backup  ########################

mysqldump --user=$DB_USER --password=$DB_PASSWORD --compress --single-transaction --quick --lock-tables=false $DB_NAME > $LOCAL_BACKUP_DIR/$DATE-$DB_NAME.sql.tgz

############### UPLOAD to FTP Server  ################

ftp -nv $FTP_SERVER << EndFTP
user "$FTP_USERNAME" "$FTP_PASSWORD"
binary
cd $FTP_UPLOAD_DIR
lcd $LOCAL_BACKUP_DIR
put "$DATE-$DB_NAME.sql.tgz"
bye
EndFTP

############### Check and save log, also send an email  ################

if test $? = 0
then
    echo "Database Successfully Uploaded to the Ftp Server!"
###    echo "Database successfully created and uploaded to the FTP Server" | mail -s 'Backup from '$DATE email@email.com

else
    echo "Error in database Upload to Ftp Server" > $LOG_FILE
fi
