VERSION    :=$(shell cat .version)
COMMIT     :=$(shell git rev-parse HEAD)
YAML_FILES :=$(shell find . -type f -regex ".*yaml" -print)

all: help

version: ## Prints the current version
	@echo $(VERSION)
.PHONY: version

tidy: ## Updates the go modules and vendors all dependancies 
	go mod tidy
	go mod vendor
.PHONY: tidy

upgrade: ## Upgrades all dependancies 
	go get -d -u ./...
	go mod tidy
	go mod vendor
.PHONY: upgrade

test: tidy ## Runs unit tests
	go test -count=1 -race -covermode=atomic -coverprofile=cover.out ./...
.PHONY: test

.PHONY: lint
lint: lint-go lint-yaml lint-tf ## Lints the entire project 
	@echo "Completed Go and YAML lints"

.PHONY: lint
lint-go: ## Lints the entire project using go 
	golangci-lint -c .golangci.yaml run

.PHONY: lint-yaml
lint-yaml: ## Runs yamllint on all yaml files (brew install yamllint)
	yamllint -c .yamllint $(YAML_FILES)

.PHONY: lint-tf
lint-tf: ## Runs terraform fmt on all terraform files
	terraform -chdir=./setup fmt

server: ## Runs uncompiled app 
	LOG_LEVEL=debug go run cmd/server/main.go
.PHONY: server

tag: ## Creates release tag 
	git tag -s -m "version bump to $(VERSION)" $(VERSION)
	git push origin $(VERSION)
.PHONY: tag

tagless: ## Delete the current release tag 
	git tag -d $(VERSION)
	git push --delete origin $(VERSION)
.PHONY: tagless

build: ## Publishes image directly using ko
	KO_DOCKER_REPO=us-west1-docker.pkg.dev/cloudy-s3c/demo/demo \
	KO_DEFAULTPLATFORMS=linux/amd64 \
	GOFLAGS="-ldflags=-X=main.version=$(VERSION) -ldflags=-X=main.commit=$(COMMIT)" \
		ko build cmd/server/main.go --image-refs .digest --bare --tags $(VERSION),latest
.PHONY: build

.PHONY: setup
setup: ## Applies Terraform
	terraform -chdir=./setup apply -auto-approve

clean: ## Cleans bin and temp directories
	go clean
	rm -fr ./vendor
	rm -fr ./bin
.PHONY: clean

help: ## Display available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk \
		'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help
