# Tyatyushkin_infra
Tyatyushkin Infra repository

## Основные сервисы Yandex Cloud

#### Выполненные работы

1. Создаем ветку **cloud-testapp**
```
git checkout -b cloud-testapp
```
2. Создаем папку VPN и переносим в нее файлы из прошлого занятия
```
mkdir VPN; git mv setupvpn.sh VPN/; git mv *.ovpn VPN/
```
3. Устанавливаем **yandex cli** и прозодим инициализацию
```
$ curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
yc init
```
4. Создаем VM
```
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --ssh-key ~/.ssh/appuser.pub
```
5. Заходим на vm по ssh *ssh yc-user@vm* и устанавливаем ruby
```
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential
```
6. Устанавливаем mongodb
```
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
```
7. Деплоим приложение предварительно установив git
```
sudo apt install -y git
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
```
8. Оборачиваем наши действия в скрипты: **install_ruby.sh**, **install_mongodb.sh**, **deploy.sh**
9. Создаем единый скрипт, который будет расскатываться при создании инстанса **startup.sh**
10. Существует несколько методов передачи метаданных через cloud-init, мы будем использовать user-data scripts, для этого добавляем в наш **startup.sh**, несколько строчек для создание пользователя, получение им sudo и проброса ключа.
```
# add user yc-user
adduser yc-user
mkdir -p /home/yc-user/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABA...r' > /home/yc-user/.ssh/authorized_keys
echo 'yc-user  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
```
11. Теперь наша команда по созданию инстанса и деплою приложения выглядит так:
```
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --metadata-from-file user-data=startup.sh
```
12. Проверить приложение можно по:
```
testapp_IP = 130.193.36.118
testapp_port = 9292
```

---
## Знакомство с облачной инфраструктурой

#### Выполненные работы

1. Создание учетной записи в *yandex cloud*
2. Создаем новую ветку *cloud-bastion*
3. Создаем каталог Otus infra
4. Создаем VM bastion и someinternalhost(без внешнего интерфейса)
5. Испольуем bastion для сквозного подключения
```
ssh -i ~/.ssh/appuser -A appuser@bastion
ssh someinternalhost
```
6. Подключение одной командой
```
ssh -A -t appuser@bastion  ssh someinternalhost
```
7. Дополнительный вариант подключения через ssh алиасы
```
cat ~/.ssh/config
Host bastion
  User appuser
  Hostname bastionIP
  ForwardAgent yes

Host someinternalhost
  ForwardAgent yes
  Hostname someinternalhostIP
  User appuser
  ProxyCommand ssh bastion -W %h:%p
```
8. Создаем VPN сервер с помощью скрипта *setupvpn.sh*
9. При возниконовении проблем с подключением iptables
```
apt install iptables
```
10. Конфигурируем VPN сервер(создаем пользователя test и организацию)
11. Подписываем сертификат с помощью sslip.io, указав в параметра bastionIP.sslip.io

bastion_IP = 130.193.48.172
someinternalhost_IP = 10.130.0.28

## Play Travis and ChatOps

#### Выполненные работы

1. Клонируем репозиторий и создаем ветку *play-travis*
```
git clone git@github.com:Otus-DevOps-2020-08/Tyatyushkin_infra.git
cd Tyatyushkin_infra
git checkout -b play-travis
```
2.  Добавление *PULL_REQUEST_TEMPLATE.md* и хука *pre-commit*
```
mkdir .github; cd .github; wget http://bit.ly/otus-pr-template -O PULL_REQUEST_TEMPLATE.md
brew install pip
pip install pre-commit
```
3. Создаем файл *.pre-commit-config.yaml*
```
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v2.3.0
    hooks:
    -   id: end-of-file-fixer
    -   id: trailing-whitespace
```
и запускаем установку
```
pre-commit install
```
4. Коммитим изменения и отправляем на GitHub
```
git add PULL_REQUEST_TEMPLATE.md
git add .pre-commit-config.yaml
git commit -m 'Add PR template'
git push --set-upstream origin play-travis
```
5. Создаем канал в Slack
6. Создаем директорю *play-travis* и скачиваем в эти директорию *test.py*
7. Создаем *.travis.yml*
```
dist: trusty
sudo: required
language: bash
before_install:
- curl https://raw.githubusercontent.com/express42/otus-homeworks/2020-08/run.sh | bash
```
8. Добавляем интеграцию со Slack
9. Коммитим изменения и исправляем ошибку
10. Делаем PR
