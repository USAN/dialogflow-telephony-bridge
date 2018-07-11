TAG ?= latest

# crd.Makefile provides targets to install Application CRD.
include marketplace-tools/crd.Makefile

# gcloud.Makefile provides default values for
# REGISTRY and NAMESPACE derived from local
# gcloud and kubectl environments.
include marketplace-tools/gcloud.Makefile

# marketplace.Makefile provides targets such as
# ".build/marketplace/deployer/envsubst" to build the base
# deployer images locally.
include marketplace-tools/marketplace.Makefile

# ubbagent.Makefile provides ".build/ubbagent/ubbagent"
# target to build the ubbagent image locally.
include marketplace-tools/ubbagent.Makefile
include marketplace-tools/var.Makefile

# app.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined as followed.
include marketplace-tools/app.Makefile

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/dialogflow-telephony-bridge/deployer:$(TAG)
NAME ?= dialogflow-telephony-bridge-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
  "imageTelephonyBridge": "$(REGISTRY)/dialogflow-telephony-bridge:$(TAG)", \
  "imageInit": "$(REGISTRY)/dialogflow-telephony-bridge/init:$(TAG)", \
  "imageUbbagent": "$(REGISTRY)/dialogflow-telephony-bridge/ubbagent:$(TAG)", \
  "reportingSecret": "$(NAME)-reporting-secret" \
}
TESTER_IMAGE ?= $(REGISTRY)/dialogflow-telephony-bridge/tester:$(TAG)
APP_TEST_PARAMETERS ?= { \
  "imageTester": "$(TESTER_IMAGE)" \
}

# Extend the target as defined in app.Makefile to
# include real dependencies.
app/build:: .build/telephony-bridge/deployer \
            .build/telephony-bridge/init \
            .build/telephony-bridge/tester \
            .build/telephony-bridge/ubbagent \
            .build/telephony-bridge/telephony-bridge


.build/telephony-bridge: | .build
	mkdir -p "$@"

.build/telephony-bridge/deployer: apptest/deployer/* \
                           apptest/deployer/manifest/* \
                           deployer/* \
                           manifest/* \
                           schema.yaml \
                           .build/marketplace/deployer/envsubst \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/telephony-bridge
	$(call print_target, $@)
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/telephony-bridge" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/telephony-bridge/tester:
	$(call print_target, $@)
	docker pull cosmintitei/bash-curl
	docker tag cosmintitei/bash-curl "$(TESTER_IMAGE)"
	docker push "$(TESTER_IMAGE)"
	@touch "$@"

.build/telephony-bridge/telephony-bridge: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/telephony-bridge
	$(call print_target, $@)
	cd telephony-bridge && docker build \
	    --tag "$(REGISTRY)/telephony-bridge:$(TAG)" \
		.
	docker push "$(REGISTRY)/telephony-bridge:$(TAG)"
	@touch "$@"

# Build secondary app image.
.build/telephony-bridge/init: init/* \
                       .build/var/REGISTRY \
                       .build/var/TAG \
                       | .build/telephony-bridge
	$(call print_target, $@)
	cd init \
	&& docker build --tag "$(REGISTRY)/telephony-bridge/init:$(TAG)" .
	docker push "$(REGISTRY)/telephony-bridge/init:$(TAG)"
	@touch "$@"

# Relocate ubbagent image to $REGISTRY.
.build/telephony-bridge/ubbagent: .build/ubbagent/ubbagent \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/telephony-bridge
	$(call print_target, $@)
	docker tag "gcr.io/cloud-marketplace-tools/ubbagent" "$(REGISTRY)/telephony-bridge/ubbagent:$(TAG)"
	docker push "$(REGISTRY)/telephony-bridge/ubbagent:$(TAG)"
	@touch "$@"
