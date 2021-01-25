#!/bin/bash
##Manually make changes on your windows scripts and copy to your container env.
##copy backups to Docker mountpoint
echo "Copy Backups step#1 $(date +"%Y_%m_%d_%I_%M_%p")" >> "operations_$(date +"%Y_%m_%d_%I").log"
cp -v /mnt/c/Users/Beralios/Desktop/SQLBackups/* \
 /mnt/wsl/docker-desktop-bind-mounts/Ubuntu-20.04/2f12bd6eb0b585cd99d53c4c02567182704ba97379eeddcd19c768516fefe84b\
 >> "operations_$(date +"%Y_%m_%d_%I").log"
##copy Scripts to Docker mountpoint
echo "Copy Scripts step#2 $(date +"%Y_%m_%d_%I_%M_%p")" >> "operations_$(date +"%Y_%m_%d_%I").log"
cp -v /mnt/c/Users/Beralios/Desktop/Query/* \
/mnt/wsl/docker-desktop-bind-mounts/Ubuntu-20.04/2f12bd6eb0b585cd99d53c4c02567182704ba97379eeddcd19c768516fefe84b\
 >> "operations_$(date +"%Y_%m_%d_%I").log"


##Giving permissions to the files in the destiny path
echo "Granting Permissions step#3 $(date +"%Y_%m_%d_%I_%M_%p")" >> "operations_$(date +"%Y_%m_%d_%I").log"
chmod -v 777 \
/mnt/wsl/docker-desktop-bind-mounts/Ubuntu-20.04/2f12bd6eb0b585cd99d53c4c02567182704ba97379eeddcd19c768516fefe84b\
 >> "operations_$(date +"%Y_%m_%d_%I").log"

#Compress our backups for the iteration
cd /mnt/wsl/docker-desktop-bind-mounts/Ubuntu-20.04/2f12bd6eb0b585cd99d53c4c02567182704ba97379eeddcd19c768516fefe84b
echo "Compressing Backups Used step#4 $(date +"%Y_%m_%d_%I_%M_%p")" >> "operations_$(date +"%Y_%m_%d_%I").log"
tar -cvf "iteration_$(date +"%m-%d-%y").tar" *.bak >> "operations_$(date +"%Y_%m_%d_%I").log"
