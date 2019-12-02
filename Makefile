USERNAME = mrshadow74

# Сборка всех образов
build_all:
	build_prometheus \
	build_comment \
	build_post-py \
	build_ui

# Сборка образа prometheus
build_prometheus:
	cd monitoring/prometheus && docker build -t $(USERNAME)/prometheus .

# Сборка образа comment
build_comment:
	export USER_NAME=$(USERNAME) && cd src/comment && bash docker_build.sh

# Сборка образа post
build_post-py:
	export USER_NAME=$(USERNAME) && cd src/post-py && bash docker_build.sh

# Сборка образа ui
build_ui:
	export USER_NAME=$(USERNAME) && cd src/ui && bash docker_build.sh

# Публикация образа в DockerHub
push_all:
	login_dh \
	push_prometheus \
	push_comment \
	push_post_py \
	push_ui

login_dh:
	docker login

push_prometheus: build_prometheus
	docker push $(USERNAME)/prometheus:latest

push_comment: build_comment
	docker push $(USERNAME)/comment:latest

push_post_py: build_post-py
	docker push $(USERNAME)/post:latest

push_ui: build_ui
	docker push $(USERNAME)/ui:latest
