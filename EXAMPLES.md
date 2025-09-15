# 📖 Konfigürasyon Örnekleri (Configuration Examples)

Bu dosya farklı kullanım senaryoları için hazır konfigürasyon örnekleri içerir.

## 📋 İçindekiler

1. [Geliştirme Ortamı](#-geliştirme-ortamı-development-environment)
2. [Üretim Sunucusu](#-üretim-sunucusu-production-server)
3. [IoT/Edge Cihaz](#-iotedge-cihaz)
4. [Kubernetes Node](#-kubernetes-node)
5. [Database Server](#-database-server)
6. [Web Server](#-web-server)
7. [Monitoring Server](#-monitoring-server)

---

## 🔧 Geliştirme Ortamı (Development Environment)

### user-data-dev.yml
```yaml
#cloud-config
autoinstall:
  version: 1
  
  identity:
    realname: "Developer"
    hostname: "dev-workstation"
    username: "developer"
    password: '$6$dev123hash...'  # Geliştirme için basit şifre
  
  early-commands:
    - echo "🔧 Development environment kurulumu başlıyor..."
    - apt update
  
  packages:
    # Geliştirme araçları
    - git
    - vim
    - nano
    - curl
    - wget
    - unzip
    - zip
    
    # Build araçları
    - build-essential
    - cmake
    - make
    - gcc
    - g++
    
    # Programlama dilleri
    - python3
    - python3-pip
    - python3-dev
    - nodejs
    - npm
    - openjdk-11-jdk
    
    # Container araçları
    - docker.io
    - docker-compose
    
    # Veritabanı araçları
    - postgresql-client
    - mysql-client
    - redis-tools
    
    # Network araçları
    - net-tools
    - htop
    - tree
    - jq
    
  locale: en_US
  keyboard:
    layout: tr
  
  user-data:
    users:
      - name: developer
        passwd: '$6$dev123hash...'
        groups: [sudo, docker, users]
        shell: /bin/bash
        ssh_authorized_keys:
          - "ssh-rsa AAAAB3NzaC1yc2EAAAA... dev@laptop"
  
  late-commands:
    # Docker'ı başlat
    - curtin in-target --target=/target -- systemctl enable docker
    - curtin in-target --target=/target -- systemctl start docker
    
    # Node.js güncel versiyonunu yükle
    - curtin in-target --target=/target -- npm install -g yarn
    - curtin in-target --target=/target -- npm install -g @vue/cli
    - curtin in-target --target=/target -- npm install -g create-react-app
    
    # Python geliştirme araçları
    - curtin in-target --target=/target -- pip3 install virtualenv
    - curtin in-target --target=/target -- pip3 install pipenv
    - curtin in-target --target=/target -- pip3 install black
    - curtin in-target --target=/target -- pip3 install flake8
    
    # Git konfigürasyonu
    - curtin in-target --target=/target -- git config --global init.defaultBranch main
    - curtin in-target --target=/target -- git config --global pull.rebase false
    
    # Geliştirme klasörleri
    - curtin in-target --target=/target -- mkdir -p /home/developer/projects
    - curtin in-target --target=/target -- mkdir -p /home/developer/scripts
    - curtin in-target --target=/target -- chown -R developer:developer /home/developer
    
    # VS Code repository ekle
    - curtin in-target --target=/target -- wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    - curtin in-target --target=/target -- install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    
    - echo "✅ Development environment kurulumu tamamlandı!"

# SSH konfigürasyonu
ssh:
  install-server: true
  allow-pw: true

# Snap paketleri
snaps:
  - name: code
    classic: true
  - name: discord
  - name: postman
```

---

## 🏭 Üretim Sunucusu (Production Server)

### user-data-production.yml
```yaml
#cloud-config
autoinstall:
  version: 1
  
  identity:
    realname: "Production Admin"
    hostname: "prod-server"
    username: "admin"
    password: '$6$veryStrongHashHere...'  # Güçlü şifre hash'i
  
  early-commands:
    - echo "🏭 Production server kurulumu başlıyor..."
    - apt update && apt upgrade -y
  
  packages:
    # Minimal gerekli paketler
    - unzip
    - curl
    - wget
    - net-tools
    - htop
    - vim
    
    # Güvenlik araçları
    - ufw
    - fail2ban
    - unattended-upgrades
    - logrotate
    
    # Monitoring araçları
    - collectd
    - rsyslog
    
    # Container runtime
    - docker.io
    
  locale: en_US
  keyboard:
    layout: us  # Production'da US layout
  
  user-data:
    users:
      - name: admin
        passwd: '$6$veryStrongHashHere...'
        groups: [sudo]
        shell: /bin/bash
        ssh_authorized_keys:
          - "ssh-rsa AAAAB3NzaC1yc2EAAAA... admin@management-server"
          - "ssh-rsa AAAAB3NzaC1yc2EAAAA... backup@backup-server"
  
  late-commands:
    # Güvenlik yapılandırması
    - curtin in-target --target=/target -- ufw enable
    - curtin in-target --target=/target -- ufw default deny incoming
    - curtin in-target --target=/target -- ufw default allow outgoing
    - curtin in-target --target=/target -- ufw allow 22/tcp  # SSH
    - curtin in-target --target=/target -- ufw allow 80/tcp  # HTTP
    - curtin in-target --target=/target -- ufw allow 443/tcp # HTTPS
    
    # Fail2ban konfigürasyonu
    - curtin in-target --target=/target -- systemctl enable fail2ban
    
    # Otomatik güncelleme
    - curtin in-target --target=/target -- systemctl enable unattended-upgrades
    
    # Docker konfigürasyonu
    - curtin in-target --target=/target -- systemctl enable docker
    - curtin in-target --target=/target -- usermod -aG docker admin
    
    # Log rotation
    - echo '/var/log/application/*.log { daily rotate 30 compress delaycompress missingok }' > /target/etc/logrotate.d/application
    
    # Sistem limitleri
    - echo 'admin soft nofile 65536' >> /target/etc/security/limits.conf
    - echo 'admin hard nofile 65536' >> /target/etc/security/limits.conf
    
    # Production klasörleri
    - curtin in-target --target=/target -- mkdir -p /opt/application
    - curtin in-target --target=/target -- mkdir -p /var/log/application
    - curtin in-target --target=/target -- chown admin:admin /opt/application
    
    - echo "✅ Production server hazır!"

# SSH sertleştirmesi
ssh:
  install-server: true
  allow-pw: false  # Sadece key authentication

# Güvenlik politikaları
apt:
  primary:
    - arches: [amd64]
      uri: http://security.ubuntu.com/ubuntu
  security:
    - arches: [amd64]
      uri: http://security.ubuntu.com/ubuntu
```

---

## 🌐 IoT/Edge Cihaz

### user-data-iot.yml
```yaml
#cloud-config
autoinstall:
  version: 1
  
  identity:
    realname: "IoT Device"
    hostname: "iot-edge-001"
    username: "iot"
    password: '$6$iotDeviceHash...'
  
  early-commands:
    - echo "🌐 IoT Edge device kurulumu..."
    - apt update
  
  packages:
    # Minimal sistem
    - unzip
    - curl
    - wget
    - net-tools
    
    # IoT araçları
    - mosquitto-clients  # MQTT client
    - python3
    - python3-pip
    - bluetooth
    - bluez
    
    # Edge computing
    - docker.io
    
  locale: en_US
  keyboard:
    layout: us
  
  user-data:
    users:
      - name: iot
        passwd: '$6$iotDeviceHash...'
        groups: [sudo, dialout, bluetooth]
        shell: /bin/bash
  
  late-commands:
    # IoT Python kütüphaneleri
    - curtin in-target --target=/target -- pip3 install paho-mqtt
    - curtin in-target --target=/target -- pip3 install requests
    - curtin in-target --target=/target -- pip3 install schedule
    - curtin in-target --target=/target -- pip3 install RPi.GPIO  # Raspberry Pi için
    
    # Docker IoT container'ları
    - curtin in-target --target=/target -- systemctl enable docker
    - curtin in-target --target=/target -- usermod -aG docker iot
    
    # Bluetooth aktif
    - curtin in-target --target=/target -- systemctl enable bluetooth
    
    # IoT klasörleri
    - curtin in-target --target=/target -- mkdir -p /opt/iot-app
    - curtin in-target --target=/target -- mkdir -p /var/log/iot
    - curtin in-target --target=/target -- chown -R iot:iot /opt/iot-app
    
    # Güç yönetimi
    - echo 'ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1234", ATTR{idProduct}=="5678", RUN+="/opt/iot-app/usb-handler.sh"' > /target/etc/udev/rules.d/99-iot-devices.rules
    
    - echo "✅ IoT Edge device hazır!"

# Ağ konfigürasyonu
network:
  version: 2
  ethernets:
    any:
      match:
        name: "e*"
      dhcp4: true
  wifis:
    any:
      match:
        name: "w*"
      dhcp4: true
      access-points:
        "IoTNetwork":
          password: "iot-wifi-password"
```

---

## ☸️ Kubernetes Node

### user-data-k8s-node.yml
```yaml
#cloud-config
autoinstall:
  version: 1
  
  identity:
    realname: "Kubernetes Node"
    hostname: "k8s-worker-01"
    username: "k8s"
    password: '$6$k8sNodeHash...'
  
  early-commands:
    - echo "☸️ Kubernetes node kurulumu..."
    - apt update && apt upgrade -y
  
  packages:
    # Sistem araçları
    - curl
    - wget
    - apt-transport-https
    - ca-certificates
    - gnupg
    - lsb-release
    
    # Container runtime
    - containerd
    
    # Network araçları
    - net-tools
    - iptables
    - ebtables
    - ethtool
    
  locale: en_US
  keyboard:
    layout: us
  
  user-data:
    users:
      - name: k8s
        passwd: '$6$k8sNodeHash...'
        groups: [sudo]
        shell: /bin/bash
        ssh_authorized_keys:
          - "ssh-rsa AAAAB3NzaC1yc2EAAAA... k8s-master@cluster"
  
  late-commands:
    # Swap'ı deaktif et (Kubernetes gereksinimi)
    - curtin in-target --target=/target -- swapoff -a
    - curtin in-target --target=/target -- sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    
    # Kernel modülleri
    - echo 'br_netfilter' >> /target/etc/modules-load.d/k8s.conf
    - echo 'overlay' >> /target/etc/modules-load.d/k8s.conf
    
    # Sysctl ayarları
    - echo 'net.bridge.bridge-nf-call-iptables = 1' >> /target/etc/sysctl.d/k8s.conf
    - echo 'net.bridge.bridge-nf-call-ip6tables = 1' >> /target/etc/sysctl.d/k8s.conf
    - echo 'net.ipv4.ip_forward = 1' >> /target/etc/sysctl.d/k8s.conf
    
    # Containerd konfigürasyonu
    - curtin in-target --target=/target -- mkdir -p /etc/containerd
    - curtin in-target --target=/target -- containerd config default > /etc/containerd/config.toml
    - curtin in-target --target=/target -- systemctl enable containerd
    
    # Kubernetes repository ekle
    - curtin in-target --target=/target -- curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    - echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /target/etc/apt/sources.list.d/kubernetes.list
    
    # Kubernetes araçlarını yükle
    - curtin in-target --target=/target -- apt update
    - curtin in-target --target=/target -- apt install -y kubelet kubeadm kubectl
    - curtin in-target --target=/target -- apt-mark hold kubelet kubeadm kubectl
    
    # Kubelet'i enable et
    - curtin in-target --target=/target -- systemctl enable kubelet
    
    - echo "✅ Kubernetes node hazır! Master'dan 'kubeadm join' komutu ile ekleyin."

# Sistem optimizasyonu
storage:
  layout:
    name: direct
    match:
      size: largest
```

---

## 🗄️ Database Server

### user-data-database.yml
```yaml
#cloud-config
autoinstall:
  version: 1
  
  identity:
    realname: "Database Admin"
    hostname: "db-server"
    username: "dbadmin"
    password: '$6$dbServerHash...'
  
  early-commands:
    - echo "🗄️ Database server kurulumu..."
    - apt update && apt upgrade -y
  
  packages:
    # Database sunucuları
    - postgresql-14
    - postgresql-contrib
    - redis-server
    
    # Yönetim araçları
    - postgresql-client
    - redis-tools
    
    # Sistem araçları
    - htop
    - iotop
    - sysstat
    - curl
    - wget
    
    # Backup araçları
    - rsync
    - cron
    
  locale: en_US
  keyboard:
    layout: us
  
  user-data:
    users:
      - name: dbadmin
        passwd: '$6$dbServerHash...'
        groups: [sudo, postgres]
        shell: /bin/bash
        ssh_authorized_keys:
          - "ssh-rsa AAAAB3NzaC1yc2EAAAA... backup@backup-server"
  
  late-commands:
    # PostgreSQL konfigürasyonu
    - curtin in-target --target=/target -- systemctl enable postgresql
    - curtin in-target --target=/target -- systemctl start postgresql
    
    # PostgreSQL kullanıcısı oluştur
    - curtin in-target --target=/target -- sudo -u postgres createuser --createdb --login --superuser dbadmin
    - curtin in-target --target=/target -- sudo -u postgres psql -c "ALTER USER dbadmin PASSWORD 'strong_db_password';"
    
    # Redis konfigürasyonu
    - curtin in-target --target=/target -- systemctl enable redis-server
    - echo 'requirepass redis_strong_password' >> /target/etc/redis/redis.conf
    - echo 'maxmemory 1gb' >> /target/etc/redis/redis.conf
    - echo 'maxmemory-policy allkeys-lru' >> /target/etc/redis/redis.conf
    
    # Database klasörleri
    - curtin in-target --target=/target -- mkdir -p /var/backups/postgresql
    - curtin in-target --target=/target -- mkdir -p /var/backups/redis
    - curtin in-target --target=/target -- chown postgres:postgres /var/backups/postgresql
    - curtin in-target --target=/target -- chown redis:redis /var/backups/redis
    
    # Backup scripti
    - |
      cat > /target/usr/local/bin/db-backup.sh << 'EOF'
      #!/bin/bash
      DATE=$(date +%Y%m%d_%H%M%S)
      
      # PostgreSQL backup
      sudo -u postgres pg_dumpall > /var/backups/postgresql/full_backup_${DATE}.sql
      
      # Redis backup
      cp /var/lib/redis/dump.rdb /var/backups/redis/redis_backup_${DATE}.rdb
      
      # Eski backupları temizle (7 günden eski)
      find /var/backups/postgresql -name "*.sql" -mtime +7 -delete
      find /var/backups/redis -name "*.rdb" -mtime +7 -delete
      
      echo "Backup completed: ${DATE}"
      EOF
    
    - curtin in-target --target=/target -- chmod +x /usr/local/bin/db-backup.sh
    
    # Günlük backup cron job
    - echo "0 2 * * * /usr/local/bin/db-backup.sh >> /var/log/backup.log 2>&1" | crontab -u root -
    
    # Güvenlik ayarları
    - curtin in-target --target=/target -- ufw enable
    - curtin in-target --target=/target -- ufw allow 22/tcp
    - curtin in-target --target=/target -- ufw allow 5432/tcp  # PostgreSQL
    - curtin in-target --target=/target -- ufw allow 6379/tcp  # Redis
    
    - echo "✅ Database server hazır!"

# Disk optimizasyonu
storage:
  layout:
    name: direct
    match:
      size: largest
  config:
    - type: disk
      id: main_disk
      match:
        size: largest
    - type: partition
      id: root_part
      device: main_disk
      size: 20G
    - type: partition
      id: data_part
      device: main_disk
      size: -1  # Kalan tüm alan
    - type: format
      id: root_fs
      volume: root_part
      fstype: ext4
    - type: format
      id: data_fs
      volume: data_part
      fstype: ext4
    - type: mount
      id: root_mount
      device: root_fs
      path: /
    - type: mount
      id: data_mount
      device: data_fs
      path: /var/lib/postgresql
```

---

## 🌐 Web Server

### user-data-webserver.yml
```yaml
#cloud-config
autoinstall:
  version: 1
  
  identity:
    realname: "Web Admin"
    hostname: "web-server"
    username: "webadmin"
    password: '$6$webServerHash...'
  
  early-commands:
    - echo "🌐 Web server kurulumu..."
    - apt update && apt upgrade -y
  
  packages:
    # Web sunucuları
    - nginx
    - apache2-utils  # htpasswd gibi araçlar
    
    # SSL/TLS
    - certbot
    - python3-certbot-nginx
    
    # PHP (isteğe bağlı)
    - php8.1-fpm
    - php8.1-mysql
    - php8.1-curl
    - php8.1-gd
    - php8.1-mbstring
    - php8.1-xml
    - php8.1-zip
    
    # Node.js
    - nodejs
    - npm
    
    # Sistem araçları
    - curl
    - wget
    - htop
    - unzip
    
  locale: en_US
  keyboard:
    layout: us
  
  user-data:
    users:
      - name: webadmin
        passwd: '$6$webServerHash...'
        groups: [sudo, www-data]
        shell: /bin/bash
        ssh_authorized_keys:
          - "ssh-rsa AAAAB3NzaC1yc2EAAAA... deploy@ci-server"
  
  late-commands:
    # Nginx konfigürasyonu
    - curtin in-target --target=/target -- systemctl enable nginx
    
    # PHP-FPM konfigürasyonu
    - curtin in-target --target=/target -- systemctl enable php8.1-fpm
    
    # Web klasörleri oluştur
    - curtin in-target --target=/target -- mkdir -p /var/www/html
    - curtin in-target --target=/target -- mkdir -p /var/www/backup
    - curtin in-target --target=/target -- chown -R www-data:www-data /var/www
    
    # Nginx güvenlik ayarları
    - |
      cat > /target/etc/nginx/conf.d/security.conf << 'EOF'
      # Güvenlik headers
      add_header X-Frame-Options "SAMEORIGIN" always;
      add_header X-XSS-Protection "1; mode=block" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header Referrer-Policy "no-referrer-when-downgrade" always;
      add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
      
      # Server tokens gizle
      server_tokens off;
      
      # Rate limiting
      limit_req_zone $binary_remote_addr zone=login:10m rate=10r/m;
      EOF
    
    # SSL için hazırlık
    - curtin in-target --target=/target -- mkdir -p /etc/nginx/ssl
    - curtin in-target --target=/target -- openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
    
    # Log rotation
    - |
      cat > /target/etc/logrotate.d/nginx-custom << 'EOF'
      /var/log/nginx/*.log {
          daily
          missingok
          rotate 30
          compress
          delaycompress
          notifempty
          create 0644 www-data adm
          sharedscripts
          postrotate
              if [ -f /var/run/nginx.pid ]; then
                  kill -USR1 `cat /var/run/nginx.pid`
              fi
          endscript
      }
      EOF
    
    # Node.js global paketler
    - curtin in-target --target=/target -- npm install -g pm2
    - curtin in-target --target=/target -- npm install -g @angular/cli
    
    # Firewall ayarları
    - curtin in-target --target=/target -- ufw enable
    - curtin in-target --target=/target -- ufw allow 22/tcp   # SSH
    - curtin in-target --target=/target -- ufw allow 80/tcp   # HTTP
    - curtin in-target --target=/target -- ufw allow 443/tcp  # HTTPS
    
    # Demo sayfa
    - |
      cat > /target/var/www/html/index.html << 'EOF'
      <!DOCTYPE html>
      <html>
      <head>
          <title>Web Server Ready</title>
          <style>
              body { font-family: Arial; text-align: center; margin-top: 50px; }
              .container { max-width: 600px; margin: 0 auto; }
              .status { color: green; font-size: 24px; }
          </style>
      </head>
      <body>
          <div class="container">
              <h1>🌐 Web Server</h1>
              <p class="status">✅ Server is running!</p>
              <p>Hostname: web-server</p>
              <p>Nginx version: $(nginx -v 2>&1)</p>
              <p>PHP version: $(php -v | head -n1)</p>
          </div>
      </body>
      </html>
      EOF
    
    - echo "✅ Web server hazır!"

# SSL sertifikası otomatik yenileme
write_files:
  - path: /etc/cron.d/certbot
    content: |
      0 12 * * * root test -x /usr/bin/certbot -a \! -d /run/systemd/system && perl -e 'sleep int(rand(43200))' && certbot -q renew
```

---

## 📊 Monitoring Server

### user-data-monitoring.yml
```yaml
#cloud-config
autoinstall:
  version: 1
  
  identity:
    realname: "Monitor Admin"
    hostname: "monitor-server"
    username: "monitor"
    password: '$6$monitorHash...'
  
  early-commands:
    - echo "📊 Monitoring server kurulumu..."
    - apt update && apt upgrade -y
  
  packages:
    # Monitoring araçları
    - prometheus
    - grafana
    - node-exporter
    
    # Log yönetimi
    - rsyslog
    - logrotate
    
    # Network monitoring
    - net-tools
    - iftop
    - nethogs
    - tcpdump
    
    # Sistem monitoring
    - htop
    - iotop
    - sysstat
    - lsof
    
    # Container monitoring
    - docker.io
    
    # Notification
    - postfix
    
  locale: en_US
  keyboard:
    layout: us
  
  user-data:
    users:
      - name: monitor
        passwd: '$6$monitorHash...'
        groups: [sudo, docker]
        shell: /bin/bash
        ssh_authorized_keys:
          - "ssh-rsa AAAAB3NzaC1yc2EAAAA... admin@management"
  
  late-commands:
    # Prometheus konfigürasyonu
    - curtin in-target --target=/target -- systemctl enable prometheus
    - |
      cat > /target/etc/prometheus/prometheus.yml << 'EOF'
      global:
        scrape_interval: 15s
        evaluation_interval: 15s
      
      scrape_configs:
        - job_name: 'prometheus'
          static_configs:
            - targets: ['localhost:9090']
        
        - job_name: 'node'
          static_configs:
            - targets: ['localhost:9100']
        
        - job_name: 'docker'
          static_configs:
            - targets: ['localhost:9323']
      EOF
    
    # Grafana konfigürasyonu
    - curtin in-target --target=/target -- systemctl enable grafana-server
    
    # Node exporter
    - curtin in-target --target=/target -- systemctl enable prometheus-node-exporter
    
    # Docker monitoring
    - |
      cat > /target/etc/docker/daemon.json << 'EOF'
      {
        "metrics-addr": "127.0.0.1:9323",
        "experimental": true
      }
      EOF
    
    - curtin in-target --target=/target -- systemctl enable docker
    
    # Alert manager konfigürasyonu
    - curtin in-target --target=/target -- mkdir -p /etc/alertmanager
    - |
      cat > /target/etc/alertmanager/alertmanager.yml << 'EOF'
      global:
        smtp_smarthost: 'localhost:587'
        smtp_from: 'monitoring@company.com'
      
      route:
        group_by: ['alertname']
        group_wait: 10s
        group_interval: 10s
        repeat_interval: 1h
        receiver: 'web.hook'
      
      receivers:
        - name: 'web.hook'
          email_configs:
            - to: 'admin@company.com'
              subject: 'Alert: {{ .GroupLabels.alertname }}'
              body: |
                {{ range .Alerts }}
                Alert: {{ .Annotations.summary }}
                Description: {{ .Annotations.description }}
                {{ end }}
      EOF
    
    # Log aggregation
    - |
      cat > /target/etc/rsyslog.d/50-monitoring.conf << 'EOF'
      # Merkezi log toplama
      $ModLoad imudp
      $UDPServerRun 514
      $UDPServerAddress 0.0.0.0
      
      # Log dosyaları
      *.info;mail.none;authpriv.none;cron.none /var/log/messages
      authpriv.* /var/log/secure
      mail.* /var/log/maillog
      cron.* /var/log/cron
      *.emerg *
      uucp,news.crit /var/log/spooler
      local7.* /var/log/boot.log
      EOF
    
    # Firewall ayarları
    - curtin in-target --target=/target -- ufw enable
    - curtin in-target --target=/target -- ufw allow 22/tcp    # SSH
    - curtin in-target --target=/target -- ufw allow 3000/tcp  # Grafana
    - curtin in-target --target=/target -- ufw allow 9090/tcp  # Prometheus
    - curtin in-target --target=/target -- ufw allow 514/udp   # Syslog
    
    # Monitoring klasörleri
    - curtin in-target --target=/target -- mkdir -p /var/monitoring/data
    - curtin in-target --target=/target -- mkdir -p /var/monitoring/logs
    - curtin in-target --target=/target -- chown -R monitor:monitor /var/monitoring
    
    # Backup script
    - |
      cat > /target/usr/local/bin/monitoring-backup.sh << 'EOF'
      #!/bin/bash
      DATE=$(date +%Y%m%d_%H%M%S)
      
      # Prometheus data backup
      tar -czf /var/monitoring/prometheus_backup_${DATE}.tar.gz /var/lib/prometheus/
      
      # Grafana backup
      tar -czf /var/monitoring/grafana_backup_${DATE}.tar.gz /var/lib/grafana/
      
      # Cleanup old backups
      find /var/monitoring -name "*_backup_*.tar.gz" -mtime +7 -delete
      
      echo "Monitoring backup completed: ${DATE}"
      EOF
    
    - curtin in-target --target=/target -- chmod +x /usr/local/bin/monitoring-backup.sh
    
    # Günlük backup
    - echo "0 3 * * * /usr/local/bin/monitoring-backup.sh >> /var/log/monitoring-backup.log 2>&1" | crontab -u monitor -
    
    - echo "✅ Monitoring server hazır!"
    - echo "📊 Grafana: http://server-ip:3000 (admin/admin)"
    - echo "📈 Prometheus: http://server-ip:9090"

# Sistem optimizasyonu
storage:
  layout:
    name: direct
  swap:
    size: 0  # Monitoring server için swap kapalı
```

---

## 📚 Kullanım Talimatları

### 1. Konfigürasyon Seçimi
```bash
# İstediğiniz konfigürasyonu kopyalayın
cp EXAMPLES/user-data-dev.yml custom-iso-editor/config/user-data

# Gerekli düzenlemeleri yapın
nano custom-iso-editor/config/user-data
```

### 2. Şifre Hash'i Güncelleme
```bash
# Güçlü şifre oluşturun
openssl passwd -6 -salt $(openssl rand -hex 16) "YourStrongPassword"

# Çıktıyı konfigürasyon dosyasına kopyalayın
```

### 3. SSH Anahtarı Ekleme
```bash
# SSH anahtar çifti oluşturun
ssh-keygen -t rsa -b 4096 -C "admin@company.com"

# Public key'i konfigürasyona ekleyin
cat ~/.ssh/id_rsa.pub
```

### 4. ISO Oluşturma
```bash
# Konfigürasyonu uygula
make iso_setup
make iso_setup-isolinux

# ISO oluştur
make iso_geniso-isolinux
```

### 5. Test ve Dağıtım
```bash
# QEMU ile test
qemu-system-x86_64 -cdrom custom-iso-editor/user_iso_files/*.iso -m 2048

# USB'ye yaz (DİKKAT!)
make iso_write_usb
```

---

## ⚠️ Güvenlik Notları

1. **Üretim Ortamları İçin:**
   - Mutlaka güçlü şifreler kullanın
   - SSH key authentication tercih edin
   - Firewall kurallarını gözden geçirin
   - Güncellemeleri otomatikleştirin

2. **Test Ortamları İçin:**
   - Basit şifreler kullanabilirsiniz
   - Geliştirme araçlarını dahil edin
   - Debug özellikleri aktifleştirin

3. **Monitoring İçin:**
   - Log rotation'ı mutlaka yapın
   - Disk alanını izleyin
   - Alert thresholdları ayarlayın

---

**Bu örnekleri ihtiyacınıza göre özelleştirin ve test edin! 🚀**