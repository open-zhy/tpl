.PHONY: build

TAG=$(shell git describe --tags --abbrev=0)

build:
	go build -ldflags "-X github.com/open-zhy/tpl/cmd.Version=$(TAG)" -o bin/tpl

install: build

test:
	go test -cover ./...

clear:
	rm -Rf bin/tpl
	go clean