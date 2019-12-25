USERNAME = mrshadow74
USER_NAME = mrshadow74
GOOGLE_PROJECT=global-incline-258416

# Создание инстанса
gcp_deploy:
	docker-machine create --driver google \
	--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
	--google-machine-type n1-standard-1 \
	--google-open-port 9292/tcp \
	--google-open-port 5601/tcp \
	--google-open-port 9411/tcp \
	--google-zone europe-west1-b \
	logging 
	eval '$(docker-machine env logging)'

# Запуск всего мониторинга
run-all:
	run-app
	run-monitor

# Остановка всего мониторинга
stop-all:
	stop-app
	stop-monitor

# Запуск приложений
run-app:
	cd docker && docker-compose up -d

# Запуск логгирования
run-logging:
	cd docker && docker-compose -f docker-compose-logging.yml up -d

# Запуск мониторинга 
run-monitor:
	cd docker && docker-compose -f docker-compose-monitoring.yml up -d

# Остановка приложений
stop-app:
	cd docker && docker-compose down

# Остановка мониторинга
stop-monitor:
	cd docker && docker-compose -f docker-compose-monitoring.yml down

#Остановка логгирования
stop-logging:
	cd docker && docker-compose -f docker-compose-logging.yml down

# Сборка всех образов monitoring
build_all_monitoring:
	build_prometheus \
	build_comment \
	build_post-py \
	build_ui

# Сборка всех образов logging
build_all_logging:
	build_comment \
	build_post-py \
	build_ui \
	build_fluentd

# Сборка образа prometheus
build_prometheus:
	cd monitoring/prometheus && docker build -t $(USERNAME)/prometheus .

# Сборка образа comment
build_comment:
	cd src/comment && bash docker_build.sh

# Сборка образа post
build_post-py:
	cd src/post-py && bash docker_build.sh

# Сборка образа ui
build_ui:
	cd src/ui && bash docker_build.sh

# Сборка образа grafana
build_grafana:
	cd monitoring/grafana && docker build -t ${USERNAME}/grafana .

# Сборка образа altermanager
build_alertmanager:
	cd monitoring/alertmanager && docker build -t ${USERNAME}/alertmanager .

# Сборка образа telegraf
build_telegraf:
	cd monitoring/telegraf && docker build -t ${USERNAME}/telegraf .

# Сборка образа fluentd
build_fluentd:
	cd logging/fluentd && docker build -t ${USERNAME}/fluentd .
         
# Публикация образа в DockerHub
push_all_monitoring:
	login_dh \
	push_l_prometheus \
	push_l_comment \
	push_l_post_py \
	push_l_ui

# Публикация образов в DockerHub
push_all_logging:
	login_dh \
	push_comment \
	push_post_py \
	push_ui

# Авторизация на DockerHub
login_dh:
	docker login

push_l_prometheus:
	docker push $(USERNAME)/prometheus:latest

push_l_comment:
	docker push $(USERNAME)/comment:latest

push_l_post_py:
	docker push $(USERNAME)/post:latest

push_l_ui:
	docker push $(USERNAME)/ui:latest

push_grafana:
	docker push ${USER_NAME}/grafana

push_alertmanager:
	docker push ${USER_NAME}/alertmanager

push_telegraf:
	docker push ${USER_NAME}/telegraf

push_comment:
	docker push $(USERNAME)/comment

push_post_py:
	docker push $(USERNAME)/post

push_ui:
	docker push $(USERNAME)/ui

push_fluentd:
	docker push $(USERNAME)/fluentd

