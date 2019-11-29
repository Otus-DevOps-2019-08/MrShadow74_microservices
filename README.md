# MrShadow74_microservices
MrShadow74 microservices repository

# Homework #12. Технологии контейнеризации. Введение в Docker.

* В домашней работе будут изучены:
 - Создание docker host
 - Создание своего образа
 - Работа с Docker Hub


* Клонирован репозиторий MrShadow74_microservices
* Создана директория docker-monolith
* Подключен TravisCI
```
wget https://bit.ly/otus-travis-yaml-2019-05 -O .travis.yml y -P ~/GitHub/MrShadow74_microservices/
mkdir .github && wget http://bit.ly/otus-pr-template -O PULL_REQUEST_TEMPLATE.md y -P ~/GitHub/MrShadow74_microservices/.github/
mkdir play-travis && wget https://raw.githubusercontent.com/express42/otus-snippets/master/hw-04/test.py -P y -P ~/GitHub/MrShadow74_microservices/play-travis/
```

* Подключен вывод сообщений в канал Slack
```
travis encrypt "devops-team-otus:<TOKEN>" --add notifications.slack
```

## Устанавливаем Docker

* Документация по установке https://docs.docker.com/install/linux/docker-ce/ubuntu/
* Выполним следующие операции:

```
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

* В результате имеем следующее:

```
$ docker version
Client: Docker Engine - Community
 Version:           19.03.4
 API version:       1.40
 Go version:        go1.12.10
 Git commit:        9013bf583a
 Built:             Fri Oct 18 15:54:09 2019
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.4
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.10
  Git commit:       9013bf583a
  Built:            Fri Oct 18 15:52:40 2019
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.2.10
  GitCommit:        b34a5c8af56e510852c35414db4c1f4fa6172339
 runc:
  Version:          1.0.0-rc8+dev
  GitCommit:        3e425f80a8c931f88e6d94a8c831b9d5aa481657
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```

* Выполним команду `docker run hello-world`

```
$ docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
1b930d010525: Pull complete
Digest: sha256:c3b4ada4687bbaa170745b3e4dd8ac3f194ca95b2d0518b417fb47e5879d9b5f
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
```

### Docker ps

* Выполним команду `docker ps -a` для вывода списка всех контейнеров

```
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
8a11cc5a7e5a        hello-world         "/hello"            18 minutes ago      Exited (0) 18 minutes ago                       friendly_tu
```

* Выполним команду `docker images` для вывода списка всех сохранённых образов

```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              fce289e99eb9        10 months ago       1.84kB
```

* Командой `docker run` создаем и запускаем контейнер из образа

```
$ docker run -it ubuntu:16.04 /bin/bash
Unable to find image 'ubuntu:16.04' locally
16.04: Pulling from library/ubuntu
e80174c8b43b: Pull complete
d1072db285cc: Pull complete
858453671e67: Pull complete
3d07b1124f98: Pull complete
Digest: sha256:bb5b48c7750a6a8775c74bcb601f7e5399135d0a06de004d000e05fd25c1a71c
Status: Downloaded newer image for ubuntu:16.04
root@f5cac9888499:/# echo 'Hello world!' > /tmp/file
root@f5cac9888499:/# cat /tmp/file
Hello world!
root@f5cac9888499:/# exit
exit
```

* Выполним команду ещё раз

```
$ docker run -it ubuntu:16.04 /bin/bash
root@ee2c7c47ac8b:/# cat /tmp/file
cat: /tmp/file: No such file or directory
root@ee2c7c47ac8b:/# exit
exit
```

**Вывод** - каждый раз запускаетсся новый контейнер. Если при запуске контейнера нет команды --rm, конейнер после выхода будет сохранён со всем своим содержимым.

* Командой `docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"` посмотрим список контейнеров и найдём ID нужного.

```
$ docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"
CONTAINER ID        IMAGE               CREATED AT                      NAMES
ee2c7c47ac8b        ubuntu:16.04        2019-11-08 14:00:24 +0500 +05   unruffled_haibt
f5cac9888499        ubuntu:16.04        2019-11-08 13:57:24 +0500 +05   priceless_hawking
8a11cc5a7e5a        hello-world         2019-11-08 13:33:39 +0500 +05   friendly_tu
```

### Docker start && attach

* docker start <CONTAINER ID> запускает остановленный ранее созданный контейнер

```
$ docker start f5cac9888499
f5cac9888499
```

* docker attach <CONTAINER ID> подсоединяет терминал к созданному контейнеру

```
$ docker attach f5cac9888499
root@f5cac9888499:/#
```

Последовательность команд `Ctrl + p, Ctrl + q` позволяют выйти за пределы контейнера, не завершая его работу

```
# read escape sequence
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
f5cac9888499        ubuntu:16.04        "/bin/bash"         17 minutes ago      Up About a minute                       priceless_hawking
```

### Docker run vs start

* docker run = docker create + docker start + docker attach
* docker create используется, когда не нужно стартовать контейнер сразу

* **Docker run**
 * Через параметры передаются лимиты(cpu/mem/disk), ip, volumes
 * -i – запускает контейнер в foreground режиме (docker attach)
 * -d – запускает контейнер в background режиме
 * -t создает TTY
 * пример `docker run -it ubuntu:16.04 bash` запустит контейнер с териналом
 * пример `docker run -dt nginx:latest` запустит контейнер с работающим сервисом nginx

* **Docker exec** запускает новый процесс внутри контейнера
```
$ docker exec -it f5cac9888499 bash
root@f5cac9888499:/# ps axf
   PID TTY      STAT   TIME COMMAND
    11 pts/1    Ss     0:00 bash
    21 pts/1    R+     0:00  \_ ps axf
     1 pts/0    Ss+    0:00 /bin/bash
```

* **Docker commit**
 * Создает image из контейнера
 * Контейнер при этом остается запущенным

```
$ docker commit docker commit f5cac9888499 mrshadow74/ubuntu-tmp-file
```

## Задание со *

$ docker images > docker-monolith/docker-1.log

```
$ docker images
REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
mrshadow74/ubuntu-tmp-file   latest              7ce5975a2335        8 minutes ago       123MB
ubuntu                       16.04               5f2bf26e3524        7 days ago          123MB
hello-world                  latest              fce289e99eb9        10 months ago       1.84kB
```

* В файл docker-monolith/docker-1.log добавлены текстовое описание разности между контейнером и образом.

### Docker kill & stop
 * kill сразу посылает SIGKILL
 * stop посылает SIGTERM, и через 10 секунд(настраивается) посылает SIGKILL
 * SIGTERM - сигнал остановки приложения
 * SIGKILL - безусловное завершение процесса

* docker system df
 * Отображает сколько дискового пространства занято образами, контейнерами и volume’ами
 * Отображает сколько из них не используется и возможно удалить

```
$ Docker system df
TYPE                TOTAL               ACTIVE              SIZE                RECLAIMABLE
Images              3                   2                   122.6MB             122.6MB (99%)
Containers          3                   0                   122B                122B (100%)
Local Volumes       0                   0                   0B                  0B
Build Cache         0                   0                   0B                  0B
```

### Docker rm & rmi
 * rm удаляет контейнер, можно добавить флаг -f, чтобы удалялся работающий container (будет послан sigkill)
 * rmi удаляет image, если от него не зависят запущенные контейнеры

```
$ docker rm $(docker ps -a -q)
ee2c7c47ac8b
f5cac9888499
8a11cc5a7e5a

$ docker rmi $(docker images -q)
Untagged: mrshadow74/ubuntu-tmp-file:latest
Deleted: sha256:7ce5975a23357bb63af3209d8d2ba395bfc97f16525b05673f00646ccd50f196
Deleted: sha256:bd2e167b8c91a9ae75b64a1250a0f0ca91a18a72c95158710c05d83cdc739e65
Untagged: ubuntu:16.04
Untagged: ubuntu@sha256:bb5b48c7750a6a8775c74bcb601f7e5399135d0a06de004d000e05fd25c1a71c
Deleted: sha256:5f2bf26e35249d8b47f002045c57b2ea9d8ba68704f45f3c209182a7a2a9ece5
Deleted: sha256:0ede31ddf30de46bceba5710ea3003a7c422fc518aa7e2fbdfda212b68a7e028
Deleted: sha256:1d7d6a85a6e52d5c6970517e1dbb83bf5cd40fa20fff510586110ace29de4de8
Deleted: sha256:c4ab874de3a30c67f9c36b38e78f2a990ec151deb2d2a888700fc13704d1fd9c
Deleted: sha256:788b17b748c23d38ec62e913e87b084b7e3efda49843b3c0809b1857559b553e
Untagged: hello-world:latest
Untagged: hello-world@sha256:c3b4ada4687bbaa170745b3e4dd8ac3f194ca95b2d0518b417fb47e5879d9b5f
Deleted: sha256:fce289e99eb9bca977dae136fbe2a82b6b7d4c372474c9235adc1741675f587e
Deleted: sha256:af0b15c8625bb1938f1d7b17081031f649fd14e6b233688eea3c5483994a66a3
```

## Docker-контейнеры. GCE

* Создан новый проект в GCP с именем docker через команду gcloud init

### Docker machine
Установка
```
base=https://github.com/docker/machine/releases/download/v0.16.0 &&
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  sudo mv /tmp/docker-machine /usr/local/bin/docker-machine &&
  chmod +x /usr/local/bin/docker-machine
```
Результат
```
$ docker-machine version
docker-machine version 0.16.0, build 702c267f
```
* ***docker-machine*** - встроенный в докер инструмент для создания хостов и установки на
них docker engine. Имеет поддержку облаков и систем виртуализации (Virtualbox, GCP и
др.)
* Команда создания - `docker-machine create <имя>`. Имен может быть много, переключение
между ними через `eval $(docker-machine env <имя>)`.
* Переключение на локальный докер- `eval $(docker-machine env --unset)`.
* Удаление - `docker-machine rm <имя>`.
```
$ export GOOGLE_PROJECT=global-incline-258416

$ docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
docker-host

Running pre-create checks...
(docker-host) Check that the project exists
(docker-host) Check if the instance already exists
Creating machine...
(docker-host) Generating SSH Key
(docker-host) Creating host...
(docker-host) Opening firewall ports
(docker-host) Creating instance
(docker-host) Waiting for Instance
(docker-host) Uploading SSH Key
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with ubuntu(systemd)...
Installing Docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: docker-machine env docker-host
```
* `docker-machine ls` выводит список виртуальных машин
```
$ docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                         SWARM   DOCKER     ERRORS
docker-host   -        google   Running   tcp://104.155.45.195:2376           v19.03.4

eval $(docker-machine env docker-host)
```

### Повторение практики из демо на лекции

>И сравните сами вывод:
`docker run --rm -ti tehbilly/htop` покажет только одни процесс, запущенный htop.
`docker run --rm --pid host -ti tehbilly/htop` покажет все процессы хоста, на котором запущен контейнер.

### Заполнение структуры репозитория

* В каталоге docker-monolith созданы файлы:
**db_config**
```
DATABASE_URL=127.0.0.1
```
**Dockerfile**
```
#Создаём образ на основе
FROM ubuntu:16.04
#Установим необходимые пакеты
RUN apt-get update
RUN apt-get install -y mongodb-server ruby-full ruby-dev build-essential git
RUN gem install bundler
RUN git clone -b monolith https://github.com/express42/reddit.git
#Добавим файлы конфигурации
COPY mongod.conf /etc/mongod.conf
COPY db_config /reddit/db_config
COPY start.sh /start.sh
#Установка зависимостей и настройка прав доступа
RUN cd /reddit && bundle install
RUN chmod 0777 /start.sh
#Старт сервиса
CMD ["/start.sh"]
```
**mongod.conf**
```
# Where and how to store data.
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

# network interfaces
net:
  port: 27017
  bindIp: 127.0.0.1
```
**start.sh**
```
#!/bin/bash

/usr/bin/mongod --fork --logpath /var/log/mongod.log --config /etc/mongodb.conf

source /reddit/db_config

cd /reddit && puma || exit
```

* Выполним команду `$ docker build -t reddit:latest .`. Точка в конце указывает на путь до файла Dockerfile

* В результате выполнения получаю ошибку
```
Err:1 http://security.ubuntu.com/ubuntu xenial-security InRelease
  Temporary failure resolving 'security.ubuntu.com'
Err:2 http://archive.ubuntu.com/ubuntu xenial InRelease
  Temporary failure resolving 'archive.ubuntu.com'
Err:3 http://archive.ubuntu.com/ubuntu xenial-updates InRelease
  Temporary failure resolving 'archive.ubuntu.com'
Err:4 http://archive.ubuntu.com/ubuntu xenial-backports InRelease
  Temporary failure resolving 'archive.ubuntu.com'
```
Исправляется добавлением в файл `/etc/docker/daemon.json` записи
```
{
    "dns": ["8.8.8.8"]
}
```

Ещё раз делаем билд, получаем результат
```
$ docker images -a
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
reddit              latest              58571c7eea1f        26 seconds ago       692MB
<none>              <none>              9c4fb52b89b4        27 seconds ago       692MB
<none>              <none>              bd5c1c44328b        28 seconds ago       692MB
<none>              <none>              6ff97462b650        42 seconds ago       647MB
<none>              <none>              06d6eb7ea19b        42 seconds ago       647MB
<none>              <none>              4c505d0794f8        42 seconds ago       647MB
<none>              <none>              eb2c9bd038ff        42 seconds ago       647MB
<none>              <none>              c892e367219d        44 seconds ago       647MB
<none>              <none>              ae218c3a87db        57 seconds ago       644MB
<none>              <none>              458feec4890b        About a minute ago   148MB
ubuntu              16.04               5f2bf26e3524        9 days ago           123MB
```

Запускаем наш контейнер
```
$ docker run --name reddit -d --network=host reddit:latest
d6efc9e7e7a182b1aba31cbdfafbfb4829e70114baf9e7cca74178f70e4d1d58

$ docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                         SWARM   DOCKER     ERRORS
docker-host   *        google   Running   tcp://35.195.187.251:2376           v19.03.4
```

* Попытка открыть адрес http://35.195.187.251:9292 заканчивается ошибкой. Для её исправления необходимо добавить правило для GCP firewall для порта 9292. После этого приложение становитя доступно.
```
$ gcloud compute firewall-rules create reddit-app \
--allow tcp:9292 \
--target-tags=docker-machine \
--description="Allow PUMA connections" \
--direction=INGRESS
```

## Docker hub:регистрация

* Создана учётная запись на hub.docker.com

* Пуш на докерхаб:
```
docker tag reddit:latest mrshadow74/otus-reddit:1.0
docker push mrshadow74/otus-reddit:1.0
```

* Проверка запуска из dockerhub
```
docker run --name reddit -d -p 9292:9292 mrshadow74/otus-reddit:1.0
```
Запуск локально происходит при выполнении
```
docker run --name reddit -d -p 9292:9292 mrshadow74/otus-reddit:1.0
```

### Проверка результата:

docker logs reddit -f - смотрим логи контейнера

docker exec -it reddit bash - запускаем bash в контейнере

ps aux - вывод процессов

killall5 1 - уничтожение процесса pid=1

docker start reddit - старт контейнера из образа reddit

docker stop reddit && docker rm reddit - остановка и удаление запущенного контейнера reddit.

docker run --name reddit --rm -it dedocker tag reddit:latest mrshadow74/otus-reddit:1.0

ps aux - увидим, что нет запущенного приложения

exit - выход

docker inspect mrshadow74/otus-reddit:1.0 - вывод инфорации о образе

docker inspect mrshadow74/otus-reddit:1.0 -f '{{.ContainerConfig.Cmd}}' - видно основной процессй: [/bin/sh -c #(nop)  CMD ["/start.sh"]]

docker run --name reddit -d -p 9292:9292 mrshadow74/otus-reddit:1.0 - запуск локально с биндом порта приложения на 9292

docker exec -it reddit bash - запуск в консоли bahs

mkdir /test1234 - создание каталога

touch /test1234/testfile - создание файла

rmdir /opt - удаление каталога /opt

exit - выход

docker diff reddit - вывод всех изменений, которые произошли в контейнере

```
C /root
A /root/.bash_history
C /var
C /var/log
A /var/log/mongod.log
C /var/lib
C /var/lib/mongodb
A /var/lib/mongodb/_tmp
A /var/lib/mongodb/journal
A /var/lib/mongodb/journal/j._0
A /var/lib/mongodb/journal/prealloc.1
A /var/lib/mongodb/journal/prealloc.2
A /var/lib/mongodb/local.0
A /var/lib/mongodb/local.ns
A /var/lib/mongodb/mongod.lock
A /test1234
A /test1234/testfile
C /tmp
A /tmp/mongodb-27017.sock
D /opt
```

А-изменился, С-создан, D-удален.

docker stop reddit && docker rm reddit - остановка и удаление контейнера

docker run --name reddit --rm -it mrshadow74/otus-reddit:1.0 bash -запуск без приложения

ls / - проверка отсутствия закомиченых изменений

### Удаление docker-машины из GCP

```
docker-machine rm docker-host -f
eval $(docker-machine env --unset)
```

## Задание со * ![build status](https://travis-ci.com/Otus-DevOps-2019-08/MrShadow74_microservices.svg?branch=master)

* Создана инфраструктура каталогов ansible, packer, terraform

* Для хранения состояни terraform создан новый bucket

* Для ansible настроен динамический инвентори

* Создан сервисный аккаунт в GCP в проекте docker с именем ansible, роль Service Account User. Файл с ключем выгружен и сохранён за пределами хранилища.

# Homework 13.
# Docker-образы. Микросервисы

* Создана ветка docker-3

## План
 - Разбить наше приложение на несколько компонентов
 - Запустить наше микросервисное приложение

* Создаём машину
```
$ export GOOGLE_PROJECT=global-incline-258416

$ docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-zone europe-west1-b \
 docker-host

$ docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                       SWARM   DOCKER     ERRORS
docker-host   *        google   Running   tcp://34.77.12.119:2376           v19.03.4

$ eval $(docker-machine env docker-host)

$ docker run --name reddit -d -p 9292:9292 mrshadow74/otus-reddit:1.0
```

* Проверяем
```
$ docker ps -a -q
59cf1d93faf7
```

* Скачиваем и распаковываем файл домашнего задания
```
$ wget https://github.com/express42/reddit/archive/microservices.zipzip \
  && unzip microservices.zip && rm microservices.zip && mv reddit microservices src
```

* Создаем файлы сервисов
```
./post-py/Dockerfile
./comment/Dockerfile
./ui/Dockerfile
```

* В файле ./post-py/Dockerfile имеется неточность, корректируем содержание.
```
FROM python:3.6.0-alpine

WORKDIR /app
ADD . /app

RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
    && pip install -r /app/requirements.txt \
    && apk del --virtual .build-deps gcc musl-dev

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

CMD ["python3", "post_app.py"]
```

* После этого собираем сервисы
```
$ docker pull mongo:latest
$ docker build -t mrshadow74/post:1.0 ./post-py
$ docker build -t mrshadow74/comment:1.0 ./comment
$ docker build -t mrshadow74/ui:1.0 ./ui
```

## Запуск приложения
* Создаем сеть для приложений
```
$ docker network create reddit
16c28ab9f1c4aa062f9dc33952b570f5011d1b851ae0805622b1fb9bf00addfd
```

* Запускаем контейнеры
```
$ docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
Unable to find image 'mongo:latest' locally
latest: Pulling from library/mongo
7ddbc47eeb70: Pull complete
c1bbdc448b72: Pull complete
8c3b70e39044: Pull complete
45d437916d57: Pull complete
e119fb0e0a55: Pull complete
91f0b9bae1ea: Pull complete
53e7c2967f11: Pull complete
69a945568374: Pull complete
93333bc225a7: Pull complete
b9c10bd6c9bd: Pull complete
7f4e3538e99c: Pull complete
1164b51d180a: Pull complete
a715a7d71f27: Pull complete
Digest: sha256:2704b1f2ad53c0c5fb029fc112f99b5e9acdca3ab869095a3f8c6d14b2e3c0f3
Status: Downloaded newer image for mongo:latest
cfd896f235b063856b427b795f741695b4ceb70f3529f1e9afe4e1cb17fb5b4f

$ docker run -d --network=reddit --network-alias=post mrshadow74/post:1.0
333f00038a9c500685e85af7e72d8ed5da6af3601a9eb12778a3f736a96f90ad

$ docker run -d --network=reddit --network-alias=comment mrshadow74/comment:1.0
b2814ecbf65a4d69316825cd034a8702d46c2d234d793c14f4d2bfb601b841a7

$ docker run -d --network=reddit -p 9292:9292 mrshadow74/ui:1.0
0d9809d3485d3b33c67315b9adc3e34be5e3b79cb599ec80c66be442c616cc6d
```

* *Что сделано:*
 - Создали bridge-сеть для контейнеров, так как сетевые алиасы не работают в сети по умолчанию
 - Запустили наши контейнеры в этой сети
 - Добавили сетевые алиасы контейнерам

## Задание со *

* Остановим контейнеры
```
docker kill $(docker ps -q)
```

* Заменим переменные окружения и создадим заново
```
docker run -d --network=reddit --network-alias=post_db2 --network-alias=comment_db2 -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post2 -e POST_DATABASE_HOST=post_db2 mrshadow74/post:1.0
docker run -d --network=reddit --network-alias=comment2 -e COMMENT_DATABASE_HOST=comment_db2 mrshadow74/comment:1.0
docker run -d --network=reddit -p 9292:9292 -e POST_SERVICE_HOST=post2 -e COMMENT_SERVICE_HOST=comment2 mrshadow74/ui:2.0
```

* Результат занимает неоправданно много дискового пространства
```
$ docker images
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
mrshadow74/ui        1.0                 9bbc2355ee0d        About an hour ago   783MB
mrshadow74/comment   1.0                 705aa79e5c6b        About an hour ago   781MB
mrshadow74/post      1.0                 13df4d215d60        About an hour ago   109MB
<none>               <none>              db3825ba9759        2 hours ago         88.6MB
mongo                latest              965553e202a4        13 days ago         363MB
ruby                 2.2                 6c8e6f9667b2        18 months ago       715MB
python               3.6.0-alpine        cb178ebbf0f2        2 years ago         88.6MB
```

* Скорректируем содержимое файла `./ui/Dockerfile`
```
FROM ubuntu:16.04
RUN apt-get update \
&& apt-get install -y ruby-full ruby-dev build-essential \
&& gem install bundler --no-ri --no-rdoc
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
CMD ["puma"]
```

* И посмотрим, что изменилось. Разница ощутима.
```
$ docker build -t mrshadow74/ui:2.0 ./ui

$ docker images
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
mrshadow74/ui        2.0                 e9c8c8fd0d58        21 seconds ago      459MB
mrshadow74/ui        1.0                 9bbc2355ee0d        2 hours ago         783MB
```

## Задание со *

### Сборка образов на базе Alpine Linux

### Уменьшение размеров образов

* Соберем образ `docker build -t mrshadow74/ui:2.0 ./ui`
```
FROM ubuntu:16.04
RUN apt-get update \
    && apt-get install -y ruby-full ruby-dev build-essential \
    && gem install bundler --no-ri --no-rdoc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
```
* Соберем образ `docker build -t mrshadow74/ui:2.0 ./ui`

* Соберем образ `docker build -t mrshadow74/ui:2.1 ./ui` на базе `https://raw.githubusercontent.com/docker-library/ruby/1dd5c255325fa0d5c3761f5238bbe1a9f50e9596/2.6/alpine3.10/Dockerfile`

Образ до конца не заработал, для старта puma чего-то не хватает, разбираться уже лениво было. Но размер файла показательный.

* Соберем новый образ `$ docker build -t mrshadow74/ui:2.2 ./ui`
```
FROM alpine:3.7
RUN apk --update add --no-cache --virtual run-dependencies \
    ruby ruby-dev ruby-json \
    build-base \
    bash \
    && gem install bundler --no-ri --no-rdoc \
    && rm -rf /var/lib/apt/lists/*

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
```

* Результат
```
$ docker images | grep ui
mrshadow74/ui        2.0                 74236d2d3d57        23 minutes ago      433MB
mrshadow74/ui        2.2                 b66a0d671ac7        About an hour ago   218MB
mrshadow74/ui        2.1                 b22519e5f791        2 hours ago         51MB
```

### Ускорение сборки

* Добавлю параметр `--no-cache=True` для команды build.

### Перезапуск приложения
```
$ docker kill $(docker ps -q)
0d9809d3485d
b2814ecbf65a
333f00038a9c
cfd896f235b0
```

* И создадим приложения заново
```
$ docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
b3302f7f01dd067b333c1efcf6cedcf1595a8cb870180b9c967875c467b4f4b2
$ docker run -d --network=reddit --network-alias=post mrshadow74/post:1.0
a0135cdc04222de25a69516035e287f76f46414a75aaaaa3f7eb289659933975
$ docker run -d --network=reddit --network-alias=comment mrshadow74/comment:1.0
f314f5a4caa31cd0e0870a5a1b642360030850906016bdf007b1b964fd7c2ac3
$ docker run -d --network=reddit -p 9292:9292 mrshadow74/ui:2.0
7e7c5d9095c658beaaf4938f5d4c5863e043f2ba48b4a8ed067a70089165623b
```

* Проверка показывает, что мы потеряли содержимое базы mongo при перезапуске контейнеров.

* Исправим это. Удалим контейнеры, создадим хранилище для базы и создадим заново

```
$ docker kill $(docker ps -q)
7e7c5d9095c6
f314f5a4caa3
a0135cdc0422
b3302f7f01dd

$ docker volume create reddit_dbreddit_db

$ docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit-db:/data/db mongo:latest
30db89cbacc20af8b9bcaf7a5523c00897b99a693830aafe07b56a9342184ed4
$ docker run -d --network=reddit --network-alias=post mrshadow74/post:1.0
3dc1d2c62f4ed33553f98f32f25fdbc19c62f53ed417a624c8593b3a2adaa84b
$ docker run -d --network=reddit --network-alias=comment mrshadow74/comment:1.0
93f335d923bf907f5735e64b5d013f285179d84680a5497541719f0454bde3fd
$ docker run -d --network=reddit -p 9292:9292 mrshadow74/ui:2.0
2b3e5a9bd4de014867d9fd17edc03faf7025f25fdf0065bbead73a9395fdea45
```

* Проверили - всё работает. Уничтожим контейнеры и запустим их заново.
```
$ docker kill $(docker ps -q)   2b3e5a9bd4de
93f335d923bf
3dc1d2c62f4e
30db89cbacc2

$ docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit-db:/data/db mongo:latest
5bfd36fad853f72f8170c826e47cd775a73f470131204faae0c80709984374f8
$ docker run -d --network=reddit --network-alias=post mrshadow74/post:1.0
54c0d59d03db0ab54db3f9e7e66f472c6e3b1542f6ddae9715b23ae60dd9842e
$ docker run -d --network=reddit --network-alias=comment mrshadow74/comment:1.0
cfed93569b5f90094d3e8649b8957e54fa10457d894bb02a6a07e2840313b421
$ docker run -d --network=reddit -p 9292:9292 mrshadow74/ui:2.0
287300676c7e374c9d706b52d3cd96c1abaa917f2b56225d7cd5e53b95dd1df7
```

* Проверяем - база на месте, записи в базе сохранились.

# Homework 14. Docker: сети, docker-compose

* План
 - работа с сетями Docker
 - использование docker-compose

* Создана ветка docker-4
* Создан хост docker-host
```
$ export GOOGLE_PROJECT=global-incline-258416

$ docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-zone europe-west1-b \
 docker-host

$ docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                      SWARM   DOCKER     ERRORS
docker-host   *        google   Running   tcp://34.77.25.81:2376           v19.03.5

eval $(docker-machine env docker-host)
```

## Работа с сетью в Docker

* План
 - разобраться с работой сети в Docker
   - none
   - host
   - bridge

### None network driver
* Выполним
```
$ docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
Unable to find image 'joffotron/docker-net-tools:latest' locally
latest: Pulling from joffotron/docker-net-tools
3690ec4760f9: Pull complete
0905b79e95dc: Pull complete
Digest: sha256:5752abdc4351a75e9daec681c1a6babfec03b317b273fc56f953592e6218d5b5
Status: Downloaded newer image for joffotron/docker-net-tools:latest
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```
* Запустим контейнер в сетевом пространстве docker-хоста
```
$ docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig
docker0   Link encap:Ethernet  HWaddr 02:42:53:29:BB:B9
          inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

ens4      Link encap:Ethernet  HWaddr 42:01:0A:84:00:0B
          inet addr:10.132.0.11  Bcast:10.132.0.11  Mask:255.255.255.255
          inet6 addr: fe80::4001:aff:fe84:b%32618/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1460  Metric:1
          RX packets:4800 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3904 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:108561315 (103.5 MiB)  TX bytes:393686 (384.4 KiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32618/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

* Сравним вывод команды с
```
$ docker-machine ssh docker-host ifconfig
docker0   Link encap:Ethernet  HWaddr 02:42:53:29:bb:b9
          inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

ens4      Link encap:Ethernet  HWaddr 42:01:0a:84:00:0b
          inet addr:10.132.0.11  Bcast:10.132.0.11  Mask:255.255.255.255
          inet6 addr: fe80::4001:aff:fe84:b/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1460  Metric:1
          RX packets:4845 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3956 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:108570552 (108.5 MB)  TX bytes:402689 (402.6 KB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```
* Результаты вывода команд идентичны
* Запустил несколько раз команду `docker run --network host -d nginx`.
```
$ docker run --network host -d nginx
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
8d691f585fa8: Pull complete
5b07f4e08ad0: Pull complete
abc291867bca: Pull complete
Digest: sha256:922c815aa4df050d4df476e92daed4231f466acc8ee90e0e774951b0fd7195a4
Status: Downloaded newer image for nginx:latest
944a610f787f6c5e1a7834ad205f9f88774cc312c997056d5be4d7e09cf2f875

$ docker run --network host -d nginx
0c7b7f3f9fefb88f53433b3c2f3807b78952a39f3344ffc77ca44cf9ff9b8d7b

$ docker run --network host -d nginx
a44bb85703ebb3e2d45739c4ec6c0a2e678e24939d537997cf411c0a65c01295
```
* Результат - загружен образ контейнера nginx, собран и запущен контейнер с ним.
* Последующие запуски команды создают контейнеры nginx, но останавливают их при запуске следующего.
* Ответ на вопрос "почему"
```
$ docker logs 944a610f787f
2019/11/18 15:53:01 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
```

* Остановим все запущенные контейнеры:
```
$ docker kill $(docker ps -q)
```

* На docker-host машине выполните команду:
```
$ docker-machine ssh docker-host
Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.15.0-1049-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage


0 packages can be updated.
0 updates are security updates.

New release '18.04.3 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

docker-user@docker-host:~$ sudo ln -s /var/run/docker/netns /var/run/netns
docker-user@docker-host:~$ sudo ip netns
default
```

* То же самое, но с использование none и host
```
$ docker run --network host -d nginx && docker run --network none -d nginx && docker run --network host -d nginx && docker run --network none -d nginx
9c10e284e43825cf53cb7693e8da0e173361ddeac2a62524cbb05bbb4ecf86b0
75d0d1f8129870b2d37a05b36c8368d83f0d388827201f5680497345a6520cab
5f1f5aaa6a9f42eac62b277b160a590fa4abd1c4076a260686457ad0c3b14376
270e05010782879a98193a8b391faf82b6dffa9ea6d55f60a5cd102d5a6ec6c5

$ docker-machine ssh docker-host sudo ip netns
6fbb83f0ccfe
fb5c9cb5cad7
default
```
## Bridge network driver
* Создадим bridge-сеть в docker
```
docker network create reddit --driver bridge
```

* Запустим наш проект reddit с использованием bridge-сети
```
$ docker run -d --network=reddit --network-alias=post mrshadow74/post:1.0
deb693ceff8af30c3833fa1ca87e2c284b7919a66dbc4e88bce4bd47cfd6b95b
$ docker run -d --network=reddit --network-alias=comment mrshadow74/comment:1.0
ab1db118445dab98e17df09ae16f54a2986a0879e0400c5bd6e36ab219000389
$ docker run -d --network=reddit -p 9292:9292 mrshadow74/ui:1.0
c7c762d66e4fc2d74f3d18b1c7f4910b41d44db6c7e9b9b7050e6abc54e563cb
```
* Проверяем - всё работает

* Остановим старые копии контейнеров
```
$ docker kill $(docker ps -q)
```
* Создадим docker-сети
```
$ docker network create back_net --subnet=10.0.2.0/24
$ docker network create front_net --subnet=10.0.1.0/24
```
* Запустим контейнеры
```
$ docker run -d --network=front_net -p 9292:9292 --name ui mrshadow74/ui:1.0
$ docker run -d --network=back_net --name comment mrshadow74/comment:1.0
$ docker run -d --network=back_net --name post mrshadow74/post:1.0
$ docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
```
* Docker при инициализации контейнера может подключить к нему только 1 сеть. При этом контейнеры из соседних сетей не будут доступны как в DNS, так и для взаимодействия по сети. Поэтому нужно поместить контейнеры post и comment в обе сети.
```
$ docker network connect front_net post && docker network connect front_net comment
```
* Заходим, проверяем, созадём пару новых постов - всё работает
* Посмотрим, как выглядит сетевой стек на текущий момент
```
$ docker-machine ssh docker-host
$ sudo apt-get update && sudo apt-get install bridge-utils
$ sudo docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
7ef8daa1f0b5        back_net            bridge              local
997ed1053ce3        bridge              bridge              local
1a3827bcf1ec        front_net           bridge              local
49d1b820110c        host                host                local
d4bb674d94c8        none                null                local

$ ifconfig | grep br
br-1a3827bcf1ec Link encap:Ethernet  HWaddr 02:42:3a:f1:fb:e3
br-7ef8daa1f0b5 Link encap:Ethernet  HWaddr 02:42:10:ab:9a:25
```

* Посмотрим, как выглядит iptables
```
$ sudo iptables -nL -t nat
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  10.0.1.0/24          0.0.0.0/0
MASQUERADE  all  --  10.0.2.0/24          0.0.0.0/0
MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0
MASQUERADE  tcp  --  10.0.1.2             10.0.1.2             tcp dpt:9292

Chain DOCKER (2 references)
target     prot opt source               destination
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:9292 to:10.0.1.2:9292
```
* Посмотрим процессы docker-proxy
```
$ ps ax |grep docker-proxy
12868 ?        Sl     0:00 /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 9292 -container-ip 10.0.1.2 -container-port 9292
24234 pts/0    S+     0:00 grep --color=auto docker-proxy
```

## Docker-compose

* Проблемы docker:
 • Одно приложение состоит из множества контейнеров/сервисов
 • Один контейнер зависит от другого
 • Порядок запуска имеет значение
 • docker build/run/create … (долго и много)

* *docker-compose*
 • Это отдельная утилита
 • Декларативное описание docker-инфраструктуры в YAML-формате
 • Управление многоконтейнерными приложениями

### Установка dockercompose
```
pip install docker-compose
```
* Создан файл `src/docker-compose.yml`

### Переменные окружения в docker-compose
* Остановим контейнеры `docker kill $(docker ps -q)`
* Выполним
```
$ export USERNAME=mrshadow74
$ docker-compose up -d
$ docker-compose ps
```
* Посмотрим, что же получилось
```
$ docker-compose ps
    Name                  Command             State           Ports
----------------------------------------------------------------------------
src_comment_1   puma                          Up
src_post_1      python3 post_app.py           Up
src_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp
src_ui_1        puma                          Up      0.0.0.0:9292->9292/tcp
```

* Созданы файлы `.env` и `.env.example`, файл `.env` добавлен в `.gitignore`
* Скорректирован файл `src/docker-compose.yml`, значения заменены на переменные из файла `.env`
* Базовое имя проекта по умолчанию берется из имени каталога, в котором находится проект. Его можно задать через конфигурационную опцию *container_name*. Единственное нужно учитывать, что имя контейнера уникально и два контейнера с одинаковым именем не смогут существовать одновременно.

## Задание со *

* Создан файл `docker-compose.override.yml`
```
version: '3.3'
services:
  post_db:
    volumes:
      - test_db:/data/db
  ui:
    volumes:
      - ui:/home/dev/ui
    command: ["puma","--debug","-w","2"]
  comment:
    volumes:
      - comment:/home/dev/comment
    command: ["puma","--debug","-w","2"]

volumes:
  test_db:
  comment:
  ui:
```

# Homework 15. Устройство Gitlab CI. Построение процесса непрерывной поставки

* Цель задания
 • Подготовить инсталляцию Gitlab CI
 • Подготовить репозиторий с кодом приложения
 • Описать для приложения этапы пайплайна
 • Определить окружения

* Создана ветка gitlab-ci-1

## Инсталляция Gitlab CI

* Создан хост gitlab-ci

```
$ export GOOGLE_PROJECT=global-incline-258416

$ docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-zone europe-west1-b \
 --google-disk-size 50 \
 docker-host

$ eval $(docker-machine env docker-host)

$ docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                      SWARM   DOCKER     ERRORS
docker-host   *        google   Running   tcp://35.205.152.54:2376           v19.03.5
```

* Подготавливаем окружение, создаем необходимые директории
```
$ docker-machine ssh docker-host
docker-user@docker-host:~$ sudo mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs
docker-user@docker-host:~$ cd /srv/gitlab/
docker-user@docker-host:/srv/gitlab$ sudo wget https://gist.githubusercontent.com/Nklya/c2ca40a128758e2dc2244beb09caebe1/raw/e9ba646b06a597734f8dfc0789aae79bc43a7242/docker-compose.yml

```
* Запускаем Gitlab CI
```
docker-compose up -d
```
* Зашел проверить `http://104.155.69.131`, вижу мордочку Gitlab. Меняю пароль root для доступа в систему.
* Создам группу *homework*, проект *example*
* Добавим remote в MrShadow74_microservices
```
git checkout -b gitlab-ci-1
git remote add gitlab http://<your-vm-ip>/homework/example.git
git push gitlab gitlab-ci-1
```
* Добавляем CI/CD Pipeline
```
wget https://gist.githubusercontent.com/Nklya/ab352648c32492e6e9b32440a79a5113/raw/265f383a48b980ac6efd9b4c23f2b68a6bf70ce5/.gitlab-ci.yml
git add .gitlab-ci.yml
git commit -m 'add pipeline definition'
git push gitlab gitlab-ci-1
```
## Gitlab CI Runner
* Получаем токен для работы runner
* На сервер Gitlab CI выполним
```
docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
```
* Регистрируем runner
```
docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
http://<YOUR-VM-IP>/
Please enter the gitlab-ci token for this runner:
<TOKEN>
Please enter the gitlab-ci description for this runner:
[38689f5588fe]: my-runner
Please enter the gitlab-ci tags for this runner (comma separated):
linux,xenial,ubuntu,docker
Please enter the executor:
docker
Please enter the default Docker image (e.g. ruby:2.1):
alpine:latest
Runner registered successfully.
```
* Проверяем состояние runner - запущен, привязан к проекту, работает
* Добавим тестирование приложения reddit в pipeline
```
git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
git add reddit/
git commit -m “Add reddit app”
git push gitlab gitlab-ci-1
```

## Тестируем приложение reddit
* Скорректируем файл `.gitlab-ci.yml`
```
image: ruby:2.4.2

stages:
  - build
  - test
  - review

variables:
  DATABASE_URL: 'mongodb://mongo/user_posts'

build_job:
  stage: build
  script:
    - echo 'Building'

before_script:
    - cd reddit
    - bundle install

test_unit_job:
  stage: test
  services:
    - mongo:latest
  script:
    - ruby simpletest.rb

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_dev_job:
  stage: review
  script:
    - echo 'Deploy'
  environment:
    name: dev
    url: http://dev.example.com
```

* Создадим файл simpletest.rb
```
wget https://gist.githubusercontent.com/Nklya/d70ff7c6d1c02de8f18bcd049e904942/raw/9c82d9a0f16c38b905c7721f54b9b85fff903b3a/simpletest.rb
```

## Staging и Production

* Скорректируем `.gitlab-ci.yml`, добавим в него окружение Stage и Production, а так же правило контроля версии для публикации в Stage и Production
```
staging:
  stage: stage
  when: manual
  only:
    - /^\d+\.\d+\.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: stage
    url: https://beta.example.com

production:
  stage: production
  when: manual
  only:
    - /^\d+\.\d+\.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: production
    url: https://example.com
```
* Тепер push без тега версии не будет запускать джобы Staging и Prodaction
* При налии тега будет запускаться полный pipeline
```
git commit -a -m ‘#4 add logout button to profile page’
git tag 2.4.10
git push gitlab gitlab-ci-1 --tags
```

## Динамические окружения

* Дополним `.gitlab-ci.yml` созданием динамического окружения
```
branch review:
  stage: review
  script: echo "Deploy to $CI_ENVIRONMENT_SLUG"
  environment:
    name: branch/$CI_COMMIT_REF_NAME
    url: http://$CI_ENVIRONMENT_SLUG.example.com
  only:
    - branches
  except:
    - master
``

## Задание со *

```
$ cat gitlab-runner.sh
docker run -d --name gitlab-runner --restart always \  
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \  
  -v /var/run/docker.sock:/var/run/docker.sock \  
  gitlab/gitlab-runner:latest
docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
```

* Добавлена интаграция со Slack
https://app.slack.com/client/T6HR0TUP3/CN5R4PTGR

