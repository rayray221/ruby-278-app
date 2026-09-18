IMAGE ?= ruby-278-app:latest
KIND_CLUSTER ?= kind
NAMESPACE ?= ruby-278
DOCKER ?= $(shell command -v docker 2>/dev/null || command -v podman)
PLATFORM ?=
TTL ?= 2h
TTL_NAME ?= ruby-278-app
TTL_IMAGE ?= ttl.sh/$(TTL_NAME):$(TTL)
IMAGE_PULL_POLICY ?= IfNotPresent

ifneq ($(PLATFORM),)
BUILD_FLAGS += --platform $(PLATFORM)
endif

.PHONY: build load push-ttl apply apply-ttl exercise logs

build:
	$(DOCKER) build $(BUILD_FLAGS) -t $(IMAGE) .

load: build
	@if command -v docker >/dev/null 2>&1; then \
	  kind load docker-image $(IMAGE) --name $(KIND_CLUSTER); \
	else \
	  $(DOCKER) save $(IMAGE) | kind load image-archive /dev/stdin --name $(KIND_CLUSTER); \
	fi

push-ttl: build
	$(DOCKER) tag $(IMAGE) $(TTL_IMAGE)
	$(DOCKER) push $(TTL_IMAGE)
	@echo "Pushed $(TTL_IMAGE) (expires after $(TTL))"

apply:
	IMAGE=$(IMAGE) IMAGE_PULL_POLICY=$(IMAGE_PULL_POLICY) ./scripts/apply-k8s.sh

apply-ttl: push-ttl
	IMAGE=$(TTL_IMAGE) IMAGE_PULL_POLICY=Always ./scripts/apply-k8s.sh

exercise:
	kubectl -n $(NAMESPACE) create job --from=cronjob/otel-exercise otel-exercise-$$(date +%s)

logs:
	kubectl -n $(NAMESPACE) get pods
