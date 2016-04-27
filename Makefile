build:
	mkdir -p build
	mkdir -p dist/bin
	mkdir -p dist/lib
	cp build.Dockerfile build/Dockerfile
	cd build && docker build -t chromapdx/mongo-rocks-builder .
	docker run -d --name mongo-rocks-builder \
		-v "$(shell pwd)/dist":/out \
		chromapdx/mongo-rocks-builder

dist:
	cp dist.Dockerfile dist/Dockerfile
	cd dist && docker build -t chromapdx/mongo-rocks-dist .

run:
	cd example && docker build -t chromapdx/mongo-rocks .
	docker run -d --name mongo-rocks \
	  -e MONGODB_PASS=mongotest \
	  -v "$(shell pwd)":/data \
	  chromapdx/mongo-rocks

all: build dist

install:
	docker push chromapdx/mongo-rocks-dist

clean:
	sudo rm -Rf build
	sudo rm -Rf dist

.PHONY: dist all build test clean
