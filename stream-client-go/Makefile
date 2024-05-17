BINARY=stream-client-go
GOARCH=amd64

# Detect the os so that we can build proper statically linked binary
OS := $(shell uname -s | awk '{print tolower($$0)}')

# Build & Run the project
all: clean build

build:
	go build -o bin/${BINARY}-${OS}-${GOARCH} .
	@echo "📦 Build Done"

consumer:
	@echo "🚀 Running Consumer"
	./bin/${BINARY}-$(OS)-${GOARCH}

producer:
	@echo "🚀 Running Producer"
	./bin/${BINARY}-$(OS)-${GOARCH} -p

clean:
	rm -rf bin


.PHONY: build clean consumer producer
