default: install-requirements

install-requirements:
	./create-filesystem.sh
	./disable-ipv6.sh
	./install-requirements.sh