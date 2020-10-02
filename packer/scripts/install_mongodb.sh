#!/bin/bash

# add repository key
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -

# add mongodb repository
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sleep 3m
# update list packages
apt-get update

# install mongodb
apt-get install -y mongodb-org

# start and enable mongodb service
systemctl start mongod
systemctl enable mongod
