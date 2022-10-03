#!/bin/bash

# MongoDB
sudo mkdir -p /data/db/
sudo chown $(id -u) /data/db


echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org=4.2.18 mongodb-org-server=4.2.18 mongodb-org-shell=4.2.18 mongodb-org-mongos=4.2.18 mongodb-org-tools=4.2.18 --allow-unauthenticated
sudo systemctl start mongod
sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo chown mongodb:mongodb /tmp/mongodb-27017.sock    
sudo service mongod restart
# sudo systemctl status mongod

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Log in using MI
az login --identity
   