[![Build Status](https://travis-ci.com/Otus-DevOps-2020-08/Tyatyushkin_infra.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2020-08/Tyatyushkin_infra)

# Tyatyushkin_infra
Tyatyushkin Infra repository
---
## Работа с ролями и окружениями Ansible
#### Выполненные работы

1. Создаем ветку **ansible-3**
2. С помощью **ansible-galaxy** создаем заготовки пол роли
```bash
ansible-galaxy init app
ansible-galaxy init db
```
3. Переводим наши плейбуки в роли
4. Модифицируем плейбуки на запуск ролей
```
---
- name: Configure MongoDB
  hosts: db
  become: true


  roles:
    - db
```
5. Проверяем фунцкионал ролей
```bash
ansible-playbook site.yml
```
6. Модифицируем **ansible.cfg** и вводим переменные окружения для сред **prod** и **stage**
7. Организуем плейбуки согласно **Best Practices**
8. Учимся использовать комьюнити роли на примере **jdauphant.nginx**
9. Учимся использовать **ansible-vault**
10. Проверяем функционал

#### Задание со ⭐
1. Для использования динамического инвентори модифицируем **ansible.cfg**
2. Копируем **inventory.json** из директории old  в наши окружения
```bash
cp old/inventory.json environment/stage/
cp old/inventory.json environment/stage/
```
3. Модифицируем **inventory.json** изменим переменную с db_ip на **db_host**
```
...
"vars": {
  "db_host": "$db_ip"
}
...
```
4. Так как у групповой переменной переменной **db_host** приоритет выше закомментируем ее в **group_vars/app**
5. Проверяем все успешно
6. Для прохожденим валидации в **travis** копируем наш **inventory.json** в **inventory.sh**
7. Убираем из **inventory.json** всю подготовительную часть
8. Валидация в **travis** пройдена

#### Задание со ⭐⭐
1. Модифицируем наш **.travis.yml**
2. Добавляем проверку **packer**, в системе присутвует packer, но старая версия в которой нет яндекс провайдера, поэтому нам необходимо закачать дистрибутив и выполннить проверки.
```
...
- wget https://releases.hashicorp.com/packer/1.6.5/packer_1.6.5_linux_amd64.zip
- sudo unzip -o packer_1.6.5_linux_amd64.zip -d /usr/local/bin
- /usr/local/bin/packer validate -var-file=packer/variables.json.example packer/app.json
- /usr/local/bin/packer validate -var-file=packer/variables.json.example packer/db.json
- cd packer
- /usr/local/bin/packer validate -var-file=variables.json.example ubuntu16.json
- /usr/local/bin/packer validate -var-file=variables.json.example immutable.json
...
```
3. Для проверки **terraform** нужно скачать **tflint**, как и сам терраформ
```
...
- wget https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip
- sudo unzip terraform_0.12.18_linux_amd64.zip -d /usr/local/bin
- curl -L "$(curl -Ls https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" -o tflint.zip && unzip tflint.zip && rm tflint.zip
- sudo mv tflint /usr/local/bin
- cd ../terraform/stage && mv backend.tf backend.tf.example && terraform init && terraform validate
- tflint
- cd ../prod && mv backend.tf backend.tf.example && terraform init && terraform validate
- tflint
...
```
4. Для проверки **ansible** нам нужен **ansible-lint**, для того чтобы все работало, необходимо указывать более старую версию пакетов.
```
...
- curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
- sudo python get-pip.py
- sudo pip install cryptography==2.2.2
- sudo pip install ansible==2.6
- sudo pip install ansible-lint==3.5.0
- ansible-lint playbooks/deploy.yml
- ansible-lint playbooks/clone.yml
- ansible-lint playbooks/db.yml
- ansible-lint playbooks/packer_app.yml
- ansible-lint playbooks/packer_db.yml
- ansible-lint playbooks/reddit_app_one_play.yml
- ansible-lint playbooks/reddit_app_multiple_plays.yml
- ansible-lint playbooks/users.yml
- ansible-galaxy install -r environments/stage/requirements.yml
- ansible-lint playbooks/app.yml --exclude=roles/jdauphant.nginx
- ansible-lint playbooks/site.yml --exclude=roles/jdauphant.nginx
...
```
5. Добавляем в **README.md** бейдж со статусом билда

---
## Деплой и управление конфигурацией с Ansible
#### Выполненные работы:

1. Создаем ветку **ansible-2**
2. Создаем плейбук **reddit_app.yml**  заполняем его и тестируем
3. Создаем плейбук на несколько сценариев **reddit_app2.yml**
4. Разбиваем наш плейбук на несколько: **app.yml**, **db.yml**, **deploy.yml** и переименовываем наши старые плейбуки
5. Модифицируем наши провижионеры в packer, меняеем их на ansible и перезапекаем образы, указываем новые образы в переменных терраформа.

#### Задание со ⭐⭐
1. Для задания со звездочкой мы снова модифицируем **ansible.cfg**
```
[defaults]
inventory = ./inventory.json
remote_user = ubuntu
private_key_file = ~/.ssh/appuser
host_key_checking = False
retry_files_enabled = False

[inventory]
enable_plugins = script
```
2. Теперь модифицируем наш **inventory.json**. Добавляем в него новую переменную **db_ip**  в которую записывается адрес базы данных и делаем так чтобы наши группы соответсвовали тем что в плейбуках.
```bash
#!/bin/bash

server1ip=$(yc compute instances list | awk '{print $10}' | sed '/^[[:space:]]*$/d' |  sed  '1d' | head -1)
server1host=$(yc compute instances list | awk '{print $4}' | sed '/^[[:space:]]*$/d' |  sed  '1d' | head -1| tr - _)
server2ip=$(yc compute instances list | awk '{print $10}' | sed '/^[[:space:]]*$/d' |  sed  '1d' | tail -1)
server2host=$(yc compute instances list | awk '{print $4}' | sed '/^[[:space:]]*$/d' |  sed  '1d' | tail -1| tr - _)

if [ "${server1host:7}" == "db" ]; then
  db_ip=$server1ip
else
  db_ip=$server2ip
fi



if [ "$1" == "--list" ] ; then
cat<<EOF
{
  "${server1host:7}": {
  "hosts": ["$server1ip"],
  "vars": {
    "db_ip": "$db_ip"
  }
  },
  "${server2host:7}": {
    "hosts": ["$server2ip"],
    "vars": {
      "db_ip": "$db_ip"
    }
  },
  "_meta": {
  "hostvars": {
    "$server1ip": {
    "host_specific_var": "$server1host"
    },
    "$server2ip": {
    "host_specific_var": "$server2host"
    }
  }
  }
}
EOF
elif [ "$1" == "--host" ]; then
  echo '{"_meta": {"hostvars": {}}}'
else
  echo "{ }"
fi

```
3. Теперь передаем нашу переменную в **app.yml**
```
  vars:
   db_host: "{{db_ip}}"
```
4. Запускаем и проверяем, все работает.
5. Чтобы пройти проверку у тревиса, возвращаем ansible.cfg в исходное состоянием и добавляем в инвентори переменную db_ip.

---
## Знакомство с Ansible
#### Выполненные работы:

1. Создаем ветку **ansible-1**
2. Устанавлием Ansible. В лекции есть реккомендация ставить ansible через pip, поэтому создаем **requirements.txt**, но ставить будем с помощью **brew**
```
brew install ansible
```
3. Создаем каталог **ansible** и собираем терраформом окружение **stage**
4. Из данных полученных в **output** создаем **inventory** файл в каталоге ansible и проверяем доступность хостов модулем **ping**
```
ansible appserver -i ./inventory -m ping
```
5. Создаем файл конфигурации **ansible.cfg** чтобы убрать некоторые параметры из инвентори и упростить работу с ansible
6. Формируем инвентори в yml-формате: **inventory.yml**
7. Изучаем новые модули для работы с ансиблом и учим слово **идемпотентность**
8. Пишем первый **playbook**, **clone.yml**
```yml
---
- name: Clone
  hosts: app
  tasks:
    - name: Clone repo
      git:
        repo: https://github.com/express42/reddit.git
        dest: /home/ubuntu/reddit

```
#### Задание со ⭐⭐
1. Нам необходимо создать инвентори в формате json, поэтому первым делом создадим файлик **inventory.json**
```
touch inventory.json
```
2. По условию задачи нельзя использовать модули и файл не должен быть статическим, но и до конца динамическим он быть не может, поэтому буду называть его **полудинамический**. Для реализации этого файла, можно использовать выгрузку из terraform сформировав template, но я выбрал другую реализацию.
3. Находим [шаблон](https://gist.github.com/tuxfight3r/2c027f8fd70333a8288e) для динамического инвентори на bash и копируем в наш **inventory.json**
```
#!/bin/bash

if [ "$1" == "--list" ] ; then
cat<<EOF
{
  "bash_hosts": {
  "hosts": [
    "10.220.21.24",
    "10.220.21.27"
  ],
  "vars": {
    "host_proxy_var": "proxy2"
  }
  },
  "_meta": {
  "hostvars": {
    "10.220.21.24": {
    "host_specific_var": "towerhost"
    },
    "10.220.21.27": {
    "host_specific_var": "testhost"
    }
  }
  }
}
EOF
elif [ "$1" == "--host" ]; then
  echo '{"_meta": {"hostvars": {}}}'
else
  echo "{ }"
fi
```
4. Нам нужны переменные, чтобы заменить дефольные параметры и сделать инвентори **полудинамическим**, для этого я решил исполльзовать комманду **yc compute instances list** , а затем распарсить и выдрать оттуда необходимые значения.
```
server1ip=$(yc compute instances list | awk '{print $10}' | sed '/^[[:space:]]*$/d' |  sed  '1d' | head -1)
server1host=$(yc compute instances list | awk '{print $4}' | sed '/^[[:space:]]*$/d' |  sed  '1d' | head -1| tr - _)
server2ip=$(yc compute instances list | awk '{print $10}' | sed '/^[[:space:]]*$/d' |  sed  '1d' | tail -1)
server2host=$(yc compute instances list | awk '{print $4}' | sed '/^[[:space:]]*$/d' |  sed  '1d' | tail -1| tr - _)
```
5. Заменяем дефолтные значения нашими переменными и делаем файл исполняемым, затем идем править **ansible.cfg**, чтобы все что мы нагородили заработало:
```
[defaults]
inventory = ./inventory.json
remote_user = ubuntu
private_key_file = ~/.ssh/appuser
host_key_checking = False
retry_files_enabled = False

[inventory]
enable_plugins = script
```
6. Проверяем, все работает. Но для прохождения валидации в travis возвращаем предыдущие параметры.

---
##  Работа с Terraform, принципы организации инфраструктурного кода и работа над инфраструктурой в команде.
#### Выполненные работы:

1. Создаем ветку **terraform-2** и подичищаем результат заданий со звездочкой:
```bash
git checkout -b terraform-2; git mv terraform/lb.tf terraform/files/
```
2. Создадим IP для внешнего ресурса с поомщью **yandex_vpc_network** и **yandex_vpc_subnet**, для этого добавляем в **main.tf** следующие строки:
```
resource "yandex_vpc_network" "app-network" {
  name = "reddit-app-network"
}

resource "yandex_vpc_subnet" "app-subnet" {
  name           = "reddit-app-subnet"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.app-network.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}
```
3. Добавляем упоминание о созданных сетевых ресурсах в код создания инстанса:
```
  network_interface {
    subnet_id = yandex_vpc_subnet.app-subnet.id
    nat = true
  }
```
4. Пересоздаем и проверяем как работают неявные зависимости:
```bash
terraform destroy --auto-approve; terraform plan; terraform apply --auto-approve
```
5. Создаем 2 новых шаблона для packer **app.json** и **db.json** на базе уже имеющегося **ubuntu16.json**
```
cp packer/ubuntu16.json packer/app.json; cp packer/ubuntu16.json packer/db.json
```
редактируем полученные файлы, оставляя каждом необходимый провижионер и поменян некоторые параметры
```
...
            "image_name": "reddit-app-base-{{timestamp}}",
            "image_family": "reddit-app-base",
...
            "disk_name": "reddit-app-base",
...
```
6. Запекаем образы
```bash
packer validate -var-file=./variables.json ./app.json
packer build -var-file=./variables.json ./app.json
packer validate -var-file=./variables.json ./db.json
packer build -var-file=./variables.json ./db.json
```
7. Разбиваем **main.tf** на части создав **app.tf** и **db.tf**, а так же выносим в отдельный файл описание сети **vpc.tf**.
Для начала определим новые переменные:
```
variable app_disk_image {
  description = "disk image for reddit app"
  default     = "reddit-app-base"
}
variable db_disk_image {
  description = "disk image for mongodb"
  default     = "reddit-db-base"
```
и обозначим их
```
app_disk_image            = "reddit-app-base"
db_disk_image             = "reddit-db-base"
```
вынесем описание ресурсов например **app.tf**
```
resource "yandex_compute_instance" "app" {
  name = "reddit-app"

  labels = {
    tags = "reddit-app"
  }
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.app_disk_image
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.app-subnet.id
    nat = true
  }

  metadata = {
  ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}
```
оставив в **main.tf** только
```
provider "yandex" {
  version                  = "~> 0.43"
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}
```
правим **outputs.tf**
```
output "external_ip_address_app" {
  value = yandex_compute_instance.app.network_interface.0.nat_ip_address
}
output "external_ip_address_db" {
  value = yandex_compute_instance.db.network_interface.0.nat_ip_address
}
```
8. Проверяем работу
```bash
terraform destroy --auto-approve; terraform plan; terraform apply --auto-approve
```
9. Создаем модульную инфраструктуру. Создаем папку **modules** внутри папки  **terraform**
```
mkdir modules
```
теперь на необходимо создать папки для наших модулей
```
mkdir app; mkdir db
```
и в кажддом из модулей создаем знакомую нам структуру из **main.tf**, **outputs.ft** и **variables.tf**
```
variable public_key_path {
  description = "Path to the public key used for ssh access"
}
  variable db_disk_image {
  description = "Disk image for reddit db"
  default = "reddit-db-base"
}
variable subnet_id {
description = "Subnets for modules"
}
```
outputs.tf
```
output "external_ip_address_app" {
  value = yandex_compute_instance.app.network_interface.0.nat_ip_address
}
```
удаляем из дириктории **app.tf**, **db.tf** и **vpc.tf**
```
rm app.tf; rm db.tf; rm vpc.tf
```
укащываем в **main.tf** исользование модулей
```
module "app" {
  source          = "./modules/app"
  public_key_path = var.public_key_path
  app_disk_image  = var.app_disk_image
  subnet_id       = var.subnet_id
}

module "db" {
  source          = "./modules/db"
  public_key_path = var.public_key_path
  db_disk_image   = var.db_disk_image
  subnet_id       = var.subnet_id
}
```
правим **outputs.tf**
```
output "external_ip_address_app" {
  value = module.app.external_ip_address_app
}
output "external_ip_address_db" {
  value = module.db.external_ip_address_db
}
```
загружаем модули
```
terraform get
```
и пробуем все собрать
```
terraform plan; terraform apply --auto-approve
```
10. Переиспользование модулей. Для этого необходимо создать среды **prod** и **stage**
```
mkdir prod; mkdir stage
```
копируем в эти каталоги наши основные рабочией файлы
```
cp main.tf prod/; cp outputs.tf prod/; cp variables.tf prod/; cp terraform.tfvars prod/
```
анологично делаем и для **stage**,  и корректируем **main.tf**
```
provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}
module "app" {
  source          = "../modules/app"
  public_key_path = var.public_key_path
  app_disk_image  = var.app_disk_image
  subnet_id       = var.subnet_id
}

module "db" {
  source          = "../modules/db"
  public_key_path = var.public_key_path
  db_disk_image   = var.db_disk_image
  subnet_id       = var.subnet_id
}
```
корректируем синтаксис
```
terraform fmt
```
и проверяем на каждом стенде
```
terraform init; terraform apply --auto-approve
```
#### Задание со ⭐⭐
1. Использование внешнего backend. Яндекс использует хранилища формата S3, для создания бакета нем необходимы **key_id** и **secret_id**, получить их можно командой:
```
yc iam access-key create --service-account-name terraform
```
обозначаем полученные данные в переменных
```
variable access_key {
  description = "key id"
}
variable secret_key {
  description = "secret key"
}
variable bucket_name {
  description = "bucket name"
}
```
и параметризуем переменные, для использование баккета как хранилища бекэнжа, нам нужно его создать до terraform init, поэтому в каталоге terraform создаем **storage-backet.tf**
```
provider "yandex" {
  version                  = "~> 0.43"
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_storage_bucket" "tyatyushkin" {
  bucket        = var.bucket_name
  access_key    = var.access_key
  secret_key    = var.secret_key
  force_destroy = "true"
}
```
добавив опцию force_destroy для удаления баккета после использования, и создаем bucket
```
terraform apply --auto-approve
```
затем в каждой из сред создаем **backend.tf** для указания бекэнда, например prod
```
terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "tyatyushkin"
    region     = "ru-central1"
    key        = "prod/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
   }
}
```
пробуем. Теперь наш *tfstate* лежит в хранилище мы можешь удалить локальное и проверить запуск.
Все работет!, блокировки тоже работают если одноврменное запускать создание инстансов так как у s3 есть такая возможность.
```
terraform init; terraform apply --auto-approve
```
2. Настраиваем deploy приложения: для начала нужно в каждом из модулей создать каталог files где будут хранится наши конфиги и скрипты.
```
mkdir modules/app/files; mkdir modules/db/files
```
Создаем темплейт **puma.service.tmpl** конфига для нашего приложения добавив адресс для подключения к базе
```
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=ubuntu
Environment=DATABASE_URL=${db_ip}
WorkingDirectory=/home/ubuntu/reddit
ExecStart=/bin/bash -lc 'puma'
Restart=always

[Install]
WantedBy=multi-user.target
```
мы используем переменную db_ip, но к ней мы вернемся позже, сам скрипт deploy.sh ничем не отличается использованных ранее поэтому будем использовать его. Теперь модифицируем **main.tf** добавив провижионеры.
```
 connection {
    type        = "ssh"
    host        = yandex_compute_instance.app.network_interface[0].nat_ip_address
    user        = "ubuntu"
    agent       = false
    private_key = file(var.private_key_path)
  }
 provisioner "file" {
    content     = templatefile("${path.module}/files/puma.service.tmpl", { db_ip = var.db_ip})
    destination = "/tmp/puma.service"
  }

 provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }
```
Как видно здесь мы передаем параметр db_ip из переменной, поэтому опишем ее
```
variable db_ip {
  description = "database IP"
}
```
Чтобы получить значение переменной мы добавляем в **main.tf**
```
module "app" {
  source          = "../modules/app"
  public_key_path = var.public_key_path
  private_key_path = var.private_key_path
  app_disk_image  = var.app_disk_image
  subnet_id       = var.subnet_id
  db_ip           = module.db.db_internal_ip
}
```
так же передав значение приватного ключа для работы провижионеров, теперь нужно добавить в **db/outputs.ff** вывод внутреннего ip адреса
```
output "db_internal_ip" {
  value = yandex_compute_instance.db.network_interface.0.ip_address
}
```
Пробуем собрать, сборка проходит корректно но у нас в ошибка в web подключение к базе данных, заходим на машину app и проверяем, все корректно сервис пытается подключаться к базе по нужному адресу, но подключения отбрасываются. Создаем в db/files/ **mongod.conf.tmpl**
```
...
# network interfaces
net:
  port: 27017
  bindIp: ${db_ip}
...
```
Указав адресс для работы, теперь создадим скрипт который будет подкидывать наш конфиг **deploy.sh**
```
#!/bin/bash

sudo mv -f /tmp/mongod.conf /etc/mongod.conf
sudo systemctl restart mongod
```
и добавим провижионеры в наш файл в db **main.tf**
```
 connection {
    type        = "ssh"
    host        = yandex_compute_instance.db.network_interface[0].nat_ip_address
    user        = "ubuntu"
    agent       = false
    private_key = file(var.private_key_path)
  }
    provisioner "file" {
    content     = templatefile("${path.module}/files/mongod.conf.tmpl", { db_ip = yandex_compute_instance.db.network_interface.0.ip_address})
    destination = "/tmp/mongod.conf"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }
```
Проверяем и видим что теперь все корректно
```
terraform destroy --auto-approve; terraform apply --auto-aprove
```
3. Добавляем возможность отключать провижионеры по значению переменной. Создадим эту переменную
```
variable prov {
  description = "using provisioner"
  default = true
}
```
будем использовать булевое значение, добавляем эту переменную в **main.tf** для обоих инстансов
```
prov            = var.prov
```
Модифицируем модули для наших задач, я буду испольщовать **null_resources** c **count**, добавляем этот ресурс и задаем значение для count:
```
resource "null_resource" "app" {
  count = var.prov ? 1 : 0
  triggers = {
    cluster_instance_ids = yandex_compute_instance.app.id
  }
```
и выносим сюда все провижионеры, аналогично делаем и для **db**, проверяем выставляя разные значения для **prov**, все работает корректно.

---
## Знакомство с Terraform
#### Выполненные работы

1. Создаем ветку **terraform-1** и устанавливаем дистрибутив Terraform
```bash
git checkout -b terraform-1
wget wget https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_darwin_amd64.zip
unzip wget https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_darwin_amd64.zip
sudo mv terraform /usr/local/bin; rm terraform_0.12.29_darwin_amd64.zip
terraform -v
Terraform v0.12.29
```
2. Создаем каталог **terraform** с **main.tf** внутри и добавляем исключения в **.gitignore**
```bash
mkdir terraform; touch terraform/main.tf
cat .gitignore
...
### Terraform files
*.tfstate
*.tfstate.*.backup
*.tfstate.backup
*.tfvars
.terraform/
...
```
3. Создаем сервисный аккаунт и профиль для работы terraform
```bash
yc iam service-account create --name terraform --description "account for terraform"
yc resource-manager folder add-access-binding infra --role editor --subject serviceAccount:abcde
yc iam key create --service-account-name terraform --output $HOME/devops/terraform.json
yc config profile create terraform
yc config set folder-id bcdef
yc config set service-account-key $HOME/devops/terraform.json
```
Экспортируем переменную **YC_SERVICE_ACCOUNT_KEY_FILE**
```
cat ~/.zshrc
...
export YC_SERVICE_ACCOUNT_KEY_FILE=$HOME/devops/terraform.json
...
```
4. Редактируем **main.tf** и проводим инцициализацию
```
cat main.tf
provider "yandex" {
  cloud_id  = "abcdef"
  folder_id = "bcdefg"
  zone      = "ru-central1-a"
}
```
```
terraform init
```
5. Создаем инстанс с помощью **terraform**
Заполняем main.tf конфигурацией из задания и делаем
```
terraform plan
```
затем
```
terraform apply
```
у нас возникает ошибка
```
Error: Error while requesting API to create instance: server-request-id = 76bc9c1a-7e5f-b439-b97e-d497fe004f4b server-trace-id = b01c8f65b967fb64:ca4dd494e5960766:b01c8f65b967fb64:1 client-request-id = 89def97d-5027-43c9-b77d-9b96e0ee3ef6 client-trace-id = 70fba088-4a74-4cb0-9ab7-47d78b9fb330 rpc error: code = InvalidArgument desc = the specified number of cores is not available on platform "standard-v1"; allowed core number: 2, 4, 6, 8, 10, 12, 14, 16, 20, 24, 28, 32
```
меняем количество ядер в **main.tf**
```
...
  resources {
    cores  = 2
    memory = 2
  }
  ...
```
И пробуем еще раз
```
terraform apply
...
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
6. Провряем подключение и создаем **outputs.tf**.
``` bash
ssh-add ~/.ssh/yc
ssh ubuntu@ip
```
не получилось?
добавлаем строчки в наш **main.tf**
```
resource "yandex_compute_instance" "app" {
...
  metadata = {
  ssh-keys = "ubuntu:${file("~/.ssh/yc.pub")}"
  }
...
}
```
и пересоздаем
```
terraform destroy -auto-approve
terraform apply -auto-approve
```
пробуем
```
ssh ubuntu@ip
```
все работает, теперь создаем **outputs.ts** для вывода внешнего IP
```
cat outputs.tf
output "external_ip_address_app" {
  value = yandex_compute_instance.app.network_interface.0.nat_ip_address
}
```
проверяем
```
terraform refresh
terraform output
external_ip_address_app = 8.8.8.8
```
7. Настраиваем провижионеры, заливаем подготовленный за ранее puma.service на создаваемый инстанс для этого добавляем в **main.tf** провижионер file:
```
  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }
  ```
  для запуска приложения используем скрипт **deploy.sh**, для которого используем remote-exec
  ```
    provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
  ```
  для подключения используем  connection
  ```
    connection {
    type  = "ssh"
    host  = yandex_compute_instance.app.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file("~/.ssh/yc")
  }
  ```
для того чтобы наши изменения применились
```
terraform taint yandex_compute_instance.app
terraform plan
terraform apply
```
8.  Использование input vars, для начала опишем наши переменные в **variables.tf**
```
...
variable cloud_id {
  description = "Cloud"
}
...
```
параметры для переменные записываем в **terraform.tfvars**
```
...
cloud_id  = "abv"
...
```
теперь указываем эти параметры в **main.tf**
```
cloud_id                 = var.cloud_id
```
И так делаем для других параметров, затем перепроверяем
```
terraform destroy -auto-approve
terraform apply -auto-approve
```

#### Задание со ⭐⭐
1. Создаем файл **lb.tf**
2. Первым делом нужно  создать *target group*, которую мы позже подключим к балансировщику
```terraform
resource "yandex_lb_target_group" "loadbalancer" {
  name      = "lb-group"
  folder_id = var.folder_id
  region_id = var.region_id

  target {
    address = yandex_compute_instance.app.network_interface.0.ip_address
      subnet_id = var.subnet_id
  }
}
```
2. Теперь необходимо создать сам балансировщик и указать для него целевую группу
```terraform
resource "yandex_lb_network_load_balancer" "lb" {
  name = "loadbalancer"
  type = "external"

  listener {
    name        = "listener"
    port        = 80
    target_port = 9292

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.loadbalancer.id

    healthcheck {
      name = "tcp"
      tcp_options {
        port = 9292
      }
    }
  }
}
```
3.  Добавляем переменные в **output.tf**
```
output "loadbalancer_ip_address" {
  value = yandex_lb_network_load_balancer.lb.listener.*.external_address_spec[0].*.address
}

```
и собираем
```bash
terraform plan; terraform apply -auto-approve
```
4. Создаем еще один ресурс **reddit-app2** по аналогии с первым
```terraform
resource "yandex_compute_instance" "app2" {
  name = "reddit-app2"
  ...
}
```
добавляем его в целевую группу
```
  target {
    address = yandex_compute_instance.app2.network_interface.0.ip_address
      subnet_id = var.subnet_id
  }
```
и правим **output.tf**
```
output "external_ip_addresses_app" {
  value = yandex_compute_instance.app[*].network_interface.0.nat_ip_address
}
```
5. Создаем инстанцы с помощью **count**, которую указываем как пременную, в **variables.tf** с дефолтным значением 1
```
variable instances {
  description = "count instances"
  default     = 1
}
```
удаляем второй инстанс и редактируем первый
```
resource "yandex_compute_instance" "app" {
  count = var.instances
  name  = "reddit-app-${count.index}"
  ...
  connection {
  ...
    host  = self.network_interface.0.nat_ip_address
  }
  ...
}
```
затем правим таргет групп используя блок **dynamic**
```
 dynamic "target" {
    for_each = yandex_compute_instance.app.*.network_interface.0.ip_address
    content {
      subnet_id = var.subnet_id
      address   = target.value
    }
  }
```
добавляем в наши переменные значение 2, собираем и проверяем
```bash
terraform plan; terraform apply -auto-approve
```
---
## Подготовка образов с помощью packer

#### Выполненные работы

1. Создаем новую ветку **packer-base** и переносим скрипты из предыдущего ДЗ в **config-scripts**
2. Устанавливаем packer
3. Создаем сервисный аккаунт в **yc**
```bash
SVC_ACCT="service"
FOLDER_ID="abcde"
yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID
```
предоставляем ему права **editor**
```bash
ACCT_ID=$(yc iam service-account get $SVC_ACCT |  grep ^id | awk '{print $2}')
yc resource-manager folder add-access-binding --id $FOLDER_ID --role editor --service-account-id $ACCT_ID
```
создаем IAM ключ
```bash
yc iam key create --service-account-id $ACCT_ID --output /home/appuser/key.json
```
4.Создаем шаблон **packer**
```bash
mkdir packer
touch packer\ubuntu16.json
mkdir packer\scripts
cp config-scripts\install_ruby.sh packer\scripts\
cp config-install_mongodb.sh packer\scripts\
```
Заполняем шаблон **ubuntu16.json**
```json
{
    "builders": [
        {
            "type": "yandex",
            "service_account_key_file": "/home/appuser/key.json",
            "folder_id": "abcd",
            "source_image_family": "ubuntu-1604-lts",
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "reddit-base",
            "ssh_username": "ubuntu",
            "use_ipv4_nat": "true",
            "platform_id": "standard-v1"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}
```
5. Проверяем и собираем образ
```bash
packer validate ./ubuntu16.json
packer build ./ubuntu16.json
```
Помимо описанной в ДЗ проблемы (отсутвием *"use_ipv4_nat": "true"*) столкнулся с еще парой проблем:
```bash
==> yandex: Error creating network: server-request-id = 20472c4c-1dea-baed-b75c-4077f496dbba client-request-id = 08fe7700-5bdb-430d-a21f-f35d1e0f50f2 client-trace-id = 4e4eff9e-3140-4e19-9306-9abde5652fa8 rpc error: code = ResourceExhausted desc = Quota limit vpc.networks.count exceeded
Build 'yandex' errored: Error creating network: server-request-id = 20472c4c-1dea-baed-b75c-4077f496dbba client-request-id = 08fe7700-5bdb-430d-a21f-f35d1e0f50f2 client-trace-id = 4e4eff9e-3140-4e19-9306-9abde5652fa8 rpc error: code = ResourceExhausted desc = Quota limit vpc.networks.count exceeded
```
Это лечится удалением всех сетевых профилей в YC, вторая проблема, при выполнение скрипта установки ruby
```bash
==> yandex: E: Could not get lock /var/lib/dpkg/lock-frontend - open (11: Resource temporarily unavailable)
==> yandex: E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), is another process using it?
```
Необходимо добавить в скрипт **install_ruby.sh**, строчку после **apt update**
```bash
echo "sleep 3m for install updates"; sleep 5m; echo "start install ruby"
```
6. Проверяем работу нашего образа
7. Создаем файлы с переменными **variables.json** и **variables.json.example**
```json
{
  "key": "key.json",
  "fid": "abcde",
  "image": "ubuntu-1604-lts"
}
```
8. Добвляем **variables.json** в **.gitignore**
9. Параметризуем другие переменные
```json
"disk_name": "reddit-base",
"disk_size_gb": "20",
```
10. Для валидации в travis необходимо создать **key.json** идентичный рабочему
```json
{
   "id": "abcd",
   "service_account_id": "efj",
   "created_at": "2020-09-20T13:09:29Z",
   "key_algorithm": "RSA_2048",
   "public_key": "-----BEGIN PUBLIC KEY-----\n",
   "private_key": "-----BEGIN PRIVATE KEY-----\n"
}
```

#### Задание со ⭐
1. На базе **ubuntu16.json** создаем **immutable.json**
```bash
copy ubuntu16.json immutable.json
```
меняем необходимые элементы конфигурации
```json
"image_name": "reddit-full-{{timestamp}}",
"image_family": "reddit-full",
```
2. Для создания **puma.service** воспользуемся [оффициальной документацией](https://github.com/puma/puma/blob/master/docs/systemd.md)
3. Для передачи **puma.service** используем провижионер [file](https://www.packer.io/docs/provisioners/file)
```json
{
  "type": "file",
  "source": "files/puma.service",
  "destination": "/tmp/puma.service"
}
```
4. Для дальнейшего развертывания будем использовать уже знакомый **shell** и массив [inline](https://www.packer.io/docs/provisioners/shell)
```json
{
  "type": "shell",
  "inline": [
      "sudo mv /tmp/puma.service /etc/systemd/system/puma.service",
      "cd /opt",
      "sudo apt-get install -y git",
      "sudo chmod -R 0777 /opt",
      "git clone -b monolith https://github.com/express42/reddit.git",
      "cd reddit && bundle install",
      "sudo systemctl daemon-reload && sudo systemctl start puma && sudo systemctl enable puma"
  ]
}
```
5. Все готово, проверяем конфиги и запускам билд
```bash
packer validate -var-file=./variables.json ./immutable.json
packer build -var-file=./variables.json ./immutable.json
```
6. Используем документацию яндекса для создания **create-reddit-mv.sh**<так как я удалял до этого сеть, то создаем заново
```
yc vpc network create --name default
```
узнаем id образа
```
yc compute image list
```
И используя полученные параметры создаем **create-reddit-mv.sh** и проверяем
```
../config-scripts/create-reddit-vm.sh
done (1m5s)
id: ***
folder_id: ***
created_at: "2020-09-20T17:33:17Z"
name: reddit-app
zone_id: ru-centra
...
```

---
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
