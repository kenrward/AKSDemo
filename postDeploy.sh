#!/bin/bash
export AZURE_STORAGE_ACCOUNT=qtru3jpv6vtjmm5s

# MongoDB Install
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org=4.2.18 mongodb-org-server=4.2.18 mongodb-org-shell=4.2.18 mongodb-org-mongos=4.2.18 mongodb-org-tools=4.2.18 --allow-unauthenticated
sudo systemctl start mongod
# Mongo set file perms
sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo chown mongodb:mongodb /tmp/mongodb-27017.sock    
# Mongo Open BindIp
sudo sed 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
# Mongo Create data folder, set perms
sudo mkdir -p /data/db/
sudo chown $(id -u) /data/db

sudo service mongod restart
# sudo systemctl status mongod


# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Log in using MI
az login --identity

## Setup Backups

DATETIME=`date +"%Y-%m-%d-%H-%M-%S"`

FILENAME="bac"
MONGO_HOST="mongodbvm-u3jpv6vtjmm5s.eastus.cloudapp.azure.com"
MONGO_DB="example_db"
MONGO_URI="mongodb://mongodbvm-u3jpv6vtjmm5s.eastus.cloudapp.azure.com:27017/"

BACKUP_NAME="$FILENAME-$MONGO_DB-$DATETIME"
BACKUP_FOLDER="/tmp/demoBackup/"
AZURE_CONTAINER="newbackup"

make_backup() {

  mkdir "$BACKUP_FOLDER"

  if [[ -n "$MONGO_URI" ]]; then
    mongodump --uri $MONGO_URI -o $BACKUP_FOLDER
  else
    # if 'MONGO_DB' is empty then backup all databases
    if [[ -n "$MONGO_DB" ]]; then
      mongodump -h $MONGO_HOST -d $MONGO_DB -o $BACKUP_FOLDER
    else
      mongodump -h $MONGO_HOST -o $BACKUP_FOLDER
    fi
  fi

  tar -zcvf $BACKUP_NAME.tgz $BACKUP_FOLDER
}

upload_backup() {

  # Create container if it doesn't exist yet (upload fails otherwise)
  # set +e
  grep -wq $AZURE_CONTAINER <<< $(az storage container list  --auth-mode login)
  CONTAINER_EXISTS=$?
  # set -e
  if [ "$CONTAINER_EXISTS" -gt "0" ]; then
    az storage container create -n $AZURE_CONTAINER --auth-mode login
  fi

  az storage blob upload -f $BACKUP_NAME.tgz -n $BACKUP_NAME.tgz -c $AZURE_CONTAINER  --auth-mode login

}

make_backup
upload_backup
   