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