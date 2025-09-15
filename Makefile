BUILD_DEPS := xorriso qemu-utils qemu-kvm ovmf curl ca-certificates cloud-image-utils gdisk kpartx wget util-linux


include custom-iso-editor/Makefile
include custom-iso-server/Makefile

all:
	@echo "Available targets are:"
	# @$(MAKE) -C subfolder


.PHONY: iso_depends
iso_depends:
	$(SUDO) apt-get -y install --no-install-recommends $(BUILD_DEPS)

