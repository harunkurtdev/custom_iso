# Hardware Configuration Templates
# These templates provide hardware-specific configurations for autoinstall

## Intel UP² Board (up2)
- **Hardware**: Intel Atom x7-E3950 Quad-core 1.6GHz
- **RAM**: 8GB LPDDR4
- **Storage**: eMMC/SSD
- **Network**: 2x Gigabit Ethernet
- **Features**: GPIO, I2C, SPI, USB 3.0
- **Use cases**: IoT development, edge computing, embedded systems

### Configuration highlights:
- Optimized for embedded development
- GPIO and I2C interfaces enabled
- Performance CPU governor
- Development tools pre-installed
- Docker support

## PC Engines APU (apu)
- **Hardware**: AMD GX-412TC SOC
- **RAM**: 2-4GB DDR3
- **Storage**: mSATA SSD
- **Network**: 3x Gigabit Ethernet
- **Features**: Serial console, hardware watchdog
- **Use cases**: Router, firewall, VPN appliance

### Configuration highlights:
- Minimal package selection for resource efficiency
- Serial console configured (115200 baud)
- Conservative CPU governor for power saving
- Basic firewall and routing tools
- Network optimized configuration

## PC Engines APU2 (apu2)
- **Hardware**: AMD GX-412TC SOC (Enhanced)
- **RAM**: 4GB DDR3
- **Storage**: mSATA SSD
- **Network**: 3x Gigabit Ethernet + WiFi capable
- **Features**: Serial console, hardware watchdog, GPIO, I2C
- **Use cases**: Advanced router, VPN server, monitoring appliance

### Configuration highlights:
- Advanced networking tools
- WiFi support for additional connectivity
- Hardware monitoring and metrics
- Docker and container support
- Prometheus node exporter enabled
- Advanced routing protocols (BGP, OSPF)

## Configuration Selection

The system automatically selects the appropriate configuration based on the `HARDWARE_TYPE` parameter:

```bash
# For Intel UP² board
make build-all HARDWARE_TYPE=up2

# For PC Engines APU
make build-all HARDWARE_TYPE=apu

# For PC Engines APU2
make build-all HARDWARE_TYPE=apu2
```

## Network Installation

For network-based installations, the Docker HTTP server provides dynamic configuration:

```bash
# Start the configuration server
make run-server

# Use in installer boot parameters
ds=nocloud-net;s=http://SERVER_IP:8080/?hw=HARDWARE_TYPE
```

## Customization

To create custom configurations:

1. Copy an existing template from `configs/autoinstall/`
2. Modify packages, network settings, and late commands
3. Update the Makefile to reference your new configuration
4. Test with `make build-all HARDWARE_TYPE=your_config`