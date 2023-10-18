.PHONY: lint test

# Used for Helm Chart
IMAGE_HELM_UNITTEST=docker.io/helmunittest/helm-unittest:3.12.3-0.3.5
IMAGE_CHART_TESTING=quay.io/helmpack/chart-testing:v3.9.0

traefikee/tests/__snapshot__:
	@mkdir traefikee/tests/__snapshot__

test: traefikee/tests/__snapshot__
	docker run ${DOCKER_ARGS} --entrypoint /bin/sh --rm -v $(CURDIR):/charts -w /charts $(IMAGE_HELM_UNITTEST) /charts/hack/test.sh

lint:
	docker run ${DOCKER_ARGS} --env GIT_SAFE_DIR="true" --entrypoint /bin/sh --rm -v $(CURDIR):/charts -w /charts $(IMAGE_CHART_TESTING) /charts/hack/ct.sh lint

test-install:
	docker run ${DOCKER_ARGS} --env GIT_SAFE_DIR="true" --entrypoint /bin/sh --rm -v $(CURDIR):/charts -w /charts $(IMAGE_CHART_TESTING) /charts/hack/ct.sh install


changelog:
	@echo "== Updating Changelogs..."
	@docker run -it --rm -v $(CURDIR):/data ghcr.io/mloiseleur/helm-changelog:v0.0.2
	@./hack/changelog.sh
	@echo "== Updating finished"
