default: install-requirements-controller

install-requirements-controller:
	./disable-ipv6.sh
	./install-requirements.sh

install-requirements-worker:
	./create-filesystem.sh
	./disable-ipv6.sh
	./install-requirements.sh