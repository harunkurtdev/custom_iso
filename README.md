# Custom ISO Builder for Ubuntu Server Automation

## 🎯 Project Overview

This project enables automated creation of customized Ubuntu 22.04 Server ISO images optimized for rapid deployment on embedded systems, particularly UP2 boards and APU/APU2 industrial computers.

### Key Features

- **Automated Installation**: Pre-configured settings for fully automated server deployments
- **Dual Deployment Methods**: Choose between ISO-based or Docker server-based installation
- **APU/APU2 Optimization**: Specifically configured for industrial embedded systems
- **Network Boot Support**: HTTP-based configuration delivery for dynamic updates
- **Minimal User Intervention**: One-time setup for multiple deployments

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    CUSTOM ISO BUILDER                      │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐         ┌─────────────────────────┐    │
│  │  ISO EDITOR     │         │    DOCKER SERVER       │    │
│  │  - Ubuntu Base  │         │  - HTTP Server          │    │
│  │  - GRUB Config  │         │  - Network: 172.20.0.0 │    │
│  │  - User Data    │         │  - Port: 3003           │    │
│  │  - Meta Data    │         │  - Real-time Updates    │    │
│  └─────────────────┘         └─────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

The system operates under the assumption that you have a customized ISO file on USB media. The `grub.cfg` file controls the boot menu selection during installation, defaulting to network-based configuration via the Docker server for maximum flexibility.

## 📖 Installation Methods

### Method 1: ISO-Based Installation

**Direct installation using embedded `pressed/user-data` configuration**

This method modifies the Ubuntu 22.04 Server ISO to include pre-configured installation parameters. The GRUB bootloader is configured to automatically locate and use the embedded user-data file, enabling completely automated installations.

**Advantages:**
- Offline installation capability
- Self-contained deployment medium
- No network dependencies during installation
- Portable via USB media

**Use Cases:**
- Remote locations without reliable network connectivity
- Security-sensitive environments requiring air-gapped installations
- Field deployments where network infrastructure is unavailable

### Method 2: Docker Server-Based Installation

**Dynamic configuration delivery via HTTP server**

The initial ISO contains a fixed `grub.cfg` that points to a network-based configuration server. During installation, the target system downloads current configuration files from the Docker server, allowing for real-time updates without recreating ISO images.

**Advantages:**
- Dynamic configuration updates
- Centralized management of multiple deployments
- Real-time customization based on target system requirements
- Reduced ISO recreation overhead

**Network Configuration:**
- Docker subnet: `172.20.0.0/24`
- Server IP: `172.20.0.2`
- Service port: `3003`

**Use Cases:**
- Large-scale deployments requiring consistent updates
- Development environments with frequent configuration changes
- Centralized IT management scenarios

## 🔧 Configuration Reference

### Cloud-Init User-Data Structure

The configuration system uses Ubuntu's Subiquity autoinstall format, based on cloud-init user-data specifications. Below is the essential structure:

```yaml
version: 1
early-commands:
  - echo "Starting pre-installation setup"
  - sleep 1
  - echo "System initialization complete"
packages:
  - openssh-server
  - curl
  - wget
  - git
late-commands:
  - echo "Finalizing installation"
  - systemctl enable ssh
  - echo "Post-installation tasks complete"
keyboard:
  layout: us
source:
  id: ubuntu-server-minimal
updates: security
identity:
  hostname: ubuntu-server
  username: ubuntu
  password: '$6$wdAcoXrU039hKYPd$508Qvbe7ObUnxoj15DRCkzC3qO7edjH0VV7BPNRDYK4QR8ofJaEEF2heacn0QgD.f8pO8SNp83XNdWG6tocBM1'
```

### Configuration Sections Explained

- **early-commands**: Scripts executed at the start of installation, before partitioning
- **packages**: Additional software packages to install during system setup
- **late-commands**: Final scripts executed after system installation but before reboot
- **identity**: User account configuration (required in all configurations)
- **keyboard**: Input method and layout specifications
- **source**: Ubuntu installation source variant selection

**Reference Documentation**: [Canonical Subiquity Examples](https://github.com/canonical/subiquity/tree/main/examples/autoinstall)

### Password Generation

Secure password hashes are required for user account creation. Use these commands to generate properly formatted passwords:

```bash
# Generate password hash for string "ubuntu"
openssl passwd -6 -salt $(openssl rand -hex 8) "ubuntu"

# Generate password hash for numeric password
openssl passwd -6 -salt $(openssl rand -hex 8) "1"
```

## 🚀 Automated ISO Creation Workflow

The build process is fully automated through Makefile targets, optimized for APU/APU2 system compatibility. These industrial-grade embedded systems feature high clock speeds and multi-core architectures, requiring specific bootloader configurations.

### Build Commands Overview

**System Preparation:**
- `make iso_depends` - Install required system dependencies and tools
- `make iso_download` - Download Ubuntu 22.04 Server ISO from official repository  
- `make iso_init` - Extract ISO contents to working directory (`iso_root`)

**Configuration Integration:**
- `make iso_setup` - Integrate custom configuration files from `config/` directory
- `make iso_setup-isolinux` - Apply APU/APU2-specific ISOLINUX bootloader configuration

**ISO Generation:**
- `make iso_geniso` - Create standard GRUB-based ISO image
- `make iso_geniso-isolinux` - Generate APU/APU2-optimized ISO with ISOLINUX bootloader

**Deployment:**
- `make iso_write_usb` - Automatically write latest ISO to connected USB devices

**⚠️ WARNING**: `make iso_write_usb` will overwrite USB devices automatically. Ensure no important data is stored on connected USB drives.

![USB Writing Process](./images/iso_write_usb_hub.jpg)

### Complete Build Process

For first-time setup, execute the following sequence:

```bash
# Initial system preparation
make iso_depends
make iso_download  
make iso_init

# Configuration and customization
make iso_setup
make iso_setup-isolinux

# Generate final ISO image
make iso_geniso-isolinux
```

Upon successful completion without errors:

```bash
# Deploy to USB media
make iso_write_usb
```

### APU/APU2 System Optimization

Intel APU systems typically feature higher clock speeds and more CPU cores compared to AMD alternatives, providing superior computational performance. The ISOLINUX bootloader configuration ensures optimal compatibility with these industrial embedded systems.

Configuration automatically includes:
- High-performance CPU scheduling parameters
- Optimized memory management for embedded systems  
- Hardware-specific driver selection
- Power management tuning for industrial environments

## 🌐 Docker Server Deployment

The Docker server provides dynamic configuration delivery during installation, enabling centralized management of multiple system deployments.

![Network Sharing Setup](./images/share_internet_for_up2.jpg)
*Network topology for Docker server deployment*

### Server Setup Process

Connect your development machine to the network infrastructure (router/switch), then build and launch the configuration server:

```bash
# Build Docker server image
make iso_server_build

# Launch configuration server
make iso_server_run
```

### Network Configuration

The server automatically configures the following network parameters:

- **Server IP Address**: `172.20.0.2`
- **Service Port**: `3003` (no conflicts with host system ports)
- **Network Subnet**: `172.20.0.0/24`

No manual network configuration is required. Once the development machine connects to the switch/router, target systems will automatically locate and use the configuration server during installation.

### Server Management

**Access server shell for debugging or monitoring:**
```bash
make iso_server_shell
```

**Server features:**
- Automatic service discovery for target systems
- Real-time configuration updates without ISO recreation
- Centralized logging of installation progress
- Support for multiple concurrent installations

### Installation Flow

1. Target system boots from custom ISO media
2. GRUB configuration automatically detects network server
3. Installation system downloads current configuration files
4. Automated installation proceeds with latest settings
5. Server logs installation progress and completion status

This approach eliminates the need to recreate ISO images for configuration changes, significantly improving deployment efficiency in dynamic environments.