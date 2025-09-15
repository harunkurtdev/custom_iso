# Ubuntu Server Custom ISO Builder for up2 squared and APU/APU2 hardware
# Automates ISO customization, configuration serving, and USB writing

# Configuration
UBUNTU_VERSION ?= 22.04.3
UBUNTU_ISO_URL ?= https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso
ISO_NAME ?= ubuntu-22.04.3-live-server-amd64.iso
CUSTOM_ISO_NAME ?= ubuntu-custom-autoinstall.iso
BUILD_DIR ?= build
DOWNLOADS_DIR ?= downloads
MNT_DIR ?= mnt
DOCKER_IMAGE ?= ubuntu-autoinstall-server
DOCKER_PORT ?= 8080
SERVER_IP ?= $(shell ip route get 1.1.1.1 | grep -oP 'src \K\S+')

# Hardware configurations
HARDWARE_TYPE ?= up2
VALID_HARDWARE := up2 apu apu2

# Default target
.PHONY: help
help:
	@echo "Ubuntu Server Custom ISO Builder"
	@echo "================================"
	@echo ""
	@echo "Available targets:"
	@echo "  download      - Download Ubuntu Server ISO"
	@echo "  extract       - Extract ISO contents"
	@echo "  customize     - Customize ISO with autoinstall configs"
	@echo "  build-iso     - Build custom ISO image"
	@echo "  build-docker  - Build Docker HTTP server image"
	@echo "  run-server    - Run HTTP server for network installations"
	@echo "  build-all     - Complete build process (download + customize + build)"
	@echo "  write-usb     - Write ISO to USB drive (requires USB_DEVICE)"
	@echo "  clean         - Clean build artifacts"
	@echo "  clean-all     - Clean everything including downloads"
	@echo ""
	@echo "Hardware configurations (set HARDWARE_TYPE):"
	@echo "  up2          - Intel UP² board configuration"
	@echo "  apu          - PC Engines APU configuration"
	@echo "  apu2         - PC Engines APU2 configuration"
	@echo ""
	@echo "Example usage:"
	@echo "  make build-all HARDWARE_TYPE=up2"
	@echo "  make run-server"
	@echo "  make write-usb USB_DEVICE=/dev/sdX"

# Validate hardware type
.PHONY: validate-hardware
validate-hardware:
	@if [ -z "$(HARDWARE_TYPE)" ]; then \
		echo "Error: HARDWARE_TYPE not set. Use: $(VALID_HARDWARE)"; \
		exit 1; \
	fi
	@if ! echo "$(VALID_HARDWARE)" | grep -wq "$(HARDWARE_TYPE)"; then \
		echo "Error: Invalid HARDWARE_TYPE '$(HARDWARE_TYPE)'. Valid options: $(VALID_HARDWARE)"; \
		exit 1; \
	fi
	@echo "Building for hardware: $(HARDWARE_TYPE)"

# Create necessary directories
.PHONY: setup-dirs
setup-dirs:
	@mkdir -p $(BUILD_DIR) $(DOWNLOADS_DIR) $(MNT_DIR)

# Download Ubuntu Server ISO
.PHONY: download
download: setup-dirs
	@echo "Downloading Ubuntu Server $(UBUNTU_VERSION)..."
	@if [ ! -f $(DOWNLOADS_DIR)/$(ISO_NAME) ]; then \
		wget -O $(DOWNLOADS_DIR)/$(ISO_NAME) $(UBUNTU_ISO_URL) || \
		curl -L -o $(DOWNLOADS_DIR)/$(ISO_NAME) $(UBUNTU_ISO_URL); \
	else \
		echo "ISO already downloaded: $(DOWNLOADS_DIR)/$(ISO_NAME)"; \
	fi

# Extract ISO contents
.PHONY: extract
extract: download
	@echo "Extracting ISO contents..."
	@sudo umount $(MNT_DIR) 2>/dev/null || true
	@sudo mount -o loop $(DOWNLOADS_DIR)/$(ISO_NAME) $(MNT_DIR)
	@rm -rf $(BUILD_DIR)/iso
	@mkdir -p $(BUILD_DIR)/iso
	@cp -rT $(MNT_DIR) $(BUILD_DIR)/iso
	@sudo umount $(MNT_DIR)
	@chmod -R +w $(BUILD_DIR)/iso

# Customize ISO with autoinstall configuration
.PHONY: customize
customize: extract validate-hardware
	@echo "Customizing ISO for $(HARDWARE_TYPE) hardware..."
	@# Copy autoinstall configuration
	@mkdir -p $(BUILD_DIR)/iso/autoinstall
	@cp configs/autoinstall/$(HARDWARE_TYPE)-user-data $(BUILD_DIR)/iso/autoinstall/user-data
	@cp configs/autoinstall/meta-data $(BUILD_DIR)/iso/autoinstall/meta-data
	@# Update grub configuration for autoinstall
	@sed -i 's|---|autoinstall ds=nocloud-net;s=http://$(SERVER_IP):$(DOCKER_PORT)/ ---|g' \
		$(BUILD_DIR)/iso/boot/grub/grub.cfg || \
	sed -i 's|---|autoinstall ds=nocloud\\;s=/cdrom/autoinstall/ ---|g' \
		$(BUILD_DIR)/iso/boot/grub/grub.cfg
	@# Update isolinux configuration
	@if [ -f $(BUILD_DIR)/iso/isolinux/txt.cfg ]; then \
		sed -i 's|---|autoinstall ds=nocloud\\;s=/cdrom/autoinstall/ ---|g' \
			$(BUILD_DIR)/iso/isolinux/txt.cfg; \
	fi
	@echo "ISO customized for $(HARDWARE_TYPE)"

# Build custom ISO
.PHONY: build-iso
build-iso: customize
	@echo "Building custom ISO..."
	@cd $(BUILD_DIR)/iso && \
	xorriso -as mkisofs \
		-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
		-c isolinux/boot.cat \
		-b isolinux/isolinux.bin \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		-eltorito-alt-boot \
		-e boot/grub/efi.img \
		-no-emul-boot \
		-isohybrid-gpt-basdat \
		-o ../$(CUSTOM_ISO_NAME) \
		.
	@echo "Custom ISO created: $(BUILD_DIR)/$(CUSTOM_ISO_NAME)"

# Build Docker image for HTTP server
.PHONY: build-docker
build-docker:
	@echo "Building Docker image for HTTP server..."
	@docker build -t $(DOCKER_IMAGE) docker/

# Run HTTP server for network installations
.PHONY: run-server
run-server: build-docker
	@echo "Starting HTTP server on port $(DOCKER_PORT)..."
	@echo "Server will be available at: http://$(SERVER_IP):$(DOCKER_PORT)"
	@docker run --rm -p $(DOCKER_PORT):80 \
		-v $(PWD)/configs:/app/configs:ro \
		--name $(DOCKER_IMAGE) \
		$(DOCKER_IMAGE)

# Complete build process
.PHONY: build-all
build-all: validate-hardware download customize build-iso
	@echo "Build complete!"
	@echo "Custom ISO: $(BUILD_DIR)/$(CUSTOM_ISO_NAME)"
	@echo "Hardware configuration: $(HARDWARE_TYPE)"

# Write ISO to USB drive
.PHONY: write-usb
write-usb:
	@if [ -z "$(USB_DEVICE)" ]; then \
		echo "Error: USB_DEVICE not specified. Use: make write-usb USB_DEVICE=/dev/sdX"; \
		echo "Available devices:"; \
		lsblk -d -o NAME,SIZE,TYPE | grep disk; \
		exit 1; \
	fi
	@if [ ! -f $(BUILD_DIR)/$(CUSTOM_ISO_NAME) ]; then \
		echo "Error: Custom ISO not found. Run 'make build-all' first."; \
		exit 1; \
	fi
	@echo "WARNING: This will overwrite $(USB_DEVICE)"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	@echo "Writing ISO to $(USB_DEVICE)..."
	@sudo dd if=$(BUILD_DIR)/$(CUSTOM_ISO_NAME) of=$(USB_DEVICE) bs=4M status=progress oflag=sync
	@sync
	@echo "USB drive written successfully"

# Check USB devices
.PHONY: list-usb
list-usb:
	@echo "Available block devices:"
	@lsblk -d -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E "(NAME|disk)"

# Validate ISO integrity
.PHONY: validate-iso
validate-iso:
	@if [ ! -f $(BUILD_DIR)/$(CUSTOM_ISO_NAME) ]; then \
		echo "Error: Custom ISO not found"; \
		exit 1; \
	fi
	@echo "Validating ISO integrity..."
	@file $(BUILD_DIR)/$(CUSTOM_ISO_NAME)
	@echo "ISO size: $$(du -h $(BUILD_DIR)/$(CUSTOM_ISO_NAME) | cut -f1)"

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR) $(MNT_DIR)
	@docker stop $(DOCKER_IMAGE) 2>/dev/null || true

# Clean everything including downloads
.PHONY: clean-all
clean-all: clean
	@echo "Cleaning downloads..."
	@rm -rf $(DOWNLOADS_DIR)
	@docker rmi $(DOCKER_IMAGE) 2>/dev/null || true

# Development helpers
.PHONY: shell
shell:
	@docker run --rm -it \
		-v $(PWD)/configs:/app/configs \
		-p $(DOCKER_PORT):80 \
		$(DOCKER_IMAGE) /bin/bash

.PHONY: debug-grub
debug-grub:
	@if [ -f $(BUILD_DIR)/iso/boot/grub/grub.cfg ]; then \
		echo "Current GRUB configuration:"; \
		grep -A 5 -B 5 "autoinstall\|ds=" $(BUILD_DIR)/iso/boot/grub/grub.cfg || true; \
	fi

# Install required dependencies (Ubuntu/Debian)
.PHONY: install-deps
install-deps:
	@echo "Installing required dependencies..."
	@sudo apt-get update
	@sudo apt-get install -y \
		xorriso \
		isolinux \
		wget \
		curl \
		docker.io
	@sudo systemctl enable docker
	@sudo systemctl start docker
	@sudo usermod -aG docker $$USER
	@echo "Dependencies installed. You may need to log out and back in for Docker permissions."