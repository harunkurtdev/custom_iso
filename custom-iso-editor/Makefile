# ================================================
# CUSTOM ISO BUILDER - MAKEFILE CONFIGURATION
# ================================================
# This Makefile automates the creation of customized Ubuntu 22.04 Server
# ISO images optimized for embedded systems, particularly APU/APU2 hardware.
# 
# Features:
# - Automated ISO download and extraction
# - Configuration file integration
# - APU/APU2-specific optimizations
# - USB deployment automation
# - Docker server integration
#
# Usage: Run 'make help' for available commands
# ================================================

# ================================================
# UBUNTU VERSION CONFIGURATION
# ================================================
UBUNTU_VERSION = 22.04.3                    # Ubuntu version to use
UBUNTU_RELEASE = 22.04                      # Ubuntu release number  
ISO_URLBASE = https://releases.ubuntu.com/$(UBUNTU_RELEASE)/
ISO_FILENAME_DOWNLOAD = ubuntu-$(UBUNTU_VERSION)-live-server-amd64.iso
ISO_FILENAME = $(PWD)/custom-iso-editor/ubuntu-$(UBUNTU_VERSION)-live-server-amd64.iso

# ================================================
# DIRECTORY STRUCTURE CONFIGURATION
# ================================================
ISO_MOUNTPOINT = /mnt/user_custom_iso        # Temporary mount point for ISO extraction
ISO_ROOT = $(PWD)/custom-iso-editor/iso_root # Extracted ISO contents directory
ISO_FILES = $(PWD)/custom-iso-editor/user_iso_files  # Generated ISO output directory

# ================================================
# CONFIGURATION FILE MAPPING
# ================================================
# Source and destination paths for custom configuration files

## GRUB bootloader configuration
GRUBCFG_SRC = $(PWD)/custom-iso-editor/config/boot/grub/grub.cfg
GRUBCFG_DEST = $(PWD)/custom-iso-editor/iso_root/boot/grub/grub.cfg

## Cloud-init autoinstall configuration  
USERDATA_SRC = $(PWD)/custom-iso-editor/config/user-data
USERDATA_DEST =$(PWD)/custom-iso-editor/iso_root/pressed/user-data

## System metadata configuration
METADATA_SRC = $(PWD)/custom-iso-editor/config/meta-data
METADATA_DEST = $(PWD)/custom-iso-editor/iso_root/pressed/meta-data

## Additional custom files (scripts, certificates, etc.)
EXTRAS_SRCDIR = $(PWD)/custom-iso-editor/config/extras/
EXTRAS_DESTDIR = $(PWD)/custom-iso-editor/iso_root/extras/

# ================================================
# ISO GENERATION CONFIGURATION
# ================================================
GENISO_LABEL = UserCustomISO                # Volume label for generated ISO
# Timestamped filename for output ISO
GENISO_FILENAME = $(PWD)/custom-iso-editor/user_iso_files/user-custom-autoinstaller.$(shell date +%Y%m%d.%H%M%S).iso
GENISO_BOOTIMG = boot/grub/i386-pc/eltorito.img    # GRUB boot image path
GENISO_BOOTCATALOG = /boot.catalog                  # Boot catalog file location
# Dynamic sector calculation from original ISO
GENISO_START_SECTOR = $(shell sudo fdisk -l $(ISO_FILENAME) |grep iso2 | cut -d' ' -f2)
GENISO_END_SECTOR = $(shell sudo fdisk -l $(ISO_FILENAME) |grep iso2 | cut -d' ' -f3)
GENISO_LANG = C                             # Language setting (C = English/Universal)

# ================================================
# APU/APU2 SYSTEM OPTIMIZATION SETTINGS
# ================================================
# APU systems use BIOS-based boot instead of UEFI, requiring ISOLINUX bootloader
GENISO_ISOLINUX = /usr/lib/ISOLINUX/isolinux.bin     # ISOLINUX bootloader binary
GENISO_ISOLINUX_MODULEDIR = /usr/lib/syslinux/modules/bios/  # SYSLINUX modules directory
GENISO_HYBRIDMBR = /usr/lib/ISOLINUX/isohdpfx.bin            # Hybrid MBR for USB compatibility
ISOLINUX_CONFIGDIR = $(PWD)/custom-iso-editor/config/isolinux # ISOLINUX configuration source
ISOLINUX_DIRNAME = isolinux                                   # Directory name in ISO

# ================================================
# COLOR DEFINITIONS FOR OUTPUT FORMATTING
# ================================================
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

# ================================================
# MAKEFILE TARGETS
# ================================================

.PHONY: help
help: ## Show this help message
	@echo "$(COLOR_BLUE)Custom ISO Builder - Available Commands$(COLOR_RESET)"
	@echo "$(COLOR_GRAY)========================================$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_GREEN)Setup Commands:$(COLOR_RESET)"
	@echo "  iso_depends     - Install required system dependencies"
	@echo "  iso_download    - Download Ubuntu 22.04 Server ISO"
	@echo "  iso_init        - Extract ISO contents for modification"
	@echo ""
	@echo "$(COLOR_GREEN)Configuration Commands:$(COLOR_RESET)"
	@echo "  iso_setup       - Apply custom configuration files"
	@echo "  iso_setup-isolinux - Apply APU/APU2-specific configuration"
	@echo ""
	@echo "$(COLOR_GREEN)ISO Generation Commands:$(COLOR_RESET)"
	@echo "  iso_geniso      - Generate standard GRUB-based ISO"
	@echo "  iso_geniso-isolinux - Generate APU/APU2-optimized ISO"
	@echo ""
	@echo "$(COLOR_GREEN)Deployment Commands:$(COLOR_RESET)"
	@echo "  iso_write_usb   - $(COLOR_RED)⚠️ WARNING: Write ISO to USB (destructive!)$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_GREEN)Docker Server Commands:$(COLOR_RESET)"
	@echo "  iso_server_build - Build Docker configuration server"
	@echo "  iso_server_run   - Run Docker configuration server"
	@echo "  iso_server_shell - Access server shell for debugging"
	@echo ""
	@echo "$(COLOR_GREEN)Utility Commands:$(COLOR_RESET)"
	@echo "  status          - Show current build status"
	@echo "  clean           - Clean up temporary files"
	@echo ""
	@echo "$(COLOR_ORANGE)Quick Start:$(COLOR_RESET)"
	@echo "  make iso_depends && make iso_download && make iso_init"
	@echo "  make iso_setup && make iso_setup-isolinux"
	@echo "  make iso_geniso-isolinux"
	@echo ""

.PHONY: status
status: ## Show current build status and file information
	@echo "$(COLOR_BLUE)Custom ISO Builder - Current Status$(COLOR_RESET)"
	@echo "$(COLOR_GRAY)====================================$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_GREEN)Configuration:$(COLOR_RESET)"
	@echo "  Ubuntu Version: $(UBUNTU_VERSION)"
	@echo "  ISO Source: $(ISO_URLBASE)"
	@echo ""
	@echo "$(COLOR_GREEN)File Status:$(COLOR_RESET)"
	@if [ -f "$(ISO_FILENAME)" ]; then \
		echo "  ✓ Ubuntu ISO: $(COLOR_GREEN)Downloaded$(COLOR_RESET) ($(shell du -h $(ISO_FILENAME) | cut -f1))"; \
	else \
		echo "  ✗ Ubuntu ISO: $(COLOR_RED)Not found$(COLOR_RESET) - run 'make iso_download'"; \
	fi
	@if [ -d "$(ISO_ROOT)" ]; then \
		echo "  ✓ ISO Contents: $(COLOR_GREEN)Extracted$(COLOR_RESET) ($(shell du -sh $(ISO_ROOT) | cut -f1))"; \
	else \
		echo "  ✗ ISO Contents: $(COLOR_RED)Not extracted$(COLOR_RESET) - run 'make iso_init'"; \
	fi
	@if [ -d "$(ISO_FILES)" ]; then \
		echo "  ✓ Output Directory: $(COLOR_GREEN)Ready$(COLOR_RESET)"; \
		@ls -la $(ISO_FILES)/*.iso 2>/dev/null | wc -l | xargs -I {} echo "    Generated ISOs: {}" || echo "    Generated ISOs: 0"; \
	else \
		echo "  ✗ Output Directory: $(COLOR_RED)Not created$(COLOR_RESET)"; \
	fi



.PHONY: iso_depends
iso_depends: ## Install required system dependencies
	@echo "$(COLOR_BLUE)Installing system dependencies...$(COLOR_RESET)"
	sudo apt update
	sudo apt install -y xorriso rsync isolinux syslinux-utils genisoimage wget curl

.PHONY: iso_download
iso_download: ## Download Ubuntu 22.04 Server ISO from official repository
	@echo "$(COLOR_BLUE)Downloading Ubuntu $(UBUNTU_VERSION) Server ISO...$(COLOR_RESET)"
	@echo "Source: $(ISO_URLBASE)$(ISO_FILENAME_DOWNLOAD)"
	wget -O ${ISO_FILENAME} -N $(ISO_URLBASE)/$(ISO_FILENAME_DOWNLOAD)
	@echo "$(COLOR_GREEN)Download completed: $(ISO_FILENAME)$(COLOR_RESET)"

.PHONY: iso_init
iso_init: ## Extract ISO contents and prepare working directory
	@echo "$(COLOR_BLUE)Initializing ISO working environment...$(COLOR_RESET)"
	sudo apt install xorriso rsync
	# Backup existing ISO_ROOT if present
	( test -d $(ISO_ROOT) && mv -f $(ISO_ROOT) $(ISO_ROOT).$(shell date +%Y%m%d.%H%M%S) ) || true
	# Create required directories
	mkdir -p $(ISO_ROOT)
	mkdir -p $(ISO_ROOT)/pressed
	mkdir -p $(ISO_ROOT)/extras
	mkdir -p $(ISO_FILES)
	sudo mkdir -p $(ISO_MOUNTPOINT)
	# Mount and extract ISO contents
	(mountpoint $(ISO_MOUNTPOINT) && sudo umount -q $(ISO_MOUNTPOINT)) || true
	@echo "$(COLOR_ORANGE)Mounting ISO and extracting contents...$(COLOR_RESET)"
	sudo mount -o ro,loop $(ISO_FILENAME) $(ISO_MOUNTPOINT)
	rsync -av $(ISO_MOUNTPOINT)/. $(ISO_ROOT)/.
	sudo umount $(ISO_MOUNTPOINT)
	@echo "$(COLOR_GREEN)ISO extraction completed$(COLOR_RESET)"

.PHONY: iso_setup
iso_setup: ## Apply custom configuration files to extracted ISO
	@echo "$(COLOR_BLUE)Applying custom configuration files...$(COLOR_RESET)"
	chmod 755 $(ISO_ROOT)
	# Apply GRUB configuration
	@echo "  - Installing GRUB configuration"
	chmod 644 $(GRUBCFG_DEST)
	cp -f $(GRUBCFG_SRC) $(GRUBCFG_DEST)
	# Apply cloud-init configuration
	@echo "  - Installing cloud-init user-data"
	chmod 755 $(ISO_ROOT)
	cp -f $(USERDATA_SRC) $(USERDATA_DEST)
	cp -f $(METADATA_SRC) $(METADATA_DEST)
	# Copy additional files
	@echo "  - Installing additional files"
	rsync -av $(EXTRAS_SRCDIR)/. $(EXTRAS_DESTDIR)/.
	@echo "$(COLOR_GREEN)Configuration setup completed$(COLOR_RESET)"

.PHONY: iso_setup-isolinux
iso_setup-isolinux: ## Apply APU/APU2-specific ISOLINUX bootloader configuration
	@echo "$(COLOR_BLUE)Configuring ISOLINUX for APU/APU2 systems...$(COLOR_RESET)"
	chmod 755 $(ISO_ROOT)
	# Install ISOLINUX dependencies
	sudo apt install isolinux syslinux-common
	# Copy ISOLINUX bootloader
	@echo "  - Installing ISOLINUX bootloader"
	cp $(GENISO_ISOLINUX) $(ISO_ROOT)/
	# Setup ISOLINUX configuration directory
	@echo "  - Setting up ISOLINUX modules and configuration"
	mkdir -p $(ISO_ROOT)/$(ISOLINUX_DIRNAME)
	rsync -av $(GENISO_ISOLINUX_MODULEDIR)/. $(ISO_ROOT)/$(ISOLINUX_DIRNAME)/.
	rsync -av $(ISOLINUX_CONFIGDIR)/. $(ISO_ROOT)/$(ISOLINUX_DIRNAME)/.
	@echo "$(COLOR_GREEN)ISOLINUX configuration completed$(COLOR_RESET)"

.PHONY: iso_geniso
iso_geniso: ## Generate standard GRUB-based ISO image
	@echo "$(COLOR_BLUE)Generating GRUB-based ISO image...$(COLOR_RESET)"
	@echo "Output: $(GENISO_FILENAME)"
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
	@echo "$(COLOR_GREEN)GRUB-based ISO generation completed$(COLOR_RESET)"

.PHONY: iso_geniso-isolinux
iso_geniso-isolinux: ## Generate APU/APU2-optimized ISO with ISOLINUX bootloader
	@echo "$(COLOR_BLUE)Generating APU/APU2-optimized ISO with ISOLINUX...$(COLOR_RESET)"
	@echo "Output: $(GENISO_FILENAME)"
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
	@echo "$(COLOR_GREEN)APU/APU2-optimized ISO generation completed$(COLOR_RESET)"


.PHONY: iso_write_usb
iso_write_usb: ## ⚠️ WARNING: Write latest ISO to USB devices (DESTRUCTIVE!)
	@echo "$(COLOR_RED)$(BLINK)⚠️ WARNING: This command will overwrite USB devices!$(COLOR_RESET)"
	@echo "$(COLOR_ORANGE)Make sure no important data is stored on connected USB devices$(COLOR_RESET)"
	@echo ""
	latest_iso=$$(ls -t $(ISO_FILES)/user-custom-autoinstaller.*.iso | head -n 1); \
	echo "$(COLOR_BLUE)Locating latest ISO file...$(COLOR_RESET)"; \
	if [ -z "$$latest_iso" ]; then \
		echo -e "$(COLOR_RED)No ISO file found. Run 'make iso_geniso-isolinux' first.$(COLOR_RESET)"; \
		exit 1; \
	else \
		echo "$(COLOR_GREEN)Latest ISO file: $(UNDERLINE)$$latest_iso$(COLOR_RESET)"; \
	fi; \
	usb_device=$$(lsblk -npl -o NAME,TYPE | awk '$$2=="disk" && $$1 ~ /^\/dev\/sd[a-z]/ {print $$1}'); \
	if [ -z "$$usb_device" ]; then \
		echo "$(COLOR_RED)No USB devices detected$(COLOR_RESET)"; \
		exit 1; \
	fi; \
	for disk in $$usb_device; do \
		echo "$(COLOR_GRAY)Found USB disk: $(COLOR_GREEN)$$disk$(COLOR_RESET)"; \
		echo "$(COLOR_ORANGE)Writing ISO to $$disk - This may take several minutes...$(COLOR_RESET)"; \
		sudo dd if="$$latest_iso" of="$$disk" bs=4M status=progress; \
		sync; \
		echo "$(COLOR_GREEN)Successfully written to $$disk$(COLOR_RESET)"; \
		echo "$(COLOR_GRAY)--------------------------------------------------------$(COLOR_RESET)"; \
	done; \
	echo "$(COLOR_GREEN)USB writing completed$(COLOR_RESET)"

.PHONY: clean
clean: ## Clean up temporary files and directories
	@echo "$(COLOR_BLUE)Cleaning up temporary files...$(COLOR_RESET)"
	@make iso_clean-up-all
	@echo "$(COLOR_GREEN)Cleanup completed$(COLOR_RESET)"

.PHONY: iso_clean-up-all
iso_clean-up-all: ## Remove all generated files and directories
	@echo "$(COLOR_ORANGE)Removing all generated files and directories...$(COLOR_RESET)"
	sudo rm -rf ${ISO_ROOT}
	sudo rm -rf ${ISO_FILES}
	sudo rm -rf ${ISO_ROOT}.*
	@echo "$(COLOR_GREEN)All files cleaned up$(COLOR_RESET)"

# ================================================
# CHROOT FUNCTIONALITY FOR ADVANCED DEBUGGING
# ================================================

# Chroot function for system debugging
define chroot
	sudo chroot $(ISO_ROOT) $(1)
endef

.PHONY: iso_chroot-shell
iso_chroot-shell: ## Access chroot shell for advanced ISO debugging
	@echo "$(COLOR_BLUE)Entering chroot environment...$(COLOR_RESET)"
	@echo "$(COLOR_ORANGE)Use 'exit' to leave the chroot environment$(COLOR_RESET)"
	sudo mount --bind /dev $(ISO_ROOT)/dev
	sudo mount --bind /proc $(ISO_ROOT)/proc
	sudo mount --bind /sys $(ISO_ROOT)/sys
	$(call chroot,/bin/bash)
	sudo umount $(ISO_ROOT)/dev
	sudo umount $(ISO_ROOT)/proc
	sudo umount $(ISO_ROOT)/sys
	@echo "$(COLOR_GREEN)Chroot session ended$(COLOR_RESET)"

