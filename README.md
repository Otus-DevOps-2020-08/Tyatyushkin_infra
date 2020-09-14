# Tyatyushkin_infra
Tyatyushkin Infra repository

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
