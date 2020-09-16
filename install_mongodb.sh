#!/bin/bash

# add repository key
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -

# add mongodb repository
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list

# update list packages
sudo apt update

# install mongodb
sudo apt-get install -y mongodb-org

# start and enable mongodb service
sudo systemctl start mongod
sudo systemctl enable mongod
