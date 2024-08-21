.PHONY_GOAL := help

.PHONY: help
help: ## show this message
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: build-linux build-darwin build-windows ## Build binaries for all platforms

.PHONY: build-linux
build-linux: ## Build binary for Linux
	GOOS=linux GOARCH=amd64 go build -mod=vendor -o bin/goose-linux ./cmd/goose/...
	sha256sum bin/goose-linux > bin/goose-linux.sha256

.PHONY: build-linux-arm
build-linux-arm: ## Build binary for Linux on ARM
	GOOS=linux GOARCH=arm64 go build -mod=vendor -o bin/goose-linux-arm ./cmd/goose/...
	sha256sum bin/goose-linux-arm > bin/goose-linux-arm.sha256

.PHONY: build-darwin
build-darwin: ## Build binary for macOS
	GOOS=darwin GOARCH=amd64 go build -mod=vendor -o bin/goose-darwin ./cmd/goose/...
	sha256sum bin/goose-darwin > bin/goose-darwin.sha256

.PHONY: build-windows
build-windows: ## Build binary for Windows
	GOOS=windows GOARCH=amd64 go build -mod=vendor -o bin/goose-windows.exe ./cmd/goose/...
	sha256sum bin/goose-windows.exe > bin/goose-windows.exe.sha256

.PHONY: clean
clean: ## Clean up binaries and checksums
	rm -rf bin/


.PHONY: upload
upload: ## Sync to S3
	aws s3 sync ./bin/ s3://devops.siteworx.io/static/bin/goose/
