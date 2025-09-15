# Ubuntu Server Custom ISO Builder

Automates and accelerates Ubuntu Server installations for Intel UP² and PC Engines APU/APU2 hardware by providing custom ISO images and a Docker-based server for dynamic configuration. Features include rapid deployment, cloud-init autoinstall scripts, HTTP configuration delivery, and Makefile automation for building, customizing, and writing ISO files to USB drives.

## Features

- 🚀 **Automated ISO Customization**: Build custom Ubuntu Server ISOs with embedded autoinstall configurations
- 🔧 **Hardware-Specific Configs**: Optimized configurations for Intel UP², PC Engines APU, and APU2 boards
- 🌐 **Network Installation**: Docker-based HTTP server for dynamic configuration delivery
- 📦 **Makefile Automation**: Complete workflow automation from download to USB writing
- 🔌 **Local & Network Support**: Both embedded and network-based installation methods
- ⚡ **Fast Deployment**: Unattended installation reduces setup time from hours to minutes

## Supported Hardware

| Hardware | CPU | RAM | Network | Use Cases |
|----------|-----|-----|---------|-----------|
| **Intel UP²** | Intel Atom x7-E3950 | 8GB LPDDR4 | 2x GbE | IoT development, edge computing |
| **PC Engines APU** | AMD GX-412TC SOC | 2-4GB DDR3 | 3x GbE | Router, firewall, VPN appliance |
| **PC Engines APU2** | AMD GX-412TC SOC+ | 4GB DDR3 | 3x GbE + WiFi | Advanced networking, monitoring |

## Quick Start

### 1. Setup Environment

```bash
# Clone repository
git clone https://github.com/harunkurtdev/custom_iso.git
cd custom_iso

# Install dependencies (Ubuntu/Debian)
./scripts/setup.sh

# Validate setup
./scripts/validate.sh
```

### 2. Build Custom ISO

```bash
# Build ISO for Intel UP² board
make build-all HARDWARE_TYPE=up2

# Build ISO for PC Engines APU2
make build-all HARDWARE_TYPE=apu2

# Build ISO for PC Engines APU
make build-all HARDWARE_TYPE=apu
```

### 3. Deploy

**Option A: USB Installation**
```bash
# Write to USB drive (replace /dev/sdX with your device)
make write-usb USB_DEVICE=/dev/sdX
```

**Option B: Network Installation**
```bash
# Start HTTP configuration server
make run-server

# Use in target system boot parameters:
# autoinstall ds=nocloud-net;s=http://SERVER_IP:8080/?hw=HARDWARE_TYPE
```

## Project Structure

```
custom_iso/
├── Makefile                    # Main automation
├── configs/
│   ├── autoinstall/           # Cloud-init configurations
│   │   ├── up2-user-data      # Intel UP² config
│   │   ├── apu-user-data      # PC Engines APU config
│   │   ├── apu2-user-data     # PC Engines APU2 config
│   │   ├── user-data          # Default config
│   │   └── meta-data          # Cloud-init metadata
│   └── hardware/              # Hardware documentation
├── docker/                    # HTTP server for network installs
│   ├── Dockerfile
│   ├── nginx.conf
│   └── server.sh
├── scripts/                   # Helper scripts
│   ├── setup.sh              # Environment setup
│   └── validate.sh           # Configuration validation
└── examples/                  # Usage examples and templates
```

## Configuration

### Hardware-Specific Features

**Intel UP² (up2)**:
- GPIO and I2C interfaces enabled
- Development tools (Python, Node.js, Docker)
- Performance-optimized CPU governor
- Hardware monitoring tools

**PC Engines APU (apu)**:
- Serial console configured (115200 baud)
- Minimal package selection for efficiency
- Basic router/firewall tools
- Power-saving CPU governor

**PC Engines APU2 (apu2)**:
- Advanced networking tools (VPN, load balancing)
- WiFi support capability
- Hardware monitoring with Prometheus
- Container orchestration support

### Customization

1. **SSH Keys**: Edit autoinstall configs to add your public keys
2. **Network Settings**: Modify network configuration for static IPs
3. **Packages**: Add/remove packages in the autoinstall files
4. **Post-Install**: Add custom commands in `late-commands` section

Example SSH key configuration:
```yaml
ssh:
  install-server: true
  allow-pw: false
  authorized-keys:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... your-key-here
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `help` | Show available targets and usage |
| `download` | Download Ubuntu Server ISO |
| `extract` | Extract ISO contents |
| `customize` | Apply hardware-specific configurations |
| `build-iso` | Build custom ISO image |
| `build-docker` | Build HTTP server Docker image |
| `run-server` | Start configuration server |
| `build-all` | Complete build process |
| `write-usb` | Write ISO to USB drive |
| `validate-iso` | Verify ISO integrity |
| `list-usb` | Show available USB devices |
| `clean` | Clean build artifacts |
| `clean-all` | Clean everything including downloads |

## Network Installation

The Docker-based HTTP server provides dynamic configuration serving:

```bash
# Start server
make run-server

# Available endpoints:
# http://SERVER_IP:8080/meta-data
# http://SERVER_IP:8080/user-data?hw=HARDWARE_TYPE
# http://SERVER_IP:8080/configs/
```

Boot target system with:
```
autoinstall ds=nocloud-net;s=http://SERVER_IP:8080/?hw=up2
```

## Examples

### Development Workflow

```bash
# Build and test cycle
make clean
make build-all HARDWARE_TYPE=up2
make validate-iso

# Quick USB deployment
make write-usb USB_DEVICE=/dev/sdb
```

### Production Deployment

```bash
# Network-based deployment
make run-server &

# Multiple systems can install simultaneously
# using the same configuration server
```

### Custom Configuration

```bash
# Copy existing config as template
cp configs/autoinstall/up2-user-data configs/autoinstall/my-custom.yaml

# Edit configuration
vim configs/autoinstall/my-custom.yaml

# Update Makefile to use custom config
# Build with custom configuration
make build-all HARDWARE_TYPE=my-custom
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure user is in docker group
2. **USB Write Fails**: Check device path with `make list-usb`
3. **Network Install**: Verify server IP and firewall settings
4. **Build Errors**: Run `./scripts/validate.sh` to check setup

### Debug Installation

Boot with debug parameters:
```
autoinstall ds=nocloud-net;s=http://SERVER_IP:8080/ debug cloud-init-debug
```

### Check Logs

```bash
# View server logs
docker logs ubuntu-autoinstall-server

# Validate configuration files
./scripts/validate.sh
```

## Requirements

- Linux host system (Ubuntu, Debian, Fedora, Arch)
- 4GB+ free disk space
- Docker and Docker Compose
- xorriso, isolinux/syslinux
- wget/curl, git, make

## Security Notes

- Default password is "ubuntu" - **CHANGE IN PRODUCTION**
- SSH password authentication enabled by default
- Add your SSH public keys for secure access
- Configure firewall rules for production use

## Contributing

1. Fork the repository
2. Create feature branch
3. Test with `./scripts/validate.sh`
4. Submit pull request

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

## Support

- Hardware compatibility questions
- Configuration customization help
- Deployment automation assistance

For issues and feature requests, please use the GitHub issue tracker.
