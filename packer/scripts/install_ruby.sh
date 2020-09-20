#!/bin/bash

# Update package list
apt-get update
#remove blocking
echo "sleep 3m for install updates"; sleep 3m; echo 'sleep start install ruby'
# Install ruby packages
apt-get install -y ruby-full ruby-bundler build-essential
