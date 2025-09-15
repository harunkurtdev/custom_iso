# Example Configurations for Custom ISO Builder

This directory contains example configurations and usage scenarios for different hardware types and deployment methods.

## Quick Start Examples

### 1. Build ISO for Intel UP² Board

```bash
# Download Ubuntu Server and build custom ISO
make build-all HARDWARE_TYPE=up2

# Write to USB drive
make write-usb USB_DEVICE=/dev/sdX
```

### 2. Network Installation for APU2

```bash
# Start HTTP configuration server
make run-server &

# Boot target system and use these kernel parameters:
# autoinstall ds=nocloud-net;s=http://SERVER_IP:8080/?hw=apu2
```

### 3. Local Installation with Embedded Config

```bash
# Build ISO with embedded configuration
make build-all HARDWARE_TYPE=apu

# Write to USB and boot target system
make write-usb USB_DEVICE=/dev/sdb
```

## Advanced Examples

### Custom SSH Keys

Edit the user-data file to include your SSH public keys:

```yaml
ssh:
  install-server: true
  allow-pw: false  # Disable password auth
  authorized-keys:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... your-key-here
    - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... another-key
```

### Custom Network Configuration

For static IP configuration, modify the network section:

```yaml
network:
  ethernets:
    enp1s0:
      dhcp4: false
      addresses: [192.168.1.100/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
```

### Additional Packages

Add packages to the autoinstall configuration:

```yaml
packages:
  - docker.io
  - nginx
  - postgresql
  - prometheus
  - grafana
```

### Custom Post-Install Scripts

Add custom setup in late-commands:

```yaml
late-commands:
  # Install custom application
  - wget -O /target/tmp/myapp.deb https://example.com/myapp.deb
  - curtin in-target --target=/target -- dpkg -i /tmp/myapp.deb
  
  # Configure custom service
  - echo 'custom-service start' >> /target/etc/rc.local
```

## Hardware-Specific Examples

### UP² Board for IoT Development

Includes:
- GPIO and I2C libraries
- Python development environment
- Docker for containerized applications
- Node.js for IoT services

### APU Router Configuration

Includes:
- Multiple ethernet interfaces
- Basic firewall (iptables/ufw)
- DHCP server (dnsmasq)
- VPN capabilities

### APU2 Advanced Networking

Includes:
- Advanced routing protocols
- Load balancing (HAProxy)
- Monitoring stack (Prometheus/Grafana)
- Container orchestration

## Deployment Scenarios

### 1. Factory Provisioning

For mass deployment in factory settings:

```bash
# Automated USB writing script
#!/bin/bash
while true; do
    USB_DEVICE=$(lsblk -d -o NAME,TYPE | grep disk | head -1 | cut -d' ' -f1)
    if [ -n "$USB_DEVICE" ]; then
        make write-usb USB_DEVICE=/dev/$USB_DEVICE
        echo "Remove USB drive and insert next one..."
        sleep 5
    fi
done
```

### 2. Remote Deployment

For remote installation over network:

```bash
# Start PXE server with custom ISO
make run-server
# Configure DHCP to point to HTTP server for autoinstall configs
```

### 3. Development Environment

For repeated development deployments:

```bash
# Quick rebuild and test cycle
make clean && make build-all HARDWARE_TYPE=up2
# Test in VM or write to development board
```

## Troubleshooting Examples

### Debug Installation

Boot with additional debug parameters:

```
autoinstall ds=nocloud-net;s=http://SERVER_IP:8080/ debug cloud-init-debug
```

### Check Hardware Detection

View detected hardware during installation:

```bash
# In emergency shell during install
lshw -short
lsblk
ip addr show
```

### Validate Configuration

Test configuration server responses:

```bash
# Test configuration endpoints
curl http://SERVER_IP:8080/meta-data
curl http://SERVER_IP:8080/user-data?hw=up2
curl http://SERVER_IP:8080/configs/
```