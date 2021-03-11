# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: ghpmc android ios ghpmc-cross evm all test clean
.PHONY: ghpmc-linux ghpmc-linux-386 ghpmc-linux-amd64 ghpmc-linux-mips64 ghpmc-linux-mips64le
.PHONY: ghpmc-linux-arm ghpmc-linux-arm-5 ghpmc-linux-arm-6 ghpmc-linux-arm-7 ghpmc-linux-arm64
.PHONY: ghpmc-darwin ghpmc-darwin-386 ghpmc-darwin-amd64
.PHONY: ghpmc-windows ghpmc-windows-386 ghpmc-windows-amd64

GOBIN = $(shell pwd)/build/bin
GO ?= latest

ghpmc:
	build/env.sh go run build/ci.go install ./cmd/ghpmc
	@echo "Done building."
	@echo "Run \"$(GOBIN)/ghpmc\" to launch ghpmc."

all:
	build/env.sh go run build/ci.go install

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/ghpmc.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Ghpmc.framework\" to use the library."

test: all
	build/env.sh go run build/ci.go test

lint: ## Run linters.
	build/env.sh go run build/ci.go lint

clean:
	./build/clean_go_build_cache.sh
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

ghpmc-cross: ghpmc-linux ghpmc-darwin ghpmc-windows ghpmc-android ghpmc-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-*

ghpmc-linux: ghpmc-linux-386 ghpmc-linux-amd64 ghpmc-linux-arm ghpmc-linux-mips64 ghpmc-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-linux-*

ghpmc-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/ghpmc
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-linux-* | grep 386

ghpmc-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/ghpmc
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-linux-* | grep amd64

ghpmc-linux-arm: ghpmc-linux-arm-5 ghpmc-linux-arm-6 ghpmc-linux-arm-7 ghpmc-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-linux-* | grep arm

ghpmc-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/ghpmc
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-linux-* | grep arm-5

ghpmc-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/ghpmc
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-linux-* | grep arm-6

ghpmc-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/ghpmc
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-linux-* | grep arm-7

ghpmc-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/ghpmc
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-linux-* | grep arm64

ghpmc-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/ghpmc
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-linux-* | grep mips

ghpmc-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/ghpmc
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-linux-* | grep mipsle

ghpmc-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/ghpmc
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-linux-* | grep mips64

ghpmc-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/ghpmc
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-linux-* | grep mips64le

ghpmc-darwin: ghpmc-darwin-386 ghpmc-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-darwin-*

ghpmc-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/ghpmc
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-darwin-* | grep 386

ghpmc-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/ghpmc
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-darwin-* | grep amd64

ghpmc-windows: ghpmc-windows-386 ghpmc-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-windows-*

ghpmc-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/ghpmc
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-windows-* | grep 386

ghpmc-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/ghpmc
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/ghpmc-windows-* | grep amd64
