# Configuration Examples and Templates

This document provides ready-to-use configuration templates for various deployment scenarios. Each example includes complete user-data configurations optimized for specific use cases.

## 🖥️ Development Environment

Complete development setup with essential tools and services for software development teams.

```yaml
#cloud-config
autoinstall:
  version: 1
  early-commands:
    - echo "Initializing development environment setup"
    - systemctl stop unattended-upgrades
  packages:
    - build-essential
    - git
    - curl
    - wget
    - vim
    - htop
    - tree
    - docker.io
    - docker-compose
    - nodejs
    - npm
    - python3
    - python3-pip
    - openssh-server
  late-commands:
    - echo "Configuring development tools"
    - usermod -aG docker ubuntu
    - systemctl enable docker
    - systemctl enable ssh
    - pip3 install virtualenv
    - npm install -g @angular/cli
    - echo "Development environment ready"
  keyboard:
    layout: us
  source:
    id: ubuntu-server
  updates: security
  identity:
    hostname: dev-server
    username: developer
    password: '$6$rounds=4096$saltsalt$...'
  storage:
    layout:
      name: lvm
  network:
    network:
      version: 2
      ethernets:
        enp0s3:
          dhcp4: true
```

## 🏭 Production Server

Hardened server configuration with security optimizations and monitoring.

```yaml
#cloud-config
autoinstall:
  version: 1
  early-commands:
    - echo "Setting up production server with security hardening"
    - systemctl stop unattended-upgrades
  packages:
    - openssh-server
    - ufw
    - fail2ban
    - logrotate
    - rsyslog
    - chrony
    - unattended-upgrades
    - apt-listchanges
  late-commands:
    - echo "Applying security hardening"
    - ufw --force enable
    - ufw default deny incoming
    - ufw allow 22/tcp
    - systemctl enable fail2ban
    - systemctl enable chrony
    - sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    - systemctl restart ssh
    - echo "Production server secured"
  keyboard:
    layout: us
  source:
    id: ubuntu-server-minimal
  updates: all
  identity:
    hostname: prod-server
    username: admin
    password: '$6$rounds=4096$saltsalt$...'
  storage:
    layout:
      name: lvm
    config:
      - type: disk
        id: disk0
        size: largest
      - type: partition
        id: boot
        device: disk0
        size: 1G
        flag: boot
      - type: partition
        id: root
        device: disk0
        size: -1
```

## 🌐 IoT/Edge Device

Minimal footprint configuration for resource-constrained environments.

```yaml
#cloud-config
autoinstall:
  version: 1
  early-commands:
    - echo "Configuring minimal IoT/Edge system"
  packages:
    - openssh-server
    - curl
    - wget
    - nano
  late-commands:
    - echo "Optimizing for edge deployment"
    - systemctl disable snapd
    - apt-get autoremove --purge -y snapd
    - systemctl mask systemd-resolved
    - echo "nameserver 8.8.8.8" > /etc/resolv.conf
    - systemctl enable ssh
    - echo "IoT system optimized"
  keyboard:
    layout: us
  source:
    id: ubuntu-server-minimal
  updates: security
  identity:
    hostname: iot-device
    username: iot
    password: '$6$rounds=4096$saltsalt$...'
  storage:
    layout:
      name: direct
    config:
      - type: disk
        id: disk0
        size: largest
      - type: partition
        id: root
        device: disk0
        size: -1
        format: ext4
        mount: /
```

## ☸️ Kubernetes Node

Container orchestration node with Docker and Kubernetes components.

```yaml
#cloud-config
autoinstall:
  version: 1
  early-commands:
    - echo "Preparing Kubernetes node setup"
    - systemctl stop unattended-upgrades
  packages:
    - docker.io
    - curl
    - apt-transport-https
    - ca-certificates
    - gnupg
    - lsb-release
    - openssh-server
  late-commands:
    - echo "Installing Kubernetes components"
    - usermod -aG docker ubuntu
    - systemctl enable docker
    - curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    - echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
    - apt-get update
    - apt-get install -y kubelet kubeadm kubectl
    - apt-mark hold kubelet kubeadm kubectl
    - systemctl enable kubelet
    - echo "Kubernetes node ready for cluster join"
  keyboard:
    layout: us
  source:
    id: ubuntu-server
  updates: security
  identity:
    hostname: k8s-node
    username: kubernetes
    password: '$6$rounds=4096$saltsalt$...'
```

## 🗄️ Database Server

Optimized database server with backup automation and monitoring.

```yaml
#cloud-config
autoinstall:
  version: 1
  early-commands:
    - echo "Setting up database server environment"
  packages:
    - mysql-server
    - redis-server
    - postgresql
    - postgresql-contrib
    - openssh-server
    - cron
    - logrotate
  late-commands:
    - echo "Configuring database services"
    - systemctl enable mysql
    - systemctl enable redis-server
    - systemctl enable postgresql
    - mysql_secure_installation
    - echo "Setting up automated backups"
    - mkdir -p /opt/backups
    - echo "0 2 * * * root mysqldump --all-databases > /opt/backups/mysql-$(date +%Y%m%d).sql" >> /etc/crontab
    - echo "Database server configured"
  keyboard:
    layout: us
  source:
    id: ubuntu-server
  updates: security
  identity:
    hostname: db-server
    username: dbadmin
    password: '$6$rounds=4096$saltsalt$...'
  storage:
    layout:
      name: lvm
    config:
      - type: disk
        id: disk0
        size: largest
      - type: partition
        id: boot
        device: disk0
        size: 1G
      - type: partition
        id: data
        device: disk0
        size: 50G
        format: ext4
        mount: /var/lib/mysql
      - type: partition
        id: backup
        device: disk0
        size: -1
        format: ext4
        mount: /opt/backups
```

## 🌍 Web Server

NGINX web server with SSL/TLS support and security hardening.

```yaml
#cloud-config
autoinstall:
  version: 1
  early-commands:
    - echo "Configuring web server setup"
  packages:
    - nginx
    - certbot
    - python3-certbot-nginx
    - ufw
    - openssh-server
    - php8.1-fpm
    - php8.1-mysql
    - php8.1-cli
  late-commands:
    - echo "Setting up web server"
    - systemctl enable nginx
    - systemctl enable php8.1-fpm
    - ufw --force enable
    - ufw allow 'Nginx Full'
    - ufw allow 22/tcp
    - mkdir -p /var/www/html
    - chown -R www-data:www-data /var/www/html
    - echo "Web server ready for deployment"
  keyboard:
    layout: us
  source:
    id: ubuntu-server
  updates: security
  identity:
    hostname: web-server
    username: webadmin
    password: '$6$rounds=4096$saltsalt$...'
```

## 📊 Monitoring Server

Comprehensive monitoring stack with Prometheus, Grafana, and log aggregation.

```yaml
#cloud-config
autoinstall:
  version: 1
  early-commands:
    - echo "Setting up monitoring infrastructure"
  packages:
    - docker.io
    - docker-compose
    - openssh-server
    - curl
    - wget
  late-commands:
    - echo "Installing monitoring stack"
    - usermod -aG docker ubuntu
    - systemctl enable docker
    - mkdir -p /opt/monitoring
    - cd /opt/monitoring
    - wget https://raw.githubusercontent.com/prometheus/prometheus/main/docker-compose.yml
    - echo "Creating Grafana configuration"
    - mkdir -p grafana/provisioning/{dashboards,datasources}
    - echo "Monitoring stack ready for configuration"
  keyboard:
    layout: us
  source:
    id: ubuntu-server
  updates: security
  identity:
    hostname: monitoring-server
    username: monitor
    password: '$6$rounds=4096$saltsalt$...'
```

## 🔒 Security Best Practices

### Password Generation

Generate secure password hashes for user accounts:

```bash
# For production systems
openssl passwd -6 -salt $(openssl rand -hex 16) "your_secure_password"

# For development environments  
openssl passwd -6 -salt $(openssl rand -hex 8) "dev_password"
```

### SSH Key Integration

Add SSH public keys for key-based authentication:

```yaml
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAA... user@hostname
  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... admin@workstation
```

### Network Security

Configure firewall rules in late-commands:

```yaml
late-commands:
  - ufw --force enable
  - ufw default deny incoming
  - ufw allow 22/tcp
  - ufw allow 80/tcp
  - ufw allow 443/tcp
```

## 🚀 Advanced Configurations

### Custom Package Repositories

Add third-party repositories for specialized software:

```yaml
late-commands:
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  - add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io
```

### Environment-Specific Configurations

Customize based on deployment environment:

```yaml
# Production
late-commands:
  - echo "ENVIRONMENT=production" >> /etc/environment
  - systemctl disable debug services

# Development  
late-commands:
  - echo "ENVIRONMENT=development" >> /etc/environment
  - systemctl enable debug services
```

## 📚 Configuration Reference

### Storage Layouts

**LVM Layout** (Recommended for servers):
```yaml
storage:
  layout:
    name: lvm
```

**Direct Layout** (For IoT/Edge devices):
```yaml
storage:
  layout:
    name: direct
```

### Network Configuration

**DHCP Configuration**:
```yaml
network:
  network:
    version: 2
    ethernets:
      enp0s3:
        dhcp4: true
```

**Static IP Configuration**:
```yaml
network:
  network:
    version: 2
    ethernets:
      enp0s3:
        addresses: [192.168.1.100/24]
        gateway4: 192.168.1.1
        nameservers:
          addresses: [8.8.8.8, 8.8.4.4]
```

### Package Installation Sources

**Standard Ubuntu Repository**:
```yaml
source:
  id: ubuntu-server
```

**Minimal Installation**:
```yaml
source:
  id: ubuntu-server-minimal
```

This comprehensive set of examples provides tested configurations for common deployment scenarios, enabling rapid customization for specific requirements.