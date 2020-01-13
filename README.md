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
```

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

# Homework 16. Введение в мониторинг. Системы мониторинга.
* Создана ветка monitoring-1

## План
* Prometheus: запуск, конфигурация, знакомство с Web UI
* Мониторинг состояния микросервисов
* Сбор метрик хоста с использованием экспортера
* Задания со *

## Подготовка окружения
* Создадим правило фаервола для Prometheus и Puma
```
$ gcloud compute firewall-rules create prometheus-default --allow tcp:9090
$ gcloud compute firewall-rules create puma-default --allow tcp:9292
```
* Создадим docker-хост в GCE
```
$ export GOOGLE_PROJECT=global-incline-258416

$ docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-zone europe-west1-b \
 docker-host2

$ eval $(docker-machine env docker-host2)
```

## Запуск Prometheus
* На основе готового docker-образа prometheus запустим систему мониторинга
```
$ docker run --rm -p 9090:9090 -d --name prometheus prom/prometheus:v2.1.0
Status: Downloaded newer image for prom/prometheus:v2.1.0
7c5d60cab0b09c669bbde525d5e9852dd415745d3ad4edac7223fff7a2a37ae6

$ docker ps
CONTAINER ID        IMAGE                    COMMAND                  CREATED
       STATUS              PORTS                    NAMES
7c5d60cab0b0        prom/prometheus:v2.1.0   "/bin/prometheus --c…"   55 seconds ago      Up 52 seconds       0.0.0.0:9090->9090/tcp   prometheus
```
* Prometheus запустился, веб-интерфес по умолчанию доступен на порту 9090
* Посмотреть адрес хоста `docker-machine ip docker-host2`

* Остановим контейнер
```
$ docker stop prometheus
```

### Переупорядочим структуру директорий
* Каталог docker-monolith командой git mv перенесён в созданный каталог docker. В него также перенесены файлы docker-compose и .env из каталога src

* Создан каталог monitoring/prometheus

### Конфигурация Prometheus
* Создам файл конфигурации
```
$ wget https://gist.githubusercontent.com/Nklya/bfe2d817f72bc6376fb7d05507e97a1d/raw/9de77435fd7cb626767f358a488d5346ca7f3a74/prometheus.yml
```
* Создаем образ
```
$ export USER_NAME=mrshadow74
$ docker build -t $USER_NAME/prometheus .
Successfully built 3a43299d4da1
Successfully tagged mrshadow74/prometheus:latest
```
## Образы микросервисов
### Сборка
```
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
```
или
```
/src/ui $ bash docker_build.sh
/src/post-py $ bash docker_build.sh
/src/comment $ bash docker_build.sh
```
* Внесены изменения в файл `docker-compose.yml`: директивы build заменены на image.
* Для сервисов в `docker/dockercompose.yml` добавлена секция network.
```
networks:
  - front_net
  - back_net
```

* Скорректирован файл `.env` под реалии
```
$ cat docker/.env
USERNAME=mrshadow74
POST_VERSION=latest
COMMENT_VERSION=latest
UI_VERSION=latest
APP_PORT=9292:9292
```

### Запуск микросервисов
* После всех изменений проведём запуск инфраструктуры
```
$ docker-compose up -d
Pulling post_db (mongo:3.2)...
3.2: Pulling from library/mongo
a92a4af0fb9c: Pull complete
74a2c7f3849e: Pull complete
927b52ab29bb: Pull complete
e941def14025: Pull complete
be6fce289e32: Pull complete
f6d82baac946: Pull complete
7c1a640b9ded: Pull complete
e8b2fc34c941: Pull complete
1fd822faa46a: Pull complete
61ba5f01559c: Pull complete
db344da27f9a: Pull complete
Digest: sha256:0463a91d8eff189747348c154507afc7aba045baa40e8d58d8a4c798e71001f3
Status: Downloaded newer image for mongo:3.2
Creating docker_ui_1         ... done
Creating docker_post_1       ... done
Creating docker_comment_1    ... done
Creating docker_prometheus_1 ... done
Creating docker_post_db_1    ... done
```
* Проверяем - Prometheus доступен и работает

## Мониторинг состояния микросервисов
* Список endpoint-ов `http://35.233.74.100:9090/targets`

### Healthchecks 
* Если требуемые для его работы сервисы здоровы, то healthcheck проверка возвращает status = 1, что соответсвует тому, что сам сервис здоров.
* Если один из нужных ему сервисов нездоров или недоступен, то проверка вернет status = 0.
* Остановим post сервис, посмотрим как это отразится на мониторинге, и запустим обратно
```
$ docker-compose stop post
Stopping starthealthchecks_post_1 ... done

$ docker-compose start post
Starting post ... done
```
* Аналогично для comment сервиса
```
$ docker-compose stop comment
Stopping docker_comment_1 ... done

$ docker-compose start comment
Starting comment ... done
```

## Сбор метрик хоста
* Exporters. Расширим файл `docker-compose.yml` контейнером для `node-exporter`
```
services:

  node-exporter:
    image: prom/node-exporter:v0.15.2
    user: root
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'
```

* Добавим в файл `prometheus.yml` запись для контроля за сервисом `node`
```
- job_name: 'node'
  static_configs:
    - targets:
      - 'node-exporter:9100'
```
* Соберем новый Docker для Prometheus
```
$ docker build -t $USER_NAME/prometheus .
```
* И перезапустим Prometheus
```
/docker$ docker-compose down
Stopping docker_post_db_1       ... done
Stopping docker_post_1          ... done
Stopping docker_node-exporter_1 ... done
Stopping docker_comment_1       ... done
Stopping docker_prometheus_1    ... done
Stopping docker_ui_1            ... done
Removing docker_post_db_1       ... done
Removing docker_post_1          ... done
Removing docker_node-exporter_1 ... done
Removing docker_comment_1       ... done
Removing docker_prometheus_1    ... done
Removing docker_ui_1            ... done
Removing network docker_back_net
Removing network docker_front_net
/docker$ docker-compose up -d
Creating network "docker_front_net" with the default driver
Creating network "docker_back_net" with the default driver
Creating docker_prometheus_1    ... done
Creating docker_post_db_1       ... done
Creating docker_comment_1       ... done
Creating docker_node-exporter_1 ... done
Creating docker_ui_1            ... done
Creating docker_post_1          ... done
```

* Выгрузим в DockerHub образы
```
$ docker login

$ docker push $USER_NAME/ui && docker push $USER_NAME/comment && docker push $USER_NAME/post && docker push $USER_NAME/prometheus
```

* Ссылки на образы
```
https://hub.docker.com/repository/docker/mrshadow74/prometheus
https://hub.docker.com/repository/docker/mrshadow74/post
https://hub.docker.com/repository/docker/mrshadow74/comment
https://hub.docker.com/repository/docker/mrshadow74/ui
```

## Задание со *

### Добавить в Prometheus мониторинг MongoDB

* Для выполнения задания буду использовать bitnami/mongodb-exporter версии latest. Дополню записью файл `docker-compose.yml`

```
mongodb-exporter:
  image: bitnami/mongodb-exporter:latest
  ports:
    - 9216:9216
  networks:
    - back_net
    - front_net
```

* Также добавлю в файл `prometheus.yml` запись о джобе mongod
```
- job_name: 'mongod'
  static_configs:
    - targets:
      - 'post_db:27017'
```

* Для работы экспортера в mongod создана отдельная учётная запись

### Добавить в Prometheus мониторинг сервисов comment, post, ui с помощью blackbox экспортера.
* Для выполнения задания буду использовать prom/blackbox-exporter версии latest. Дополню записью файл `docker-compose.yml`
```
blackbox-exporter:
  image: prom/blackbox-exporter:latest
  networks:
    - back_net
    - front_net
```
* Также добавлю в файл `prometheus.yml` запись о джобе
```
- job_name: 'blackbox'
  static_configs:
    - targets:
      - 'comment:80'
      - 'post:80'
      - 'ui:80'
```

* Создан `Makefile`

# Мониторинг приложения и инфраструктуры

## План
* Мониторинг Docker контейнеров
* Визуализация метрик
* Сбор метрик работы приложения и бизнес метрик
* Настройка и проверка алертинга

## Подготовка окружения
* Создадим Docker хост в GCE и настроим локальное окружение
```
$ export GOOGLE_PROJECT=global-incline-258416

$ docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-zone europe-west1-b \
 docker-host

$ eval $(docker-machine env docker-host)

$ docker-machine ip docker-host
35.240.56.196
```

## Мониторинг Docker контейнеров
* Разделим файлы Docker Compose
* Оставим описание приложений в `docker-compose.yml`, а мониторинг выделим в отдельный файл `docker-composemonitoring.yml`
* Для запуска приложений будем как и ранее использовать `docker-compose up -d`, а для мониторинга - `docker-compose -f docker-compose-monitoring.yml up -d`

## cAdvisor
* Будем использовать для наблюдения за состоянием наших Docker контейнеров.
* Дополним `docker-compose-monitoring.yml` следующей записью
```
cadvisor:
  image: google/cadvisor:v0.29.0
  volumes:
    - '/:/rootfs:ro'
    - '/var/run:/var/run:rw'
    - '/sys:/sys:ro'
    - '/var/lib/docker/:/var/lib/docker:ro'
  ports:
    - '8080:8080'
```
* Добавим информацию о новом сервисе в конфигурацию Prometheus, чтобы он начал собирать метрики
```
- job_name: 'cadvisor'
  static_configs:
    - targets:
      - 'cadvisor:8080'
```
* Пересоберем образ Prometheus с обновленной конфигурацией
```
$ export USER_NAME=mrshadow74
$ docker build -t $USER_NAME/prometheus .

Sending build context to Docker daemon  3.584kB
Step 1/2 : FROM prom/prometheus:v2.1.0
v2.1.0: Pulling from prom/prometheus
Image docker.io/prom/prometheus:v2.1.0 uses outdated schema1 manifest format. Please upgrade to a schema2 image for better future compatibility. More information at https://docs.docker.com/registry/spec/deprecated-schema-v1/
aab39f0bc16d: Pull complete
a3ed95caeb02: Pull complete
2cd9e239cea6: Pull complete
48afad9e6cdd: Pull complete
8fb7aa0e1c16: Pull complete
3b9d4fd63760: Pull complete
57a87cf4a659: Pull complete
9a31588e38ae: Pull complete
7a0ac0080f04: Pull complete
659e24e6d37f: Pull complete
Digest: sha256:7b987901dbc44d17a88e7bda42dbbbb743c161e3152662959acd9f35aeefb9a3
Status: Downloaded newer image for prom/prometheus:v2.1.0
 ---> c8ecf7c719c1
Step 2/2 : ADD prometheus.yml /etc/prometheus/
 ---> 0be36d79b399
Successfully built 0be36d79b399
Successfully tagged mrshadow74/prometheus:latest
```
* Запустим сервисы
```
$ docker-compose up -d
Creating docker_ui_1      ... done
Creating docker_post_db_1 ... done
Creating docker_post_1    ... done
Creating docker_comment_1 ... done

$ docker-compose -f docker-compose-monitoring.yml up -d
Creating docker_blackbox-exporter_1 ... done
Creating docker_prometheus_1        ... done
Creating docker_mongodb-exporter_1  ... done
Creating docker_node-exporter_1     ... done
Creating docker_cadvisor_1          ... done
```

* Создадим правила для фаервола
```
$ gcloud compute firewall-rules create cadvisor-allow --allow tcp:8080
$ gcloud compute firewall-rules create prometheus-default-allow --allow tcp:9090
```

* Откроем `http://35.240.56.196:8080`, зайдем в интерфейс cAdvisor UI
* Откроем `http://35.240.56.196:8080/metrics`, зайдем в интерфейс cAdvisor UI, посмотрим на список собираемых метрик. Имена метрик контейнеров начинаются со слова
container.

## Визуализация метрик: Grafana

* Используем инструмент Grafana для визуализации данных из Prometheus. Добавим новый сервис в `docker-compose-monitoring.yml`

```
  grafana:
    image: grafana/grafana:5.0.0
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=secret
    depends_on:
      - prometheus
    ports:
      - 3000:3000

volumes:
  grafana_data:
```

### Grafana: Web UI
* Создадим новое правило для файрвола и запустим новый сервис
* И добавим сразу правило в файрвол
```
$ gcloud compute firewall-rules create grafana-allow --allow tcp:3000

$ docker-compose -f docker-compose-monitoring.yml up -d grafana
```

* Grafana: Добавление источника данных
* Add data source, зададим нужный тип и параметры подключения
```
Name: Prometheus Server
Type: Prometheus
URL: http://prometheus:9090
Access: Proxy
```

### Дашборды Grafana

* На сайте `https://grafana.com/grafana/dashboards` можно найти и скачать большое
количество уже созданных официальных и комьюнити дашбордов для визуализации различного типа метрик для разных систем мониторинга и баз данных

* В директории monitoring создадим директории grafana/dashboards, куда поместим скачанный дашборд с именем `DockerMonitoring.json`

* Загрузим JSON для дашборда Docker and system monitoring в директорию grafana/dashboards с именем `DockerMonitoring.json`

* Добавим в файл `prometheus.yml` информацию о post-сервисе
```
- job_name: 'post'
  static_configs:
    - targets:
    - 'post:5000'
```

* И добавим сразу правило в файрвол
```
$ gcloud compute firewall-rules create grafana-post-allow --allow tcp:5000
```

* Пересоберем образ Prometheus с обновленной конфигурацией
```
$ export USER_NAME=mrshadow74
$ docker build -t $USER_NAME/prometheus .
```

* Пересоздадим Docker инфраструктуру мониторинга и добавим несколько постов в приложении и несколько комментов, чтобы собрать значения метрик приложения
```
$ docker-compose -f docker-compose-monitoring.yml down
$ docker-compose -f docker-compose-monitoring.yml up -d
```
* Создадим дашбор `ui_request_count`
* Создадим дашбор `ui_request_count` с выводом графика ошибок 4хх и 5хх
```
rate(ui_request_count{http_status=~"^[45].*"}[1m])
```

* Изменим базовый график `ui_request_count`, модифицировав его по аналогии с 
```
rate(ui_request_count{http_status=~"^[2].*"}[1m])
```
* Создана гистограмма 95%
```
histogram_quantile(0.95, sum(rate(ui_request_latency_seconds_bucket[5m])) by (le))
```

* Выгружен дашборд в файл `UI_Service_Monitoring.json`

## Сбор метрик бизнес-логики

### Мониторинг бизнес-логики

* Создадим новый дашборд, назовем его *Business_Logic_Monitoring* и построим графики с  функциями `rate(post_count[1h])` и `rate(comment_count[1h])`
* Выгружен дашборд в файл `Business_Logic_Monitoring.json`

## Алертинг

### Alertmanager

* Alertmanager - дополнительный компонент для системы мониторинга Prometheus, который отвечает за первичную обработку алертов и дальнейшую отправку оповещений по
заданному назначению. Создадим новую директорию monitoring/alertmanager. В этой
директории создам Dockerfile со следующим содержимым:
```
FROM prom/alertmanager:v0.14.0
ADD config.yml /etc/alertmanager/
```
* Настройки Alertmanager-а как и Prometheus задаются через YAML файл или опции командой строки. В директории monitoring/alertmanager создам файл config.yml, в котором определим отправку нотификаций в тестовый слак канал.

* Соберем образ alertmanager
```
$ docker build -t $USER_NAME/alertmanager . 
```

* Добавим новый сервис в компоуз файл мониторинга
```
alertmanager:
  image: ${USER_NAME}/alertmanager
  command:
    - '--config.file=/etc/alertmanager/config.yml'
  ports:
    - 9093:9093
```
* Создадим правило файрвола
```
$ gcloud compute firewall-rules create altermanager-allow --allow tcp:9093
```

### Alert rules
* Создадим файл alerts.yml
```
groups:
  - name: alert.rules
    rules:
    - alert: InstanceDown
      expr: up == 0
      for: 1m
      labels:
        severity: page
      annotations:
        description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute'
        summary: 'Instance {{ $labels.instance }} down'
```
* Добавим операцию копирования данного файла в Dockerfile
```
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
ADD alerts.yml /etc/prometheus/
```
* Добавим информацию о правилах в конфиг Prometheus
```
rule_files:
  - "alerts.yml"

alerting:
  alertmanagers:
  - scheme: http
    static_configs:
    - targets:
      - "alertmanager:9093"
```

* Пересоберем образ Prometheus
```
$ docker build -t $USER_NAME/prometheus .
```

### Проверка алерта

* Пересоздадим нашу Docker инфраструктуру мониторинга
```
$ docker-compose -f docker-compose-monitoring.yml down
$ docker-compose -f docker-compose-monitoring.yml up -d
```

* Проверка алерта. Остановим один из сервисов и подождем одну минуту
```
$ docker-compose stop post
```
* Прилетел алерт в слак
* Выгрузить образы в DockerHub
```
$ docker login
$ docker push $USER_NAME/ui
$ docker push $USER_NAME/comment
$ docker push $USER_NAME/post
$ docker push $USER_NAME/prometheus
$ docker push $USER_NAME/alertmanager
```

### Задание со *
* Добавлены записи в `Makefile` для запуска мониторинга

### Задание с **


### Задание с ***

# Homework 18. Логирование и распределенная трассировка

## План
 - Сбор неструктурированных логов
 - Визуализация логов
 - Сбор структурированных логов
 - Распределенная трасировка

* Обновлен код приложения из репозитория `https://github.com/express42/reddit/tree/logging`
```
$ git clone --branch=logging  https://github.com/express42/reddit.git
```
* Выполнить сборку образов
```
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
```

## Подготовка окружения
* Создадим Docker хост в GCE и настроим локальное окружение
```
$ export GOOGLE_PROJECT=global-incline-258416

$ docker-machine create --driver google \
  --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
  --google-machine-type n1-standard-1 \
  --google-zone europe-west1-b \
  --google-open-port 5601/tcp \
  --google-open-port 9292/tcp \
  --google-open-port 9411/tcp \
  logging

$ eval $(docker-machine env logging)

$ docker-machine ip logging
34.76.21.75
```

## Логирование Docker контейнеров
## Elastic Stack: ELK - EFK
* Elastic стек включает в себя 3 осовных компонента:
 - ElasticSearch (TSDB и поисковый движок для хранения данных)
 - Logstash (для агрегации и трансформации данных)
 - Kibana (для визуализации)

* Вместо Logstash мы будем использовать Fluentd, получим EFK.
* В каталоге `docker` создадим файл `docker-compose-logging.yml`
```
wget https://raw.githubusercontent.com/express42/otus-snippets/master/hw-25/docker-compose-logging1.yml
```

## Fluentd
* Создадим в вашем проекте *microservices* директорию `logging/fluentd`, внутри создадим `Dockerfile`
```
FROM fluent/fluentd:v0.12
RUN gem install fluent-plugin-elasticsearch --no-rdoc --no-ri --version 1.9.5
RUN gem install fluent-plugin-grok-parser --no-rdoc --no-ri --version 1.0.0
ADD fluent.conf /fluentd/etc
```

* В директории `logging/fluentd` создадим файл конфигурации `fluent.conf`
```
wget https://raw.githubusercontent.com/express42/otus-snippets/master/hw-25/fluent.conf
```

* Соберем docker image для fluentd
```
docker build -t $USER_NAME/fluentd .
```

## Структурированные логи
* Лог-сообщения также должны иметь понятный для выбранной системы логирования формат, чтобы избежать ненужной траты ресурсов на преобразование данных в нужный вид. Структурированные логи мы рассмотрим на примере сервиса post.

* Правим `.env` файл и меняем теги приложения на logging, после чего запустим сервисы приложения `$ docker-compose up -d` и выполним команду для просмотра логов post сервиса `docker-compose logs -f post`
```
$ docker-compose logs -f post
Attaching to docker_post_1
post_1     | {"addr": "172.28.0.3", "event": "request", "level": "info", "method": "GET", "path": "/healthcheck?", "request_id": null, "response_status": 200, "service"
: "post", "timestamp": "2019-12-19 20:38:19"}
post_1     | {"addr": "172.28.0.3", "event": "request", "level": "info", "method": "GET", "path": "/healthcheck?", "request_id": null, "response_status": 200, "service"
: "post", "timestamp": "2019-12-19 20:38:19"}
post_1     | {"addr": "172.28.0.3", "event": "request", "level": "info", "method": "GET", "path": "/healthcheck?", "request_id": null, "response_status": 200, "service"
: "post", "timestamp": "2019-12-19 20:38:24"}
post_1     | {"addr": "172.28.0.3", "event": "request", "level": "info", "method": "GET", "path": "/healthcheck?", "request_id": null, "response_status": 200, "service"
: "post", "timestamp": "2019-12-19 20:38:24"}
post_1     | {"addr": "172.28.0.3", "event": "request", "level": "info", "method": "GET", "path": "/healthcheck?", "request_id": null, "response_status": 200, "service"
: "post", "timestamp": "2019-12-19 20:38:29"}
```
* Создадим несколько новых постов и посмотрим, как это отразится в логах
```
post_1     | {"event": "post_create", "level": "info", "message": "Successfully created a new post", "params": {"link": "http://www2.ru", "title": "test post2"}, "request_id": "48c1177e-bf6d-4a3f-8f21-e4660925e89c", "service": "post", "timestamp": "2019-12-19 20:43:47"}
post_1     | {"addr": "172.28.0.3", "event": "request", "level": "info", "method": "POST", "path": "/add_post?", "request_id": "48c1177e-bf6d-4a3f-8f21-e4660925e89c", "response_status": 200, "service": "post", "timestamp": "2019-12-19 20:43:47"}
post_1     | {"event": "find_all_posts", "level": "info", "message": "Successfully retrieved all posts from the database", "params": {}, "request_id": "433f4c67-11cf-4055-871e-2503b4f926f7", "service": "post", "timestamp": "2019-12-19 20:43:47"}
post_1     | {"addr": "172.28.0.3", "event": "request", "level": "info", "method": "GET", "path": "/posts?", "request_id": "433f4c67-11cf-4055-871e-2503b4f926f7", "response_status": 200, "service": "post", "timestamp": "2019-12-19 20:43:47"}
```


## Отправка логов во Fluentd
* Для отправки логов во Fluentd используем docker драйвер fluentd `https://docs.docker.com/config/containers/logging/fluentd/`

* Определим драйвер для логирования для сервиса post внутри `docker-compose.yml`
```
services:
  post:
    image: ${USER_NAME}/post
    environment:
      - POST_DATABASE_HOST=post_db
      - POST_DATABASE=posts
    depends_on:
      - post_db
    ports:
      - "5000:5000"
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.post
```

* Перезапустим сервисы приложения и логгирования
```
$ docker-compose -f docker-compose-logging.yml up -d
$ docker-compose down
$ docker-compose up -d
```

## Kibana
* Проверяем запуск Kibana `http://35.241.212.235:5601`, получаем ответ
```
Kibana server is not ready yet
```
* Проверим запущенные контейнеры
```
$ docker-compose -f docker-compose-logging.yml ps

         Name                       Command                State                               Ports
--------------------------------------------------------------------------------------------------------------------------------
docker_elasticsearch_1   /usr/local/bin/docker-entr ...   Exit 78
docker_fluentd_1         tini -- /bin/entrypoint.sh ...   Up        0.0.0.0:24224->24224/tcp, 0.0.0.0:24224->24224/udp, 5140/tcp
docker_kibana_1          /usr/local/bin/dumb-init - ...   Up        0.0.0.0:5601->5601/tcp
```

* Посмотрим, что случилось с elasticsearch
```
$ docker-compose -f docker-compose-logging.yml logs elasticsearch

elasticsearch_1  | ERROR: [2] bootstrap checks failed
elasticsearch_1  | [1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
elasticsearch_1  | [2]: the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured
```
* Решение проблемы тут `https://github.com/deviantony/docker-elk/issues/243`
* Лечим проблему, дополним конфиг переменными
```
    image: elasticsearch:7.5.0
    environment:
      - node.name=elasticsearch
      - cluster.name=docker-cluster
      - node.master=true
      - cluster.initial_master_nodes=elasticsearch
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    ulimits:
      memlock:
        soft: -1
        hard: -1
```

* Перезапустим логгинг, проверим
```
$ make stop-logging run-logging

$ docker-compose -f docker-compose-logging.yml ps
         Name                       Command               State                              Ports
------------------------------------------------------------------------------------------------------------------------------
docker_elasticsearch_1   /usr/local/bin/docker-entr ...   Up      0.0.0.0:9200->9200/tcp, 0.0.0.0:9300->9300/tcp
docker_fluentd_1         tini -- /bin/entrypoint.sh ...   Up      0.0.0.0:24224->24224/tcp, 0.0.0.0:24224->24224/udp, 5140/tcp
docker_kibana_1          /usr/local/bin/dumb-init - ...   Up      0.0.0.0:5601->5601/tcp
```
### Фильтры
* Добавим фильтр для парсинга json логов, приходящих от post сервиса, в конфиг `logging/fluentd/fluent.conf`
```
<filter service.post>
@type parser
format json
key_name log
</filter>
```
* Перезапустим сервис fluentd
```
$ docker-compose -f docker-compose-logging.yml up -d fluentd
$ docker-compose -f docker-compose-logging.yml ps
         Name                       Command               State                              Ports
------------------------------------------------------------------------------------------------------------------------------
docker_elasticsearch_1   /usr/local/bin/docker-entr ...   Up      0.0.0.0:9200->9200/tcp, 9300/tcp
docker_fluentd_1         tini -- /bin/entrypoint.sh ...   Up      0.0.0.0:24224->24224/tcp, 0.0.0.0:24224->24224/udp, 5140/tcp
docker_kibana_1          /usr/local/bin/dumb-init - ...   Up      0.0.0.0:5601->5601/tcp
```

* Для корректного разбора логов необходимо использовать более высокую версию `fluent-plugin-elasticsearch`, скорректирован `Dockerfile` до версии 1.18.1. Можно поднимать версию выше, если есть необходимость.

## Неструктурированные логи
* Неструктурированные логи отличаются отсутствием четкой структуры данных. Также часто бывает, что формат лог-сообщений не подстроен под систему централизованного логирования, что существенно увеличивает затраты вычислительных и временных ресурсов на обработку данных и выделение нужной информации. На примере сервиса ui рассмотрим пример логов с неудобным форматом сообщений.

### Логирование UI сервиса
* По аналогии с post сервисом определим для ui сервиса драйвер для логирования fluentd в `docker/docker-compose.yml`
```
 ui:
    image: ${USERNAME}/ui:${UI_VERSION}
    environment:
      - POST_SERVICE_HOST=post
      - POST_SERVICE_PORT=5000
      - COMMENT_SERVICE_HOST=comment
      - COMMENT_SERVICE_PORT=9292
    ports:
      - ${APP_PORT}/tcp
    depends_on:
      - post
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.ui
    networks:
      - front_net
```

* Перезапустим ui сервис
```
$ docker-compose stop ui
$ docker-compose rm ui
$ docker-compose up -d
```

### Парсинг логов ui-сервиса
* Добавим в `/docker/fluentd/fluent.conf` регулярное выражение для разбора не структурированных логов
```
<filter service.ui>
  @type parser
  format /\[(?<time>[^\]]*)\]  (?<level>\S+) (?<user>\S+)[\W]*service=(?<service>\S+)[\W]*event=(?<event>\S+)[\W]*(?:path=(?<path>\S+)[\W]*)?request_id=(?<request_id>\S+)[\W]*(?:remote_addr=(?<remote_addr>\S+)[\W]*)?(?:method= (?<method>\S+)[\W]*)?(?:response_status=(?<response_status>\S+)[\W]*)?(?:message='(?<message>[^\']*)[\W]*)?/
  key_name log
</filter>
```

* Пересоберем образ fluentd и перезапустим kibana для применения изменений

```
$ docker-compose -f docker-compose-logging.yml down
$ docker-compose -f docker-compose-logging.yml up -d
```

* Созданные регулярки могут иметь ошибки, их сложно менять и невозможно читать. Для облегчения задачи парсинга вместо стандартных регулярок можно использовать grok-шаблоны. По-сути grok’и - это именованные шаблоны регулярных выражений (очень похоже на функции). Можно использовать готовый regexp, просто сославшись на него как на функцию `fluent.conf`.
```
<filter service.ui>
@type parser
format grok
grok_pattern %{RUBY_LOGGER}
key_name log
</filter>
```
### Задания co *

* UI-сервис шлет логи в нескольких форматах. Такой лог остался неразобранным. Необходимо составить конфигурацию fluentd так, чтобы разбирались оба формата логов UI-сервиса (тот, что сделали до этого и текущий) одновременно.

* Используя документацию `https://github.com/fluent/fluent-plugin-grok-parser/blob/master/README.md` и готовые шаблоны `https://github.com/fluent/fluent-plugin-grok-parser/tree/master/patterns` 

```
<filter service.ui>
  @type parser
  format grok
  <grok>
    pattern service=%{WORD:service} \| event=%{WORD:event} \| request_id=%{GREEDYDATA:request_id} \| message='%{GREEDYDATA:message}'
  </grok>
  <grok>
    pattern event=%{WORD:event} \| method= %{WORD:message} \| path=%{URIPATH:path} \| remote_addr=%{IP:remote_addr} \| response_status=%{INT:response_status} \| request_id=%{GREEDYDATA:request_id} \| service=%{WORD:service} \|
  </grok>
  key_name message
  reserve_data true
</filter>
```

## Распределенный трейсинг. Zipkin

* Добавим в `compose-файл` для сервисов логирования сервис распределенного трейсинга *Zipkin*
```
services:
  zipkin:
    image: openzipkin/zipkin
    ports:
      - "9411:9411"
```
* Правим наш `docker-compose.yml`, добавив для каждого сервиса поддержку ENV переменных и зададим параметризованный параметр ZIPKIN_ENABLED
```
environment:
- ZIPKIN_ENABLED=${ZIPKIN_ENABLED}
```

* В .env файле укажем `ZIPKIN_ENABLED=true` и перевыкатим приложение `docker-compose up -d`

* Zipkin должен быть в одной сети с приложениями, поэтому нужно объявить эти сети в
`docker-compose-logging.yml`

```
services:
  zipkin:
    image: openzipkin/zipkin
    ports:
      - "9411:9411"
    networks:
      - front_net
      - back_net
```

* Пересоздадим наши сервисы, откроем Zipkin WEB UI на порту 9411, пока никаких трейсов поиск не выдает, т.к. никаких запросов нашему приложению еще не поступало.

```
$ docker-compose -f docker-compose-logging.yml -f docker-compose.yml down
$ docker-compose -f docker-compose-logging.yml -f docker-compose.yml up -d
```

* Откроем главную страницу приложения и обновим ее несколько раз. Заглянув затем в UI Zipkin, увидим несколько трейсов. Нажмем на один из трейсов, чтобы посмотреть, как запрос шел через нашу систему микросервисов и каково общее время обработки запроса у нашего приложения при запросе главной страницы.
* Видим, что первым делом наш запрос попал к ui сервису, который смог обработать наш запрос за суммарное время равное 187.566 ms.
* Из этих 187 ms ушло 134.155ms на то чтобы ui мог направить запрос post сервису по пути /posts и получить от него ответ в виде списка постов. Post сервис в свою очередь использовал функцию обращения к БД за списком постов, на что ушло 4.827 ms.

### Самостоятельное задание со *
* С нашим приложением происходит что-то странное. Пользователи жалуются, что при нажатии на пост они вынуждены долго ждать, пока у них загрузится страница с постом. Жалоб на загрузку других страниц не поступало. Нужно выяснить, в чем проблема, используя Zipkin. Код сломанного приложения берём здесь `https://github.com/Artemmkin/bugged-code`
```
git clone https://github.com/Artemmkin/bugged-code.git
```
* Скорректируем файлы `docker-build.sh` каждого компонента, назначив тег bugged, соберем их и опубликуем в dockerhub
* На основе файла `docker-compose.yml` создадим файл `docker-compose-bugged.yml`, в котором будем запускать приложения с тегом bugged.
* Теперь остановим наше рабочее приложение и на его место запустим поломанное.
```
$ docker-compose down
$ docker-compose -f docker-compose-bugg.yml up -d
```
* Приложение работает, визуально всё хорошо. Создан новый пост, всё в норме. При попытке посмотреть созданный пост возникает задумчивая задержка в 3 секунды.
* Анализ спанов в zipkin показал, что резко, до 3s возросло время работы приложения post. Причиной этому может быть несколько вариантов ошибок в коде приложения, например: зацикливание или залипание приложения. Попробуем их поискать.
* Греп по каталогу приложения `post-py` показал наличие записи `time.sleep(3)` в 167 строке кода приложения. По этой причине и возникает пауза в 3 секунды на выполнение.

# HW #19. Введение в Kubernetes

* Цели
 - Разобрать на практике все компоненты Kubernetes, развернуть их вручную используя The Hard Way;
 - Ознакомиться с описанием основных примитивов нашего приложения и его дальнейшим запуском в Kubernetes.

## Создание примитивов

* Опишем приложение в контексте Kubernetes с помощью manifest-ов в YAML-формате. Основным примитивом будет Deployment. Основные задачи сущности Deployment:
 - Создание Replication Controller-а (следит, чтобы число запущенных Pod-ов соответствовало описанному);
 - Ведение истории версий запущенных Pod-ов (для различных стратегий деплоя, для возможностей отката);
 - Описание процесса деплоя (стратегия, параметры стратегий).

* По ходу курса эти манифесты будут обновляться, а также появляться новые. Текущие файлы нужны для создания структуры и проверки работоспособности kubernetes-кластера.
* Для выполнения задания создадим директорию `kubernetes`, в ней поддиректорию `reddit`.
* Сохраним файл `post-deployment.yml` в директории `kubernetes/reddit`
* Создадим собственные файлы с Deployment манифестами приложений и сохраним их в папке `kubernetes/reddit`:

```
ui-deployment.yml
comment-deployment.yml
mongo-deployment.yml
```

## Kubernetes The Hard Way

* В качестве домашнего задания необходимо пройти *Kubernetes The Hard Way* `https://github.com/kelseyhightower/kubernetes-the-hard-way`, разработанный инженером Google Kelsey Hightower. Туториал представляет собой:
 - Пошаговое руководство по ручной инсталляции основных компонентов Kubernetes кластера;
 - Краткое описание необходимых действий и объектов.

## Прохождение Kubernetes The Hard Way
## Подготовка
* Создадим отдельную директорию the_hard_way в директории kubernetes
* Проверим версию Google Cloud, требуется не ниже 262.0.0
```
$ gcloud version
Google Cloud SDK 274.0.0
alpha 2019.12.17
beta 2019.12.17
bq 2.0.51
core 2019.12.17
gsutil 4.46
kubectl 2019.12.17
```
* Зададим регион и тайм-зону для Google Cloud
```
$ gcloud config set compute/region us-west1
$ gcloud config set compute/zone us-west1-c
```

## Установка клиентских тулзов
* Следующим шагом необходимо установить клиентские тулзы *cfssl, cfssljson и kubectl*
* *cfssl* и *cfssljson* являются утилитами командной строки для генерации TLS сертификатов

```
$ wget -q --show-progress --https-only --timestamping \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssl \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssljson
$ chmod +x cfssl cfssljson
$ sudo mv cfssl cfssljson /usr/local/bin/
```

* Проверим, что версии установленных *cfssl* и *cfssljson* 1.3.4 или выше
```
$ cfssl version
Version: 1.3.4
Revision: dev
Runtime: go1.13

$ cfssljson --version
Version: 1.3.4
Revision: dev
Runtime: go1.13
```

* *kubectl* является утилитой коамндной строки для взаимодействия с Kubernetes API Server.
```
$ wget https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl
$ chmod +x kubectl
$ sudo mv kubectl /usr/local/bin/
```

* Проверим версию *kubectl*, она должна быть 1.15.3 или выше
```
$ kubectl version --client
Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.3", GitCommit:"2d3c76f9091b6bec110a5e63777c332469e0cba2", GitTreeState:"clean", BuildDate:"2019-08-19T11:13:54Z", GoVersion:"go1.12.9", Compiler:"gc", Platform:"linux/amd64"}
```

## Подготовка вычислительных мощностей

* Kubernetes требует набор машин и хоста управления Kubernetes, на которых будут запускаться контейнеры. В конечном счете на эти вычислительные ресурсы потребуются для безопасного запуска и обеспечения высокой доступности кластера Kubernetes в одной зоне.

### Сеть. Виртуальная частная облачная сеть

* Kubernetes предполагает плоскую сеть из контейнеров и нод, которые взоимодействуют друг с другом и внешними сетевыми ресурсами. 
* Создадим частную сеть
```
$ gcloud compute networks create kubernetes-the-hard-way --subnet-mode custom
Created [https://www.googleapis.com/compute/v1/projects/global-incline-258416/global/networks/kubernetes-the-hard-way].
NAME                     SUBNET_MODE  BGP_ROUTING_MODE  IPV4_RANGE  GATEWAY_IPV4
kubernetes-the-hard-way  CUSTOM       REGIONAL

Instances on this network will not be reachable until firewall rules
are created. As an example, you can allow all internal traffic between
instances as well as SSH, RDP, and ICMP by running:

$ gcloud compute firewall-rules create <FIREWALL_NAME> --network kubernetes-the-hard-way --allow tcp,udp,icmp --source-ranges <IP_RANGE>
$ gcloud compute firewall-rules create <FIREWALL_NAME> --network kubernetes-the-hard-way --allow tcp:22,tcp:3389,icmp
```

* Создадим подсеть
```
$ gcloud compute networks subnets create kubernetes
\
>   --network kubernetes-the-hard-way \
>   --range 10.240.0.0/24

Created [https://www.googleapis.com/compute/v1/projects/global-incline-258416/regions/us-west1/subnetworks/kubernetes].
NAME        REGION    NETWORK                  RANGE
kubernetes  us-west1  kubernetes-the-hard-way  10.240.0.0/24
```

* Создадим правило для файрвола, разрешающее любой внутренний трафик в нашей сети
```
$ gcloud compute firewall-rules create kubernetes-the-hard-way-allow-internal \
>   --allow tcp,udp,icmp \
>   --network kubernetes-the-hard-way \
>   --source-ranges 10.240.0.0/24,10.200.0.0/16
Creating firewall...⠧Created [https://www.googleapis.com/compute/v1/projects/global-incline-258416/global/firewalls/kubernetes-the-hard-way-allow-internal].
Creating firewall...done.
NAME                                    NETWORK                  DIRECTION  PRIORITY  ALLOW         DENY  DISABLED
kubernetes-the-hard-way-allow-internal  kubernetes-the-hard-way  INGRESS    1000      tcp,udp,icmp        False
```

* Создадим правила для файрвола, разрешающие внешний трафик на нашу сеть по протоколам SSH, ICMP, HTTPS
```
$ gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external \
>   --allow tcp:22,tcp:6443,icmp \
>   --network kubernetes-the-hard-way \
>   --source-ranges 0.0.0.0/0
Creating firewall...⠧Created [https://www.googleapis.com/compute/v1/projects/global-incline-258416/global/firewalls/kubernetes-the-hard-way-allow-external].
Creating firewall...done.
NAME                                    NETWORK                  DIRECTION  PRIORITY  ALLOW                 DENY  DISABLED
kubernetes-the-hard-way-allow-external  kubernetes-the-hard-way  INGRESS    1000      tcp:22,tcp:6443,icmp        False
``` 

* Проверим список созданных нами правил
```
$ gcloud compute firewall-rules list --filter="network:kubernetes-the-hard-way"
NAME                                    NETWORK                  DIRECTION  PRIORITY  ALLOW                 DENY  DISABLED
kubernetes-the-hard-way-allow-external  kubernetes-the-hard-way  INGRESS    1000      tcp:22,tcp:6443,icmp        False
kubernetes-the-hard-way-allow-internal  kubernetes-the-hard-way  INGRESS    1000      tcp,udp,icmp                False
```

### Сеть. Публичный адрес для Kubernetes API Server
* Закрепим внешний ip-адрес за внешним балансировщиком нагрузки для Kubernetes API Server
```
$ gcloud compute addresses create kubernetes-the-hard-way \
>   --region $(gcloud config get-value compute/region)
Your active configuration is: [docker]
Created [https://www.googleapis.com/compute/v1/projects/global-incline-258416/regions/us-west1/addresses/kubernetes-the-hard-way].
```

* Проверим, что адрес действительно закреплен
```
$ gcloud compute addresses list --filter="name=('kubernetes-the-hard-way')"
NAME                     ADDRESS/RANGE  TYPE      PURPOSE  NETWORK  REGION    SUBNET  STATUS
kubernetes-the-hard-way  35.247.90.171  EXTERNAL                    us-west1          RESERVED
```

### Инстансы. Kubernetes Controllers
* Создадим инстансы для управления Kubernetes
```
$ for i in 0 1 2; do
>   gcloud compute instances create controller-${i} \
>     --async \
>     --boot-disk-size 200GB \
>     --can-ip-forward \
>     --image-family ubuntu-1804-lts \
>     --image-project ubuntu-os-cloud \
>     --machine-type n1-standard-1 \
>     --private-network-ip 10.240.0.1${i} \
>     --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
>     --subnet kubernetes \
>     --tags kubernetes-the-hard-way,controller
> done

NOTE: The users will be charged for public IPs when VMs are created.
Instance creation in progress for [controller-0]: https://www.googleapis.com/compute/v1/projects/global-incline-258416/zones/us-west1-c/operations/operation-1577293290823-59a8a364e5f70-31b11fc5-d800103f
Use [gcloud compute operations describe URI] command to check the status of the operation(s).
NOTE: The users will be charged for public IPs when VMs are created.
Instance creation in progress for [controller-1]: https://www.googleapis.com/compute/v1/projects/global-incline-258416/zones/us-west1-c/operations/operation-15772932939
12-59a8a367d8117-d26805b2-de2a7547
Use [gcloud compute operations describe URI] command to check the status of the operation(s).
NOTE: The users will be charged for public IPs when VMs are created.
Instance creation in progress for [controller-2]: https://www.googleapis.com/compute/v1/projects/global-incline-258416/zones/us-west1-c/operations/operation-15772932969
63-59a8a36ac110a-9ed36c32-799262df
Use [gcloud compute operations describe URI] command to check the status of the operation(s).
```

### Инстансы. Kubernetes Workers
* Каждому воркеру требуется выделение подсети pod из диапазона CIDR кластера Kubernetes. Выделенные подсети под будет использоваться для настройки сети контейнера в дальнейшем. Метаданные `pod-cidr` инстанса будет использоваться, чтобы предоставить `pod`  подсеть для распределения вычислительных мощностей во время выполнения.
```
$ for i in 0 1 2; do
>   gcloud compute instances create worker-${i} \
>     --async \
>     --boot-disk-size 200GB \
>     --can-ip-forward \
>     --image-family ubuntu-1804-lts \
>     --image-project ubuntu-os-cloud \
>     --machine-type n1-standard-1 \
>     --metadata pod-cidr=10.200.${i}.0/24 \
>     --private-network-ip 10.240.0.2${i} \
>     --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
>     --subnet kubernetes \
>     --tags kubernetes-the-hard-way,worker
> done
NOTE: The users will be charged for public IPs when VMs are created.
Instance creation in progress for [worker-0]: https://www.googleapis.com/compute/v1/projects/global-incline-258416/zones/us-west1-c/operations/operation-1577293877626-59a8a5948453b-fae68c29-0127b332
Use [gcloud compute operations describe URI] command to check the status of the operation(s).
NOTE: The users will be charged for public IPs when VMs are created.
Instance creation in progress for [worker-1]: https://www.googleapis.com/compute/v1/projects/global-incline-258416/zones/us-west1-c/operations/operation-1577293880836-59a8a59793fa8-daf4d9d8-70bfa33c
Use [gcloud compute operations describe URI] command to check the status of the operation(s).
NOTE: The users will be charged for public IPs when VMs are created.
Instance creation in progress for [worker-2]: https://www.googleapis.com/compute/v1/projects/global-incline-258416/zones/us-west1-c/operations/operation-1577293883933-59a8a59a88306-4d54ba44-badba654
Use [gcloud compute operations describe URI] command to check the status of the operation(s).
```

* Проверим результат
```
$ gcloud compute instances list
NAME          ZONE            MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
logging       europe-west1-b  n1-standard-1               10.132.0.26                 TERMINATED
nginx-labs    europe-west3-c  g1-small                    10.156.0.4                  TERMINATED
controller-0  us-west1-c      n1-standard-1               10.240.0.10  34.82.132.218  RUNNING
controller-1  us-west1-c      n1-standard-1               10.240.0.11  35.230.19.127  RUNNING
controller-2  us-west1-c      n1-standard-1               10.240.0.12  35.247.2.108   RUNNING
worker-0      us-west1-c      n1-standard-1               10.240.0.20  34.82.130.131  RUNNING
worker-1      us-west1-c      n1-standard-1               10.240.0.21  34.82.247.37   RUNNING
worker-2      us-west1-c      n1-standard-1               10.240.0.22  35.247.19.164  RUNNING
```

### Настройка доступа по SSH
* SSH будет использоваться для конфигурирования инстансов контроллеров и воркеров. Проверим доступ по SSH к инстансу `controller-0`
```
$ gcloud compute ssh controller-0
WARNING: The public SSH key file for gcloud does not exist.
WARNING: The private SSH key file for gcloud does not exist.
WARNING: You do not have an SSH key for gcloud.
WARNING: SSH keygen will be executed to generate a key.
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/eaa/.ssh/google_compute_engine.
Your public key has been saved in /home/eaa/.ssh/google_compute_engine.pub.
The key fingerprint is:
SHA256:PNgz1pauG+mSHYmhTe4DBhHGy7ITkYg9UJc4Bj8P1W0 eaa@noname
The key's randomart image is:
+---[RSA 2048]----+
|=B+ooo .         |
|=oOo. . E        |
| ++=   .         |
|o ++  o+ . .     |
| + ..=.oS.+      |
|o   + +.oB       |
| . . o oo..      |
|      =..o       |
|       o+.       |
+----[SHA256]-----+
Updating project ssh metadata...⠹Updated [https://www.googleapis.com/compute/v1/projects/global-incline-258416].
Updating project ssh metadata...done.
Waiting for SSH key to propagate.

Last login: Thu Dec 26 05:49:10 2019 from 85.140.23.65
eaa@controller-0:~$ exit
logout
Connection to 34.82.132.218 closed.
```

### Подготовка СА и генерация TLS сертификатов
* В данной работе мы подготавливаем PKI Инфраструктуру используя CloudFlare's PKI тулзы; cfssl, когда используется начальная загрузка CA, и генерация сертификатов следующих компонентов: etcd, kube-apiserver, kube-controller-manager, kube-scheduler, kubelet, and kube-proxy.

### CA
* Сгенерим для СА конфигурационный файл, сертификат и приватный ключ
```
{

cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

}
2019/12/26 11:53:37 [INFO] generating a new CA key and certificate from CSR
2019/12/26 11:53:37 [INFO] generate received request
2019/12/26 11:53:37 [INFO] received CSR
2019/12/26 11:53:37 [INFO] generating key: rsa-2048
2019/12/26 11:53:37 [INFO] encoded CSR
2019/12/26 11:53:37 [INFO] signed certificate with serial number 585888141182873940981144770666619312126110486843
```

### Клиентский и серверный сертификаты
* В данном разделе мы должны сгенерировать клиентский и серверный сертификаты для каждого компонента Kubernetes и клиентский сертификат для пользователя `admin` в Kubernetes.

### Клиентский сертификат пользователя admin
* Сгенерируем клиентский сертификат и приватный ключ для пользователя `admin`
```
{

cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:masters",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

}

2019/12/26 12:11:22 [INFO] generate received request
2019/12/26 12:11:22 [INFO] received CSR
2019/12/26 12:11:22 [INFO] generating key: rsa-2048
2019/12/26 12:11:22 [INFO] encoded CSR
2019/12/26 12:11:22 [INFO] signed certificate with serial number 575130181595570420421763699921872326299849279237
```

### Kubelet клиентский сертификат
* Kubernetes использует специальный режим авторизации, называемый Node Authorizer, который специально авторизует запросы API, сделанные Kubelets . Чтобы авторизоваться Node Authorizer, Kubelets должен использовать учетные данные, идентифицирующие их как принадлежащие к `system:nodes` группе, с именем пользователя `system:node:<nodeName>`. В этом разделе мы создадим сертификат для каждого рабочего узла Kubernetes, который отвечает требованиям Node Authorizer.
* Создадим сертификат и закрытый ключ для каждого воркера Kubernetes
```
$ for instance in worker-0 worker-1 worker-2; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

EXTERNAL_IP=$(gcloud compute instances describe ${instance} \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

INTERNAL_IP=$(gcloud compute instances describe ${instance} \
  --format 'value(networkInterfaces[0].networkIP)')

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
done

2019/12/26 14:44:56 [INFO] generate received request
2019/12/26 14:44:56 [INFO] received CSR
2019/12/26 14:44:56 [INFO] generating key: rsa-2048
2019/12/26 14:44:56 [INFO] encoded CSR
2019/12/26 14:44:56 [INFO] signed certificate with serial number 145729974634475055202349642705251712358953928673
2019/12/26 14:45:04 [INFO] generate received request
2019/12/26 14:45:04 [INFO] received CSR
2019/12/26 14:45:04 [INFO] generating key: rsa-2048
2019/12/26 14:45:06 [INFO] encoded CSR
2019/12/26 14:45:06 [INFO] signed certificate with serial number 298273109268347887019483229633587832640690205440
2019/12/26 14:45:09 [INFO] generate received request
2019/12/26 14:45:09 [INFO] received CSR
2019/12/26 14:45:09 [INFO] generating key: rsa-2048
2019/12/26 14:45:09 [INFO] encoded CSR
2019/12/26 14:45:09 [INFO] signed certificate with serial number 426126736473422024603293719599669445371896724770
```

### Клиентский сертификат Controller Manager
* Сгенериуем для `kube-controller-manager` клиентский сертификат и закрытый ключ
```
{

cat > kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

}

2019/12/26 15:52:48 [INFO] generate received request
2019/12/26 15:52:48 [INFO] received CSR
2019/12/26 15:52:48 [INFO] generating key: rsa-2048
2019/12/26 15:52:49 [INFO] encoded CSR
2019/12/26 15:52:49 [INFO] signed certificate with serial number 667238372267422468440851784487685612648793832918
```

### Сертификат клиента Kube Proxy
* Сгенерируем клиентский сертификат и закрытый ключ
```
{

cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:node-proxier",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy

}

2019/12/26 16:09:22 [INFO] generate received request
2019/12/26 16:09:22 [INFO] received CSR
2019/12/26 16:09:22 [INFO] generating key: rsa-2048
2019/12/26 16:09:23 [INFO] encoded CSR
2019/12/26 16:09:23 [INFO] signed certificate with serial number 433115458703145522834131935306002434624475247415
```

### Сертификат клиента планировщика

* Сгенерируем клиентский сертификат и закрытый ключ для kube-scheduler
```
{

cat > kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler

}
2019/12/26 16:11:38 [INFO] generate received request
2019/12/26 16:11:38 [INFO] received CSR
2019/12/26 16:11:38 [INFO] generating key: rsa-2048
2019/12/26 16:11:38 [INFO] encoded CSR
2019/12/26 16:11:38 [INFO] signed certificate with serial number 8000937814644565388891186195448938120692320842
```

### Серверный сертификат Kubernetes API
* Статический IP-адрес будет включен в список подлежащих альтернативных имен для сертификата Kubernetes API сервера. Это гарантирует, что сертификат может быть проверен удаленными клиентами.

* Сгенерируем сертификат и закрытый ключ сервера API Kubernetes
```
{

KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')

KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

}
Your active configuration is: [docker]
2019/12/26 16:23:19 [INFO] generate received request
2019/12/26 16:23:19 [INFO] received CSR
2019/12/26 16:23:19 [INFO] generating key: rsa-2048
2019/12/26 16:23:20 [INFO] encoded CSR
2019/12/26 16:23:20 [INFO] signed certificate with serial number 644327125168728612594656936464303866243977288071
```

### Пара ключей сервисной учетной записи
* Kubernetes Controller Manager использует пару ключей для создания и подписи токенов учетных записей служб.
* Сгенерируем service-account сертификат и закрытый ключ
```
{

cat > service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account

}
2019/12/26 16:37:24 [INFO] generate received request
2019/12/26 16:37:24 [INFO] received CSR
2019/12/26 16:37:24 [INFO] generating key: rsa-2048
2019/12/26 16:37:25 [INFO] encoded CSR
2019/12/26 16:37:25 [INFO] signed certificate with serial number 438828618733781479699087992906710981407979417481
```

### Раздать клиентские и серверные сертификаты
* Скопируем соответствующие сертификаты и закрытые ключи для каждого воркера
```
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/
done
```

* Скопируем соответствующие сертификаты и закрытые ключи для каждого экземпляра контроллера
```
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${instance}:~/
done
```

## Генерация конфигурационных файлов Kubernetes для аутентификации

### Client Authentication Configs. Kubernetes Public IP Address.

* Каждому `kubeconfig` требуется соединение с *Kubernetes API Server*. Для поддержкивысокой доступности IP адрес назначен внутреннему балансировщику нагрузки, используемому Kubernetes API Servers. Получим статический адрес.
```
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')
```

### Конфигурационный файл kubelet Kubernetes

* При создании файлов kubeconfig для Kubelets должен использоваться сертификат клиента, соответствующий имени узла Kubelet. Это обеспечит надлежащую авторизацию Kubelets. Создадим файл kubeconfig для каждого воркера
```
for instance in worker-0 worker-1 worker-2; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done

Cluster "kubernetes-the-hard-way" set.
User "system:node:worker-0" set.
Context "default" created.
Switched to context "default".
Cluster "kubernetes-the-hard-way" set.
User "system:node:worker-1" set.
Context "default" created.
Switched to context "default".
Cluster "kubernetes-the-hard-way" set.
User "system:node:worker-2" set.
Context "default" created.
Switched to context "default".
```

### Конфигурационный файл kube-proxy Kubernetes
* Создадим файл `kubeconfig` для kube-proxy
```
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.pem \
    --client-key=kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}

Cluster "kubernetes-the-hard-way" set.
User "system:kube-proxy" set.
Context "default" created.
Switched to context "default".
```

### Конфигурационный файл kube-controller-manager Kubernetes

* Создадим файл kubeconfig для kube-controller-manager
```
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.pem \
    --client-key=kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
}
Cluster "kubernetes-the-hard-way" set.
User "system:kube-controller-manager" set.
Context "default" created.
Switched to context "default".
```

### Конфигурационный файл kube-планировщика Kubernetes

* Создадим файл kubeconfig для kube-scheduler
```
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.pem \
    --client-key=kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
}
Cluster "kubernetes-the-hard-way" set.
User "system:kube-scheduler" set.
Context "default" created.
Switched to context "default".
```

### Конфигурационный файл администратора Kubernetes

* Создадим файл kubeconfig для пользователя admin
```
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
}
Cluster "kubernetes-the-hard-way" set.
User "admin" set.
Context "default" created.
Switched to context "default".
```

### Распространим конфигурационные файлы Kubernetes

* Скопируем на воркеры соответствующие `kubelet` и `kube-proxy` конфигурационные файлы kubeconfig
```
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}:~/
done
```

* Скопируем на контроллеры соответствующие `kubelet` и `kube-proxy` конфигурационные файлы kubeconfig
```
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}:~/
done
```

## Генерация конфигурационного файла шифрования данных и ключа

### Ключ шифрования
* Сгенерируем ключ шифрования
```
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
```

### Конфигурационный файл для шифрования
* Создадим конфигурационный файл для шифрования `encryption-config.yaml`
```
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
```

* Скопируем конфигурационный файл `encryption-config.yaml` на соответствующие инстансы контроллеров
```
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp encryption-config.yaml ${instance}:~/
done
```

## Начальная загрузка etcd кластера
* Компоненты Kubernetes не имеют состояния и хранят состояние кластера в etcd . Мы загрузим кластер etcd с тремя узлами и настроим его для обеспечения высокой доступности и безопасного удаленного доступа.
* На каждом экземпляре контроллера `controller-0`, `controller-1` и `controller-2` необходимо зайти и выполнить команды.
```
gcloud compute ssh controller-i
```

### Начальная загрузка члена кластера etcd
* Загрузим и установим двоичные файлы `etcd` из проекта etcd GitHub
```
wget -q --show-progress --https-only --timestamping \
  "https://github.com/etcd-io/etcd/releases/download/v3.4.0/etcd-v3.4.0-linux-amd64.tar.gz"
```

* Извлечем и установим etcd сервер и etcdctl утилиту командной строки
```
{
  tar -xvf etcd-v3.4.0-linux-amd64.tar.gz
  sudo mv etcd-v3.4.0-linux-amd64/etcd* /usr/local/bin/
}
```

* Настроим сервер etcd
```
{
  sudo mkdir -p /etc/etcd /var/lib/etcd
  sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
}
```

* Внутренний IP-адрес экземпляра будет использоваться для обслуживания клиентских запросов и связи с одноранговыми кластерами etcd. Получим внутренний IP-адрес для текущего инстанса
```
INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
```

* Каждый член etcd должен иметь уникальное имя в кластере etcd. Установим имя etcd в соответствии с именем хоста текущего инстанса
```
ETCD_NAME=$(hostname -s)
```

* Создадим etcd.service файл системного модуля
```
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controller-0=https://10.240.0.10:2380,controller-1=https://10.240.0.11:2380,controller-2=https://10.240.0.12:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

* Запустим сервер etcd
```
{
  sudo systemctl daemon-reload
  sudo systemctl enable etcd
  sudo systemctl start etcd
}
```

### Проверяем результат
* Посмотрим список членов etcd кластера
```
List the etcd cluster members:

sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem

3a57933972cb5131, started, controller-2, https://10.240.0.12:2380, https://10.240.0.12:2379, false
f98dc20bce6225a0, started, controller-0, https://10.240.0.10:2380, https://10.240.0.10:2379, false
ffed16798470cab5, started, controller-1, https://10.240.0.11:2380, https://10.240.0.11:2379, false
```

## Начальная загрузка Kubernetes Control Plane
### Kubernetes Control Plane

* Создадим каталог конфигурации Kubernetes
```
sudo mkdir -p /etc/kubernetes/config
```

### Загрузить и установить Kubernetes Controller Binaries
* Загрузим
```
wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl"
```

* Установим
```
{
  chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
  sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/
}
```

### Настройка Kubernetes API Server
```
{
  sudo mkdir -p /var/lib/kubernetes/

  sudo mv ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem \
    encryption-config.yaml /var/lib/kubernetes/
}
```

* Внутренний IP-адрес инстанса будет использоваться для объявления сервера API для членов кластера. Получим внутренний IP-адрес для текущего инстанса
```
INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
```

* Создадим файл `kube-apiserver.service` systemd unit
```
cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=https://10.240.0.10:2379,https://10.240.0.11:2379,https://10.240.0.12:2379 \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --kubelet-https=true \\
  --runtime-config=api/all \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

###  Настроим диспетчер контроллеров Kubernetes

* Переместите kube-controller-manager.kubeconfig
```
sudo mv kube-controller-manager.kubeconfig /var/lib/kubernetes/
```

* Создадим файл kube-controller-manager.service systemd unit
```
cat <<EOF | sudo tee /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --address=0.0.0.0 \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Настроим планировщик Kubernetes

* Переместим kube-scheduler и kubeconfig
```
sudo mv kube-scheduler.kubeconfig /var/lib/kubernetes/
```

* Создадим файл конфигурации `kube-scheduler.yaml`
```
cat <<EOF | sudo tee /etc/kubernetes/config/kube-scheduler.yaml
apiVersion: kubescheduler.config.k8s.io/v1alpha1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF
```

* Создадим файл `kube-scheduler.service` systemd unit
```
cat <<EOF | sudo tee /etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --config=/etc/kubernetes/config/kube-scheduler.yaml \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

* Запустим службы контроллера
```
{
  sudo systemctl daemon-reload
  sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
  sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler
}
```

### Включить проверки работоспособности HTTP
* Google Network Load Balancer будет использоваться для распределения трафика по трем серверам API и позволяют каждому серверу API прекратить TLS соединений и сертификатов Проверка клиента. Балансировщик сетевой нагрузки поддерживает только проверки работоспособности HTTP, что означает, что конечная точка HTTPS, предоставляемая сервером API, не может использоваться. В качестве обходного пути веб-сервер nginx можно использовать для проверки работоспособности HTTP-прокси. В этом разделе nginx будет установлен и настроен на прием проверок работоспособности HTTP на порт 80и на прокси-соединениях с сервером API `https://127.0.0.1:6443/healthz`

* Установите базовый веб-сервер для обработки проверок состояния HTTP
```
sudo apt-get update
sudo apt-get install -y nginx
cat > kubernetes.default.svc.cluster.local <<EOF
server {
  listen      80;
  server_name kubernetes.default.svc.cluster.local;

  location /healthz {
     proxy_pass                    https://127.0.0.1:6443/healthz;
     proxy_ssl_trusted_certificate /var/lib/kubernetes/ca.pem;
  }
}
EOF
{
  sudo mv kubernetes.default.svc.cluster.local \
    /etc/nginx/sites-available/kubernetes.default.svc.cluster.local

  sudo ln -s /etc/nginx/sites-available/kubernetes.default.svc.cluster.local /etc/nginx/sites-enabled/
}
sudo systemctl restart nginx
sudo systemctl enable nginx
```

* Проверка
```
kubectl get componentstatuses --kubeconfig admin.kubeconfig
NAME                 STATUS    MESSAGE              ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-2               Healthy   {"health": "true"}
etcd-0               Healthy   {"health": "true"}
etcd-1               Healthy   {"health": "true"}
```

* Протестируем проверка работоспособности nginx HTTP
```
curl -H "Host: kubernetes.default.svc.cluster.local" -i http://127.0.0.1/healthz
HTTP/1.1 200 OK
Server: nginx/1.14.0 (Ubuntu)
Date: Sat, 28 Dec 2019 16:05:52 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 2
Connection: keep-alive
X-Content-Type-Options: nosniff

ok
```

## RBAC для авторизации Kubelet
* В этом разделе мы настроим разрешения RBAC, чтобы позволить серверу API Kubernetes получать доступ к API Kubelet на каждом рабочем узле. Доступ к API Kubelet необходим для получения метрик, журналов и выполнения команд в модулях.
* Этот учебник устанавливает --authorization-mode флаг Kubelet в Webhook. В режиме Webhook для определения авторизации используется API SubjectAccessReview. Команды в этом разделе влияют на весь кластер, и их нужно запускать только один раз с одного из узлов контроллера.
```
gcloud compute ssh controller-0
```
* Создайдим system:kube-apiserver-to-kubelet ClusterRole с разрешениями для доступа к API-интерфейсу Kubelet и выполнения наиболее распространенных задач, связанных с управлением модулями
```
cat <<EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF
```
* Сервер API Kubernetes аутентифицируется в Kubelet как `kubernetes` пользователь, используя сертификат клиента, как определено --kubelet-client-certificate флагом.
* Привязать `system:kube-apiserver-to-kubelet` ClusterRole к `kubernetes` пользователю
```
cat <<EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF
```

## Балансировщик нагрузки внешнего интерфейса Kubernetes
* В этом разделе мы предоставим внешний балансировщик нагрузки для фронта серверов Kubernetes API. Для `kubernetes-the-hard-way` статический IP-адрес будет прикреплен к полученному балансировщику нагрузки.
* Экземпляры вычислений, созданные в этом руководстве, не будут иметь разрешения для завершения этого раздела. Выполним следующие команды с того же компьютера, который использовался для создания инстансов.

### Обеспечение балансировки сетевой нагрузки
* Создадим внешние сетевые ресурсы балансировщика нагрузки
```
{
  KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')

  gcloud compute http-health-checks create kubernetes \
    --description "Kubernetes Health Check" \
    --host "kubernetes.default.svc.cluster.local" \
    --request-path "/healthz"

  gcloud compute firewall-rules create kubernetes-the-hard-way-allow-health-check \
    --network kubernetes-the-hard-way \
    --source-ranges 209.85.152.0/22,209.85.204.0/22,35.191.0.0/16 \
    --allow tcp

  gcloud compute target-pools create kubernetes-target-pool \
    --http-health-check kubernetes

  gcloud compute target-pools add-instances kubernetes-target-pool \
   --instances controller-0,controller-1,controller-2

  gcloud compute forwarding-rules create kubernetes-forwarding-rule \
    --address ${KUBERNETES_PUBLIC_ADDRESS} \
    --ports 6443 \
    --region $(gcloud config get-value compute/region) \
    --target-pool kubernetes-target-pool
}
```

### Проверка
* Инстансы, созданные в этом руководстве, не будут иметь разрешения для завершения этого раздела. Выполним следующие команды с того же компьютера, который использовался для создания инстансов.
* Получим `kubernetes-the-hard-way` статический IP-адрес
```
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')
```

* Выполним HTTP-запрос для информации о версии Kubernetes
```
curl --cacert ca.pem https://${KUBERNETES_PUBLIC_ADDRESS}:6443/version

{
  "major": "1",
  "minor": "15",
  "gitVersion": "v1.15.3",
  "gitCommit": "2d3c76f9091b6bec110a5e63777c332469e0cba2",
  "gitTreeState": "clean",
  "buildDate": "2019-08-19T11:05:50Z",
  "goVersion": "go1.12.9",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

### Начальная загрузка воркеров Kubernetes
* В этой мы загрузим три воркера Kubernetes. Следующие компоненты будут установлены на каждом узле: RunC , контейнерных сетевых плагинов , containerd , kubelet и kube-proxy.

* Команды должны выполняться на каждом экземпляре воркера: worker-0, worker-1и worker-2.
```
gcloud compute ssh worker-0
```

## Предоставление ноды воркера Kubernetes
* Установим зависимости ОС
```
{
  sudo apt-get update
  sudo apt-get -y install socat conntrack ipset
}
```

### Отключим swap
* По умолчанию kubelet не запустится, если включен своп . Есть рекомендация, что swap должен быть отключен, чтобы обеспечить Kubernetes надлежащее распределение ресурсов и качество обслуживания. Проверим, включен ли swap.
```
sudo swapon --show
```

* Если вывод пустой, то подкачка не включена. Если swap включен, необходимо выполнить следующую команду
```
sudo swapoff -a
```

* Загрузим и установим рабочие бинарные файлы
```
wget -q --show-progress --https-only --timestamping \
  https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.15.0/crictl-v1.15.0-linux-amd64.tar.gz \
  https://github.com/opencontainers/runc/releases/download/v1.0.0-rc8/runc.amd64 \
  https://github.com/containernetworking/plugins/releases/download/v0.8.2/cni-plugins-linux-amd64-v0.8.2.tgz \
  https://github.com/containerd/containerd/releases/download/v1.2.9/containerd-1.2.9.linux-amd64.tar.gz \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubelet
```

* Создадим каталоги установки
```
sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes
```

* Установим бинарники
```
{
  mkdir containerd
  tar -xvf crictl-v1.15.0-linux-amd64.tar.gz
  tar -xvf containerd-1.2.9.linux-amd64.tar.gz -C containerd
  sudo tar -xvf cni-plugins-linux-amd64-v0.8.2.tgz -C /opt/cni/bin/
  sudo mv runc.amd64 runc
  chmod +x crictl kubectl kube-proxy kubelet runc 
  sudo mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/
  sudo mv containerd/bin/* /bin/
}
```

### Настроим сеть CNI
* Получим диапазон Pod CIDR для текущего инстанса
```
POD_CIDR=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/attributes/pod-cidr)
```

* Создадим bridge-файл конфигурации сети
```
cat <<EOF | sudo tee /etc/cni/net.d/10-bridge.conf
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF
```

* Создадим loopback-файл конфигурации сети
```
cat <<EOF | sudo tee /etc/cni/net.d/99-loopback.conf
{
    "cniVersion": "0.3.1",
    "name": "lo",
    "type": "loopback"
}
EOF
```

### Настроим containerd
* Создайдим containerd файл конфигурации
```
sudo mkdir -p /etc/containerd/
cat << EOF | sudo tee /etc/containerd/config.toml
[plugins]
  [plugins.cri.containerd]
    snapshotter = "overlayfs"
    [plugins.cri.containerd.default_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runc"
      runtime_root = ""
EOF
```

* Создадим `containerd.service` файл systemd unit
```
cat <<EOF | sudo tee /etc/systemd/system/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF
```

### Настроим Kubelet
```
{
  sudo mv ${HOSTNAME}-key.pem ${HOSTNAME}.pem /var/lib/kubelet/
  sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
  sudo mv ca.pem /var/lib/kubernetes/
}
```

* Создайдим `kubelet-config.yaml` файл конфигурации
```
cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "${POD_CIDR}"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${HOSTNAME}-key.pem"
EOF
```

* Создадим `kubelet.service` файл systemd unit
```
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Настроим Kubernetes-proxy

```
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
```

* Создадим `kube-proxy-config.yaml` файл конфигурации
```
cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF
```

* Создадим `kube-proxy.service` файл systemd unit
```
cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Запустим воркеры
```
{
  sudo systemctl daemon-reload
  sudo systemctl enable containerd kubelet kube-proxy
  sudo systemctl start containerd kubelet kube-proxy
}
```

### Проверка
* Инстансы не будут иметь разрешения для завершения этого раздела. Выполните следующие команды с того же компьютера, который использовался для создания инстансов.
* Список зарегистрированных узлов Kubernetes

```
gcloud compute ssh controller-0 \
  --command "kubectl get nodes --kubeconfig admin.kubeconfig"

NAME       STATUS   ROLES    AGE   VERSION
worker-0   Ready    <none>   31s   v1.15.3
worker-1   Ready    <none>   29s   v1.15.3
worker-2   Ready    <none>   27s   v1.15.3
```

## Настройка kubectl для удаленного доступа
* Создадим файл `kubeconfig` для `kubectl` утилиты командной строки на основе пользователя `admin`.
* Команды запускаются из того же каталога, который использовался для создания клиентских сертификатов администратора.

### Конфигурационный файл Admin Kubernetes
* Каждому `kubeconfig` требуется сервер API Kubernetes для подключения. Для обеспечения высокой доступности будет использоваться IP-адрес, назначенный внешнему балансировщику нагрузки на серверах API Kubernetes.

* Создадим файл `kubeconfig`, подходящий для аутентификации пользователя `admin`.
```
{
  KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem

  kubectl config set-context kubernetes-the-hard-way \
    --cluster=kubernetes-the-hard-way \
    --user=admin

  kubectl config use-context kubernetes-the-hard-way
}
```

### Проверка
* Проверим работоспособность удаленного кластера Kubernetes
```
kubectl get componentstatuses

NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok
controller-manager   Healthy   ok
etcd-2               Healthy   {"health":"true"}
etcd-1               Healthy   {"health":"true"}
etcd-0               Healthy   {"health":"true"}

kubectl get nodes

NAME       STATUS   ROLES    AGE   VERSION
worker-0   Ready    <none>   10m   v1.15.3
worker-1   Ready    <none>   10m   v1.15.3
worker-2   Ready    <none>   10m   v1.15.3
```

## Предоставление сетевых маршрутов Pod
* Модули, запланированные для узла, получают IP-адрес из диапазона CIDR Pod узла. На этом этапе модули не могут связываться с другими модулями, работающими на разных узлах из-за отсутствия сетевых маршрутов. Мы создадим маршрут для каждого рабочего узла, который сопоставляет диапазон Pod CIDR узла с внутренним IP-адресом узла.

### Таблица маршрутизации
* В этом разделе мы соберем информацию, необходимую для создания маршрутов в `kubernetes-the-hard-way` сети VPC.

* Вывести внутренний IP-адрес и диапазон Pod CIDR для каждого рабочего экземпляра
```
for instance in worker-0 worker-1 worker-2; do
  gcloud compute instances describe ${instance} \
    --format 'value[separator=" "](networkInterfaces[0].networkIP,metadata.items[0].value)'
done

10.240.0.20 10.200.0.0/24
10.240.0.21 10.200.1.0/24
10.240.0.22 10.200.2.0/24
```

### Маршруты
* Создание сетевые маршруты для каждого воркера
```
for i in 0 1 2; do
  gcloud compute routes create kubernetes-route-10-200-${i}-0-24 \
    --network kubernetes-the-hard-way \
    --next-hop-address 10.240.0.2${i} \
    --destination-range 10.200.${i}.0/24
done
```

* Перечислим маршруты в `kubernetes-the-hard-way` сети VPC
```
gcloud compute routes list --filter "network: kubernetes-the-hard-way"

NAME                            NETWORK                  DEST_RANGE     NEXT_HOP                  PRIORITY
default-route-2ab6e9a2a571e619  kubernetes-the-hard-way  10.240.0.0/24  kubernetes-the-hard-way   1000
default-route-b82c84833eafc29c  kubernetes-the-hard-way  0.0.0.0/0      default-internet-gateway  1000
kubernetes-route-10-200-0-0-24  kubernetes-the-hard-way  10.200.0.0/24  10.240.0.20               1000
kubernetes-route-10-200-1-0-24  kubernetes-the-hard-way  10.200.1.0/24  10.240.0.21               1000
kubernetes-route-10-200-2-0-24  kubernetes-the-hard-way  10.200.2.0/24  10.240.0.22               1000
```

## Развертывание надстройки DNS-кластера
* Развернем надстройку DNS, которая обеспечит обнаружение служб на основе DNS при поддержке CoreDNS для приложений, работающих в кластере Kubernetes.

### Надстройка DNS-кластера

* Развернем coredns кластерный add-on
```
kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml

serviceaccount/coredns created
clusterrole.rbac.authorization.k8s.io/system:coredns created
clusterrolebinding.rbac.authorization.k8s.io/system:coredns created
configmap/coredns created
deployment.extensions/coredns created
service/kube-dns created
```

* Список модулей, созданных при kube-dns развертывании
```
kubectl get pods -l k8s-app=kube-dns -n kube-system

NAME                     READY   STATUS    RESTARTS   AGE
coredns-5fb99965-b8xrn   1/1     Running   0          23s
coredns-5fb99965-q77bd   1/1     Running   0          23s
```

### Проверка

* Создадим `busybox` развертывание
```
kubectl run --generator=run-pod/v1 busybox --image=busybox:1.28 --command -- sleep 3600

kubectl get pods -l run=busybox

NAME      READY   STATUS    RESTARTS   AGE
busybox   1/1     Running   0          18s
```

* Получим полное имя Pod-a busybox
```
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
```

* Выполним поиск DNS для `kubernetes` службы внутри `busybox`-модуля
```
kubectl exec -ti $POD_NAME -- nslookup kubernetes

Server:    10.32.0.10
Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.32.0.1 kubernetes.default.svc.cluster.local
```

## Тест шифрования
* Мы выполним ряд задач, чтобы убедиться, что ваш кластер Kubernetes работает правильно.

### Шифрование данных
* В этом разделе мы проверим возможность шифрования секретных данных в состоянии покоя. Создадиме общий секрет
```
kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata"
```

* Выведем `hexdump` для `kubernetes-the-hard-way` секрета, хранящегося в etcd
```
gcloud compute ssh controller-0 \
  --command "sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"

00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6b 75 62 65 72 6e  |s/default/kubern|
00000020  65 74 65 73 2d 74 68 65  2d 68 61 72 64 2d 77 61  |etes-the-hard-wa|
00000030  79 0a 6b 38 73 3a 65 6e  63 3a 61 65 73 63 62 63  |y.k8s:enc:aescbc|
00000040  3a 76 31 3a 6b 65 79 31  3a 33 4a 09 8c 8b 68 99  |:v1:key1:3J...h.|
00000050  60 65 7a 94 99 2f 53 5b  ea 64 ee 36 7c c6 43 c9  |`ez../S[.d.6|.C.|
00000060  99 17 99 72 d0 31 1e dc  e5 ee aa 94 bf 61 a8 d2  |...r.1.......a..|
00000070  5e dd 6c d8 07 d1 1e 57  08 0b 8d 68 a9 20 f8 ae  |^.l....W...h. ..|
00000080  9a b4 1f 8b 49 6e 30 c4  fb 27 cb 11 1e 56 d1 76  |....In0..'...V.v|
00000090  2a 42 8d b5 1b 62 06 35  d6 e9 e9 54 cc f3 e7 b6  |*B...b.5...T....|
000000a0  18 c4 d0 e4 17 0c 13 01  db 0f 6d 12 76 6e e7 dc  |..........m.vn..|
000000b0  e0 9f e5 95 3a 28 d2 5b  f8 a7 78 94 72 40 c0 39  |....:(.[..x.r@.9|
000000c0  d5 26 ee 82 98 1e 8e d7  f7 f8 2e 37 30 4f a7 61  |.&.........70O.a|
000000d0  09 54 0d ae 89 e6 f2 3d  45 9d c3 f5 91 8c 4b b1  |.T.....=E.....K.|
000000e0  13 6d 3d 88 3f 62 a2 69  c9 0a                    |.m=.?b.i..|
000000ea
```

* К ключу etcd должен быть добавлен префикс *k8s:enc:aescbc:v1:key1*, который указывает, что aescbc-провайдер использовался для шифрования данных с key1-помощью ключа шифрования.

### Деплоймент
* В этом разделе мы проверим возможность создания и управления деплойментом

* Создадим развертывание для веб-сервера nginx
```
kubectl create deployment nginx --image=nginx

kubectl get pods -l app=nginx

NAME                     READY   STATUS    RESTARTS   AGE
nginx-554b9c67f9-n2hnb   1/1     Running   0          11s
```

### Перенаправление порта
* В этом разделе мы проверим возможность удаленного доступа к приложениям с помощью переадресации портов

* Получим полное имя nginx pod-a
```
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")
```

* Форвард порта 8080 на локальном компьютере, к порту 80 в nginx-контейнере
```
kubectl port-forward $POD_NAME 8080:80

Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

* В новом терминале сделаем HTTP-запрос, используя адрес пересылки
```
curl --head http://127.0.0.1:8080

HTTP/1.1 200 OK
Server: nginx/1.17.6
Date: Sun, 29 Dec 2019 11:09:11 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 19 Nov 2019 12:50:08 GMT
Connection: keep-alive
ETag: "5dd3e500-264"
Accept-Ranges: bytes
```

* Вернемся к предыдущему терминалу и остановим переадресацию порта на nginx-модуль
```
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
^C
```

### Логи
* В этом разделе мы проверите возможность получения журналов контейнера
* Выведем nginx-журналы pod-a
```
kubectl logs $POD_NAME

127.0.0.1 - - [29/Dec/2019:11:09:11 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.58.0" "-"
```

### Exec
* В этом разделе мы проверим возможность выполнения команд в контейнере.
* Выведем версию nginx, выполнив `nginx -v` команду в nginx-контейнере
```
kubectl exec -ti $POD_NAME -- nginx -v

nginx version: nginx/1.17.6
```

### Сервисы
* В этом разделе мы проверим возможность выставлять приложения, используя Сервисы.
* Выполним nginx-развертывание, используя сервис NodePort
```
kubectl expose deployment nginx --port 80 --type NodePort
```

* Получим порт узла, назначенный nginx-службе
```
NODE_PORT=$(kubectl get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
```

* Создадим правило брандмауэра, разрешающее удаленный доступ к nginx-порту узла
```
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-nginx-service \
  --allow=tcp:${NODE_PORT} \
  --network kubernetes-the-hard-way

Creating firewall...⠶Created [https://www.googleapis.com/compute/v1/projects/global-incline-258416/global/firewalls/kubernetes-the-hard-way-allow-nginx-service].
Creating firewall...done.
NAME                                         NETWORK                  DIRECTION  PRIORITY  ALLOW      DENY  DISABLED
kubernetes-the-hard-way-allow-nginx-service  kubernetes-the-hard-way  INGRESS    1000      tcp:32262        False
```

* Получим внешний IP-адрес воркера
```
EXTERNAL_IP=$(gcloud compute instances describe worker-0 \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')
```

* Сделаем HTTP-запрос, используя внешний IP-адрес и nginx-порта узла
```
curl -I http://${EXTERNAL_IP}:${NODE_PORT}

HTTP/1.1 200 OK
Server: nginx/1.17.6
Date: Sun, 29 Dec 2019 11:34:23 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 19 Nov 2019 12:50:08 GMT
Connection: keep-alive
ETag: "5dd3e500-264"
Accept-Ranges: bytes
```

## The Hard Way Kubernetes пройден
* Развернем поды нашего приложения
```
$ kubectl apply -f mongo-deployment.yml
$ kubectl apply -f comment-deployment.yml
$ kubectl apply -f post-deployment.yml
$ kubectl apply -f ui-deployment.yml
```

* Выведем список текущих подов
```
$ kubectl get pod
NAME                                  READY   STATUS    RESTARTS   AGE
busybox                               1/1     Running   0          41m
comment-deployment-6b4d766d94-zbhgv   1/1     Running   0          2m48s
mongo-deployment-86d49445c4-d4lkw     1/1     Running   0          57s
nginx-554b9c67f9-n2hnb                1/1     Running   0          33m
post-deployment-58d8498bd8-np2xb      1/1     Running   0          47s
ui-deployment-597bf9999b-cc7rw        1/1     Running   0          41s
```

## Генеральная уборка
* Удалим все ресурсы, созданные во время данной работы.

### Инстансы
* Удалите экземпляры контроллера и воркеров
```
gcloud -q compute instances delete \
  controller-0 controller-1 controller-2 \
  worker-0 worker-1 worker-2 \
  --zone $(gcloud config get-value compute/zone)
```

### Сети
* Удалим внешние сетевые ресурсы балансировщика нагрузки
```
{
  gcloud -q compute forwarding-rules delete kubernetes-forwarding-rule \
    --region $(gcloud config get-value compute/region)

  gcloud -q compute target-pools delete kubernetes-target-pool

  gcloud -q compute http-health-checks delete kubernetes

  gcloud -q compute addresses delete kubernetes-the-hard-way
}
```

* Удалим `kubernetes-the-hard-way` правила брандмауэра
```
gcloud -q compute firewall-rules delete \
  kubernetes-the-hard-way-allow-nginx-service \
  kubernetes-the-hard-way-allow-internal \
  kubernetes-the-hard-way-allow-external \
  kubernetes-the-hard-way-allow-health-check
```

Удалим `kubernetes-the-hard-way` сеть VPC
```
{
  gcloud -q compute routes delete \
    kubernetes-route-10-200-0-0-24 \
    kubernetes-route-10-200-1-0-24 \
    kubernetes-route-10-200-2-0-24

  gcloud -q compute networks subnets delete kubernetes

  gcloud -q compute networks delete kubernetes-the-hard-way
}
```
* Чисто.

## Задание со *
* Для реализации концепции разворачивания кластера Kubernetis на GCE из 3 воркеров и 3 контроллеров с выполнением всех пунктов THW использован пакет `https://github.com/Zenika/k8s-on-gce`
```
How to use 🗺
Put your adc.json in the app dir (See Gcloud account for details on this file) .
Adapt profile to match your desired region, zone and project
Launch ./in.sh, it will build a docker image and launch a container with all needed tools
In the container, launch ./create.sh and wait for ~10mins
And you're done ! 🚀
🚽 When you finish, launch ./cleanup.sh to remove all gce resources.
```

# Homework 20. Kubernetes. Запуск кластера и приложения. Модель безопасности.

* Подготовка. Создадим новую ветку в репозитории Microservices для выполнения данного ДЗ. Так как это второе задание по Kubernetes, то назовем ее kubernetes-2

* План
 - Развернуть локальное окружение для работы с Kubernetes
 - Развернуть Kubernetes в GKE
 - Запустить reddit в Kubernetes

## Разворачиваем Kubernetes локально

* Для дальнейшей работы нам нужно подготовить локальное окружение, которое будет состоять из:
 - kubectl - фактически, главной утилиты для работы c Kubernetes API (все, что делает kubectl, можно сделать с помощью HTTP-запросов к API k8s)
 - Директории ~/.kube - содержит служебную инфу для kubectl (конфиги, кеши, схемы API)
 - minikube - утилиты для разворачивания локальной инсталляции Kubernetes.

### Kubectl
* Необходимо установить kubectl, все способы установки доступны по ссылке `https://kubernetes.io/docs/tasks/tools/install-kubectl/`

### Minikube
* Установка Minikube. Для работы Minukube вам понадобится локальный гипервизор, в нашем случае это уже установленный VirtualBox.

* Minikube. Инструкция по установке Minikube для разных ОС `https://kubernetes.io/docs/tasks/tools/install-minikube/`
```
Install Minikube via direct download. If you’re not installing via a package, you can download a stand-alone binary and use that.

curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube

sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/
```

* Запустим наш Minukube-кластер.
```
$ minikube start
* minikube v1.6.2 on Ubuntu 18.04
* Selecting 'virtualbox' driver from existing profile (alternates: [none])
* Tip: Use 'minikube start -p <name>' to create a new cluster, or 'minikube delete' to delete this one.
* Using the running virtualbox "minikube" VM ...
* Waiting for the host to be provisioned ...
* Preparing Kubernetes v1.17.0 on Docker '19.03.5' ...
* Downloading kubelet v1.17.0
* Downloading kubeadm v1.17.0
* Launching Kubernetes ...
* Done! kubectl is now configured to use "minikube"
```

* Наш Minikube-кластер развернут. При этом автоматически был настроен конфиг kubectl. Проверим, что это так.
```
$ kubectl get nodes
NAME       STATUS   ROLES    AGE     VERSION
minikube   Ready    master   5m19s   v1.17.0
```

* Конфигурация kubectl - это контекст. Контекст - это комбинация

1) cluster - API-сервер
2) user - пользователь для подключения к кластеру
3) namespace - область видимости (не обязательно, по-умолчанию default)

* Информацию о контекстах kubectl сохраняет в файле `~/.kube/config` - это такой же манифест kubernetes в YAML-формате.

* Кластер (cluster) - это
1) server - адрес kubernetes API-сервера
2) certificate-authority - корневой сертификат (которым подписан SSL-сертификат самого сервера), чтобы убедиться, что нас не обманывают и перед нами тот самый сервер
+ name (Имя) для идентификации в конфиге.

* Пользователь (user) - это
1) Данные для аутентификации (зависит от того, как настроен сервер). Это могут быть: - username + password (Basic Auth
 - client key + client certificate
 - token
 - auth-provider config (например GCP)
 + name (Имя) для идентификации в конфиге.

* Контекст (контекст) - это
1) cluster - имя кластера из списка clusters
2) user - имя пользователя из списка users
3) namespace - область видимости по-умолчанию (не обязательно)
+ name (Имя) для идентификации в конфиге

* Обычно порядок конфигурирования kubectl следующий
1) Создать cluster
```
$ kubectl config set-cluster … cluster_name
```
2) Создать данные пользователя (credentials)
```
$ kubectl config set-credentials … user_name
```
3) Создать контекст
```
$ kubectl config set-context context_name \
--cluster=cluster_name \
--user=user_name
```
4) Использовать контекст
```
$ kubectl config use-context context_name
```

* Таким образом `kubectl` конфигурируется для подключения к разным кластерам, под разными пользователями.
* Текущий контекст можно увидеть так
```
$ kubectl config current-context
minikube
```
* Список всех контекстов можно увидеть так
```
$ kubectl config get-contexts
```

## Запуск приложения
* Для работы в приложения kubernetes, нам необходимо описать их желаемое состояние либо в YAML-манифестах, либо с помощью командной строки. Всю конфигурацию поместим в каталог `./kubernetes/reddit` внутри вашего репозитория.

### Deployment
* Основные объекты - это ресурсы Deployment. Основные его задачи:
 - Создание ReplicationSet (следит, чтобы число запущенных Pod-ов соответствовало описанному)
 - Ведение истории версий запущенных Pod-ов (для различных стратегий деплоя, для возможностей отката)
 - Описание процесса деплоя (стратегия, параметры стратегий)

* Запустим в Minikube ui-компоненту
```
$ kubectl apply -f ui-deployment.yml
deployment.apps/ui created

$ kubectl get pods
NAME                 READY   STATUS    RESTARTS   AGE
ui-68766dc77-2n6ks   1/1     Running   0          8m13s
ui-68766dc77-6gksg   1/1     Running   0          8m13s
ui-68766dc77-w5rzh   1/1     Running   0          8m13s
```

* Убедимся, что во 2,3,4 и 5 столбцах стоит число 3 (число реплик ui)
```
$ kubectl get deployment
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
ui     3/3     3            3           8m21s
```

* Пока что мы не можем использовать наше приложение полностью, потому что никак не настроена сеть для общения с ним. Но kubectl умеет пробрасывать сетевые порты POD-ов на локальную машину. Найдем, используя selector, POD-ы приложения
```
$ kubectl get pods --selector component=ui
NAME                 READY   STATUS    RESTARTS   AGE
ui-68766dc77-2n6ks   1/1     Running   0          30m
ui-68766dc77-6gksg   1/1     Running   0          30m
ui-68766dc77-w5rzh   1/1     Running   0          30m

$ kubectl port-forward ui-68766dc77-2n6ks 8080:9292
```

* Зайдем в браузере на `http://localhost:8080` - UI работает, подключим остальные компоненты.

* Компонент comment описывается похожим образом. Меняется только имя образа и метки и применяем (kubectl apply). Проверить можно так же, пробросив `<local-port>:9292` и зайдя на адрес `http://localhost:<local-port>/healthcheck`
```
$ kubectl apply -f comment-deployment.yml
deployment.apps/comment created

$ kubectl get pods --selector component=comment
NAME                       READY   STATUS    RESTARTS   AGE
comment-6fd6f8f46f-5k2bt   1/1     Running   0          7m39s
comment-6fd6f8f46f-g8g2g   1/1     Running   0          7m39s
comment-6fd6f8f46f-rfwg8   1/1     Running   0          7m39s

$ kubectl port-forward comment-6fd6f8f46f-5k2bt 8080:9292
```

* Deployment компонента post сконфигурируйте подобным же образом самостоятельно и проверьте его работу. Не забудьте, что post слушает по-умолчанию на порту 5000.

```
$ kubectl apply -f post-deployment.yml
deployment.apps/post created

$ kubectl get pods --selector component=post
NAME                    READY   STATUS    RESTARTS   AGE
post-7cfbfc5d47-6xnvb   1/1     Running   0          4m
post-7cfbfc5d47-knlsq   1/1     Running   0          4m
post-7cfbfc5d47-xlrkp   1/1     Running   0          4m

$ kubectl port-forward post-7cfbfc5d47-6xnvb 5000:9292
```

* MongoDB. Разместим базу данных. Все похоже, но меняются только образы и значения label-ов. Также примонтируем стандартный Volume для хранения данных вне контейнера
```
$ kubectl apply -f mongo-deployment.yml
deployment.apps/mongo created

$ kubectl get pods --selector component=mongo
NAME                     READY   STATUS    RESTARTS   AGE
mongo-7fb8945897-cxlck   1/1     Running   0          3m24s
```

## Services
* В текущем состоянии приложение не будет работать, так его компоненты ещё не знают как найти друг друга. Для связи компонент между собой и с внешним миром используется объект Service - абстракция, которая определяет набор POD-ов (Endpoints) и способ доступа к ним.
* Для связи ui с post и comment нужно создать им по объекту Service.
* Когда объект service будет создан:
 - В DNS появится запись для comment
 - При обращении на адрес post:9292 изнутри любого из POD-ов текущего namespace нас переправит на 9292-ный порт одного из POD-ов приложения post, выбранных по label-ам
* По label-ам должны были быть найдены соответствующие POD-ы. Посмотреть можно с помощью
```
$ kubectl apply -f comment-service.yml
service/comment created

$ kubectl describe service comment | grep Endpoints
Endpoints:         172.17.0.10:9292,172.17.0.11:9292,172.17.0.2:9292
```

* А изнутри любого POD-а должно разрешаться
```
$ kubectl exec -ti post-7cfbfc5d47-6xnvb nslookup comment

nslookup: can't resolve '(null)': Name does not resolve

Name:      comment
Address 1: 10.96.38.17 comment.default.svc.cluster.local
```

* По аналогии создадим объект Service в файле `postservice.yml` для компонента `post` (и не забудем про label-ы и правильные tcp-порты).
```
---
apiVersion: v1
kind: Service
metadata:
  name: post
  labels:
    app: reddit
    component: post
spec:
  ports:
  - port: 9292
    protocol: TCP
    targetPort: 5000
  selector:
    app: reddit
    component: post
```

* После команды `kubectl apply -f post-service.yml` minikube перестал отвечать на запросы.
```
Unable to connect to the server: net/http: TLS handshake timeout
```
* Делаем ему рестарт для приведения в чувства
```
$ minikube stop
$ minikube start
$ kubectl get componentstatuses

$ kubectl apply -f post-service.yml
service/post created
```

* Post и Comment также используют mongodb, следовательно ей тоже нужен объект Service
```
$ kubectl apply -f mongodb-service.yml
service/mongodb created
```

* Пробрасываем порт UI `kubectl port-forward ui-68766dc77-2n6ks 9292:9292` и проверяем работу
* Приложение при открытии уходит в себя и о чем-то думает. По итогу открывается с ошибкой `Can't show blog posts, some problems with the post service.`

* Посмотрим логи, например, comment `kubectl logs comment-6b99d97f-2nm6z`
```
Puma starting in single mode...
* Version 3.12.0 (ruby 2.2.10-p489), codename: Llamas in Pajamas
* Min threads: 0, max threads: 16
* Environment: development
* Listening on tcp://0.0.0.0:9292
Use Ctrl-C to stop
I, [2020-01-02T05:11:31.213152 #1]  INFO -- : service=comment | event=request | path=/healthcheck
request_id=null | remote_addr=172.17.0.4 | method= GET | response_status=200
I, [2020-01-02T05:11:31.258181 #1]  INFO -- : service=comment | event=request | path=/healthcheck
request_id=null | remote_addr=172.17.0.8 | method= GET | response_status=200
I, [2020-01-02T05:11:33.273550 #1]  INFO -- : service=comment | event=request | path=/healthcheck
request_id=null | remote_addr=172.17.0.8 | method= GET | response_status=200
I, [2020-01-02T05:11:35.528716 #1]  INFO -- : service=comment | event=request | path=/healthcheck
request_id=null | remote_addr=172.17.0.6 | method= GET | response_status=200
I, [2020-01-02T05:11:39.728725 #1]  INFO -- : service=comment | event=request | path=/healthcheck
request_id=null | remote_addr=172.17.0.4 | method= GET | response_status=200
I, [2020-01-02T05:11:40.286765 #1]  INFO -- : service=comment | event=request | path=/healthcheck
request_id=null | remote_addr=172.17.0.6 | method= GET | response_status=200
```
* Сообщений, как в методичке домашнего задания, нет от слова "совсем". Уровень отладки в моём варианте явно отличается от задания. Либо так задумано, либо где-то вкралась очепятка.
* В тексте `/src/comment/comment_app.rb` уровень логирования в моем случае задан на уровне `WARN`, в методичке же явно виден `DEBUG`. Попробуем поправить, и заодно уберу тэг `logging` от предыдущего задания, мы ведь его сейчас в задании не используем.


* В логах приложение ищет совсем другой адрес: comment_db, а не mongodb. Аналогично и сервис comment ищет post_db. Эти адреса заданы в их Dockerfile-ах в виде переменных окружения
```
post/Dockerfile
…
ENV POST_DATABASE_HOST=post_db
comment/Dockerfile
…
ENV COMMENT_DATABASE_HOST=comment_db
```

* В Docker Swarm проблема доступа к одному ресурсу под разными именами решалась с помощью сетевых алиасов. В Kubernetes такого функционала нет. Мы эту проблему можем решить с помощью тех же Service-ов.

* Сделаем файл Service для БД comment
```
wget https://raw.githubusercontent.com/express42/otus-snippets/e7b0bc08c47a77709d313cfcbbaa3f9ed4b19340/k8s-controllers/comment-mongodb-service.yml
```

* Так же придется обновить файл deployment для mongodb, чтобы новый Service смог найти нужный POD
```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
    comment-db: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo
      labels:
        app: reddit
        component: mongo
        comment-db: "true"
    spec:
      containers:
        - image: mongo:3.2
          name: mongo
          volumeMounts:
          - name: mongo-persistent-storage
            mountPath: /data/db
      volumes:
        - name: mongo-persistent-storage
          emptyDir: {}
```
* Зададим pod-ам comment переменную окружения для обращения к базе
```
        env:
        - name: COMMENT_DATABASE_HOST
          value: comment-db
```

* Мы сделали базу доступной для comment. Проделаем аналогичные же действия для post-сервиса. Название сервиса должно быть post-db.

* После этого снова сделаем port-forwarding на UI и убедимся, что приложение запустилось без ошибок и посты создаются.

* Проверили - все гуд, работает.

* Для чистоты эксперимента выполним всё с нуля
```
$ minikube delete && minikube start && kubectl apply -f ./kubernetes/reddit

$ kubectl get pod
NAME                     READY   STATUS    RESTARTS   AGE
comment-6b99d97f-2nm6z   1/1     Running   0          9m52s
comment-6b99d97f-9vmm5   1/1     Running   0          9m52s
comment-6b99d97f-z4tvb   1/1     Running   0          9m52s
mongo-6fbb94b746-srcv4   1/1     Running   0          9m52s
post-f48875b9-4m9b7      1/1     Running   0          9m52s
post-f48875b9-4p8rn      1/1     Running   0          9m52s
post-f48875b9-qvxl5      1/1     Running   0          9m52s
ui-68766dc77-5pj6l       1/1     Running   0          9m51s
ui-68766dc77-62d58       1/1     Running   0          9m51s
ui-68766dc77-lslt6       1/1     Running   0          9m51s

$ kubectl get service
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE
comment      ClusterIP   10.96.16.89     <none>        9292/TCP    26s
comment-db   ClusterIP   10.96.228.91    <none>        27017/TCP   26s
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP     25m
mongodb      ClusterIP   10.96.197.125   <none>        27017/TCP   26s
post         ClusterIP   10.96.251.146   <none>        5000/TCP    25s
post-db      ClusterIP   10.96.113.2     <none>        27017/TCP   26s
```

* Удалим объект mongodb-service `$ kubectl delete -f mongodb-service.yml` или `$ kubectl delete service mongodb`
```
service "mongodb" deleted
```

* Нам нужно как-то обеспечить доступ к ui-сервису снаружи. Для этого нам понадобится Service для UI-компоненты
```
---
apiVersion: v1
kind: Service
metadata:
  name: ui
  labels:
    app: reddit
    component: ui
spec:
  type: NodePort
  ports:  
  - nodePort: 32092
    port: 9292
    protocol: TCP
    targetPort: 9292
  selector:
    app: reddit
    component: ui
```

* По-умолчанию все сервисы имеют тип ClusterIP - это значит, что сервис распологается на внутреннем диапазоне IP-адресов кластера. Снаружи до него нет доступа. Тип NodePort - на каждой ноде кластера открывает порт из диапазона 30000-32767 и переправляет трафик с этого порта на тот, который указан в targetPort Pod (похоже на стандартный expose в docker). Теперь до сервиса можно дойти по `<Node-IP>:<NodePort>`. Также можно указать самим NodePort (но все равно из диапазона)

* Т.е. в описании service NodePort - для доступа снаружи кластера port - для доступа к сервису изнутри кластера.

## Minikube. Dashboard

* Minikube может выдавать web-странцы с сервисами которые были помечены типом NodePort
```
$ minikube service ui
|-----------|------|-------------|-----------------------------|
| NAMESPACE | NAME | TARGET PORT |             URL             |
|-----------|------|-------------|-----------------------------|
| default   | ui   |             | http://192.168.99.100:32092 |
|-----------|------|-------------|-----------------------------|
```

* Minikube может перенаправлять на web-странцы с сервисами которые были помечены типом NodePort. Посмотрим на список сервисов
```
$ minikube service list
|-------------|------------|-----------------------------|-----|
|  NAMESPACE  |    NAME    |         TARGET PORT         | URL |
|-------------|------------|-----------------------------|-----|
| default     | comment    | No node port                |
| default     | comment-db | No node port                |
| default     | kubernetes | No node port                |
| default     | post       | No node port                |
| default     | post-db    | No node port                |
| default     | ui         | http://192.168.99.100:32092 |
| kube-system | kube-dns   | No node port                |
|-------------|------------|-----------------------------|-----|
```

* Minikube также имеет в комплекте несколько стандартных аддонов (расширений) для Kubernetes (kube-dns, dashboard, monitoring,…). Каждое расширение - это такие же PODы и сервисы, какие создавались нами, только они еще общаются с API самого Kubernetes. Получим список расширений
```
$ minikube addons list
- addon-manager: enabled
- dashboard: disabled
- default-storageclass: enabled
- efk: disabled
- freshpod: disabled
- gvisor: disabled
- helm-tiller: disabled
- ingress: disabled
- ingress-dns: disabled
- logviewer: disabled
- metrics-server: disabled
- nvidia-driver-installer: disabled
- nvidia-gpu-device-plugin: disabled
- registry: disabled
- registry-creds: disabled
- storage-provisioner: enabled
- storage-provisioner-gluster: disabled
```

* Интересный аддон - *dashboard*. Это UI для работы с kubernetes. По умолчанию в новых версиях он включен. Как и многие kubernetes add-on'ы, dashboard запускается в виде pod'а. Если мы посмотрим на запущенные pod'ы с помощью команды `kubectl get pods`, то обнаружим только наше приложение.
* Потому что поды и сервисы для dashboard-а были запущены в namespace (пространстве имен) kube-system. Мы же запросили пространство имен default.
* *Namespace* - это, по сути, виртуальный кластер Kubernetes внутри самого Kubernetes. Внутри каждого такого кластера находятся свои объекты (POD-ы, Service-ы, Deployment-ы и т.д.), кроме объектов, общих на все namespace-ы (nodes, ClusterRoles, PersistentVolumes). В разных namespace-ах могут находится объекты с одинаковым именем, но в рамках одного namespace имена объектов должны быть уникальны.
* При старте Kubernetes кластер уже имеет 3 namespace:
 • default - для объектов для которых не определен другой Namespace (в нем мы работали все это время)
 • kube-system - для объектов созданных Kubernetes’ом и для управления им
 • kube-public - для объектов к которым нужен доступ из любой точки кластера
* Для того, чтобы выбрать конкретное пространство имен, нужно указать флаг *-n <namespace>* или *--namespace <namespace>* при запуске kubectl
* Так как в нашем случае аддон dashboard выключен, необходимо его включить
```
minikube dashboard
* Enabling dashboard ...
* Verifying dashboard health ...
* Launching proxy ...
* Verifying proxy health ...
* Opening http://127.0.0.1:37429/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/ in your default browser...
```

* Найдем же теперь объекты нашего dashboard
```
$ kubectl get all -n kube-system --selector k8s-app=kubernetes-dashboard
NAME READY STATUS RESTARTS AGE
pod/kubernetes-dashboard-598d75cb96-vnntk 1/1 Running 0 1h
NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE
service/kubernetes-dashboard ClusterIP 10.55.244.13 <none> 443/TCP 1h
NAME DESIRED CURRENT UP-TO-DATE AVAILABLE AGE
deployment.apps/kubernetes-dashboard 1 1 1 1 1h
NAME DESIRED CURRENT READY AGE
replicaset.apps/kubernetes-dashboard-598d75cb96 1 1 1 1h
```

* Мы вывели все объекты из неймспейса kube-system, имеющие label app=kubernetes-dashboard
* Зайдем в Dashboard
```
$ minikube service kubernetes-dashboard -n kube-system
```

### Dashboard
* В самом Dashboard можно:
 - отслеживать состояние кластера и рабочих нагрузок в нем
 - создавать новые объекты (загружать YAML-файлы)
 - Удалять и изменять объекты (кол-во реплик, yaml-файлы)
 - отслеживать логи в Pod-ах
 - при включении Heapster-аддона смотреть нагрузку на Pod-ах
 - и т.д.

## Minikube. Namespace
* Используем же namespace в наших целях. Отделим среду для разработки приложения от всего остального кластера. Для этого создадим свой Namespace dev
```
---
apiVersion: v1
kind: Namespace
metadata:
name: dev

$ kubectl apply -f dev-namespace.yml
namespace/dev created

$ kubectl get namespace
NAME                   STATUS   AGE
default                Active   135m
dev                    Active   30s
kube-node-lease        Active   135m
kube-public            Active   135m
kube-system            Active   135m
kubernetes-dashboard   Active   5m20s
```

* Запустим приложение в dev неймспейсе
```
$ kubectl apply -n dev -f .
deployment.apps/comment created
service/comment-db created
service/comment created
namespace/dev unchanged
deployment.apps/mongo created
service/mongodb created
deployment.apps/post created
service/post-db created
service/post created
deployment.apps/ui created
service/ui created
```

* Смотрим результат:
```
$ minikube service ui -n dev
|-----------|------|-------------|-----------------------------|
| NAMESPACE | NAME | TARGET PORT |             URL             |
|-----------|------|-------------|-----------------------------|
| dev       | ui   |             | http://192.168.99.100:32092 |
|-----------|------|-------------|-----------------------------|
```

* Добавим инфу об окружении внутрь контейнера UI `ui-deployment.yml`
```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ui
  labels:
    app: reddit
    component: ui
spec:
  replicas: 3
  selector:
    matchLabels:
      app: reddit
      component: ui
  template:
    metadata:
      name: ui-pod
      labels:
        app: reddit
        component: ui
    spec:
      containers:
        - image: mrshadow74/ui
          name: ui
          env:
          - name: ENV
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
```

* И применим изменения
```
$ kubectl apply -f ui-deployment.yml -n dev
deployment.apps/ui configured
```

## Разворачиваем Kubernetes

* Мы подготовили наше приложение в локальном окружении. Теперь самое время запустить его на реальном кластере Kubernetes. В качестве основной платформы будем использовать Google Kubernetes Engine.
* Зайдите в свою gcloud console, перейдите в “kubernetes clusters”, нажмите “создать Cluster”
* Укажите следующие настройки кластера:
 - Тип машины - небольшая машина (1,7 ГБ) (для экономии ресурсов)
 - Размер - 2
 - Базовая аутентификация - отключена
 - Устаревшие права доступа - отключено
 - Панель управления Kubernetes - отключено
 - Размер загрузочного диска - 20 ГБ (для экономии)

### GCE
* Компоненты управления кластером запускаются в container engine и управляются Google:
 - kube-apiserver
 - kube-scheduler
 - kube-controller-manager
 - etcd
* Рабочая нагрузка (собственные POD-ы), аддоны, мониторинг, логирование и т.д. запускаются на рабочих нодах
* Рабочие ноды - стандартные ноды Google compute engine. Их можно увидеть в списке запущенных узлов. На них всегда можно зайти по ssh, их можно остановить и запустить.
* Подключимся к GKE для запуска нашего приложения
```
$ gcloud container clusters get-credentials standard-cluster-1 --zone europe-west3-c --project global-incline-258416
```
* В результате в файл `~/.kube/config` будут добавлены *user*, *cluster* и *context* для подключения к кластеру в GKE. Также текущий контекст будет выставлен для подключения к этому кластеру. Убедиться можно, введя
```
$ kubectl config current-context
gke_global-incline-258416_europe-west3-c_standard-cluster-1
```
* Запустим наше приложение в GKE. Создадим *dev* namespace
```
$ kubectl apply -f ./kubernetes/reddit/dev-namespace.yml
namespace/dev created
```

* Задеплоим все компоненты приложения в namespace dev
```
$ kubectl apply -f ./kubernetes/reddit/ -n dev
deployment.apps/comment created
service/comment-db created
service/comment created
namespace/dev unchanged
deployment.apps/mongo created
service/mongodb created
deployment.apps/post created
service/post-db created
service/post created
deployment.apps/ui created
service/ui created
```
* Откроем Reddit для внешнего мира, зайдем в “правила брандмауэра”, нажмем “создать правило брандмауэра”
* Откроем диапазон портов kubernetes для публикации сервисов:
 - Название - произвольно, но понятно
 - Целевые экземпляры - все экземпляры в сети
 - Диапазоны IP-адресов источников - 0.0.0.0/0
 - Протоколы и порты - Указанные протоколы и порты tcp:30000-32767
* Найдем внешний IP-адрес любой ноды из кластера либо в веб-консоли, либо External IP в выводе
```
$ kubectl get nodes -o wide
NAME                                                STATUS   ROLES    AGE   VERSION          INTERNAL-IP   EXTERNAL-IP     OS-IMAGE                             KERNEL-VERSION   CONTAINER-RUNTIME
gke-standard-cluster-1-default-pool-ababd233-mhwg   Ready    <none>   16m   v1.15.4-gke.22   10.156.0.5    34.89.184.112   Container-Optimized OS from Google   4.19.76+         docker://19.3.1
gke-standard-cluster-1-default-pool-ababd233-wvvg   Ready    <none>   16m   v1.15.4-gke.22   10.156.0.6    34.89.246.216   Container-Optimized OS from Google   4.19.76+         docker://19.3.1
```
* Найдем порт публикации сервиса ui
```
$ kubectl describe service ui -n dev | grep NodePort
Type:                     NodePort
NodePort:                 <unset>  32092/TCP
```
* Идем по адресу `http://34.89.184.112:32092/`
```
Microservices Reddit in dev ui-555c4746c7-c6n9l container
```
* В GKE также можно запустить Dashboard для кластера, нажмем на имя кластера, далее "изменить"
* В этом меню можно поменять конфигурацию кластера. Нам нужно включить дополнение “Панель управления Kubernetes”.
* А по факту это грязные инсинуации, так как сделать это в интерфейсе нельзя, нет сейчас такого пункта в меню. В документации кубернетис есть документ `https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/` с инструкцией
* Для включения нужно выполнить следкющую команду
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml

namespace/kubernetes-dashboard created
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/dashboard-metrics-scraper created
```
* Выполним в консоли команду `kubectl proxy`
```
Kubectl will make Dashboard available at http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```
* Требуется пройти авторизацию. Пройти ее невозможно, а кнопка Skip из слайда в домашнем заданим отсутствует. Традиционно поиск на stackoverflow дает решение `https://stackoverflow.com/questions/50747783/how-to-access-gke-kubectl-proxy-dashboard`
```
Provided you are authenticated with gcloud auth login and the current project and k8s cluster is configured to the one you need, authenticate kubectl to the cluster (this will write ~/.kube/config):

gcloud container clusters get-credentials <cluster name> --zone <zone> --project <project>
retrieve the auth token that the kubectl itself uses to authenticate as you

gcloud config config-helper --format=json | jq -r '.credential.access_token'
run

kubectl proxy

Then open a local machine web browser on

http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy (This will only work if you checked the checkbox Deploy Dashboard in GCP console)

and use the token from the second command to log in with your Google Account's permissions.
```

* Получаем необходимый нам токен, вводим его и получаем наш dashboard. 
* Скриншот сохранен ./kubernetes/GCE_screen.png

## Задание со *

### Развернуть Kubenetes-кластер в GKE с помощью Terraform модуля

* Для решения данной задачи буду использовать *Terraform Kubernetes Engine Module* `https://github.com/terraform-google-modules/terraform-google-kubernetes-engine`
* Созданы файл инфраструктуры terraform в каталоге `./kubernetes/Additional_task/terraform/`

* Сформированы файлы инфраструктуры terraform: `main.tf`, `output.tf`, `variable.tf`
* После выполнения `terraform plan && terraform aply` подключим кластер и проверим результат построения инфраструктуры
```
$ gcloud container clusters get-credentials kube-gke-test-cluster --region europe-west3 --project global-incline-258416

$ kubectl cluster-info
Kubernetes master is running at https://35.198.119.208
calico-typha is running at https://35.198.119.208/api/v1/namespaces/kube-system/services/calico-typha:calico-typha/proxy
GLBCDefaultBackend is running at https://35.198.119.208/api/v1/namespaces/kube-system/services/default-http-backend:http/proxy
Heapster is running at https://35.198.119.208/api/v1/namespaces/kube-system/services/heapster/proxy
KubeDNS is running at https://35.198.119.208/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://35.198.119.208/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy
```

* Посмотрим информацию о нодах
```
$ kubectl get nodes -o wide
NAME                                                  STATUS   ROLES    AGE   VERSION          INTERNAL-IP   EXTERNAL-IP     OS-IMAGE                             KERNEL-VERSION   CONTAINER-RUNTIME
gke-kube-gke-test-cl-default-node-poo-32f818e2-lxhk   Ready    <none>   11m   v1.15.4-gke.22   10.156.0.9    35.246.131.14   Container-Optimized OS from Google   4.19.76+         docker://19.3.1
gke-kube-gke-test-cl-default-node-poo-38f088ca-lrbs   Ready    <none>   11m   v1.15.4-gke.22   10.156.0.8    34.89.246.216   Container-Optimized OS from Google   4.19.76+         docker://19.3.1
gke-kube-gke-test-cl-default-node-poo-f40a3b42-lx5n   Ready    <none>   11m   v1.15.4-gke.22   10.156.0.7    34.89.184.112   Container-Optimized OS from Google   4.19.76+         docker://19.3.1
```

* Создадим окружение dev
$ kubectl apply -f ./kubernetes/reddit/dev-namespace.yml

* Развернем наше приложение
```
$ kubectl apply -f ./kubernetes/reddit/ -n dev
```

* Посмотрим перечень созданных нод
```
$ kubectl get nodes -n dev
NAME                                                  STATUS   ROLES    AGE   VERSION
gke-kube-gke-test-cl-default-node-poo-32f818e2-lxhk   Ready    <none>   11m   v1.15.4-gke.22
gke-kube-gke-test-cl-default-node-poo-38f088ca-lrbs   Ready    <none>   11m   v1.15.4-gke.22
gke-kube-gke-test-cl-default-node-poo-f40a3b42-lx5n   Ready    <none>   11m   v1.15.4-gke.22
```

* Посмотрим список подов
```
$ kubectl get pod -n dev
NAME                       READY   STATUS    RESTARTS   AGE
comment-744bbdc5cc-6rfqk   1/1     Running   0          17m
comment-744bbdc5cc-7n7pw   1/1     Running   0          17m
comment-744bbdc5cc-88hpw   1/1     Running   0          17m
mongo-7f5c49d9b4-vg5k5     1/1     Running   0          17m
post-7cf6db88ff-7n5sd      1/1     Running   0          17m
post-7cf6db88ff-blwvm      1/1     Running   0          17m
post-7cf6db88ff-fn2vw      1/1     Running   0          17m
ui-555c4746c7-4zx7t        1/1     Running   0          17m
ui-555c4746c7-9tgzf        1/1     Running   0          17m
ui-555c4746c7-cw9t2        1/1     Running   0          17m
```

* Проверяем в разрезе приложений и сервисов
```
$ kubectl -n dev get deployments
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
comment   3/3     3            3           22m
mongo     1/1     1            1           22m
post      3/3     3            3           22m
ui        3/3     3            3           22m

$ kubectl -n dev get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)          AGE
comment      ClusterIP   10.0.3.191   <none>        9292/TCP         24m
comment-db   ClusterIP   10.0.9.134   <none>        27017/TCP        24m
mongodb      ClusterIP   10.0.14.51   <none>        27017/TCP        24m
post         ClusterIP   10.0.11.72   <none>        5000/TCP         24m
post-db      ClusterIP   10.0.2.61    <none>        27017/TCP        24m
ui           NodePort    10.0.14.0    <none>        9292:32092/TCP   24m
```

* Проверяем наше приложение `http://35.246.131.14:32092/` - все открывается, работает.

### Создать YAML-манифесты для описания созданных сущностей для включения dashboard

* Для выполнения данного задания использован YAML-манифест `https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml`. Данный манифест выполняет полный набор операций для активации дашборда кубернетис.
* Файл сохранен `./kubernetes/Additional_task/k8s_dashboard_create.yaml`

# HW21 Kubernetes. Networks ,Storages

* План
 - Ingress Controller
 - Ingress
 - Secret
 - TLS
 - LoadBalancer Service
 - Network Policies
 - PersistentVolumes
 - PersistentVolumeClaims

## Сетевое взаимодействие

* В предыдущей работе нам уже довелось настраивать сетевое взаимодействие с приложением в Kubernetes с помощью Service - абстракции, определяющей конечные узлы доступа (Endpoint’ы) и способ коммуникации с ними (nodePort, LoadBalancer, ClusterIP). Разберем чуть подробнее что в реальности нам это дает.

* *Service* - определяет конечные узлы доступа (Endpoint’ы):
 - селекторные сервисы (k8s сам находит POD-ы по label’ам)
 - безселекторные сервисы (мы вручную описываем конкретные endpoint’ы)
* и *способ коммуникации* с ними (тип (type) сервиса):
 - ClusterIP - дойти до сервиса можно только изнутри кластера
 - nodePort - клиент снаружи кластера приходит на опубликованный порт
 - LoadBalancer - клиент приходит на облачный (aws elb, Google gclb) ресурс балансировки
 - ExternalName - внешний ресурс по отношению к кластеру

* Вспомним, как выглядели Service’ы. Это селекторный сервис типа ClusetrIP (тип не указан, т.к. этот тип по-умолчанию).
```
 ---
apiVersion: v1
kind: Service
metadata:
  name: post
  labels:
    app: reddit
    component: post
spec:
  ports:
  - port: 5000
    protocol: TCP
    targetPort: 5000
  selector:
    app: reddit
    component: post
```

* *ClusterIP* - это виртуальный (в реальности нет интерфейса, pod’а или машины с таким адресом) IP-адрес из диапазона адресов для работы внутри, скрывающий за собой IP-адреса реальных POD-ов. Сервису любого типа (кроме ExternalName) назначается этот IP-адрес. В предыдущем задании мы могли его увидеть, например выполнив команду `kubectl get services -n dev`
```
$ kubectl get services -n dev
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
comment      ClusterIP   10.0.9.142    <none>        9292/TCP         3m55s
comment-db   ClusterIP   10.0.10.163   <none>        27017/TCP        3m56s
mongodb      ClusterIP   10.0.8.160    <none>        27017/TCP        3m54s
post         ClusterIP   10.0.15.15    <none>        5000/TCP         3m53s
post-db      ClusterIP   10.0.1.35     <none>        27017/TCP        3m53s
ui           NodePort    10.0.7.88     <none>        9292:32092/TCP   3m52s
```

### Kube-dns

* Отметим, что *Service* - это лишь абстракция и описание того, как получить доступ к сервису. Но опирается она на реальные механизмы и объекты: DNS-сервер, балансировщики, iptables.
* Для того, чтобы дойти до сервиса, нам нужно узнать его адрес по имени. Kubernetes не имеет своего собственного DNS-сервера для разрешения имен. Поэтому используется плагин *kube-dns* (это тоже Pod). Его задачи:
 - ходить в API Kubernetes’a и отслеживать Service-объекты
 - заносить DNS-записи о Service’ах в собственную базу
 - предоставлять DNS-сервис для разрешения имен в IP-адреса (как внутренних, так и внешних)

* Можете убедиться, что при отключенном kube-dns сервисе связность между компонентами reddit-app пропадет и он перестанет работать.
 - Проскейлим в 0 сервис, который следит, чтобы dns-kube подов всегда хватало
```
$ kubectl scale deployment --replicas 0 -n kube-system kube-dns-autoscaler
deployment.extensions/kube-dns-autoscaler scaled
```
 - Проскейлим в 0 сам kube-dns
```
$ kubectl scale deployment --replicas 0 -n kube-system kube-dns
deployment.extensions/kube-dns scaled
```
 - Попробуйте достучатсья по имени до любого сервиса.
```
$ kubectl exec -ti -n dev post-7cf6db88ff-h9xc2 ping comment
ping: bad address 'comment'
command terminated with exit code 1
```
 - Вернем kube-dns-autoscale в исходную
```
$ kubectl scale deployment --replicas 1 -n kube-system kube-dnsautoscaler
deployment.extensions/kube-dns-autoscaler scaled
```
 - Проверим, что приложение заработало, все стабильно.

* Как уже говорилось, ClusterIP - виртуальный и не принадлежит ни одной реальной физической сущности. Его чтением и дальнейшими действиями с пакетами, принадлежащими ему, занимается в нашем случае iptables, который настраивается утилитой kube-proxy (забирающей инфу с API-сервера). Сам kube-proxy, можно настроить на прием трафика, но это устаревшее поведение и не рекомендуется его применять. На любой из нод кластера можно посмотреть эти правила IPTABLES.

### Kubenet
* А в рамках кластера? На самом деле, независимо от того, на одной ноде находятся
поды или на разных - трафик проходит через свою цепочку.
* Kubernetes не имеет в комплекте механизма организации overlay-сетей (как у Docker Swarm). Он лишь предоставляет интерфейс для этого. Для создания Overlay-сетей используются отдельные аддоны: Weave, Calico, Flannel, … . В Google Kontainer Engine (GKE)
используется собственный плагин kubenet (он - часть kubelet).
* Он работает только вместе с платформой GCP и, по-сути занимается тем, что настраивает google-сети для передачи трафика Kubernetes. Поэтому в конфигурации Docker сейчас вы не увидите никаких Overlay-сетей.

### nodePort
* Service с типом *NodePort* - похож на сервис типа *ClusterIP*, только к нему прибавляется прослушивание портов нод (всех нод) для доступа к сервисам *снаружи*. При этом ClusterIP также назначается этому сервису для доступа к нему изнутри кластера.
* *kube-proxy* прослушивается либо заданный порт (nodePort: 32092), либо порт из диапазона 30000-32670. Дальше IPTables решает, на какой Pod попадет трафик.
* Сервис UI мы уже публиковали наружу с помощью *NodePort*
* Тип *NodePort* хоть и предоставляет доступ к сервису снаружи, но открывать все порты наружу или искать IP-адреса наших нод (которые вообще динамические) не очень удобно.

### LoadBalancer
* Тип *LoadBalancer* позволяет нам использовать внешний облачный балансировщик нагрузки как единую точку входа в наши сервисы, а не полагаться на IPTables и не открывать наружу весь кластер.
* Настроим соответствующим образом Service UI для работы *LoadBalacer*
```
$ kubectl apply -f ./kubernetes/reddit/ui-service.yml -n dev
service/ui configured
```
* И проверим, что у нас получилось
```
$ kubectl get service -n dev --selector component=ui
NAME   TYPE           CLUSTER-IP   EXTERNAL-IP     PORT(S)        AGE
ui     LoadBalancer   10.0.7.88    34.89.224.172   80:32092/TCP   36m
```
* Откроем наше приложение в браузере по адресу LoadBalancer-а `http://34.89.224.172` - приложение доступно и работает.
* В консоли GCP в разделе Network services - Load balancing создался балансировщик с именем `a5619a18b81f3407285776cc90b8c4d2`, который объеденил все хосты нашего кластера.
```
$ kubectl get services -n dev
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE
comment      ClusterIP      10.0.9.142    <none>          9292/TCP       43m
comment-db   ClusterIP      10.0.10.163   <none>          27017/TCP      43m
mongodb      ClusterIP      10.0.8.160    <none>          27017/TCP      43m
post         ClusterIP      10.0.15.15    <none>          5000/TCP       43m
post-db      ClusterIP      10.0.1.35     <none>          27017/TCP      43m
ui           LoadBalancer   10.0.7.88     34.89.224.172   80:32092/TCP   43m
```

* Но есть но: балансировка с помощью Service типа LoadBalancing имеет ряд недостатков:
 - нельзя управлять с помощью http URI (L7-балансировка)
 - используются только облачные балансировщики (AWS, GCP)
 - нет гибких правил работы с трафиком.

### Ingress
* Для более удобного управления входящим снаружи трафиком и решения недостатков *LoadBalancer* можно использовать другой объект Kubernetes - *Ingress*.
* *Ingress* – это набор правил внутри кластера Kubernetes, предназначенных для того, чтобы входящие подключения могли достичь сервисов (Services). Сами по себе Ingress’ы это просто правила. Для их применения нужен *Ingress Controller*.
* Для работы Ingress-ов необходим Ingress Controller. В отличие остальных контроллеров k8s - он не стартует вместе с кластером.
* *Ingress Controller* - это скорее плагин (а значит и отдельный POD), который состоит из 2-х функциональных частей:
 - Приложение, которое отслеживает через k8s API новые объекты Ingress и обновляет конфигурацию балансировщика
 - Балансировщик (Nginx, haproxy, traefik,…), который и занимается управлением сетевым трафиком
* Основные задачи, решаемые с помощью Ingress’ов:
 - Организация единой точки входа в приложения снаружи
 - Обеспечение балансировки трафика
 - Терминация SSL
 - Виртуальный хостинг на основе имен и т.д
* Посколько у нас web-приложение, нам вполне было бы логично использовать L7-балансировщик вместо Service LoadBalancer.
* Google в GKE уже предоставляет возможность использовать их собственные решения балансирощик в качестве Ingress controller-ов. Перейдем в настройки кластера в веб-консоли gcloud.
* Убедимся, что встроенный Ingress включен (HTTP load balancing - Enabled)
* Создадим Ingress для сервиса UI
```
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ui
spec:
  backend:
    serviceName: ui
    servicePort: 80
```
* Это *Singe Service Ingress* - значит, что весь ingress контроллер будет просто балансировать нагрузку на Node-ы для одного сервиса (очень похоже на Service LoadBalancer)
* Ну и применим новый конфиг
```
$ kubectl apply -f kubernetes/reddit/ui-ingress.yml -n dev
ingress.extensions/ui created
```
* В web-консоли можно увидеть новое правило `k8s-um-dev-ui--e14a6e1b3389d985`. Из свойст нового правила видно, что для работы с Ingress в GCP ему нужен минимум один Service с типом NodePort. У нас как раз он один уже есть.
* Посмотрим в сам кластер
```
$ kubectl get ingress -n dev
NAME   HOSTS   ADDRESS         PORTS   AGE
ui     *       34.107.216.76   80      9m41s
```
* Откроем в браузере новый адрес, проверим - все работает исправно.
* Но и в текущей схеме есть несколько недостатков:
 - у нас 2 балансировщика для 1 сервиса
 - Мы не умеем управлять трафиком на уровне HTTP

* Один балансировщик можно спокойно убрать. Обновим сервис для UI
```
---
apiVersion: v1
kind: Service
metadata:
  name: ui
  labels:
    app: reddit
    component: ui
spec:
  type: NodePort
  ports:
  - port: 9292
    protocol: TCP
    targetPort: 9292
  selector:
    app: reddit
    component: ui
```

* И применим его
```
$ kubectl apply -f ./kubernetes/reddit/ui-service.yml -n dev
service/ui configured
```

* Заставим работать Ingress Controller как классический веб
```
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ui
spec:
  rules:
  - http:
      paths:
      - path: /*
        backend:
          serviceName: ui
          servicePort: 9292
```

* Применили, проверили - все работает.

### Secret

* Теперь защитим наш сервис с помощью TLS. Вспомним Ingress IP
```
$ kubectl get ingress -n dev
NAME   HOSTS   ADDRESS         PORTS   AGE
ui     *       34.107.216.76   80      38m
```

* Подготовим сертификат используя IP как CN
```
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=34.107.216.76"
Generating a RSA private key
.........................................................+++++
............................................................+++++
writing new private key to 'tls.key'
-----
```

* И загрузим сертификат в кластер kubernetes
```
$ kubectl create secret tls ui-ingress --key tls.key --cert tls.crt -n dev
secret/ui-ingress created
```

* Проверим результат загрузки командой
```
$ kubectl describe secret ui-ingress -n dev
Name:         ui-ingress
Namespace:    dev
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.key:  1704 bytes
tls.crt:  1123 bytes
```

* Теперь настроим Ingress на прием только HTTPS траффика
```
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ui
  annotations:
    kubernetes.io/ingress.allow-http: "false"
spec:
  tls:
  - secretName: ui-ingress
  backend:
    serviceName: ui
    servicePort: 9292
```

* Применим и проверим
```
$ kubectl apply -f ./kubernetes/reddit/ui-ingress.yml -n dev
ingress.extensions/ui configured
```

* В консоли в свойствах балансировщика видим, что старое правило для http не удалилось полностью. Необходимо удалить полностью существующее правило и создать его заново
```
$ kubectl delete ingress ui -n dev
ingress.extensions "ui" deleted
eaa@noname:~/GitHub/MrShadow74_microservices$ kubectl apply -f ./kubernetes/reddit/ui-ingress.yml -n dev
ingress.extensions/ui created
```
* Правила Ingress могут долго применяться, если не получилось зайти с первой попытки - подождите и попробуйте еще раз.
* Заходим на страницу нашего приложения по http и получаем отказ.
* Заходим на страницу нашего приложения по https, подтверждаем исключение безопасности (у нас сертификат самоподписанный) и видим что все работает.

## Задание со *
* Опишите создаваемый объект Secret в виде Kubernetes-манифеста.
* Линки по данной теме:
 - документация kubernetes `https://kubernetes.io/docs/concepts/configuration/secret/`
 - примеры кодов всевозможных видов secret `https://github.com/kubernetes/kubernetes/blob/release-1.15/pkg/apis/core/types.go#L4458`
 - кусочек, который нужен для реализации нашего типа secret `SecretTypeTLS` в задании `https://github.com/kubernetes/kubernetes/blob/release-1.15/pkg/apis/core/types.go#L4530`
```
// SecretTypeTLS contains information about a TLS client or server secret. It
// is primarily used with TLS termination of the Ingress resource, but may be
// used in other types.
//
// Required fields:
// - Secret.Data["tls.key"] - TLS private key.
//   Secret.Data["tls.crt"] - TLS certificate.
// TODO: Consider supporting different formats, specifying CA/destinationCA.

SecretTypeTLS SecretType = "kubernetes.io/tls"
// TLSCertKey is the key for tls certificates in a TLS secret.
TLSCertKey = "tls.crt"
// TLSPrivateKeyKey is the key for the private key field in a TLS secret.
TLSPrivateKeyKey = "tls.key"
```

* Создадим файл `ui-secret.yml`
```
---
apiVersion: v1
kind: Secret
metadata:
  name: ui-ingress
type: kubernetes.io/tls
data:
  tls.crt: base64-encoded-content-of_tls.crt
  tls.key: base64-encoded-content-of_tls.key
```

* Удалим текущий secret
```
kubectl delete secrets ui-ingress -n dev
secret "ui-ingress" deleted
```
* И создадим новый secret из нашего файла `ui-secret.yml`
```
$ kubectl apply -f ui-secret.yml -n dev
secret/ui-ingress created
```
* Проверим результат
```
$ kubectl get secret -n dev
NAME                  TYPE                                  DATA   AGE
default-token-bdqlt   kubernetes.io/service-account-token   3      25h
ui-ingress            kubernetes.io/tls                     2      22s
```
* Откроем наше приложение в браузере - всё хорошо работает.

## Network Policy
* В прошлых проектах мы договорились о том, что хотелось бы разнести сервисы базы данных и сервис фронтенда по разным сетям, сделав их недоступными друг для друга.
* В Kubernetes у нас так сделать не получится с помощью отдельных сетей, так как все POD-ы могут достучаться друг до друга по-умолчанию.
* Мы будем использовать *NetworkPolicy* - инструмент для декларативного описания потоков трафика. Отметим, что не все сетевые плагины поддерживают политики сети. В частности, у GKE эта функция пока в Beta-тесте и для её работы отдельно будет включен сетевой плагин *Calico* (вместо *Kubenet*). Его мы и протеструем.
* Наша задача - ограничить трафик, поступающий на *mongodb* отовсюду, кроме сервисов post и comment.
* Найдите имя кластера
```
$ gcloud beta container clusters list
NAME       LOCATION        MASTER_VERSION  MASTER_IP     MACHINE_TYPE  NODE_VERSION   NUM_NODES  STATUS
kuber-gke  europe-west3-b  1.15.4-gke.22   34.89.253.47  g1-small      1.15.4-gke.22  3          RECONCILING
```
* Включим network-policy для GKE
```
$ gcloud beta container clusters update kuber-gke --zone=europe-west3-b --update-addons=NetworkPolicy=ENABLED
Updating kuber-gke...done.
Updated [https://container.googleapis.com/v1beta1/projects/global-incline-258416/zones/europe-west3-b/clusters/kuber-gke].
To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/europe-west3-b/kuber-gke?project=global-incline-258416

$ gcloud beta container clusters update kuber-gke --zone=europe-west3-b --enable-network-policy
Enabling/Disabling Network Policy causes a rolling update of all
cluster nodes, similar to performing a cluster upgrade.  This
operation is long-running and will block other operations on the
cluster (including delete) until it has run to completion.

Do you want to continue (Y/n)?  y

Updating kuber-gke...done.
Updated [https://container.googleapis.com/v1beta1/projects/global-incline-258416/zones/europe-west3-b/clusters/kuber-gke].
To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/europe-west3-b/kuber-gke?project=global-incline-258416
```

* Дождемся, пока кластер обновится. Может быть предложено добавить beta-функционал в gcloud - нажмем yes.

* Создадим файл `mongo-network-policy.yml`
```
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-db-traffic
  labels:
    app: reddit
spec:
  podSelector:
    matchLabels:
      app: reddit
      component: mongo
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: reddit
          component: comment
```

* Применяем политику и проверим работу приложения
```
$ kubectl apply -f mongo-network-policy.yml -n dev
networkpolicy.networking.k8s.io/deny-db-traffic created

$ kubectl describe networkpolicies deny-db-traffic -n dev
Name:         deny-db-traffic
Namespace:    dev
Created on:   2020-01-06 16:31:40 +0500 +05
Labels:       app=reddit
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"networking.k8s.io/v1","kind":"NetworkPolicy","metadata":{"annotations":{},"labels":{"app":"reddit"},"name":"deny-db-traffic...
Spec:
  PodSelector:     app=reddit,component=mongo
  Allowing ingress traffic:
    To Port: <any> (traffic allowed to all ports)
    From:
      PodSelector: app=reddit,component=comment
    ----------
    To Port: <any> (traffic allowed to all ports)
    From:
      PodSelector: app=reddit,component=post
  Not affecting egress traffic
  Policy Types: Ingress
```

* По тексту задания должны получить ошибку доступа сервиса post - ее мы и получили. Теперь нужно дополнить правила `mongo-network-policy.yml, чтобы все заработало.
```
  - from:
    - podSelector:
        matchLabels:
          app: reddit
          component: post
```
* Проверяем - теперь все хорошо, работает.

### Хранилище для базы

* Рассмотрим вопросы хранения данных. Основной Stateful сервис в нашем приложении - это база данных MongoDB. В текущий момент она запускается в виде Deployment и хранит данные в стаднартный Docker Volume-ах. Это имеет несколько проблем:
 - при удалении POD-а удаляется и Volume
 - потеря Nod’ы с mongo грозит потерей данных
 - запуск базы на другой ноде запускает новый экземпляр данных.

* Создадим файл `mongo-deployment.yml`
```
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
    post-db: "true"
    comment-db: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo
      labels:
        app: reddit
        component: mongo
        post-db: "true"
        comment-db: "true"
    spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts:
        - name: mongo-persistent-storage
          mountPath: /data/db
      volumes:
      - name: mongo-persistent-storage
        emptyDir: {}
```

* Сейчас используется тип Volume *emptyDir*. При создании пода с таким типом просто создается пустой docker volume. При остановке POD’a содержимое emtpyDir удалится навсегда. Хотя в общем случае падение POD’a не вызывает удаления Volume’a. Задание:
 - создадм пост в приложении
 - удалим deployment для mongo
 - создам его заново.

* Пост создан, удалим деплоймент `kubectl delete -f mongo-deployment.yml -n dev`, создадим его заново `kubectl apply -f mongo-deployment.yml -n dev`. Созданный пост в результате данных действий пропал.

* Вместо того, чтобы хранить данные локально на ноде, имеет смысл подключить удаленное хранилище. В нашем случае можем использовать Volume gcePersistentDisk, который будет складывать данные в хранилище GCE.

* Создадим диск в Google Cloud.
```
$ gcloud compute disks create --size=25GB --zone=europe-west3-b reddit-mongo-disk
WARNING: You have selected a disk size of under [200GB]. This may result in poor I/O performance. For more information, see: https://developers.google.com/compute/docs/disks#performance.
Created [https://www.googleapis.com/compute/v1/projects/global-incline-258416/zones/europe-west3-b/disks/reddit-mongo-disk].
NAME               ZONE            SIZE_GB  TYPE         STATUS
reddit-mongo-disk  europe-west3-b  25       pd-standard  READY

New disks are unformatted. You must format and mount a disk before it
can be used. You can find instructions on how to do this at:

https://cloud.google.com/compute/docs/disks/add-persistent-disk#formatting
```

* Добавим новый Volume POD-у базы
```
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
    post-db: "true"
    comment-db: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo
      labels:
        app: reddit
        component: mongo
        post-db: "true"
        comment-db: "true"
    spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts:
        - name: mongo-gce-pd-storage
          mountPath: /data/db
      volumes:
      - name: mongo-persistent-storage
        emptyDir: {}
        volumes:
      - name: mongo-gce-pd-storage
        gcePersistentDisk:
          pdName: reddit-mongo-disk
          fsType: ext4
```

* Cмонтируем выделенный диск к POD’у mongo
```
$ kubectl apply -f mongo-deployment.yml -n dev
```
* Дождитесь, пересоздания Pod'а (занимает до 10 минут). Зайдем в приложение и добавим пост. А потом пересоздадим деплоймент mongo и проверим сохранность поста. Он, собственно, и на месте, как должно быть.

* Здесь `https://console.cloud.google.com/compute/disks` можно посмотреть на созданный диск и увидеть, какая машина его использует.

### PersistentVolume
* Используемый механизм Volume-ов можно сделать удобнее. Мы можем использовать не целый выделенный диск для каждого пода, а целый ресурс хранилища, общий для всего кластера. Тогда при запуске Stateful-задач в кластере, мы сможем запросить хранилище в виде такого же ресурса, как CPU или оперативная память. Для этого будем использовать механизм *PersistentVolume*.

* Создадим описание PersistentVolume в файле `mongo-volume.yml`
```
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: reddit-mongo-disk
spec:
  capacity:
    storage: 25Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  gcePersistentDisk:
    fsType: "ext4" 
    pdName: "reddit-mongo-disk"
```

* И теперь добавим PersistentVolume в кластер
```
$ kubectl apply -f mongo-volume.yml -n dev
persistentvolume/reddit-mongo-disk created
```

* Мы создали ресурс дискового хранилища, распространенный на весь кластер, в виде PersistentVolume. Чтобы выделить приложению часть такого ресурса - нужно создать запрос на выдачу - *PersistentVolumeClaim*. Claim - это именно запрос, а не само хранилище. С помощью запроса можно выделить место как из конкретного *PersistentVolume* (тогда параметры accessModes и StorageClass должны соответствовать, а места должно хватать), так и просто создать отдельный PersistentVolume под конкретный запрос.

* Создадим описание PersistentVolumeClaim (PVC) и добавим его в кластер
```
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: mongo-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 15Gi
```

* Таким образом мы выделили место в PV по запросу для нашей базы. Одновременно использовать один PV можно только по одному Claim’у.

### PersistentVolumeClaim
* Если Claim не найдет по заданным параметрам PV внутри кластера, либо тот будет занят другим Claim’ом то он сам создаст нужный ему PV воспользовавшись стандартным StorageClass.
```
$ kubectl describe storageclass standard -n dev
Name:                  standard
IsDefaultClass:        Yes
Annotations:           storageclass.kubernetes.io/is-default-class=true
Provisioner:           kubernetes.io/gce-pd
Parameters:            type=pd-standard
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     Immediate
Events:                <none>
```

* В нашем случае это обычный медленный Google Cloud Persistent Drive

### Подключение PVC
* Подключим PVC к нашим Pod'ам
```
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
    post-db: "true"
    comment-db: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo
      labels:
        app: reddit
        component: mongo
        post-db: "true"
        comment-db: "true"
    spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts:
        - name: mongo-gce-pd-storage
          mountPath: /data/db
      volumes:
      - name: mongo-gce-pd-storage
        persistentVolumeClaim:
          claimName: mongo-pvc
```
* Обновим наш деплоймент mongo, смонтируем выделенное по PVC хранилище к POD’у
mongo

### Динамическое выделение Volume'ов
* Создав PersistentVolume мы отделили объект "хранилища" от наших Service'ов и Pod'ов. Теперь мы можем его при необходимости переиспользовать. Но нам гораздо интереснее создавать хранилища при необходимости и в автоматическом режиме. В этом нам помогут StorageClass’ы. Они описывают где (какой провайдер) и какие хранилища создаются. В нашем случае создадим StorageClass Fast так, чтобы монтировались SSD-диски для работы нашего хранилища.
* Создадим описание StorageClass’а в файле `storage-fast.yml` и добавим StorageClass в кластер
```
---
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: fast
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
```
```
$ kubectl apply -f storage-fast.yml -n dev
storageclass.storage.k8s.io/fast created
```

### PVC + StorageClass
* Создадим описание PersistentVolumeClaim в файле `mongo-claim-dynamic.yml`
```
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: mongo-pvc-dynamic
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast
  resources:
    requests:
      storage: 10Gi
```

* Добавим StorageClass в кластер
```
$ kubectl apply -f mongo-claim-dynamic.yml -n dev
persistentvolumeclaim/mongo-pvc-dynamic created
```

### Подключение динамического PVC
* Подключим PVC к нашим Pod'ам `mongo-deployment.yml`
```
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
    post-db: "true"
    comment-db: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo
      labels:
        app: reddit
        component: mongo
        post-db: "true"
        comment-db: "true"
    spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts:
        - name: mongo-gce-pd-storage
          mountPath: /data/db
      volumes:
      - name: mongo-gce-pd-storage
        persistentVolumeClaim:
          claimName: mongo-pvc-dynamic
```

* Обновим описание нашего Deployment'а
```
$ kubectl apply -f mongo-deployment.yml -n dev
deployment.apps/mongo configured
```

* Давайте посмотрит какие в итоге у нас получились PersistentVolume'ы
```
$ kubectl get persistentvolume -n dev
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                   STORAGECLASS   REASON   AGE
pvc-2d2dc526-7dac-4b48-a840-649c296d99eb   10Gi       RWO            Delete           Bound       dev/mongo-pvc-dynamic   fast                    4m36s
pvc-be6654c0-1486-466a-b520-f664d35ae18d   15Gi       RWO            Delete           Bound       dev/mongo-pvc           standard                27m
reddit-mongo-disk                          25Gi       RWO            Retain           Available                                                   30m
```
* На созданные Kubernetes'ом диски можно посмотреть в web-консоли `https://console.cloud.google.com/compute/disks`

# CI/CD в Kubernetes

* План
	Работа с Helm
	Развертывание Gitlab в Kubernetes
	Запуск CI/CD конвейера в Kubernetes

## Helm

*Helm* - пакетный менеджер для Kubernetes.
С его помощью мы будем:
 1. Стандартизировать поставку приложения в Kubernetes
 2. Декларировать инфраструктуру
 3. Деплоить новые версии приложения

Helm - клиент-серверное приложение. Установим его клиентскую часть - консольный клиент Helm. Из репозитория возьмем последнюю редакцию 2.16.1 из 2 версии
```
wget https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz
cp helm /usr/local/bin
```

Helm читает конфигурацию kubectl (~/.kube/config) и сам определяет текущий контекст (кластер, пользователь, неймспейс). Если хотим сменить кластер, то либо меняем контекст с помощью `kubectl config set-context` либо подгружайте helm’у собственный config-файл флагом --kube-context.


* Установим серверную часть Helm’а - Tiller. Tiller - это аддон Kubernetes, т.е. Pod, который общается с API Kubernetes. Для этого понадобится ему выдать ServiceAccount и назначить роли RBAC, необходимые для работы.

* Создадим файл `tiller.yml` и поместите в него yaml-манифест
```
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
```

Применим созданный манифест
```
$ kubectl apply -f tiller.yml
serviceaccount/tiller created
clusterrolebinding.rbac.authorization.k8s.io/tiller created
```

Теперь запустим tiller-сервер
```
$ helm init --service-account tiller
Creating /home/eaa/.helm
Creating /home/eaa/.helm/repository
Creating /home/eaa/.helm/repository/cache
Creating /home/eaa/.helm/repository/local
Creating /home/eaa/.helm/plugins
Creating /home/eaa/.helm/starters
Creating /home/eaa/.helm/cache/archive
Creating /home/eaa/.helm/repository/repositories.yaml
Adding stable repo with URL: https://kubernetes-charts.storage.googleapis.com
Adding local repo with URL: http://127.0.0.1:8879/charts
$HELM_HOME has been configured at /home/eaa/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
```

Проверим, что получилось
```
$ kubectl get pods -n kube-system --selector app=helm
NAME                             READY   STATUS    RESTARTS   AGE
tiller-deploy-54f7455d59-ws6sn   1/1     Running   0          60s
```

### Charts
*Chart* - это пакет в Helm. Создадим директорию Charts в папке kubernetes со следующей структурой директорий
```
├── Charts
    ├── comment
    ├── post
    ├── reddit
    └── ui
```

* Начнем разработку *Chart*’а для компонента *ui* приложения. Создадим файл-описание chart’а. Helm предпочитает *.yaml*
```
name: ui
version: 1.0.0
description: OTUS reddit application UI
maintainers:
  - name: Someone
    email: my@mail.com
appVersion: 1.0
```

Реально значимыми являются поля name и version. От них зависит работа Helm’а с Chart’ом. Остальное - описания.

### Templates

* Основным содержимым Chart’ов являются шаблоны манифестов Kubernetes.
	1) Создадим директорию ui/templates
	2) Перенесем в неё все манифесты, разработанные ранее для сервиса ui (ui-service, ui-deployment, ui-ingress)
	3) Переименем их (уберем префикс “ui-“) и поменяем расширение на .yaml) - стилистические правки
```
└── ui
 ├── Chart.yaml
 ├── templates
 │   ├── deployment.yaml
 │   ├── ingress.yaml
 │   └── service.yaml
```

* По-сути, это уже готовый пакет для установки в Kubernetes
	1) Убедитесь, что у вас не развернуты компоненты приложения в kubernetes. Если развернуты - удалите их
	2) Установим Chart
```
$ helm install --name test-ui-1 ui/
NAME:   test-ui-1
LAST DEPLOYED: Wed Jan  8 15:16:24 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Deployment
NAME  AGE
ui    1s

==> v1/Pod(related)
NAME                 AGE
ui-555c4746c7-8t7sq  1s
ui-555c4746c7-9nr6k  1s
ui-555c4746c7-rhs9z  1s

==> v1/Service
NAME  AGE
ui    1s

==> v1beta1/Ingress
NAME  AGE
ui    1s
```
Передаем имя и путь до Chart'a соответсвенно

	3) Посмотрим, что получилось
```
$ helm ls
NAME            REVISION        UPDATED                         STATUS          CHART           APP VERSION     NAMESPACE
test-ui-1       1               Wed Jan  8 15:16:24 2020        DEPLOYED        ui-1.0.0        1               default
```

Теперь необходимо сделать так, чтобы можно было использовать Chart №1 для запуска нескольких экземпляров (релизов). Шаблонизируем `ui/templates/service.yaml`
```
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: ui
    release: {{ .Release.Name }}
spec:
  type: NodePort
  ports:
  - port: 9292
    protocol: TCP
    targetPort: 9292
  selector:
    app: reddit
    component: ui
    release: {{ .Release.Name }}
```

`name: {{ .Release.Name }}-{{ .Chart.Name }}`
Здесь мы используем встроенные переменные
.Release - группа переменных с информацией о релизе (конкретном запуске Chart’а в k8s)
.Chart - группа переменных с информацией о Chart’е (содержимое файла Chart.yaml)
Также еще есть группы переменных:
.Template - информация о текущем шаблоне ( .Name и .BasePath)
.Capabilities - информация о Kubernetes (версия, версии API)
.Files.Get - получить содержимое файла

* Шаблонизируем подобным образом остальные сущности `ui/templates/deployment.yaml`
```
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: ui
    release: {{ .Release.Name }}
spec:
  replicas: 3
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: reddit
      component: ui
      release: {{ .Release.Name }}
  template:
    metadata:
      name: ui
      labels:
        app: reddit
        component: ui
        release: {{ .Release.Name }}
    spec:
      containers:
      - image: chromko/ui
        name: ui
        ports:
        - containerPort: 9292
          name: ui
          protocol: TCP
        env:
        - name: ENV
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
```
Важно, чтобы selector deployment'a нашел только нужные POD-ы

* Шаблонизируем подобным образом остальные сущности `ui/templates/ingress.yaml`
```
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  annotations:
    kubernetes.io/ingress.class: "gce"
spec:
  rules:
  - http:
      paths:
      - path: /*
        backend:
          serviceName: {{ .Release.Name }}-{{ .Chart.Name }}
          servicePort: 9292
```

* Установим несколько релизов ui
```
$ helm install --name test-ui-2 ui/
NAME:   test-ui-2
LAST DEPLOYED: Wed Jan  8 19:18:57 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Pod(related)
NAME                           AGE
test-ui-2-ui-5675c86955-l4vzw  1s
test-ui-2-ui-5675c86955-wbdqq  1s
test-ui-2-ui-5675c86955-xlvh8  1s

==> v1/Service
NAME          AGE
test-ui-2-ui  1s

==> v1beta1/Deployment
NAME          AGE
test-ui-2-ui  1s

==> v1beta1/Ingress
NAME          AGE
test-ui-2-ui  1s

$ helm install --name test-ui-3 ui/
NAME:   test-ui-3
LAST DEPLOYED: Wed Jan  8 19:19:06 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Pod(related)
NAME                           AGE
test-ui-3-ui-7dd6979644-mxnmz  1s
test-ui-3-ui-7dd6979644-xjnzp  1s
test-ui-3-ui-7dd6979644-xwqpg  1s

==> v1/Service
NAME          AGE
test-ui-3-ui  1s

==> v1beta1/Deployment
NAME          AGE
test-ui-3-ui  1s

==> v1beta1/Ingress
NAME          AGE
test-ui-3-ui  1s
```

В результате мы должны получить 3 ingress'а
```
$ kubectl get ingress
NAME           HOSTS   ADDRESS         PORTS     AGE
test-ui-1-ui   *                       80        17s
test-ui-2-ui   *       35.190.64.129   80        5m6s
test-ui-3-ui   *       34.107.216.76   80        4m57s
ui             *                       80, 443   4h7m
```
Видимо оставалось наследие, попробуем почистить и пересоздать
```
$ helm del --purge test-ui-1
release "test-ui-1" deleted

$ helm install --name test-ui-1 ui/

$ kubectl get ingress
NAME           HOSTS   ADDRESS          PORTS   AGE
test-ui-1-ui   *       34.107.242.208   80      3m16s
test-ui-2-ui   *       35.190.64.129    80      8m5s
test-ui-3-ui   *       34.107.216.76    80      7m56s
```

По IP-адресам можно попасть на разные релизы ui-приложений. Необхидмо подождать пару минут после выполнения команды, пока ingress’ы станут доступными

Мы уже сделали возможность запуска нескольких версий приложений из одного пакета манифестов, используя лишь встроенные переменные. Кастомизируем установку своими переменными (образ и порт).
*ui/templates/deployment.yaml*
```
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: ui
    release: {{ .Release.Name }}
spec:
  replicas: 3
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: reddit
      component: ui
      release: {{ .Release.Name }}
  template:
    metadata:
      name: ui
      labels:
        app: reddit
        component: ui
        release: {{ .Release.Name }}
    spec:
      containers:
      - image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        name: ui
        ports:
        - containerPort: {{ .Values.service.internalPort }}
          name: ui
          protocol: TCP
        env:
        - name: ENV
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
```

*ui/templates/ingress.yaml*
```
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: ui
    release: {{ .Release.Name }}
spec:
  type: NodePort
  ports:
  - port: {{ .Values.service.externalPort }}
    protocol: TCP
    targetPort: {{ .Values.service.internalPort }}
  selector:
    app: reddit
    component: ui
    release: {{ .Release.Name }}
```

*ui/templates/ingress.yaml*
```
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  annotations:
    kubernetes.io/ingress.class: "gce"
spec:
  rules:
  - http:
      paths:
      - path: /
        backend:
          serviceName: {{ .Release.Name }}-{{ .Chart.Name }}
          servicePort: {{ .Values.service.externalPort }}
```


* Определим значения собственных переменных *ui/values.yaml*
```
---
service:
  internalPort: 9292
  externalPort: 9292

image:
  repository: mrshadow74/ui
  tag: latest
```

Так мы собрали Chart для развертывания ui-компоненты приложения. Он должен иметь следующую структуру
```
└── ui
    ├── Chart.yaml
    ├── templates
    │   ├── deployment.yaml
    │   ├── ingress.yaml
    │   └── service.yaml
    └── values.yaml
```

* Осталось аналогично собрать пакеты для остальных компонент
*post/templates/service.yaml*
```
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: post
    release: {{ .Release.Name }}
spec:
  type: ClusterIP
  ports:
  - port: {{ .Values.service.externalPort }}
    protocol: TCP
    targetPort: {{ .Values.service.internalPort }}
  selector:
    app: reddit
    component: post
    release: {{ .Release.Name }}
```

*post/templates/deployment.yaml*
```
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: post
    release: {{ .Release.Name }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: post
      release: {{ .Release.Name }}
  template:
    metadata:
      name: post
      labels:
        app: reddit
        component: post
        release: {{ .Release.Name }}
    spec:
      containers:
      - image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        name: post
        ports:
        - containerPort: {{ .Values.service.internalPort }}
          name: post
          protocol: TCP
        env:
        - name: POST_DATABASE_HOST
          value: {{ .Values.databaseHost }}
```

* Обратим внимание на адрес БД.
```
env:
- name: POST_DATABASE_HOST
value: postdb
```

Поскольку адрес БД может меняться в зависимости от условий запуска (бд отдельно от кластера, бд запущено в отдельном релизе), то создадим удобный шаблон для задания адреса БД.
```
env:
- name: POST_DATABASE_HOST
value: {{ .Values.databaseHost }}
```

Будем задавать бд через переменную databaseHost. Иногда лучше использовать подобный формат переменных вместо структур database.host, так как тогда прийдется определять структуру database, иначе helm выдаст ошибку. Используем функцию default. Если databaseHost не будет определена или ее значение будет пустым, то используется вывод функции printf (которая просто формирует строку <имя-релиза>-mongodb)
```
value: {{ .Values.databaseHost | default (printf "%s-mongodb" .Release.Name) }}

release-name-mongodb
```

* В итоге теперь, если databaseHost не задано, то будет использован адрес базы, поднятой внутри релиза. Более подробная по шаблонизации и функциям здесь `https://helm.sh/docs/chart_template_guide/#the-chart-template-developer-s-guide`

*post/values.yaml*
```
service:
  internalPort: 5000
  externalPort: 5000

image:
  repository: chromko/post
  tag: latest

databaseHost:
```

* Шаблонизируем сервис comment
`comment/templates/deployment.yaml`
```
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: comment
    release: {{ .Release.Name }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: comment
      release: {{ .Release.Name }}
  template:
    metadata:
      name: comment
      labels:
        app: reddit
        component: comment
        release: {{ .Release.Name }}
    spec:
      containers:
      - image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        name: comment
        ports:
        - containerPort: {{ .Values.service.internalPort }}
          name: comment
          protocol: TCP
        env:
        - name: COMMENT_DATABASE_HOST
          value: {{ .Values.databaseHost | default (printf "%s-mongodb" .Release.Name) }}
```

`comment/templates/service.yaml`
```
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: comment
    release: {{ .Release.Name }}
spec:
  type: ClusterIP
  ports:
  - port: {{ .Values.service.externalPort }}
    protocol: TCP
    targetPort: {{ .Values.service.internalPort }}
  selector:
    app: reddit
    component: comment
    release: {{ .Release.Name }}
```

`comment/values.yaml`
```
---
service:
  internalPort: 9292
  externalPort: 9292

image:
  repository: chromko/comment
  tag: latest

databaseHost:
```

* Итоговая структура
```
.
├── comment
│   ├── Chart.yaml
│   ├── templates
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   └── values.yml
├── post
│   ├── Chart.yaml
│   ├── templates
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   └── values.yml
├── reddit
├── tiller.yml
└── ui
    ├── Chart.yaml
    ├── templates
    │   ├── deployment.yaml
    │   ├── ingress.yaml
    │   └── service.yaml
    └── values.yml
```

* Также стоит отметить функционал helm по использованию helper’ов и функции templates. Helper - это написанная нами функция. В функция описывается, как правило, сложная логика. Шаблоны этих функция распологаются в файле *_helpers.tpl*

Пример функции на основе файла `comment.fullname: Charts/comment/templates/_helpers.tpl`
```
{{- define "comment.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name }}
{{- end -}}
```
Которая в результате выдаст нам то же, что и `{{ .Release.Name }}-{{ .Chart.Name }}`

* Скорректируем файл `charts/comment/templates/service.yaml`
```
---
apiVersion: v1
kind: Service
metadata:
  name: {{ template "comment.fullname" . }}
  labels:
    app: reddit
    component: comment
    release: {{ .Release.Name }}
spec:
  type: ClusterIP
  ports:
  - port: {{ .Values.service.externalPort }}
    protocol: TCP
    targetPort: {{ .Values.service.internalPort }}
  selector:
    app: reddit
    component: comment
    release: {{ .Release.Name }}
```

* По аналогии создадим для каждого сервиса файл `_helpers.tpl` и скорректируем манифесты под использование функции.
* Теперь структура выглядит так
```
.
├── comment
│   ├── Chart.yaml
│   ├── templates
│   │   ├── deployment.yaml
│   │   ├── _helpers.tpl
│   │   └── service.yaml
│   └── values.yml
├── post
│   ├── Chart.yaml
│   ├── templates
│   │   ├── deployment.yaml
│   │   ├── _helpers.tpl
│   │   └── service.yaml
│   └── values.yml
├── reddit
├── tiller.yml
└── ui
    ├── Chart.yaml
    ├── templates
    │   ├── deployment.yaml
    │   ├── _helpers.tpl
    │   ├── ingress.yaml
    │   └── service.yaml
    └── values.yml
```

### Управление зависимостями

* Мы создали Chart’ы для каждой компоненты нашего приложения. Каждый из них можно запустить по-отдельности командой `$ helm install <chart-path> --name <release-name>`. Но они будут запускаться в разных релизах, и не будут видеть друг друга. С помощью механизма управления зависимостями создадим единый Chart reddit, который объединит наши компоненты.

Создадим файл `reddit/Chart.yaml`
```
name: reddit
version: 0.1.0
description: OTUS sample reddit application
maintainers:
- name: mrshadow74
  email: mrshadow74@mail.ru
```

Создадим пустой файл `reddit/values.yaml`
Cоздадим файл `reddit/requirements.yaml`
```
---
dependencies:
  - name: ui
    version: "1.0.0"
    repository: "file://../ui"

  - name: post
    version: "1.0.0"
    repository: "file://../post"

  - name: comment
    version: "1.0.0"
    repository: "file://../comment"
```

Имя и версия должны совпадать с содержанием `<приложение>/Chart.yml`. Путь указывается относительно расположения самого `requirements.yaml`

Далее необходимо загрузить зависимости (когда Chart’ не упакован в tgz архив)
```
$ helm dep update
Hang tight while we grab the latest from your chart repositories...
...Unable to get an update from the "local" chart repository (http://127.0.0.1:8879/charts):
        Get http://127.0.0.1:8879/charts/index.yaml: dial tcp 127.0.0.1:8879: connect: connection refused
...Successfully got an update from the "stable" chart repository
Update Complete.
Saving 3 charts
Deleting outdated charts
```
Появится файл `requirements.lock` с фиксацией зависимостей, будет создана директория charts с зависимостями в виде архивов. Структура станет следующей
```
.
├── charts
│   ├── comment-1.0.0.tgz
│   ├── post-1.0.0.tgz
│   └── ui-1.0.0.tgz
├── Chart.yaml
├── requirements.lock
├── requirements.yaml
└── values.yaml
```

* Chart для базы данных не будем создавать вручную. Возьмем готовый.
1) Найдем Chart в общедоступном репозитории
```
$ helm search mongo
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
stable/mongodb                          7.6.3           4.0.14          NoSQL document-oriented database that stores JSON-like do...
stable/mongodb-replicaset               3.11.2          3.6             NoSQL document-oriented database that stores JSON-like do...
stable/prometheus-mongodb-exporter      2.4.0           v0.10.0         A Prometheus exporter for MongoDB metrics
stable/unifi                            0.5.2           5.11.50         Ubiquiti Network's Unifi Controller
```
Версия `stable/mongodb` отличается как от слайда задания, так и от гиста. Возьму последнюю стабильную.

2) добавлю в `reddit/requirements.yaml` запись по mongodb
```
  - name: mongodb
    version: 7.6.3
    repository: https://kubernetes-charts.storage.googleapis.com
```

3) Выгружу зависимости
```
$ helm dep update
Hang tight while we grab the latest from your chart repositories...
...Unable to get an update from the "local" chart repository (http://127.0.0.1:8879/charts):
        Get http://127.0.0.1:8879/charts/index.yaml: dial tcp 127.0.0.1:8879: connect: connection refused
...Successfully got an update from the "stable" chart repository
Update Complete.
Saving 4 charts
Downloading mongodb from repo https://kubernetes-charts.storage.googleapis.com
Deleting outdated charts
```
Дерево стало таким
```
.
├── charts
│   ├── comment-1.0.0.tgz
│   ├── mongodb-7.6.3.tgz
│   ├── post-1.0.0.tgz
│   └── ui-1.0.0.tgz
├── Chart.yaml
├── requirements.lock
├── requirements.yaml
└── values.yaml
```

* Установим наше приложение
```
$ helm install reddit --name reddit-test
Error: YAML parse error on reddit/charts/post/templates/deployment.yaml: error converting YAML to JSON: yaml: line 25: did not find expected key
```

Данная проблема похоже связана с копипастом кода и отсутсвием символов завершения строки. Поправим переносы и заново выполним команду `helm dep update` - без этого пакет не заработает.

Пробуем ещё раз
```
$ helm install reddit --name reddit-test
Error: YAML parse error on reddit/charts/post/templates/deployment.yaml: error converting YAML to JSON: yaml: line 25: did not find expected '-' indicator
```

Теперь проблема с форатированием - похоже helm очень чувствителен к правильности расположения текста. Правим, выполняем `heml dep update` и проверяе ещё раз.

```
$ helm install reddit --name reddit-test
NAME:   reddit-test
LAST DEPLOYED: Thu Jan  9 23:13:59 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Deployment
NAME                 AGE
reddit-test-mongodb  1s
reddit-test-post     1s

==> v1/PersistentVolumeClaim
NAME                 AGE
reddit-test-mongodb  1s

==> v1/Pod(related)
NAME                                  AGE
reddit-test-comment-7f849c8486-rcr2n  1s
reddit-test-mongodb-65b547b8f5-jvvkg  1s
reddit-test-post-65779b44f4-tmwz2     1s
reddit-test-ui-749d47bd49-2hpq4       1s
reddit-test-ui-749d47bd49-g98vc       1s
reddit-test-ui-749d47bd49-tft9n       1s

==> v1/Secret
NAME                 AGE
reddit-test-mongodb  1s

==> v1/Service
NAME                 AGE
reddit-test-comment  1s
reddit-test-mongodb  1s
reddit-test-post     1s
reddit-test-ui       1s

==> v1beta1/Deployment
NAME            AGE
reddit-test-ui  1s

==> v1beta1/Ingress
NAME            AGE
reddit-test-ui  1s

==> v1beta2/Deployment
NAME                 AGE
reddit-test-comment  1s
```
Дождемся формирование ингресса и проверим результат
```
$ helm list
NAME            REVISION        UPDATED                         STATUS          CHART           APP VERSION     NAMESPACE
reddit-test     1               Fri Jan 10 09:55:39 2020        DEPLOYED        reddit-0.1.0                    default

$ kubectl get ingress
NAME             HOSTS   ADDRESS         PORTS   AGE
reddit-test-ui   *       35.190.64.129   80      2m39s
```

Откроем адрес ингресса, в первом приближении результат положительный.

Есть проблема с тем, что UI-сервис не знает как правильно ходить в post и comment сервисы. Ведь их имена теперь динамические и зависят от имен чартов. В Dockerfile UI-сервиса уже заданы переменные окружения. Надо, чтобы они указывали на нужные бекенды
```
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
```

* Добавим в ui/deployments.yaml
```
…
env:
- name: POST_SERVICE_HOST
value: {{ .Values.postHost | default (printf "%s-post" .Release.Name) }}
- name: POST_SERVICE_PORT
value: {{ .Values.postPort | default "5000" | quote }}
- name: COMMENT_SERVICE_HOST
value: {{ .Values.commentHost | default (printf "%s-comment" .Release.Name)
}}
- name: COMMENT_SERVICE_PORT
value: {{ .Values.commentPort | default "9292" | quote }}
```

❗ Обратим внимание на функцию добавления кавычек. Для чисел и булевых значений это важно `{{ .Values.commentPort | default "9292" | quote }}`

Добавим в `ui/values.yaml`
```
ingress:
  class: nginx

postHost:
postPort:
commentHost:
commentPort:
```
Эти параметры можно сделать закомментированными или оставить пустыми. Главное, чтобы они были в конфигурации Chart’а в качестве документации.

* Можно задавать переменные для зависимостей прямо в `reddit/values.yaml` самого Chart’а reddit. Они имеют больший приоритет и перезаписывают значения переменных из зависимых чартов.
```
comment:
  image:
    repository: mrshadow74/comment
    tag: latest
  service:
    externalPort: 9292

post:
  image:
    repository: mrshadow74/post
    tag: latest
  service:
    externalPort: 5000

ui:
  image:
    repository: mrshadow74/ui
    tag: latest
  service:
    externalPort: 9292
```

* После обновления необходимо обновить зависимости чарта reddit.
```
$ helm dep update ./reddit
Hang tight while we grab the latest from your chart repositories...
...Unable to get an update from the "local" chart repository (http://127.0.0.1:8879/charts):
        Get http://127.0.0.1:8879/charts/index.yaml: dial tcp 127.0.0.1:8879: connect: connection refused
...Successfully got an update from the "stable" chart repository
Update Complete.
Saving 4 charts
Downloading mongodb from repo https://kubernetes-charts.storage.googleapis.com
Deleting outdated charts
```

И после этого обновим релиз и переоткроем web-страницу
```
$ helm upgrade reddit-test ./reddit
Release "reddit-test" has been upgraded.
LAST DEPLOYED: Fri Jan 10 10:51:30 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Deployment
NAME                 AGE
reddit-test-mongodb  55m
reddit-test-post     55m

==> v1/PersistentVolumeClaim
NAME                 AGE
reddit-test-mongodb  55m

==> v1/Pod(related)
NAME                                  AGE
reddit-test-comment-7f849c8486-fzwng  55m
reddit-test-mongodb-65b547b8f5-2fkjp  55m
reddit-test-post-65779b44f4-qg2j4     46m
reddit-test-post-7ccddc484f-hxmg4     2s
reddit-test-ui-749d47bd49-2dgrg       46m
reddit-test-ui-749d47bd49-g22gl       55m
reddit-test-ui-749d47bd49-qqrgc       55m

==> v1/Secret
NAME                 AGE
reddit-test-mongodb  55m

==> v1/Service
NAME                 AGE
reddit-test-comment  55m
reddit-test-mongodb  55m
reddit-test-post     55m
reddit-test-ui       55m

==> v1beta1/Deployment
NAME            AGE
reddit-test-ui  55m

==> v1beta1/Ingress
NAME            AGE
reddit-test-ui  55m

==> v1beta2/Deployment
NAME                 AGE
reddit-test-comment  55m
```

Что-то идет не так, post недоступен. Нашлась кучка неточностей в конфигах, удалим приложение и перевыкатим его еще раз.
```
$ helm list
helm deleNAME           REVISION        UPDATED                         STATUS          CHART           APP VERSION     NAMESPACE
reddit-test     3               Fri Jan 10 11:06:16 2020        DEPLOYED        reddit-0.1.0                    default

$ helm del --purge reddit-test
release "reddit-test" deleted

$ helm install ./reddit --name reddit-test
$ helm upgrade reddit-test ./reddit                                                              [15/1929]
Release "reddit-test" has been upgraded.
LAST DEPLOYED: Fri Jan 10 12:37:00 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Deployment
NAME                 AGE
reddit-test-mongodb  29m
reddit-test-post     29m
reddit-test-ui       29m

==> v1/PersistentVolumeClaim
NAME                 AGE
reddit-test-mongodb  29m

==> v1/Pod(related)
NAME                                  AGE
reddit-test-comment-67cbffbf7d-ql5zn  29m
reddit-test-mongodb-65b547b8f5-xlslv  29m
reddit-test-mongodb-7499bc7697-jf56b  6m37s
reddit-test-post-7ccddc484f-f6l2r     29m
reddit-test-ui-5999c9fd79-2j5vc       29m
reddit-test-ui-5999c9fd79-cmv9v       29m
reddit-test-ui-5999c9fd79-z4cwm       29m

==> v1/Service
NAME                 AGE
reddit-test-comment  29m
reddit-test-mongodb  29m
reddit-test-post     29m
reddit-test-ui       29m

==> v1beta1/Ingress
NAME            AGE
reddit-test-ui  29m

==> v1beta2/Deployment
NAME                 AGE
reddit-test-comment  29m
```

* Теперь все работает как и должно: приложение открывается, посты сохраняются, комментарии открываются.

### Как обезопасить себя? (helm2 tiller plugin)

До этого мы деплоили с помощью tiller'а с правами cluster-admin, что небезопасно. Есть концепция создания tiller'а в каждом namespace'е и наделение его лишь необходимыми правами. Чтобы не создавать каждый раз namespace и tiller в нем руками, используем tiller-plugin `https://github.com/rimusz/helm-tiller`, его описание здесь `https://rimusz.net/tillerless-helm`.

1. Удалим уже имеющийся tiller из кластера
```
$ helm reset
Error: there are still 1 deployed releases (Tip: use --force to remove Tiller. Releases will not be deleted.)
```
Прислушаемся к рекомендации и попробуем выполнить с ключом --force
```
$ helm reset --force
Tiller (the Helm server-side component) has been uninstalled from your Kubernetes Cluster.
```

2. Выполним установку плагина и сам деплой в новый namespace *reddit-ns*:
```
$ helm init --client-only
$HELM_HOME has been configured at /home/eaa/.helm.
Not installing Tiller due to 'client-only' flag having been set

$ helm plugin install https://github.com/rimusz/helm-tiller
Installed plugin: tiller

$ helm tiller run -- helm upgrade --install --wait --namespace=reddit-ns reddit reddit/          [25/1809]
Installed Helm version v2.16.1
Installed Tiller version v2.16.1
Helm and Tiller are the same version!
Starting Tiller...
Tiller namespace: kube-system
Running: helm upgrade --install --wait --namespace=reddit-ns reddit reddit/

Release "reddit" does not exist. Installing it now.
NAME:   reddit
LAST DEPLOYED: Fri Jan 10 15:13:15 2020
NAMESPACE: reddit-ns
STATUS: DEPLOYED

RESOURCES:
==> v1/Deployment
NAME            AGE
reddit-mongodb  30s
reddit-post     30s
reddit-ui       30s

==> v1/PersistentVolumeClaim
NAME            AGE
reddit-mongodb  31s

==> v1/Pod(related)
NAME                             AGE
reddit-comment-7fcd4bf47d-gxdwt  30s
reddit-mongodb-57844dcc44-bw626  30s
reddit-post-6c9c9765f5-snns5     30s
reddit-ui-7d77676698-bw2vs       30s
reddit-ui-7d77676698-r6tx9       30s
reddit-ui-7d77676698-vlgrs       30s

==> v1/Service
NAME            AGE
reddit-comment  30s
reddit-mongodb  31s
reddit-post     30s
reddit-ui       30s

==> v1beta1/Ingress
NAME       AGE
reddit-ui  30s

==> v1beta2/Deployment
NAME            AGE
reddit-comment  30s

Stopping Tiller...
```

3. Проверим, что все успешно, получив айпи от `kubectl get ingress -n reddit-ns` и пройдя по нему.
```
$ kubectl get ingress -n reddit-ns
NAME        HOSTS   ADDRESS         PORTS   AGE
reddit-ui   *       34.107.168.43   80      4m7s

Microservices Reddit in reddit-ns reddit-ui-7d77676698-vlgrs container
```

### Helm3
Опробуем в бою новую 3 версию helm.

1. Скачаем третью версию инструмента.
Линк из методички уже помер в связи с появлением релиза, будем пробовать его
```
$ wget https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz
```
2. Положим скаченный бинарник helm в PATH директорую с бинарниками под именем helm3
3. Создадим новый namespace *new-helm*
```
$ kubectl create ns new-helm
namespace/new-helm created
```
4. Задеплоимся
```
$ helm3 upgrade --install --namespace=new-helm --wait reddit-release reddit/
Release "reddit-release" does not exist. Installing it now.
NAME: reddit-release
LAST DEPLOYED: Fri Jan 10 21:30:13 2020
NAMESPACE: new-helm
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Посмотрим его детально
```
$ kubectl get ingress -n new-helm
NAME                HOSTS   ADDRESS          PORTS   AGE
reddit-release-ui   *       34.107.242.208   80      117s

$ kubectl describe ingress reddit-release-ui -n new-helm
Name:             reddit-release-ui
Namespace:        new-helm
Address:          34.107.242.208
Default backend:  default-http-backend:80 (10.8.1.8:8080)
Rules:
  Host  Path  Backends
  ----  ----  --------
  *
        /*   reddit-release-ui:9292 (10.8.0.5:9292,10.8.1.10:9292,10.8.2.3:9292)
Annotations:
  kubernetes.io/ingress.class:            gce
  ingress.kubernetes.io/backends:         {"k8s-be-30421--8f17c16aa2a9f28c":"HEALTHY","k8s-be-31104--8f17c16aa2a9f28c":"HEALTHY"}
  ingress.kubernetes.io/forwarding-rule:  k8s-fw-new-helm-reddit-release-ui--8f17c16aa2a9f28c
  ingress.kubernetes.io/target-proxy:     k8s-tp-new-helm-reddit-release-ui--8f17c16aa2a9f28c
  ingress.kubernetes.io/url-map:          k8s-um-new-helm-reddit-release-ui--8f17c16aa2a9f28c
Events:
  Type    Reason  Age    From                     Message
  ----    ------  ----   ----                     -------
  Normal  ADD     5m52s  loadbalancer-controller  new-helm/reddit-release-ui
  Normal  CREATE  4m50s  loadbalancer-controller  ip: 34.107.242.208

Microservices Reddit in new-helm reddit-release-ui-595d54678-fn9pr container
```

## GitLab + Kubernetes
* Подготовим GKE-кластер. Нам нужны машинки помощнее.
Добавим новый пул узлов:
назовем его `bigpool`;
1 узел типа n1-standard-2 (7,5 Гб, 2 виртуальных ЦП);
Размер диска 20 Гб.

С помощью пулов узлов можно добавлять в кластер новые машины разной мощности и комплектации. Необходимо подождать некоторое время, пока кластер будет готов к дальнейшей работе.

В итоге получаем штангу в виде лимитом CPUs=8.0 при запрашиваемом 9.0.
Создадим новый кластер

Отключим RBAC для упрощения работы. Gitlab-Omnibus пока не подготовлен для этого, а самим это в рамках работы смысла делать нет. Там же, в настройках кластера включим поддержку Enable legacy authorization

### Установим GitLab

Gitlab будем ставить также с помощью Helm Chart’а из пакета
Omnibus.
1. Добавим репозиторий Gitlab
```
$ helm repo add gitlab https://charts.gitlab.io
"gitlab" has been added to your repositories
```

2. Мы будем менять конфигурацию Gitlab, поэтому скачаем Chart
```
$ helm fetch gitlab/gitlab-omnibus --version 0.1.37 --untar
$ cd gitlab-omnibus
```

Теперь необходимо скорректировать конфигурацию по рекомендации ДЗ
1. Поправьте `gitlab-omnibus/values.yaml`
```
baseDomain: example.com
legoEmail: you@example.com
```
2. Добавьте в `gitlab-omnibus/templates/gitlab/gitlabsvc.yaml`
```
apiVersion: v1
kind: Service
metadata:
  name: {{ template "fullname" . }}
  labels:
    app: {{ template "fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
spec:
  selector:
    name: {{ template "fullname" . }}
  ports:
    - name: ssh
      port: 22
      targetPort: ssh
    - name: mattermost
      port: 8065
      targetPort: mattermost
    - name: registry
      port: 8105
      targetPort: registry
    - name: workhorse
      port: 8005
      targetPort: workhorse
    - name: prometheus
      port: 9090
      targetPort: prometheus
    - name: web
      port: 80
      targetPort: workhorse
```

3. Поправить в `gitlab-omnibus/templates/gitlab-config.yaml`
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ template "fullname" . }}-config
  labels:
    app: {{ template "fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
data:
  external_scheme: http
  external_hostname: {{ template "fullname" . }}
  registry_external_scheme: https
  registry_external_hostname: registry.{{ .Values.baseDomain }}
  mattermost_external_scheme: https
  mattermost_external_hostname: mattermost.{{ .Values.baseDomain }}
  mattermost_app_uid: {{ .Values.mattermostAppUID }}
  postgres_user: gitlab
  postgres_db: gitlab_production
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ template "fullname" . }}-secrets
  labels:
    app: {{ template "fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
data:
  postgres_password: {{ .Values.postgresPassword }}
  initial_shared_runners_registration_token: {{ default "" .Values.initialSharedRunnersRegistrationToken | b64enc | quote }}
  mattermost_app_secret: {{ .Values.mattermostAppSecret | b64enc | quote }}
{{- if .Values.gitlabEELicense }}
  gitlab_ee_license: {{ .Values.gitlabEELicense | b64enc | quote }}
{{- end }}
```

4. Поправить `gitlab-omnibus/templates/ingress/gitlab-ingress.yaml`
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ template "fullname" . }}
  labels:
    app: {{ template "fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
  annotations:
    kubernetes.io/tls-acme: "true"
    kubernetes.io/ingress.class: "nginx"
spec:
  tls:
  - hosts:
    - gitlab.{{ .Values.baseDomain }}
    - registry.{{ .Values.baseDomain }}
    - mattermost.{{ .Values.baseDomain }}
    - prometheus.{{ .Values.baseDomain }}
    secretName: gitlab-tls
  rules:
  - host: {{ template "fullname" . }}
    http:
      paths:
      - path: /
        backend:
          serviceName: {{ template "fullname" . }}
          servicePort: 8005
  - host: registry.{{ .Values.baseDomain }}
    http:
      paths:
      - path: /
        backend:
          serviceName: {{ template "fullname" . }}
          servicePort: 8105
  - host: mattermost.{{ .Values.baseDomain }}
    http:
      paths:
      - path: /
        backend:
          serviceName: {{ template "fullname" . }}
          servicePort: 8065
  - host: prometheus.{{ .Values.baseDomain }}
    http:
      paths:
      - path: /
        backend:
          serviceName: {{ template "fullname" . }}
          servicePort: 9090
---
```

* И задеплоим результат
```
$ helm install --name gitlab . -f values.yaml
NAME:   gitlab
LAST DEPLOYED: Sat Jan 11 16:35:26 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                             AGE
gitlab-gitlab-config             2s
gitlab-gitlab-postgresql-initdb  2s
gitlab-gitlab-runner             2s
kube-lego                        2s
nginx                            2s
tcp-ports                        2s

==> v1/Namespace
NAME           AGE
kube-lego      2s
nginx-ingress  2s

==> v1/PersistentVolumeClaim
NAME                              AGE
gitlab-gitlab-config-storage      2s
gitlab-gitlab-postgresql-storage  2s
gitlab-gitlab-redis-storage       2s
gitlab-gitlab-registry-storage    2s
gitlab-gitlab-storage             2s

==> v1/Pod(related)
NAME                                       AGE
default-http-backend-65b964d8cc-tf5qj      1s
gitlab-gitlab-6f69d99f66-pm97p             1s
gitlab-gitlab-postgresql-66d5b899b8-mg5x5  1s
gitlab-gitlab-redis-6c675dd568-h4ssg       1s
gitlab-gitlab-runner-cb5c77568-4dr2g       2s
kube-lego-cd56b654b-fmm52                  1s
nginx-7flh4                                1s
nginx-bt47h                                1s
nginx-fps8s                                1s
nginx-rr4k6                                1s
nginx-vghwp                                1s

==> v1/Secret
NAME                   AGE
gitlab-gitlab-runner   2s
gitlab-gitlab-secrets  2s

==> v1/Service
NAME                      AGE
default-http-backend      2s
gitlab-gitlab             2s
gitlab-gitlab-postgresql  2s
gitlab-gitlab-redis       2s
nginx                     2s

==> v1/StorageClass
NAME                AGE
gitlab-gitlab-fast  2s

==> v1beta1/DaemonSet
NAME   AGE
nginx  2s

==> v1beta1/Deployment
NAME                      AGE
default-http-backend      2s
gitlab-gitlab             2s
gitlab-gitlab-postgresql  2s
gitlab-gitlab-redis       2s
gitlab-gitlab-runner      2s
kube-lego                 2s

==> v1beta1/Ingress
NAME           AGE
gitlab-gitlab  2s


NOTES:

  It may take several minutes for GitLab to reconfigure.
    You can watch the status by running `kubectl get deployment -w gitlab-gitlab --namespace default
  You did not specify a baseIP so one will be assigned for you.
  It may take a few minutes for the LoadBalancer IP to be available.
  Watch the status with: 'kubectl get svc -w --namespace nginx-ingress nginx', then:

  export SERVICE_IP=$(kubectl get svc --namespace nginx-ingress nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

  Then make sure to configure DNS with something like:
    *.example.com       300 IN A $SERVICE_IP
```

* Должно пройти несколько минут. Найдите выданный IP-адрес ingress-контроллера nginx.
```
$ kubectl get service -n nginx-ingress nginx
NAME    TYPE           CLUSTER-IP   EXTERNAL-IP     PORT(S)                                   AGE
nginx   LoadBalancer   10.0.15.89   34.89.184.112   80:31301/TCP,443:32168/TCP,22:31498/TCP   3m7s
```

* Поместите запись в локальный файл /etc/hosts
```
echo "34.89.246.216 gitlab-gitlab staging production” >> /etc/hosts
```

* И получаем ШТАНГУ!!! 
```
$ kubectl get pods
NAME                                        READY   STATUS             RESTARTS   AGE
gitlab-gitlab-6dfb86cd67-9bw4s              0/1     Pending            0          18m
gitlab-gitlab-postgresql-66d5b899b8-wsv9c   0/1     Pending            0          18m
gitlab-gitlab-redis-6c675dd568-s24ls        1/1     Running            0          18m
gitlab-gitlab-runner-cb5c77568-8k5cm        0/1     CrashLoopBackOff   8          18m
```
Долгие копания в логах показывали ошибки сети и прочие непотребности. Учитывая статус пакета *DEPRICATED* - грусть и тоска. В конечном итоге выяснилось, что не хватает дисковой квоты SSD для разворачивания данного пакета. Уменьшение запросов в конфигурации компонентов приложения gitlab-omnibus и очистка непонятно каким образом оставшихся выделенных дисков SSD от предыдущих кластеров и попыток разворачивания приложения позволило запустить приложение в таком варианте.
```
$ kubectl get pods -n gitlab
NAME                                        READY   STATUS             RESTARTS   AGE
gitlab-gitlab-6dfb86cd67-w2tjf              1/1     Running            0          34m
gitlab-gitlab-postgresql-66d5b899b8-wqnkz   1/1     Running            0          34m
gitlab-gitlab-redis-6c675dd568-dk52s        1/1     Running            0          25m
gitlab-gitlab-runner-74d447979b-nwv5d       0/1     CrashLoopBackOff   8          25m
```
* Web-интерфейс при этом стал доступен, залогиниться и задать первоначальный пароль успешно удалось. Через какое-то время gitlab-runner запустился с 10 попытки.
```
$ kubectl get pods -n gitlab
NAME                                        READY   STATUS    RESTARTS   AGE
gitlab-gitlab-6dfb86cd67-9rbxz              1/1     Running   0          6m
gitlab-gitlab-postgresql-66d5b899b8-lm4wr   1/1     Running   0          6m
gitlab-gitlab-redis-6c675dd568-r8g85        1/1     Running   0          6m
gitlab-gitlab-runner-74d447979b-5ltvl       1/1     Running   5          6m
```

И так, gitlab поднялся, идем по адресу `http://gitlab-gitlab`, ставим пароль otusgitlab и логинимся под пользователем root.

Создадим группу, в качестве имени используем Docker ID. В настройках группы выберем пункт CI/CD, добавим 2 переменные:
 - *CI_REGISTRY_USER* - логин в dockerhub
 - *CI_REGISTRY_PASSWORD* - пароль от Docker Hub
Эти учетные данные будут использованы при сборке и релизе docker-образов с помощью Gitlab CI.
В группе создадим новый публичный проект с именем *reddit-deploy*.
Создадим еще 3 публичных проекта: post, ui, comment

Локально вне структуры нашего репозитория создадим директорию Gitlab_ci со следующей
структурой директорий. Перенесить не стал, скопировал исходные коды сервиса ui в Gitlab_ci/ui
```
.
├── comment
├── post
├── reddit-deploy
└── ui
    ├── build_info.txt
    ├── config.ru
    ├── docker_build.sh
    ├── Dockerfile
    ├── Gemfile
    ├── Gemfile.lock
    ├── helpers.rb
    ├── middleware.rb
    ├── ui_app.rb
    ├── VERSION
    └── views
        ├── create.haml
        ├── index.haml
        ├── layout.haml
        └── show.haml
```

* В директории Gitlab_ci/ui:
1. Инициализируем локальный git-репозиторий
```
$ git init
Initialized empty Git repository
```

2. Добавим удаленный репозиторий
```
$ git remote add origin http://gitlab-gitlab/mrshadow74/ui.git
```

3. Закоммитим и отправим в gitlab
```
$ git push origin master
Username for 'http://gitlab-gitlab': root
Password for 'http://root@gitlab-gitlab':
Counting objects: 17, done.
Delta compression using up to 2 threads.
Compressing objects: 100% (15/15), done.
Writing objects: 100% (17/17), 7.32 KiB | 576.00 KiB/s, done.
Total 17 (delta 1), reused 0 (delta 0)
To http://gitlab-gitlab/mrshadow74/ui.git
 * [new branch]      master -> master
```

Для post и comment продейлаем аналогичные действия.

1. Скопируем содержимое директории Charts (папки ui, post, comment, reddit) в Gitlab_ci/reddit-deploy
2. Запушить reddit-deploy в gitlab-проект reddit-deploy

Получилось так
```
.                                                                                                                                                              [36/1803]
├── comment
│   ├── build_info.txt
│   ├── comment_app.rb
│   ├── config.ru
│   ├── docker_build.sh
│   ├── Dockerfile
│   ├── Gemfile
│   ├── Gemfile.lock
│   ├── helpers.rb
│   └── VERSION
├── post
│   ├── build_info.txt
│   ├── docker_build.sh
│   ├── Dockerfile
│   ├── helpers.py
│   ├── post_app.py
│   ├── requirements.txt
│   └── VERSION
├── reddit-deploy
│   ├── comment
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   ├── deployment.yaml
│   │   │   ├── _helpers.tpl
│   │   │   └── service.yaml
│   │   └── values.yaml
│   ├── post
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   ├── deployment.yaml
│   │   │   ├── _helpers.tpl
│   │   │   └── service.yaml
│   │   └── values.yaml
│   ├── reddit
│   │   ├── charts
│   │   │   ├── comment-1.0.0.tgz
│   │   │   ├── mongodb-7.6.3.tgz
│   │   │   ├── post-1.0.0.tgz
│   │   │   └── ui-1.0.0.tgz
│   │   ├── Chart.yaml
│   │   ├── requirements.lock
│   │   ├── requirements.yaml
│   │   └── values.yaml
│   └── ui
│       ├── Chart.yaml
│       ├── templates
│       │   ├── deployment.yaml
│       │   ├── _helpers.tpl
│       │   ├── ingress.yaml
│       │   └── service.yaml
│       └── values.yaml
└── ui
    ├── build_info.txt
    ├── config.ru
    ├── docker_build.sh
    ├── Dockerfile
    ├── Gemfile
    ├── Gemfile.lock
    ├── helpers.rb
    ├── middleware.rb
    ├── ui_app.rb
    ├── VERSION
    └── views
        ├── create.haml
        ├── index.haml
        ├── layout.haml
        └── show.haml

13 directories, 54 files
```

### Настроим CI

1. Создадим файл gitlab_ci/ui/.gitlab-ci.yml
```
image: alpine:latest

stages:
  - build
  - test
  - release
  - cleanup

build:
  stage: build
  image: docker:git
  services:
    - docker:18.09.7-dind
  script:
    - setup_docker
    - build
  variables:
    DOCKER_DRIVER: overlay2
  only:
    - branches

test:
  stage: test
  script:
    - exit 0
  only:
    - branches

release:
  stage: release
  image: docker
  services:
    - docker:dind
  script:
    - setup_docker
    - release
  variables:
    DOCKER_TLS_CERTDIR: ""
  only:
    - master

.auto_devops: &auto_devops |
  [[ "$TRACE" ]] && set -x
  export CI_REGISTRY="index.docker.io"
  export CI_APPLICATION_REPOSITORY=$CI_REGISTRY/$CI_PROJECT_PATH
  export CI_APPLICATION_TAG=$CI_COMMIT_REF_SLUG
  export CI_CONTAINER_NAME=ci_job_build_${CI_JOB_ID}
  export TILLER_NAMESPACE="kube-system"

  function setup_docker() {
    if ! docker info &>/dev/null; then
      if [ -z "$DOCKER_HOST" -a "$KUBERNETES_PORT" ]; then
        export DOCKER_HOST='tcp://localhost:2375'
      fi
    fi
  }

  function release() {

    echo "Updating docker images ..."

    if [[ -n "$CI_REGISTRY_USER" ]]; then
      echo "Logging to GitLab Container Registry with CI credentials..."
      docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      echo ""
    fi

    docker pull "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    docker tag "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    docker push "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    echo ""
  }

  function build() {

    echo "Building Dockerfile-based application..."
    echo `git show --format="%h" HEAD | head -1` > build_info.txt
    echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt
    docker build -t "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" .

    if [[ -n "$CI_REGISTRY_USER" ]]; then
      echo "Logging to GitLab Container Registry with CI credentials..."
      docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      echo ""
    fi

    echo "Pushing to GitLab Container Registry..."
    docker push "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    echo ""
  }

before_script:
  - *auto_devops
```

2. Закомитим и запушим в gitlab
3. Проверим, что Pipeline работает - работает.

В текущей конфигурации CI выполняет
1. Build: Сборку докер-образа с тегом master
2. Test: Фиктивное тестирование
3. Release: Смену тега с master на тег из файла VERSION и пуш docker-образа с новым тегом
Job для выполнения каждой задачи запускается в отдельном Kubernetes POD-е.


Требуемые операции вызываются в блоках script:
```
script:
- setup_docker
- build
```

Описание самих операций производится в виде bash-функций в блоке .auto_devops
```
.auto_devops: &auto_devops |
function setup_docker() {
…
}
function release() {
…
}
function build() {
…
}
```

* Для Post и Comment также добавим в репозиторий .gitlabci.yml и проследим, что сборки образов прошли успешно.

* Дадим возможность разработчику запускать отдельное окружение в Kubernetes по коммиту в feature-бранч. Немного обновим конфиг ингресса для сервиса UI
```
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ template "ui.fullname" . }}
  annotations:
    kubernetes.io/ingress.class: {{ .Values.ingress.class }}
spec:
  rules:
  - host: {{ .Values.ingress.host | default .Release.Name }}
    http:
      paths:
      - path: /*
        backend:
          serviceName: {{ template "ui.fullname" . }}
          servicePort: {{ .Values.service.externalPort }}
```

* Обновим конфиг ингресса для сервиса UI
Зачем - не ясно, все уже сделано ранее.

* Дадим возможность разработчику запускать отдельное окружение в Kubernetes по коммиту в feature-бранч.

1. Создайте новый бранч в репозитории ui
```
$ git checkout -b feature/3
Switched to a new branch 'feature/3'
```
2. Обновим `ui/.gitlab-ci.yml`
```
---
image: alpine:latest

stages:
  - build
  - test
  - review
  - release

build:
  stage: build
  image: docker:git
  services:
    - docker:18.09.7-dind
  script:
    - setup_docker
    - build
  variables:
    DOCKER_DRIVER: overlay2
  only:
    - branches

test:
  stage: test
  script:
    - exit 0
  only:
    - branches

release:
  stage: release
  image: docker
  services:
    - docker:18.09.7-dind
  script:
    - setup_docker
    - release
  only:
    - master

review:
  stage: review
  script:
    - install_dependencies
    - ensure_namespace
    - install_tiller
    - deploy
  variables:
    KUBE_NAMESPACE: review
    host: $CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    url: http://$CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
    on_stop: stop_review
  only:
    refs:
      - branches
    kubernetes: active
  except:
    - master

.auto_devops: &auto_devops |
  [[ "$TRACE" ]] && set -x
  export CI_REGISTRY="index.docker.io"
  export CI_APPLICATION_REPOSITORY=$CI_REGISTRY/$CI_PROJECT_PATH
  export CI_APPLICATION_TAG=$CI_COMMIT_REF_SLUG
  export CI_CONTAINER_NAME=ci_job_build_${CI_JOB_ID}
  export TILLER_NAMESPACE="kube-system"

  function deploy() {
    track="${1-stable}"
    name="$CI_ENVIRONMENT_SLUG"

    if [[ "$track" != "stable" ]]; then
      name="$name-$track"
    fi

    echo "Clone deploy repository..."
    git clone http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/reddit-deploy.git

    echo "Download helm dependencies..."
    helm dep update reddit-deploy/reddit

    echo "Deploy helm release $name to $KUBE_NAMESPACE"
    helm upgrade --install \
      --wait \
      --set ui.ingress.host="$host" \
      --set $CI_PROJECT_NAME.image.tag=$CI_APPLICATION_TAG \
      --namespace="$KUBE_NAMESPACE" \
      --version="$CI_PIPELINE_ID-$CI_JOB_ID" \
      "$name" \
      reddit-deploy/reddit/
  }

  function install_dependencies() {

    apk add -U openssl curl tar gzip bash ca-certificates git
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk
    apk add glibc-2.23-r3.apk
    rm glibc-2.23-r3.apk

    curl https://storage.googleapis.com/pub/gsutil.tar.gz | tar -xz -C $HOME
    export PATH=${PATH}:$HOME/gsutil

    curl https://kubernetes-helm.storage.googleapis.com/helm-v2.13.1-linux-amd64.tar.gz | tar zx

    mv linux-amd64/helm /usr/bin/
    helm version --client

    curl  -o /usr/bin/sync-repo.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/sync-repo.sh
    chmod a+x /usr/bin/sync-repo.sh

    curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x /usr/bin/kubectl
    kubectl version --client
  }

  function setup_docker() {
    if ! docker info &>/dev/null; then
      if [ -z "$DOCKER_HOST" -a "$KUBERNETES_PORT" ]; then
        export DOCKER_HOST='tcp://localhost:2375'
      fi
    fi
  }

  function ensure_namespace() {
    kubectl describe namespace "$KUBE_NAMESPACE" || kubectl create namespace "$KUBE_NAMESPACE"
  }

  function release() {

    echo "Updating docker images ..."

    if [[ -n "$CI_REGISTRY_USER" ]]; then
      echo "Logging to GitLab Container Registry with CI credentials..."
      docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      echo ""
    fi

    docker pull "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    docker tag "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    docker push "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    echo ""
  }

  function build() {

    echo "Building Dockerfile-based application..."
    echo `git show --format="%h" HEAD | head -1` > build_info.txt
    echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt
    docker build -t "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" .

    if [[ -n "$CI_REGISTRY_USER" ]]; then
      echo "Logging to GitLab Container Registry with CI credentials..."
      docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      echo ""
    fi

    echo "Pushing to GitLab Container Registry..."
    docker push "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    echo ""
  }

  function install_tiller() {
    echo "Checking Tiller..."
    helm init --upgrade
    kubectl rollout status -n "$TILLER_NAMESPACE" -w "deployment/tiller-deploy"
    if ! helm version --debug; then
      echo "Failed to init Tiller."
      return 1
    fi
    echo ""
  }

before_script:
  - *auto_devops
...
```

3. Закоммитим и запушим изменения
```
$ git commit -am "Add review feature"
$ git push origin feature/3
```

В коммитах ветки feature/3 можете найти сделанные изменения. Отметим, что мы добавили стадию review, запускающую приложение в k8s по коммиту в feature-бранчи (не master).
```
review:
stage: review
script:
- install_dependencies
- ensure_namespace
- install_tiller
- deploy
variables:
KUBE_NAMESPACE: review
host: $CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
environment:
name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
url: http://$CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
only:
refs:
- branches
kubernetes: active
except:
- master
```

Мы также добавили функцию deploy, которая загружает Chart из репозитория reddit-deploy и делает релиз в неймспейсе review с образом приложения, собранным на стадии build.

```
function deploy() {
…
git clone http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/reddit-deploy.git
echo "Download helm dependencies..."
helm dep update reddit-deploy/reddit
echo "Deploy helm release $name to $KUBE_NAMESPACE"
helm upgrade --install \
--wait \
--set ui.ingress.host="$host" \
--set $CI_PROJECT_NAME.image.tag=$CI_APPLICATION_TAG \
--namespace="$KUBE_NAMESPACE" \
--version="$CI_PIPELINE_ID-$CI_JOB_ID" \
"$name" \
reddit-deploy/reddit/
}
```

* Можем увидеть какие релизы запущены `helm ls`

Созданные для таких целей окружения временны, их требуется “убивать”, когда они больше не нужны.

Добавим в `ui/.gitlab-ci.yml`
```
stop_review:
stage: cleanup
variables:
GIT_STRATEGY: none
script:
- install_dependencies
- delete
environment:
name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
action: stop
when: manual
allow_failure: true
only:
refs:
- branches
kubernetes: active
except:
- master

stages:
- build
- test
- review
- release
- cleanup
review:
stage: review
…
environment:
name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
url: http://$CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
on_stop: stop_review
…

.auto_devops: &auto_devops |
…
function delete() {
track="${1-stable}"
name="$CI_ENVIRONMENT_SLUG"
helm delete "$name" --purge || true
}
```

1. Запушим изменения в Git
2. Зайдем в Pipelines ветки feature/3

В Environments можем получить ссылку на сбилженное приложение. Только ссылка ведет на gitlab, а приложение запускается на собственном ингрессе. И либо результат не пробрасывается на стороне nginx gitlab-а, либо просто данный функционал нифига не работает.

* !!! А на самом деле всё открывается, если обращатсья не на ip gitlab-a, а на ip-адреса ингрессов приложений.

Скопируем полученный файл `.gitlab-ci.yml` для ui в репозитории для post и comment. Проверим, что динамическое создание и удаление окружений работает с ними как ожидалось - работают успешно.

### Деплоим

Теперь создадим staging и production среды для работы приложения. Создадим файл `reddit-deploy/.gitlab-ci.yml`, запушим в репозиторий `reddit-deploy` ветку master. Этот файл отличается от предыдущих тем, что:
1. Не собирает docker-образы
2. Деплоит на статичные окружения (staging и production)
3. Не удаляет окружения

```
image: alpine:latest

stages:
  - test
  - staging
  - production

test:
  stage: test
  script:
    - exit 0
  only:
    - triggers
    - branches

staging:
  stage: staging
  script:
  - install_dependencies
  - ensure_namespace
  - install_tiller
  - deploy
  variables:
    KUBE_NAMESPACE: staging
  environment:
    name: staging
    url: http://staging
  only:
    refs:
      - master
    kubernetes: active

production:
  stage: production
  script:
    - install_dependencies
    - ensure_namespace
    - install_tiller
    - deploy
  variables:
    KUBE_NAMESPACE: production
  environment:
    name: production
    url: http://production
  when: manual
  only:
    refs:
      - master
    kubernetes: active

.auto_devops: &auto_devops |
  # Auto DevOps variables and functions
  [[ "$TRACE" ]] && set -x
  export CI_REGISTRY="index.docker.io"
  export CI_APPLICATION_REPOSITORY=$CI_REGISTRY/$CI_PROJECT_PATH
  export CI_APPLICATION_TAG=$CI_COMMIT_REF_SLUG
  export CI_CONTAINER_NAME=ci_job_build_${CI_JOB_ID}
  export TILLER_NAMESPACE="kube-system"

  function deploy() {
    echo $KUBE_NAMESPACE
    track="${1-stable}"
    name="$CI_ENVIRONMENT_SLUG"
    helm dep build reddit

    # for microservice in $(helm dep ls | grep "file://" | awk '{print $1}') ; do
    #   SET_VERSION="$SET_VERSION \ --set $microservice.image.tag='$(curl http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/ui/raw/master/VERSION)' "

    helm upgrade --install \
      --wait \
      --set ui.ingress.host="$host" \
      --set ui.image.tag="$(curl http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/ui/raw/master/VERSION)" \
      --set post.image.tag="$(curl http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/post/raw/master/VERSION)" \
      --set comment.image.tag="$(curl http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/comment/raw/master/VERSION)" \
      --namespace="$KUBE_NAMESPACE" \
      --version="$CI_PIPELINE_ID-$CI_JOB_ID" \
      "$name" \
      reddit
  }

  function install_dependencies() {

    apk add -U openssl curl tar gzip bash ca-certificates git
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk
    apk add glibc-2.23-r3.apk
    rm glibc-2.23-r3.apk

    curl https://kubernetes-helm.storage.googleapis.com/helm-v2.13.1-linux-amd64.tar.gz | tar zx

    mv linux-amd64/helm /usr/bin/
    helm version --client

    curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x /usr/bin/kubectl
    kubectl version --client
  }

  function ensure_namespace() {
    kubectl describe namespace "$KUBE_NAMESPACE" || kubectl create namespace "$KUBE_NAMESPACE"
  }

  function install_tiller() {
    echo "Checking Tiller..."
    helm init --upgrade
    kubectl rollout status -n "$TILLER_NAMESPACE" -w "deployment/tiller-deploy"
    if ! helm version --debug; then
      echo "Failed to init Tiller."
      return 1
    fi
    echo ""
  }

  function delete() {
    track="${1-stable}"
    name="$CI_ENVIRONMENT_SLUG"
    helm delete "$name" || true
  }

before_script:
  - *auto_devops
```

* Staging успешно завершен

### Пайплайн здорового человека

* Сейчас почти вся логика пайплайна заключена в auto_devops и трудночитаема. Давайте переделаем имеющийся для ui пайплайн так, чтобы он соответствовал синтаксису Gitlab. Тонкости синтаксиса:
1. Объявление переменных можно перенести в variables
2. conditional statements можно записать так:
```
if [[ "$track" != "stable" ]]; then
name="$name-$track"
fi
```

А разносить строку на несколько так:
```
helm upgrade --install \
--wait \
--set ui.ingress.host="$host"
```

Как видим, читаемость кода значительно возросла.

* Задание
1. Изменить пайплайн сервиса COMMENT, использующих для деплоя helm2 таким образом, чтобы деплой осуществлялся с использованием . Таким образом, деплой каждого пайплайна из трех сервисов должен производиться по-разному.
2. Изменить пайплайн сервиса POST, чтобы он использовал helm3 для деплоя.

* Полученные файлы пайплайнов для сервисов (4 штуки: ui, post, comment, reddit) положить в директорию Charts/gitlabci под именами .gitlab-ci.yml и закоммитить.
Большой философский вопрос: почему четыре, когда проверка ищет только три, и почему по такому пути, когда проверка ищет совсем в другом месте???

* Файл `.gitlab-ci.yml` сервиса *comment*
```
...
function install_dependencies() {
...
helm init --client-only
    helm plugin install https://github.com/rimusz/helm-tiller
...
function deploy() {
...
echo "Deploy helm release $name to $KUBE_NAMESPACE"
    helm tiller run \
    helm upgrade --install \
      --wait \
      --set ui.ingress.host="$host" \
      --set $CI_PROJECT_NAME.image.tag=$CI_APPLICATION_TAG \
      --namespace="$KUBE_NAMESPACE" \
      --version="$CI_PIPELINE_ID-$CI_JOB_ID" \
      "$name" \
      reddit-deploy/reddit/
  }
...
function install_tiller() {
    echo "Checking Tiller..."
    #helm init --upgrade
    helm init --client-only
    kubectl rollout status -n "$TILLER_NAMESPACE" -w "deployment/tiller-deploy"
    if ! helm version --debug; then
      echo "Failed to init Tiller."
      return 1
    fi
    echo ""
  }
```

* Файл `.gitlab-ci.yml` сервиса *post*
```
...
function install_dependencies() {
    #curl https://kubernetes-helm.storage.googleapis.com/helm-v2.13.1-linux-amd64.tar.gz | tar zx
    curl https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz | tar zx
...
```

## Задание со *
* Сейчас у нас выкатка на staging и production - по нажатию кнопки. Свяжите пайплайны сборки образов и пайплайн деплоя на staging и production так, чтобы после релиза образа из ветки мастер запускался деплой уже новой версии приложения на production

* Решение: заменить параметр when со значения manual на on_success
```
production:
  stage: production
  script:
    - install_dependencies
    - ensure_namespace
    - install_tiller
    - deploy
  variables:
    KUBE_NAMESPACE: production
  environment:
    name: production
    url: http://production
  when: on_success
  only:
    refs:
      - master
    kubernetes: active
```

* Выковыривание auto_devops уже не стал расписывать, грабли замучали. Сделать можно собиранием содержимого всех функций в 2 группы скриптов, выполняемых до начала деплоя и после его окончания.

* Файл `.gitlab-ci.yml` проекта reddit-deploy помещен в каталог `kubernetes/Charts`

# Kubernetes. Мониторинг и логирование

У вас должен быть развернуть кластер k8s:
 - минимум 2 ноды g1-small (1,5 ГБ)
 - минимум 1 нода n1-standard-2 (7,5 ГБ)

В настройках:
 - Stackdriver Logging - Отключен
 - Stackdriver Monitoring - Отключен
 - Устаревшие права доступа - Включено

Из Helm-чарта установим ingress-контроллер nginx
```
$ kubectl apply -f tiller.yml
serviceaccount/tiller created
clusterrolebinding.rbac.authorization.k8s.io/tiller created

$ helm init --service-account tiller
$HELM_HOME has been configured

$ helm install stable/nginx-ingress --name nginx                                                 [54/1816]
NAME:   nginx
LAST DEPLOYED: Mon Jan 13 13:36:57 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ClusterRole
NAME                 AGE
nginx-nginx-ingress  1s

==> v1/ClusterRoleBinding
NAME                 AGE
nginx-nginx-ingress  1s

==> v1/Deployment
NAME                                 AGE
nginx-nginx-ingress-controller       1s
nginx-nginx-ingress-default-backend  1s

==> v1/Pod(related)
NAME                                                  AGE
nginx-nginx-ingress-controller-787986ff47-zz9fq       1s
nginx-nginx-ingress-default-backend-766d57499b-5x9nq  1s

==> v1/Role
NAME                 AGE
nginx-nginx-ingress  1s

==> v1/RoleBinding                                                                                                                                             [25/1816]
NAME                 AGE
nginx-nginx-ingress  1s

==> v1/Service
NAME                                 AGE
nginx-nginx-ingress-controller       1s
nginx-nginx-ingress-default-backend  1s

==> v1/ServiceAccount
NAME                         AGE
nginx-nginx-ingress          1s
nginx-nginx-ingress-backend  1s


NOTES:
The nginx-ingress controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace default get services -o wide -w nginx-nginx-ingress-controller'

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
```

Найдем IP-адрес, выданный nginx’у
```
$ kubectl get svc
NAME                                  TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)                      AGE
kubernetes                            ClusterIP      10.0.0.1      <none>           443/TCP                      21m
nginx-nginx-ingress-controller        LoadBalancer   10.0.7.11     35.246.227.226   80:30413/TCP,443:30064/TCP   3m9s
nginx-nginx-ingress-default-backend   ClusterIP      10.0.11.237   <none>           80/TCP                       3m9s
```

Добавим в /etc/hosts
```
35.246.227.226 reddit reddit-prometheus reddit-grafana reddit-non-prod production redditkibana staging prod
```

* План
Развертывание Prometheus в k8s.
Настройка Prometheus и Grafana для сбора метрик.
Настройка EFK для сбора логов.

## Мониторинг

* Стек
В задании будем использовать уже знакомые нам инструменты:
 - prometheus - сервер сбора метрик
 - grafana - сервер визуализации метрик
 - alertmanager - компонент prometheus для алертинга различные экспортеры для метрик prometheus.
Prometheus отлично подходит для работы с контейнерами и динамичным размещением сервисов.

### Установим Prometheus
Prometheus будем ставить с помощью Helm чарта. Загрузим prometheus локально в Charts каталог
```
$ cd kubernetes/Charts && helm fetch --untar stable/prometheus
```

* Создадим внутри директории чарта файл `custom_values.yml` из гиста `https://gist.githubusercontent.com/chromko/2bd290f7becdf707cde836ba1ea6ec5c/raw/c17372866867607cf4a0445eb519f9c2c377a0ba/gistfile1.txt`

Основные отличия от values.yml:
 - отключена часть устанавливаемых сервисов (pushgateway, alertmanager, kube-state-metrics)
 - включено создание Ingress’а для подключения через nginx
 - поправлен endpoint для сбора метрик cadvisor
 - уменьшен интервал сбора метрик (с 1 минуты до 30 секунд)

* Запустим Prometheus в k8s из charsts/prometheus
```
s$ helm upgrade prom . -f custom_values.yml --install                                  [26/1801]
Release "prom" does not exist. Installing it now.
NAME:   prom
LAST DEPLOYED: Mon Jan 13 14:15:06 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                    AGE
prom-prometheus-server  2s

==> v1/Deployment
NAME                    AGE
prom-prometheus-server  2s

==> v1/PersistentVolumeClaim
NAME                    AGE
prom-prometheus-server  2s

==> v1/Pod(related)
NAME                                   AGE
prom-prometheus-server-bdc8df4b-sdl6k  2s

==> v1/Service
NAME                    AGE
prom-prometheus-server  2s

==> v1/ServiceAccount
NAME                    AGE
prom-prometheus-server  2s

==> v1beta1/Ingress
NAME                    AGE
prom-prometheus-server  2s

NOTES:
The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prom-prometheus-server.default.svc.cluster.local

From outside the cluster, the server URL(s) are:
http://reddit-prometheus

#################################################################################
######   WARNING: Pod Security Policy has been moved to a global property.  #####
######            use .Values.podSecurityPolicy.enabled with pod-based      #####
######            annotations                                               #####
######            (e.g. .Values.nodeExporter.podSecurityPolicy.annotations) #####
#################################################################################

For more information on running Prometheus, visit:
https://prometheus.io/
```

### Targets

В статусах таргетов у нас уже присутствует ряд endpoint’ов для сбора метрик:
 - сам prometheus
 - Метрики API-сервера
 - метрики нод с cadvisor’ов

* Отметим, что можно собирать метрики cadvisor’а (который уже является частью kubelet) через проксирующий запрос в kube-apiserver. Если зайти по ssh на любую из машин кластера и запросить `$ curl http://localhost:4194/metrics`, то мы получим те же метрики у kubelet напрямую. Но вариант с kube-api предпочтительней, т.к. этот трафик
шифруется TLS и требует аутентификации.

* Таргеты для сбора метрик найдены с помощью *service discovery (SD)*, настроенного в конфиге prometheus *custom-values.yml*.
```
prometheus.yml:
...
  - job_name: 'kubernetes-apiservers' # kubernetes-apiservers (1/1 up)
...
  - job_name: 'kubernetes-nodes' # kubernetes-nodes (3/3 up)
      kubernetes_sd_configs: # Настройки Service Discovery (для поиска target’ов)
        - role: node
      scheme: https # Настройки подключения к target’ам (для сбора метрик)
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        insecure_skip_verify: true
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      relabel_configs: # Настройки различных меток, фильтрация найденных таргетов, их изменений
```

Использование SD в kubernetes позволяет нам динамично менять кластер (как сами хосты, так и сервисы и приложения). Цели для мониторинга находим c помощью запросов к k8s API:
```
prometheus.yml:
...
    scrape_configs:
      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
          - role: node # Role объект, который нужно найти:
# - node
# - endpoints
# - pod
# - service
# - ingress

prometheus.yml:
...
    scrape_configs:
    - job_name: 'kubernetes-nodes'
      kubernetes_sd_configs:
      - role: node
```

Т.к. сбор метрик prometheus осуществляется поверх стандартного HTTP-протокола, то могут понадобится доп. настройки для безопасного доступа к метрикам. Ниже приведены настройки для сбора метрик из k8s AP
```
scheme: https
tls_config:
  ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  insecure_skip_verify: true
bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
```

1. Схема подключения - http (default) или https
2. Конфиг TLS - корневой сертификат сервера для проверки достоверности сервера
3. Токен для аутентификации на сервере

Targets:
```
$ kubectl get nodes
NAME                                        STATUS   ROLES    AGE   VERSION
gke-kuber-gke-g1-small-9c85d19b-0p28        Ready    <none>   88m   v1.15.4-gke.22
gke-kuber-gke-g1-small-9c85d19b-ppz0        Ready    <none>   88m   v1.15.4-gke.22
gke-kuber-gke-n1-standard-2-fadc5ba8-zzff   Ready    <none>   88m   v1.15.4-gke.22
```

Подробнее о том, как работает *relabel_config* `https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config`
```
#Kubernetes nodes
relabel_configs:
- action: labelmap # преобразовать все k8s лейблы таргета в лейблы prometheus
  regex: __meta_kubernetes_node_label_(.+)
- target_label: __address__ # Поменять лейбл для адреса сбора метрик
  replacement: kubernetes.default.svc:443
- source_labels: [__meta_kubernetes_node_name] # Поменять лейбл для пути сбора метрик
  regex: (.+)
  target_label: __metrics_path__
  replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor
```

* В результате получим лейблы в prometheus.

### Metrics

* Все найденные на эндпоинтах метрики сразу же отобразятся в списке (вкладка Graph). Метрики Cadvisor начинаются с *container_*.

* Cadvisor собирает лишь информацию о потреблении ресурсов и производительности отдельных docker-контейнеров. При этом он ничего не знает о сущностях k8s (деплойменты, репликасеты, ...). Для сбора этой информации будем использовать сервис *kubestate-metrics*. Он входит в чарт Prometheus. Включим его.
```

##prometheus/custom_values.yml
...
kubeStateMetrics:
  ## If false, kube-state-metrics will not be installed
  ##
  enabled: true
```

И обновим релиз
```
$ helm upgrade prom . -f custom_values.yml --install
Release "prom" has been upgraded.
LAST DEPLOYED: Mon Jan 13 15:51:19 2020
NAMESPACE: default
STATUS: DEPLOYED
```

* В Таргетсах видим запланированные изменения, в Графах видим добавившиеся метрики *kube_deployment_*.

* По аналогии с *kube_state_metrics* включим поды `node-exporter` в `custom_values.yml`.
```
nodeExporter:
  ## If false, node-exporter will not be installed
  ##
  enabled: true
```
И применим изменения 
```
$ helm upgrade prom . -f custom_values.yml --install
Release "prom" has been upgraded.
LAST DEPLOYED: Mon Jan 13 19:49:26 2020
NAMESPACE: default
STATUS: DEPLOYED
```

Проверим, что метрики начали собираться с них - добавились метрики `kube_node_` с данными.












