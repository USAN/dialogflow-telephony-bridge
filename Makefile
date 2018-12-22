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

include marketplace-tools/var.Makefile

# app.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined as followed.
include marketplace-tools/app.Makefile

APP_REGISTRY_FOLDER ?= dialogflow-telephony-bridge-de

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_REGISTRY_FOLDER)/deployer:$(TAG)
NAME ?= dialogflow-telephony-bridge-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
  "imageTelephonyBridge": "$(REGISTRY)/$(APP_REGISTRY_FOLDER):$(TAG)" \
}
TESTER_IMAGE ?= $(REGISTRY)/$(APP_REGISTRY_FOLDER)/tester:$(TAG)
APP_TEST_PARAMETERS ?= { \
  "imageTester": "$(TESTER_IMAGE)" \
}

# Extend the target as defined in app.Makefile to
# include real dependencies.
app/build:: .build/dialogflow-telephony-bridge/deployer \
            .build/dialogflow-telephony-bridge/tester \
            .build/dialogflow-telephony-bridge/dialogflow-telephony-bridge


.build/dialogflow-telephony-bridge: | .build
	mkdir -p "$@"

.build/dialogflow-telephony-bridge/deployer: apptest/deployer/* \
                           apptest/deployer/manifest/* \
                           deployer/* \
                           manifest/* \
                           schema.yaml \
                           .build/marketplace/deployer/envsubst \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/dialogflow-telephony-bridge
	$(call print_target, $@)
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/$(APP_REGISTRY_FOLDER)" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/dialogflow-telephony-bridge/tester: .build/var/REGISTRY \
                            .build/var/TAG \
							apptest/* \
							apptest/dialogflow-telephony-bridge-testsuite/* \
							apptest/dialogflow-telephony-bridge-testsuite/sip/* \
							| .build/dialogflow-telephony-bridge
	$(call print_target, $@)
	cd apptest && docker build \
		--tag "$(TESTER_IMAGE)" \
		.
	docker push "$(TESTER_IMAGE)"
	@touch "$@"

.build/dialogflow-telephony-bridge/dialogflow-telephony-bridge: .build/var/REGISTRY \
                            .build/var/TAG \
							telephony-bridge/* \
							telephony-bridge/etc_asterisk/* \
                            | .build/dialogflow-telephony-bridge
	$(call print_target, $@)
	cd telephony-bridge && docker build \
	    --tag "$(REGISTRY)/$(APP_REGISTRY_FOLDER):$(TAG)" \
		.
	docker push "$(REGISTRY)/$(APP_REGISTRY_FOLDER):$(TAG)"
	@touch "$@"

