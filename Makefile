.PHONY: build

TAG_FULL=$(shell git describe --tags)
TAG_SHORT=$(shell git describe --tags --abbrev=0)

build:
	go build -ldflags "-X main.Version=$(TAG_FULL)" -o bin/go-worker

docker-build:
	docker build -t gcr.io/portal-wau-co/go-worker .
	docker tag gcr.io/portal-wau-co/go-worker gcr.io/portal-wau-co/go-worker:$(TAG_SHORT)

docker-push:
	docker push gcr.io/portal-wau-co/go-worker

test:
	go test -cover ./...

clear:
	rm -Rf buil/go-worker
	go clean