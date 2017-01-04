NAME := $(shell basename `pwd`)
PWD := $(shell pwd)

# Image name and version
IMAGE := damiang/ionic2:latest

.PHONY: help start enter build run ionic delete purge
.SILENT:

## This help screen
help:
	printf "Commands:\n"
	awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  %-15s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## Start container
start:
	docker run --name $(NAME) -ti --rm --net host --privileged -v /dev/bus/usb:/dev/bus/usb -v $(PWD)/.gradle:/root/.gradle -p 8100:8100 -p 35729:35729 -v $(PWD):/app:rw $(IMAGE)

## Enter running container
enter:
	printf "To exit container press: Ctrl + P then Ctrl + Q\n"
	docker exec -ti $(NAME) /bin/bash

## Upload an app to your Ionic account
upload:
	make ionic cmd=upload

## Build (prepare + compile) an Ionic project for a android platform
build:
	make ionic cmd="build android"

## Run an Ionic project on a connected device
run:
	make ionic cmd="run android"

## Run ionic command inside container, pass the command as cmd, e.g: make ionic cmd=info
ionic:
ifdef cmd
	docker exec -ti $(NAME) ionic $(cmd)
else
	printf "Please specify command, e.g: make ionic cmd=info\n"
endif

## Delete container
delete:
	docker rm -f $(NAME)

## Delete container and image
purge:
	make delete
	docker rmi -f $(IMAGE)