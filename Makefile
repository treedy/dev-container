MOUNT_PT = /mounted_homedir/${USER}
VOLUMES = -v ${HOME}:$(MOUNT_PT)
UID := $(shell id -u)

NS ?= ${USER}
VERSION ?= latest

IMAGE_NAME ?= devshell
CONTAINER_NAME ?= ${USER}-$(IMAGE_NAME)-$$$$

REPO_SERVER ?= gcr.io
REPO_PROJECT ?= chore-bot-demo

RUN_IMAGE ?= $(NS)/$(IMAGE_NAME):$(VERSION)

.PHONY: build push run start compile_ycm build_clean

build: Dockerfile ## Build the container based on Dockerfile
	docker build -t $(RUN_IMAGE) .

push: ## Push the image to the container registry
	# EG: docker tag treedydev:latest gcr.io/chore-bot-demo/devshell
	docker tag  $(NS)/$(IMAGE_NAME):$(VERSION) \
		$(REPO_SERVER)/$(REPO_PROJECT)/$(IMAGE_NAME)
	docker push $(REPO_SERVER)/$(REPO_PROJECT)/$(IMAGE_NAME)

run: ## Run the container (starts a shell)
	docker volume create home >/dev/null 2>&1
	docker run -it --rm --name $(CONTAINER_NAME) \
		-v home:/home $(VOLUMES) $(ENV) \
		--hostname=$(IMAGE_NAME) $(RUN_IMAGE) ${USER} $(UID)

start: ## Start the container. Will not detele when stopped
	docker volume create home >/dev/null 2>&1
	docker run -it --name $(CONTAINER_NAME) \
		-v home:/home $(VOLUMES) $(ENV) \
		--hostname=$(IMAGE_NAME) $(RUN_IMAGE) ${USER} $(UID)

build_clean: Dockerfile ## Build the container based on Dockerfile without cache
	docker build --no-cache -t $(NS)/$(IMAGE_NAME):$(VERSION) .

backup: ## Backup the home directory of the current user
	docker run --rm --name $(CONTAINER_NAME) \
		-v home:/home $(VOLUMES) $(ENV) \
		--entrypoint=/opt/devshell/home-dir-dr.sh \
		--hostname=$(IMAGE_NAME) $(RUN_IMAGE) \
		backup ${USER} $(MOUNT_PT)/${USER}-backup.bz2

restore: ## Restore the home directory of the current user
	docker volume create home >/dev/null 2>&1
	docker run --rm --name $(CONTAINER_NAME) \
		-v home:/home $(VOLUMES) $(ENV) \
		--entrypoint=/opt/devshell/home-dir-dr.sh \
		--hostname=$(IMAGE_NAME) $(RUN_IMAGE) \
		restore ${USER} $(MOUNT_PT)/${USER}-backup.bz2

default: build

# vim: ts=4
