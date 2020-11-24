.PHONY: destroy apply plan
.ONESHELL:

set-env:
	@if [ -z $(ENV) ]; then \
		echo "$(BOLD)$(RED)ENV was not set$(RESET)"; \
		echo "TIPS: ENV=staging make <cmd>"; \
		exit 1; \
	else \
		echo "Running for env: ${ENV}"; \
	 fi
	@if [ -z $(AWS_DEFAULT_REGION) ]; then \
		echo "$(BOLD)$(RED)REGION was not set$(RESET)"; \
		exit 1; \
	 fi
	@if [ -z $(AWS_PROFILE) ]; then \
		echo "$(BOLD)$(RED)AWS_PROFILE was not set.$(RESET)"; \
		exit 1; \
	 fi

set-workspace:
	@cd tf-shared
	@echo "selecting workspace 'shared' for tf-shared"
	@terraform workspace select shared
	@cd ../tf-db
	@echo "selecting workspace '${ENV}' for tf-db"
	@terraform workspace select ${ENV}
	@cd ../tf-app
	@echo "selecting workspace '${ENV}' for tf-app"
	@terraform workspace select ${ENV}

destroy: set-env set-workspace
	@cd tf-app; \
	echo "running destroy for tf-app in workspace: '${ENV}'"; \
	terraform destroy -var env=${ENV}; \
	cd ../tf-db; \
	echo "running destroy for tf-db in workspace: '${ENV}'"; \
	terraform destroy -var env=${ENV}; \
	cd ../tf-shared; \
	echo "running destroy for tf-shared in workspace: 'shared'"; \
	terraform destroy -var env=shared

apply: set-env set-workspace
	@cd tf-shared; \
	echo "running apply for tf-shared in workspace: 'shared'"; \
	terraform apply -var env=shared; \
	cd ../tf-db; \
	echo "running apply for tf-db in workspace: '${ENV}'"; \
	terraform apply -var env=${ENV}; \
	@cd tf-app; \
	echo "running apply for tf-app in workspace: '${ENV}'"; \
	terraform apply -var env=${ENV}
