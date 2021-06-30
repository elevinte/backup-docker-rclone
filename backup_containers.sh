#!/bin/bash

backup_path="/home/elevinte/backup/docker/conteneurs"

if [ ! -d "$backup_path" ];then
mkdir -p $backup_path/
fi


clone=/home/elevinte/rclone/rclone
logs=/home/elevinte/backup/rclone_log.log
DATE=$(date +%Y-%m-%d)
TIME=$(date +%T)


echo -e "\nBackup for Compose Projects started at $DATE $TIME \n"

#docker inspect.. fait la recherche des conteneurs existant 
for i in `sudo docker inspect --format='{{.Name}}' $(sudo docker ps -q) | cut -f2 -d\/`; do
		echo -e " Backup du Container: - $i";
		#Docker fait la recherche des images des conteneurs 
        container_image=`sudo docker inspect --format='{{.Config.Image}}' $i`
		#
       # save_file="$backup_path/$i-$DATE-image.tar.gz"
      #  sudo docker save -o $save_file $container_image
		sudo docker save  $container_image | gzip > "$backup_path/$i-$DATE-image.tar.gz"
		
		$clone copy "$backup_path/$i-$DATE-image.tar.gz" azure:conteneurs . --log-file $logs --log-level DEBUG
		
	TIME2=$(date +%T)	
done

echo -e "\n Backup for Compose Projects completed at $DATE $TIME2 \n"

mail -s "Cron - Weekly Azure Backup Con $DATE "  admin@idealgo.ca < $logs

