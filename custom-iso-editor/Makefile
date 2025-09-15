UBUNTU_VERSION = 22.04.3
UBUNTU_RELEASE = 22.04
ISO_URLBASE = https://releases.ubuntu.com/$(UBUNTU_RELEASE)/
ISO_FILENAME_DOWNLOAD = ubuntu-$(UBUNTU_VERSION)-live-server-amd64.iso
ISO_FILENAME = $(PWD)/custom-iso-editor/ubuntu-$(UBUNTU_VERSION)-live-server-amd64.iso
ISO_MOUNTPOINT = /mnt/user_custom_iso
ISO_ROOT = $(PWD)/custom-iso-editor/iso_root
ISO_FILES = $(PWD)/custom-iso-editor/user_iso_files

## copy files
GRUBCFG_SRC = $(PWD)/custom-iso-editor/config/boot/grub/grub.cfg
GRUBCFG_DEST = $(PWD)/custom-iso-editor/iso_root/boot/grub/grub.cfg
USERDATA_SRC = $(PWD)/custom-iso-editor/config/user-data
USERDATA_DEST =$(PWD)/custom-iso-editor/iso_root/pressed/user-data
METADATA_SRC = $(PWD)/custom-iso-editor/config/meta-data
METADATA_DEST = $(PWD)/custom-iso-editor/iso_root/pressed/meta-data
EXTRAS_SRCDIR = $(PWD)/custom-iso-editor/config/extras/
EXTRAS_DESTDIR = $(PWD)/custom-iso-editor/iso_root/extras/


GENISO_LABEL = UserCustomISO
GENISO_FILENAME = $(PWD)/custom-iso-editor/user_iso_files/user-custom-autoinstaller.$(shell date +%Y%m%d.%H%M%S).iso
GENISO_BOOTIMG = boot/grub/i386-pc/eltorito.img
GENISO_BOOTCATALOG = /boot.catalog
GENISO_START_SECTOR = $(shell sudo fdisk -l $(ISO_FILENAME) |grep iso2 | cut -d' ' -f2)
GENISO_END_SECTOR = $(shell sudo fdisk -l $(ISO_FILENAME) |grep iso2 | cut -d' ' -f3)
GENISO_LANG = C

## for APU/APU2
GENISO_ISOLINUX = /usr/lib/ISOLINUX/isolinux.bin
GENISO_ISOLINUX_MODULEDIR = /usr/lib/syslinux/modules/bios/
GENISO_HYBRIDMBR = /usr/lib/ISOLINUX/isohdpfx.bin
ISOLINUX_CONFIGDIR = $(PWD)/custom-iso-editor/config/isolinux
ISOLINUX_DIRNAME = isolinux

## Colors
COLOR_RED = \033[5;31m
COLOR_GREEN = \033[5;32m
COLOR_ORANGE = \033[5;33m
COLOR_BLUE = \033[5;34m
COLOR_GRAY = \033[1;37m
COLOR_GRAY_BLINK = \033[4;37m
COLOR_GRAY_BLINK_UNDERLINE = \033[5;37m\033[4m
COLOR_RESET = \033[0m
BLINK = \033[5m
UNDERLINE = \033[4m



.PHONY: iso_download
iso_download:
	wget -O ${ISO_FILENAME} -N $(ISO_URLBASE)/$(ISO_FILENAME_DOWNLOAD)

.PHONY: iso_init
iso_init:
	sudo apt install xorriso rsync
	( test -d $(ISO_ROOT) && mv -f $(ISO_ROOT) $(ISO_ROOT).$(shell date +%Y%m%d.%H%M%S) ) || true
	mkdir -p $(ISO_ROOT)
	mkdir -p $(ISO_ROOT)/pressed
	mkdir -p $(ISO_ROOT)/extras
	mkdir -p $(ISO_FILES)
	sudo mkdir -p $(ISO_MOUNTPOINT)
	(mountpoint $(ISO_MOUNTPOINT) && sudo umount -q $(ISO_MOUNTPOINT)) || true
	sudo mount -o ro,loop $(ISO_FILENAME) $(ISO_MOUNTPOINT)
	rsync -av $(ISO_MOUNTPOINT)/. $(ISO_ROOT)/.
	sudo umount $(ISO_MOUNTPOINT)

.PHONY: iso_setup
iso_setup:
	chmod 755 $(ISO_ROOT)
	chmod 644 $(GRUBCFG_DEST)
	cp -f $(GRUBCFG_SRC) $(GRUBCFG_DEST)
	chmod 755 $(ISO_ROOT)
	cp -f $(USERDATA_SRC) $(USERDATA_DEST)
	cp -f $(METADATA_SRC) $(METADATA_DEST)
	rsync -av $(EXTRAS_SRCDIR)/. $(EXTRAS_DESTDIR)/.

.PHONY: iso_setup-isolinux
iso_setup-isolinux:
	chmod 755 $(ISO_ROOT)
	sudo apt install isolinux syslinux-common
	cp $(GENISO_ISOLINUX) $(ISO_ROOT)/
	mkdir -p $(ISO_ROOT)/$(ISOLINUX_DIRNAME)
	rsync -av $(GENISO_ISOLINUX_MODULEDIR)/. $(ISO_ROOT)/$(ISOLINUX_DIRNAME)/.
	rsync -av $(ISOLINUX_CONFIGDIR)/. $(ISO_ROOT)/$(ISOLINUX_DIRNAME)/.

.PHONY: iso_geniso
iso_geniso:
	sudo env LANG=$(GENISO_LANG) xorriso -as mkisofs -volid $(GENISO_LABEL) \
	-output $(GENISO_FILENAME) \
	-eltorito-boot $(GENISO_BOOTIMG) \
	-eltorito-catalog $(GENISO_BOOTCATALOG) -no-emul-boot \
	-boot-load-size 4 -boot-info-table -eltorito-alt-boot \
	-no-emul-boot -isohybrid-gpt-basdat \
	-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:$(GENISO_START_SECTOR)d-$(GENISO_END_SECTOR)d::'$(ISO_FILENAME)' \
	-e '--interval:appended_partition_2_start_1782357s_size_8496d:all::' \
	--grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:'$(ISO_FILENAME)' \
	"${ISO_ROOT}"

.PHONY: iso_geniso-isolinux
iso_geniso-isolinux:
	sudo env LANG=$(GENISO_LANG) xorriso -as mkisofs -volid $(GENISO_LABEL) \
	-output $(GENISO_FILENAME) \
	-eltorito-boot /$(shell basename $(GENISO_ISOLINUX)) \
	-eltorito-catalog $(GENISO_BOOTCATALOG) -no-emul-boot \
	-boot-load-size 4 -boot-info-table -eltorito-alt-boot \
	-no-emul-boot -isohybrid-gpt-basdat \
	-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:$(GENISO_START_SECTOR)d-$(GENISO_END_SECTOR)d::'$(ISO_FILENAME)' \
	-isohybrid-mbr $(GENISO_HYBRIDMBR) \
	-e '--interval:appended_partition_2_start_1782357s_size_8496d:all::' \
	"${ISO_ROOT}"


.PHONY: iso_write_usb
iso_write_usb:
	latest_iso=$(shell ls -t $(ISO_FILES)/user-custom-autoinstaller.*.iso | head -n 1); \
	echo "$(COLOR_BLUE)Yazdirilacak son ISO bulunuyor....$(COLOR_RESET)"; \
	if [ -z "$$latest_iso" ]; then \
		echo -e "$(COLOR_RED)No ISO file found.$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_GREEN)Latest ISO file: $(UNDERLINE)$$latest_iso$(COLOR_RESET)"; \
	fi; \
	usb_device=$$(lsblk -npl -o NAME,TYPE | awk '$$2=="disk" && $$1 ~ /^\/dev\/sd[a-z]/ {print $$1}'); \
	for disk in $$usb_device; do \
		echo "$(COLOR_GRAY)Found SD disk: $(COLOR_GREEN)$$disk$(COLOR_RESET)"; \
		echo "$(COLOR_GRAY_BLINK)Harun Kahve Icmeye gidebilirsin...$(COLOR_RESET)"; \
		yes | sudo mkfs -t ext4 "$$disk"; \
		sudo dd if="$$latest_iso" of="$$disk" bs=4M status=progress; \
		echo "$(COLOR_GRAY_BLINK_UNDERLINE)--------------------------------------------------------$(COLOR_RESET)"; \
	done; \


# Chroot function
define chroot
	sudo chroot $(ISO_ROOT) $(1)
endef

# ... (Rest of your Makefile)

.PHONY: iso_chroot-shell
iso_chroot-shell:
	sudo mount --bind /dev $(ISO_ROOT)/dev
	sudo mount --bind /proc $(ISO_ROOT)/proc
	sudo mount --bind /sys $(ISO_ROOT)/sys
	$(call chroot,/bin/bash)
	sudo umount $(ISO_ROOT)/dev
	sudo umount $(ISO_ROOT)/proc
	sudo umount $(ISO_ROOT)/sys



.PHONY: clean
clean:
	echo User ISO Dosyalar temizlendi.
	@make iso_clean-up-all
	# find . -type f -a -user "$(shell id -un)" -a -name '*~' -exec rm {} \; -print
	

.PHONY: iso_clean-up-all
iso_clean-up-all: clean
	sudo rm -rf ${ISO_ROOT}
	sudo rm -rf ${ISO_FILES}
	sudo rm -rf ${ISO_ROOT}.*

