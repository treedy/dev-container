ENV_FILE ?= make.env
include $(ENV_FILE)

NS ?= treedy
VERSION ?= latest

IMAGE_NAME ?= devshell
CONTAINER_NAME ?= ${USER}-$(IMAGE_NAME)-$$$$

REPO_SERVER ?= gcr.io
REPO_PROJECT ?= chore-bot-demo
USER_SHELL ?= zsh -l

RUN_IMAGE ?= $(NS)/$(IMAGE_NAME):$(VERSION)

.PHONY: build push run start compile_ycm build_clean

build: Dockerfile ## Build the container based on Dockerfile
	docker build -t $(NS)/$(IMAGE_NAME):$(VERSION) .

push: ## Push the image to the container registry
	# EG: docker tag treedydev:latest gcr.io/chore-bot-demo/devshell
	docker tag  $(NS)/$(IMAGE_NAME):$(VERSION) \
		$(REPO_SERVER)/$(REPO_PROJECT)/$(IMAGE_NAME)
	docker push $(REPO_SERVER)/$(REPO_PROJECT)/$(IMAGE_NAME)

run: ## Run the container (starts a shell)
	docker run -it --rm --name $(CONTAINER_NAME) \
		$(PORTS) $(VOLUMES) $(ENV) \
		$(RUN_IMAGE) ${USER} $(UID)

start: ## Start the container. Will not detele when stopped
	docker run -it --name $(CONTAINER_NAME) \
		$(PORTS) $(VOLUMES) $(ENV) \
		$(RUN_IMAGE) ${USER} $(UID)

build_clean: Dockerfile ## Build the container based on Dockerfile without cache
	docker build --no-cache -t $(NS)/$(IMAGE_NAME):$(VERSION) .

default: build

# vim: ts=4
