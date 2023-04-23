VERSION    :=$(shell cat .version)
YAML_FILES :=$(shell find . ! -path "./vendor/*" ! -path "./deploy/*" ! -path "./setup/*" -type f -regex ".*y*ml" -print)

all: help

.PHONY: version
version: ## Prints the current version
	@echo $(VERSION)

.PHONY: tidy
tidy: ## Updates the go modules and vendors all dependancies 
	go mod tidy
	go mod vendor

.PHONY: upgrade
upgrade: ## Upgrades all dependancies 
	go get -d -u ./...
	go mod tidy
	go mod vendor

.PHONY: test
test: tidy ## Runs unit tests
	go test -count=1 -race -covermode=atomic -coverprofile=cover.out ./...

.PHONY: lint
lint: lint-go lint-yaml ## Lints the entire project 
	@echo "Completed Go and YAML lints"

.PHONY: lint
lint-go: ## Lints the entire project using go 
	golangci-lint -c .golangci.yaml run

.PHONY: lint-yaml
lint-yaml: ## Runs yamllint on all yaml files (brew install yamllint)
	yamllint -c .yamllint $(YAML_FILES)

.PHONY: build
build: tidy ## Builds CLI binary
	mkdir -p ./bin
	CGO_ENABLED=0 go build -trimpath \
	-ldflags="-w -s -X main.version=$(RELEASE_VERSION) \
	-extldflags '-static'" -mod vendor \
	-o bin/server internal/cmd/main.go

.PHONY: vulncheck
vulncheck: ## Checks for soource vulnerabilities
	govulncheck -test ./...

.PHONY: server
server: ## Runs uncompiled app 
	LOG_LEVEL=debug go run internal/cmd/main.go

.PHONY: tag
tag: ## Creates release tag 
	git tag -s -m "version bump to $(VERSION)" $(VERSION)
	git push origin $(VERSION)

.PHONY: tagless
tagless: ## Delete the current release tag 
	git tag -d $(VERSION)
	git push --delete origin $(VERSION)

.PHONY: clean
clean: ## Cleans bin and temp directories
	go clean
	rm -fr ./vendor
	rm -fr ./bin

.PHONY: help
help: ## Display available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk \
		'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
