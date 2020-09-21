#!/bin/bash

# install git
sudo apt install -y git

# change dir
cd /home/yc-user

# clone repo from github
git clone -b monolith https://github.com/express42/reddit.git

# bundle reddit
cd reddit && bundle install

# start reddit
puma -d
