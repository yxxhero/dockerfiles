ARCH:=$(shell uname -m)
TAG:=$(shell case `uname -m` in \
	("arm64"|"aarch64") echo "arm64" ;; \
    ("x86_64") echo "amd64" ;; \
    (*) echo $(ARCH) ;; \
esac)

.PHONY: build
build:
	@case $(ARCH) in \
		("all") \
			docker build -f Dockerfile -t chatwork/`basename $$PWD`:amd64 .; \
			docker build -f Dockerfile.arm64v8 -t chatwork/`basename $$PWD`:arm64 .; \
            break ;; \
		("arm64"|"aarch64") \
			docker build -f Dockerfile.arm64v8 -t chatwork/`basename $$PWD`:arm64 .; \
			break ;; \
		("x86_64")  \
			docker build -f Dockerfile -t chatwork/`basename $$PWD`:amd64 .; \
			break ;; \
		(*) \
			echo "arch: $(ARCH) is not supported."; \
			exit 1; \
			break ;; \
	esac

	@version=$$(docker inspect -f {{.Config.Labels.version}} chatwork/`basename $$PWD`:${TAG}); \
    if [ -n "$$version" ]; then \
    	docker tag chatwork/`basename $$PWD`:${TAG} chatwork/`basename $$PWD`:$$version; \
    	docker tag chatwork/`basename $$PWD`:${TAG} chatwork/`basename $$PWD`; \
    fi

.PHONY: check
check:
	@version=$$(docker inspect -f {{.Config.Labels.version}} chatwork/`basename $$PWD`); \
		if [ -z "$$version" ]; then \
			echo "\033[91mError: version is not defined in Dockerfile.\033[0m"; \
			exit 1; \
		fi;
	@echo "\033[92mno problem.\033[0m";

.PHONY: test
test:
	docker-compose -f docker-compose.test.yml up --build --no-start sut
	docker cp $(shell pwd)/goss `basename $$PWD`:/goss
	docker-compose -f docker-compose.test.yml up --no-recreate --exit-code-from sut sut

.PHONY: push
push:
	@version=$$(docker inspect -f {{.Config.Labels.version}} chatwork/`basename $$PWD`:latest); \
		if docker inspect --format='{{index .RepoDigests 0}}' chatwork/$$(basename $$PWD):$$version >/dev/null 2>&1; then \
			echo "no changes"; \
		else \
			docker push chatwork/`basename $$PWD`:$$version-amd64; \
			docker push chatwork/`basename $$PWD`:$$version-arm64; \

			docker manifest create chatwork/`basename $$PWD`:$$version chatwork/`basename $$PWD`:$$version-amd64 chatwork/`basename $$PWD`:$$version-arm64; \
			docker manifest push chatwork/`basename $$PWD`:$$version \

			docker manifest create chatwork/`basename $$PWD` chatwork/`basename $$PWD`:$$version-amd64 chatwork/`basename $$PWD`:$$version-arm64; \
			docker manifest push chatwork/`basename $$PWD` \
		fi
