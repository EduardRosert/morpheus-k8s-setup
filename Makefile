
SCRIPT_NAME_INSTALL_MASTER=Install Kubernetes Master Node

default: install-requirements-controller

install-requirements-controller:
	./disable-swap.sh
	./disable-ipv6.sh
	./install-requirements.sh
	./setup-controller.sh

install-requirements-worker:
	./create-filesystem.sh
	./disable-swap.sh
	./disable-ipv6.sh
	./install-requirements.sh
	./setup-worker.sh

morpheus-setup:morpheus-cleanup-scripts
	@#removing by name works if there's at most one script with that name
	@echo "Adding library script '${SCRIPT_NAME_INSTALL_MASTER}'"
	@(morpheus library-scripts list | grep '${SCRIPT_NAME_INSTALL_MASTER}' > /dev/null) \
		&& echo "Script '${SCRIPT_NAME_INSTALL_MASTER}' already exists." \
		|| morpheus library-scripts add --name "${SCRIPT_NAME_INSTALL_MASTER}" --type bash --phase provision --file ./tasks/install_kubernetes_controller.sh

morpheus-cleanup-scripts:
	@echo "Cleaning up library script '${SCRIPT_NAME_INSTALL_MASTER}'"
	@(morpheus library-scripts list | grep '${SCRIPT_NAME_INSTALL_MASTER}' > /dev/null) \
		&& morpheus library-scripts remove "${SCRIPT_NAME_INSTALL_MASTER}" -y \
		|| echo "Nothing to clean up."