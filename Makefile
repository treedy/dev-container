include make.env

NS ?= treedy
VERSION ?= latest

IMAGE_NAME ?= devshell
CONTAINER_NAME ?= ${USER}-$(IMAGE_NAME)

REPO_SERVER ?= gcr.io
REPO_PROJECT ?= chore-bot-demo

.PHONY: build push run start stop rm release

build: Dockerfile ## Build the container based on Dockerfile
	docker build -t $(NS)/$(IMAGE_NAME):$(VERSION) .

push: ## Push the image to the container registry
	# EG: docker tag treedydev:latest gcr.io/chore-bot-demo/devshell
	docker tag  $(NS)/$(IMAGE_NAME):$(VERSION) \
	  $(REPO_SERVER)/$(REPO_PROJECT)/$(IMAGE_NAME)
	docker push $(REPO_SERVER)/$(REPO_PROJECT)/$(IMAGE_NAME)

run: ## Run the container (starts a shell)
	docker run -it --rm --name $(CONTAINER_NAME) \
	  $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)

start: ## Start the container. Will not detele when stopped
	docker run -it --name $(CONTAINER_NAME) \
	  $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)

compile_ycm:
	docker run --rm --name $(CONTAINER_NAME) \
	  $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION) \
	  /bin/bash -c "cd ~/.vim/bundle/YouCompleteMe && \
	  ./install.py --go-completer --clang-completer --java-completer"

build_clean: Dockerfile ## Build the container based on Dockerfile without cache
	docker build --no-cache -t $(NS)/$(IMAGE_NAME):$(VERSION) .

default: build
