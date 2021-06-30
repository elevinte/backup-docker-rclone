#!/bin/bash

BACKUPDIR="/home/elevinte/backup/docker/volumes"
cd "${BASH_SOURCE%/*}" || exit

if [ ! -d "$BACKUPDIR" ];then
mkdir -p $BACKUPDIR/
fi

clone=/home/elevinte/rclone/rclone
logs=/home/elevinte/.rclone.conf
DATE=$(date +%Y-%m-%d)
TIME=$(date +%T)

VOLUME=$(sudo docker volume ls -q)
echo -e "\n Start Backup for Volumes at $DATE $TIME:\n"

for i in $VOLUME; do 
	echo -e " Backup du Volume:\n  * $i"; 
	sudo docker run --rm \
        -v $BACKUPDIR:/backup \
        -v $i:/data:ro \
	-e DATE=$DATE \
	-e i=$i	${MEMORYLIMIT} \
	--name volumebackup \
        alpine sh -c "cd /data && /bin/tar -czf /backup/$i-$DATE.tar.gz ."
	#alpine sh -c "cd /data && gzip > /backup/$i-$DATE.tar.gz "


	$clone copy "$BACKUPDIR/$i-$DATE.tar.gz" azure:docker/volumes --log-file $logs --log-level DEBUG
	TIME2=$(date +%T)	

done
echo -e "\n Backup for Volumes completed at $DATE $TIME2 \n"

#mail -s "Cron - Weekly Azure Backup Volumes $DATE $TIME2 "  admin@idealgo.ca < $logs