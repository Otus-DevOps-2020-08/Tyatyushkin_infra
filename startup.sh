#!/bin/bash

# add user yc-user
adduser yc-user
mkdir -p /home/yc-user/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDQEYK2Hn9IvQSV6nEhbLLHJIW/40eMAEgFgkKr0MXAM9s2bZVov5Sq4H1gApGa7hf0NsZxkjPnuM6Ras/daFZAR20igUs1vM6+XHxAEc622a++yjcy3d5wVh2eqYKZ88us9pzodat4LcW9+BFY3Q6dD4Mn+XpKYmK6MUGaKnJt/2qSFa4ksavhVN8qQYlhHT6VWzMzeQ735h0AWJTmUIrHS/l5utyklY9vCH4p2Hp7K3AaUef+O/2jncou0HIGviYVtp+AIQrqEtUVQNTr0pcO68ov7iIUxXZbK9UDuksatzPx8BDEILSFqG6kuhsam1KfdbE7QAYIeavCPa3LB4DVPBbNbRYkJ8eUw7Ba1rfZezfLhz19ImAekIMfVVLcIk167KzHNYaJKAPxMIp2CZeQ1dg8KQ/5B/SE3tsVqgMZGPR4z33ZeyrzqdGOKjTClmXqdbp+04hJsdDaoVFkOKx8rWHTcPkgp6UVuSd0lzOlYYsMVHi8T3K8j27cMOo/ky0= appuser' > /home/yc-user/.ssh/authorized_keys
echo 'yc-user  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Update package list
sudo apt update

# Install ruby packages
sudo apt install -y ruby-full ruby-bundler build-essential

# add repository key
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -

# add mongodb repository
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list

# update list packages
sudo apt update

# install mongodb
sudo apt-get install -y mongodb-org

# start and enable mongodb service
sudo systemctl start mongod
sudo systemctl enable mongod

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
