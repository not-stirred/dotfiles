#!/bin/bash
###################################################################################################################
# Script to back up Bitwarden_rs db and attachments with rclone. Overall, this script should be preferred to
# bitwarden-backup.sh because it backs up all users and does not need to be run interactively.
# Note that this script does not encrypt the backup because Bitwarden stores it already encrypted.
# 
# This script is specific to my setup. It had to have some workarounds due to permissions issues and other things.
# Please test it before you try it!
#
# Requirements:
#   sqlite3
#   rclone
#
# Decryption and extraction:
#   gpg --output export.tar.gz --decrypt export.tar.gz.gpg
#   tar zxvf export.tar.gz
###################################################################################################################

#################### CONFIGURATION ####################

# Your rclone remote (can be found with "rclone listremotes")
rclone_remote=personal-gdrive

# Your rclone destination path (the directory where the backup will be saved)
rclone_path=bitwarden-server-backup

# The full path to the Bitwarden data directory
bw_data=/home/administrator/bitwarden

################ END OF CONFIGURATION #################

# Back up db + attachments
mkdir backup
sqlite3 $bw_data/db.sqlite3 ".backup 'backup/backup.sqlite3'"
cp -r $bw_data/attachments backup/attachments

# Create an archive
tar czf backup.tar.gz backup
rm -rf backup/

# Upload
sudo -u administrator rclone copy backup.tar.gz "$rclone_remote":"$rclone_path"
rm backup.tar.gz