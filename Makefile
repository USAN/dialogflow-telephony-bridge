TAG ?= latest

# Convenience makefiles.
include ../gcloud.Makefile
include ../var.Makefile

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/dialogflow-telephony-bridge/deployer:$(TAG)
NAME ?= dialogflow-telephony-bridge-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
  "imageTelephonyBridge": "$(REGISTRY)/dialogflow-telephony-bridge:$(TAG)" \
}
TESTER_IMAGE ?= $(REGISTRY)/dialogflow-telephony-bridge/tester:$(TAG)
APP_TEST_PARAMETERS ?= { \
  "imageTester": "$(TESTER_IMAGE)" \
}

# app.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app.Makefile

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
						   .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/dialogflow-telephony-bridge
	$(call print_target, $@)
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/dialogflow-telephony-bridge" \
	    --build-arg TAG="$(TAG)" \
		--build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
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
	    --tag "$(REGISTRY)/dialogflow-telephony-bridge:$(TAG)" \
		.
	docker push "$(REGISTRY)/dialogflow-telephony-bridge:$(TAG)"
	@touch "$@"

